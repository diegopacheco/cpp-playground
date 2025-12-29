#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <simd/simd.h>
#import <ApplicationServices/ApplicationServices.h>
#include <vector>
#include <cmath>
#include <random>

struct Vertex {
    simd_float3 position;
    simd_float3 normal;
    simd_float3 color;
};

struct RainParticle {
    simd_float3 position;
    float velocity;
};

struct Uniforms {
    simd_float4x4 model;
    simd_float4x4 view;
    simd_float4x4 proj;
    simd_float3 camPos;
    float time;
    simd_float3 lightDir;
    float fogDensity;
    simd_float3 fogColor;
    float rain;
};

simd_float4x4 matrix_perspective(float fovyRadians, float aspect, float nearZ, float farZ) {
    float ys = 1 / tanf(fovyRadians * 0.5);
    float xs = ys / aspect;
    float zs = farZ / (nearZ - farZ);
    return (simd_float4x4){{
        {xs, 0, 0, 0},
        {0, ys, 0, 0},
        {0, 0, zs, -1},
        {0, 0, nearZ * zs, 0}
    }};
}

simd_float4x4 matrix_look_at(simd_float3 eye, simd_float3 target, simd_float3 up) {
    simd_float3 z = simd_normalize(eye - target);
    simd_float3 x = simd_normalize(simd_cross(up, z));
    simd_float3 y = simd_cross(z, x);
    return (simd_float4x4){{
        {x.x, y.x, z.x, 0},
        {x.y, y.y, z.y, 0},
        {x.z, y.z, z.z, 0},
        {-simd_dot(x, eye), -simd_dot(y, eye), -simd_dot(z, eye), 1}
    }};
}

simd_float4x4 matrix_identity() {
    return (simd_float4x4){{
        {1, 0, 0, 0},
        {0, 1, 0, 0},
        {0, 0, 1, 0},
        {0, 0, 0, 1}
    }};
}

simd_float4x4 matrix_translation(float x, float y, float z) {
    simd_float4x4 m = matrix_identity();
    m.columns[3] = (simd_float4){x, y, z, 1};
    return m;
}

simd_float4x4 matrix_rotation_y(float angle) {
    float c = cosf(angle);
    float s = sinf(angle);
    return (simd_float4x4){{
        {c, 0, -s, 0},
        {0, 1, 0, 0},
        {s, 0, c, 0},
        {0, 0, 0, 1}
    }};
}

@interface Renderer : NSObject <MTKViewDelegate>
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong) id<MTLRenderPipelineState> rainPipelineState;
@property (nonatomic, strong) id<MTLDepthStencilState> depthState;
@property (nonatomic, strong) id<MTLBuffer> uniformBuffer;
@property (nonatomic, strong) id<MTLBuffer> sceneBuffer;
@property (nonatomic, assign) NSUInteger sceneVertexCount;
@property (nonatomic, strong) id<MTLBuffer> rainBuffer;
@property (nonatomic, assign) NSUInteger rainParticleCount;
@property (nonatomic, assign) simd_float3 cameraPosition;
@property (nonatomic, assign) float cameraYaw;
@property (nonatomic, assign) float cameraPitch;
@property (nonatomic, assign) float time;
@property (nonatomic, assign) BOOL keyW, keyA, keyS, keyD, keySpace, keyShift;
@end

@implementation Renderer

- (instancetype)initWithMetalKitView:(MTKView *)view {
    self = [super init];
    if (self) {
        _device = view.device;
        _commandQueue = [_device newCommandQueue];
        _cameraPosition = (simd_float3){0, 2.0, 15};
        _cameraYaw = 0;
        _cameraPitch = 0;
        _time = 0;
        [self setupPipelines:view];
        [self generateScene];
        [self generateRain];
    }
    return self;
}

- (void)setupPipelines:(MTKView *)view {
    NSError *error;
    NSString *shaderSource = @R"(
        #include <metal_stdlib>
        using namespace metal;
        struct VertexIn { float3 position [[attribute(0)]]; float3 normal [[attribute(1)]]; float3 color [[attribute(2)]]; };
        struct VertexOut { float4 position [[position]]; float3 normal; float3 color; float fog; };
        struct Uniforms { float4x4 model; float4x4 view; float4x4 proj; float3 camPos; float time; float3 lightDir; float fogDensity; float3 fogColor; float rain; };
        vertex VertexOut vertex_main(VertexIn in [[stage_in]], constant Uniforms& u [[buffer(1)]]) {
            VertexOut out;
            float4 world = u.model * float4(in.position, 1.0);
            out.position = u.proj * u.view * world;
            out.normal = normalize((u.model * float4(in.normal, 0.0)).xyz);
            out.color = in.color;
            out.fog = clamp(1.0 - exp(-u.fogDensity * length(world.xyz - u.camPos) * 0.015), 0.0, 0.8);
            return out;
        }
        fragment float4 fragment_main(VertexOut in [[stage_in]], constant Uniforms& u [[buffer(1)]]) {
            float light = 0.3 + 0.5 * max(dot(in.normal, normalize(u.lightDir)), 0.0);
            float3 col = in.color * light * (1.0 - u.rain * 0.2);
            return float4(mix(col, u.fogColor, in.fog), 1.0);
        }
        struct RainIn { float3 position [[attribute(0)]]; float velocity [[attribute(1)]]; };
        struct RainOut { float4 position [[position]]; float alpha; float size [[point_size]]; };
        vertex RainOut rain_vertex(RainIn in [[stage_in]], constant Uniforms& u [[buffer(1)]]) {
            RainOut out;
            float3 pos = in.position;
            pos.y -= fmod(u.time * (20.0 + in.velocity * 15.0) + in.velocity * 100.0, 50.0);
            if (pos.y < 0.0) pos.y += 50.0;
            out.position = u.proj * u.view * float4(pos, 1.0);
            float d = length(pos - u.camPos);
            out.alpha = clamp(1.0 - d / 60.0, 0.0, 0.5) * u.rain;
            out.size = max(1.5, 4.0 - d * 0.06);
            return out;
        }
        fragment float4 rain_fragment(RainOut in [[stage_in]]) { return float4(0.7, 0.75, 0.85, in.alpha); }
    )";

    MTLCompileOptions *options = [[MTLCompileOptions alloc] init];
    id<MTLLibrary> library = [_device newLibraryWithSource:shaderSource options:options error:&error];

    MTLVertexDescriptor *vd = [[MTLVertexDescriptor alloc] init];
    vd.attributes[0].format = MTLVertexFormatFloat3; vd.attributes[0].offset = 0; vd.attributes[0].bufferIndex = 0;
    vd.attributes[1].format = MTLVertexFormatFloat3; vd.attributes[1].offset = 12; vd.attributes[1].bufferIndex = 0;
    vd.attributes[2].format = MTLVertexFormatFloat3; vd.attributes[2].offset = 24; vd.attributes[2].bufferIndex = 0;
    vd.layouts[0].stride = sizeof(Vertex);

    MTLRenderPipelineDescriptor *pd = [[MTLRenderPipelineDescriptor alloc] init];
    pd.vertexFunction = [library newFunctionWithName:@"vertex_main"];
    pd.fragmentFunction = [library newFunctionWithName:@"fragment_main"];
    pd.vertexDescriptor = vd;
    pd.colorAttachments[0].pixelFormat = view.colorPixelFormat;
    pd.depthAttachmentPixelFormat = view.depthStencilPixelFormat;
    _pipelineState = [_device newRenderPipelineStateWithDescriptor:pd error:&error];

    MTLVertexDescriptor *rvd = [[MTLVertexDescriptor alloc] init];
    rvd.attributes[0].format = MTLVertexFormatFloat3; rvd.attributes[0].offset = 0; rvd.attributes[0].bufferIndex = 0;
    rvd.attributes[1].format = MTLVertexFormatFloat; rvd.attributes[1].offset = 12; rvd.attributes[1].bufferIndex = 0;
    rvd.layouts[0].stride = sizeof(RainParticle);

    MTLRenderPipelineDescriptor *rpd = [[MTLRenderPipelineDescriptor alloc] init];
    rpd.vertexFunction = [library newFunctionWithName:@"rain_vertex"];
    rpd.fragmentFunction = [library newFunctionWithName:@"rain_fragment"];
    rpd.vertexDescriptor = rvd;
    rpd.colorAttachments[0].pixelFormat = view.colorPixelFormat;
    rpd.colorAttachments[0].blendingEnabled = YES;
    rpd.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactorSourceAlpha;
    rpd.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    rpd.depthAttachmentPixelFormat = view.depthStencilPixelFormat;
    _rainPipelineState = [_device newRenderPipelineStateWithDescriptor:rpd error:&error];

    MTLDepthStencilDescriptor *dsd = [[MTLDepthStencilDescriptor alloc] init];
    dsd.depthCompareFunction = MTLCompareFunctionLess;
    dsd.depthWriteEnabled = YES;
    _depthState = [_device newDepthStencilStateWithDescriptor:dsd];
    _uniformBuffer = [_device newBufferWithLength:sizeof(Uniforms) options:MTLResourceStorageModeShared];
}

- (void)addQuad:(std::vector<Vertex>&)v p0:(simd_float3)p0 p1:(simd_float3)p1 p2:(simd_float3)p2 p3:(simd_float3)p3 c:(simd_float3)c {
    simd_float3 n = simd_normalize(simd_cross(p1 - p0, p3 - p0));
    v.push_back({p0, n, c}); v.push_back({p1, n, c}); v.push_back({p2, n, c});
    v.push_back({p0, n, c}); v.push_back({p2, n, c}); v.push_back({p3, n, c});
}

- (void)addBox:(std::vector<Vertex>&)v pos:(simd_float3)pos size:(simd_float3)s c:(simd_float3)c {
    float x = pos.x, y = pos.y, z = pos.z, w = s.x/2, h = s.y, d = s.z/2;
    [self addQuad:v p0:{x-w,y,z+d} p1:{x+w,y,z+d} p2:{x+w,y+h,z+d} p3:{x-w,y+h,z+d} c:c];
    [self addQuad:v p0:{x+w,y,z-d} p1:{x-w,y,z-d} p2:{x-w,y+h,z-d} p3:{x+w,y+h,z-d} c:c];
    [self addQuad:v p0:{x-w,y,z-d} p1:{x-w,y,z+d} p2:{x-w,y+h,z+d} p3:{x-w,y+h,z-d} c:c];
    [self addQuad:v p0:{x+w,y,z+d} p1:{x+w,y,z-d} p2:{x+w,y+h,z-d} p3:{x+w,y+h,z+d} c:c];
    [self addQuad:v p0:{x-w,y+h,z+d} p1:{x+w,y+h,z+d} p2:{x+w,y+h,z-d} p3:{x-w,y+h,z-d} c:c];
}

- (void)generateScene {
    std::vector<Vertex> vertices;
    std::mt19937 rng(42);

    for (int i = -25; i < 25; i++) {
        for (int j = -25; j < 25; j++) {
            float x = i * 2.0f, z = j * 2.0f;
            float g = 0.15f + (rng() % 100) / 1000.0f;
            simd_float3 gc = {0.1f + g, 0.25f + g, 0.08f + g * 0.5f};
            simd_float3 n = {0, 1, 0};
            vertices.push_back({{x, 0, z}, n, gc});
            vertices.push_back({{x+2, 0, z}, n, gc});
            vertices.push_back({{x+2, 0, z+2}, n, gc});
            vertices.push_back({{x, 0, z}, n, gc});
            vertices.push_back({{x+2, 0, z+2}, n, gc});
            vertices.push_back({{x, 0, z+2}, n, gc});
        }
    }

    std::uniform_real_distribution<float> posDist(-40, 40);
    for (int t = 0; t < 30; t++) {
        float x = posDist(rng), z = posDist(rng);
        float h = 6 + (rng() % 80) / 10.0f;
        simd_float3 trunk = {0.4f, 0.25f, 0.15f};
        [self addBox:vertices pos:{x, 0, z} size:{0.6f, h * 0.6f, 0.6f} c:trunk];
        float ly = h * 0.35f;
        for (int l = 0; l < 3; l++) {
            float r = 3.0f - l * 0.7f;
            float lh = 2.5f;
            float gv = (rng() % 50) / 500.0f;
            simd_float3 leaf = {0.1f + gv, 0.45f + gv, 0.1f + gv * 0.3f};
            [self addBox:vertices pos:{x, ly, z} size:{r * 2, lh, r * 2} c:leaf];
            ly += lh * 0.7f;
        }
    }

    for (int i = 0; i < 5; i++) {
        float x = posDist(rng), z = posDist(rng);
        simd_float3 body = {0.5f, 0.35f, 0.2f};
        [self addBox:vertices pos:{x, 0, z} size:{1.0f, 0.6f, 0.6f} c:body];
        [self addBox:vertices pos:{x + 0.4f, 0.3f, z} size:{0.4f, 0.4f, 0.4f} c:body];
        simd_float3 leg = {0.35f, 0.25f, 0.15f};
        [self addBox:vertices pos:{x - 0.25f, 0, z - 0.15f} size:{0.15f, 0.3f, 0.15f} c:leg];
        [self addBox:vertices pos:{x - 0.25f, 0, z + 0.15f} size:{0.15f, 0.3f, 0.15f} c:leg];
        [self addBox:vertices pos:{x + 0.25f, 0, z - 0.15f} size:{0.15f, 0.3f, 0.15f} c:leg];
        [self addBox:vertices pos:{x + 0.25f, 0, z + 0.15f} size:{0.15f, 0.3f, 0.15f} c:leg];
    }

    for (int i = 0; i < 4; i++) {
        float x = posDist(rng), z = posDist(rng);
        simd_float3 frog = {0.2f, 0.55f, 0.15f};
        [self addBox:vertices pos:{x, 0, z} size:{0.4f, 0.25f, 0.35f} c:frog];
        [self addBox:vertices pos:{x + 0.15f, 0.1f, z} size:{0.2f, 0.2f, 0.25f} c:frog];
    }

    for (int i = 0; i < 3; i++) {
        float x = posDist(rng), z = posDist(rng);
        simd_float3 monkey = {0.15f, 0.12f, 0.1f};
        [self addBox:vertices pos:{x, 2.5f, z} size:{0.5f, 0.6f, 0.4f} c:monkey];
        [self addBox:vertices pos:{x, 3.0f, z} size:{0.35f, 0.35f, 0.3f} c:monkey];
    }

    for (int i = 0; i < 6; i++) {
        float x = posDist(rng), z = posDist(rng);
        simd_float3 bird;
        int c = rng() % 3;
        if (c == 0) bird = {0.9f, 0.2f, 0.1f};
        else if (c == 1) bird = {0.1f, 0.3f, 0.9f};
        else bird = {0.95f, 0.85f, 0.1f};
        [self addBox:vertices pos:{x, 4 + (rng() % 30) / 10.0f, z} size:{0.3f, 0.2f, 0.5f} c:bird];
    }

    _sceneVertexCount = vertices.size();
    _sceneBuffer = [_device newBufferWithBytes:vertices.data() length:vertices.size() * sizeof(Vertex) options:MTLResourceStorageModeShared];
}

- (void)generateRain {
    std::vector<RainParticle> particles;
    std::mt19937 rng(999);
    std::uniform_real_distribution<float> posDist(-50, 50);
    std::uniform_real_distribution<float> heightDist(0, 50);
    std::uniform_real_distribution<float> velDist(0, 1);
    _rainParticleCount = 2000;
    for (NSUInteger i = 0; i < _rainParticleCount; i++) {
        particles.push_back({{posDist(rng), heightDist(rng), posDist(rng)}, velDist(rng)});
    }
    _rainBuffer = [_device newBufferWithBytes:particles.data() length:particles.size() * sizeof(RainParticle) options:MTLResourceStorageModeShared];
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {}

- (void)drawInMTKView:(MTKView *)view {
    _time += 1.0f / 60.0f;
    float speed = 6.0f / 60.0f;
    simd_float3 fwd = {sinf(_cameraYaw), 0, -cosf(_cameraYaw)};
    simd_float3 right = {cosf(_cameraYaw), 0, sinf(_cameraYaw)};
    if (_keyW) _cameraPosition = _cameraPosition + fwd * speed;
    if (_keyS) _cameraPosition = _cameraPosition - fwd * speed;
    if (_keyA) _cameraPosition = _cameraPosition - right * speed;
    if (_keyD) _cameraPosition = _cameraPosition + right * speed;
    if (_keySpace) _cameraPosition.y += speed;
    if (_keyShift) _cameraPosition.y -= speed;
    _cameraPosition.y = fmaxf(_cameraPosition.y, 1.5f);

    id<MTLCommandBuffer> cmd = [_commandQueue commandBuffer];
    MTLRenderPassDescriptor *rpd = view.currentRenderPassDescriptor;
    if (rpd) {
        rpd.colorAttachments[0].clearColor = MTLClearColorMake(0.45, 0.5, 0.55, 1.0);
        id<MTLRenderCommandEncoder> enc = [cmd renderCommandEncoderWithDescriptor:rpd];
        [enc setDepthStencilState:_depthState];

        float aspect = view.drawableSize.width / view.drawableSize.height;
        simd_float3 lookDir = {sinf(_cameraYaw) * cosf(_cameraPitch), sinf(_cameraPitch), -cosf(_cameraYaw) * cosf(_cameraPitch)};

        Uniforms u;
        u.model = matrix_identity();
        u.view = matrix_look_at(_cameraPosition, _cameraPosition + lookDir, (simd_float3){0, 1, 0});
        u.proj = matrix_perspective(M_PI / 3.0f, aspect, 0.1f, 150.0f);
        u.camPos = _cameraPosition;
        u.time = _time;
        u.lightDir = simd_normalize((simd_float3){0.3f, 1.0f, 0.5f});
        u.fogDensity = 0.6f;
        u.fogColor = (simd_float3){0.5f, 0.55f, 0.6f};
        u.rain = 0.7f;
        memcpy(_uniformBuffer.contents, &u, sizeof(u));

        [enc setRenderPipelineState:_pipelineState];
        [enc setVertexBuffer:_sceneBuffer offset:0 atIndex:0];
        [enc setVertexBuffer:_uniformBuffer offset:0 atIndex:1];
        [enc setFragmentBuffer:_uniformBuffer offset:0 atIndex:1];
        [enc drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:_sceneVertexCount];

        [enc setRenderPipelineState:_rainPipelineState];
        [enc setVertexBuffer:_rainBuffer offset:0 atIndex:0];
        [enc drawPrimitives:MTLPrimitiveTypePoint vertexStart:0 vertexCount:_rainParticleCount];

        [enc endEncoding];
        [cmd presentDrawable:view.currentDrawable];
    }
    [cmd commit];
}
@end

@interface GameView : MTKView
@property (nonatomic, weak) Renderer *renderer;
@end

@implementation GameView
- (BOOL)acceptsFirstResponder { return YES; }
- (void)keyDown:(NSEvent *)e {
    switch (e.keyCode) {
        case 13: _renderer.keyW = YES; break;
        case 0: _renderer.keyA = YES; break;
        case 1: _renderer.keyS = YES; break;
        case 2: _renderer.keyD = YES; break;
        case 49: _renderer.keySpace = YES; break;
        case 56: case 60: _renderer.keyShift = YES; break;
    }
}
- (void)keyUp:(NSEvent *)e {
    switch (e.keyCode) {
        case 13: _renderer.keyW = NO; break;
        case 0: _renderer.keyA = NO; break;
        case 1: _renderer.keyS = NO; break;
        case 2: _renderer.keyD = NO; break;
        case 49: _renderer.keySpace = NO; break;
        case 56: case 60: _renderer.keyShift = NO; break;
    }
}
- (void)mouseDragged:(NSEvent *)e {
    _renderer.cameraYaw += e.deltaX * 0.005f;
    _renderer.cameraPitch -= e.deltaY * 0.005f;
    _renderer.cameraPitch = fminf(fmaxf(_renderer.cameraPitch, -1.4f), 1.4f);
}
@end

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (nonatomic, strong) NSWindow *window;
@property (nonatomic, strong) Renderer *renderer;
@end

@implementation AppDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)n {
    _window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 1280, 720)
                                          styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable
                                            backing:NSBackingStoreBuffered defer:NO];
    [_window setTitle:@"Amazon Rainforest - WASD move, Drag mouse to look, Space/Shift up/down"];
    [_window center];

    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    GameView *view = [[GameView alloc] initWithFrame:_window.contentView.bounds device:device];
    view.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
    view.depthStencilPixelFormat = MTLPixelFormatDepth32Float;
    view.preferredFramesPerSecond = 60;

    _renderer = [[Renderer alloc] initWithMetalKitView:view];
    view.delegate = _renderer;
    view.renderer = _renderer;

    [_window setContentView:view];
    [_window makeFirstResponder:view];
    [_window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)s { return YES; }
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        [app setActivationPolicy:NSApplicationActivationPolicyRegular];
        ProcessSerialNumber psn = {0, kCurrentProcess};
        TransformProcessType(&psn, kProcessTransformToForegroundApplication);
        AppDelegate *delegate = [[AppDelegate alloc] init];
        [app setDelegate:delegate];
        [app activateIgnoringOtherApps:YES];
        [app run];
    }
    return 0;
}

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

simd_float4x4 matrix_perspective(float fovy, float aspect, float near, float far) {
    float y = 1 / tanf(fovy * 0.5f), x = y / aspect, z = far / (near - far);
    return (simd_float4x4){{{x,0,0,0},{0,y,0,0},{0,0,z,-1},{0,0,near*z,0}}};
}

simd_float4x4 matrix_look_at(simd_float3 eye, simd_float3 target, simd_float3 up) {
    simd_float3 z = simd_normalize(eye - target), x = simd_normalize(simd_cross(up, z)), y = simd_cross(z, x);
    return (simd_float4x4){{{x.x,y.x,z.x,0},{x.y,y.y,z.y,0},{x.z,y.z,z.z,0},{-simd_dot(x,eye),-simd_dot(y,eye),-simd_dot(z,eye),1}}};
}

simd_float4x4 matrix_identity() {
    return (simd_float4x4){{{1,0,0,0},{0,1,0,0},{0,0,1,0},{0,0,0,1}}};
}

@interface Renderer : NSObject <MTKViewDelegate>
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong) id<MTLRenderPipelineState> rainPipelineState;
@property (nonatomic, strong) id<MTLRenderPipelineState> skyPipelineState;
@property (nonatomic, strong) id<MTLDepthStencilState> depthState;
@property (nonatomic, strong) id<MTLDepthStencilState> noDepthState;
@property (nonatomic, strong) id<MTLBuffer> uniformBuffer;
@property (nonatomic, strong) id<MTLBuffer> sceneBuffer;
@property (nonatomic, assign) NSUInteger sceneVertexCount;
@property (nonatomic, strong) id<MTLBuffer> rainBuffer;
@property (nonatomic, assign) NSUInteger rainParticleCount;
@property (nonatomic, strong) id<MTLBuffer> skyBuffer;
@property (nonatomic, assign) simd_float3 cameraPosition;
@property (nonatomic, assign) float cameraYaw, cameraPitch, time;
@property (nonatomic, assign) BOOL keyW, keyA, keyS, keyD, keySpace, keyShift;
@end

@implementation Renderer

- (instancetype)initWithMetalKitView:(MTKView *)view {
    self = [super init];
    if (self) {
        _device = view.device;
        _commandQueue = [_device newCommandQueue];
        _cameraPosition = (simd_float3){0, 2.5, 20};
        _cameraYaw = 0; _cameraPitch = 0; _time = 0;
        [self setupPipelines:view];
        [self generateScene];
        [self generateRain];
        [self generateSky];
    }
    return self;
}

- (void)setupPipelines:(MTKView *)view {
    NSError *error;
    NSString *src = @R"(
#include <metal_stdlib>
using namespace metal;

struct V { float3 pos [[attribute(0)]]; float3 norm [[attribute(1)]]; float3 col [[attribute(2)]]; };
struct F { float4 pos [[position]]; float3 norm; float3 col; float3 wpos; };
struct U { float4x4 model, view, proj; float3 camPos; float time; float3 lightDir; float fogDensity; float3 fogColor; float rain; };

vertex F vmain(V v [[stage_in]], constant U& u [[buffer(1)]]) {
    F o;
    float4 w = u.model * float4(v.pos, 1.0);
    o.wpos = w.xyz;
    o.pos = u.proj * u.view * w;
    o.norm = normalize((u.model * float4(v.norm, 0.0)).xyz);
    o.col = v.col;
    return o;
}

fragment float4 fmain(F f [[stage_in]], constant U& u [[buffer(1)]]) {
    float3 n = normalize(f.norm);
    float3 l = normalize(u.lightDir);
    float diff = max(dot(n, l), 0.0) * 0.6;
    float amb = 0.4;
    float3 col = f.col * (amb + diff);
    col *= (1.0 - u.rain * 0.15);
    float spec = pow(max(dot(reflect(-l, n), normalize(u.camPos - f.wpos)), 0.0), 32.0) * u.rain * 0.3;
    col += spec;
    float dist = length(f.wpos - u.camPos);
    float fog = 1.0 - exp(-u.fogDensity * dist * 0.012);
    fog = clamp(fog, 0.0, 0.75);
    col = mix(col, u.fogColor, fog);
    return float4(col, 1.0);
}

struct RV { float3 pos [[attribute(0)]]; float vel [[attribute(1)]]; };
struct RF { float4 pos [[position]]; float alpha; float size [[point_size]]; };

vertex RF rvmain(RV v [[stage_in]], constant U& u [[buffer(1)]]) {
    RF o;
    float3 p = v.pos;
    p.y -= fmod(u.time * (30.0 + v.vel * 20.0) + v.vel * 100.0, 60.0);
    if (p.y < 0.0) p.y += 60.0;
    p.x += sin(u.time * 2.0 + v.vel * 10.0) * 0.3;
    o.pos = u.proj * u.view * float4(p, 1.0);
    float d = length(p - u.camPos);
    o.alpha = clamp(1.0 - d / 50.0, 0.0, 0.7) * u.rain;
    o.size = max(2.0, 5.0 - d * 0.08);
    return o;
}

fragment float4 rfmain(RF f [[stage_in]]) {
    return float4(0.75, 0.8, 0.9, f.alpha);
}

struct SV { float3 pos [[attribute(0)]]; };
struct SF { float4 pos [[position]]; float2 uv; };

vertex SF svmain(SV v [[stage_in]], constant U& u [[buffer(1)]]) {
    SF o;
    o.pos = float4(v.pos.xy, 0.9999, 1.0);
    o.uv = v.pos.xy * 0.5 + 0.5;
    return o;
}

fragment float4 sfmain(SF f [[stage_in]], constant U& u [[buffer(1)]]) {
    float3 top = float3(0.2, 0.25, 0.35);
    float3 mid = float3(0.45, 0.55, 0.65);
    float3 bot = float3(0.5, 0.6, 0.55);
    float y = f.uv.y;
    float3 col;
    if (y > 0.5) col = mix(mid, top, (y - 0.5) * 2.0);
    else col = mix(bot, mid, y * 2.0);
    float clouds = sin(f.uv.x * 8.0 + u.time * 0.1) * cos(f.uv.y * 4.0) * 0.1 + 0.1;
    clouds += sin(f.uv.x * 3.0 - u.time * 0.05) * cos(f.uv.y * 6.0 + u.time * 0.02) * 0.08;
    col += clouds * float3(0.3, 0.3, 0.35) * (1.0 - u.rain * 0.5);
    col = mix(col, u.fogColor, u.rain * 0.3);
    return float4(col, 1.0);
}
    )";

    MTLCompileOptions *opt = [[MTLCompileOptions alloc] init];
    id<MTLLibrary> lib = [_device newLibraryWithSource:src options:opt error:&error];

    MTLVertexDescriptor *vd = [[MTLVertexDescriptor alloc] init];
    vd.attributes[0].format = MTLVertexFormatFloat3; vd.attributes[0].offset = 0; vd.attributes[0].bufferIndex = 0;
    vd.attributes[1].format = MTLVertexFormatFloat3; vd.attributes[1].offset = 12; vd.attributes[1].bufferIndex = 0;
    vd.attributes[2].format = MTLVertexFormatFloat3; vd.attributes[2].offset = 24; vd.attributes[2].bufferIndex = 0;
    vd.layouts[0].stride = sizeof(Vertex);

    MTLRenderPipelineDescriptor *pd = [[MTLRenderPipelineDescriptor alloc] init];
    pd.vertexFunction = [lib newFunctionWithName:@"vmain"];
    pd.fragmentFunction = [lib newFunctionWithName:@"fmain"];
    pd.vertexDescriptor = vd;
    pd.colorAttachments[0].pixelFormat = view.colorPixelFormat;
    pd.depthAttachmentPixelFormat = view.depthStencilPixelFormat;
    _pipelineState = [_device newRenderPipelineStateWithDescriptor:pd error:&error];

    MTLVertexDescriptor *rvd = [[MTLVertexDescriptor alloc] init];
    rvd.attributes[0].format = MTLVertexFormatFloat3; rvd.attributes[0].offset = 0; rvd.attributes[0].bufferIndex = 0;
    rvd.attributes[1].format = MTLVertexFormatFloat; rvd.attributes[1].offset = 12; rvd.attributes[1].bufferIndex = 0;
    rvd.layouts[0].stride = sizeof(RainParticle);

    MTLRenderPipelineDescriptor *rpd = [[MTLRenderPipelineDescriptor alloc] init];
    rpd.vertexFunction = [lib newFunctionWithName:@"rvmain"];
    rpd.fragmentFunction = [lib newFunctionWithName:@"rfmain"];
    rpd.vertexDescriptor = rvd;
    rpd.colorAttachments[0].pixelFormat = view.colorPixelFormat;
    rpd.colorAttachments[0].blendingEnabled = YES;
    rpd.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactorSourceAlpha;
    rpd.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    rpd.depthAttachmentPixelFormat = view.depthStencilPixelFormat;
    _rainPipelineState = [_device newRenderPipelineStateWithDescriptor:rpd error:&error];

    MTLVertexDescriptor *svd = [[MTLVertexDescriptor alloc] init];
    svd.attributes[0].format = MTLVertexFormatFloat3; svd.attributes[0].offset = 0; svd.attributes[0].bufferIndex = 0;
    svd.layouts[0].stride = 12;

    MTLRenderPipelineDescriptor *spd = [[MTLRenderPipelineDescriptor alloc] init];
    spd.vertexFunction = [lib newFunctionWithName:@"svmain"];
    spd.fragmentFunction = [lib newFunctionWithName:@"sfmain"];
    spd.vertexDescriptor = svd;
    spd.colorAttachments[0].pixelFormat = view.colorPixelFormat;
    spd.depthAttachmentPixelFormat = view.depthStencilPixelFormat;
    _skyPipelineState = [_device newRenderPipelineStateWithDescriptor:spd error:&error];

    MTLDepthStencilDescriptor *dd = [[MTLDepthStencilDescriptor alloc] init];
    dd.depthCompareFunction = MTLCompareFunctionLess;
    dd.depthWriteEnabled = YES;
    _depthState = [_device newDepthStencilStateWithDescriptor:dd];

    MTLDepthStencilDescriptor *ndd = [[MTLDepthStencilDescriptor alloc] init];
    ndd.depthCompareFunction = MTLCompareFunctionAlways;
    ndd.depthWriteEnabled = NO;
    _noDepthState = [_device newDepthStencilStateWithDescriptor:ndd];

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
    [self addQuad:v p0:{x-w,y,z-d} p1:{x+w,y,z-d} p2:{x+w,y,z+d} p3:{x-w,y,z+d} c:c];
}

- (void)generateScene {
    std::vector<Vertex> verts;
    std::mt19937 rng(42);

    for (int i = -30; i < 30; i++) {
        for (int j = -30; j < 30; j++) {
            float x = i * 1.5f, z = j * 1.5f;
            float v = (rng() % 100) / 1000.0f;
            simd_float3 gc = {0.08f + v, 0.18f + v * 2, 0.05f + v};
            simd_float3 n = {0, 1, 0};
            verts.push_back({{x, 0, z}, n, gc});
            verts.push_back({{x+1.5f, 0, z}, n, gc});
            verts.push_back({{x+1.5f, 0, z+1.5f}, n, gc});
            verts.push_back({{x, 0, z}, n, gc});
            verts.push_back({{x+1.5f, 0, z+1.5f}, n, gc});
            verts.push_back({{x, 0, z+1.5f}, n, gc});
        }
    }

    std::uniform_real_distribution<float> pos(-35, 35);
    for (int t = 0; t < 60; t++) {
        float x = pos(rng), z = pos(rng);
        float h = 8 + (rng() % 100) / 12.0f;
        float tw = 0.4f + (rng() % 30) / 100.0f;
        simd_float3 trunk = {0.35f + (rng()%20)/200.0f, 0.2f + (rng()%15)/200.0f, 0.1f};
        [self addBox:verts pos:{x, 0, z} size:{tw, h * 0.7f, tw} c:trunk];

        float ly = h * 0.3f;
        int layers = 3 + (rng() % 2);
        for (int l = 0; l < layers; l++) {
            float r = (3.5f - l * 0.6f) * (0.8f + (rng() % 40) / 100.0f);
            float lh = 2.0f + (rng() % 100) / 100.0f;
            float gv = (rng() % 80) / 800.0f;
            simd_float3 leaf = {0.05f + gv, 0.35f + gv * 3, 0.08f + gv};
            [self addBox:verts pos:{x, ly, z} size:{r * 2, lh, r * 2} c:leaf];
            ly += lh * 0.65f;
        }
        simd_float3 top = {0.03f, 0.4f + (rng()%20)/200.0f, 0.05f};
        [self addBox:verts pos:{x, ly, z} size:{1.5f, 1.5f, 1.5f} c:top];
    }

    for (int i = 0; i < 8; i++) {
        float x = pos(rng), z = pos(rng);
        simd_float3 body = {0.55f, 0.4f, 0.25f};
        simd_float3 head = {0.5f, 0.35f, 0.2f};
        [self addBox:verts pos:{x, 0.2f, z} size:{1.2f, 0.7f, 0.7f} c:body];
        [self addBox:verts pos:{x + 0.5f, 0.5f, z} size:{0.5f, 0.5f, 0.5f} c:head];
        simd_float3 leg = {0.4f, 0.28f, 0.18f};
        [self addBox:verts pos:{x - 0.3f, 0, z - 0.2f} size:{0.18f, 0.35f, 0.18f} c:leg];
        [self addBox:verts pos:{x - 0.3f, 0, z + 0.2f} size:{0.18f, 0.35f, 0.18f} c:leg];
        [self addBox:verts pos:{x + 0.3f, 0, z - 0.2f} size:{0.18f, 0.35f, 0.18f} c:leg];
        [self addBox:verts pos:{x + 0.3f, 0, z + 0.2f} size:{0.18f, 0.35f, 0.18f} c:leg];
        simd_float3 ear = {0.3f, 0.2f, 0.15f};
        [self addBox:verts pos:{x + 0.6f, 0.85f, z - 0.15f} size:{0.12f, 0.15f, 0.08f} c:ear];
        [self addBox:verts pos:{x + 0.6f, 0.85f, z + 0.15f} size:{0.12f, 0.15f, 0.08f} c:ear];
    }

    for (int i = 0; i < 10; i++) {
        float x = pos(rng), z = pos(rng);
        int col = rng() % 4;
        simd_float3 frog;
        if (col == 0) frog = {0.1f, 0.7f, 0.2f};
        else if (col == 1) frog = {0.9f, 0.1f, 0.1f};
        else if (col == 2) frog = {0.1f, 0.2f, 0.9f};
        else frog = {0.95f, 0.8f, 0.1f};
        [self addBox:verts pos:{x, 0.05f, z} size:{0.35f, 0.2f, 0.3f} c:frog];
        [self addBox:verts pos:{x + 0.12f, 0.15f, z} size:{0.2f, 0.18f, 0.22f} c:frog];
        simd_float3 eye = {0.1f, 0.1f, 0.1f};
        [self addBox:verts pos:{x + 0.2f, 0.28f, z - 0.06f} size:{0.08f, 0.1f, 0.08f} c:eye];
        [self addBox:verts pos:{x + 0.2f, 0.28f, z + 0.06f} size:{0.08f, 0.1f, 0.08f} c:eye];
        simd_float3 legf = {frog.x * 0.7f, frog.y * 0.7f, frog.z * 0.7f};
        [self addBox:verts pos:{x - 0.12f, 0, z - 0.12f} size:{0.1f, 0.08f, 0.2f} c:legf];
        [self addBox:verts pos:{x - 0.12f, 0, z + 0.12f} size:{0.1f, 0.08f, 0.2f} c:legf];
    }

    for (int i = 0; i < 6; i++) {
        float x = pos(rng), z = pos(rng);
        simd_float3 monkey = {0.2f, 0.15f, 0.1f};
        float h = 3.5f + (rng() % 50) / 20.0f;
        [self addBox:verts pos:{x, h, z} size:{0.55f, 0.6f, 0.45f} c:monkey];
        [self addBox:verts pos:{x, h + 0.45f, z} size:{0.4f, 0.4f, 0.38f} c:monkey];
        simd_float3 face = {0.5f, 0.4f, 0.35f};
        [self addBox:verts pos:{x + 0.15f, h + 0.5f, z} size:{0.15f, 0.2f, 0.2f} c:face];
        simd_float3 arm = {0.18f, 0.12f, 0.08f};
        [self addBox:verts pos:{x, h - 0.1f, z - 0.35f} size:{0.12f, 0.5f, 0.12f} c:arm];
        [self addBox:verts pos:{x, h - 0.1f, z + 0.35f} size:{0.12f, 0.5f, 0.12f} c:arm];
        [self addBox:verts pos:{x - 0.35f, h + 0.1f, z} size:{0.5f, 0.1f, 0.1f} c:arm];
    }

    for (int i = 0; i < 12; i++) {
        float x = pos(rng), z = pos(rng);
        float h = 5 + (rng() % 60) / 10.0f;
        simd_float3 bird;
        int col = rng() % 5;
        if (col == 0) bird = {0.95f, 0.15f, 0.1f};
        else if (col == 1) bird = {0.1f, 0.4f, 0.95f};
        else if (col == 2) bird = {0.95f, 0.9f, 0.1f};
        else if (col == 3) bird = {0.1f, 0.95f, 0.3f};
        else bird = {0.95f, 0.5f, 0.1f};
        [self addBox:verts pos:{x, h, z} size:{0.25f, 0.2f, 0.4f} c:bird];
        simd_float3 wing = {bird.x * 0.8f, bird.y * 0.8f, bird.z * 0.8f};
        [self addBox:verts pos:{x, h + 0.05f, z - 0.25f} size:{0.08f, 0.05f, 0.3f} c:wing];
        [self addBox:verts pos:{x, h + 0.05f, z + 0.25f} size:{0.08f, 0.05f, 0.3f} c:wing];
        simd_float3 beak = {0.9f, 0.6f, 0.1f};
        [self addBox:verts pos:{x + 0.2f, h, z} size:{0.15f, 0.08f, 0.08f} c:beak];
    }

    for (int i = 0; i < 5; i++) {
        float x = pos(rng), z = pos(rng);
        simd_float3 snake = {0.3f + (rng()%30)/100.0f, 0.5f + (rng()%30)/100.0f, 0.1f};
        for (int s = 0; s < 10; s++) {
            float sx = x + s * 0.15f;
            float sy = 0.08f + sinf(s * 0.5f) * 0.05f;
            float sz = z + sinf(s * 0.8f) * 0.15f;
            [self addBox:verts pos:{sx, sy, sz} size:{0.18f, 0.12f, 0.12f} c:snake];
        }
        simd_float3 head = {snake.x * 1.1f, snake.y * 1.1f, snake.z};
        [self addBox:verts pos:{x - 0.1f, 0.12f, z} size:{0.2f, 0.15f, 0.15f} c:head];
    }

    for (int i = 0; i < 20; i++) {
        float x = pos(rng), z = pos(rng);
        float h = (rng() % 100) / 50.0f + 0.5f;
        float gv = (rng() % 50) / 500.0f;
        simd_float3 bush = {0.05f + gv, 0.3f + gv * 2, 0.05f + gv};
        float sz = 0.8f + (rng() % 100) / 100.0f;
        [self addBox:verts pos:{x, 0, z} size:{sz, h, sz} c:bush];
    }

    for (int i = 0; i < 15; i++) {
        float x = pos(rng), z = pos(rng);
        simd_float3 flower;
        int col = rng() % 4;
        if (col == 0) flower = {0.95f, 0.2f, 0.4f};
        else if (col == 1) flower = {0.95f, 0.95f, 0.3f};
        else if (col == 2) flower = {0.95f, 0.5f, 0.9f};
        else flower = {0.95f, 0.6f, 0.2f};
        simd_float3 stem = {0.1f, 0.4f, 0.1f};
        [self addBox:verts pos:{x, 0, z} size:{0.05f, 0.4f, 0.05f} c:stem];
        [self addBox:verts pos:{x, 0.35f, z} size:{0.25f, 0.15f, 0.25f} c:flower];
    }

    _sceneVertexCount = verts.size();
    _sceneBuffer = [_device newBufferWithBytes:verts.data() length:verts.size() * sizeof(Vertex) options:MTLResourceStorageModeShared];
}

- (void)generateRain {
    std::vector<RainParticle> particles;
    std::mt19937 rng(999);
    std::uniform_real_distribution<float> p(-45, 45), h(0, 60), v(0, 1);
    _rainParticleCount = 4000;
    for (NSUInteger i = 0; i < _rainParticleCount; i++) {
        particles.push_back({{p(rng), h(rng), p(rng)}, v(rng)});
    }
    _rainBuffer = [_device newBufferWithBytes:particles.data() length:particles.size() * sizeof(RainParticle) options:MTLResourceStorageModeShared];
}

- (void)generateSky {
    float skyVerts[] = {-1,-1,0, 1,-1,0, 1,1,0, -1,-1,0, 1,1,0, -1,1,0};
    _skyBuffer = [_device newBufferWithBytes:skyVerts length:sizeof(skyVerts) options:MTLResourceStorageModeShared];
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {}

- (void)drawInMTKView:(MTKView *)view {
    _time += 1.0f / 60.0f;
    float spd = 8.0f / 60.0f;
    simd_float3 fwd = {sinf(_cameraYaw), 0, -cosf(_cameraYaw)};
    simd_float3 right = {cosf(_cameraYaw), 0, sinf(_cameraYaw)};
    if (_keyW) _cameraPosition = _cameraPosition + fwd * spd;
    if (_keyS) _cameraPosition = _cameraPosition - fwd * spd;
    if (_keyA) _cameraPosition = _cameraPosition - right * spd;
    if (_keyD) _cameraPosition = _cameraPosition + right * spd;
    if (_keySpace) _cameraPosition.y += spd;
    if (_keyShift) _cameraPosition.y -= spd;
    _cameraPosition.y = fmaxf(_cameraPosition.y, 1.5f);
    _cameraPosition.x = fminf(fmaxf(_cameraPosition.x, -40), 40);
    _cameraPosition.z = fminf(fmaxf(_cameraPosition.z, -40), 40);

    id<MTLCommandBuffer> cmd = [_commandQueue commandBuffer];
    MTLRenderPassDescriptor *rpd = view.currentRenderPassDescriptor;
    if (rpd) {
        rpd.colorAttachments[0].clearColor = MTLClearColorMake(0.3, 0.35, 0.4, 1.0);
        id<MTLRenderCommandEncoder> enc = [cmd renderCommandEncoderWithDescriptor:rpd];

        float aspect = view.drawableSize.width / view.drawableSize.height;
        simd_float3 look = {sinf(_cameraYaw) * cosf(_cameraPitch), sinf(_cameraPitch), -cosf(_cameraYaw) * cosf(_cameraPitch)};

        Uniforms u;
        u.model = matrix_identity();
        u.view = matrix_look_at(_cameraPosition, _cameraPosition + look, (simd_float3){0, 1, 0});
        u.proj = matrix_perspective(M_PI / 3.0f, aspect, 0.1f, 200.0f);
        u.camPos = _cameraPosition;
        u.time = _time;
        u.lightDir = simd_normalize((simd_float3){0.4f, 1.0f, 0.3f});
        u.fogDensity = 0.5f;
        u.fogColor = (simd_float3){0.4f, 0.48f, 0.5f};
        u.rain = 0.8f;
        memcpy(_uniformBuffer.contents, &u, sizeof(u));

        [enc setDepthStencilState:_noDepthState];
        [enc setRenderPipelineState:_skyPipelineState];
        [enc setVertexBuffer:_skyBuffer offset:0 atIndex:0];
        [enc setVertexBuffer:_uniformBuffer offset:0 atIndex:1];
        [enc setFragmentBuffer:_uniformBuffer offset:0 atIndex:1];
        [enc drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];

        [enc setDepthStencilState:_depthState];
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
        AppDelegate *d = [[AppDelegate alloc] init];
        [app setDelegate:d];
        [app activateIgnoringOtherApps:YES];
        [app run];
    }
    return 0;
}

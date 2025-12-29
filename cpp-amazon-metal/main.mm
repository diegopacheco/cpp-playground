#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <simd/simd.h>
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
    simd_float4x4 modelMatrix;
    simd_float4x4 viewMatrix;
    simd_float4x4 projectionMatrix;
    simd_float3 cameraPosition;
    float time;
    simd_float3 lightDirection;
    float fogDensity;
    simd_float3 fogColor;
    float rainIntensity;
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
@property (nonatomic, strong) id<MTLRenderPipelineState> groundPipelineState;
@property (nonatomic, strong) id<MTLDepthStencilState> depthState;
@property (nonatomic, strong) id<MTLBuffer> uniformBuffer;
@property (nonatomic, strong) NSMutableArray<id<MTLBuffer>>* treeBuffers;
@property (nonatomic, strong) NSMutableArray<NSNumber*>* treeVertexCounts;
@property (nonatomic, strong) NSMutableArray<id<MTLBuffer>>* animalBuffers;
@property (nonatomic, strong) NSMutableArray<NSNumber*>* animalVertexCounts;
@property (nonatomic, strong) NSMutableArray<NSValue*>* animalPositions;
@property (nonatomic, strong) id<MTLBuffer> groundBuffer;
@property (nonatomic, assign) NSUInteger groundVertexCount;
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
        _treeBuffers = [NSMutableArray new];
        _treeVertexCounts = [NSMutableArray new];
        _animalBuffers = [NSMutableArray new];
        _animalVertexCounts = [NSMutableArray new];
        _animalPositions = [NSMutableArray new];
        _cameraPosition = (simd_float3){0, 2.0, 10};
        _cameraYaw = 0;
        _cameraPitch = 0;
        _time = 0;

        [self setupPipelines:view];
        [self generateGround];
        [self generateTrees];
        [self generateAnimals];
        [self generateRain];
    }
    return self;
}

- (void)setupPipelines:(MTKView *)view {
    NSError *error;
    NSString *shaderPath = [[NSBundle mainBundle] pathForResource:@"Shaders" ofType:@"metallib"];
    id<MTLLibrary> library;
    if (shaderPath) {
        library = [_device newLibraryWithFile:shaderPath error:&error];
    }
    if (!library) {
        NSString *sourcePath = @"Shaders.metal";
        NSString *source = [NSString stringWithContentsOfFile:sourcePath encoding:NSUTF8StringEncoding error:&error];
        if (!source) {
            source = [NSString stringWithContentsOfFile:@"./Shaders.metal" encoding:NSUTF8StringEncoding error:&error];
        }
        MTLCompileOptions *options = [[MTLCompileOptions alloc] init];
        library = [_device newLibraryWithSource:source options:options error:&error];
    }

    MTLVertexDescriptor *vertexDescriptor = [[MTLVertexDescriptor alloc] init];
    vertexDescriptor.attributes[0].format = MTLVertexFormatFloat3;
    vertexDescriptor.attributes[0].offset = 0;
    vertexDescriptor.attributes[0].bufferIndex = 0;
    vertexDescriptor.attributes[1].format = MTLVertexFormatFloat3;
    vertexDescriptor.attributes[1].offset = sizeof(simd_float3);
    vertexDescriptor.attributes[1].bufferIndex = 0;
    vertexDescriptor.attributes[2].format = MTLVertexFormatFloat3;
    vertexDescriptor.attributes[2].offset = sizeof(simd_float3) * 2;
    vertexDescriptor.attributes[2].bufferIndex = 0;
    vertexDescriptor.layouts[0].stride = sizeof(Vertex);

    MTLRenderPipelineDescriptor *pipelineDesc = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineDesc.vertexFunction = [library newFunctionWithName:@"vertex_main"];
    pipelineDesc.fragmentFunction = [library newFunctionWithName:@"fragment_main"];
    pipelineDesc.vertexDescriptor = vertexDescriptor;
    pipelineDesc.colorAttachments[0].pixelFormat = view.colorPixelFormat;
    pipelineDesc.depthAttachmentPixelFormat = view.depthStencilPixelFormat;
    _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineDesc error:&error];

    pipelineDesc.vertexFunction = [library newFunctionWithName:@"ground_vertex"];
    pipelineDesc.fragmentFunction = [library newFunctionWithName:@"ground_fragment"];
    _groundPipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineDesc error:&error];

    MTLVertexDescriptor *rainVertexDesc = [[MTLVertexDescriptor alloc] init];
    rainVertexDesc.attributes[0].format = MTLVertexFormatFloat3;
    rainVertexDesc.attributes[0].offset = 0;
    rainVertexDesc.attributes[0].bufferIndex = 0;
    rainVertexDesc.attributes[1].format = MTLVertexFormatFloat;
    rainVertexDesc.attributes[1].offset = sizeof(simd_float3);
    rainVertexDesc.attributes[1].bufferIndex = 0;
    rainVertexDesc.layouts[0].stride = sizeof(RainParticle);

    MTLRenderPipelineDescriptor *rainPipelineDesc = [[MTLRenderPipelineDescriptor alloc] init];
    rainPipelineDesc.vertexFunction = [library newFunctionWithName:@"rain_vertex"];
    rainPipelineDesc.fragmentFunction = [library newFunctionWithName:@"rain_fragment"];
    rainPipelineDesc.vertexDescriptor = rainVertexDesc;
    rainPipelineDesc.colorAttachments[0].pixelFormat = view.colorPixelFormat;
    rainPipelineDesc.colorAttachments[0].blendingEnabled = YES;
    rainPipelineDesc.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactorSourceAlpha;
    rainPipelineDesc.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    rainPipelineDesc.depthAttachmentPixelFormat = view.depthStencilPixelFormat;
    _rainPipelineState = [_device newRenderPipelineStateWithDescriptor:rainPipelineDesc error:&error];

    MTLDepthStencilDescriptor *depthDesc = [[MTLDepthStencilDescriptor alloc] init];
    depthDesc.depthCompareFunction = MTLCompareFunctionLess;
    depthDesc.depthWriteEnabled = YES;
    _depthState = [_device newDepthStencilStateWithDescriptor:depthDesc];

    _uniformBuffer = [_device newBufferWithLength:sizeof(Uniforms) options:MTLResourceStorageModeShared];
}

- (void)generateGround {
    std::vector<Vertex> vertices;
    float size = 100;
    int divisions = 50;
    float step = size / divisions;

    for (int i = 0; i < divisions; i++) {
        for (int j = 0; j < divisions; j++) {
            float x0 = -size/2 + i * step;
            float z0 = -size/2 + j * step;
            float x1 = x0 + step;
            float z1 = z0 + step;

            auto groundColor = [](float x, float z) -> simd_float3 {
                float noise = sinf(x * 0.3f) * cosf(z * 0.3f) * 0.1f + 0.5f;
                float r = 0.15f + noise * 0.1f;
                float g = 0.25f + noise * 0.15f;
                float b = 0.1f + noise * 0.05f;
                return (simd_float3){r, g, b};
            };

            simd_float3 normal = {0, 1, 0};
            vertices.push_back({{x0, 0, z0}, normal, groundColor(x0, z0)});
            vertices.push_back({{x1, 0, z0}, normal, groundColor(x1, z0)});
            vertices.push_back({{x1, 0, z1}, normal, groundColor(x1, z1)});
            vertices.push_back({{x0, 0, z0}, normal, groundColor(x0, z0)});
            vertices.push_back({{x1, 0, z1}, normal, groundColor(x1, z1)});
            vertices.push_back({{x0, 0, z1}, normal, groundColor(x0, z1)});
        }
    }

    _groundVertexCount = vertices.size();
    _groundBuffer = [_device newBufferWithBytes:vertices.data()
                                         length:vertices.size() * sizeof(Vertex)
                                        options:MTLResourceStorageModeShared];
}

- (void)addCylinder:(std::vector<Vertex>&)vertices
             base:(simd_float3)base
           radius:(float)radius
           height:(float)height
            color:(simd_float3)color
         segments:(int)segments {
    for (int i = 0; i < segments; i++) {
        float angle0 = (float)i / segments * M_PI * 2;
        float angle1 = (float)(i + 1) / segments * M_PI * 2;
        float x0 = cosf(angle0) * radius;
        float z0 = sinf(angle0) * radius;
        float x1 = cosf(angle1) * radius;
        float z1 = sinf(angle1) * radius;

        simd_float3 n0 = simd_normalize((simd_float3){x0, 0, z0});
        simd_float3 n1 = simd_normalize((simd_float3){x1, 0, z1});

        vertices.push_back({{base.x + x0, base.y, base.z + z0}, n0, color});
        vertices.push_back({{base.x + x1, base.y, base.z + z1}, n1, color});
        vertices.push_back({{base.x + x1, base.y + height, base.z + z1}, n1, color});

        vertices.push_back({{base.x + x0, base.y, base.z + z0}, n0, color});
        vertices.push_back({{base.x + x1, base.y + height, base.z + z1}, n1, color});
        vertices.push_back({{base.x + x0, base.y + height, base.z + z0}, n0, color});
    }
}

- (void)addCone:(std::vector<Vertex>&)vertices
          base:(simd_float3)base
        radius:(float)radius
        height:(float)height
         color:(simd_float3)color
      segments:(int)segments {
    for (int i = 0; i < segments; i++) {
        float angle0 = (float)i / segments * M_PI * 2;
        float angle1 = (float)(i + 1) / segments * M_PI * 2;
        float x0 = cosf(angle0) * radius;
        float z0 = sinf(angle0) * radius;
        float x1 = cosf(angle1) * radius;
        float z1 = sinf(angle1) * radius;

        simd_float3 tip = {base.x, base.y + height, base.z};
        simd_float3 p0 = {base.x + x0, base.y, base.z + z0};
        simd_float3 p1 = {base.x + x1, base.y, base.z + z1};

        simd_float3 edge0 = p0 - tip;
        simd_float3 edge1 = p1 - tip;
        simd_float3 normal = simd_normalize(simd_cross(edge1, edge0));

        vertices.push_back({tip, normal, color});
        vertices.push_back({p0, normal, color});
        vertices.push_back({p1, normal, color});
    }
}

- (void)addSphere:(std::vector<Vertex>&)vertices
          center:(simd_float3)center
          radius:(float)radius
           color:(simd_float3)color
       latitudes:(int)latitudes
      longitudes:(int)longitudes {
    for (int i = 0; i < latitudes; i++) {
        float theta0 = (float)i / latitudes * M_PI;
        float theta1 = (float)(i + 1) / latitudes * M_PI;

        for (int j = 0; j < longitudes; j++) {
            float phi0 = (float)j / longitudes * M_PI * 2;
            float phi1 = (float)(j + 1) / longitudes * M_PI * 2;

            auto spherePoint = [&](float theta, float phi) -> simd_float3 {
                return {
                    center.x + radius * sinf(theta) * cosf(phi),
                    center.y + radius * cosf(theta),
                    center.z + radius * sinf(theta) * sinf(phi)
                };
            };

            auto sphereNormal = [&](float theta, float phi) -> simd_float3 {
                return simd_normalize((simd_float3){
                    sinf(theta) * cosf(phi),
                    cosf(theta),
                    sinf(theta) * sinf(phi)
                });
            };

            simd_float3 p00 = spherePoint(theta0, phi0);
            simd_float3 p01 = spherePoint(theta0, phi1);
            simd_float3 p10 = spherePoint(theta1, phi0);
            simd_float3 p11 = spherePoint(theta1, phi1);

            simd_float3 n00 = sphereNormal(theta0, phi0);
            simd_float3 n01 = sphereNormal(theta0, phi1);
            simd_float3 n10 = sphereNormal(theta1, phi0);
            simd_float3 n11 = sphereNormal(theta1, phi1);

            vertices.push_back({p00, n00, color});
            vertices.push_back({p10, n10, color});
            vertices.push_back({p11, n11, color});

            vertices.push_back({p00, n00, color});
            vertices.push_back({p11, n11, color});
            vertices.push_back({p01, n01, color});
        }
    }
}

- (void)generateTrees {
    std::mt19937 rng(42);
    std::uniform_real_distribution<float> posDist(-45, 45);
    std::uniform_real_distribution<float> heightDist(8, 18);
    std::uniform_real_distribution<float> radiusDist(0.3, 0.6);

    for (int t = 0; t < 80; t++) {
        std::vector<Vertex> vertices;
        float x = posDist(rng);
        float z = posDist(rng);
        float height = heightDist(rng);
        float trunkRadius = radiusDist(rng);

        simd_float3 trunkColor = {0.35f, 0.2f, 0.1f};
        [self addCylinder:vertices base:(simd_float3){0, 0, 0} radius:trunkRadius height:height * 0.7f color:trunkColor segments:8];

        int foliageLayers = 3 + (rng() % 3);
        float foliageStart = height * 0.4f;
        float foliageHeight = height - foliageStart;

        for (int l = 0; l < foliageLayers; l++) {
            float layerY = foliageStart + (float)l / foliageLayers * foliageHeight;
            float layerRadius = (2.0f + (float)(foliageLayers - l) * 0.8f) * (1.0f + (rng() % 100) / 500.0f);
            float layerHeight = foliageHeight / foliageLayers * 1.2f;

            float greenVar = (rng() % 100) / 500.0f;
            simd_float3 leafColor = {0.1f + greenVar, 0.4f + greenVar, 0.1f + greenVar * 0.5f};

            [self addCone:vertices base:(simd_float3){0, layerY, 0} radius:layerRadius height:layerHeight color:leafColor segments:12];
        }

        id<MTLBuffer> buffer = [_device newBufferWithBytes:vertices.data()
                                                    length:vertices.size() * sizeof(Vertex)
                                                   options:MTLResourceStorageModeShared];
        [_treeBuffers addObject:buffer];
        [_treeVertexCounts addObject:@(vertices.size())];

        simd_float4x4 transform = matrix_translation(x, 0, z);
        NSValue *transformValue = [NSValue valueWithBytes:&transform objCType:@encode(simd_float4x4)];
        [_animalPositions addObject:transformValue];
    }
}

- (void)generateAnimals {
    std::mt19937 rng(123);
    std::uniform_real_distribution<float> posDist(-40, 40);

    for (int i = 0; i < 8; i++) {
        std::vector<Vertex> vertices;
        float x = posDist(rng);
        float z = posDist(rng);

        simd_float3 bodyColor = {0.45f, 0.35f, 0.2f};
        [self addSphere:vertices center:(simd_float3){0, 0.8f, 0} radius:0.6f color:bodyColor latitudes:8 longitudes:12];
        [self addSphere:vertices center:(simd_float3){0.5f, 1.0f, 0} radius:0.35f color:bodyColor latitudes:6 longitudes:8];

        simd_float3 legColor = {0.35f, 0.25f, 0.15f};
        [self addCylinder:vertices base:(simd_float3){-0.25f, 0, -0.2f} radius:0.08f height:0.5f color:legColor segments:6];
        [self addCylinder:vertices base:(simd_float3){-0.25f, 0, 0.2f} radius:0.08f height:0.5f color:legColor segments:6];
        [self addCylinder:vertices base:(simd_float3){0.25f, 0, -0.2f} radius:0.08f height:0.5f color:legColor segments:6];
        [self addCylinder:vertices base:(simd_float3){0.25f, 0, 0.2f} radius:0.08f height:0.5f color:legColor segments:6];

        id<MTLBuffer> buffer = [_device newBufferWithBytes:vertices.data()
                                                    length:vertices.size() * sizeof(Vertex)
                                                   options:MTLResourceStorageModeShared];
        [_animalBuffers addObject:buffer];
        [_animalVertexCounts addObject:@(vertices.size())];

        simd_float4x4 transform = matrix_translation(x, 0, z);
        transform = simd_mul(transform, matrix_rotation_y((float)(rng() % 628) / 100.0f));
        NSValue *transformValue = [NSValue valueWithBytes:&transform objCType:@encode(simd_float4x4)];
        [_animalPositions addObject:transformValue];
    }

    for (int i = 0; i < 6; i++) {
        std::vector<Vertex> vertices;
        float x = posDist(rng);
        float z = posDist(rng);

        simd_float3 bodyColor = {0.2f, 0.6f, 0.1f};
        [self addSphere:vertices center:(simd_float3){0, 0.15f, 0} radius:0.25f color:bodyColor latitudes:6 longitudes:8];

        simd_float3 headColor = {0.25f, 0.65f, 0.15f};
        [self addSphere:vertices center:(simd_float3){0.2f, 0.2f, 0} radius:0.12f color:headColor latitudes:5 longitudes:6];

        simd_float3 legColor = {0.15f, 0.5f, 0.1f};
        [self addCylinder:vertices base:(simd_float3){-0.15f, 0, -0.1f} radius:0.04f height:0.12f color:legColor segments:4];
        [self addCylinder:vertices base:(simd_float3){-0.15f, 0, 0.1f} radius:0.04f height:0.12f color:legColor segments:4];
        [self addCylinder:vertices base:(simd_float3){0.1f, 0, -0.15f} radius:0.04f height:0.12f color:legColor segments:4];
        [self addCylinder:vertices base:(simd_float3){0.1f, 0, 0.15f} radius:0.04f height:0.12f color:legColor segments:4];

        id<MTLBuffer> buffer = [_device newBufferWithBytes:vertices.data()
                                                    length:vertices.size() * sizeof(Vertex)
                                                   options:MTLResourceStorageModeShared];
        [_animalBuffers addObject:buffer];
        [_animalVertexCounts addObject:@(vertices.size())];

        simd_float4x4 transform = matrix_translation(x, 0, z);
        NSValue *transformValue = [NSValue valueWithBytes:&transform objCType:@encode(simd_float4x4)];
        [_animalPositions addObject:transformValue];
    }

    for (int i = 0; i < 5; i++) {
        std::vector<Vertex> vertices;
        float x = posDist(rng);
        float z = posDist(rng);

        simd_float3 bodyColor = {0.1f, 0.1f, 0.1f};
        [self addSphere:vertices center:(simd_float3){0, 3.0f, 0} radius:0.4f color:bodyColor latitudes:6 longitudes:8];
        [self addSphere:vertices center:(simd_float3){0.3f, 3.1f, 0} radius:0.2f color:bodyColor latitudes:5 longitudes:6];

        simd_float3 armColor = {0.12f, 0.1f, 0.1f};
        [self addCylinder:vertices base:(simd_float3){0, 2.6f, -0.3f} radius:0.1f height:0.6f color:armColor segments:5];
        [self addCylinder:vertices base:(simd_float3){0, 2.6f, 0.3f} radius:0.1f height:0.6f color:armColor segments:5];

        [self addCylinder:vertices base:(simd_float3){-0.1f, 2.6f, 0} radius:0.08f height:0.5f color:armColor segments:5];
        [self addCylinder:vertices base:(simd_float3){0.1f, 2.6f, 0} radius:0.08f height:0.5f color:armColor segments:5];

        id<MTLBuffer> buffer = [_device newBufferWithBytes:vertices.data()
                                                    length:vertices.size() * sizeof(Vertex)
                                                   options:MTLResourceStorageModeShared];
        [_animalBuffers addObject:buffer];
        [_animalVertexCounts addObject:@(vertices.size())];

        simd_float4x4 transform = matrix_translation(x, 0, z);
        NSValue *transformValue = [NSValue valueWithBytes:&transform objCType:@encode(simd_float4x4)];
        [_animalPositions addObject:transformValue];
    }

    for (int i = 0; i < 10; i++) {
        std::vector<Vertex> vertices;
        float x = posDist(rng);
        float z = posDist(rng);

        float hue = (float)(rng() % 100) / 100.0f;
        simd_float3 color;
        if (hue < 0.33f) {
            color = {0.9f, 0.2f, 0.1f};
        } else if (hue < 0.66f) {
            color = {0.1f, 0.3f, 0.9f};
        } else {
            color = {0.9f, 0.8f, 0.1f};
        }

        [self addSphere:vertices center:(simd_float3){0, 4.0f, 0} radius:0.15f color:color latitudes:5 longitudes:6];

        simd_float3 wingColor = {color.x * 0.8f, color.y * 0.8f, color.z * 0.8f};
        [self addCone:vertices base:(simd_float3){0, 4.0f, -0.1f} radius:0.2f height:0.05f color:wingColor segments:6];
        [self addCone:vertices base:(simd_float3){0, 4.0f, 0.1f} radius:0.2f height:0.05f color:wingColor segments:6];

        id<MTLBuffer> buffer = [_device newBufferWithBytes:vertices.data()
                                                    length:vertices.size() * sizeof(Vertex)
                                                   options:MTLResourceStorageModeShared];
        [_animalBuffers addObject:buffer];
        [_animalVertexCounts addObject:@(vertices.size())];

        simd_float4x4 transform = matrix_translation(x, 0, z);
        NSValue *transformValue = [NSValue valueWithBytes:&transform objCType:@encode(simd_float4x4)];
        [_animalPositions addObject:transformValue];
    }

    for (int i = 0; i < 4; i++) {
        std::vector<Vertex> vertices;
        float x = posDist(rng);
        float z = posDist(rng);

        simd_float3 bodyColor = {0.4f, 0.5f, 0.2f};
        float segmentLength = 0.8f;
        for (int s = 0; s < 8; s++) {
            float offset = s * segmentLength * 0.6f;
            float wave = sinf(s * 0.5f) * 0.1f;
            [self addSphere:vertices center:(simd_float3){offset, 0.15f, wave} radius:0.12f color:bodyColor latitudes:4 longitudes:6];
        }

        simd_float3 headColor = {0.35f, 0.45f, 0.15f};
        [self addSphere:vertices center:(simd_float3){-0.2f, 0.2f, 0} radius:0.15f color:headColor latitudes:5 longitudes:6];

        simd_float3 eyeColor = {0.1f, 0.1f, 0.1f};
        [self addSphere:vertices center:(simd_float3){-0.3f, 0.25f, 0.08f} radius:0.03f color:eyeColor latitudes:3 longitudes:4];
        [self addSphere:vertices center:(simd_float3){-0.3f, 0.25f, -0.08f} radius:0.03f color:eyeColor latitudes:3 longitudes:4];

        id<MTLBuffer> buffer = [_device newBufferWithBytes:vertices.data()
                                                    length:vertices.size() * sizeof(Vertex)
                                                   options:MTLResourceStorageModeShared];
        [_animalBuffers addObject:buffer];
        [_animalVertexCounts addObject:@(vertices.size())];

        simd_float4x4 transform = matrix_translation(x, 0, z);
        transform = simd_mul(transform, matrix_rotation_y((float)(rng() % 628) / 100.0f));
        NSValue *transformValue = [NSValue valueWithBytes:&transform objCType:@encode(simd_float4x4)];
        [_animalPositions addObject:transformValue];
    }
}

- (void)generateRain {
    std::mt19937 rng(999);
    std::uniform_real_distribution<float> posDist(-50, 50);
    std::uniform_real_distribution<float> heightDist(0, 60);
    std::uniform_real_distribution<float> velDist(0, 1);

    std::vector<RainParticle> particles;
    _rainParticleCount = 8000;

    for (NSUInteger i = 0; i < _rainParticleCount; i++) {
        RainParticle p;
        p.position = {posDist(rng), heightDist(rng), posDist(rng)};
        p.velocity = velDist(rng);
        particles.push_back(p);
    }

    _rainBuffer = [_device newBufferWithBytes:particles.data()
                                       length:particles.size() * sizeof(RainParticle)
                                      options:MTLResourceStorageModeShared];
}

- (void)updateCamera:(float)deltaTime {
    float moveSpeed = 8.0f * deltaTime;
    float forward = 0, right = 0;

    if (_keyW) forward += 1;
    if (_keyS) forward -= 1;
    if (_keyA) right -= 1;
    if (_keyD) right += 1;

    simd_float3 forwardDir = {sinf(_cameraYaw), 0, -cosf(_cameraYaw)};
    simd_float3 rightDir = {cosf(_cameraYaw), 0, sinf(_cameraYaw)};

    _cameraPosition = _cameraPosition + forwardDir * forward * moveSpeed;
    _cameraPosition = _cameraPosition + rightDir * right * moveSpeed;

    if (_keySpace) _cameraPosition.y += moveSpeed;
    if (_keyShift) _cameraPosition.y -= moveSpeed;

    _cameraPosition.y = fmaxf(_cameraPosition.y, 1.5f);
    _cameraPosition.x = fminf(fmaxf(_cameraPosition.x, -48), 48);
    _cameraPosition.z = fminf(fmaxf(_cameraPosition.z, -48), 48);
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {}

- (void)drawInMTKView:(MTKView *)view {
    float deltaTime = 1.0f / 60.0f;
    _time += deltaTime;
    [self updateCamera:deltaTime];

    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    MTLRenderPassDescriptor *renderPassDesc = view.currentRenderPassDescriptor;

    if (renderPassDesc) {
        renderPassDesc.colorAttachments[0].clearColor = MTLClearColorMake(0.4, 0.45, 0.5, 1.0);

        id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDesc];
        [encoder setDepthStencilState:_depthState];

        float aspect = view.drawableSize.width / view.drawableSize.height;

        simd_float3 lookDir = {
            sinf(_cameraYaw) * cosf(_cameraPitch),
            sinf(_cameraPitch),
            -cosf(_cameraYaw) * cosf(_cameraPitch)
        };
        simd_float3 target = _cameraPosition + lookDir;

        Uniforms uniforms;
        uniforms.viewMatrix = matrix_look_at(_cameraPosition, target, (simd_float3){0, 1, 0});
        uniforms.projectionMatrix = matrix_perspective(M_PI / 3.0f, aspect, 0.1f, 200.0f);
        uniforms.cameraPosition = _cameraPosition;
        uniforms.time = _time;
        uniforms.lightDirection = simd_normalize((simd_float3){0.3f, 1.0f, 0.5f});
        uniforms.fogDensity = 0.8f;
        uniforms.fogColor = (simd_float3){0.45f, 0.5f, 0.55f};
        uniforms.rainIntensity = 0.8f;

        uniforms.modelMatrix = matrix_identity();
        memcpy(_uniformBuffer.contents, &uniforms, sizeof(Uniforms));

        [encoder setRenderPipelineState:_groundPipelineState];
        [encoder setVertexBuffer:_groundBuffer offset:0 atIndex:0];
        [encoder setVertexBuffer:_uniformBuffer offset:0 atIndex:1];
        [encoder setFragmentBuffer:_uniformBuffer offset:0 atIndex:1];
        [encoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:_groundVertexCount];

        [encoder setRenderPipelineState:_pipelineState];

        for (NSUInteger i = 0; i < _treeBuffers.count; i++) {
            simd_float4x4 transform;
            [_animalPositions[i] getValue:&transform];
            uniforms.modelMatrix = transform;
            memcpy(_uniformBuffer.contents, &uniforms, sizeof(Uniforms));

            [encoder setVertexBuffer:_treeBuffers[i] offset:0 atIndex:0];
            [encoder setVertexBuffer:_uniformBuffer offset:0 atIndex:1];
            [encoder setFragmentBuffer:_uniformBuffer offset:0 atIndex:1];
            [encoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:[_treeVertexCounts[i] unsignedIntegerValue]];
        }

        NSUInteger treeCount = _treeBuffers.count;
        for (NSUInteger i = 0; i < _animalBuffers.count; i++) {
            simd_float4x4 transform;
            [_animalPositions[treeCount + i] getValue:&transform];

            float animOffset = (float)i * 0.5f;
            float bob = sinf(_time * 2.0f + animOffset) * 0.05f;
            transform.columns[3].y += bob;

            uniforms.modelMatrix = transform;
            memcpy(_uniformBuffer.contents, &uniforms, sizeof(Uniforms));

            [encoder setVertexBuffer:_animalBuffers[i] offset:0 atIndex:0];
            [encoder setVertexBuffer:_uniformBuffer offset:0 atIndex:1];
            [encoder setFragmentBuffer:_uniformBuffer offset:0 atIndex:1];
            [encoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:[_animalVertexCounts[i] unsignedIntegerValue]];
        }

        uniforms.modelMatrix = matrix_identity();
        memcpy(_uniformBuffer.contents, &uniforms, sizeof(Uniforms));

        [encoder setRenderPipelineState:_rainPipelineState];
        [encoder setVertexBuffer:_rainBuffer offset:0 atIndex:0];
        [encoder setVertexBuffer:_uniformBuffer offset:0 atIndex:1];
        [encoder drawPrimitives:MTLPrimitiveTypePoint vertexStart:0 vertexCount:_rainParticleCount];

        [encoder endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
    }

    [commandBuffer commit];
}

@end

@interface GameView : MTKView
@property (nonatomic, weak) Renderer *renderer;
@property (nonatomic, assign) NSPoint lastMouseLocation;
@property (nonatomic, assign) BOOL mouseCaptured;
@end

@implementation GameView

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)keyDown:(NSEvent *)event {
    switch (event.keyCode) {
        case 13: _renderer.keyW = YES; break;
        case 0: _renderer.keyA = YES; break;
        case 1: _renderer.keyS = YES; break;
        case 2: _renderer.keyD = YES; break;
        case 49: _renderer.keySpace = YES; break;
        case 56: case 60: _renderer.keyShift = YES; break;
        case 53:
            if (_mouseCaptured) {
                CGAssociateMouseAndMouseCursorPosition(true);
                [NSCursor unhide];
                _mouseCaptured = NO;
            }
            break;
    }
}

- (void)keyUp:(NSEvent *)event {
    switch (event.keyCode) {
        case 13: _renderer.keyW = NO; break;
        case 0: _renderer.keyA = NO; break;
        case 1: _renderer.keyS = NO; break;
        case 2: _renderer.keyD = NO; break;
        case 49: _renderer.keySpace = NO; break;
        case 56: case 60: _renderer.keyShift = NO; break;
    }
}

- (void)mouseDown:(NSEvent *)event {
    if (!_mouseCaptured) {
        CGAssociateMouseAndMouseCursorPosition(false);
        [NSCursor hide];
        _mouseCaptured = YES;
        _lastMouseLocation = [NSEvent mouseLocation];
    }
}

- (void)mouseDragged:(NSEvent *)event {
    [self handleMouseMovement:event];
}

- (void)mouseMoved:(NSEvent *)event {
    [self handleMouseMovement:event];
}

- (void)handleMouseMovement:(NSEvent *)event {
    if (_mouseCaptured) {
        float sensitivity = 0.003f;
        _renderer.cameraYaw += event.deltaX * sensitivity;
        _renderer.cameraPitch -= event.deltaY * sensitivity;
        _renderer.cameraPitch = fminf(fmaxf(_renderer.cameraPitch, -M_PI_2 + 0.1f), M_PI_2 - 0.1f);
    }
}

@end

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (nonatomic, strong) NSWindow *window;
@property (nonatomic, strong) Renderer *renderer;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSRect screenRect = [[NSScreen mainScreen] frame];
    NSRect frame = NSMakeRect((screenRect.size.width - 1280) / 2,
                              (screenRect.size.height - 720) / 2,
                              1280, 720);
    _window = [[NSWindow alloc] initWithContentRect:frame
                                          styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable | NSWindowStyleMaskMiniaturizable
                                            backing:NSBackingStoreBuffered
                                              defer:NO];
    [_window setTitle:@"Amazon Rainforest - WASD to move, Mouse to look, Space/Shift for up/down, ESC to release mouse"];
    [_window setReleasedWhenClosed:NO];

    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    if (!device) {
        NSLog(@"Metal is not supported on this device");
        [NSApp terminate:nil];
        return;
    }

    GameView *view = [[GameView alloc] initWithFrame:_window.contentView.bounds device:device];
    view.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
    view.depthStencilPixelFormat = MTLPixelFormatDepth32Float;
    view.clearColor = MTLClearColorMake(0.4, 0.45, 0.5, 1.0);
    view.preferredFramesPerSecond = 60;

    _renderer = [[Renderer alloc] initWithMetalKitView:view];
    view.delegate = _renderer;
    view.renderer = _renderer;

    [_window setContentView:view];
    [_window makeFirstResponder:view];
    [_window center];
    [_window makeKeyAndOrderFront:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        [app setActivationPolicy:NSApplicationActivationPolicyRegular];

        NSMenu *menubar = [[NSMenu alloc] init];
        NSMenuItem *appMenuItem = [[NSMenuItem alloc] init];
        [menubar addItem:appMenuItem];
        NSMenu *appMenu = [[NSMenu alloc] init];
        NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
        [appMenu addItem:quitItem];
        [appMenuItem setSubmenu:appMenu];
        [app setMainMenu:menubar];

        AppDelegate *delegate = [[AppDelegate alloc] init];
        [app setDelegate:delegate];
        [app activateIgnoringOtherApps:YES];
        [app run];
    }
    return 0;
}

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
    float3 color [[attribute(2)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 worldPosition;
    float3 normal;
    float3 color;
    float fogFactor;
};

struct Uniforms {
    float4x4 modelMatrix;
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
    float3 cameraPosition;
    float time;
    float3 lightDirection;
    float fogDensity;
    float3 fogColor;
    float rainIntensity;
};

vertex VertexOut vertex_main(VertexIn in [[stage_in]],
                             constant Uniforms& uniforms [[buffer(1)]]) {
    VertexOut out;

    float4 worldPos = uniforms.modelMatrix * float4(in.position, 1.0);
    out.worldPosition = worldPos.xyz;
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * worldPos;
    out.normal = normalize((uniforms.modelMatrix * float4(in.normal, 0.0)).xyz);
    out.color = in.color;

    float distance = length(worldPos.xyz - uniforms.cameraPosition);
    out.fogFactor = 1.0 - exp(-uniforms.fogDensity * distance * 0.01);
    out.fogFactor = clamp(out.fogFactor, 0.0, 0.85);

    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]],
                              constant Uniforms& uniforms [[buffer(1)]]) {
    float3 lightDir = normalize(uniforms.lightDirection);
    float3 normal = normalize(in.normal);

    float ambient = 0.3;
    float diffuse = max(dot(normal, lightDir), 0.0) * 0.5;
    float lighting = ambient + diffuse;

    float3 color = in.color * lighting;

    float wetness = uniforms.rainIntensity * 0.3;
    color = mix(color, color * 0.7, wetness);
    color = color * (1.0 + wetness * 0.1);

    color = mix(color, uniforms.fogColor, in.fogFactor);

    return float4(color, 1.0);
}

struct RainVertexIn {
    float3 position [[attribute(0)]];
    float velocity [[attribute(1)]];
};

struct RainVertexOut {
    float4 position [[position]];
    float alpha;
    float size [[point_size]];
};

vertex RainVertexOut rain_vertex(RainVertexIn in [[stage_in]],
                                  constant Uniforms& uniforms [[buffer(1)]]) {
    RainVertexOut out;

    float3 pos = in.position;
    float fallSpeed = 25.0 + in.velocity * 10.0;
    pos.y -= fmod(uniforms.time * fallSpeed + in.velocity * 100.0, 60.0);
    if (pos.y < 0.0) pos.y += 60.0;

    float4 worldPos = float4(pos, 1.0);
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * worldPos;

    float distance = length(pos - uniforms.cameraPosition);
    out.alpha = clamp(1.0 - distance / 80.0, 0.0, 0.6) * uniforms.rainIntensity;
    out.size = max(1.0, 3.0 - distance * 0.05);

    return out;
}

fragment float4 rain_fragment(RainVertexOut in [[stage_in]]) {
    float3 rainColor = float3(0.7, 0.75, 0.85);
    return float4(rainColor, in.alpha);
}

vertex VertexOut ground_vertex(VertexIn in [[stage_in]],
                               constant Uniforms& uniforms [[buffer(1)]]) {
    VertexOut out;

    float4 worldPos = uniforms.modelMatrix * float4(in.position, 1.0);

    float puddle = sin(in.position.x * 0.5) * cos(in.position.z * 0.5) * 0.3;
    puddle += sin(uniforms.time * 2.0 + in.position.x) * 0.02 * uniforms.rainIntensity;

    out.worldPosition = worldPos.xyz;
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * worldPos;
    out.normal = normalize((uniforms.modelMatrix * float4(in.normal, 0.0)).xyz);
    out.color = in.color * (1.0 + puddle * 0.2);

    float distance = length(worldPos.xyz - uniforms.cameraPosition);
    out.fogFactor = 1.0 - exp(-uniforms.fogDensity * distance * 0.01);
    out.fogFactor = clamp(out.fogFactor, 0.0, 0.85);

    return out;
}

fragment float4 ground_fragment(VertexOut in [[stage_in]],
                                constant Uniforms& uniforms [[buffer(1)]]) {
    float3 lightDir = normalize(uniforms.lightDirection);
    float3 normal = normalize(in.normal);

    float ambient = 0.35;
    float diffuse = max(dot(normal, lightDir), 0.0) * 0.4;
    float lighting = ambient + diffuse;

    float3 color = in.color * lighting;

    float wetness = uniforms.rainIntensity * 0.5;
    float reflection = pow(max(dot(reflect(-lightDir, normal), normalize(uniforms.cameraPosition - in.worldPosition)), 0.0), 16.0);
    color += float3(0.3, 0.35, 0.4) * reflection * wetness;

    color = mix(color, uniforms.fogColor, in.fogFactor);

    return float4(color, 1.0);
}

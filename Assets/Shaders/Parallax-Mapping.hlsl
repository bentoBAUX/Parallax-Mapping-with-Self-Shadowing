#ifndef PARALLAX_MAPPING_INCLUDED
#define PARALLAX_MAPPING_INCLUDED

float2 ParallaxMapping(sampler2D heightMap, float2 texCoords, float3 viewDir, int numLayers, float heightScale);
float2 SteepParallaxMapping(sampler2D heightMap, float2 texCoords, float3 viewDir, float3 lightDir, int numLayers,
                            float heightScale, out float shadow);
float SoftShadow(sampler2D heightMap, float2 texCoords, float3 lightDir, float numLayers, float heightScale);

float ParallaxShadow(sampler2D heightMap, float2 texCoords, float3 lightDir, float numLayers, float heightScale);

float2 ParallaxMapping(sampler2D heightMap, float2 texCoords, float3 viewDir, int numLayers, float heightScale)
{
    if (texCoords.x > 1.0 || texCoords.y > 1.0 || texCoords.x < 0.0 || texCoords.y < 0.0)
        discard;
    float height = tex2D(heightMap, texCoords).r;
    float2 p = viewDir.xy / viewDir.z * height * heightScale;
    return texCoords - p;
}

float2 SteepParallaxMapping(sampler2D heightMap, float2 texCoords, float3 viewDir, int numLayers, float heightScale)
{
    if (texCoords.x > 1.0 || texCoords.y > 1.0 || texCoords.x < 0.0 || texCoords.y < 0.0)
        discard;

    float optimisedLayers = lerp(32, numLayers, max(dot(float3(0, 0, 1), viewDir), 0));
    float layerDepth = 1.0 / optimisedLayers;

    float2 p = viewDir.xy * heightScale;
    float2 deltaTexCoords = p / optimisedLayers;

    float currentLayerDepth = 0.0;
    float2 currentTexCoords = texCoords;
    float currentDepth = tex2Dlod(heightMap, float4(currentTexCoords, 0, 0.0)).r;


    while (currentLayerDepth < currentDepth)
    {
        currentTexCoords -= deltaTexCoords;
        currentDepth = tex2Dlod(heightMap, float4(currentTexCoords, 0, 0.0)).r;
        currentLayerDepth += layerDepth;
    }

    float2 prevTexCoords = currentTexCoords + deltaTexCoords;
    float afterDepth = currentDepth - currentLayerDepth;
    float beforeDepth = tex2Dlod(heightMap, float4(prevTexCoords, 0, 0)).r - currentLayerDepth + layerDepth;

    float weight = afterDepth / (afterDepth - beforeDepth);
    float2 finalTexCoords = prevTexCoords * weight + currentTexCoords * (1.0 - weight);


    return finalTexCoords;
}

float ParallaxShadow(sampler2D heightMap, float2 texCoords, float3 lightDir, float numLayers, float heightScale)
{
    float optimisedLayers = lerp(16, numLayers, max(dot(float3(0, 0, 1), lightDir), 0)); // Adjust for performance
    float layerDepth = 1.0 / optimisedLayers;

    float2 p = lightDir.xy / (abs(lightDir.z) + 0.01) * heightScale; // Normalize step size
    float2 deltaTexCoords = p / optimisedLayers;

    float2 currentTexCoords = texCoords;
    float h0 = tex2D(heightMap, currentTexCoords).r;
    float currentLayerDepth = h0;

    float shadowBias = 0.03; // Bias to reduce self-shadowing
    int maxIterations = 32; // Cap iterations
    int i = 0;

    // Traverse along the light direction
    while (currentLayerDepth <= h0 + shadowBias && currentLayerDepth > 0.0 && i < maxIterations)
    {
        currentTexCoords += deltaTexCoords;
        h0 = tex2D(heightMap, currentTexCoords).r;
        currentLayerDepth -= layerDepth;
        i++;
    }

    return currentLayerDepth > h0 ? 0.0 : 1.0; // No occlusion = fully lit
}


#endif

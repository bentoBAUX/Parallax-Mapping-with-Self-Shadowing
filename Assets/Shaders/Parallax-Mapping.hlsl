#ifndef PARALLAX_MAPPING_INCLUDED
#define PARALLAX_MAPPING_INCLUDED

float2 ParallaxMapping(sampler2D depthMap, float2 texCoords, float3 viewDir, float depthScale);
float2 SteepParallaxMapping(sampler2D depthMap, float2 texCoords, float3 viewDir, float3 lightDir, int numLayers,
                            float depthScale, out float shadow);
float ParallaxShadow(sampler2D depthMap, float2 texCoords, float3 lightDir, float maxLayers, float depthScale);

float2 ParallaxMapping(sampler2D depthMap, float2 texCoords, float3 viewDir, float depthScale)
{
    float depth = tex2D(depthMap, texCoords).r;
    float2 p = viewDir.xy / viewDir.z * depth * depthScale;
    return texCoords - p;
}

float2 SteepParallaxMapping(sampler2D depthMap, float2 texCoords, float3 viewDir, int numLayers, float depthScale)
{
    float layerDepth = 1.0 / numLayers;

    float2 p = viewDir.xy * depthScale;
    float2 stepVector = p / numLayers;

    float currentLayerDepth = 0.0;
    float2 currentTexCoords = texCoords;
    float currentDepthMapValue = tex2Dlod(depthMap, float4(currentTexCoords, 0, 0.0)).r;

    while (currentLayerDepth < currentDepthMapValue)
    {
        currentTexCoords -= stepVector;
        currentDepthMapValue = tex2Dlod(depthMap, float4(currentTexCoords, 0, 0.0)).r;
        currentLayerDepth += layerDepth;
    }

    float2 prevTexCoords = currentTexCoords + stepVector;
    float afterDepth = currentDepthMapValue - currentLayerDepth;
    float beforeDepth = tex2Dlod(depthMap, float4(prevTexCoords, 0, 0)).r - currentLayerDepth + layerDepth;

    float weight = afterDepth / (afterDepth - beforeDepth);
    float2 finalTexCoords = prevTexCoords * weight + currentTexCoords * (1.0 - weight);


    return finalTexCoords;
}

float ParallaxShadow(sampler2D depthMap, float2 texCoords, float3 lightDir, float numLayers, float depthScale)
{
    if (lightDir.z <= 0) return 0.0;

    float layerDepth = 1.0 / numLayers;

    float2 p = lightDir.xy / lightDir.z * depthScale; // Normalize step size
    float2 stepVector = p / numLayers;

    float2 currentTexCoords = texCoords;
    float currentDepthMapValue = tex2D(depthMap, currentTexCoords).r;
    float currentLayerDepth = currentDepthMapValue;

    float shadowBias = 0.03; // Bias to reduce self-shadowing
    int maxIterations = 32; // Cap iterations
    int iterationCount = 0;

    // Traverse along the light direction
    while (currentLayerDepth <= currentDepthMapValue + shadowBias && currentLayerDepth > 0.0 && iterationCount < maxIterations)
    {
        currentTexCoords += stepVector;
        currentDepthMapValue = tex2D(depthMap, currentTexCoords).r;
        currentLayerDepth -= layerDepth;
        iterationCount++;
    }

    return currentLayerDepth > currentDepthMapValue ? 0.0 : 1.0; // No occlusion = fully lit
}


#endif

#ifndef PARALLAX_MAPPING_INCLUDED
#define PARALLAX_MAPPING_INCLUDED

float2 SimpleParallaxMapping(sampler2D depthMap, float2 texCoords, float3 viewDir, float depthScale);
float2 SteepParallaxMapping(sampler2D depthMap, float2 texCoords, float3 viewDir, float3 lightDir, int numLayers, float depthScale);
float SelfShadowing(sampler2D depthMap, float2 texCoords, float3 lightDir, float numLayers, float depthScale);

float2 SimpleParallaxMapping(sampler2D depthMap, float2 texCoords, float3 viewDir, float depthScale)
{
    float depth = tex2D(depthMap, texCoords).r;
    float2 p = viewDir.xy / viewDir.z * depth * depthScale;
    return texCoords - p;
}

float2 SteepParallaxMapping(sampler2D depthMap, float2 texCoords, float3 viewDir, int numLayers, float depthScale)
{
    // Calculate the size of a single layer
    float layerDepth = 1.0 / numLayers;

    // Determine the step vector based on our view angle
    float2 p = viewDir.xy * depthScale;
    float2 stepVector = p / numLayers;

    // Initialise and set starting values before the loop
    float currentLayerDepth = 0.0;
    float2 currentTexCoords = texCoords;

    // Sample with fixed LOD to avoid issues in loops that will cause GPU timeouts
    float currentDepthMapValue = tex2Dlod(depthMap, float4(currentTexCoords, 0, 0.0)).r;

    // Loop until we have stepped too far below the surface (the surface is where the depth map says it is)
    while (currentLayerDepth < currentDepthMapValue)
    {
        // Shift the texture coordinates in the direction of step vector
        currentTexCoords -= stepVector;

        // Sample the depthmap with the new texture coordinate to get the new depth value
        currentDepthMapValue = tex2Dlod(depthMap, float4(currentTexCoords, 0, 0.0)).r;

        // Move on to the next layer
        currentLayerDepth += layerDepth;
    }

    // Compute the texture coordinates from the previous iteration
    float2 prevTexCoords = currentTexCoords + stepVector;

    // Compute how far below the surface we are at the current step
    float surfaceOffsetAfter = currentDepthMapValue - currentLayerDepth;

    // Compute how far above the surface we were at the previous step
    float surfaceOffsetBefore = tex2Dlod(depthMap, float4(prevTexCoords, 0, 0)).r - currentLayerDepth + layerDepth;

    // Linearly interpolate the texture coordinates using the calculated weight
    float weight = surfaceOffsetAfter / (surfaceOffsetAfter - surfaceOffsetBefore);
    float2 finalTexCoords = prevTexCoords * weight + currentTexCoords * (1.0 - weight);

    return finalTexCoords;
}

float SelfShadowing(sampler2D depthMap, float2 texCoords, float3 lightDir, float numLayers, float depthScale)
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

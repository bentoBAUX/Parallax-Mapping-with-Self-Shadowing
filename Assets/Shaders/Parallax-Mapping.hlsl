#ifndef PARALLAX_MAPPING_INCLUDED
#define PARALLAX_MAPPING_INCLUDED

float2 ParallaxMapping(sampler2D heightMap, float2 texCoords, float3 viewDir, int numLayers, float heightScale);
float2 SteepParallaxMapping(sampler2D heightMap, float2 texCoords, float3 viewDir, float3 lightDir, int numLayers,
                            float heightScale, out float shadow);
float Shadow(sampler2D heightMap, float2 texCoords, float3 lightDir, float numLayers, float heightScale);

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

    float adjustedNumLayers = lerp(32, numLayers, max(dot(float3(0, 0, 1), viewDir), 0));
    float layerDepth = 1.0 / adjustedNumLayers;
    float currentLayerDepth = 0.0;

    float2 p = viewDir.xy * heightScale;
    float2 deltaTexCoords = p / adjustedNumLayers;

    float2 currentTexCoords = texCoords;
    float currentDepth = tex2Dlod(heightMap, float4(currentTexCoords, 0, 0)).r;

    while (currentLayerDepth < currentDepth)
    {
        currentTexCoords -= deltaTexCoords;
        currentDepth = tex2Dlod(heightMap, float4(currentTexCoords, 0, 0)).r;
        currentLayerDepth += layerDepth;
    }
    float2 prevTexCoords = currentTexCoords + deltaTexCoords;
    float afterDepth = currentDepth - currentLayerDepth;
    float beforeDepth = tex2Dlod(heightMap, float4(prevTexCoords, 0, 0)).r - currentLayerDepth + layerDepth;

    float weight = afterDepth / (afterDepth - beforeDepth);
    float2 finalTexCoords = prevTexCoords * weight + currentTexCoords * (1.0 - weight);


    return finalTexCoords;
}

float Shadow(sampler2D heightMap, float2 texCoords, float3 lightDir, float numLayers, float heightScale)
{
    float adjustedNumLayers = lerp(32, numLayers, max(dot(float3(0, 0, 1), lightDir), 0));

    float layerDepth = 1.0 / adjustedNumLayers;

    float2 p = lightDir.xy / lightDir.z * heightScale; // Fix projection scaling
    float2 deltaTexCoords = p / adjustedNumLayers;

    float2 currentTexCoords = texCoords;
    float currentDepth = tex2Dlod(heightMap, float4(currentTexCoords, 0, 0)).r;
    float currentLayerDepth = currentDepth;

    while (currentLayerDepth <= currentDepth && currentLayerDepth > 0.0)
    {
        currentTexCoords += deltaTexCoords;
        currentDepth = tex2Dlod(heightMap, float4(currentTexCoords, 0, 0)).r;
        currentLayerDepth -= layerDepth;
    }

    return currentLayerDepth > currentDepth ? 0.0 : 1.0;
}


#endif

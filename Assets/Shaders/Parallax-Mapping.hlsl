#ifndef PARALLAX_MAPPING_INCLUDED
#define PARALLAX_MAPPING_INCLUDED

float2 ParallaxMapping(sampler2D heightMap, float2 texCoords, float3 viewDir, int numLayers, float heightScale)
{
    if (texCoords.x > 1.0 || texCoords.y > 1.0 || texCoords.x < 0.0 || texCoords.y < 0.0)
        discard;
    float height = tex2D(heightMap,texCoords).r;
    float2 p = viewDir.xy/viewDir.z  * height * heightScale;
    return texCoords - p;
}

float2 SteepParallaxMapping(sampler2D heightMap, float2 texCoords, float3 viewDir, int numLayers, float heightScale)
{
    if (texCoords.x > 1.0 || texCoords.y > 1.0 || texCoords.x < 0.0 || texCoords.y < 0.0)
        discard;

    float layerDepth = 1.0/numLayers;
    float currentLayerDepth = 0.0;

    float2 p = viewDir.xy * heightScale;
    float2 deltaTexCoords = p/numLayers;

    float2 currentTexCoords = texCoords;
    float currentDepth = tex2Dlod(heightMap,float4(currentTexCoords,0,0)).r;

    while (currentLayerDepth < currentDepth)
    {
        currentTexCoords -= deltaTexCoords;
        currentDepth = tex2Dlod(heightMap,float4(currentTexCoords,0,0)).r;
        currentLayerDepth += layerDepth;
    }
    float2 prevTexCoords = currentTexCoords + deltaTexCoords;
    float afterDepth = currentDepth - currentLayerDepth;
    float beforeDepth = tex2Dlod(heightMap, float4(prevTexCoords,0,0)).r - currentLayerDepth + layerDepth;

    float weight = afterDepth / (afterDepth - beforeDepth);
    float2 finalTexCoords = prevTexCoords * weight + currentTexCoords * (1.0 - weight);
    
    return finalTexCoords;
}

#endif

#ifndef TOONCHARACTER_SURFACE_INCLUDED
#define TOONCHARACTER_SURFACE_INCLUDED

struct CustomSurfaceData
{
    half3 albedo;
    half3 specular;
    half  metallic;
    half  smoothness;
    half3 normalTS;
    half3 emission;
    half  occlusion;
    half  alpha;
    half3 goochDarkColor;
    half3 goochBrightColor;

    float3 tangentWS;
    float3 bitangentWS;

};

#endif

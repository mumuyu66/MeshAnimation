#ifndef TOONCHARACTER_CORE_INCLUDED
#define TOONCHARACTER_CORE_INCLUDED

#include "Common.hlsl"
#include "SurfaceData.hlsl"


//Why unity doesnt support scaled normal in mobile ???
half3 SampleNormalScaled(float2 uv, TEXTURE2D_PARAM(bumpMap, sampler_bumpMap), half scale = 1.0h)
{
#ifdef _NORMALMAP
    half4 n = SAMPLE_TEXTURE2D(bumpMap, sampler_bumpMap, uv);
    return UnpackNormalScale(n, scale);
#else
    return half3(0.0h, 0.0h, 1.0h);
#endif
}

half3 XD_SampleEmission(float2 uv, half3 emissionColor, TEXTURE2D_PARAM(emissionMap, sampler_emissionMap))
{
#ifndef _ENABLEEMISSION
    return 0;
#else
    return SAMPLE_TEXTURE2D(emissionMap, sampler_emissionMap, uv).rgb * emissionColor;
#endif
}

inline void InitializeCustomSurfaceData(float2 uv, float3 tangentWS,float3 bitangentWS,out CustomSurfaceData outSurfaceData){
    outSurfaceData = (CustomSurfaceData) 0;

   
    //mask.r = metallic,mask.g = occlusion,mask.b = roughness
    half4 albedoAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    outSurfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb;
    outSurfaceData.alpha = albedoAlpha.a* _BaseColor.a;

#ifdef _METALLICMAP
    half4 mask = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_MetallicMap, sampler_MetallicMap));
    outSurfaceData.metallic = mask.r;
    outSurfaceData.occlusion = _OcclusionStrength * lerp(1.0,mask.g,_AOStrength);
    outSurfaceData.smoothness = 1- mask.b;
#else
    outSurfaceData.metallic = _Metallic; 
    outSurfaceData.smoothness = _Smoothness;
    outSurfaceData.occlusion = _OcclusionStrength;
#endif
    outSurfaceData.specular = 0;
    outSurfaceData.tangentWS = tangentWS;
    outSurfaceData.bitangentWS = bitangentWS;
    outSurfaceData.normalTS = SampleNormalScaled(uv,TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
    #ifndef _ENABLEEMISSION
    outSurfaceData.emission = _EmissionColor.rgb;
    #else
    outSurfaceData.emission = XD_SampleEmission(uv, _EmissionColor.rgb, TEXTURE2D_ARGS(_Emissionmap, sampler_Emissionmap));
    #endif
    outSurfaceData.goochBrightColor = _GoochBrightColor;
    outSurfaceData.goochDarkColor = _GoochDarkColor;

}

//threshold based lighting type
inline half Cel(half threshold, half smoothnessMin, half smoothnessMax, half value)
{
    #if SHADER_TARGET >= 35 && !defined(SHADER_API_GLES) && !defined(SHADER_API_GLES3)
        half ddxy = fwidth(value);
        return smoothstep(threshold - smoothnessMin - ddxy, threshold + smoothnessMax + ddxy, value);
    #else
        return smoothstep(threshold - smoothnessMin, threshold + smoothnessMax, value);
    #endif
}

//level based lighting type
inline half Banding(half v, half levels, half smoothnessMin, half smoothnessMax, half threshold, half fade)
{ 
    levels--;
    threshold = lerp(threshold, threshold * levels, fade);
    half vl = v * lerp(1, levels, fade);
    half levelStep = Rcp(levels);

    half bands = Cel(threshold, smoothnessMin, smoothnessMax, vl);
    bands += Cel(levelStep + threshold, smoothnessMin, smoothnessMax, vl);
    bands += Cel(levelStep * 2 + threshold, smoothnessMin, smoothnessMax, vl) * step(3, levels);
    bands += Cel(levelStep * 3 + threshold, smoothnessMin, smoothnessMax, vl) * step(4, levels);
    bands += Cel(levelStep * 4 + threshold, smoothnessMin, smoothnessMax, vl) * step(5, levels);
    bands += Cel(levelStep * 5 + threshold, smoothnessMin, smoothnessMax, vl) * step(6, levels);

    return bands * levelStep;
}


void RebuildTB(half3 normalWS, out half3 tangentWS,out half3 bitangentWS){
    tangentWS = SafeNormalize(cross(normalWS,half3(0,1.0,0)));
    bitangentWS = SafeNormalize(cross(normalWS,tangentWS));
}

//Scale of the aniso
inline half2 AnisoScale(half roughness, half anisotropy)
{
    return half2(roughness * (1 + anisotropy), roughness * (1 - anisotropy));
}


#endif

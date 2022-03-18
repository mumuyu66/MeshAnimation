#ifndef TOON_LIGHTING_INCLUDED
#define TOON_LIGHTING_INCLUDED



inline half3 XD_DirectBRDFSpecular(BRDFData brdfData,half3 lightDirectionWS,half3 normalWS, half3 viewDirectionWS,half3 tangentWS,half3 bitangentWS)
{
    float3 halfDir  = SafeNormalize(float3(lightDirectionWS) + float3(viewDirectionWS));
    float NoH = saturate(dot(normalWS, halfDir));
    float NoL = saturate(dot(normalWS,lightDirectionWS));
    float NoV = saturate(dot(normalWS,viewDirectionWS));
    float VoH = saturate(dot(viewDirectionWS,halfDir));



#ifdef _SPECULARMODE_ANISOTROPIC
    // half3 tangentWS;
    // half3 bitangentWS;
    // RebuildTB(normalWS,tangentWS,bitangentWS);
    float ToH = (dot(tangentWS,halfDir));
    float BoH = (dot(bitangentWS,halfDir));
    float ToV = (dot(tangentWS,viewDirectionWS));
    float BoV = (dot(bitangentWS,viewDirectionWS));
    float ToL = (dot(tangentWS,lightDirectionWS));
    float BoL = (dot(bitangentWS,lightDirectionWS));
    half2 roughnessBT = AnisoScale(brdfData.roughness,_Anisotropy);
    half DVis = DV_SmithJointGGXAniso(ToH,BoH, NoH,
                        ToV,BoV, NoV,
                        ToL, BoL, NoL,
                        roughnessBT.y,  roughnessBT.x);

#else
    half DVis = DV_SmithJointGGX(NoH,NoL,NoV,brdfData.roughness);
#endif

    #if defined(CELLSHADING_SPECULAR) && !defined(_PBR_SHADING_ON)
        DVis = Banding(DVis,_LightBands,_SpecularSmoothness * 0.5,_SpecularSmoothness * 0.5,_SpecularLightThreshold,_LightBandsScale);
    #endif
    half3 F = F_Schlick( brdfData.specular, VoH);
    return DVis * F * _SpecularIntensity;

}

half3 ANISOReflect(half3 reflectDirection,half3 tangentWS,half3 bitangentWS,half3 normalWS,half anisotropy){
    half3 stretchDir;
    #if SHADER_TARGET >= 30
        stretchDir = anisotropy > 0 ? tangentWS : bitangentWS;
    #else
        stretchDir =  bitangentWS;
    #endif
    half3 reflectNormal = SafeNormalize(lerp(normalWS, cross(cross(reflectDirection, stretchDir), stretchDir), abs(anisotropy) * 0.5));
    return  reflectDirection - 3.0 * dot(reflectNormal, reflectDirection) * reflectNormal;
}

half3 XD_EnvironmentBRDF(BRDFData brdfData, half3 indirectDiffuse, half3 indirectSpecular, half fresnelTerm)
{
    half3 c = indirectDiffuse * brdfData.diffuse;
    c += indirectSpecular * EnvironmentBRDFSpecular(brdfData, fresnelTerm);
    return c;
}


half3 XD_GlobalIllumination(BRDFData brdfData, half3 bakedGI, half occlusion,
    half3 normalWS, half3 viewDirectionWS,half3 tangentWS,half3 bitangentWS)
{
#ifdef _SPECULARMODE_ANISOTROPIC
    half3 reflectVector = ANISOReflect(-viewDirectionWS,tangentWS,bitangentWS,normalWS,_Anisotropy);
#else
    half3 reflectVector = reflect(-viewDirectionWS, normalWS);
#endif
    half NoV = saturate(dot(normalWS, viewDirectionWS));
    half fresnelTerm = Pow4(1.0 - NoV);

    half3 indirectDiffuse = bakedGI * occlusion;
    half3 indirectSpecular = GlossyEnvironmentReflection(reflectVector, brdfData.perceptualRoughness, occlusion);
    
    half3 color = EnvironmentBRDF(brdfData, indirectDiffuse, indirectSpecular, fresnelTerm);
    return color;
}


half3 XD_LightingPhysicallyBased(BRDFData brdfData,Light light,half3 normalWS, half3 viewDirectionWS,half3 tangentWS,half3 bitangentWS){
    half3 lightDirectionWS = light.direction;
    half NdotL = saturate(dot(normalWS, lightDirectionWS));
    half attenuation =  light.distanceAttenuation * light.shadowAttenuation ;
    
    
    half3  lu = light.color * (attenuation);
    half3 radiance = lu * NdotL;
    #ifndef _PBR_SHADING_ON
    half band = Banding(NdotL,_LightBands,_DiffuseSmoothness * .5,_DiffuseSmoothness * .5,_LightThreshold,_LightBandsScale);
    half goochLerpValue = band * attenuation;
    half3 gooch = lerp(_GoochDarkColor,_GoochBrightColor,goochLerpValue);
    half3 brdf = brdfData.diffuse * light.color * gooch * light.distanceAttenuation;
    #else
    half3 brdf = brdfData.diffuse * radiance;
    #endif

    #if  defined(_SPECULARMODE_ISOTROPIC) || defined(_SPECULARMODE_ANISOTROPIC)
        brdf += XD_DirectBRDFSpecular( brdfData, lightDirectionWS, normalWS, viewDirectionWS, tangentWS, bitangentWS) * radiance;
    #endif
    return brdf ;
}




inline void XD_InitializeBRDFDataDirect(half3 diffuse, half3 specular, half reflectivity, half oneMinusReflectivity, half smoothness,out BRDFData outBRDFData)
{
    outBRDFData.diffuse = diffuse;
    outBRDFData.specular = specular;
    outBRDFData.reflectivity = reflectivity;

    outBRDFData.perceptualRoughness = PerceptualSmoothnessToPerceptualRoughness(smoothness);
    outBRDFData.roughness           = PerceptualRoughnessToRoughness(outBRDFData.perceptualRoughness);
    outBRDFData.roughness2          = max(outBRDFData.roughness * outBRDFData.roughness, HALF_MIN);
    outBRDFData.grazingTerm         = saturate(smoothness + reflectivity);
    outBRDFData.normalizationTerm   = outBRDFData.roughness * 4.0h + 2.0h;
    outBRDFData.roughness2MinusOne  = outBRDFData.roughness2 - 1.0h;

}



inline void XD_InitializeBRDFData(half3 albedo, half metallic, half3 specular, half smoothness, out BRDFData outBRDFData)
{
#if  defined(_SPECULARMODE_ISOTROPIC) || defined(_SPECULARMODE_ANISOTROPIC)
    half oneMinusReflectivity = OneMinusReflectivityMetallic(metallic);
    half reflectivity = 1.0 - oneMinusReflectivity;
    half3 brdfDiffuse = albedo * oneMinusReflectivity;
    half3 brdfSpecular = lerp(kDieletricSpec.rgb, albedo, metallic);
    XD_InitializeBRDFDataDirect(brdfDiffuse, brdfSpecular, reflectivity, oneMinusReflectivity, smoothness,outBRDFData);
#else
    outBRDFData = (BRDFData) 0;
    outBRDFData.diffuse = albedo;
#endif

    
}
half4 XD_UniversalFragmentToonPBR(InputData inputData, CustomSurfaceData surfaceData){
    
    half3 tangentWS;
    half3 bitangentWS;
    RebuildTB(inputData.normalWS,tangentWS,bitangentWS);

#if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
    half4 shadowMask = inputData.shadowMask;
#elif !defined (LIGHTMAP_ON)
    half4 shadowMask = unity_ProbesOcclusion;
#else
    half4 shadowMask = half4(1, 1, 1, 1);
#endif 

    Light mainLight = GetMainLight(inputData.shadowCoord,inputData.positionWS,shadowMask);
    BRDFData brdfData;
    XD_InitializeBRDFData(surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness,brdfData);
    MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI);
    half3 color = XD_GlobalIllumination(brdfData,inputData.bakedGI,surfaceData.occlusion,inputData.normalWS,inputData.viewDirectionWS,tangentWS,bitangentWS);
    color += XD_LightingPhysicallyBased(brdfData,mainLight,inputData.normalWS, inputData.viewDirectionWS,tangentWS,bitangentWS);
    
#ifdef _ADDITIONAL_LIGHTS
    uint pixelLightCount = GetAdditionalLightsCount();
    for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
    {
        Light light = GetAdditionalLight(lightIndex, inputData.positionWS, 1.0);
        color += XD_LightingPhysicallyBased(brdfData, light,inputData.normalWS, inputData.viewDirectionWS,tangentWS,bitangentWS);
    }
#endif

    color += surfaceData.emission;
    return half4(color,1.0);
}


#endif

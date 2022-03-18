#ifndef TOONCHARACTER_COMMON_INCLUDED
#define TOONCHARACTER_COMMON_INCLUDED

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Macros.hlsl"

#ifndef SHADER_API_METAL
    half SafeDivide(half v, half d)
    {
        return v / (d + HALF_MIN);
    }
    half2 SafeDivide(half2 v, half d)
    {
        return v / (d + HALF_MIN);
    }
    half2 SafeDivide(half2 v, half2 d)
    {
        return v / (d + HALF_MIN);
    }
    half3 SafeDivide(half3 v, half d)
    {
        return v / (d + HALF_MIN);
    }
    half3 SafeDivide(half3 v, half3 d)
    {
        return v / (d + HALF_MIN);
    }
    half4 SafeDivide(half4 v, half d)
    {
        return v / (d + HALF_MIN);
    }
    half4 SafeDivide(half4 v, half4 d)
    {
        return v / (d + HALF_MIN);
    }
#endif
float SafeDivide(float v, float d)
{
    return v / (d + HALF_MIN);
}
float2 SafeDivide(float2 v, float d)
{
    return v / (d + HALF_MIN);
}
float2 SafeDivide(float2 v, float2 d)
{
    return v / (d + HALF_MIN);
}
float3 SafeDivide(float3 v, float d)
{
    return v / (d + HALF_MIN);
}
float3 SafeDivide(float3 v, float3 d)
{
    return v / (d + HALF_MIN);
}
float4 SafeDivide(float4 v, float d)
{
    return v / (d + HALF_MIN);
}
float4 SafeDivide(float4 v, float4 d)
{
    return v / (d + HALF_MIN);
}


//Single Component Reciprocal
inline half Rcp(half v)
{
    #if SHADER_TARGET >= 50
        return rcp(v);
    #else
        //avoid division by 0
        return SafeDivide(1.0, v);
    #endif
}

inline half FastPow2(half v)
{
    return v * v;
}

inline half FastPow3(half v)
{
    return v * v * v;
}

inline half FastPow4(half v)
{
    return v * v * v * v;
}

inline half FastPow5(half v)
{
    return v * v * v * v * v;
}



#endif

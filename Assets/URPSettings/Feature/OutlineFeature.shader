Shader "URPFeature/Outline"
{
    Properties
    {
        [Header(OutlineSettings)]
        [Header(Stencil)]
        [Space(5)]
        [IntRange] _Stencil("Stencil Reference", Range(0, 255)) = 1
        _OutlineWidth           ("Outline Width",Range(0,2)) = 0.01
        _OutlineColor           ("Outline Color",Color) = (0.0,0.0,0.0,1.0)
        [KeywordEnum(Origin,Tangent,UV2,VertexColor)]
        _SmoothNormalInChannel("Smooth Normal In Channel", Float)  = 0 
        _OffsetZ("OffsetZ",Float ) = 0
        
        // BlendMode
        [HideInInspector] _SrcBlend("Src", Float) = 1.0
        [HideInInspector] _DstBlend("Dst", Float) = 0.0
        [HideInInspector] _ZWrite("ZWrite", Float) = 1.0
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("ZTestForCull",Float) = 0

        // Editmode props
        [HideInInspector] _QueueOffset("Queue offset", Float) = 0.0

        // ObsoleteProperties
        [HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
        [HideInInspector] _Color("Base Color", Color) = (0.5, 0.5, 0.5, 1)
        [HideInInspector] _SampleGI("SampleGI", float) = 0.0 // needed from bakedlit
    }
    SubShader
    {
        Tags {"RenderType" = "Opaque" "IgnoreProjector" = "True" "RenderPipeline" = "UniversalPipeline" "ShaderModel"="4.5"}
        LOD 100

        Blend [_SrcBlend][_DstBlend]
        ZWrite [_ZWrite]
        Cull  Back

        Pass
        {
            Name "NDC_OUTLINE"
            Tags{"LightMode" = "UniversalForward"}

            Stencil {
                Ref[_Stencil]
                Comp  NotEqual
                Pass  Keep
                Fail  Keep
                ZFail Keep
            }

            ZWrite On
            Cull  Front

            HLSLPROGRAM
            #pragma multi_compile_fog
            #pragma shader_feature_local __ _SMOOTHNORMALINCHANNEL_TANGENT _SMOOTHNORMALINCHANNEL_UV2 _SMOOTHNORMALINCHANNEL_VERTEXCOLOR

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityInput.hlsl"

            struct appdata
            {
                float4 vertex   : POSITION;
                #ifdef _SMOOTHNORMALINCHANNEL_UV2
                    float4 uv2      : TEXCOORD1;
                #endif

                #ifdef _SMOOTHNORMALINCHANNEL_VERTEXCOLOR
                    float4 color    : COLOR;
                #endif

                #ifdef _SMOOTHNORMALINCHANNEL_TANGENT
                    float4 tangent    : TANGENT;
                #endif

                float4 normal   : NORMAL;

                UNITY_VERTEX_INPUT_INSTANCE_ID

            };

            struct v2f
            {
                float fogCoord  : TEXCOORD0;
                float4 vertex   : SV_POSITION;
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            half4 _BaseColor;
            half _BumpScale;
            half3 _EmissionColor;
            //Specular Setup
            half _SpecularIntensity;
            half _Anisotropy;
            half _Metallic;
            half _Smoothness;
            half _AOStrength;
            half _OcclusionStrength;
            half _LightBands;
            half _LightBandsScale;
            half _LightThreshold;
            half _DiffuseSmoothness;
            half _SpecularSmoothness;
            half _SpecularLightThreshold;


            //Rim
            half4 _RimColor;
            half _RimPower;


            half3 _GoochBrightColor;
            half3 _GoochDarkColor;
            half _Cutoff;
            half _Surface;
            half _OutlineWidth;
            half3 _OutlineColor;
            half _OffsetZ;
            CBUFFER_END


            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);

                #ifdef _SMOOTHNORMALINCHANNEL_UV2
                    float3 outDir;
                    v.uv2.x = v.uv2.x * 255.0 / 16.0;
                    outDir.x = floor(v.uv2.x) / 15.0;
                    outDir.y = frac(v.uv2.x) * 16.0 / 15.0;
                    outDir.z = v.uv2.y;
                    outDir = 2 * outDir - 1;
                #elif  _SMOOTHNORMALINCHANNEL_VERTEXCOLOR
                    float3 outDir = 2 * v.color.xyz - 1;
                #elif  _SMOOTHNORMALINCHANNEL_TANGENT
                    float3 outDir = v.tangent;
                #else
                    float3 outDir = v.normal.xyz;
                #endif
                float3 normalCS = mul(UNITY_MATRIX_VP, mul(UNITY_MATRIX_M, float4(outDir, 0.0))).xyz;

                float3 normalVS = mul((float3x3)UNITY_MATRIX_IT_MV, outDir.xyz);

                float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                float4 pos = TransformWorldToHClip(positionWS);
                o.fogCoord = ComputeFogFactor(pos.z);

                half3 viewdir = normalize(_WorldSpaceCameraPos.xyz - pos.xyz);
                float3 normalNDC = normalize(mul(UNITY_MATRIX_P, normalVS.xyz)) * pos.w;


                float aspect = abs(_ScreenParams.y / _ScreenParams.x);
                normalNDC.x *= aspect;
                pos.xy += 0.01 * _OutlineWidth * normalNDC.xy ;
                o.vertex = pos;
                // float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                //// half3 viewDirWS = _WorldSpaceCameraPos.xyz - positionWS;
                // o.vertex = TransformWorldToHClip(positionWS);
                float4 clipCameraPos = mul(UNITY_MATRIX_VP, float4(_WorldSpaceCameraPos.xyz, 1));

                #if defined(UNITY_REVERSED_Z)
                    //DX
                    _OffsetZ = _OffsetZ * -0.01;
                #else
                    //OpenGL
                    _OffsetZ = _OffsetZ * 0.01;
                #endif
                o.vertex.z += _OffsetZ * clipCameraPos.z;
                
                

                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                half4 col = float4(_OutlineColor.xyz, 1.0);
                col.rgb = MixFog(col.rgb,i.fogCoord);
                return col;
            }
            ENDHLSL
        }
    }
    SubShader
    {
        Tags {"RenderType" = "Opaque" "IgnoreProjector" = "True" "RenderPipeline" = "UniversalPipeline" "ShaderModel"="3.0"}
        LOD 100

        Blend [_SrcBlend][_DstBlend]
        ZWrite [_ZWrite]
        Cull  Back

        Pass
        {
            Name "NDC_OUTLINE"
            Tags{"LightMode" = "UniversalForward"}

            Stencil {
                Ref[_Stencil]
                Comp  NotEqual
                Pass  Keep
                Fail  Keep
                ZFail Keep
            }

            ZWrite On
            Cull  Front

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma multi_compile_fog
            #pragma shader_feature_local __ _SMOOTHNORMALINCHANNEL_TANGENT _SMOOTHNORMALINCHANNEL_UV2 _SMOOTHNORMALINCHANNEL_VERTEXCOLOR

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityInput.hlsl"

            struct appdata
            {
                float4 vertex   : POSITION;
                #ifdef _SMOOTHNORMALINCHANNEL_UV2
                    float4 uv2      : TEXCOORD1;
                #endif

                #ifdef _SMOOTHNORMALINCHANNEL_VERTEXCOLOR
                    float4 color    : COLOR;
                #endif

                #ifdef _SMOOTHNORMALINCHANNEL_TANGENT
                    float4 tangent    : TANGENT;
                #endif

                float4 normal   : NORMAL;

                UNITY_VERTEX_INPUT_INSTANCE_ID

            };

            struct v2f
            {
                float fogCoord  : TEXCOORD0;
                float4 vertex   : SV_POSITION;
            };

            CBUFFER_START(UnityPerMaterial)
            half3 _EmissionColor;
            //Specular Setup
            half _Smoothness;
            half _AOStrength;
            half _OcclusionStrength;
            half _LightBands;
            half _LightBandsScale;
            half _LightThreshold;
            half _DiffuseSmoothness;
            half _SpecularSmoothness;
            half _SpecularLightThreshold;

            //Rim
            half4 _RimColor;
            half _RimPower;

            half3 _GoochBrightColor;
            half3 _GoochDarkColor;
            half _OutlineWidth;
            half3 _OutlineColor;
            half _OffsetZ;
            CBUFFER_END

            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);

                #ifdef _SMOOTHNORMALINCHANNEL_UV2
                    float3 outDir;
                    v.uv2.x = v.uv2.x * 255.0 / 16.0;
                    outDir.x = floor(v.uv2.x) / 15.0;
                    outDir.y = frac(v.uv2.x) * 16.0 / 15.0;
                    outDir.z = v.uv2.y;
                    outDir = 2 * outDir - 1;
                #elif  _SMOOTHNORMALINCHANNEL_VERTEXCOLOR
                    float3 outDir = 2 * v.color.xyz - 1;
                #elif  _SMOOTHNORMALINCHANNEL_TANGENT
                    float3 outDir = v.tangent;
                #else
                    float3 outDir = v.normal.xyz;
                #endif
                float3 normalCS = mul(UNITY_MATRIX_VP, mul(UNITY_MATRIX_M, float4(outDir, 0.0))).xyz;

                float3 normalVS = mul((float3x3)UNITY_MATRIX_IT_MV, outDir.xyz);

                float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                float4 pos = TransformWorldToHClip(positionWS);
                o.fogCoord = ComputeFogFactor(pos.z);

                half3 viewdir = normalize(_WorldSpaceCameraPos.xyz - pos.xyz);
                float3 normalNDC = normalize(mul(UNITY_MATRIX_P, normalVS.xyz)) * pos.w;

                float aspect = abs(_ScreenParams.y / _ScreenParams.x);
                normalNDC.x *= aspect;
                pos.xy += 0.01 * _OutlineWidth * normalNDC.xy ;
                o.vertex = pos;
                float4 clipCameraPos = mul(UNITY_MATRIX_VP, float4(_WorldSpaceCameraPos.xyz, 1));

                #if defined(UNITY_REVERSED_Z)
                    //DX
                    _OffsetZ = _OffsetZ * -0.01;
                #else
                    //OpenGL
                    _OffsetZ = _OffsetZ * 0.01;
                #endif
                o.vertex.z += _OffsetZ * clipCameraPos.z;
                
                return o;
            }
            half4 frag(v2f i) : SV_Target
            {
                half4 col = float4(_OutlineColor.xyz, 1.0);
                col.rgb = MixFog(col.rgb,i.fogCoord);
                return col;
            }
            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError" 
}
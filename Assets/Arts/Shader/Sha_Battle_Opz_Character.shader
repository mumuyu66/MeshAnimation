Shader "Toon/TA/Opz_Sha_BattleCharacter_StencilOutline"
{
    Properties
    {

        [ToggleOff(_RECEIVE_SHADOWS_OFF)]
        _ReceiveShadows             ("Receive Shadows", Float) = 1.0

        [MainTexture] _BaseMap("Albedo", 2D) = "white" {}
        [MainColor]   _BaseColor("Color", Color) = (1, 1, 1, 1)


        [Toggle(_NORMALMAP)]
        _EnableNormalMap("Enable Normal Map",Float) = 0
        _BumpMap("Normal Map",2D) = "bump"{}
        _BumpScale("Normal Scale",Float) = 1
         
        [Header(SpecualrSetup)]
        [KeywordEnum(OFF,ISOTROPIC,ANISOTROPIC)]
        _SpecularMode("Specular Mode",Float) = 1
        _Anisotropy("Anisotropy Strength",Range(-1.0,1.0)) = 0
        _SpecularIntensity("Specular Intensity",Float) = 1.0

        [Toggle(_METALLICMAP)]
        _EnableMetallicMap("Enable Metallic Map",Float) = 0
        _MetallicMap("Metallic(r),Occ(g),Roughness(b)",2D) = "white"{}
        _Metallic("Metallic",Range(0,1.0)) = 0
        _OcclusionStrength("Occlusion Strength",Range(0,1.0)) = 1.0
        _AOStrength("AO Strength",Range(0,1.0)) = 1.0
        _Smoothness("Smoothness",Range(0,1.0)) = 0
        [Toggle(_ENABLEEMISSION)]
        _EnableEmission("EnableEmission",Float) = 0
        _Emissionmap("Emissionmap",2D) = "black"{}
        [HDR] _EmissionColor("Emission Color", Color) = (0,0,0)

        [Header(CellShading)]
        _LightBands("Light Bands",Range(2,6)) = 4
        _LightBandsScale("Light Bands Scale",Range(0.0,1.0)) = 0.5
        _LightThreshold("Light Threshold",Range(0.0,1.0)) = 0.5
        _DiffuseSmoothness ("Diffuse Smoothness", Range (0.0, 1.0)) = 0.0
        
        [Toggle(CELLSHADING_SPECULAR)]
        _EnableCellSpec("Enable Cell Specular",Float) = 0
        _SpecularSmoothness ("Specular Smoothness", Range (0.0, 1.0)) = 0.0
        _SpecularLightThreshold("Specular Light Threshold",Range(0.0,1.0)) = 0.5

        [Header(Gooch)]
        _GoochBrightColor ("Gooch Bright Color", Color) = (1, 1, 1, 1)
        _GoochDarkColor ("Gooch Dark Color", Color) = (0, 0, 0, 1)

        [Header(Rim Lighting)]
        [Space(5)]
        [Toggle(_RIMLIGHTING)]
        _Rim                        ("Enable Rim Lighting", Float) = 0
        [HDR] _RimColor             ("Rim Color", Color) = (0.5,0.5,0.5,1)
        _RimPower                   ("Rim Power", Float) = 2
        _Cutoff                     ("Cutoff",Range(0,1)) = 0.5

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
        [HideInInspector] _Surface("__surface", Float) = 0.0
        [HideInInspector] _Blend("__blend", Float) = 0.0
        [HideInInspector] _AlphaClip("__clip", Float) = 0.0
        [HideInInspector] _SrcBlend("Src", Float) = 1.0
        [HideInInspector] _DstBlend("Dst", Float) = 0.0
        [HideInInspector] _ZWrite("ZWrite", Float) = 1.0
        [HideInInspector] _Cull("__cull", Float) = 2.0
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
            Stencil {
                Ref[_Stencil]
                Comp  always
                Pass  replace
                Fail  replace
                ZFail keep
            }


            Name "Toon_Charater_Shader"

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            //To reduce shader variance .. 
            #define _SHADOWS_SOFT
            #define _ADDITIONAL_LIGHTS
            #define _MAIN_LIGHT_SHADOWS
            #define LIGHTMAP_SHADOW_MIXING
            #define _ENABLEEMISSION

            #pragma vertex vert
            #pragma fragment frag

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            //#pragma multi_compile _ _ADDITIONAL_LIGHTS
            //#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            //#pragma multi_compile_fragment _ _SHADOWS_SOFT
            //#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ _RIMLIGHTING


            //Material keywords
            #pragma shader_feature_local __ _SPECULARMODE_ISOTROPIC _SPECULARMODE_ANISOTROPIC
            #pragma shader_feature_local CELLSHADING_SPECULAR
            #pragma shader_feature_local _NORMALMAP
            //#pragma shader_feature_local _RIMLIGHTING
            #pragma shader_feature_local _METALLICMAP
            //#pragma shader_feature_local _ENABLEEMISSION
            #pragma shader_feature_local __ _SMOOTHNORMALINCHANNEL_TANGENT _SMOOTHNORMALINCHANNEL_UV2 _SMOOTHNORMALINCHANNEL_VERTEXCOLOR
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Includes/ToonCharaterInput.hlsl"

            struct Attributes
            {
                float4 positionOS       : POSITION;
                float3 normalOS         : NORMAL;
                float4 tangentOS        : TANGENT;
                float2 uv               : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv           : TEXCOORD0;
                DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);
                float fogCoord      : TEXCOORD2;
                float3 positionWS   : TEXCOORD3;
                float3 normalWS     : TEXCOORD4;
                float4 tangentWS    : TEXCOORD5;
                float3 bitangentWS    : TEXCOORD6;
                float3 viewDirWS      : TEXCOORD7;
                float4 shadowCoord  : TEXCOORD8;
                float4 vertex       : SV_POSITION;
                

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData){
                inputData = (InputData)0;
                half3 viewDirWS = SafeNormalize(input.viewDirWS);
                inputData.positionWS = input.positionWS;

            #if defined(_NORMALMAP) && !defined(_SMOOTHNORMALINCHANNEL_TANGENT)
                float3 bitangent = input.bitangentWS;
                inputData.normalWS  = TransformTangentToWorld(normalTS, half3x3(input.tangentWS.xyz, bitangent , input.normalWS.xyz));
            #else
                inputData.normalWS = input.normalWS;
                
            #endif
                inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
                inputData.viewDirectionWS = viewDirWS;

            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                inputData.shadowCoord = input.shadowCoord;
            #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
                inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
            #else
                inputData.shadowCoord = float4(0, 0, 0, 0);
            #endif

                
                inputData.bakedGI =SAMPLE_GI(input.lightmapUV, input.vertexSH, inputData.normalWS);
                inputData.fogCoord = input.fogCoord;


            }

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                half3 viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);

                real sign = input.tangentOS.w * GetOddNegativeScale();
                half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);

                output.tangentWS = tangentWS;
                output.bitangentWS = normalInput.bitangentWS ;
                output.vertex = vertexInput.positionCS;
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                output.fogCoord = ComputeFogFactor(vertexInput.positionCS.z);
                output.positionWS = vertexInput.positionWS;
                output.normalWS = normalInput.normalWS;
                output.viewDirWS = viewDirWS;
                output.shadowCoord = GetShadowCoord(vertexInput);
                OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
                OUTPUT_SH(output.normalWS.xyz, output.vertexSH);
       

                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 uv = input.uv;

                CustomSurfaceData surfaceData;
                InitializeCustomSurfaceData(uv,input.tangentWS.xyz,input.bitangentWS,surfaceData);
                

                InputData inputData;
                InitializeInputData(input,surfaceData.normalTS,inputData);
                

                #if defined(_RIMLIGHTING)
                    half rim = saturate(1.0h - saturate( dot(inputData.normalWS, inputData.viewDirectionWS) ) );
                    half power = _RimPower;
                    surfaceData.emission += pow(rim, power) * _RimColor.rgb * _RimColor.a;
                #endif

                
                
                half4 color = XD_UniversalFragmentToonPBR(inputData,surfaceData);
                //Is this good ? simplify ?
                color = clamp(color,0.0,15);
                color.rgb = MixFog(color.rgb, inputData.fogCoord);
            
                return color;
            }
            ENDHLSL
        }
        /*
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

        Pass
        {
            Name "CullColorPass"
            Tags{"LightMode" = "CullColorPass"} //UniversalForward

            Stencil {
                Ref 0
                Comp  Equal
                Pass  Keep
                Fail  Keep
            }


            Blend SrcAlpha OneMinusSrcAlpha
            Cull Back
            ZTest[_ZTest]
            
            
            

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"



            struct Attributes
            {
                float4 positionOS       : POSITION;
                float2 uv               : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv        : TEXCOORD0;
                float fogCoord : TEXCOORD1;
                float4 vertex : SV_POSITION;

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
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
             half3 _CullColor;
             half _CullTransparency;

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                output.vertex = vertexInput.positionCS;

                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                half2 uv = input.uv;
                half3 color =_CullColor;

                return half4(color, _CullTransparency);
            }
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            // -------------------------------------
            // Universal Pipeline keywords

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            //#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Includes/ToonCharaterInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "Includes/ToonCharaterInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL
        }
        */
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
            Stencil {
                Ref[_Stencil]
                Comp  always
                Pass  replace
                Fail  replace
                ZFail keep
            }


            Name "Toon_Charater_Shader"

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 3.0

            //To reduce shader variance .. 
            #define _SHADOWS_SOFT
            #define _ADDITIONAL_LIGHTS
            #define _MAIN_LIGHT_SHADOWS
            #define LIGHTMAP_SHADOW_MIXING
            #define _ENABLEEMISSION

            #pragma vertex vert
            #pragma fragment frag

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            //#pragma multi_compile _ _ADDITIONAL_LIGHTS
            //#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            //#pragma multi_compile_fragment _ _SHADOWS_SOFT
            //#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ _RIMLIGHTING


            //Material keywords
            #pragma shader_feature_local __ _SPECULARMODE_ISOTROPIC _SPECULARMODE_ANISOTROPIC
            #pragma shader_feature_local CELLSHADING_SPECULAR
            #pragma shader_feature_local _NORMALMAP
            //#pragma shader_feature_local _RIMLIGHTING
            #pragma shader_feature_local _METALLICMAP
            //#pragma shader_feature_local _ENABLEEMISSION
            #pragma shader_feature_local __ _SMOOTHNORMALINCHANNEL_TANGENT _SMOOTHNORMALINCHANNEL_UV2 _SMOOTHNORMALINCHANNEL_VERTEXCOLOR
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Includes/ToonCharaterInput.hlsl"

            struct Attributes
            {
                float4 positionOS       : POSITION;
                float3 normalOS         : NORMAL;
                float4 tangentOS        : TANGENT;
                float2 uv               : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv           : TEXCOORD0;
                DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);
                float fogCoord      : TEXCOORD2;
                float3 positionWS   : TEXCOORD3;
                float3 normalWS     : TEXCOORD4;
                float4 tangentWS    : TEXCOORD5;
                float3 bitangentWS    : TEXCOORD6;
                float3 viewDirWS      : TEXCOORD7;
                float4 shadowCoord  : TEXCOORD8;
                float4 vertex       : SV_POSITION;
                

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData){
                inputData = (InputData)0;
                half3 viewDirWS = SafeNormalize(input.viewDirWS);
                inputData.positionWS = input.positionWS;

            #if defined(_NORMALMAP) && !defined(_SMOOTHNORMALINCHANNEL_TANGENT)
                float3 bitangent = input.bitangentWS;
                inputData.normalWS  = TransformTangentToWorld(normalTS, half3x3(input.tangentWS.xyz, bitangent , input.normalWS.xyz));
            #else
                inputData.normalWS = input.normalWS;
                
            #endif
                inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
                inputData.viewDirectionWS = viewDirWS;

            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                inputData.shadowCoord = input.shadowCoord;
            #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
                inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
            #else
                inputData.shadowCoord = float4(0, 0, 0, 0);
            #endif

                
                inputData.bakedGI =SAMPLE_GI(input.lightmapUV, input.vertexSH, inputData.normalWS);
                inputData.fogCoord = input.fogCoord;


            }

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                half3 viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);

                real sign = input.tangentOS.w * GetOddNegativeScale();
                half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);

                output.tangentWS = tangentWS;
                output.bitangentWS = normalInput.bitangentWS ;
                output.vertex = vertexInput.positionCS;
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                output.fogCoord = ComputeFogFactor(vertexInput.positionCS.z);
                output.positionWS = vertexInput.positionWS;
                output.normalWS = normalInput.normalWS;
                output.viewDirWS = viewDirWS;
                output.shadowCoord = GetShadowCoord(vertexInput);
                OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
                OUTPUT_SH(output.normalWS.xyz, output.vertexSH);
       

                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 uv = input.uv;

                CustomSurfaceData surfaceData;
                InitializeCustomSurfaceData(uv,input.tangentWS.xyz,input.bitangentWS,surfaceData);
                

                InputData inputData;
                InitializeInputData(input,surfaceData.normalTS,inputData);
                

                #if defined(_RIMLIGHTING)
                    half rim = saturate(1.0h - saturate( dot(inputData.normalWS, inputData.viewDirectionWS) ) );
                    half power = _RimPower;
                    surfaceData.emission += pow(rim, power) * _RimColor.rgb * _RimColor.a;
                #endif

                
                
                half4 color = XD_UniversalFragmentToonPBR(inputData,surfaceData);
                //Is this good ? simplify ?
                color = clamp(color,0.0,15);
                color.rgb = MixFog(color.rgb, inputData.fogCoord);
            
                return color;
            }
            ENDHLSL
        }/*
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

        Pass
        {
            Name "CullColorPass"
            Tags{"LightMode" = "CullColorPass"} //UniversalForward

            Stencil {
                Ref 0
                Comp  Equal
                Pass  Keep
                Fail  Keep
            }


            Blend SrcAlpha OneMinusSrcAlpha
            Cull Back
            ZTest[_ZTest]
            
            
            

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"



            struct Attributes
            {
                float4 positionOS       : POSITION;
                float2 uv               : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv        : TEXCOORD0;
                float fogCoord : TEXCOORD1;
                float4 vertex : SV_POSITION;

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
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
             half3 _CullColor;
             half _CullTransparency;

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                output.vertex = vertexInput.positionCS;

                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                half2 uv = input.uv;
                half3 color =_CullColor;

                return half4(color, _CullTransparency);
            }
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            // -------------------------------------
            // Universal Pipeline keywords

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            //#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Includes/ToonCharaterInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "Includes/ToonCharaterInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL*/
        //}

    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError" 
    CustomEditor "OpzCharacterGUI"

}

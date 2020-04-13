// Crest Ocean System

// Copyright 2020 Wave Harmonic Ltd

Shader "Crest/Framework"
{
    Properties
    {
        _Smoothness("Smoothness", Range(0, 1)) = 0.8
        _SmoothnessFar("Smoothness Far", Range(0, 1)) = 0.35
        _SmoothnessFarDistance("Smoothness Far Distance", Range(1, 8000)) = 2000
        _SmoothnessFalloff("Smoothness Falloff", Range(0, 5)) = 0.5
        _Specular("Specular", Range(0, 1)) = 0.036
        _Occlusion("Occlusion", Range(0, 1)) = 0.332
        _ScatterColourBase("Scatter Colour Base", Color) = (0.384167, 0.6049405, 0.8396226, 0)
        _ScatterColourShallow("Scatter Colour Shallow", Color) = (0.3758455, 0.7105559, 0.7735849, 0)
        _ScatterColourShallowDepthMax("Scatter Colour Shallow Depth Max", Range(0, 50)) = 7
        _ScatterColourShallowDepthFalloff("Scatter Colour Shallow Depth Falloff", Range(0, 10)) = 2.57
        [NoScaleOffset]_TextureNormals("Normals", 2D) = "bump" {}
        _NormalsScale("Normals Scale", Range(0.01, 200)) = 40
        _NormalsStrength("Normals Strength", Range(0, 1)) = 0.5
        _SSSIntensityBase("SSS Intensity Base", Range(0, 4)) = 1.04
        _SSSIntensitySun("SSS Intensity Sun", Range(0, 10)) = 4.46
        _SSSTint("SSS Tint", Color) = (0.089, 0.497, 0.456, 0)
        _SSSSunFalloff("SSS Sun Falloff", Range(0, 16)) = 5
        _RefractionStrength("Refraction Strength", Range(0, 2)) = 0.2
        _DepthFogDensity("Depth Fog Density", Vector) = (0.33, 0.23, 0.37, 0)
        [NoScaleOffset]_TextureFoam("Foam", 2D) = "white" {}
        _FoamScale("Foam Scale", Range(0.01, 50)) = 10
        _FoamFeather("Foam Feather", Range(0.001, 1)) = 0.32
        _FoamIntensityAlbedo("Foam Albedo Intensity", Range(0, 3)) = 1
        _FoamIntensityEmissive("Foam Emissive Intensity", Range(0, 2)) = 0.5
        _FoamSmoothness("Foam Smoothness", Range(0, 1)) = 0.7
        _FoamNormalStrength("Foam Normal Strength", Range(0, 2)) = 1
        _FoamBubbleColor("Foam Bubbles Colour", Color) = (0.6392157, 0.8313726, 0.8196079, 0)
        _FoamBubbleParallax("Foam Bubbles Parallax", Range(0, 0.5)) = 0.14
        _FoamBubblesCoverage("Foam Bubbles Coverage", Range(0, 5)) = 1.68
        [NoScaleOffset]_CausticsTexture("Caustics Texture", 2D) = "black" {}
        _CausticsTextureScale("Caustics Texture Scale", Range(0, 25)) = 5
        _CausticsTextureAverage("Caustics Texture Grey Point", Range(0, 1)) = 0.07
        _CausticsStrength("Caustics Strength", Range(0, 10)) = 3.2
        _CausticsFocalDepth("Caustics Focal Depth", Range(0, 25)) = 2
        _CausticsDepthOfField("Caustics Depth of Field", Range(0.01, 10)) = 6
        [NoScaleOffset]_CausticsDistortionTexture("Caustics Distortion Texture", 2D) = "grey" {}
        _CausticsDistortionStrength("Caustics Distortion Strength", Range(0, 0.25)) = 0.16
        _CausticsDistortionScale("Caustics Distortion Scale", Range(0.01, 50)) = 25
        [Toggle]CREST_FOAM("FOAM", Float) = 1
        [Toggle]CREST_CAUSTICS("CAUSTICS", Float) = 1
        [Toggle]CREST_FLOW("FLOW", Float) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "Queue"="Transparent-1"
        }
        
        Pass
        {
            Name "Universal Forward"
            Tags 
            { 
                "LightMode" = "UniversalForward"
            }
           
            // Render State
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            Cull Off
            ZTest LEqual
            ZWrite On
            // ColorMask: <None>
        
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
        
            // Debug
            // <None>
        
            // --------------------------------------------------
            // Pass
        
            // Pragmas
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
        
            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
			// HB - knock these out as transparent surfaces currently pull shadows from underlying surfaces
            //#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            //#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
            //#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            //#pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
            #pragma shader_feature_local _ CREST_FOAM_ON
            #pragma shader_feature_local _ CREST_CAUSTICS_ON
            #pragma shader_feature_local _ CREST_FLOW_ON
            
            #if defined(CREST_FOAM_ON) && defined(CREST_CAUSTICS_ON) && defined(CREST_FLOW_ON)
                #define KEYWORD_PERMUTATION_0
            #elif defined(CREST_FOAM_ON) && defined(CREST_CAUSTICS_ON)
                #define KEYWORD_PERMUTATION_1
            #elif defined(CREST_FOAM_ON) && defined(CREST_FLOW_ON)
                #define KEYWORD_PERMUTATION_2
            #elif defined(CREST_FOAM_ON)
                #define KEYWORD_PERMUTATION_3
            #elif defined(CREST_CAUSTICS_ON) && defined(CREST_FLOW_ON)
                #define KEYWORD_PERMUTATION_4
            #elif defined(CREST_CAUSTICS_ON)
                #define KEYWORD_PERMUTATION_5
            #elif defined(CREST_FLOW_ON)
                #define KEYWORD_PERMUTATION_6
            #else
                #define KEYWORD_PERMUTATION_7
            #endif
            
		#define CREST_GENERATED_SHADER_ON 1
            
            // Defines
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define _SURFACE_TYPE_TRANSPARENT 1
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define _NORMALMAP 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define _SPECULAR_SETUP
        #endif
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD2
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD3
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_POSITION_WS 
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_NORMAL_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TANGENT_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD2
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD3
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_BITANGENT_WS
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_CULLFACE
        #endif
        
            #define FEATURES_GRAPH_VERTEX
            #define SHADERPASS_FORWARD
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #define REQUIRE_DEPTH_TEXTURE
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #define REQUIRE_OPAQUE_TEXTURE
            #endif
        
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
            // --------------------------------------------------
            // Graph
        
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            half _Smoothness;
            float _SmoothnessFar;
            float _SmoothnessFarDistance;
            float _SmoothnessFalloff;
            float _Specular;
            float _Occlusion;
            half4 _ScatterColourBase;
            float4 _ScatterColourShallow;
            half _ScatterColourShallowDepthMax;
            half _ScatterColourShallowDepthFalloff;
            half _NormalsScale;
            half _NormalsStrength;
            half _SSSIntensityBase;
            half _SSSIntensitySun;
            half4 _SSSTint;
            half _SSSSunFalloff;
            half _RefractionStrength;
            half3 _DepthFogDensity;
            half _FoamScale;
            half _FoamFeather;
            half _FoamIntensityAlbedo;
            half _FoamIntensityEmissive;
            half _FoamSmoothness;
            half _FoamNormalStrength;
            half4 _FoamBubbleColor;
            half _FoamBubbleParallax;
            half _FoamBubblesCoverage;
            float _CausticsTextureScale;
            float _CausticsTextureAverage;
            float _CausticsStrength;
            float _CausticsFocalDepth;
            float _CausticsDepthOfField;
            float _CausticsDistortionStrength;
            float _CausticsDistortionScale;
            CBUFFER_END
            TEXTURE2D(_TextureNormals); SAMPLER(sampler_TextureNormals); float4 _TextureNormals_TexelSize;
            TEXTURE2D(_TextureFoam); SAMPLER(sampler_TextureFoam); half4 _TextureFoam_TexelSize;
            TEXTURE2D(_CausticsTexture); SAMPLER(sampler_CausticsTexture); float4 _CausticsTexture_TexelSize;
            TEXTURE2D(_CausticsDistortionTexture); SAMPLER(sampler_CausticsDistortionTexture); float4 _CausticsDistortionTexture_TexelSize;
            SAMPLER(SamplerState_Linear_Repeat);
        
            // Graph Functions
            
            // dc55dc563cc13ab0a4a38f335aac9cb2
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeDrivenInputs.hlsl"
            
            struct Bindings_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d
            {
            };
            
            void SG_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d(Bindings_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d IN, out half MeshScaleAlpha_1, out half LodDataTexelSize_8, out half GeometryGridSize_2, out half3 OceanPosScale0_3, out half3 OceanPosScale1_4, out half4 OceanParams0_5, out half4 OceanParams1_6, out half SliceIndex0_7)
            {
                half _CustomFunction_CD9A5F8F_MeshScaleAlpha_9;
                half _CustomFunction_CD9A5F8F_LodDataTexelSize_10;
                half _CustomFunction_CD9A5F8F_GeometryGridSize_14;
                half3 _CustomFunction_CD9A5F8F_OceanPosScale0_7;
                half3 _CustomFunction_CD9A5F8F_OceanPosScale1_8;
                half4 _CustomFunction_CD9A5F8F_OceanParams0_11;
                half4 _CustomFunction_CD9A5F8F_OceanParams1_12;
                half _CustomFunction_CD9A5F8F_SliceIndex0_13;
                CrestOceanSurfaceValues_half(_CustomFunction_CD9A5F8F_MeshScaleAlpha_9, _CustomFunction_CD9A5F8F_LodDataTexelSize_10, _CustomFunction_CD9A5F8F_GeometryGridSize_14, _CustomFunction_CD9A5F8F_OceanPosScale0_7, _CustomFunction_CD9A5F8F_OceanPosScale1_8, _CustomFunction_CD9A5F8F_OceanParams0_11, _CustomFunction_CD9A5F8F_OceanParams1_12, _CustomFunction_CD9A5F8F_SliceIndex0_13);
                MeshScaleAlpha_1 = _CustomFunction_CD9A5F8F_MeshScaleAlpha_9;
                LodDataTexelSize_8 = _CustomFunction_CD9A5F8F_LodDataTexelSize_10;
                GeometryGridSize_2 = _CustomFunction_CD9A5F8F_GeometryGridSize_14;
                OceanPosScale0_3 = _CustomFunction_CD9A5F8F_OceanPosScale0_7;
                OceanPosScale1_4 = _CustomFunction_CD9A5F8F_OceanPosScale1_8;
                OceanParams0_5 = _CustomFunction_CD9A5F8F_OceanParams0_11;
                OceanParams1_6 = _CustomFunction_CD9A5F8F_OceanParams1_12;
                SliceIndex0_7 = _CustomFunction_CD9A5F8F_SliceIndex0_13;
            }
            
            // 0749fb83929f8caedf1bd96120cd0442
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeGeoMorph.hlsl"
            
            struct Bindings_CrestGeoMorph_9ab91ec3462438049923ca0ff16f68ad
            {
            };
            
            void SG_CrestGeoMorph_9ab91ec3462438049923ca0ff16f68ad(float3 Vector3_28A0F264, float3 Vector3_F1111B56, float Vector1_691AFD6A, float Vector1_37DEE8F3, Bindings_CrestGeoMorph_9ab91ec3462438049923ca0ff16f68ad IN, out half3 MorphedPositionWS_1, out half LodAlpha_2)
            {
                float3 _Property_C4B6B1D5_Out_0 = Vector3_28A0F264;
                float3 _Property_13BC6D1A_Out_0 = Vector3_F1111B56;
                float _Property_DE4BC103_Out_0 = Vector1_691AFD6A;
                float _Property_B3D2A4DF_Out_0 = Vector1_37DEE8F3;
                half3 _CustomFunction_C8F1D6C4_MorphedPositionWS_4;
                half _CustomFunction_C8F1D6C4_LodAlpha_5;
                GeoMorph_half(_Property_C4B6B1D5_Out_0, _Property_13BC6D1A_Out_0, _Property_DE4BC103_Out_0, _Property_B3D2A4DF_Out_0, _CustomFunction_C8F1D6C4_MorphedPositionWS_4, _CustomFunction_C8F1D6C4_LodAlpha_5);
                MorphedPositionWS_1 = _CustomFunction_C8F1D6C4_MorphedPositionWS_4;
                LodAlpha_2 = _CustomFunction_C8F1D6C4_LodAlpha_5;
            }
            
            // 280776a3899d7788e7b68f32405fa944
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeSampleOceanData.hlsl"
            
            struct Bindings_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4
            {
            };
            
            void SG_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4(float2 Vector2_3171933F, float Vector1_CD41515B, float3 Vector3_7E91D336, float3 Vector3_3A95DCDF, float4 Vector4_C0B2B5EA, float4 Vector4_9C46108E, float Vector1_8EA8B92B, Bindings_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4 IN, out float3 Displacement_1, out float OceanWaterDepth_5, out float Foam_6, out float2 Shadow_7, out float2 Flow_8, out float SubSurfaceScattering_9)
            {
                float2 _Property_1A287CC6_Out_0 = Vector2_3171933F;
                float _Property_2D1D1700_Out_0 = Vector1_CD41515B;
                float3 _Property_C925A867_Out_0 = Vector3_7E91D336;
                float3 _Property_6C273401_Out_0 = Vector3_3A95DCDF;
                float4 _Property_467D1BE7_Out_0 = Vector4_C0B2B5EA;
                float4 _Property_4E045F45_Out_0 = Vector4_9C46108E;
                float _Property_59E019ED_Out_0 = Vector1_8EA8B92B;
                float3 _CustomFunction_487C31E1_Displacement_3;
                float _CustomFunction_487C31E1_OceanDepth_8;
                float _CustomFunction_487C31E1_Foam_4;
                float2 _CustomFunction_487C31E1_Shadow_5;
                float2 _CustomFunction_487C31E1_Flow_6;
                float _CustomFunction_487C31E1_SSS_17;
                CrestNodeSampleOceanData_float(_Property_1A287CC6_Out_0, _Property_2D1D1700_Out_0, _Property_C925A867_Out_0, _Property_6C273401_Out_0, _Property_467D1BE7_Out_0, _Property_4E045F45_Out_0, _Property_59E019ED_Out_0, _CustomFunction_487C31E1_Displacement_3, _CustomFunction_487C31E1_OceanDepth_8, _CustomFunction_487C31E1_Foam_4, _CustomFunction_487C31E1_Shadow_5, _CustomFunction_487C31E1_Flow_6, _CustomFunction_487C31E1_SSS_17);
                Displacement_1 = _CustomFunction_487C31E1_Displacement_3;
                OceanWaterDepth_5 = _CustomFunction_487C31E1_OceanDepth_8;
                Foam_6 = _CustomFunction_487C31E1_Foam_4;
                Shadow_7 = _CustomFunction_487C31E1_Shadow_5;
                Flow_8 = _CustomFunction_487C31E1_Flow_6;
                SubSurfaceScattering_9 = _CustomFunction_487C31E1_SSS_17;
            }
            
            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
            {
                Out = A + B;
            }
            
            // 25927ab6b885bcd0b86a13376933b174
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeComputeSamplingData.hlsl"
            
            void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
            {
                Out = A - B;
            }
            
            struct Bindings_CrestComputeOceanDataFromDisplacedPosition_1f483fe321b10c64e8b93a023ae60dd6
            {
            };
            
            void SG_CrestComputeOceanDataFromDisplacedPosition_1f483fe321b10c64e8b93a023ae60dd6(float3 Vector3_A7B8495A, Bindings_CrestComputeOceanDataFromDisplacedPosition_1f483fe321b10c64e8b93a023ae60dd6 IN, out float2 UndisplacedPosXZAWS_7, out float LodAlpha_6, out float3 Displacement_8, out float OceanWaterDepth_1, out float Foam_2, out float2 Shadow_3, out float2 Flow_4, out float SubSurfaceScattering_5)
            {
                float3 _Property_232E7FDA_Out_0 = Vector3_A7B8495A;
                float _Split_8E8A6DCA_R_1 = _Property_232E7FDA_Out_0[0];
                float _Split_8E8A6DCA_G_2 = _Property_232E7FDA_Out_0[1];
                float _Split_8E8A6DCA_B_3 = _Property_232E7FDA_Out_0[2];
                float _Split_8E8A6DCA_A_4 = 0;
                float2 _Vector2_A3499051_Out_0 = float2(_Split_8E8A6DCA_R_1, _Split_8E8A6DCA_B_3);
                half _CustomFunction_A082C8F2_LodAlpha_3;
                half3 _CustomFunction_A082C8F2_OceanPosScale0_4;
                half3 _CustomFunction_A082C8F2_OceanPosScale1_5;
                half4 _CustomFunction_A082C8F2_OceanParams0_6;
                half4 _CustomFunction_A082C8F2_OceanParams1_7;
                half _CustomFunction_A082C8F2_Slice0_1;
                half _CustomFunction_A082C8F2_Slice1_2;
                CrestComputeSamplingData_half(_Vector2_A3499051_Out_0, _CustomFunction_A082C8F2_LodAlpha_3, _CustomFunction_A082C8F2_OceanPosScale0_4, _CustomFunction_A082C8F2_OceanPosScale1_5, _CustomFunction_A082C8F2_OceanParams0_6, _CustomFunction_A082C8F2_OceanParams1_7, _CustomFunction_A082C8F2_Slice0_1, _CustomFunction_A082C8F2_Slice1_2);
                Bindings_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4 _CrestSampleOceanData_87ACC65F;
                float3 _CrestSampleOceanData_87ACC65F_Displacement_1;
                float _CrestSampleOceanData_87ACC65F_OceanWaterDepth_5;
                float _CrestSampleOceanData_87ACC65F_Foam_6;
                float2 _CrestSampleOceanData_87ACC65F_Shadow_7;
                float2 _CrestSampleOceanData_87ACC65F_Flow_8;
                float _CrestSampleOceanData_87ACC65F_SubSurfaceScattering_9;
                SG_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4(_Vector2_A3499051_Out_0, _CustomFunction_A082C8F2_LodAlpha_3, _CustomFunction_A082C8F2_OceanPosScale0_4, _CustomFunction_A082C8F2_OceanPosScale1_5, _CustomFunction_A082C8F2_OceanParams0_6, _CustomFunction_A082C8F2_OceanParams1_7, _CustomFunction_A082C8F2_Slice0_1, _CrestSampleOceanData_87ACC65F, _CrestSampleOceanData_87ACC65F_Displacement_1, _CrestSampleOceanData_87ACC65F_OceanWaterDepth_5, _CrestSampleOceanData_87ACC65F_Foam_6, _CrestSampleOceanData_87ACC65F_Shadow_7, _CrestSampleOceanData_87ACC65F_Flow_8, _CrestSampleOceanData_87ACC65F_SubSurfaceScattering_9);
                float _Split_CD3A9051_R_1 = _CrestSampleOceanData_87ACC65F_Displacement_1[0];
                float _Split_CD3A9051_G_2 = _CrestSampleOceanData_87ACC65F_Displacement_1[1];
                float _Split_CD3A9051_B_3 = _CrestSampleOceanData_87ACC65F_Displacement_1[2];
                float _Split_CD3A9051_A_4 = 0;
                float2 _Vector2_B8C0C1F0_Out_0 = float2(_Split_CD3A9051_R_1, _Split_CD3A9051_B_3);
                float2 _Subtract_8977A663_Out_2;
                Unity_Subtract_float2(_Vector2_A3499051_Out_0, _Vector2_B8C0C1F0_Out_0, _Subtract_8977A663_Out_2);
                half _CustomFunction_9D8B14F0_LodAlpha_3;
                half3 _CustomFunction_9D8B14F0_OceanPosScale0_4;
                half3 _CustomFunction_9D8B14F0_OceanPosScale1_5;
                half4 _CustomFunction_9D8B14F0_OceanParams0_6;
                half4 _CustomFunction_9D8B14F0_OceanParams1_7;
                half _CustomFunction_9D8B14F0_Slice0_1;
                half _CustomFunction_9D8B14F0_Slice1_2;
                CrestComputeSamplingData_half(_Subtract_8977A663_Out_2, _CustomFunction_9D8B14F0_LodAlpha_3, _CustomFunction_9D8B14F0_OceanPosScale0_4, _CustomFunction_9D8B14F0_OceanPosScale1_5, _CustomFunction_9D8B14F0_OceanParams0_6, _CustomFunction_9D8B14F0_OceanParams1_7, _CustomFunction_9D8B14F0_Slice0_1, _CustomFunction_9D8B14F0_Slice1_2);
                Bindings_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4 _CrestSampleOceanData_D8619779;
                float3 _CrestSampleOceanData_D8619779_Displacement_1;
                float _CrestSampleOceanData_D8619779_OceanWaterDepth_5;
                float _CrestSampleOceanData_D8619779_Foam_6;
                float2 _CrestSampleOceanData_D8619779_Shadow_7;
                float2 _CrestSampleOceanData_D8619779_Flow_8;
                float _CrestSampleOceanData_D8619779_SubSurfaceScattering_9;
                SG_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4(_Subtract_8977A663_Out_2, _CustomFunction_9D8B14F0_LodAlpha_3, _CustomFunction_9D8B14F0_OceanPosScale0_4, _CustomFunction_9D8B14F0_OceanPosScale1_5, _CustomFunction_9D8B14F0_OceanParams0_6, _CustomFunction_9D8B14F0_OceanParams1_7, _CustomFunction_9D8B14F0_Slice0_1, _CrestSampleOceanData_D8619779, _CrestSampleOceanData_D8619779_Displacement_1, _CrestSampleOceanData_D8619779_OceanWaterDepth_5, _CrestSampleOceanData_D8619779_Foam_6, _CrestSampleOceanData_D8619779_Shadow_7, _CrestSampleOceanData_D8619779_Flow_8, _CrestSampleOceanData_D8619779_SubSurfaceScattering_9);
                float _Split_1616DE7_R_1 = _CrestSampleOceanData_D8619779_Displacement_1[0];
                float _Split_1616DE7_G_2 = _CrestSampleOceanData_D8619779_Displacement_1[1];
                float _Split_1616DE7_B_3 = _CrestSampleOceanData_D8619779_Displacement_1[2];
                float _Split_1616DE7_A_4 = 0;
                float2 _Vector2_B871614F_Out_0 = float2(_Split_1616DE7_R_1, _Split_1616DE7_B_3);
                float2 _Subtract_39E2CE30_Out_2;
                Unity_Subtract_float2(_Vector2_A3499051_Out_0, _Vector2_B871614F_Out_0, _Subtract_39E2CE30_Out_2);
                half _CustomFunction_10AEAD9A_LodAlpha_3;
                half3 _CustomFunction_10AEAD9A_OceanPosScale0_4;
                half3 _CustomFunction_10AEAD9A_OceanPosScale1_5;
                half4 _CustomFunction_10AEAD9A_OceanParams0_6;
                half4 _CustomFunction_10AEAD9A_OceanParams1_7;
                half _CustomFunction_10AEAD9A_Slice0_1;
                half _CustomFunction_10AEAD9A_Slice1_2;
                CrestComputeSamplingData_half(_Subtract_39E2CE30_Out_2, _CustomFunction_10AEAD9A_LodAlpha_3, _CustomFunction_10AEAD9A_OceanPosScale0_4, _CustomFunction_10AEAD9A_OceanPosScale1_5, _CustomFunction_10AEAD9A_OceanParams0_6, _CustomFunction_10AEAD9A_OceanParams1_7, _CustomFunction_10AEAD9A_Slice0_1, _CustomFunction_10AEAD9A_Slice1_2);
                Bindings_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4 _CrestSampleOceanData_A1195FE2;
                float3 _CrestSampleOceanData_A1195FE2_Displacement_1;
                float _CrestSampleOceanData_A1195FE2_OceanWaterDepth_5;
                float _CrestSampleOceanData_A1195FE2_Foam_6;
                float2 _CrestSampleOceanData_A1195FE2_Shadow_7;
                float2 _CrestSampleOceanData_A1195FE2_Flow_8;
                float _CrestSampleOceanData_A1195FE2_SubSurfaceScattering_9;
                SG_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4(_Subtract_39E2CE30_Out_2, _CustomFunction_10AEAD9A_LodAlpha_3, _CustomFunction_10AEAD9A_OceanPosScale0_4, _CustomFunction_10AEAD9A_OceanPosScale1_5, _CustomFunction_10AEAD9A_OceanParams0_6, _CustomFunction_10AEAD9A_OceanParams1_7, _CustomFunction_10AEAD9A_Slice0_1, _CrestSampleOceanData_A1195FE2, _CrestSampleOceanData_A1195FE2_Displacement_1, _CrestSampleOceanData_A1195FE2_OceanWaterDepth_5, _CrestSampleOceanData_A1195FE2_Foam_6, _CrestSampleOceanData_A1195FE2_Shadow_7, _CrestSampleOceanData_A1195FE2_Flow_8, _CrestSampleOceanData_A1195FE2_SubSurfaceScattering_9);
                UndisplacedPosXZAWS_7 = _Subtract_39E2CE30_Out_2;
                LodAlpha_6 = _CustomFunction_10AEAD9A_LodAlpha_3;
                Displacement_8 = _CrestSampleOceanData_A1195FE2_Displacement_1;
                OceanWaterDepth_1 = _CrestSampleOceanData_A1195FE2_OceanWaterDepth_5;
                Foam_2 = _CrestSampleOceanData_A1195FE2_Foam_6;
                Shadow_3 = _CrestSampleOceanData_A1195FE2_Shadow_7;
                Flow_4 = _CrestSampleOceanData_A1195FE2_Flow_8;
                SubSurfaceScattering_5 = _CrestSampleOceanData_A1195FE2_SubSurfaceScattering_9;
            }
            
            struct Bindings_CrestUnpackData_5bc4cf08f88035c489658d60edefeec8
            {
                float3 AbsoluteWorldSpacePosition;
                half4 uv0;
                half4 uv1;
                half4 uv2;
            };
            
            void SG_CrestUnpackData_5bc4cf08f88035c489658d60edefeec8(Bindings_CrestUnpackData_5bc4cf08f88035c489658d60edefeec8 IN, out float2 PositionXZWSUndisp_2, out float LodAlpha_1, out float OceanDepth_3, out float Foam_4, out float2 Shadow_5, out float2 Flow_6, out float SubSurfaceScattering_7)
            {
                float4 _UV_CF6CD5F2_Out_0 = IN.uv0;
                float _Split_B10345C8_R_1 = _UV_CF6CD5F2_Out_0[0];
                float _Split_B10345C8_G_2 = _UV_CF6CD5F2_Out_0[1];
                float _Split_B10345C8_B_3 = _UV_CF6CD5F2_Out_0[2];
                float _Split_B10345C8_A_4 = _UV_CF6CD5F2_Out_0[3];
                float2 _Vector2_552A5E1F_Out_0 = float2(_Split_B10345C8_R_1, _Split_B10345C8_G_2);
                Bindings_CrestComputeOceanDataFromDisplacedPosition_1f483fe321b10c64e8b93a023ae60dd6 _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB;
                float2 _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_UndisplacedPosXZAWS_7;
                float _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_LodAlpha_6;
                float3 _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Displacement_8;
                float _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_OceanWaterDepth_1;
                float _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Foam_2;
                float2 _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Shadow_3;
                float2 _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Flow_4;
                float _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_SubSurfaceScattering_5;
                SG_CrestComputeOceanDataFromDisplacedPosition_1f483fe321b10c64e8b93a023ae60dd6(IN.AbsoluteWorldSpacePosition, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_UndisplacedPosXZAWS_7, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_LodAlpha_6, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Displacement_8, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_OceanWaterDepth_1, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Foam_2, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Shadow_3, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Flow_4, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_SubSurfaceScattering_5);
                #if defined(CREST_GENERATED_SHADER_ON)
                float2 _GENERATEDSHADER_71C0694B_Out_0 = _Vector2_552A5E1F_Out_0;
                #else
                float2 _GENERATEDSHADER_71C0694B_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_UndisplacedPosXZAWS_7;
                #endif
                #if defined(CREST_GENERATED_SHADER_ON)
                float _GENERATEDSHADER_2A933A74_Out_0 = _Split_B10345C8_B_3;
                #else
                float _GENERATEDSHADER_2A933A74_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_LodAlpha_6;
                #endif
                #if defined(CREST_GENERATED_SHADER_ON)
                float _GENERATEDSHADER_EFBF6036_Out_0 = _Split_B10345C8_A_4;
                #else
                float _GENERATEDSHADER_EFBF6036_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_OceanWaterDepth_1;
                #endif
                float4 _UV_39E1D2DF_Out_0 = IN.uv1;
                float _Split_CB2CA9B8_R_1 = _UV_39E1D2DF_Out_0[0];
                float _Split_CB2CA9B8_G_2 = _UV_39E1D2DF_Out_0[1];
                float _Split_CB2CA9B8_B_3 = _UV_39E1D2DF_Out_0[2];
                float _Split_CB2CA9B8_A_4 = _UV_39E1D2DF_Out_0[3];
                #if defined(CREST_GENERATED_SHADER_ON)
                float _GENERATEDSHADER_1BBAE801_Out_0 = _Split_CB2CA9B8_G_2;
                #else
                float _GENERATEDSHADER_1BBAE801_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Foam_2;
                #endif
                float4 _UV_33A67BF5_Out_0 = IN.uv2;
                float _Split_753DFB28_R_1 = _UV_33A67BF5_Out_0[0];
                float _Split_753DFB28_G_2 = _UV_33A67BF5_Out_0[1];
                float _Split_753DFB28_B_3 = _UV_33A67BF5_Out_0[2];
                float _Split_753DFB28_A_4 = _UV_33A67BF5_Out_0[3];
                float2 _Vector2_7883B8A6_Out_0 = float2(_Split_753DFB28_R_1, _Split_753DFB28_G_2);
                #if defined(CREST_GENERATED_SHADER_ON)
                float2 _GENERATEDSHADER_B499BDE6_Out_0 = _Vector2_7883B8A6_Out_0;
                #else
                float2 _GENERATEDSHADER_B499BDE6_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Shadow_3;
                #endif
                float2 _Vector2_3A83E1FC_Out_0 = float2(_Split_753DFB28_B_3, _Split_753DFB28_A_4);
                #if defined(CREST_GENERATED_SHADER_ON)
                float2 _GENERATEDSHADER_84CB20AD_Out_0 = _Vector2_3A83E1FC_Out_0;
                #else
                float2 _GENERATEDSHADER_84CB20AD_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Flow_4;
                #endif
                #if defined(CREST_GENERATED_SHADER_ON)
                float _GENERATEDSHADER_6BDC98D1_Out_0 = _Split_CB2CA9B8_R_1;
                #else
                float _GENERATEDSHADER_6BDC98D1_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_SubSurfaceScattering_5;
                #endif
                PositionXZWSUndisp_2 = _GENERATEDSHADER_71C0694B_Out_0;
                LodAlpha_1 = _GENERATEDSHADER_2A933A74_Out_0;
                OceanDepth_3 = _GENERATEDSHADER_EFBF6036_Out_0;
                Foam_4 = _GENERATEDSHADER_1BBAE801_Out_0;
                Shadow_5 = _GENERATEDSHADER_B499BDE6_Out_0;
                Flow_6 = _GENERATEDSHADER_84CB20AD_Out_0;
                SubSurfaceScattering_7 = _GENERATEDSHADER_6BDC98D1_Out_0;
            }
            
            // 673f3e02c7d6371b4ae419cc02e9dca4
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeLightData.hlsl"
            
            struct Bindings_CrestLightData_b74b6e8c0b489314ca7aea3e2cc9c54c
            {
            };
            
            void SG_CrestLightData_b74b6e8c0b489314ca7aea3e2cc9c54c(Bindings_CrestLightData_b74b6e8c0b489314ca7aea3e2cc9c54c IN, out half3 Direction_1, out half3 Intensity_2)
            {
                half3 _CustomFunction_5D41A6E0_Direction_0;
                half3 _CustomFunction_5D41A6E0_Colour_1;
                CrestNodeLightData_half(_CustomFunction_5D41A6E0_Direction_0, _CustomFunction_5D41A6E0_Colour_1);
                Direction_1 = _CustomFunction_5D41A6E0_Direction_0;
                Intensity_2 = _CustomFunction_5D41A6E0_Colour_1;
            }
            
            void Unity_Normalize_float3(float3 In, out float3 Out)
            {
                Out = normalize(In);
            }
            
            void Unity_Not_float(float In, out float Out)
            {
                Out = !In;
            }
            
            struct Bindings_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2
            {
                float FaceSign;
            };
            
            void SG_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2(Bindings_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2 IN, out float OutBoolean_1)
            {
                float _IsFrontFace_F6DF08D5_Out_0 = max(0, IN.FaceSign);
                float _Not_3B19614D_Out_1;
                Unity_Not_float(_IsFrontFace_F6DF08D5_Out_0, _Not_3B19614D_Out_1);
                OutBoolean_1 = _Not_3B19614D_Out_1;
            }
            
            // 928f91ea5fffaa68cdc1e5110d727baf
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeNormalMapping.hlsl"
            
            struct Bindings_CrestComputeNormal_61b9efc6612ab3b4f84174344af5e12a
            {
                float FaceSign;
            };
            
            void SG_CrestComputeNormal_61b9efc6612ab3b4f84174344af5e12a(float3 Vector3_FE793823, float3 Vector3_C8190B61, float4 Vector4_F18E4948, float4 Vector4_43DD8E03, float Vector1_8771A258, TEXTURE2D_PARAM(Texture2D_6CA3A26C, samplerTexture2D_6CA3A26C), float4 Texture2D_6CA3A26C_TexelSize, float Vector1_418D6270, float Vector1_6EC9A7C0, float Vector1_5D9D8139, float2 Vector2_3ED47A62, float2 Vector2_891575B0, float3 Vector3_A9F402BF, Bindings_CrestComputeNormal_61b9efc6612ab3b4f84174344af5e12a IN, out half3 Normal_1)
            {
                float3 _Property_9021A08B_Out_0 = Vector3_FE793823;
                float3 _Property_9C8BC1F1_Out_0 = Vector3_C8190B61;
                float4 _Property_BA13B38B_Out_0 = Vector4_F18E4948;
                float4 _Property_587E24D5_Out_0 = Vector4_43DD8E03;
                float _Property_1A49C52D_Out_0 = Vector1_8771A258;
                float _Property_514FBFB9_Out_0 = Vector1_418D6270;
                float _Property_27A6DF1E_Out_0 = Vector1_6EC9A7C0;
                float _Property_A277E64F_Out_0 = Vector1_5D9D8139;
                float2 _Property_805F9A1D_Out_0 = Vector2_3ED47A62;
                float2 _Property_100A6EB8_Out_0 = Vector2_891575B0;
                float3 _Property_11AD0CE_Out_0 = Vector3_A9F402BF;
                Bindings_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2 _CrestIsUnderwater_BA18A1A;
                _CrestIsUnderwater_BA18A1A.FaceSign = IN.FaceSign;
                float _CrestIsUnderwater_BA18A1A_OutBoolean_1;
                SG_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2(_CrestIsUnderwater_BA18A1A, _CrestIsUnderwater_BA18A1A_OutBoolean_1);
                half3 _CustomFunction_61A7F8B0_NormalTS_1;
                OceanNormals_half(_Property_9021A08B_Out_0, _Property_9C8BC1F1_Out_0, _Property_BA13B38B_Out_0, _Property_587E24D5_Out_0, _Property_1A49C52D_Out_0, Texture2D_6CA3A26C, _Property_514FBFB9_Out_0, _Property_27A6DF1E_Out_0, _Property_A277E64F_Out_0, _Property_805F9A1D_Out_0, _Property_100A6EB8_Out_0, _Property_11AD0CE_Out_0, _CrestIsUnderwater_BA18A1A_OutBoolean_1, _CustomFunction_61A7F8B0_NormalTS_1);
                Normal_1 = _CustomFunction_61A7F8B0_NormalTS_1;
            }
            
            // 52e02b1b13552331adad44cf4a7ae4a5
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeApplyFresnel.hlsl"
            
            struct Bindings_CrestFresnel_c6f6c13c4fdb04e42b427e4c2610d3c9
            {
                float FaceSign;
            };
            
            void SG_CrestFresnel_c6f6c13c4fdb04e42b427e4c2610d3c9(float3 Vector3_FFFD5D37, float3 Vector3_50713CBB, float Vector1_C2909293, float Vector1_DDF5B66E, Bindings_CrestFresnel_c6f6c13c4fdb04e42b427e4c2610d3c9 IN, out float LightTransmitted_1, out float LightReflected_2)
            {
                float3 _Property_3166A32_Out_0 = Vector3_50713CBB;
                float3 _Property_ED2FFB18_Out_0 = Vector3_FFFD5D37;
                Bindings_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2 _CrestIsUnderwater_291EED16;
                _CrestIsUnderwater_291EED16.FaceSign = IN.FaceSign;
                float _CrestIsUnderwater_291EED16_OutBoolean_1;
                SG_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2(_CrestIsUnderwater_291EED16, _CrestIsUnderwater_291EED16_OutBoolean_1);
                float _Property_D5B7D059_Out_0 = Vector1_DDF5B66E;
                float _Property_2395CED2_Out_0 = Vector1_C2909293;
                float _CustomFunction_6DEBC54E_LightTransmitted_1;
                float _CustomFunction_6DEBC54E_LightReflected_10;
                CrestNodeApplyFresnel_float(_Property_3166A32_Out_0, _Property_ED2FFB18_Out_0, _CrestIsUnderwater_291EED16_OutBoolean_1, _Property_D5B7D059_Out_0, _Property_2395CED2_Out_0, _CustomFunction_6DEBC54E_LightTransmitted_1, _CustomFunction_6DEBC54E_LightReflected_10);
                LightTransmitted_1 = _CustomFunction_6DEBC54E_LightTransmitted_1;
                LightReflected_2 = _CustomFunction_6DEBC54E_LightReflected_10;
            }
            
            void GetAmbientLighting_float(out float3 AmbientLighting)
            {
                AmbientLighting = half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
            }
            
            // 4e36a733a1fa5e9359282bf30157c748
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeLightWaterVolume.hlsl"
            
            struct Bindings_CrestVolumeLighting_e9ed6e11710a50640bb4b811d0fa84f2
            {
            };
            
            void SG_CrestVolumeLighting_e9ed6e11710a50640bb4b811d0fa84f2(float4 Vector4_7C3B7892, float3 Vector3_CB562741, float4 Vector4_1925E051, float Vector1_E556918C, float Vector1_67342C54, float Vector1_D7DF1AB, float Vector1_6823579F, float4 Vector4_79A1BE1F, float Vector1_7223C6AC, float Vector1_66E9E54, float2 Vector2_D3558D33, float Vector1_96B7F6DA, float3 Vector3_1559C54, float3 Vector3_EBF06BD4, float3 Vector3_4BB1E4A, float3 Vector3_938EEF71, float3 Vector3_CAD84B7A, Bindings_CrestVolumeLighting_e9ed6e11710a50640bb4b811d0fa84f2 IN, out half3 VolumeLighting_1)
            {
                float4 _Property_3BF186D2_Out_0 = Vector4_7C3B7892;
                float3 _Property_36BD3B33_Out_0 = Vector3_CB562741;
                float4 _Property_DEEB4017_Out_0 = Vector4_1925E051;
                float _Property_DEF8261_Out_0 = Vector1_E556918C;
                float _Property_E59433A0_Out_0 = Vector1_67342C54;
                float _Property_B909C546_Out_0 = Vector1_D7DF1AB;
                float _Property_E4FBA75D_Out_0 = Vector1_6823579F;
                float4 _Property_856C2495_Out_0 = Vector4_79A1BE1F;
                float _Property_D81EDA3D_Out_0 = Vector1_7223C6AC;
                float _Property_9368CB3D_Out_0 = Vector1_66E9E54;
                float2 _Property_BF038BF7_Out_0 = Vector2_D3558D33;
                float _Property_F35AF73E_Out_0 = Vector1_96B7F6DA;
                float3 _Property_32B01413_Out_0 = Vector3_1559C54;
                float3 _Property_5B1BCADB_Out_0 = Vector3_EBF06BD4;
                float3 _Property_6BBACEFC_Out_0 = Vector3_4BB1E4A;
                float3 _Property_C8DE9461_Out_0 = Vector3_938EEF71;
                float3 _Property_919832B1_Out_0 = Vector3_CAD84B7A;
                half3 _CustomFunction_F6F194A9_VolumeLighting_5;
                CrestNodeLightWaterVolume_half((_Property_3BF186D2_Out_0.xyz), _Property_36BD3B33_Out_0, (_Property_DEEB4017_Out_0.xyz), _Property_DEF8261_Out_0, _Property_E59433A0_Out_0, _Property_B909C546_Out_0, _Property_E4FBA75D_Out_0, (_Property_856C2495_Out_0.xyz), _Property_D81EDA3D_Out_0, _Property_9368CB3D_Out_0, _Property_BF038BF7_Out_0, _Property_F35AF73E_Out_0, _Property_32B01413_Out_0, _Property_5B1BCADB_Out_0, _Property_6BBACEFC_Out_0, _Property_C8DE9461_Out_0, _Property_919832B1_Out_0, _CustomFunction_F6F194A9_VolumeLighting_5);
                VolumeLighting_1 = _CustomFunction_F6F194A9_VolumeLighting_5;
            }
            
            void Unity_Negate_float(float In, out float Out)
            {
                Out = -1 * In;
            }
            
            void Unity_SceneColor_float(float4 UV, out float3 Out)
            {
                Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
            }
            
            void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
            
            // edda0395615fdcd072915b34eccb4069
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeOceanGlobals.hlsl"
            
            struct Bindings_CrestOceanGlobals_d50a85284893ec447a25a093505a2120
            {
            };
            
            void SG_CrestOceanGlobals_d50a85284893ec447a25a093505a2120(Bindings_CrestOceanGlobals_d50a85284893ec447a25a093505a2120 IN, out float CrestTime_1, out float TexelsPerWave_2, out float3 OceanCenterPosWorld_3, out float SliceCount_4, out float MeshScaleLerp_5)
            {
                float _CustomFunction_9ED6B15_CrestTime_0;
                float _CustomFunction_9ED6B15_TexelsPerWave_1;
                float3 _CustomFunction_9ED6B15_OceanCenterPosWorld_2;
                float _CustomFunction_9ED6B15_SliceCount_3;
                float _CustomFunction_9ED6B15_MeshScaleLerp_4;
                CrestNodeOceanGlobals_float(_CustomFunction_9ED6B15_CrestTime_0, _CustomFunction_9ED6B15_TexelsPerWave_1, _CustomFunction_9ED6B15_OceanCenterPosWorld_2, _CustomFunction_9ED6B15_SliceCount_3, _CustomFunction_9ED6B15_MeshScaleLerp_4);
                CrestTime_1 = _CustomFunction_9ED6B15_CrestTime_0;
                TexelsPerWave_2 = _CustomFunction_9ED6B15_TexelsPerWave_1;
                OceanCenterPosWorld_3 = _CustomFunction_9ED6B15_OceanCenterPosWorld_2;
                SliceCount_4 = _CustomFunction_9ED6B15_SliceCount_3;
                MeshScaleLerp_5 = _CustomFunction_9ED6B15_MeshScaleLerp_4;
            }
            
            void Unity_Modulo_float(float A, float B, out float Out)
            {
                Out = fmod(A, B);
            }
            
            void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
            {
                Out = A * B;
            }
            
            void Unity_Comparison_Greater_float(float A, float B, out float Out)
            {
                Out = A > B ? 1 : 0;
            }
            
            void Unity_Subtract_float(float A, float B, out float Out)
            {
                Out = A - B;
            }
            
            void Unity_Branch_float(float Predicate, float True, float False, out float Out)
            {
                Out = lerp(False, True, Predicate);
            }
            
            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }
            
            struct Bindings_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1
            {
            };
            
            void SG_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1(float2 Vector2_B562EFB1, float2 Vector2_83AA31A8, Bindings_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1 IN, out float2 DisplacedA_1, out float WeightA_3, out float2 DisplacedB_2, out float WeightB_4)
            {
                float2 _Property_DB670C03_Out_0 = Vector2_83AA31A8;
                float2 _Property_6ED023E0_Out_0 = Vector2_B562EFB1;
                Bindings_CrestOceanGlobals_d50a85284893ec447a25a093505a2120 _CrestOceanGlobals_40DCBE3E;
                float _CrestOceanGlobals_40DCBE3E_CrestTime_1;
                float _CrestOceanGlobals_40DCBE3E_TexelsPerWave_2;
                float3 _CrestOceanGlobals_40DCBE3E_OceanCenterPosWorld_3;
                float _CrestOceanGlobals_40DCBE3E_SliceCount_4;
                float _CrestOceanGlobals_40DCBE3E_MeshScaleLerp_5;
                SG_CrestOceanGlobals_d50a85284893ec447a25a093505a2120(_CrestOceanGlobals_40DCBE3E, _CrestOceanGlobals_40DCBE3E_CrestTime_1, _CrestOceanGlobals_40DCBE3E_TexelsPerWave_2, _CrestOceanGlobals_40DCBE3E_OceanCenterPosWorld_3, _CrestOceanGlobals_40DCBE3E_SliceCount_4, _CrestOceanGlobals_40DCBE3E_MeshScaleLerp_5);
                float _Modulo_CC9BC285_Out_2;
                Unity_Modulo_float(_CrestOceanGlobals_40DCBE3E_CrestTime_1, 2, _Modulo_CC9BC285_Out_2);
                float2 _Multiply_821FCA56_Out_2;
                Unity_Multiply_float(_Property_6ED023E0_Out_0, (_Modulo_CC9BC285_Out_2.xx), _Multiply_821FCA56_Out_2);
                float2 _Subtract_273125FF_Out_2;
                Unity_Subtract_float2(_Property_DB670C03_Out_0, _Multiply_821FCA56_Out_2, _Subtract_273125FF_Out_2);
                float2 _Property_C2A19C1C_Out_0 = Vector2_83AA31A8;
                #if defined(CREST_FLOW_ON)
                float2 _FLOW_963D27CC_Out_0 = _Subtract_273125FF_Out_2;
                #else
                float2 _FLOW_963D27CC_Out_0 = _Property_C2A19C1C_Out_0;
                #endif
                float _Comparison_67E5EC91_Out_2;
                Unity_Comparison_Greater_float(_Modulo_CC9BC285_Out_2, 1, _Comparison_67E5EC91_Out_2);
                float _Subtract_289E2A26_Out_2;
                Unity_Subtract_float(2, _Modulo_CC9BC285_Out_2, _Subtract_289E2A26_Out_2);
                float _Branch_57B6378F_Out_3;
                Unity_Branch_float(_Comparison_67E5EC91_Out_2, _Subtract_289E2A26_Out_2, _Modulo_CC9BC285_Out_2, _Branch_57B6378F_Out_3);
                #if defined(CREST_FLOW_ON)
                float _FLOW_AB68F2D0_Out_0 = _Branch_57B6378F_Out_3;
                #else
                float _FLOW_AB68F2D0_Out_0 = 0;
                #endif
                float2 _Property_CF607B59_Out_0 = Vector2_83AA31A8;
                float2 _Property_8EFEBF1A_Out_0 = Vector2_B562EFB1;
                float _Add_43F824C8_Out_2;
                Unity_Add_float(_CrestOceanGlobals_40DCBE3E_CrestTime_1, 1, _Add_43F824C8_Out_2);
                float _Modulo_2FF365BF_Out_2;
                Unity_Modulo_float(_Add_43F824C8_Out_2, 2, _Modulo_2FF365BF_Out_2);
                float2 _Multiply_28DD98EB_Out_2;
                Unity_Multiply_float(_Property_8EFEBF1A_Out_0, (_Modulo_2FF365BF_Out_2.xx), _Multiply_28DD98EB_Out_2);
                float2 _Subtract_1C7014D5_Out_2;
                Unity_Subtract_float2(_Property_CF607B59_Out_0, _Multiply_28DD98EB_Out_2, _Subtract_1C7014D5_Out_2);
                #if defined(CREST_FLOW_ON)
                float2 _FLOW_D38C09E5_Out_0 = _Subtract_1C7014D5_Out_2;
                #else
                float2 _FLOW_D38C09E5_Out_0 = _Property_C2A19C1C_Out_0;
                #endif
                float _Subtract_563D329D_Out_2;
                Unity_Subtract_float(1, _Branch_57B6378F_Out_3, _Subtract_563D329D_Out_2);
                #if defined(CREST_FLOW_ON)
                float _FLOW_CB3A12C4_Out_0 = _Subtract_563D329D_Out_2;
                #else
                float _FLOW_CB3A12C4_Out_0 = 0;
                #endif
                DisplacedA_1 = _FLOW_963D27CC_Out_0;
                WeightA_3 = _FLOW_AB68F2D0_Out_0;
                DisplacedB_2 = _FLOW_D38C09E5_Out_0;
                WeightB_4 = _FLOW_CB3A12C4_Out_0;
            }
            
            void Unity_Lerp_float2(float2 A, float2 B, float2 T, out float2 Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Multiply_float(float A, float B, out float Out)
            {
                Out = A * B;
            }
            
            void Unity_Add_float2(float2 A, float2 B, out float2 Out)
            {
                Out = A + B;
            }
            
            void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
            {
                Out = A / B;
            }
            
            void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
            {
                Out = dot(A, B);
            }
            
            void Unity_Lerp_float(float A, float B, float T, out float Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
            {
                Out = A * B;
            }
            
            void Unity_Saturate_float(float In, out float Out)
            {
                Out = saturate(In);
            }
            
            // 77d0d525f8d2ec135aebd23c92ac3bf7
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeAmbientLight.hlsl"
            
            struct Bindings_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744
            {
            };
            
            void SG_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744(float3 Vector3_6BC21072, float Vector1_856C8201, float Vector1_D8FFBADE, TEXTURE2D_PARAM(Texture2D_E5D62D20, samplerTexture2D_E5D62D20), float4 Texture2D_E5D62D20_TexelSize, float2 Vector2_1544647C, float Vector1_563FFC82, float Vector1_50FCE8BC, float3 Vector3_8690BC0A, float4 Vector4_8E91C60A, float4 Vector4_8FA06CD1, float2 Vector2_A796D1D3, float2 Vector2_73579388, float Vector1_5220E305, float3 Vector3_7DE999FE, Bindings_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744 IN, out float3 Colour_1)
            {
                float _Vector1_50808D77_Out_0 = 0.74;
                float2 _Property_1DB3A8DD_Out_0 = Vector2_73579388;
                float2 _Property_4E1B12A2_Out_0 = Vector2_A796D1D3;
                float _Vector1_22194DBD_Out_0 = 0.7;
                float2 _Lerp_24C286E6_Out_3;
                Unity_Lerp_float2(_Property_1DB3A8DD_Out_0, _Property_4E1B12A2_Out_0, (_Vector1_22194DBD_Out_0.xx), _Lerp_24C286E6_Out_3);
                Bindings_CrestOceanGlobals_d50a85284893ec447a25a093505a2120 _CrestOceanGlobals_FD233E7F;
                float _CrestOceanGlobals_FD233E7F_CrestTime_1;
                float _CrestOceanGlobals_FD233E7F_TexelsPerWave_2;
                float3 _CrestOceanGlobals_FD233E7F_OceanCenterPosWorld_3;
                float _CrestOceanGlobals_FD233E7F_SliceCount_4;
                float _CrestOceanGlobals_FD233E7F_MeshScaleLerp_5;
                SG_CrestOceanGlobals_d50a85284893ec447a25a093505a2120(_CrestOceanGlobals_FD233E7F, _CrestOceanGlobals_FD233E7F_CrestTime_1, _CrestOceanGlobals_FD233E7F_TexelsPerWave_2, _CrestOceanGlobals_FD233E7F_OceanCenterPosWorld_3, _CrestOceanGlobals_FD233E7F_SliceCount_4, _CrestOceanGlobals_FD233E7F_MeshScaleLerp_5);
                float _Multiply_8E48D7F_Out_2;
                Unity_Multiply_float(0.5, _CrestOceanGlobals_FD233E7F_CrestTime_1, _Multiply_8E48D7F_Out_2);
                float2 _Vector2_93AF7702_Out_0 = float2(0.866, 0.5);
                float2 _Multiply_E81E304E_Out_2;
                Unity_Multiply_float((_Multiply_8E48D7F_Out_2.xx), _Vector2_93AF7702_Out_0, _Multiply_E81E304E_Out_2);
                float2 _Add_99B474A3_Out_2;
                Unity_Add_float2(_Lerp_24C286E6_Out_3, _Multiply_E81E304E_Out_2, _Add_99B474A3_Out_2);
                float _Property_A5B593BF_Out_0 = Vector1_563FFC82;
                float2 _Divide_6E172BAC_Out_2;
                Unity_Divide_float2(_Add_99B474A3_Out_2, (_Property_A5B593BF_Out_0.xx), _Divide_6E172BAC_Out_2);
                float _Vector1_33088EF8_Out_0 = 0.125;
                float3 _Property_CBFC7F14_Out_0 = Vector3_8690BC0A;
                float _Split_638CEA28_R_1 = _Property_CBFC7F14_Out_0[0];
                float _Split_638CEA28_G_2 = _Property_CBFC7F14_Out_0[1];
                float _Split_638CEA28_B_3 = _Property_CBFC7F14_Out_0[2];
                float _Split_638CEA28_A_4 = 0;
                float2 _Vector2_1CDF6E92_Out_0 = float2(_Split_638CEA28_R_1, _Split_638CEA28_B_3);
                float2 _Multiply_FEAB095D_Out_2;
                Unity_Multiply_float((_Vector1_33088EF8_Out_0.xx), _Vector2_1CDF6E92_Out_0, _Multiply_FEAB095D_Out_2);
                float2 _Add_301F9C93_Out_2;
                Unity_Add_float2(_Divide_6E172BAC_Out_2, _Multiply_FEAB095D_Out_2, _Add_301F9C93_Out_2);
                float2 _Multiply_47C4DD4E_Out_2;
                Unity_Multiply_float((_Vector1_50808D77_Out_0.xx), _Add_301F9C93_Out_2, _Multiply_47C4DD4E_Out_2);
                float _Property_569DF47F_Out_0 = Vector1_856C8201;
                float3 _Property_D240D17_Out_0 = Vector3_7DE999FE;
                float _Split_628EF5DE_R_1 = _Property_D240D17_Out_0[0];
                float _Split_628EF5DE_G_2 = _Property_D240D17_Out_0[1];
                float _Split_628EF5DE_B_3 = _Property_D240D17_Out_0[2];
                float _Split_628EF5DE_A_4 = 0;
                float2 _Vector2_BF066046_Out_0 = float2(_Split_628EF5DE_R_1, _Split_628EF5DE_B_3);
                float2 _Multiply_43CB1359_Out_2;
                Unity_Multiply_float((_Property_569DF47F_Out_0.xx), _Vector2_BF066046_Out_0, _Multiply_43CB1359_Out_2);
                float3 _Property_122053A8_Out_0 = Vector3_8690BC0A;
                float3 _Property_ADBC2425_Out_0 = Vector3_7DE999FE;
                float _DotProduct_B4F8C812_Out_2;
                Unity_DotProduct_float3(_Property_122053A8_Out_0, _Property_ADBC2425_Out_0, _DotProduct_B4F8C812_Out_2);
                float2 _Divide_63189A2B_Out_2;
                Unity_Divide_float2(_Multiply_43CB1359_Out_2, (_DotProduct_B4F8C812_Out_2.xx), _Divide_63189A2B_Out_2);
                float2 _Add_D56F8BCC_Out_2;
                Unity_Add_float2(_Multiply_47C4DD4E_Out_2, _Divide_63189A2B_Out_2, _Add_D56F8BCC_Out_2);
                float _Vector1_4A3115D0_Out_0 = 4;
                float4 _Property_6BB45B70_Out_0 = Vector4_8E91C60A;
                float _Split_128BB5B0_R_1 = _Property_6BB45B70_Out_0[0];
                float _Split_128BB5B0_G_2 = _Property_6BB45B70_Out_0[1];
                float _Split_128BB5B0_B_3 = _Property_6BB45B70_Out_0[2];
                float _Split_128BB5B0_A_4 = _Property_6BB45B70_Out_0[3];
                float _Multiply_338764B5_Out_2;
                Unity_Multiply_float(_Vector1_4A3115D0_Out_0, _Split_128BB5B0_R_1, _Multiply_338764B5_Out_2);
                float _Property_ACBE1A98_Out_0 = Vector1_563FFC82;
                float _Multiply_69F2FFA6_Out_2;
                Unity_Multiply_float(_Multiply_338764B5_Out_2, _Property_ACBE1A98_Out_0, _Multiply_69F2FFA6_Out_2);
                float2 _Divide_FF361B20_Out_2;
                Unity_Divide_float2(_Add_D56F8BCC_Out_2, (_Multiply_69F2FFA6_Out_2.xx), _Divide_FF361B20_Out_2);
                float4 _SampleTexture2DLOD_181D539B_RGBA_0 = SAMPLE_TEXTURE2D_LOD(Texture2D_E5D62D20, SamplerState_Linear_Repeat, _Divide_FF361B20_Out_2, 3);
                float _SampleTexture2DLOD_181D539B_R_5 = _SampleTexture2DLOD_181D539B_RGBA_0.r;
                float _SampleTexture2DLOD_181D539B_G_6 = _SampleTexture2DLOD_181D539B_RGBA_0.g;
                float _SampleTexture2DLOD_181D539B_B_7 = _SampleTexture2DLOD_181D539B_RGBA_0.b;
                float _SampleTexture2DLOD_181D539B_A_8 = _SampleTexture2DLOD_181D539B_RGBA_0.a;
                float _Vector1_C260EA24_Out_0 = 4;
                float4 _Property_1EB65445_Out_0 = Vector4_8FA06CD1;
                float _Split_DFFF5F9B_R_1 = _Property_1EB65445_Out_0[0];
                float _Split_DFFF5F9B_G_2 = _Property_1EB65445_Out_0[1];
                float _Split_DFFF5F9B_B_3 = _Property_1EB65445_Out_0[2];
                float _Split_DFFF5F9B_A_4 = _Property_1EB65445_Out_0[3];
                float _Multiply_FD1848E_Out_2;
                Unity_Multiply_float(_Vector1_C260EA24_Out_0, _Split_DFFF5F9B_R_1, _Multiply_FD1848E_Out_2);
                float _Property_4D74395B_Out_0 = Vector1_563FFC82;
                float _Multiply_BB87C63D_Out_2;
                Unity_Multiply_float(_Multiply_FD1848E_Out_2, _Property_4D74395B_Out_0, _Multiply_BB87C63D_Out_2);
                float2 _Divide_7AE4E36C_Out_2;
                Unity_Divide_float2(_Add_D56F8BCC_Out_2, (_Multiply_BB87C63D_Out_2.xx), _Divide_7AE4E36C_Out_2);
                float4 _SampleTexture2DLOD_F7B977AE_RGBA_0 = SAMPLE_TEXTURE2D_LOD(Texture2D_E5D62D20, SamplerState_Linear_Repeat, _Divide_7AE4E36C_Out_2, 3);
                float _SampleTexture2DLOD_F7B977AE_R_5 = _SampleTexture2DLOD_F7B977AE_RGBA_0.r;
                float _SampleTexture2DLOD_F7B977AE_G_6 = _SampleTexture2DLOD_F7B977AE_RGBA_0.g;
                float _SampleTexture2DLOD_F7B977AE_B_7 = _SampleTexture2DLOD_F7B977AE_RGBA_0.b;
                float _SampleTexture2DLOD_F7B977AE_A_8 = _SampleTexture2DLOD_F7B977AE_RGBA_0.a;
                float _Property_8BDFE27D_Out_0 = Vector1_5220E305;
                float _Lerp_8E281E25_Out_3;
                Unity_Lerp_float(_SampleTexture2DLOD_181D539B_R_5, _SampleTexture2DLOD_F7B977AE_R_5, _Property_8BDFE27D_Out_0, _Lerp_8E281E25_Out_3);
                float3 _Property_76A1927E_Out_0 = Vector3_6BC21072;
                float3 _Multiply_559CF32F_Out_2;
                Unity_Multiply_float((_Lerp_8E281E25_Out_3.xxx), _Property_76A1927E_Out_0, _Multiply_559CF32F_Out_2);
                float _Property_47590F25_Out_0 = Vector1_50FCE8BC;
                float _Property_8CF73BE5_Out_0 = Vector1_D8FFBADE;
                float _Multiply_A19262A8_Out_2;
                Unity_Multiply_float(_Property_47590F25_Out_0, _Property_8CF73BE5_Out_0, _Multiply_A19262A8_Out_2);
                float _Saturate_A17AF199_Out_1;
                Unity_Saturate_float(_Multiply_A19262A8_Out_2, _Saturate_A17AF199_Out_1);
                float3 _Multiply_DCE93606_Out_2;
                Unity_Multiply_float(_Multiply_559CF32F_Out_2, (_Saturate_A17AF199_Out_1.xxx), _Multiply_DCE93606_Out_2);
                half3 _CustomFunction_6C4427EF_AmbientLight_0;
                CrestNodeAmbientLight_half(_CustomFunction_6C4427EF_AmbientLight_0);
                float3 _Multiply_9B6FA71B_Out_2;
                Unity_Multiply_float(_Multiply_DCE93606_Out_2, _CustomFunction_6C4427EF_AmbientLight_0, _Multiply_9B6FA71B_Out_2);
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_B0667840_Out_0 = _Multiply_9B6FA71B_Out_2;
                #else
                float3 _FOAM_B0667840_Out_0 = float3(0, 0, 0);
                #endif
                Colour_1 = _FOAM_B0667840_Out_0;
            }
            
            struct Bindings_CrestFoamBubblesWithFlow_e132fba35874b4923988ef35a40e48c3
            {
            };
            
            void SG_CrestFoamBubblesWithFlow_e132fba35874b4923988ef35a40e48c3(float3 Vector3_6BC21072, float Vector1_856C8201, float Vector1_D8FFBADE, TEXTURE2D_PARAM(Texture2D_E5D62D20, samplerTexture2D_E5D62D20), float4 Texture2D_E5D62D20_TexelSize, float2 Vector2_1544647C, float Vector1_563FFC82, float Vector1_50FCE8BC, float3 Vector3_8690BC0A, float4 Vector4_8E91C60A, float4 Vector4_8FA06CD1, float2 Vector2_A796D1D3, float2 Vector2_73579388, float Vector1_5220E305, float3 Vector3_7DE999FE, float2 Vector2_58330803, Bindings_CrestFoamBubblesWithFlow_e132fba35874b4923988ef35a40e48c3 IN, out float3 Colour_1)
            {
                float3 _Property_943DDE94_Out_0 = Vector3_6BC21072;
                float _Property_2A86C6D_Out_0 = Vector1_856C8201;
                float _Property_742EBA65_Out_0 = Vector1_D8FFBADE;
                float2 _Property_56F70460_Out_0 = Vector2_1544647C;
                float _Property_BBD1954E_Out_0 = Vector1_563FFC82;
                float _Property_63B10EE4_Out_0 = Vector1_50FCE8BC;
                float3 _Property_736DEE08_Out_0 = Vector3_8690BC0A;
                float4 _Property_E1794A68_Out_0 = Vector4_8E91C60A;
                float4 _Property_13FD15E9_Out_0 = Vector4_8FA06CD1;
                float2 _Property_8C400C63_Out_0 = Vector2_A796D1D3;
                float2 _Property_B43D23D2_Out_0 = Vector2_58330803;
                float2 _Property_6AC0F258_Out_0 = Vector2_73579388;
                Bindings_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1 _CrestFlow_2C0F2FAE;
                float2 _CrestFlow_2C0F2FAE_DisplacedA_1;
                float _CrestFlow_2C0F2FAE_WeightA_3;
                float2 _CrestFlow_2C0F2FAE_DisplacedB_2;
                float _CrestFlow_2C0F2FAE_WeightB_4;
                SG_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1(_Property_B43D23D2_Out_0, _Property_6AC0F258_Out_0, _CrestFlow_2C0F2FAE, _CrestFlow_2C0F2FAE_DisplacedA_1, _CrestFlow_2C0F2FAE_WeightA_3, _CrestFlow_2C0F2FAE_DisplacedB_2, _CrestFlow_2C0F2FAE_WeightB_4);
                float _Property_4C00CA0D_Out_0 = Vector1_5220E305;
                float3 _Property_5BF1E9DE_Out_0 = Vector3_7DE999FE;
                Bindings_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744 _CrestFoamBubbles_E18873D;
                float3 _CrestFoamBubbles_E18873D_Colour_1;
                SG_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744(_Property_943DDE94_Out_0, _Property_2A86C6D_Out_0, _Property_742EBA65_Out_0, TEXTURE2D_ARGS(Texture2D_E5D62D20, samplerTexture2D_E5D62D20), Texture2D_E5D62D20_TexelSize, _Property_56F70460_Out_0, _Property_BBD1954E_Out_0, _Property_63B10EE4_Out_0, _Property_736DEE08_Out_0, _Property_E1794A68_Out_0, _Property_13FD15E9_Out_0, _Property_8C400C63_Out_0, _CrestFlow_2C0F2FAE_DisplacedA_1, _Property_4C00CA0D_Out_0, _Property_5BF1E9DE_Out_0, _CrestFoamBubbles_E18873D, _CrestFoamBubbles_E18873D_Colour_1);
                float3 _Multiply_91E077CA_Out_2;
                Unity_Multiply_float(_CrestFoamBubbles_E18873D_Colour_1, (_CrestFlow_2C0F2FAE_WeightA_3.xxx), _Multiply_91E077CA_Out_2);
                float3 _Property_A1641BBA_Out_0 = Vector3_6BC21072;
                float _Property_3D5C8C49_Out_0 = Vector1_856C8201;
                float _Property_212108F5_Out_0 = Vector1_D8FFBADE;
                float2 _Property_E4A605_Out_0 = Vector2_1544647C;
                float _Property_6B5F6C8D_Out_0 = Vector1_563FFC82;
                float _Property_C1EFD93_Out_0 = Vector1_50FCE8BC;
                float3 _Property_374658EE_Out_0 = Vector3_8690BC0A;
                float4 _Property_93465CAB_Out_0 = Vector4_8E91C60A;
                float4 _Property_D292F7E_Out_0 = Vector4_8FA06CD1;
                float2 _Property_41EA12FB_Out_0 = Vector2_A796D1D3;
                float _Property_ACCAE2A2_Out_0 = Vector1_5220E305;
                float3 _Property_419B8C8_Out_0 = Vector3_7DE999FE;
                Bindings_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744 _CrestFoamBubbles_B2999161;
                float3 _CrestFoamBubbles_B2999161_Colour_1;
                SG_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744(_Property_A1641BBA_Out_0, _Property_3D5C8C49_Out_0, _Property_212108F5_Out_0, TEXTURE2D_ARGS(Texture2D_E5D62D20, samplerTexture2D_E5D62D20), Texture2D_E5D62D20_TexelSize, _Property_E4A605_Out_0, _Property_6B5F6C8D_Out_0, _Property_C1EFD93_Out_0, _Property_374658EE_Out_0, _Property_93465CAB_Out_0, _Property_D292F7E_Out_0, _Property_41EA12FB_Out_0, _CrestFlow_2C0F2FAE_DisplacedB_2, _Property_ACCAE2A2_Out_0, _Property_419B8C8_Out_0, _CrestFoamBubbles_B2999161, _CrestFoamBubbles_B2999161_Colour_1);
                float3 _Multiply_B28E3E4F_Out_2;
                Unity_Multiply_float(_CrestFoamBubbles_B2999161_Colour_1, (_CrestFlow_2C0F2FAE_WeightB_4.xxx), _Multiply_B28E3E4F_Out_2);
                float3 _Add_4A081B98_Out_2;
                Unity_Add_float3(_Multiply_91E077CA_Out_2, _Multiply_B28E3E4F_Out_2, _Add_4A081B98_Out_2);
                #if defined(CREST_FLOW_ON)
                float3 _FLOW_3ACDD4E5_Out_0 = _Add_4A081B98_Out_2;
                #else
                float3 _FLOW_3ACDD4E5_Out_0 = _CrestFoamBubbles_E18873D_Colour_1;
                #endif
                Colour_1 = _FLOW_3ACDD4E5_Out_0;
            }
            
            // 11f8e1767f0d2397594b0042f8356f6e
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeVolumeEmission.hlsl"
            
            struct Bindings_CrestSampleOceanDataSingle_a667f031fd6a3dd42beee0ccc432233d
            {
            };
            
            void SG_CrestSampleOceanDataSingle_a667f031fd6a3dd42beee0ccc432233d(float2 Vector2_1BD49B8D, float3 Vector3_7E91D336, float4 Vector4_C0B2B5EA, float Vector1_8EA8B92B, Bindings_CrestSampleOceanDataSingle_a667f031fd6a3dd42beee0ccc432233d IN, out float3 Displacement_1, out float OceanWaterDepth_5, out float Foam_6, out float2 Shadow_7, out float2 Flow_8, out float SubSurfaceScattering_9)
            {
                float2 _Property_FA70A3E6_Out_0 = Vector2_1BD49B8D;
                float3 _Property_C925A867_Out_0 = Vector3_7E91D336;
                float4 _Property_467D1BE7_Out_0 = Vector4_C0B2B5EA;
                float _Property_59E019ED_Out_0 = Vector1_8EA8B92B;
                float3 _CustomFunction_487C31E1_Displacement_3;
                float _CustomFunction_487C31E1_OceanDepth_8;
                float _CustomFunction_487C31E1_Foam_4;
                float2 _CustomFunction_487C31E1_Shadow_5;
                float2 _CustomFunction_487C31E1_Flow_6;
                float _CustomFunction_487C31E1_SSS_17;
                CrestNodeSampleOceanDataSingle_float(_Property_FA70A3E6_Out_0, _Property_C925A867_Out_0, _Property_467D1BE7_Out_0, _Property_59E019ED_Out_0, _CustomFunction_487C31E1_Displacement_3, _CustomFunction_487C31E1_OceanDepth_8, _CustomFunction_487C31E1_Foam_4, _CustomFunction_487C31E1_Shadow_5, _CustomFunction_487C31E1_Flow_6, _CustomFunction_487C31E1_SSS_17);
                Displacement_1 = _CustomFunction_487C31E1_Displacement_3;
                OceanWaterDepth_5 = _CustomFunction_487C31E1_OceanDepth_8;
                Foam_6 = _CustomFunction_487C31E1_Foam_4;
                Shadow_7 = _CustomFunction_487C31E1_Shadow_5;
                Flow_8 = _CustomFunction_487C31E1_Flow_6;
                SubSurfaceScattering_9 = _CustomFunction_487C31E1_SSS_17;
            }
            
            // 733e22c05b4f35356dd63172ccf21370
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeApplyCaustics.hlsl"
            
            void Unity_Negate_float3(float3 In, out float3 Out)
            {
                Out = -1 * In;
            }
            
            void Unity_Exponential_float3(float3 In, out float3 Out)
            {
                Out = exp(In);
            }
            
            void Unity_OneMinus_float3(float3 In, out float3 Out)
            {
                Out = 1 - In;
            }
            
            void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
            {
                Out = lerp(False, True, Predicate);
            }
            
            struct Bindings_CrestEmission_8c56460232fde1e46ae90d905a00f908
            {
            };
            
            void SG_CrestEmission_8c56460232fde1e46ae90d905a00f908(float Vector1_82EC3C0B, float3 Vector3_6C3F4D52, float3 Vector3_83F0ECB8, float3 Vector3_D6B78A76, float3 Vector3_703F2DD, float4 Vector4_5D0F731B, float Vector1_73B9F9E8, float3 Vector3_D4CABAFD, float Vector1_6C78E163, half3 Vector3_71E7580E, TEXTURE2D_PARAM(Texture2D_BA141407, samplerTexture2D_BA141407), float4 Texture2D_BA141407_TexelSize, half Vector1_460D9038, half Vector1_D5CE42D3, half Vector1_AC9C2A2, half Vector1_8DBC6E14, half Vector1_EA8F2BEC, TEXTURE2D_PARAM(Texture2D_AC91C4C3, samplerTexture2D_AC91C4C3), float4 Texture2D_AC91C4C3_TexelSize, half Vector1_DB8E128A, half Vector1_CFFD6A53, float3 Vector3_32FB76B3, Bindings_CrestEmission_8c56460232fde1e46ae90d905a00f908 IN, out float3 EmittedLight_1)
            {
                float Boolean_6AA51A5 = 0;
                float _Property_101786D0_Out_0 = Vector1_82EC3C0B;
                float3 _Property_833375DE_Out_0 = Vector3_83F0ECB8;
                float3 _Property_83DC9AD9_Out_0 = Vector3_703F2DD;
                float4 _Property_83CEC55B_Out_0 = Vector4_5D0F731B;
                float _Property_37502285_Out_0 = Vector1_73B9F9E8;
                float3 _Property_5935620A_Out_0 = Vector3_D4CABAFD;
                float _Property_AF5C7A5F_Out_0 = Vector1_6C78E163;
                half3 _CustomFunction_F95A252D_SceneColour_5;
                half _CustomFunction_F95A252D_SceneDistance_9;
                half3 _CustomFunction_F95A252D_ScenePositionWS_10;
                CrestNodeSceneColour_half(_Property_101786D0_Out_0, _Property_833375DE_Out_0, _Property_83DC9AD9_Out_0, _Property_83CEC55B_Out_0, _Property_37502285_Out_0, _Property_5935620A_Out_0, _Property_AF5C7A5F_Out_0, _CustomFunction_F95A252D_SceneColour_5, _CustomFunction_F95A252D_SceneDistance_9, _CustomFunction_F95A252D_ScenePositionWS_10);
                half _Split_550754E3_R_1 = _CustomFunction_F95A252D_ScenePositionWS_10[0];
                half _Split_550754E3_G_2 = _CustomFunction_F95A252D_ScenePositionWS_10[1];
                half _Split_550754E3_B_3 = _CustomFunction_F95A252D_ScenePositionWS_10[2];
                half _Split_550754E3_A_4 = 0;
                half2 _Vector2_B1CFC7F6_Out_0 = half2(_Split_550754E3_R_1, _Split_550754E3_B_3);
                Bindings_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d _CrestDrivenData_541C70CC;
                half _CrestDrivenData_541C70CC_MeshScaleAlpha_1;
                half _CrestDrivenData_541C70CC_LodDataTexelSize_8;
                half _CrestDrivenData_541C70CC_GeometryGridSize_2;
                half3 _CrestDrivenData_541C70CC_OceanPosScale0_3;
                half3 _CrestDrivenData_541C70CC_OceanPosScale1_4;
                half4 _CrestDrivenData_541C70CC_OceanParams0_5;
                half4 _CrestDrivenData_541C70CC_OceanParams1_6;
                half _CrestDrivenData_541C70CC_SliceIndex0_7;
                SG_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d(_CrestDrivenData_541C70CC, _CrestDrivenData_541C70CC_MeshScaleAlpha_1, _CrestDrivenData_541C70CC_LodDataTexelSize_8, _CrestDrivenData_541C70CC_GeometryGridSize_2, _CrestDrivenData_541C70CC_OceanPosScale0_3, _CrestDrivenData_541C70CC_OceanPosScale1_4, _CrestDrivenData_541C70CC_OceanParams0_5, _CrestDrivenData_541C70CC_OceanParams1_6, _CrestDrivenData_541C70CC_SliceIndex0_7);
                float _Add_87784A87_Out_2;
                Unity_Add_float(_CrestDrivenData_541C70CC_SliceIndex0_7, 1, _Add_87784A87_Out_2);
                Bindings_CrestSampleOceanDataSingle_a667f031fd6a3dd42beee0ccc432233d _CrestSampleOceanDataSingle_5C7B7E58;
                float3 _CrestSampleOceanDataSingle_5C7B7E58_Displacement_1;
                float _CrestSampleOceanDataSingle_5C7B7E58_OceanWaterDepth_5;
                float _CrestSampleOceanDataSingle_5C7B7E58_Foam_6;
                float2 _CrestSampleOceanDataSingle_5C7B7E58_Shadow_7;
                float2 _CrestSampleOceanDataSingle_5C7B7E58_Flow_8;
                float _CrestSampleOceanDataSingle_5C7B7E58_SubSurfaceScattering_9;
                SG_CrestSampleOceanDataSingle_a667f031fd6a3dd42beee0ccc432233d(_Vector2_B1CFC7F6_Out_0, _CrestDrivenData_541C70CC_OceanPosScale1_4, _CrestDrivenData_541C70CC_OceanParams1_6, _Add_87784A87_Out_2, _CrestSampleOceanDataSingle_5C7B7E58, _CrestSampleOceanDataSingle_5C7B7E58_Displacement_1, _CrestSampleOceanDataSingle_5C7B7E58_OceanWaterDepth_5, _CrestSampleOceanDataSingle_5C7B7E58_Foam_6, _CrestSampleOceanDataSingle_5C7B7E58_Shadow_7, _CrestSampleOceanDataSingle_5C7B7E58_Flow_8, _CrestSampleOceanDataSingle_5C7B7E58_SubSurfaceScattering_9);
                Bindings_CrestOceanGlobals_d50a85284893ec447a25a093505a2120 _CrestOceanGlobals_FCFEE3C8;
                float _CrestOceanGlobals_FCFEE3C8_CrestTime_1;
                float _CrestOceanGlobals_FCFEE3C8_TexelsPerWave_2;
                float3 _CrestOceanGlobals_FCFEE3C8_OceanCenterPosWorld_3;
                float _CrestOceanGlobals_FCFEE3C8_SliceCount_4;
                float _CrestOceanGlobals_FCFEE3C8_MeshScaleLerp_5;
                SG_CrestOceanGlobals_d50a85284893ec447a25a093505a2120(_CrestOceanGlobals_FCFEE3C8, _CrestOceanGlobals_FCFEE3C8_CrestTime_1, _CrestOceanGlobals_FCFEE3C8_TexelsPerWave_2, _CrestOceanGlobals_FCFEE3C8_OceanCenterPosWorld_3, _CrestOceanGlobals_FCFEE3C8_SliceCount_4, _CrestOceanGlobals_FCFEE3C8_MeshScaleLerp_5);
                float3 _Add_13827433_Out_2;
                Unity_Add_float3(_CrestSampleOceanDataSingle_5C7B7E58_Displacement_1, _CrestOceanGlobals_FCFEE3C8_OceanCenterPosWorld_3, _Add_13827433_Out_2);
                float _Split_8D03CDFB_R_1 = _Add_13827433_Out_2[0];
                float _Split_8D03CDFB_G_2 = _Add_13827433_Out_2[1];
                float _Split_8D03CDFB_B_3 = _Add_13827433_Out_2[2];
                float _Split_8D03CDFB_A_4 = 0;
                half3 _Property_513534C6_Out_0 = Vector3_71E7580E;
                half _Property_EF9152A2_Out_0 = Vector1_460D9038;
                half _Property_3D2898B2_Out_0 = Vector1_D5CE42D3;
                half _Property_35078BD5_Out_0 = Vector1_AC9C2A2;
                half _Property_1B866598_Out_0 = Vector1_8DBC6E14;
                half _Property_2016136C_Out_0 = Vector1_EA8F2BEC;
                half _Property_A64ADC3_Out_0 = Vector1_DB8E128A;
                half _Property_DDF09C09_Out_0 = Vector1_CFFD6A53;
                float3 _CustomFunction_2F6A103B_SceneColourOut_8;
                CrestNodeApplyCaustics_float(_CustomFunction_F95A252D_SceneColour_5, _CustomFunction_F95A252D_ScenePositionWS_10, _Split_8D03CDFB_G_2, _Property_513534C6_Out_0, _CustomFunction_F95A252D_SceneDistance_9, Texture2D_BA141407, _Property_EF9152A2_Out_0, _Property_3D2898B2_Out_0, _Property_35078BD5_Out_0, _Property_1B866598_Out_0, _Property_2016136C_Out_0, Texture2D_AC91C4C3, _Property_A64ADC3_Out_0, _Property_DDF09C09_Out_0, _CustomFunction_2F6A103B_SceneColourOut_8);
                #if defined(CREST_CAUSTICS_ON)
                float3 _CAUSTICS_6D445714_Out_0 = _CustomFunction_2F6A103B_SceneColourOut_8;
                #else
                float3 _CAUSTICS_6D445714_Out_0 = _CustomFunction_F95A252D_SceneColour_5;
                #endif
                float3 _Property_78DFA568_Out_0 = Vector3_83F0ECB8;
                float3 _Property_54BACED9_Out_0 = Vector3_32FB76B3;
                float3 _Add_954C4741_Out_2;
                Unity_Add_float3(_Property_78DFA568_Out_0, _Property_54BACED9_Out_0, _Add_954C4741_Out_2);
                float3 _Property_D76B9A0B_Out_0 = Vector3_6C3F4D52;
                float3 _Multiply_C51E63DE_Out_2;
                Unity_Multiply_float((_CustomFunction_F95A252D_SceneDistance_9.xxx), _Property_D76B9A0B_Out_0, _Multiply_C51E63DE_Out_2);
                float3 _Negate_ADFF8761_Out_1;
                Unity_Negate_float3(_Multiply_C51E63DE_Out_2, _Negate_ADFF8761_Out_1);
                float3 _Exponential_6FCB9AC3_Out_1;
                Unity_Exponential_float3(_Negate_ADFF8761_Out_1, _Exponential_6FCB9AC3_Out_1);
                float3 _OneMinus_9962618_Out_1;
                Unity_OneMinus_float3(_Exponential_6FCB9AC3_Out_1, _OneMinus_9962618_Out_1);
                float3 _Lerp_E9270AE8_Out_3;
                Unity_Lerp_float3(_CAUSTICS_6D445714_Out_0, _Add_954C4741_Out_2, _OneMinus_9962618_Out_1, _Lerp_E9270AE8_Out_3);
                float3 _Branch_2D3EE3D3_Out_3;
                Unity_Branch_float3(1, _Lerp_E9270AE8_Out_3, _CAUSTICS_6D445714_Out_0, _Branch_2D3EE3D3_Out_3);
                float3 _Branch_D043DFC1_Out_3;
                Unity_Branch_float3(Boolean_6AA51A5, _CAUSTICS_6D445714_Out_0, _Branch_2D3EE3D3_Out_3, _Branch_D043DFC1_Out_3);
                EmittedLight_1 = _Branch_D043DFC1_Out_3;
            }
            
            void Unity_Divide_float(float A, float B, out float Out)
            {
                Out = A / B;
            }
            
            void Unity_Power_float(float A, float B, out float Out)
            {
                Out = pow(A, B);
            }
            
            // 97e077ca2652cbf427809ae775e45d5a
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeFoam.hlsl"
            
            struct Bindings_CrestFoamWithFlow_3a6c22dceac0847a2a31cb05a577b963
            {
            };
            
            void SG_CrestFoamWithFlow_3a6c22dceac0847a2a31cb05a577b963(TEXTURE2D_PARAM(Texture2D_D9E7A343, samplerTexture2D_D9E7A343), float4 Texture2D_D9E7A343_TexelSize, float2 Vector2_C4E9ED58, float Vector1_7492C815, float Vector1_33DC93D, float Vector1_3439FC0A, float Vector1_FB133018, float Vector1_7CFAFAC1, float Vector1_53F45327, float4 Vector4_2FA9AEA5, float4 Vector4_FD283A50, float Vector1_D6DA4100, float Vector1_13F2A8C8, float2 Vector2_28A2C5B9, float3 Vector3_3AD012AA, float3 Vector3_E4AC4432, float Vector1_3E452608, float2 Vector2_5AD72ED, Bindings_CrestFoamWithFlow_3a6c22dceac0847a2a31cb05a577b963 IN, out float3 Albedo_1, out float3 NormalTS_2, out float3 Emission_3, out float Smoothness_4)
            {
                float2 _Property_B71BFD9B_Out_0 = Vector2_C4E9ED58;
                float _Property_7C437CB0_Out_0 = Vector1_7492C815;
                float _Property_BD5882DA_Out_0 = Vector1_33DC93D;
                float _Property_3EF95B2A_Out_0 = Vector1_3439FC0A;
                float _Property_38B853C9_Out_0 = Vector1_FB133018;
                float _Property_8F25A4DF_Out_0 = Vector1_7CFAFAC1;
                float _Property_561CFE5E_Out_0 = Vector1_53F45327;
                float4 _Property_A1E249A2_Out_0 = Vector4_2FA9AEA5;
                float4 _Property_9A7BA0BB_Out_0 = Vector4_FD283A50;
                float _Property_4C4E1C83_Out_0 = Vector1_D6DA4100;
                float _Property_D81DA51E_Out_0 = Vector1_13F2A8C8;
                float2 _Property_4BF1D6EA_Out_0 = Vector2_5AD72ED;
                float2 _Property_DEC66EB9_Out_0 = Vector2_28A2C5B9;
                Bindings_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1 _CrestFlow_B4596B;
                float2 _CrestFlow_B4596B_DisplacedA_1;
                float _CrestFlow_B4596B_WeightA_3;
                float2 _CrestFlow_B4596B_DisplacedB_2;
                float _CrestFlow_B4596B_WeightB_4;
                SG_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1(_Property_4BF1D6EA_Out_0, _Property_DEC66EB9_Out_0, _CrestFlow_B4596B, _CrestFlow_B4596B_DisplacedA_1, _CrestFlow_B4596B_WeightA_3, _CrestFlow_B4596B_DisplacedB_2, _CrestFlow_B4596B_WeightB_4);
                float3 _Property_EB1DCAFB_Out_0 = Vector3_3AD012AA;
                float3 _Property_A2BD94BA_Out_0 = Vector3_E4AC4432;
                float _Property_7BFA2B51_Out_0 = Vector1_3E452608;
                half3 _CustomFunction_2B0D0960_Albedo_8;
                half3 _CustomFunction_2B0D0960_NormalTS_7;
                half3 _CustomFunction_2B0D0960_Emission_9;
                half _CustomFunction_2B0D0960_Smoothness_10;
                CrestNodeFoam_half(Texture2D_D9E7A343, _Property_B71BFD9B_Out_0, _Property_7C437CB0_Out_0, _Property_BD5882DA_Out_0, _Property_3EF95B2A_Out_0, _Property_38B853C9_Out_0, _Property_8F25A4DF_Out_0, _Property_561CFE5E_Out_0, _Property_A1E249A2_Out_0, _Property_9A7BA0BB_Out_0, _Property_4C4E1C83_Out_0, _Property_D81DA51E_Out_0, _CrestFlow_B4596B_DisplacedA_1, _Property_EB1DCAFB_Out_0, _Property_A2BD94BA_Out_0, _Property_7BFA2B51_Out_0, _CustomFunction_2B0D0960_Albedo_8, _CustomFunction_2B0D0960_NormalTS_7, _CustomFunction_2B0D0960_Emission_9, _CustomFunction_2B0D0960_Smoothness_10);
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_384819B4_Out_0 = _CustomFunction_2B0D0960_Albedo_8;
                #else
                float3 _FOAM_384819B4_Out_0 = float3(0, 0, 0);
                #endif
                float3 _Multiply_278EF57C_Out_2;
                Unity_Multiply_float(_FOAM_384819B4_Out_0, (_CrestFlow_B4596B_WeightA_3.xxx), _Multiply_278EF57C_Out_2);
                float2 _Property_6338038D_Out_0 = Vector2_C4E9ED58;
                float _Property_C8444C80_Out_0 = Vector1_7492C815;
                float _Property_3DF87814_Out_0 = Vector1_33DC93D;
                float _Property_589C4301_Out_0 = Vector1_3439FC0A;
                float _Property_E9D88423_Out_0 = Vector1_FB133018;
                float _Property_366CB823_Out_0 = Vector1_7CFAFAC1;
                float _Property_1F5469F5_Out_0 = Vector1_53F45327;
                float4 _Property_920AF23F_Out_0 = Vector4_2FA9AEA5;
                float4 _Property_37F6AC84_Out_0 = Vector4_FD283A50;
                float _Property_E7E25E74_Out_0 = Vector1_D6DA4100;
                float _Property_FA2913B0_Out_0 = Vector1_13F2A8C8;
                float3 _Property_4E6AF5FF_Out_0 = Vector3_3AD012AA;
                float3 _Property_A2DA52BE_Out_0 = Vector3_E4AC4432;
                float _Property_9DE15AC9_Out_0 = Vector1_3E452608;
                half3 _CustomFunction_16EDEEAC_Albedo_8;
                half3 _CustomFunction_16EDEEAC_NormalTS_7;
                half3 _CustomFunction_16EDEEAC_Emission_9;
                half _CustomFunction_16EDEEAC_Smoothness_10;
                CrestNodeFoam_half(Texture2D_D9E7A343, _Property_6338038D_Out_0, _Property_C8444C80_Out_0, _Property_3DF87814_Out_0, _Property_589C4301_Out_0, _Property_E9D88423_Out_0, _Property_366CB823_Out_0, _Property_1F5469F5_Out_0, _Property_920AF23F_Out_0, _Property_37F6AC84_Out_0, _Property_E7E25E74_Out_0, _Property_FA2913B0_Out_0, _CrestFlow_B4596B_DisplacedB_2, _Property_4E6AF5FF_Out_0, _Property_A2DA52BE_Out_0, _Property_9DE15AC9_Out_0, _CustomFunction_16EDEEAC_Albedo_8, _CustomFunction_16EDEEAC_NormalTS_7, _CustomFunction_16EDEEAC_Emission_9, _CustomFunction_16EDEEAC_Smoothness_10);
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_E9D68DEC_Out_0 = _CustomFunction_16EDEEAC_Albedo_8;
                #else
                float3 _FOAM_E9D68DEC_Out_0 = float3(0, 0, 0);
                #endif
                float3 _Multiply_BCF80692_Out_2;
                Unity_Multiply_float((_CrestFlow_B4596B_WeightB_4.xxx), _FOAM_E9D68DEC_Out_0, _Multiply_BCF80692_Out_2);
                float3 _Add_48FC5557_Out_2;
                Unity_Add_float3(_Multiply_278EF57C_Out_2, _Multiply_BCF80692_Out_2, _Add_48FC5557_Out_2);
                #if defined(CREST_FLOW_ON)
                float3 _FLOW_1260C700_Out_0 = _Add_48FC5557_Out_2;
                #else
                float3 _FLOW_1260C700_Out_0 = _FOAM_384819B4_Out_0;
                #endif
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_14E9F7C1_Out_0 = _CustomFunction_2B0D0960_NormalTS_7;
                #else
                float3 _FOAM_14E9F7C1_Out_0 = _Property_EB1DCAFB_Out_0;
                #endif
                float3 _Multiply_FAB0278F_Out_2;
                Unity_Multiply_float(_FOAM_14E9F7C1_Out_0, (_CrestFlow_B4596B_WeightA_3.xxx), _Multiply_FAB0278F_Out_2);
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_9C6E353_Out_0 = _CustomFunction_16EDEEAC_NormalTS_7;
                #else
                float3 _FOAM_9C6E353_Out_0 = _Property_4E6AF5FF_Out_0;
                #endif
                float3 _Multiply_CE1E9F74_Out_2;
                Unity_Multiply_float((_CrestFlow_B4596B_WeightB_4.xxx), _FOAM_9C6E353_Out_0, _Multiply_CE1E9F74_Out_2);
                float3 _Add_3A03EC0D_Out_2;
                Unity_Add_float3(_Multiply_FAB0278F_Out_2, _Multiply_CE1E9F74_Out_2, _Add_3A03EC0D_Out_2);
                #if defined(CREST_FLOW_ON)
                float3 _FLOW_2D8BA180_Out_0 = _Add_3A03EC0D_Out_2;
                #else
                float3 _FLOW_2D8BA180_Out_0 = _FOAM_14E9F7C1_Out_0;
                #endif
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_D8E821F0_Out_0 = _CustomFunction_2B0D0960_Emission_9;
                #else
                float3 _FOAM_D8E821F0_Out_0 = _Property_A2BD94BA_Out_0;
                #endif
                float3 _Multiply_716921DC_Out_2;
                Unity_Multiply_float(_FOAM_D8E821F0_Out_0, (_CrestFlow_B4596B_WeightA_3.xxx), _Multiply_716921DC_Out_2);
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_9468CE46_Out_0 = _CustomFunction_16EDEEAC_Emission_9;
                #else
                float3 _FOAM_9468CE46_Out_0 = _Property_A2DA52BE_Out_0;
                #endif
                float3 _Multiply_A0DE696C_Out_2;
                Unity_Multiply_float((_CrestFlow_B4596B_WeightB_4.xxx), _FOAM_9468CE46_Out_0, _Multiply_A0DE696C_Out_2);
                float3 _Add_2EBEBFCF_Out_2;
                Unity_Add_float3(_Multiply_716921DC_Out_2, _Multiply_A0DE696C_Out_2, _Add_2EBEBFCF_Out_2);
                #if defined(CREST_FLOW_ON)
                float3 _FLOW_225158E3_Out_0 = _Add_2EBEBFCF_Out_2;
                #else
                float3 _FLOW_225158E3_Out_0 = _FOAM_D8E821F0_Out_0;
                #endif
                #if defined(CREST_FOAM_ON)
                float _FOAM_F0F633C_Out_0 = _CustomFunction_2B0D0960_Smoothness_10;
                #else
                float _FOAM_F0F633C_Out_0 = _Property_7BFA2B51_Out_0;
                #endif
                float _Multiply_C03E7AFC_Out_2;
                Unity_Multiply_float(_FOAM_F0F633C_Out_0, _CrestFlow_B4596B_WeightA_3, _Multiply_C03E7AFC_Out_2);
                #if defined(CREST_FOAM_ON)
                float _FOAM_AB9E199D_Out_0 = _CustomFunction_16EDEEAC_Smoothness_10;
                #else
                float _FOAM_AB9E199D_Out_0 = _Property_9DE15AC9_Out_0;
                #endif
                float _Multiply_8F8BE539_Out_2;
                Unity_Multiply_float(_CrestFlow_B4596B_WeightB_4, _FOAM_AB9E199D_Out_0, _Multiply_8F8BE539_Out_2);
                float _Add_7629FC1B_Out_2;
                Unity_Add_float(_Multiply_C03E7AFC_Out_2, _Multiply_8F8BE539_Out_2, _Add_7629FC1B_Out_2);
                #if defined(CREST_FLOW_ON)
                float _FLOW_386EA56_Out_0 = _Add_7629FC1B_Out_2;
                #else
                float _FLOW_386EA56_Out_0 = _FOAM_F0F633C_Out_0;
                #endif
                Albedo_1 = _FLOW_1260C700_Out_0;
                NormalTS_2 = _FLOW_2D8BA180_Out_0;
                Emission_3 = _FLOW_225158E3_Out_0;
                Smoothness_4 = _FLOW_386EA56_Out_0;
            }
            
            void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
            {
                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            }
            
            struct Bindings_CrestOceanPixel_6f6706d805d8e8649adddaaa94260269
            {
                float3 WorldSpaceViewDirection;
                float3 ViewSpacePosition;
                float3 AbsoluteWorldSpacePosition;
                float4 ScreenPosition;
                float FaceSign;
            };
            
            void SG_CrestOceanPixel_6f6706d805d8e8649adddaaa94260269(TEXTURE2D_PARAM(Texture2D_BE500045, samplerTexture2D_BE500045), float4 Texture2D_BE500045_TexelSize, float2 Vector2_2F51BFFE, float Vector1_1CEB35D8, float Vector1_43921196, float Vector1_E301593B, float Vector1_958E8942, float Vector1_2ED4C943, float Vector1_BF3AF964, float3 Vector3_EEEBAAB5, float Vector1_D3410E3, float Vector1_1EC1FE35, float2 Vector2_9C73A0C6, float Vector1_B01E1A6A, float Vector1_D74C6609, float Vector1_B61034CA, float2 Vector2_AE8873FA, float2 Vector2_69CC43DC, float Vector1_255AB964, float Vector1_47308CC2, float Vector1_26549044, float Vector1_177E111C, float Vector1_33255829, TEXTURE2D_PARAM(Texture2D_40AB1455, samplerTexture2D_40AB1455), float4 Texture2D_40AB1455_TexelSize, float Vector1_23A72EC7, float Vector1_F406EE17, float4 Vector4_2F6E352, float3 Vector3_57B74D6A, float4 Vector4_B3AD63B4, float Vector1_FA688590, float Vector1_9835666E, float Vector1_B331E24E, float Vector1_951CF2DF, float4 Vector4_ADCA8891, float Vector1_2E8E2C59, float Vector1_9BD9C342, float3 Vector3_8228B74C, float3 Vector3_B2D6AD84, float3 Vector3_D2C93D25, TEXTURE2D_PARAM(Texture2D_EB8C8549, samplerTexture2D_EB8C8549), float4 Texture2D_EB8C8549_TexelSize, float Vector1_9AE39B77, half Vector1_1B073674, float Vector1_C885385, float Vector1_90CEE6B8, float Vector1_E27586E2, TEXTURE2D_PARAM(Texture2D_DA8A756A, samplerTexture2D_DA8A756A), float4 Texture2D_DA8A756A_TexelSize, float Vector1_C96A6500, float Vector1_1AD36684, float Vector1_9E87174F, float Vector1_80D0DF9E, Bindings_CrestOceanPixel_6f6706d805d8e8649adddaaa94260269 IN, out float3 Albedo_2, out float3 NormalTS_3, out float3 Emission_4, out float Smoothness_5, out float Alpha_1, out float Specular_6)
            {
                float2 _Property_B9BA8901_Out_0 = Vector2_2F51BFFE;
                float _Property_6AEC3552_Out_0 = Vector1_1CEB35D8;
                float _Property_76EA797B_Out_0 = Vector1_43921196;
                float _Property_83C2E998_Out_0 = Vector1_E301593B;
                float _Property_705FD8D9_Out_0 = Vector1_958E8942;
                float _Property_735B5A53_Out_0 = Vector1_2ED4C943;
                float _Property_EB4C03CF_Out_0 = Vector1_BF3AF964;
                Bindings_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d _CrestDrivenData_6635D6E9;
                half _CrestDrivenData_6635D6E9_MeshScaleAlpha_1;
                half _CrestDrivenData_6635D6E9_LodDataTexelSize_8;
                half _CrestDrivenData_6635D6E9_GeometryGridSize_2;
                half3 _CrestDrivenData_6635D6E9_OceanPosScale0_3;
                half3 _CrestDrivenData_6635D6E9_OceanPosScale1_4;
                half4 _CrestDrivenData_6635D6E9_OceanParams0_5;
                half4 _CrestDrivenData_6635D6E9_OceanParams1_6;
                half _CrestDrivenData_6635D6E9_SliceIndex0_7;
                SG_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d(_CrestDrivenData_6635D6E9, _CrestDrivenData_6635D6E9_MeshScaleAlpha_1, _CrestDrivenData_6635D6E9_LodDataTexelSize_8, _CrestDrivenData_6635D6E9_GeometryGridSize_2, _CrestDrivenData_6635D6E9_OceanPosScale0_3, _CrestDrivenData_6635D6E9_OceanPosScale1_4, _CrestDrivenData_6635D6E9_OceanParams0_5, _CrestDrivenData_6635D6E9_OceanParams1_6, _CrestDrivenData_6635D6E9_SliceIndex0_7);
                float _Property_EE920C2C_Out_0 = Vector1_B61034CA;
                float _Property_8BC6F5AD_Out_0 = Vector1_B01E1A6A;
                float2 _Property_A2CEB215_Out_0 = Vector2_9C73A0C6;
                float _Property_A636CE7E_Out_0 = Vector1_23A72EC7;
                float _Property_C1531E4C_Out_0 = Vector1_F406EE17;
                float _Property_C7723E93_Out_0 = Vector1_B01E1A6A;
                float2 _Property_94C56295_Out_0 = Vector2_9C73A0C6;
                float2 _Property_E65AA85_Out_0 = Vector2_69CC43DC;
                float3 _Normalize_3574419A_Out_1;
                Unity_Normalize_float3(IN.WorldSpaceViewDirection, _Normalize_3574419A_Out_1);
                Bindings_CrestComputeNormal_61b9efc6612ab3b4f84174344af5e12a _CrestComputeNormal_6DAE4B39;
                _CrestComputeNormal_6DAE4B39.FaceSign = IN.FaceSign;
                half3 _CrestComputeNormal_6DAE4B39_Normal_1;
                SG_CrestComputeNormal_61b9efc6612ab3b4f84174344af5e12a(_CrestDrivenData_6635D6E9_OceanPosScale0_3, _CrestDrivenData_6635D6E9_OceanPosScale1_4, _CrestDrivenData_6635D6E9_OceanParams0_5, _CrestDrivenData_6635D6E9_OceanParams1_6, _CrestDrivenData_6635D6E9_SliceIndex0_7, TEXTURE2D_ARGS(Texture2D_40AB1455, samplerTexture2D_40AB1455), Texture2D_40AB1455_TexelSize, _Property_A636CE7E_Out_0, _Property_C1531E4C_Out_0, _Property_C7723E93_Out_0, _Property_94C56295_Out_0, _Property_E65AA85_Out_0, _Normalize_3574419A_Out_1, _CrestComputeNormal_6DAE4B39, _CrestComputeNormal_6DAE4B39_Normal_1);
                float _Property_FCAEBD15_Out_0 = Vector1_9E87174F;
                float _Property_2D376CE_Out_0 = Vector1_80D0DF9E;
                Bindings_CrestFresnel_c6f6c13c4fdb04e42b427e4c2610d3c9 _CrestFresnel_FD3200EB;
                _CrestFresnel_FD3200EB.FaceSign = IN.FaceSign;
                float _CrestFresnel_FD3200EB_LightTransmitted_1;
                float _CrestFresnel_FD3200EB_LightReflected_2;
                SG_CrestFresnel_c6f6c13c4fdb04e42b427e4c2610d3c9(_CrestComputeNormal_6DAE4B39_Normal_1, _Normalize_3574419A_Out_1, _Property_FCAEBD15_Out_0, _Property_2D376CE_Out_0, _CrestFresnel_FD3200EB, _CrestFresnel_FD3200EB_LightTransmitted_1, _CrestFresnel_FD3200EB_LightReflected_2);
                float _Property_2599690E_Out_0 = Vector1_9BD9C342;
                float3 _Property_A57CAD6E_Out_0 = Vector3_8228B74C;
                float4 _Property_479D2E13_Out_0 = Vector4_2F6E352;
                float3 _Property_F631E4E0_Out_0 = Vector3_57B74D6A;
                float4 _Property_D9155CD7_Out_0 = Vector4_B3AD63B4;
                float _Property_D8B923AB_Out_0 = Vector1_FA688590;
                float _Property_F7F4791A_Out_0 = Vector1_9835666E;
                float _Property_2ABF6C61_Out_0 = Vector1_B331E24E;
                float _Property_22A5FA38_Out_0 = Vector1_951CF2DF;
                float4 _Property_C1E8071C_Out_0 = Vector4_ADCA8891;
                float _Property_9AD6466F_Out_0 = Vector1_2E8E2C59;
                float _Property_4D8B881_Out_0 = Vector1_D74C6609;
                float2 _Property_5A879B44_Out_0 = Vector2_AE8873FA;
                float _Property_41C453D9_Out_0 = Vector1_255AB964;
                float3 _CustomFunction_C3448D1A_AmbientLighting_0;
                GetAmbientLighting_float(_CustomFunction_C3448D1A_AmbientLighting_0);
                float3 _Property_13E6764D_Out_0 = Vector3_B2D6AD84;
                float3 _Property_2FA7DB0_Out_0 = Vector3_D2C93D25;
                Bindings_CrestVolumeLighting_e9ed6e11710a50640bb4b811d0fa84f2 _CrestVolumeLighting_5A1A391;
                half3 _CrestVolumeLighting_5A1A391_VolumeLighting_1;
                SG_CrestVolumeLighting_e9ed6e11710a50640bb4b811d0fa84f2(_Property_479D2E13_Out_0, _Property_F631E4E0_Out_0, _Property_D9155CD7_Out_0, _Property_D8B923AB_Out_0, _Property_F7F4791A_Out_0, _Property_2ABF6C61_Out_0, _Property_22A5FA38_Out_0, _Property_C1E8071C_Out_0, _Property_9AD6466F_Out_0, _Property_4D8B881_Out_0, _Property_5A879B44_Out_0, _Property_41C453D9_Out_0, _Normalize_3574419A_Out_1, IN.AbsoluteWorldSpacePosition, _CustomFunction_C3448D1A_AmbientLighting_0, _Property_13E6764D_Out_0, _Property_2FA7DB0_Out_0, _CrestVolumeLighting_5A1A391, _CrestVolumeLighting_5A1A391_VolumeLighting_1);
                float4 _ScreenPosition_42FE0E3E_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                float _Split_66230827_R_1 = IN.ViewSpacePosition[0];
                float _Split_66230827_G_2 = IN.ViewSpacePosition[1];
                float _Split_66230827_B_3 = IN.ViewSpacePosition[2];
                float _Split_66230827_A_4 = 0;
                float _Negate_5F3C7D3D_Out_1;
                Unity_Negate_float(_Split_66230827_B_3, _Negate_5F3C7D3D_Out_1);
                float3 _SceneColor_61626E7C_Out_1;
                Unity_SceneColor_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneColor_61626E7C_Out_1);
                float _SceneDepth_FD35F7D9_Out_1;
                Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_FD35F7D9_Out_1);
                float3 _Property_DC1C088D_Out_0 = Vector3_B2D6AD84;
                float _Property_8BC39E79_Out_0 = Vector1_9AE39B77;
                half _Property_683CAF2_Out_0 = Vector1_1B073674;
                float _Property_B4B35559_Out_0 = Vector1_C885385;
                float _Property_E694F888_Out_0 = Vector1_90CEE6B8;
                float _Property_50A87698_Out_0 = Vector1_E27586E2;
                float _Property_8BC9D755_Out_0 = Vector1_C96A6500;
                float _Property_6F95DFBF_Out_0 = Vector1_1AD36684;
                float3 _Property_4729CD24_Out_0 = Vector3_EEEBAAB5;
                float _Property_C36E9B6_Out_0 = Vector1_D3410E3;
                float _Property_2C173F60_Out_0 = Vector1_1EC1FE35;
                float2 _Property_4258AA49_Out_0 = Vector2_2F51BFFE;
                float _Property_3FC34BC9_Out_0 = Vector1_1CEB35D8;
                float _Property_D42BE95B_Out_0 = Vector1_B61034CA;
                float _Split_CEEBC462_R_1 = IN.AbsoluteWorldSpacePosition[0];
                float _Split_CEEBC462_G_2 = IN.AbsoluteWorldSpacePosition[1];
                float _Split_CEEBC462_B_3 = IN.AbsoluteWorldSpacePosition[2];
                float _Split_CEEBC462_A_4 = 0;
                float2 _Vector2_BB7CEEF5_Out_0 = float2(_Split_CEEBC462_R_1, _Split_CEEBC462_B_3);
                float2 _Property_305FB73_Out_0 = Vector2_9C73A0C6;
                float _Property_88A7570_Out_0 = Vector1_B01E1A6A;
                float2 _Property_5CBA815_Out_0 = Vector2_69CC43DC;
                Bindings_CrestFoamBubblesWithFlow_e132fba35874b4923988ef35a40e48c3 _CrestFoamBubblesWithFlow_F7286BE2;
                float3 _CrestFoamBubblesWithFlow_F7286BE2_Colour_1;
                SG_CrestFoamBubblesWithFlow_e132fba35874b4923988ef35a40e48c3(_Property_4729CD24_Out_0, _Property_C36E9B6_Out_0, _Property_2C173F60_Out_0, TEXTURE2D_ARGS(Texture2D_BE500045, samplerTexture2D_BE500045), Texture2D_BE500045_TexelSize, _Property_4258AA49_Out_0, _Property_3FC34BC9_Out_0, _Property_D42BE95B_Out_0, _CrestComputeNormal_6DAE4B39_Normal_1, _CrestDrivenData_6635D6E9_OceanParams0_5, _CrestDrivenData_6635D6E9_OceanParams1_6, _Vector2_BB7CEEF5_Out_0, _Property_305FB73_Out_0, _Property_88A7570_Out_0, _Normalize_3574419A_Out_1, _Property_5CBA815_Out_0, _CrestFoamBubblesWithFlow_F7286BE2, _CrestFoamBubblesWithFlow_F7286BE2_Colour_1);
                Bindings_CrestEmission_8c56460232fde1e46ae90d905a00f908 _CrestEmission_6580C0F9;
                float3 _CrestEmission_6580C0F9_EmittedLight_1;
                SG_CrestEmission_8c56460232fde1e46ae90d905a00f908(_Property_2599690E_Out_0, _Property_A57CAD6E_Out_0, _CrestVolumeLighting_5A1A391_VolumeLighting_1, _Normalize_3574419A_Out_1, _CrestComputeNormal_6DAE4B39_Normal_1, _ScreenPosition_42FE0E3E_Out_0, _Negate_5F3C7D3D_Out_1, _SceneColor_61626E7C_Out_1, _SceneDepth_FD35F7D9_Out_1, _Property_DC1C088D_Out_0, TEXTURE2D_ARGS(Texture2D_EB8C8549, samplerTexture2D_EB8C8549), Texture2D_EB8C8549_TexelSize, _Property_8BC39E79_Out_0, _Property_683CAF2_Out_0, _Property_B4B35559_Out_0, _Property_E694F888_Out_0, _Property_50A87698_Out_0, TEXTURE2D_ARGS(Texture2D_DA8A756A, samplerTexture2D_DA8A756A), Texture2D_DA8A756A_TexelSize, _Property_8BC9D755_Out_0, _Property_6F95DFBF_Out_0, _CrestFoamBubblesWithFlow_F7286BE2_Colour_1, _CrestEmission_6580C0F9, _CrestEmission_6580C0F9_EmittedLight_1);
                float3 _Multiply_CFF25F4B_Out_2;
                Unity_Multiply_float((_CrestFresnel_FD3200EB_LightTransmitted_1.xxx), _CrestEmission_6580C0F9_EmittedLight_1, _Multiply_CFF25F4B_Out_2);
                float _Property_5DA83C2A_Out_0 = Vector1_47308CC2;
                float _Property_44533AA4_Out_0 = Vector1_26549044;
                float _Property_19CC00AB_Out_0 = Vector1_177E111C;
                float _Divide_6B6C7F25_Out_2;
                Unity_Divide_float(_Negate_5F3C7D3D_Out_1, _Property_19CC00AB_Out_0, _Divide_6B6C7F25_Out_2);
                float _Saturate_D69CDED6_Out_1;
                Unity_Saturate_float(_Divide_6B6C7F25_Out_2, _Saturate_D69CDED6_Out_1);
                float _Property_8033277F_Out_0 = Vector1_33255829;
                float _Power_BC121A67_Out_2;
                Unity_Power_float(_Saturate_D69CDED6_Out_1, _Property_8033277F_Out_0, _Power_BC121A67_Out_2);
                float _Lerp_3E7590A8_Out_3;
                Unity_Lerp_float(_Property_5DA83C2A_Out_0, _Property_44533AA4_Out_0, _Power_BC121A67_Out_2, _Lerp_3E7590A8_Out_3);
                float2 _Property_374C5B7E_Out_0 = Vector2_69CC43DC;
                Bindings_CrestFoamWithFlow_3a6c22dceac0847a2a31cb05a577b963 _CrestFoamWithFlow_193F69CA;
                float3 _CrestFoamWithFlow_193F69CA_Albedo_1;
                float3 _CrestFoamWithFlow_193F69CA_NormalTS_2;
                float3 _CrestFoamWithFlow_193F69CA_Emission_3;
                float _CrestFoamWithFlow_193F69CA_Smoothness_4;
                SG_CrestFoamWithFlow_3a6c22dceac0847a2a31cb05a577b963(TEXTURE2D_ARGS(Texture2D_BE500045, samplerTexture2D_BE500045), Texture2D_BE500045_TexelSize, _Property_B9BA8901_Out_0, _Property_6AEC3552_Out_0, _Property_76EA797B_Out_0, _Property_83C2E998_Out_0, _Property_705FD8D9_Out_0, _Property_735B5A53_Out_0, _Property_EB4C03CF_Out_0, _CrestDrivenData_6635D6E9_OceanParams0_5, _CrestDrivenData_6635D6E9_OceanParams1_6, _Property_EE920C2C_Out_0, _Property_8BC6F5AD_Out_0, _Property_A2CEB215_Out_0, _CrestComputeNormal_6DAE4B39_Normal_1, _Multiply_CFF25F4B_Out_2, _Lerp_3E7590A8_Out_3, _Property_374C5B7E_Out_0, _CrestFoamWithFlow_193F69CA, _CrestFoamWithFlow_193F69CA_Albedo_1, _CrestFoamWithFlow_193F69CA_NormalTS_2, _CrestFoamWithFlow_193F69CA_Emission_3, _CrestFoamWithFlow_193F69CA_Smoothness_4);
                float _Subtract_5BDB5822_Out_2;
                Unity_Subtract_float(_SceneDepth_FD35F7D9_Out_1, _Negate_5F3C7D3D_Out_1, _Subtract_5BDB5822_Out_2);
                float _Remap_D52CFDA9_Out_3;
                Unity_Remap_float(_Subtract_5BDB5822_Out_2, float2 (0, 0.2), float2 (0, 1), _Remap_D52CFDA9_Out_3);
                float _Saturate_896FB384_Out_1;
                Unity_Saturate_float(_Remap_D52CFDA9_Out_3, _Saturate_896FB384_Out_1);
                Albedo_2 = _CrestFoamWithFlow_193F69CA_Albedo_1;
                NormalTS_3 = _CrestFoamWithFlow_193F69CA_NormalTS_2;
                Emission_4 = _CrestFoamWithFlow_193F69CA_Emission_3;
                Smoothness_5 = _CrestFoamWithFlow_193F69CA_Smoothness_4;
                Alpha_1 = _Saturate_896FB384_Out_1;
                Specular_6 = _CrestFresnel_FD3200EB_LightReflected_2;
            }
        
            // Graph Vertex
            struct VertexDescriptionInputs
            {
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 WorldSpaceNormal;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 WorldSpaceTangent;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 ObjectSpaceBiTangent;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 WorldSpaceBiTangent;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 AbsoluteWorldSpacePosition;
                #endif
            };
            
            struct VertexDescription
            {
                float3 VertexPosition;
                float3 VertexNormal;
                float3 VertexTangent;

                // Crest -------------------
                float LodAlpha;
                float2 WorldXZUndisplaced;
                half OceanDepth;
                half Foam;
                half2 Shadow;
                half2 Flow;
                half SSS;
                // -------------------------
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                Bindings_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d _CrestDrivenData_A1078169;
                half _CrestDrivenData_A1078169_MeshScaleAlpha_1;
                half _CrestDrivenData_A1078169_LodDataTexelSize_8;
                half _CrestDrivenData_A1078169_GeometryGridSize_2;
                half3 _CrestDrivenData_A1078169_OceanPosScale0_3;
                half3 _CrestDrivenData_A1078169_OceanPosScale1_4;
                half4 _CrestDrivenData_A1078169_OceanParams0_5;
                half4 _CrestDrivenData_A1078169_OceanParams1_6;
                half _CrestDrivenData_A1078169_SliceIndex0_7;
                SG_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d(_CrestDrivenData_A1078169, _CrestDrivenData_A1078169_MeshScaleAlpha_1, _CrestDrivenData_A1078169_LodDataTexelSize_8, _CrestDrivenData_A1078169_GeometryGridSize_2, _CrestDrivenData_A1078169_OceanPosScale0_3, _CrestDrivenData_A1078169_OceanPosScale1_4, _CrestDrivenData_A1078169_OceanParams0_5, _CrestDrivenData_A1078169_OceanParams1_6, _CrestDrivenData_A1078169_SliceIndex0_7);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                Bindings_CrestGeoMorph_9ab91ec3462438049923ca0ff16f68ad _CrestGeoMorph_8F1A4FF1;
                half3 _CrestGeoMorph_8F1A4FF1_MorphedPositionWS_1;
                half _CrestGeoMorph_8F1A4FF1_LodAlpha_2;
                SG_CrestGeoMorph_9ab91ec3462438049923ca0ff16f68ad(IN.AbsoluteWorldSpacePosition, _CrestDrivenData_A1078169_OceanPosScale0_3, _CrestDrivenData_A1078169_MeshScaleAlpha_1, _CrestDrivenData_A1078169_GeometryGridSize_2, _CrestGeoMorph_8F1A4FF1, _CrestGeoMorph_8F1A4FF1_MorphedPositionWS_1, _CrestGeoMorph_8F1A4FF1_LodAlpha_2);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Split_CC063A43_R_1 = _CrestGeoMorph_8F1A4FF1_MorphedPositionWS_1[0];
                float _Split_CC063A43_G_2 = _CrestGeoMorph_8F1A4FF1_MorphedPositionWS_1[1];
                float _Split_CC063A43_B_3 = _CrestGeoMorph_8F1A4FF1_MorphedPositionWS_1[2];
                float _Split_CC063A43_A_4 = 0;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float2 _Vector2_2D46FD43_Out_0 = float2(_Split_CC063A43_R_1, _Split_CC063A43_B_3);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                Bindings_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4 _CrestSampleOceanData_340A6610;
                float3 _CrestSampleOceanData_340A6610_Displacement_1;
                float _CrestSampleOceanData_340A6610_OceanWaterDepth_5;
                float _CrestSampleOceanData_340A6610_Foam_6;
                float2 _CrestSampleOceanData_340A6610_Shadow_7;
                float2 _CrestSampleOceanData_340A6610_Flow_8;
                float _CrestSampleOceanData_340A6610_SubSurfaceScattering_9;
                SG_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4(_Vector2_2D46FD43_Out_0, _CrestGeoMorph_8F1A4FF1_LodAlpha_2, _CrestDrivenData_A1078169_OceanPosScale0_3, _CrestDrivenData_A1078169_OceanPosScale1_4, _CrestDrivenData_A1078169_OceanParams0_5, _CrestDrivenData_A1078169_OceanParams1_6, _CrestDrivenData_A1078169_SliceIndex0_7, _CrestSampleOceanData_340A6610, _CrestSampleOceanData_340A6610_Displacement_1, _CrestSampleOceanData_340A6610_OceanWaterDepth_5, _CrestSampleOceanData_340A6610_Foam_6, _CrestSampleOceanData_340A6610_Shadow_7, _CrestSampleOceanData_340A6610_Flow_8, _CrestSampleOceanData_340A6610_SubSurfaceScattering_9);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 _Add_2D79A354_Out_2;
                Unity_Add_float3(_CrestGeoMorph_8F1A4FF1_MorphedPositionWS_1, _CrestSampleOceanData_340A6610_Displacement_1, _Add_2D79A354_Out_2);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 _Transform_9C2ACF28_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Add_2D79A354_Out_2.xyz));
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 _Transform_86205EE4_Out_1 = TransformWorldToObjectDir(float3 (0, 1, 0).xyz);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 _Transform_22BD1A85_Out_1 = TransformWorldToObjectDir(GetCameraRelativePositionWS(float3 (1, 0, 0).xyz));
                #endif
                description.VertexPosition = _Transform_9C2ACF28_Out_1;
                description.VertexNormal = _Transform_86205EE4_Out_1;
                description.VertexTangent = _Transform_22BD1A85_Out_1;

                // Crest -------------------
                description.LodAlpha = _CrestGeoMorph_8F1A4FF1_LodAlpha_2;
                description.WorldXZUndisplaced = _Vector2_2D46FD43_Out_0;
                description.OceanDepth = _CrestSampleOceanData_340A6610_OceanWaterDepth_5;
                description.Foam = _CrestSampleOceanData_340A6610_Foam_6;
                description.Shadow = _CrestSampleOceanData_340A6610_Shadow_7;
                description.Flow = _CrestSampleOceanData_340A6610_Flow_8;
                description.SSS = _CrestSampleOceanData_340A6610_SubSurfaceScattering_9;
                // -------------------------

                return description;
            }
            
            // Graph Pixel
            struct SurfaceDescriptionInputs
            {
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 WorldSpaceViewDirection;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 ViewSpacePosition;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 WorldSpacePosition;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 AbsoluteWorldSpacePosition;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 ScreenPosition;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv0;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv1;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv2;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv3;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float FaceSign;
                #endif
            };
            
            struct SurfaceDescription
            {
                float3 Albedo;
                float3 Normal;
                float3 Emission;
                float3 Specular;
                float Smoothness;
                float Occlusion;
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _TexelSize_CA3A0DD6_Width_0 = _TextureFoam_TexelSize.z;
                half _TexelSize_CA3A0DD6_Height_2 = _TextureFoam_TexelSize.w;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half2 _Vector2_15E252FB_Out_0 = half2(_TexelSize_CA3A0DD6_Width_0, _TexelSize_CA3A0DD6_Height_2);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_87E9391A_Out_0 = _FoamScale;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_BC30BCB6_Out_0 = _FoamFeather;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_5E8CB038_Out_0 = _FoamIntensityAlbedo;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_77A524C7_Out_0 = _FoamIntensityEmissive;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_CED296A4_Out_0 = _FoamSmoothness;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_D1CA3C84_Out_0 = _FoamNormalStrength;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half4 _Property_3BAB5FF_Out_0 = _FoamBubbleColor;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_EDC4DC3C_Out_0 = _FoamBubbleParallax;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_E7925FBA_Out_0 = _FoamBubblesCoverage;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                Bindings_CrestUnpackData_5bc4cf08f88035c489658d60edefeec8 _CrestUnpackData_C3998C1C;
                _CrestUnpackData_C3998C1C.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
                _CrestUnpackData_C3998C1C.uv0 = IN.uv0;
                _CrestUnpackData_C3998C1C.uv1 = IN.uv1;
                _CrestUnpackData_C3998C1C.uv2 = IN.uv2;
                float2 _CrestUnpackData_C3998C1C_PositionXZWSUndisp_2;
                float _CrestUnpackData_C3998C1C_LodAlpha_1;
                float _CrestUnpackData_C3998C1C_OceanDepth_3;
                float _CrestUnpackData_C3998C1C_Foam_4;
                float2 _CrestUnpackData_C3998C1C_Shadow_5;
                float2 _CrestUnpackData_C3998C1C_Flow_6;
                float _CrestUnpackData_C3998C1C_SubSurfaceScattering_7;
                SG_CrestUnpackData_5bc4cf08f88035c489658d60edefeec8(_CrestUnpackData_C3998C1C, _CrestUnpackData_C3998C1C_PositionXZWSUndisp_2, _CrestUnpackData_C3998C1C_LodAlpha_1, _CrestUnpackData_C3998C1C_OceanDepth_3, _CrestUnpackData_C3998C1C_Foam_4, _CrestUnpackData_C3998C1C_Shadow_5, _CrestUnpackData_C3998C1C_Flow_6, _CrestUnpackData_C3998C1C_SubSurfaceScattering_7);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_994CB3A3_Out_0 = _Smoothness;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_7079FD32_Out_0 = _SmoothnessFar;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_FAEF961B_Out_0 = _SmoothnessFarDistance;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_35DA1E70_Out_0 = _SmoothnessFalloff;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_D1430252_Out_0 = _NormalsScale;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_B882DB1E_Out_0 = _NormalsStrength;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half4 _Property_B5E474DF_Out_0 = _ScatterColourBase;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 _Property_B98AE6FA_Out_0 = _ScatterColourShallow;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_CF7CEF3A_Out_0 = _ScatterColourShallowDepthMax;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_698A3C81_Out_0 = _ScatterColourShallowDepthFalloff;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_5924F1E9_Out_0 = _SSSIntensityBase;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_67308B5F_Out_0 = _SSSIntensitySun;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half4 _Property_A723E757_Out_0 = _SSSTint;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_5AD6818A_Out_0 = _SSSSunFalloff;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_888FA49_Out_0 = _RefractionStrength;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half3 _Property_F1315B19_Out_0 = _DepthFogDensity;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                Bindings_CrestLightData_b74b6e8c0b489314ca7aea3e2cc9c54c _CrestLightData_5AD806DD;
                half3 _CrestLightData_5AD806DD_Direction_1;
                half3 _CrestLightData_5AD806DD_Intensity_2;
                SG_CrestLightData_b74b6e8c0b489314ca7aea3e2cc9c54c(_CrestLightData_5AD806DD, _CrestLightData_5AD806DD_Direction_1, _CrestLightData_5AD806DD_Intensity_2);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_A26763AB_Out_0 = _CausticsTextureScale;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_3230CB90_Out_0 = _CausticsTextureAverage;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_6B2F7D3E_Out_0 = _CausticsStrength;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_D5C90779_Out_0 = _CausticsFocalDepth;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_2743B36F_Out_0 = _CausticsDepthOfField;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_61877218_Out_0 = _CausticsDistortionStrength;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_5F1E3794_Out_0 = _CausticsDistortionScale;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                Bindings_CrestOceanPixel_6f6706d805d8e8649adddaaa94260269 _CrestOceanPixel_51593A7C;
                _CrestOceanPixel_51593A7C.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
                _CrestOceanPixel_51593A7C.ViewSpacePosition = IN.ViewSpacePosition;
                _CrestOceanPixel_51593A7C.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
                _CrestOceanPixel_51593A7C.ScreenPosition = IN.ScreenPosition;
                _CrestOceanPixel_51593A7C.FaceSign = IN.FaceSign;
                float3 _CrestOceanPixel_51593A7C_Albedo_2;
                float3 _CrestOceanPixel_51593A7C_NormalTS_3;
                float3 _CrestOceanPixel_51593A7C_Emission_4;
                float _CrestOceanPixel_51593A7C_Smoothness_5;
                float _CrestOceanPixel_51593A7C_Alpha_1;
                float _CrestOceanPixel_51593A7C_Specular_6;
                SG_CrestOceanPixel_6f6706d805d8e8649adddaaa94260269(TEXTURE2D_ARGS(_TextureFoam, sampler_TextureFoam), _TextureFoam_TexelSize, _Vector2_15E252FB_Out_0, _Property_87E9391A_Out_0, _Property_BC30BCB6_Out_0, _Property_5E8CB038_Out_0, _Property_77A524C7_Out_0, _Property_CED296A4_Out_0, _Property_D1CA3C84_Out_0, (_Property_3BAB5FF_Out_0.xyz), _Property_EDC4DC3C_Out_0, _Property_E7925FBA_Out_0, _CrestUnpackData_C3998C1C_PositionXZWSUndisp_2, _CrestUnpackData_C3998C1C_LodAlpha_1, _CrestUnpackData_C3998C1C_OceanDepth_3, _CrestUnpackData_C3998C1C_Foam_4, _CrestUnpackData_C3998C1C_Shadow_5, _CrestUnpackData_C3998C1C_Flow_6, _CrestUnpackData_C3998C1C_SubSurfaceScattering_7, _Property_994CB3A3_Out_0, _Property_7079FD32_Out_0, _Property_FAEF961B_Out_0, _Property_35DA1E70_Out_0, TEXTURE2D_ARGS(_TextureNormals, sampler_TextureNormals), _TextureNormals_TexelSize, _Property_D1430252_Out_0, _Property_B882DB1E_Out_0, _Property_B5E474DF_Out_0, float3 (0, 0, 0), _Property_B98AE6FA_Out_0, _Property_CF7CEF3A_Out_0, _Property_698A3C81_Out_0, _Property_5924F1E9_Out_0, _Property_67308B5F_Out_0, _Property_A723E757_Out_0, _Property_5AD6818A_Out_0, _Property_888FA49_Out_0, _Property_F1315B19_Out_0, _CrestLightData_5AD806DD_Direction_1, _CrestLightData_5AD806DD_Intensity_2, TEXTURE2D_ARGS(_CausticsTexture, sampler_CausticsTexture), _CausticsTexture_TexelSize, _Property_A26763AB_Out_0, _Property_3230CB90_Out_0, _Property_6B2F7D3E_Out_0, _Property_D5C90779_Out_0, _Property_2743B36F_Out_0, TEXTURE2D_ARGS(_CausticsDistortionTexture, sampler_CausticsDistortionTexture), _CausticsDistortionTexture_TexelSize, _Property_61877218_Out_0, _Property_5F1E3794_Out_0, 1.33, 1, _CrestOceanPixel_51593A7C, _CrestOceanPixel_51593A7C_Albedo_2, _CrestOceanPixel_51593A7C_NormalTS_3, _CrestOceanPixel_51593A7C_Emission_4, _CrestOceanPixel_51593A7C_Smoothness_5, _CrestOceanPixel_51593A7C_Alpha_1, _CrestOceanPixel_51593A7C_Specular_6);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_A3329432_Out_0 = _Specular;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Multiply_E01A7830_Out_2;
                Unity_Multiply_float(_Property_A3329432_Out_0, _CrestOceanPixel_51593A7C_Specular_6, _Multiply_E01A7830_Out_2);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_E132C977_Out_0 = _Occlusion;
                #endif
                surface.Albedo = _CrestOceanPixel_51593A7C_Albedo_2;
                surface.Normal = _CrestOceanPixel_51593A7C_NormalTS_3;
                surface.Emission = _CrestOceanPixel_51593A7C_Emission_4;
                surface.Specular = (_Multiply_E01A7830_Out_2.xxx);
                surface.Smoothness = _CrestOceanPixel_51593A7C_Smoothness_5;
                surface.Occlusion = _Property_E132C977_Out_0;
                surface.Alpha = _CrestOceanPixel_51593A7C_Alpha_1;
                surface.AlphaClipThreshold = 0;
                return surface;
            }
        
            // --------------------------------------------------
            // Structs and Packing
        
            // Generated Type: Attributes
            struct Attributes
            {
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 positionOS : POSITION;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 normalOS : NORMAL;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 tangentOS : TANGENT;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv0 : TEXCOORD0;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv1 : TEXCOORD1;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv2 : TEXCOORD2;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv3 : TEXCOORD3;
                #endif
                #if UNITY_ANY_INSTANCING_ENABLED
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                uint instanceID : INSTANCEID_SEMANTIC;
                #endif
                #endif
            };
        
            // Generated Type: Varyings
            struct Varyings
            {
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 positionCS : SV_Position;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 positionWS;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 normalWS;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 tangentWS;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 texCoord0;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 texCoord1;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 texCoord2;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 texCoord3;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 viewDirectionWS;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 bitangentWS;
                #endif
                #if defined(LIGHTMAP_ON)
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float2 lightmapUV;
                #endif
                #endif
                #if !defined(LIGHTMAP_ON)
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 sh;
                #endif
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 fogFactorAndVertexLight;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 shadowCoord;
                #endif
                #if UNITY_ANY_INSTANCING_ENABLED
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #endif
            };
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            // Generated Type: PackedVaryings
            struct PackedVaryings
            {
                float4 positionCS : SV_Position;
                #if defined(LIGHTMAP_ON)
                #endif
                #if !defined(LIGHTMAP_ON)
                #endif
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                float3 interp00 : TEXCOORD0;
                float3 interp01 : TEXCOORD1;
                float4 interp02 : TEXCOORD2;
                float4 interp03 : TEXCOORD3;
                float4 interp04 : TEXCOORD4;
                float4 interp05 : TEXCOORD5;
                float4 interp06 : TEXCOORD6;
                float3 interp07 : TEXCOORD7;
                float3 interp08 : TEXCOORD8;
                float2 interp09 : TEXCOORD9;
                float3 interp10 : TEXCOORD10;
                float4 interp11 : TEXCOORD11;
                float4 interp12 : TEXCOORD12;
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Packed Type: Varyings
            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output;
                output.positionCS = input.positionCS;
                output.interp00.xyz = input.positionWS;
                output.interp01.xyz = input.normalWS;
                output.interp02.xyzw = input.tangentWS;
                output.interp03.xyzw = input.texCoord0;
                output.interp04.xyzw = input.texCoord1;
                output.interp05.xyzw = input.texCoord2;
                output.interp06.xyzw = input.texCoord3;
                output.interp07.xyz = input.viewDirectionWS;
                output.interp08.xyz = input.bitangentWS;
                #if defined(LIGHTMAP_ON)
                output.interp09.xy = input.lightmapUV;
                #endif
                #if !defined(LIGHTMAP_ON)
                output.interp10.xyz = input.sh;
                #endif
                output.interp11.xyzw = input.fogFactorAndVertexLight;
                output.interp12.xyzw = input.shadowCoord;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                return output;
            }
            
            // Unpacked Type: Varyings
            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.positionWS = input.interp00.xyz;
                output.normalWS = input.interp01.xyz;
                output.tangentWS = input.interp02.xyzw;
                output.texCoord0 = input.interp03.xyzw;
                output.texCoord1 = input.interp04.xyzw;
                output.texCoord2 = input.interp05.xyzw;
                output.texCoord3 = input.interp06.xyzw;
                output.viewDirectionWS = input.interp07.xyz;
                output.bitangentWS = input.interp08.xyz;
                #if defined(LIGHTMAP_ON)
                output.lightmapUV = input.interp09.xy;
                #endif
                #if !defined(LIGHTMAP_ON)
                output.sh = input.interp10.xyz;
                #endif
                output.fogFactorAndVertexLight = input.interp11.xyzw;
                output.shadowCoord = input.interp12.xyzw;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                return output;
            }
            #endif
        
            // --------------------------------------------------
            // Build Graph Inputs
        
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            #endif
            
            
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
            #endif
            
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS.xyz, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
            #endif
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
            #endif
            
            
            
            
            
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
            #endif
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
                return output;
            }
            
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            
            
            
            
            
            
            
            
            
            
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            #endif
            
            
            
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.WorldSpacePosition =          input.positionWS;
            #endif
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.ViewSpacePosition =           TransformWorldToView(input.positionWS);
            #endif
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(input.positionWS);
            #endif
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            #endif
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.uv0 =                         input.texCoord0;
            #endif
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.uv1 =                         input.texCoord1;
            #endif
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.uv2 =                         input.texCoord2;
            #endif
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.uv3 =                         input.texCoord3;
            #endif
            
            
            
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                return output;
            }
            
        
            // --------------------------------------------------
            // Main
        
            // Crest -------------------
            #include "CrestVaryingsURP.hlsl"
            // -------------------------
            //#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
            ENDHLSL
        }

		/*
        Pass
        {
            Name "ShadowCaster"
            Tags 
            { 
                "LightMode" = "ShadowCaster"
            }
           
            // Render State
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            Cull Off
            ZTest LEqual
            ZWrite On
            // ColorMask: <None>
        
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
        
            // Debug
            // <None>
        
            // --------------------------------------------------
            // Pass
        
            // Pragmas
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            #pragma multi_compile_instancing
        
            // Keywords
            // PassKeywords: <None>
            #pragma shader_feature_local _ CREST_FOAM_ON
            #pragma shader_feature_local _ CREST_CAUSTICS_ON
            #pragma shader_feature_local _ CREST_FLOW_ON
            
            #if defined(CREST_FOAM_ON) && defined(CREST_CAUSTICS_ON) && defined(CREST_FLOW_ON)
                #define KEYWORD_PERMUTATION_0
            #elif defined(CREST_FOAM_ON) && defined(CREST_CAUSTICS_ON)
                #define KEYWORD_PERMUTATION_1
            #elif defined(CREST_FOAM_ON) && defined(CREST_FLOW_ON)
                #define KEYWORD_PERMUTATION_2
            #elif defined(CREST_FOAM_ON)
                #define KEYWORD_PERMUTATION_3
            #elif defined(CREST_CAUSTICS_ON) && defined(CREST_FLOW_ON)
                #define KEYWORD_PERMUTATION_4
            #elif defined(CREST_CAUSTICS_ON)
                #define KEYWORD_PERMUTATION_5
            #elif defined(CREST_FLOW_ON)
                #define KEYWORD_PERMUTATION_6
            #else
                #define KEYWORD_PERMUTATION_7
            #endif
            
            
            // Defines
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define _SURFACE_TYPE_TRANSPARENT 1
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define _NORMALMAP 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define _SPECULAR_SETUP
        #endif
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD2
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD3
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_POSITION_WS 
        #endif
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD2
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD3
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #endif
        
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_CULLFACE
        #endif
        
            #define FEATURES_GRAPH_VERTEX
            #define SHADERPASS_SHADOWCASTER
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #define REQUIRE_DEPTH_TEXTURE
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #define REQUIRE_OPAQUE_TEXTURE
            #endif
        
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
            // --------------------------------------------------
            // Graph
        
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            half _Smoothness;
            float _SmoothnessFar;
            float _SmoothnessFarDistance;
            float _SmoothnessFalloff;
            float _Specular;
            float _Occlusion;
            half4 _ScatterColourBase;
            float4 _ScatterColourShallow;
            half _ScatterColourShallowDepthMax;
            half _ScatterColourShallowDepthFalloff;
            half _NormalsScale;
            half _NormalsStrength;
            half _SSSIntensityBase;
            half _SSSIntensitySun;
            half4 _SSSTint;
            half _SSSSunFalloff;
            half _RefractionStrength;
            half3 _DepthFogDensity;
            half _FoamScale;
            half _FoamFeather;
            half _FoamIntensityAlbedo;
            half _FoamIntensityEmissive;
            half _FoamSmoothness;
            half _FoamNormalStrength;
            half4 _FoamBubbleColor;
            half _FoamBubbleParallax;
            half _FoamBubblesCoverage;
            float _CausticsTextureScale;
            float _CausticsTextureAverage;
            float _CausticsStrength;
            float _CausticsFocalDepth;
            float _CausticsDepthOfField;
            float _CausticsDistortionStrength;
            float _CausticsDistortionScale;
            CBUFFER_END
            TEXTURE2D(_TextureNormals); SAMPLER(sampler_TextureNormals); float4 _TextureNormals_TexelSize;
            TEXTURE2D(_TextureFoam); SAMPLER(sampler_TextureFoam); half4 _TextureFoam_TexelSize;
            TEXTURE2D(_CausticsTexture); SAMPLER(sampler_CausticsTexture); float4 _CausticsTexture_TexelSize;
            TEXTURE2D(_CausticsDistortionTexture); SAMPLER(sampler_CausticsDistortionTexture); float4 _CausticsDistortionTexture_TexelSize;
            SAMPLER(SamplerState_Linear_Repeat);
        
            // Graph Functions
            
            // dc55dc563cc13ab0a4a38f335aac9cb2
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeDrivenInputs.hlsl"
            
            struct Bindings_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d
            {
            };
            
            void SG_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d(Bindings_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d IN, out half MeshScaleAlpha_1, out half LodDataTexelSize_8, out half GeometryGridSize_2, out half3 OceanPosScale0_3, out half3 OceanPosScale1_4, out half4 OceanParams0_5, out half4 OceanParams1_6, out half SliceIndex0_7)
            {
                half _CustomFunction_CD9A5F8F_MeshScaleAlpha_9;
                half _CustomFunction_CD9A5F8F_LodDataTexelSize_10;
                half _CustomFunction_CD9A5F8F_GeometryGridSize_14;
                half3 _CustomFunction_CD9A5F8F_OceanPosScale0_7;
                half3 _CustomFunction_CD9A5F8F_OceanPosScale1_8;
                half4 _CustomFunction_CD9A5F8F_OceanParams0_11;
                half4 _CustomFunction_CD9A5F8F_OceanParams1_12;
                half _CustomFunction_CD9A5F8F_SliceIndex0_13;
                CrestOceanSurfaceValues_half(_CustomFunction_CD9A5F8F_MeshScaleAlpha_9, _CustomFunction_CD9A5F8F_LodDataTexelSize_10, _CustomFunction_CD9A5F8F_GeometryGridSize_14, _CustomFunction_CD9A5F8F_OceanPosScale0_7, _CustomFunction_CD9A5F8F_OceanPosScale1_8, _CustomFunction_CD9A5F8F_OceanParams0_11, _CustomFunction_CD9A5F8F_OceanParams1_12, _CustomFunction_CD9A5F8F_SliceIndex0_13);
                MeshScaleAlpha_1 = _CustomFunction_CD9A5F8F_MeshScaleAlpha_9;
                LodDataTexelSize_8 = _CustomFunction_CD9A5F8F_LodDataTexelSize_10;
                GeometryGridSize_2 = _CustomFunction_CD9A5F8F_GeometryGridSize_14;
                OceanPosScale0_3 = _CustomFunction_CD9A5F8F_OceanPosScale0_7;
                OceanPosScale1_4 = _CustomFunction_CD9A5F8F_OceanPosScale1_8;
                OceanParams0_5 = _CustomFunction_CD9A5F8F_OceanParams0_11;
                OceanParams1_6 = _CustomFunction_CD9A5F8F_OceanParams1_12;
                SliceIndex0_7 = _CustomFunction_CD9A5F8F_SliceIndex0_13;
            }
            
            // 0749fb83929f8caedf1bd96120cd0442
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeGeoMorph.hlsl"
            
            struct Bindings_CrestGeoMorph_9ab91ec3462438049923ca0ff16f68ad
            {
            };
            
            void SG_CrestGeoMorph_9ab91ec3462438049923ca0ff16f68ad(float3 Vector3_28A0F264, float3 Vector3_F1111B56, float Vector1_691AFD6A, float Vector1_37DEE8F3, Bindings_CrestGeoMorph_9ab91ec3462438049923ca0ff16f68ad IN, out half3 MorphedPositionWS_1, out half LodAlpha_2)
            {
                float3 _Property_C4B6B1D5_Out_0 = Vector3_28A0F264;
                float3 _Property_13BC6D1A_Out_0 = Vector3_F1111B56;
                float _Property_DE4BC103_Out_0 = Vector1_691AFD6A;
                float _Property_B3D2A4DF_Out_0 = Vector1_37DEE8F3;
                half3 _CustomFunction_C8F1D6C4_MorphedPositionWS_4;
                half _CustomFunction_C8F1D6C4_LodAlpha_5;
                GeoMorph_half(_Property_C4B6B1D5_Out_0, _Property_13BC6D1A_Out_0, _Property_DE4BC103_Out_0, _Property_B3D2A4DF_Out_0, _CustomFunction_C8F1D6C4_MorphedPositionWS_4, _CustomFunction_C8F1D6C4_LodAlpha_5);
                MorphedPositionWS_1 = _CustomFunction_C8F1D6C4_MorphedPositionWS_4;
                LodAlpha_2 = _CustomFunction_C8F1D6C4_LodAlpha_5;
            }
            
            // 280776a3899d7788e7b68f32405fa944
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeSampleOceanData.hlsl"
            
            struct Bindings_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4
            {
            };
            
            void SG_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4(float2 Vector2_3171933F, float Vector1_CD41515B, float3 Vector3_7E91D336, float3 Vector3_3A95DCDF, float4 Vector4_C0B2B5EA, float4 Vector4_9C46108E, float Vector1_8EA8B92B, Bindings_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4 IN, out float3 Displacement_1, out float OceanWaterDepth_5, out float Foam_6, out float2 Shadow_7, out float2 Flow_8, out float SubSurfaceScattering_9)
            {
                float2 _Property_1A287CC6_Out_0 = Vector2_3171933F;
                float _Property_2D1D1700_Out_0 = Vector1_CD41515B;
                float3 _Property_C925A867_Out_0 = Vector3_7E91D336;
                float3 _Property_6C273401_Out_0 = Vector3_3A95DCDF;
                float4 _Property_467D1BE7_Out_0 = Vector4_C0B2B5EA;
                float4 _Property_4E045F45_Out_0 = Vector4_9C46108E;
                float _Property_59E019ED_Out_0 = Vector1_8EA8B92B;
                float3 _CustomFunction_487C31E1_Displacement_3;
                float _CustomFunction_487C31E1_OceanDepth_8;
                float _CustomFunction_487C31E1_Foam_4;
                float2 _CustomFunction_487C31E1_Shadow_5;
                float2 _CustomFunction_487C31E1_Flow_6;
                float _CustomFunction_487C31E1_SSS_17;
                CrestNodeSampleOceanData_float(_Property_1A287CC6_Out_0, _Property_2D1D1700_Out_0, _Property_C925A867_Out_0, _Property_6C273401_Out_0, _Property_467D1BE7_Out_0, _Property_4E045F45_Out_0, _Property_59E019ED_Out_0, _CustomFunction_487C31E1_Displacement_3, _CustomFunction_487C31E1_OceanDepth_8, _CustomFunction_487C31E1_Foam_4, _CustomFunction_487C31E1_Shadow_5, _CustomFunction_487C31E1_Flow_6, _CustomFunction_487C31E1_SSS_17);
                Displacement_1 = _CustomFunction_487C31E1_Displacement_3;
                OceanWaterDepth_5 = _CustomFunction_487C31E1_OceanDepth_8;
                Foam_6 = _CustomFunction_487C31E1_Foam_4;
                Shadow_7 = _CustomFunction_487C31E1_Shadow_5;
                Flow_8 = _CustomFunction_487C31E1_Flow_6;
                SubSurfaceScattering_9 = _CustomFunction_487C31E1_SSS_17;
            }
            
            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
            {
                Out = A + B;
            }
            
            // 25927ab6b885bcd0b86a13376933b174
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeComputeSamplingData.hlsl"
            
            void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
            {
                Out = A - B;
            }
            
            struct Bindings_CrestComputeOceanDataFromDisplacedPosition_1f483fe321b10c64e8b93a023ae60dd6
            {
            };
            
            void SG_CrestComputeOceanDataFromDisplacedPosition_1f483fe321b10c64e8b93a023ae60dd6(float3 Vector3_A7B8495A, Bindings_CrestComputeOceanDataFromDisplacedPosition_1f483fe321b10c64e8b93a023ae60dd6 IN, out float2 UndisplacedPosXZAWS_7, out float LodAlpha_6, out float3 Displacement_8, out float OceanWaterDepth_1, out float Foam_2, out float2 Shadow_3, out float2 Flow_4, out float SubSurfaceScattering_5)
            {
                float3 _Property_232E7FDA_Out_0 = Vector3_A7B8495A;
                float _Split_8E8A6DCA_R_1 = _Property_232E7FDA_Out_0[0];
                float _Split_8E8A6DCA_G_2 = _Property_232E7FDA_Out_0[1];
                float _Split_8E8A6DCA_B_3 = _Property_232E7FDA_Out_0[2];
                float _Split_8E8A6DCA_A_4 = 0;
                float2 _Vector2_A3499051_Out_0 = float2(_Split_8E8A6DCA_R_1, _Split_8E8A6DCA_B_3);
                half _CustomFunction_A082C8F2_LodAlpha_3;
                half3 _CustomFunction_A082C8F2_OceanPosScale0_4;
                half3 _CustomFunction_A082C8F2_OceanPosScale1_5;
                half4 _CustomFunction_A082C8F2_OceanParams0_6;
                half4 _CustomFunction_A082C8F2_OceanParams1_7;
                half _CustomFunction_A082C8F2_Slice0_1;
                half _CustomFunction_A082C8F2_Slice1_2;
                CrestComputeSamplingData_half(_Vector2_A3499051_Out_0, _CustomFunction_A082C8F2_LodAlpha_3, _CustomFunction_A082C8F2_OceanPosScale0_4, _CustomFunction_A082C8F2_OceanPosScale1_5, _CustomFunction_A082C8F2_OceanParams0_6, _CustomFunction_A082C8F2_OceanParams1_7, _CustomFunction_A082C8F2_Slice0_1, _CustomFunction_A082C8F2_Slice1_2);
                Bindings_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4 _CrestSampleOceanData_87ACC65F;
                float3 _CrestSampleOceanData_87ACC65F_Displacement_1;
                float _CrestSampleOceanData_87ACC65F_OceanWaterDepth_5;
                float _CrestSampleOceanData_87ACC65F_Foam_6;
                float2 _CrestSampleOceanData_87ACC65F_Shadow_7;
                float2 _CrestSampleOceanData_87ACC65F_Flow_8;
                float _CrestSampleOceanData_87ACC65F_SubSurfaceScattering_9;
                SG_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4(_Vector2_A3499051_Out_0, _CustomFunction_A082C8F2_LodAlpha_3, _CustomFunction_A082C8F2_OceanPosScale0_4, _CustomFunction_A082C8F2_OceanPosScale1_5, _CustomFunction_A082C8F2_OceanParams0_6, _CustomFunction_A082C8F2_OceanParams1_7, _CustomFunction_A082C8F2_Slice0_1, _CrestSampleOceanData_87ACC65F, _CrestSampleOceanData_87ACC65F_Displacement_1, _CrestSampleOceanData_87ACC65F_OceanWaterDepth_5, _CrestSampleOceanData_87ACC65F_Foam_6, _CrestSampleOceanData_87ACC65F_Shadow_7, _CrestSampleOceanData_87ACC65F_Flow_8, _CrestSampleOceanData_87ACC65F_SubSurfaceScattering_9);
                float _Split_CD3A9051_R_1 = _CrestSampleOceanData_87ACC65F_Displacement_1[0];
                float _Split_CD3A9051_G_2 = _CrestSampleOceanData_87ACC65F_Displacement_1[1];
                float _Split_CD3A9051_B_3 = _CrestSampleOceanData_87ACC65F_Displacement_1[2];
                float _Split_CD3A9051_A_4 = 0;
                float2 _Vector2_B8C0C1F0_Out_0 = float2(_Split_CD3A9051_R_1, _Split_CD3A9051_B_3);
                float2 _Subtract_8977A663_Out_2;
                Unity_Subtract_float2(_Vector2_A3499051_Out_0, _Vector2_B8C0C1F0_Out_0, _Subtract_8977A663_Out_2);
                half _CustomFunction_9D8B14F0_LodAlpha_3;
                half3 _CustomFunction_9D8B14F0_OceanPosScale0_4;
                half3 _CustomFunction_9D8B14F0_OceanPosScale1_5;
                half4 _CustomFunction_9D8B14F0_OceanParams0_6;
                half4 _CustomFunction_9D8B14F0_OceanParams1_7;
                half _CustomFunction_9D8B14F0_Slice0_1;
                half _CustomFunction_9D8B14F0_Slice1_2;
                CrestComputeSamplingData_half(_Subtract_8977A663_Out_2, _CustomFunction_9D8B14F0_LodAlpha_3, _CustomFunction_9D8B14F0_OceanPosScale0_4, _CustomFunction_9D8B14F0_OceanPosScale1_5, _CustomFunction_9D8B14F0_OceanParams0_6, _CustomFunction_9D8B14F0_OceanParams1_7, _CustomFunction_9D8B14F0_Slice0_1, _CustomFunction_9D8B14F0_Slice1_2);
                Bindings_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4 _CrestSampleOceanData_D8619779;
                float3 _CrestSampleOceanData_D8619779_Displacement_1;
                float _CrestSampleOceanData_D8619779_OceanWaterDepth_5;
                float _CrestSampleOceanData_D8619779_Foam_6;
                float2 _CrestSampleOceanData_D8619779_Shadow_7;
                float2 _CrestSampleOceanData_D8619779_Flow_8;
                float _CrestSampleOceanData_D8619779_SubSurfaceScattering_9;
                SG_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4(_Subtract_8977A663_Out_2, _CustomFunction_9D8B14F0_LodAlpha_3, _CustomFunction_9D8B14F0_OceanPosScale0_4, _CustomFunction_9D8B14F0_OceanPosScale1_5, _CustomFunction_9D8B14F0_OceanParams0_6, _CustomFunction_9D8B14F0_OceanParams1_7, _CustomFunction_9D8B14F0_Slice0_1, _CrestSampleOceanData_D8619779, _CrestSampleOceanData_D8619779_Displacement_1, _CrestSampleOceanData_D8619779_OceanWaterDepth_5, _CrestSampleOceanData_D8619779_Foam_6, _CrestSampleOceanData_D8619779_Shadow_7, _CrestSampleOceanData_D8619779_Flow_8, _CrestSampleOceanData_D8619779_SubSurfaceScattering_9);
                float _Split_1616DE7_R_1 = _CrestSampleOceanData_D8619779_Displacement_1[0];
                float _Split_1616DE7_G_2 = _CrestSampleOceanData_D8619779_Displacement_1[1];
                float _Split_1616DE7_B_3 = _CrestSampleOceanData_D8619779_Displacement_1[2];
                float _Split_1616DE7_A_4 = 0;
                float2 _Vector2_B871614F_Out_0 = float2(_Split_1616DE7_R_1, _Split_1616DE7_B_3);
                float2 _Subtract_39E2CE30_Out_2;
                Unity_Subtract_float2(_Vector2_A3499051_Out_0, _Vector2_B871614F_Out_0, _Subtract_39E2CE30_Out_2);
                half _CustomFunction_10AEAD9A_LodAlpha_3;
                half3 _CustomFunction_10AEAD9A_OceanPosScale0_4;
                half3 _CustomFunction_10AEAD9A_OceanPosScale1_5;
                half4 _CustomFunction_10AEAD9A_OceanParams0_6;
                half4 _CustomFunction_10AEAD9A_OceanParams1_7;
                half _CustomFunction_10AEAD9A_Slice0_1;
                half _CustomFunction_10AEAD9A_Slice1_2;
                CrestComputeSamplingData_half(_Subtract_39E2CE30_Out_2, _CustomFunction_10AEAD9A_LodAlpha_3, _CustomFunction_10AEAD9A_OceanPosScale0_4, _CustomFunction_10AEAD9A_OceanPosScale1_5, _CustomFunction_10AEAD9A_OceanParams0_6, _CustomFunction_10AEAD9A_OceanParams1_7, _CustomFunction_10AEAD9A_Slice0_1, _CustomFunction_10AEAD9A_Slice1_2);
                Bindings_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4 _CrestSampleOceanData_A1195FE2;
                float3 _CrestSampleOceanData_A1195FE2_Displacement_1;
                float _CrestSampleOceanData_A1195FE2_OceanWaterDepth_5;
                float _CrestSampleOceanData_A1195FE2_Foam_6;
                float2 _CrestSampleOceanData_A1195FE2_Shadow_7;
                float2 _CrestSampleOceanData_A1195FE2_Flow_8;
                float _CrestSampleOceanData_A1195FE2_SubSurfaceScattering_9;
                SG_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4(_Subtract_39E2CE30_Out_2, _CustomFunction_10AEAD9A_LodAlpha_3, _CustomFunction_10AEAD9A_OceanPosScale0_4, _CustomFunction_10AEAD9A_OceanPosScale1_5, _CustomFunction_10AEAD9A_OceanParams0_6, _CustomFunction_10AEAD9A_OceanParams1_7, _CustomFunction_10AEAD9A_Slice0_1, _CrestSampleOceanData_A1195FE2, _CrestSampleOceanData_A1195FE2_Displacement_1, _CrestSampleOceanData_A1195FE2_OceanWaterDepth_5, _CrestSampleOceanData_A1195FE2_Foam_6, _CrestSampleOceanData_A1195FE2_Shadow_7, _CrestSampleOceanData_A1195FE2_Flow_8, _CrestSampleOceanData_A1195FE2_SubSurfaceScattering_9);
                UndisplacedPosXZAWS_7 = _Subtract_39E2CE30_Out_2;
                LodAlpha_6 = _CustomFunction_10AEAD9A_LodAlpha_3;
                Displacement_8 = _CrestSampleOceanData_A1195FE2_Displacement_1;
                OceanWaterDepth_1 = _CrestSampleOceanData_A1195FE2_OceanWaterDepth_5;
                Foam_2 = _CrestSampleOceanData_A1195FE2_Foam_6;
                Shadow_3 = _CrestSampleOceanData_A1195FE2_Shadow_7;
                Flow_4 = _CrestSampleOceanData_A1195FE2_Flow_8;
                SubSurfaceScattering_5 = _CrestSampleOceanData_A1195FE2_SubSurfaceScattering_9;
            }
            
            struct Bindings_CrestUnpackData_5bc4cf08f88035c489658d60edefeec8
            {
                float3 AbsoluteWorldSpacePosition;
                half4 uv0;
                half4 uv1;
                half4 uv2;
            };
            
            void SG_CrestUnpackData_5bc4cf08f88035c489658d60edefeec8(Bindings_CrestUnpackData_5bc4cf08f88035c489658d60edefeec8 IN, out float2 PositionXZWSUndisp_2, out float LodAlpha_1, out float OceanDepth_3, out float Foam_4, out float2 Shadow_5, out float2 Flow_6, out float SubSurfaceScattering_7)
            {
                float4 _UV_CF6CD5F2_Out_0 = IN.uv0;
                float _Split_B10345C8_R_1 = _UV_CF6CD5F2_Out_0[0];
                float _Split_B10345C8_G_2 = _UV_CF6CD5F2_Out_0[1];
                float _Split_B10345C8_B_3 = _UV_CF6CD5F2_Out_0[2];
                float _Split_B10345C8_A_4 = _UV_CF6CD5F2_Out_0[3];
                float2 _Vector2_552A5E1F_Out_0 = float2(_Split_B10345C8_R_1, _Split_B10345C8_G_2);
                Bindings_CrestComputeOceanDataFromDisplacedPosition_1f483fe321b10c64e8b93a023ae60dd6 _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB;
                float2 _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_UndisplacedPosXZAWS_7;
                float _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_LodAlpha_6;
                float3 _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Displacement_8;
                float _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_OceanWaterDepth_1;
                float _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Foam_2;
                float2 _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Shadow_3;
                float2 _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Flow_4;
                float _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_SubSurfaceScattering_5;
                SG_CrestComputeOceanDataFromDisplacedPosition_1f483fe321b10c64e8b93a023ae60dd6(IN.AbsoluteWorldSpacePosition, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_UndisplacedPosXZAWS_7, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_LodAlpha_6, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Displacement_8, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_OceanWaterDepth_1, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Foam_2, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Shadow_3, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Flow_4, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_SubSurfaceScattering_5);
                #if defined(CREST_GENERATED_SHADER_ON)
                float2 _GENERATEDSHADER_71C0694B_Out_0 = _Vector2_552A5E1F_Out_0;
                #else
                float2 _GENERATEDSHADER_71C0694B_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_UndisplacedPosXZAWS_7;
                #endif
                #if defined(CREST_GENERATED_SHADER_ON)
                float _GENERATEDSHADER_2A933A74_Out_0 = _Split_B10345C8_B_3;
                #else
                float _GENERATEDSHADER_2A933A74_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_LodAlpha_6;
                #endif
                #if defined(CREST_GENERATED_SHADER_ON)
                float _GENERATEDSHADER_EFBF6036_Out_0 = _Split_B10345C8_A_4;
                #else
                float _GENERATEDSHADER_EFBF6036_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_OceanWaterDepth_1;
                #endif
                float4 _UV_39E1D2DF_Out_0 = IN.uv1;
                float _Split_CB2CA9B8_R_1 = _UV_39E1D2DF_Out_0[0];
                float _Split_CB2CA9B8_G_2 = _UV_39E1D2DF_Out_0[1];
                float _Split_CB2CA9B8_B_3 = _UV_39E1D2DF_Out_0[2];
                float _Split_CB2CA9B8_A_4 = _UV_39E1D2DF_Out_0[3];
                #if defined(CREST_GENERATED_SHADER_ON)
                float _GENERATEDSHADER_1BBAE801_Out_0 = _Split_CB2CA9B8_G_2;
                #else
                float _GENERATEDSHADER_1BBAE801_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Foam_2;
                #endif
                float4 _UV_33A67BF5_Out_0 = IN.uv2;
                float _Split_753DFB28_R_1 = _UV_33A67BF5_Out_0[0];
                float _Split_753DFB28_G_2 = _UV_33A67BF5_Out_0[1];
                float _Split_753DFB28_B_3 = _UV_33A67BF5_Out_0[2];
                float _Split_753DFB28_A_4 = _UV_33A67BF5_Out_0[3];
                float2 _Vector2_7883B8A6_Out_0 = float2(_Split_753DFB28_R_1, _Split_753DFB28_G_2);
                #if defined(CREST_GENERATED_SHADER_ON)
                float2 _GENERATEDSHADER_B499BDE6_Out_0 = _Vector2_7883B8A6_Out_0;
                #else
                float2 _GENERATEDSHADER_B499BDE6_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Shadow_3;
                #endif
                float2 _Vector2_3A83E1FC_Out_0 = float2(_Split_753DFB28_B_3, _Split_753DFB28_A_4);
                #if defined(CREST_GENERATED_SHADER_ON)
                float2 _GENERATEDSHADER_84CB20AD_Out_0 = _Vector2_3A83E1FC_Out_0;
                #else
                float2 _GENERATEDSHADER_84CB20AD_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Flow_4;
                #endif
                #if defined(CREST_GENERATED_SHADER_ON)
                float _GENERATEDSHADER_6BDC98D1_Out_0 = _Split_CB2CA9B8_R_1;
                #else
                float _GENERATEDSHADER_6BDC98D1_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_SubSurfaceScattering_5;
                #endif
                PositionXZWSUndisp_2 = _GENERATEDSHADER_71C0694B_Out_0;
                LodAlpha_1 = _GENERATEDSHADER_2A933A74_Out_0;
                OceanDepth_3 = _GENERATEDSHADER_EFBF6036_Out_0;
                Foam_4 = _GENERATEDSHADER_1BBAE801_Out_0;
                Shadow_5 = _GENERATEDSHADER_B499BDE6_Out_0;
                Flow_6 = _GENERATEDSHADER_84CB20AD_Out_0;
                SubSurfaceScattering_7 = _GENERATEDSHADER_6BDC98D1_Out_0;
            }
            
            // 673f3e02c7d6371b4ae419cc02e9dca4
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeLightData.hlsl"
            
            struct Bindings_CrestLightData_b74b6e8c0b489314ca7aea3e2cc9c54c
            {
            };
            
            void SG_CrestLightData_b74b6e8c0b489314ca7aea3e2cc9c54c(Bindings_CrestLightData_b74b6e8c0b489314ca7aea3e2cc9c54c IN, out half3 Direction_1, out half3 Intensity_2)
            {
                half3 _CustomFunction_5D41A6E0_Direction_0;
                half3 _CustomFunction_5D41A6E0_Colour_1;
                CrestNodeLightData_half(_CustomFunction_5D41A6E0_Direction_0, _CustomFunction_5D41A6E0_Colour_1);
                Direction_1 = _CustomFunction_5D41A6E0_Direction_0;
                Intensity_2 = _CustomFunction_5D41A6E0_Colour_1;
            }
            
            void Unity_Normalize_float3(float3 In, out float3 Out)
            {
                Out = normalize(In);
            }
            
            void Unity_Not_float(float In, out float Out)
            {
                Out = !In;
            }
            
            struct Bindings_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2
            {
                float FaceSign;
            };
            
            void SG_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2(Bindings_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2 IN, out float OutBoolean_1)
            {
                float _IsFrontFace_F6DF08D5_Out_0 = max(0, IN.FaceSign);
                float _Not_3B19614D_Out_1;
                Unity_Not_float(_IsFrontFace_F6DF08D5_Out_0, _Not_3B19614D_Out_1);
                OutBoolean_1 = _Not_3B19614D_Out_1;
            }
            
            // 928f91ea5fffaa68cdc1e5110d727baf
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeNormalMapping.hlsl"
            
            struct Bindings_CrestComputeNormal_61b9efc6612ab3b4f84174344af5e12a
            {
                float FaceSign;
            };
            
            void SG_CrestComputeNormal_61b9efc6612ab3b4f84174344af5e12a(float3 Vector3_FE793823, float3 Vector3_C8190B61, float4 Vector4_F18E4948, float4 Vector4_43DD8E03, float Vector1_8771A258, TEXTURE2D_PARAM(Texture2D_6CA3A26C, samplerTexture2D_6CA3A26C), float4 Texture2D_6CA3A26C_TexelSize, float Vector1_418D6270, float Vector1_6EC9A7C0, float Vector1_5D9D8139, float2 Vector2_3ED47A62, float2 Vector2_891575B0, float3 Vector3_A9F402BF, Bindings_CrestComputeNormal_61b9efc6612ab3b4f84174344af5e12a IN, out half3 Normal_1)
            {
                float3 _Property_9021A08B_Out_0 = Vector3_FE793823;
                float3 _Property_9C8BC1F1_Out_0 = Vector3_C8190B61;
                float4 _Property_BA13B38B_Out_0 = Vector4_F18E4948;
                float4 _Property_587E24D5_Out_0 = Vector4_43DD8E03;
                float _Property_1A49C52D_Out_0 = Vector1_8771A258;
                float _Property_514FBFB9_Out_0 = Vector1_418D6270;
                float _Property_27A6DF1E_Out_0 = Vector1_6EC9A7C0;
                float _Property_A277E64F_Out_0 = Vector1_5D9D8139;
                float2 _Property_805F9A1D_Out_0 = Vector2_3ED47A62;
                float2 _Property_100A6EB8_Out_0 = Vector2_891575B0;
                float3 _Property_11AD0CE_Out_0 = Vector3_A9F402BF;
                Bindings_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2 _CrestIsUnderwater_BA18A1A;
                _CrestIsUnderwater_BA18A1A.FaceSign = IN.FaceSign;
                float _CrestIsUnderwater_BA18A1A_OutBoolean_1;
                SG_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2(_CrestIsUnderwater_BA18A1A, _CrestIsUnderwater_BA18A1A_OutBoolean_1);
                half3 _CustomFunction_61A7F8B0_NormalTS_1;
                OceanNormals_half(_Property_9021A08B_Out_0, _Property_9C8BC1F1_Out_0, _Property_BA13B38B_Out_0, _Property_587E24D5_Out_0, _Property_1A49C52D_Out_0, Texture2D_6CA3A26C, _Property_514FBFB9_Out_0, _Property_27A6DF1E_Out_0, _Property_A277E64F_Out_0, _Property_805F9A1D_Out_0, _Property_100A6EB8_Out_0, _Property_11AD0CE_Out_0, _CrestIsUnderwater_BA18A1A_OutBoolean_1, _CustomFunction_61A7F8B0_NormalTS_1);
                Normal_1 = _CustomFunction_61A7F8B0_NormalTS_1;
            }
            
            // 52e02b1b13552331adad44cf4a7ae4a5
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeApplyFresnel.hlsl"
            
            struct Bindings_CrestFresnel_c6f6c13c4fdb04e42b427e4c2610d3c9
            {
                float FaceSign;
            };
            
            void SG_CrestFresnel_c6f6c13c4fdb04e42b427e4c2610d3c9(float3 Vector3_FFFD5D37, float3 Vector3_50713CBB, float Vector1_C2909293, float Vector1_DDF5B66E, Bindings_CrestFresnel_c6f6c13c4fdb04e42b427e4c2610d3c9 IN, out float LightTransmitted_1, out float LightReflected_2)
            {
                float3 _Property_3166A32_Out_0 = Vector3_50713CBB;
                float3 _Property_ED2FFB18_Out_0 = Vector3_FFFD5D37;
                Bindings_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2 _CrestIsUnderwater_291EED16;
                _CrestIsUnderwater_291EED16.FaceSign = IN.FaceSign;
                float _CrestIsUnderwater_291EED16_OutBoolean_1;
                SG_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2(_CrestIsUnderwater_291EED16, _CrestIsUnderwater_291EED16_OutBoolean_1);
                float _Property_D5B7D059_Out_0 = Vector1_DDF5B66E;
                float _Property_2395CED2_Out_0 = Vector1_C2909293;
                float _CustomFunction_6DEBC54E_LightTransmitted_1;
                float _CustomFunction_6DEBC54E_LightReflected_10;
                CrestNodeApplyFresnel_float(_Property_3166A32_Out_0, _Property_ED2FFB18_Out_0, _CrestIsUnderwater_291EED16_OutBoolean_1, _Property_D5B7D059_Out_0, _Property_2395CED2_Out_0, _CustomFunction_6DEBC54E_LightTransmitted_1, _CustomFunction_6DEBC54E_LightReflected_10);
                LightTransmitted_1 = _CustomFunction_6DEBC54E_LightTransmitted_1;
                LightReflected_2 = _CustomFunction_6DEBC54E_LightReflected_10;
            }
            
            void GetAmbientLighting_float(out float3 AmbientLighting)
            {
                AmbientLighting = half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
            }
            
            // 4e36a733a1fa5e9359282bf30157c748
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeLightWaterVolume.hlsl"
            
            struct Bindings_CrestVolumeLighting_e9ed6e11710a50640bb4b811d0fa84f2
            {
            };
            
            void SG_CrestVolumeLighting_e9ed6e11710a50640bb4b811d0fa84f2(float4 Vector4_7C3B7892, float3 Vector3_CB562741, float4 Vector4_1925E051, float Vector1_E556918C, float Vector1_67342C54, float Vector1_D7DF1AB, float Vector1_6823579F, float4 Vector4_79A1BE1F, float Vector1_7223C6AC, float Vector1_66E9E54, float2 Vector2_D3558D33, float Vector1_96B7F6DA, float3 Vector3_1559C54, float3 Vector3_EBF06BD4, float3 Vector3_4BB1E4A, float3 Vector3_938EEF71, float3 Vector3_CAD84B7A, Bindings_CrestVolumeLighting_e9ed6e11710a50640bb4b811d0fa84f2 IN, out half3 VolumeLighting_1)
            {
                float4 _Property_3BF186D2_Out_0 = Vector4_7C3B7892;
                float3 _Property_36BD3B33_Out_0 = Vector3_CB562741;
                float4 _Property_DEEB4017_Out_0 = Vector4_1925E051;
                float _Property_DEF8261_Out_0 = Vector1_E556918C;
                float _Property_E59433A0_Out_0 = Vector1_67342C54;
                float _Property_B909C546_Out_0 = Vector1_D7DF1AB;
                float _Property_E4FBA75D_Out_0 = Vector1_6823579F;
                float4 _Property_856C2495_Out_0 = Vector4_79A1BE1F;
                float _Property_D81EDA3D_Out_0 = Vector1_7223C6AC;
                float _Property_9368CB3D_Out_0 = Vector1_66E9E54;
                float2 _Property_BF038BF7_Out_0 = Vector2_D3558D33;
                float _Property_F35AF73E_Out_0 = Vector1_96B7F6DA;
                float3 _Property_32B01413_Out_0 = Vector3_1559C54;
                float3 _Property_5B1BCADB_Out_0 = Vector3_EBF06BD4;
                float3 _Property_6BBACEFC_Out_0 = Vector3_4BB1E4A;
                float3 _Property_C8DE9461_Out_0 = Vector3_938EEF71;
                float3 _Property_919832B1_Out_0 = Vector3_CAD84B7A;
                half3 _CustomFunction_F6F194A9_VolumeLighting_5;
                CrestNodeLightWaterVolume_half((_Property_3BF186D2_Out_0.xyz), _Property_36BD3B33_Out_0, (_Property_DEEB4017_Out_0.xyz), _Property_DEF8261_Out_0, _Property_E59433A0_Out_0, _Property_B909C546_Out_0, _Property_E4FBA75D_Out_0, (_Property_856C2495_Out_0.xyz), _Property_D81EDA3D_Out_0, _Property_9368CB3D_Out_0, _Property_BF038BF7_Out_0, _Property_F35AF73E_Out_0, _Property_32B01413_Out_0, _Property_5B1BCADB_Out_0, _Property_6BBACEFC_Out_0, _Property_C8DE9461_Out_0, _Property_919832B1_Out_0, _CustomFunction_F6F194A9_VolumeLighting_5);
                VolumeLighting_1 = _CustomFunction_F6F194A9_VolumeLighting_5;
            }
            
            void Unity_Negate_float(float In, out float Out)
            {
                Out = -1 * In;
            }
            
            void Unity_SceneColor_float(float4 UV, out float3 Out)
            {
                Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
            }
            
            void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
            
            // edda0395615fdcd072915b34eccb4069
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeOceanGlobals.hlsl"
            
            struct Bindings_CrestOceanGlobals_d50a85284893ec447a25a093505a2120
            {
            };
            
            void SG_CrestOceanGlobals_d50a85284893ec447a25a093505a2120(Bindings_CrestOceanGlobals_d50a85284893ec447a25a093505a2120 IN, out float CrestTime_1, out float TexelsPerWave_2, out float3 OceanCenterPosWorld_3, out float SliceCount_4, out float MeshScaleLerp_5)
            {
                float _CustomFunction_9ED6B15_CrestTime_0;
                float _CustomFunction_9ED6B15_TexelsPerWave_1;
                float3 _CustomFunction_9ED6B15_OceanCenterPosWorld_2;
                float _CustomFunction_9ED6B15_SliceCount_3;
                float _CustomFunction_9ED6B15_MeshScaleLerp_4;
                CrestNodeOceanGlobals_float(_CustomFunction_9ED6B15_CrestTime_0, _CustomFunction_9ED6B15_TexelsPerWave_1, _CustomFunction_9ED6B15_OceanCenterPosWorld_2, _CustomFunction_9ED6B15_SliceCount_3, _CustomFunction_9ED6B15_MeshScaleLerp_4);
                CrestTime_1 = _CustomFunction_9ED6B15_CrestTime_0;
                TexelsPerWave_2 = _CustomFunction_9ED6B15_TexelsPerWave_1;
                OceanCenterPosWorld_3 = _CustomFunction_9ED6B15_OceanCenterPosWorld_2;
                SliceCount_4 = _CustomFunction_9ED6B15_SliceCount_3;
                MeshScaleLerp_5 = _CustomFunction_9ED6B15_MeshScaleLerp_4;
            }
            
            void Unity_Modulo_float(float A, float B, out float Out)
            {
                Out = fmod(A, B);
            }
            
            void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
            {
                Out = A * B;
            }
            
            void Unity_Comparison_Greater_float(float A, float B, out float Out)
            {
                Out = A > B ? 1 : 0;
            }
            
            void Unity_Subtract_float(float A, float B, out float Out)
            {
                Out = A - B;
            }
            
            void Unity_Branch_float(float Predicate, float True, float False, out float Out)
            {
                Out = lerp(False, True, Predicate);
            }
            
            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }
            
            struct Bindings_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1
            {
            };
            
            void SG_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1(float2 Vector2_B562EFB1, float2 Vector2_83AA31A8, Bindings_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1 IN, out float2 DisplacedA_1, out float WeightA_3, out float2 DisplacedB_2, out float WeightB_4)
            {
                float2 _Property_DB670C03_Out_0 = Vector2_83AA31A8;
                float2 _Property_6ED023E0_Out_0 = Vector2_B562EFB1;
                Bindings_CrestOceanGlobals_d50a85284893ec447a25a093505a2120 _CrestOceanGlobals_40DCBE3E;
                float _CrestOceanGlobals_40DCBE3E_CrestTime_1;
                float _CrestOceanGlobals_40DCBE3E_TexelsPerWave_2;
                float3 _CrestOceanGlobals_40DCBE3E_OceanCenterPosWorld_3;
                float _CrestOceanGlobals_40DCBE3E_SliceCount_4;
                float _CrestOceanGlobals_40DCBE3E_MeshScaleLerp_5;
                SG_CrestOceanGlobals_d50a85284893ec447a25a093505a2120(_CrestOceanGlobals_40DCBE3E, _CrestOceanGlobals_40DCBE3E_CrestTime_1, _CrestOceanGlobals_40DCBE3E_TexelsPerWave_2, _CrestOceanGlobals_40DCBE3E_OceanCenterPosWorld_3, _CrestOceanGlobals_40DCBE3E_SliceCount_4, _CrestOceanGlobals_40DCBE3E_MeshScaleLerp_5);
                float _Modulo_CC9BC285_Out_2;
                Unity_Modulo_float(_CrestOceanGlobals_40DCBE3E_CrestTime_1, 2, _Modulo_CC9BC285_Out_2);
                float2 _Multiply_821FCA56_Out_2;
                Unity_Multiply_float(_Property_6ED023E0_Out_0, (_Modulo_CC9BC285_Out_2.xx), _Multiply_821FCA56_Out_2);
                float2 _Subtract_273125FF_Out_2;
                Unity_Subtract_float2(_Property_DB670C03_Out_0, _Multiply_821FCA56_Out_2, _Subtract_273125FF_Out_2);
                float2 _Property_C2A19C1C_Out_0 = Vector2_83AA31A8;
                #if defined(CREST_FLOW_ON)
                float2 _FLOW_963D27CC_Out_0 = _Subtract_273125FF_Out_2;
                #else
                float2 _FLOW_963D27CC_Out_0 = _Property_C2A19C1C_Out_0;
                #endif
                float _Comparison_67E5EC91_Out_2;
                Unity_Comparison_Greater_float(_Modulo_CC9BC285_Out_2, 1, _Comparison_67E5EC91_Out_2);
                float _Subtract_289E2A26_Out_2;
                Unity_Subtract_float(2, _Modulo_CC9BC285_Out_2, _Subtract_289E2A26_Out_2);
                float _Branch_57B6378F_Out_3;
                Unity_Branch_float(_Comparison_67E5EC91_Out_2, _Subtract_289E2A26_Out_2, _Modulo_CC9BC285_Out_2, _Branch_57B6378F_Out_3);
                #if defined(CREST_FLOW_ON)
                float _FLOW_AB68F2D0_Out_0 = _Branch_57B6378F_Out_3;
                #else
                float _FLOW_AB68F2D0_Out_0 = 0;
                #endif
                float2 _Property_CF607B59_Out_0 = Vector2_83AA31A8;
                float2 _Property_8EFEBF1A_Out_0 = Vector2_B562EFB1;
                float _Add_43F824C8_Out_2;
                Unity_Add_float(_CrestOceanGlobals_40DCBE3E_CrestTime_1, 1, _Add_43F824C8_Out_2);
                float _Modulo_2FF365BF_Out_2;
                Unity_Modulo_float(_Add_43F824C8_Out_2, 2, _Modulo_2FF365BF_Out_2);
                float2 _Multiply_28DD98EB_Out_2;
                Unity_Multiply_float(_Property_8EFEBF1A_Out_0, (_Modulo_2FF365BF_Out_2.xx), _Multiply_28DD98EB_Out_2);
                float2 _Subtract_1C7014D5_Out_2;
                Unity_Subtract_float2(_Property_CF607B59_Out_0, _Multiply_28DD98EB_Out_2, _Subtract_1C7014D5_Out_2);
                #if defined(CREST_FLOW_ON)
                float2 _FLOW_D38C09E5_Out_0 = _Subtract_1C7014D5_Out_2;
                #else
                float2 _FLOW_D38C09E5_Out_0 = _Property_C2A19C1C_Out_0;
                #endif
                float _Subtract_563D329D_Out_2;
                Unity_Subtract_float(1, _Branch_57B6378F_Out_3, _Subtract_563D329D_Out_2);
                #if defined(CREST_FLOW_ON)
                float _FLOW_CB3A12C4_Out_0 = _Subtract_563D329D_Out_2;
                #else
                float _FLOW_CB3A12C4_Out_0 = 0;
                #endif
                DisplacedA_1 = _FLOW_963D27CC_Out_0;
                WeightA_3 = _FLOW_AB68F2D0_Out_0;
                DisplacedB_2 = _FLOW_D38C09E5_Out_0;
                WeightB_4 = _FLOW_CB3A12C4_Out_0;
            }
            
            void Unity_Lerp_float2(float2 A, float2 B, float2 T, out float2 Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Multiply_float(float A, float B, out float Out)
            {
                Out = A * B;
            }
            
            void Unity_Add_float2(float2 A, float2 B, out float2 Out)
            {
                Out = A + B;
            }
            
            void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
            {
                Out = A / B;
            }
            
            void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
            {
                Out = dot(A, B);
            }
            
            void Unity_Lerp_float(float A, float B, float T, out float Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
            {
                Out = A * B;
            }
            
            void Unity_Saturate_float(float In, out float Out)
            {
                Out = saturate(In);
            }
            
            // 77d0d525f8d2ec135aebd23c92ac3bf7
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeAmbientLight.hlsl"
            
            struct Bindings_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744
            {
            };
            
            void SG_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744(float3 Vector3_6BC21072, float Vector1_856C8201, float Vector1_D8FFBADE, TEXTURE2D_PARAM(Texture2D_E5D62D20, samplerTexture2D_E5D62D20), float4 Texture2D_E5D62D20_TexelSize, float2 Vector2_1544647C, float Vector1_563FFC82, float Vector1_50FCE8BC, float3 Vector3_8690BC0A, float4 Vector4_8E91C60A, float4 Vector4_8FA06CD1, float2 Vector2_A796D1D3, float2 Vector2_73579388, float Vector1_5220E305, float3 Vector3_7DE999FE, Bindings_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744 IN, out float3 Colour_1)
            {
                float _Vector1_50808D77_Out_0 = 0.74;
                float2 _Property_1DB3A8DD_Out_0 = Vector2_73579388;
                float2 _Property_4E1B12A2_Out_0 = Vector2_A796D1D3;
                float _Vector1_22194DBD_Out_0 = 0.7;
                float2 _Lerp_24C286E6_Out_3;
                Unity_Lerp_float2(_Property_1DB3A8DD_Out_0, _Property_4E1B12A2_Out_0, (_Vector1_22194DBD_Out_0.xx), _Lerp_24C286E6_Out_3);
                Bindings_CrestOceanGlobals_d50a85284893ec447a25a093505a2120 _CrestOceanGlobals_FD233E7F;
                float _CrestOceanGlobals_FD233E7F_CrestTime_1;
                float _CrestOceanGlobals_FD233E7F_TexelsPerWave_2;
                float3 _CrestOceanGlobals_FD233E7F_OceanCenterPosWorld_3;
                float _CrestOceanGlobals_FD233E7F_SliceCount_4;
                float _CrestOceanGlobals_FD233E7F_MeshScaleLerp_5;
                SG_CrestOceanGlobals_d50a85284893ec447a25a093505a2120(_CrestOceanGlobals_FD233E7F, _CrestOceanGlobals_FD233E7F_CrestTime_1, _CrestOceanGlobals_FD233E7F_TexelsPerWave_2, _CrestOceanGlobals_FD233E7F_OceanCenterPosWorld_3, _CrestOceanGlobals_FD233E7F_SliceCount_4, _CrestOceanGlobals_FD233E7F_MeshScaleLerp_5);
                float _Multiply_8E48D7F_Out_2;
                Unity_Multiply_float(0.5, _CrestOceanGlobals_FD233E7F_CrestTime_1, _Multiply_8E48D7F_Out_2);
                float2 _Vector2_93AF7702_Out_0 = float2(0.866, 0.5);
                float2 _Multiply_E81E304E_Out_2;
                Unity_Multiply_float((_Multiply_8E48D7F_Out_2.xx), _Vector2_93AF7702_Out_0, _Multiply_E81E304E_Out_2);
                float2 _Add_99B474A3_Out_2;
                Unity_Add_float2(_Lerp_24C286E6_Out_3, _Multiply_E81E304E_Out_2, _Add_99B474A3_Out_2);
                float _Property_A5B593BF_Out_0 = Vector1_563FFC82;
                float2 _Divide_6E172BAC_Out_2;
                Unity_Divide_float2(_Add_99B474A3_Out_2, (_Property_A5B593BF_Out_0.xx), _Divide_6E172BAC_Out_2);
                float _Vector1_33088EF8_Out_0 = 0.125;
                float3 _Property_CBFC7F14_Out_0 = Vector3_8690BC0A;
                float _Split_638CEA28_R_1 = _Property_CBFC7F14_Out_0[0];
                float _Split_638CEA28_G_2 = _Property_CBFC7F14_Out_0[1];
                float _Split_638CEA28_B_3 = _Property_CBFC7F14_Out_0[2];
                float _Split_638CEA28_A_4 = 0;
                float2 _Vector2_1CDF6E92_Out_0 = float2(_Split_638CEA28_R_1, _Split_638CEA28_B_3);
                float2 _Multiply_FEAB095D_Out_2;
                Unity_Multiply_float((_Vector1_33088EF8_Out_0.xx), _Vector2_1CDF6E92_Out_0, _Multiply_FEAB095D_Out_2);
                float2 _Add_301F9C93_Out_2;
                Unity_Add_float2(_Divide_6E172BAC_Out_2, _Multiply_FEAB095D_Out_2, _Add_301F9C93_Out_2);
                float2 _Multiply_47C4DD4E_Out_2;
                Unity_Multiply_float((_Vector1_50808D77_Out_0.xx), _Add_301F9C93_Out_2, _Multiply_47C4DD4E_Out_2);
                float _Property_569DF47F_Out_0 = Vector1_856C8201;
                float3 _Property_D240D17_Out_0 = Vector3_7DE999FE;
                float _Split_628EF5DE_R_1 = _Property_D240D17_Out_0[0];
                float _Split_628EF5DE_G_2 = _Property_D240D17_Out_0[1];
                float _Split_628EF5DE_B_3 = _Property_D240D17_Out_0[2];
                float _Split_628EF5DE_A_4 = 0;
                float2 _Vector2_BF066046_Out_0 = float2(_Split_628EF5DE_R_1, _Split_628EF5DE_B_3);
                float2 _Multiply_43CB1359_Out_2;
                Unity_Multiply_float((_Property_569DF47F_Out_0.xx), _Vector2_BF066046_Out_0, _Multiply_43CB1359_Out_2);
                float3 _Property_122053A8_Out_0 = Vector3_8690BC0A;
                float3 _Property_ADBC2425_Out_0 = Vector3_7DE999FE;
                float _DotProduct_B4F8C812_Out_2;
                Unity_DotProduct_float3(_Property_122053A8_Out_0, _Property_ADBC2425_Out_0, _DotProduct_B4F8C812_Out_2);
                float2 _Divide_63189A2B_Out_2;
                Unity_Divide_float2(_Multiply_43CB1359_Out_2, (_DotProduct_B4F8C812_Out_2.xx), _Divide_63189A2B_Out_2);
                float2 _Add_D56F8BCC_Out_2;
                Unity_Add_float2(_Multiply_47C4DD4E_Out_2, _Divide_63189A2B_Out_2, _Add_D56F8BCC_Out_2);
                float _Vector1_4A3115D0_Out_0 = 4;
                float4 _Property_6BB45B70_Out_0 = Vector4_8E91C60A;
                float _Split_128BB5B0_R_1 = _Property_6BB45B70_Out_0[0];
                float _Split_128BB5B0_G_2 = _Property_6BB45B70_Out_0[1];
                float _Split_128BB5B0_B_3 = _Property_6BB45B70_Out_0[2];
                float _Split_128BB5B0_A_4 = _Property_6BB45B70_Out_0[3];
                float _Multiply_338764B5_Out_2;
                Unity_Multiply_float(_Vector1_4A3115D0_Out_0, _Split_128BB5B0_R_1, _Multiply_338764B5_Out_2);
                float _Property_ACBE1A98_Out_0 = Vector1_563FFC82;
                float _Multiply_69F2FFA6_Out_2;
                Unity_Multiply_float(_Multiply_338764B5_Out_2, _Property_ACBE1A98_Out_0, _Multiply_69F2FFA6_Out_2);
                float2 _Divide_FF361B20_Out_2;
                Unity_Divide_float2(_Add_D56F8BCC_Out_2, (_Multiply_69F2FFA6_Out_2.xx), _Divide_FF361B20_Out_2);
                float4 _SampleTexture2DLOD_181D539B_RGBA_0 = SAMPLE_TEXTURE2D_LOD(Texture2D_E5D62D20, SamplerState_Linear_Repeat, _Divide_FF361B20_Out_2, 3);
                float _SampleTexture2DLOD_181D539B_R_5 = _SampleTexture2DLOD_181D539B_RGBA_0.r;
                float _SampleTexture2DLOD_181D539B_G_6 = _SampleTexture2DLOD_181D539B_RGBA_0.g;
                float _SampleTexture2DLOD_181D539B_B_7 = _SampleTexture2DLOD_181D539B_RGBA_0.b;
                float _SampleTexture2DLOD_181D539B_A_8 = _SampleTexture2DLOD_181D539B_RGBA_0.a;
                float _Vector1_C260EA24_Out_0 = 4;
                float4 _Property_1EB65445_Out_0 = Vector4_8FA06CD1;
                float _Split_DFFF5F9B_R_1 = _Property_1EB65445_Out_0[0];
                float _Split_DFFF5F9B_G_2 = _Property_1EB65445_Out_0[1];
                float _Split_DFFF5F9B_B_3 = _Property_1EB65445_Out_0[2];
                float _Split_DFFF5F9B_A_4 = _Property_1EB65445_Out_0[3];
                float _Multiply_FD1848E_Out_2;
                Unity_Multiply_float(_Vector1_C260EA24_Out_0, _Split_DFFF5F9B_R_1, _Multiply_FD1848E_Out_2);
                float _Property_4D74395B_Out_0 = Vector1_563FFC82;
                float _Multiply_BB87C63D_Out_2;
                Unity_Multiply_float(_Multiply_FD1848E_Out_2, _Property_4D74395B_Out_0, _Multiply_BB87C63D_Out_2);
                float2 _Divide_7AE4E36C_Out_2;
                Unity_Divide_float2(_Add_D56F8BCC_Out_2, (_Multiply_BB87C63D_Out_2.xx), _Divide_7AE4E36C_Out_2);
                float4 _SampleTexture2DLOD_F7B977AE_RGBA_0 = SAMPLE_TEXTURE2D_LOD(Texture2D_E5D62D20, SamplerState_Linear_Repeat, _Divide_7AE4E36C_Out_2, 3);
                float _SampleTexture2DLOD_F7B977AE_R_5 = _SampleTexture2DLOD_F7B977AE_RGBA_0.r;
                float _SampleTexture2DLOD_F7B977AE_G_6 = _SampleTexture2DLOD_F7B977AE_RGBA_0.g;
                float _SampleTexture2DLOD_F7B977AE_B_7 = _SampleTexture2DLOD_F7B977AE_RGBA_0.b;
                float _SampleTexture2DLOD_F7B977AE_A_8 = _SampleTexture2DLOD_F7B977AE_RGBA_0.a;
                float _Property_8BDFE27D_Out_0 = Vector1_5220E305;
                float _Lerp_8E281E25_Out_3;
                Unity_Lerp_float(_SampleTexture2DLOD_181D539B_R_5, _SampleTexture2DLOD_F7B977AE_R_5, _Property_8BDFE27D_Out_0, _Lerp_8E281E25_Out_3);
                float3 _Property_76A1927E_Out_0 = Vector3_6BC21072;
                float3 _Multiply_559CF32F_Out_2;
                Unity_Multiply_float((_Lerp_8E281E25_Out_3.xxx), _Property_76A1927E_Out_0, _Multiply_559CF32F_Out_2);
                float _Property_47590F25_Out_0 = Vector1_50FCE8BC;
                float _Property_8CF73BE5_Out_0 = Vector1_D8FFBADE;
                float _Multiply_A19262A8_Out_2;
                Unity_Multiply_float(_Property_47590F25_Out_0, _Property_8CF73BE5_Out_0, _Multiply_A19262A8_Out_2);
                float _Saturate_A17AF199_Out_1;
                Unity_Saturate_float(_Multiply_A19262A8_Out_2, _Saturate_A17AF199_Out_1);
                float3 _Multiply_DCE93606_Out_2;
                Unity_Multiply_float(_Multiply_559CF32F_Out_2, (_Saturate_A17AF199_Out_1.xxx), _Multiply_DCE93606_Out_2);
                half3 _CustomFunction_6C4427EF_AmbientLight_0;
                CrestNodeAmbientLight_half(_CustomFunction_6C4427EF_AmbientLight_0);
                float3 _Multiply_9B6FA71B_Out_2;
                Unity_Multiply_float(_Multiply_DCE93606_Out_2, _CustomFunction_6C4427EF_AmbientLight_0, _Multiply_9B6FA71B_Out_2);
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_B0667840_Out_0 = _Multiply_9B6FA71B_Out_2;
                #else
                float3 _FOAM_B0667840_Out_0 = float3(0, 0, 0);
                #endif
                Colour_1 = _FOAM_B0667840_Out_0;
            }
            
            struct Bindings_CrestFoamBubblesWithFlow_e132fba35874b4923988ef35a40e48c3
            {
            };
            
            void SG_CrestFoamBubblesWithFlow_e132fba35874b4923988ef35a40e48c3(float3 Vector3_6BC21072, float Vector1_856C8201, float Vector1_D8FFBADE, TEXTURE2D_PARAM(Texture2D_E5D62D20, samplerTexture2D_E5D62D20), float4 Texture2D_E5D62D20_TexelSize, float2 Vector2_1544647C, float Vector1_563FFC82, float Vector1_50FCE8BC, float3 Vector3_8690BC0A, float4 Vector4_8E91C60A, float4 Vector4_8FA06CD1, float2 Vector2_A796D1D3, float2 Vector2_73579388, float Vector1_5220E305, float3 Vector3_7DE999FE, float2 Vector2_58330803, Bindings_CrestFoamBubblesWithFlow_e132fba35874b4923988ef35a40e48c3 IN, out float3 Colour_1)
            {
                float3 _Property_943DDE94_Out_0 = Vector3_6BC21072;
                float _Property_2A86C6D_Out_0 = Vector1_856C8201;
                float _Property_742EBA65_Out_0 = Vector1_D8FFBADE;
                float2 _Property_56F70460_Out_0 = Vector2_1544647C;
                float _Property_BBD1954E_Out_0 = Vector1_563FFC82;
                float _Property_63B10EE4_Out_0 = Vector1_50FCE8BC;
                float3 _Property_736DEE08_Out_0 = Vector3_8690BC0A;
                float4 _Property_E1794A68_Out_0 = Vector4_8E91C60A;
                float4 _Property_13FD15E9_Out_0 = Vector4_8FA06CD1;
                float2 _Property_8C400C63_Out_0 = Vector2_A796D1D3;
                float2 _Property_B43D23D2_Out_0 = Vector2_58330803;
                float2 _Property_6AC0F258_Out_0 = Vector2_73579388;
                Bindings_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1 _CrestFlow_2C0F2FAE;
                float2 _CrestFlow_2C0F2FAE_DisplacedA_1;
                float _CrestFlow_2C0F2FAE_WeightA_3;
                float2 _CrestFlow_2C0F2FAE_DisplacedB_2;
                float _CrestFlow_2C0F2FAE_WeightB_4;
                SG_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1(_Property_B43D23D2_Out_0, _Property_6AC0F258_Out_0, _CrestFlow_2C0F2FAE, _CrestFlow_2C0F2FAE_DisplacedA_1, _CrestFlow_2C0F2FAE_WeightA_3, _CrestFlow_2C0F2FAE_DisplacedB_2, _CrestFlow_2C0F2FAE_WeightB_4);
                float _Property_4C00CA0D_Out_0 = Vector1_5220E305;
                float3 _Property_5BF1E9DE_Out_0 = Vector3_7DE999FE;
                Bindings_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744 _CrestFoamBubbles_E18873D;
                float3 _CrestFoamBubbles_E18873D_Colour_1;
                SG_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744(_Property_943DDE94_Out_0, _Property_2A86C6D_Out_0, _Property_742EBA65_Out_0, TEXTURE2D_ARGS(Texture2D_E5D62D20, samplerTexture2D_E5D62D20), Texture2D_E5D62D20_TexelSize, _Property_56F70460_Out_0, _Property_BBD1954E_Out_0, _Property_63B10EE4_Out_0, _Property_736DEE08_Out_0, _Property_E1794A68_Out_0, _Property_13FD15E9_Out_0, _Property_8C400C63_Out_0, _CrestFlow_2C0F2FAE_DisplacedA_1, _Property_4C00CA0D_Out_0, _Property_5BF1E9DE_Out_0, _CrestFoamBubbles_E18873D, _CrestFoamBubbles_E18873D_Colour_1);
                float3 _Multiply_91E077CA_Out_2;
                Unity_Multiply_float(_CrestFoamBubbles_E18873D_Colour_1, (_CrestFlow_2C0F2FAE_WeightA_3.xxx), _Multiply_91E077CA_Out_2);
                float3 _Property_A1641BBA_Out_0 = Vector3_6BC21072;
                float _Property_3D5C8C49_Out_0 = Vector1_856C8201;
                float _Property_212108F5_Out_0 = Vector1_D8FFBADE;
                float2 _Property_E4A605_Out_0 = Vector2_1544647C;
                float _Property_6B5F6C8D_Out_0 = Vector1_563FFC82;
                float _Property_C1EFD93_Out_0 = Vector1_50FCE8BC;
                float3 _Property_374658EE_Out_0 = Vector3_8690BC0A;
                float4 _Property_93465CAB_Out_0 = Vector4_8E91C60A;
                float4 _Property_D292F7E_Out_0 = Vector4_8FA06CD1;
                float2 _Property_41EA12FB_Out_0 = Vector2_A796D1D3;
                float _Property_ACCAE2A2_Out_0 = Vector1_5220E305;
                float3 _Property_419B8C8_Out_0 = Vector3_7DE999FE;
                Bindings_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744 _CrestFoamBubbles_B2999161;
                float3 _CrestFoamBubbles_B2999161_Colour_1;
                SG_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744(_Property_A1641BBA_Out_0, _Property_3D5C8C49_Out_0, _Property_212108F5_Out_0, TEXTURE2D_ARGS(Texture2D_E5D62D20, samplerTexture2D_E5D62D20), Texture2D_E5D62D20_TexelSize, _Property_E4A605_Out_0, _Property_6B5F6C8D_Out_0, _Property_C1EFD93_Out_0, _Property_374658EE_Out_0, _Property_93465CAB_Out_0, _Property_D292F7E_Out_0, _Property_41EA12FB_Out_0, _CrestFlow_2C0F2FAE_DisplacedB_2, _Property_ACCAE2A2_Out_0, _Property_419B8C8_Out_0, _CrestFoamBubbles_B2999161, _CrestFoamBubbles_B2999161_Colour_1);
                float3 _Multiply_B28E3E4F_Out_2;
                Unity_Multiply_float(_CrestFoamBubbles_B2999161_Colour_1, (_CrestFlow_2C0F2FAE_WeightB_4.xxx), _Multiply_B28E3E4F_Out_2);
                float3 _Add_4A081B98_Out_2;
                Unity_Add_float3(_Multiply_91E077CA_Out_2, _Multiply_B28E3E4F_Out_2, _Add_4A081B98_Out_2);
                #if defined(CREST_FLOW_ON)
                float3 _FLOW_3ACDD4E5_Out_0 = _Add_4A081B98_Out_2;
                #else
                float3 _FLOW_3ACDD4E5_Out_0 = _CrestFoamBubbles_E18873D_Colour_1;
                #endif
                Colour_1 = _FLOW_3ACDD4E5_Out_0;
            }
            
            // 11f8e1767f0d2397594b0042f8356f6e
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeVolumeEmission.hlsl"
            
            struct Bindings_CrestSampleOceanDataSingle_a667f031fd6a3dd42beee0ccc432233d
            {
            };
            
            void SG_CrestSampleOceanDataSingle_a667f031fd6a3dd42beee0ccc432233d(float2 Vector2_1BD49B8D, float3 Vector3_7E91D336, float4 Vector4_C0B2B5EA, float Vector1_8EA8B92B, Bindings_CrestSampleOceanDataSingle_a667f031fd6a3dd42beee0ccc432233d IN, out float3 Displacement_1, out float OceanWaterDepth_5, out float Foam_6, out float2 Shadow_7, out float2 Flow_8, out float SubSurfaceScattering_9)
            {
                float2 _Property_FA70A3E6_Out_0 = Vector2_1BD49B8D;
                float3 _Property_C925A867_Out_0 = Vector3_7E91D336;
                float4 _Property_467D1BE7_Out_0 = Vector4_C0B2B5EA;
                float _Property_59E019ED_Out_0 = Vector1_8EA8B92B;
                float3 _CustomFunction_487C31E1_Displacement_3;
                float _CustomFunction_487C31E1_OceanDepth_8;
                float _CustomFunction_487C31E1_Foam_4;
                float2 _CustomFunction_487C31E1_Shadow_5;
                float2 _CustomFunction_487C31E1_Flow_6;
                float _CustomFunction_487C31E1_SSS_17;
                CrestNodeSampleOceanDataSingle_float(_Property_FA70A3E6_Out_0, _Property_C925A867_Out_0, _Property_467D1BE7_Out_0, _Property_59E019ED_Out_0, _CustomFunction_487C31E1_Displacement_3, _CustomFunction_487C31E1_OceanDepth_8, _CustomFunction_487C31E1_Foam_4, _CustomFunction_487C31E1_Shadow_5, _CustomFunction_487C31E1_Flow_6, _CustomFunction_487C31E1_SSS_17);
                Displacement_1 = _CustomFunction_487C31E1_Displacement_3;
                OceanWaterDepth_5 = _CustomFunction_487C31E1_OceanDepth_8;
                Foam_6 = _CustomFunction_487C31E1_Foam_4;
                Shadow_7 = _CustomFunction_487C31E1_Shadow_5;
                Flow_8 = _CustomFunction_487C31E1_Flow_6;
                SubSurfaceScattering_9 = _CustomFunction_487C31E1_SSS_17;
            }
            
            // 733e22c05b4f35356dd63172ccf21370
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeApplyCaustics.hlsl"
            
            void Unity_Negate_float3(float3 In, out float3 Out)
            {
                Out = -1 * In;
            }
            
            void Unity_Exponential_float3(float3 In, out float3 Out)
            {
                Out = exp(In);
            }
            
            void Unity_OneMinus_float3(float3 In, out float3 Out)
            {
                Out = 1 - In;
            }
            
            void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
            {
                Out = lerp(False, True, Predicate);
            }
            
            struct Bindings_CrestEmission_8c56460232fde1e46ae90d905a00f908
            {
            };
            
            void SG_CrestEmission_8c56460232fde1e46ae90d905a00f908(float Vector1_82EC3C0B, float3 Vector3_6C3F4D52, float3 Vector3_83F0ECB8, float3 Vector3_D6B78A76, float3 Vector3_703F2DD, float4 Vector4_5D0F731B, float Vector1_73B9F9E8, float3 Vector3_D4CABAFD, float Vector1_6C78E163, half3 Vector3_71E7580E, TEXTURE2D_PARAM(Texture2D_BA141407, samplerTexture2D_BA141407), float4 Texture2D_BA141407_TexelSize, half Vector1_460D9038, half Vector1_D5CE42D3, half Vector1_AC9C2A2, half Vector1_8DBC6E14, half Vector1_EA8F2BEC, TEXTURE2D_PARAM(Texture2D_AC91C4C3, samplerTexture2D_AC91C4C3), float4 Texture2D_AC91C4C3_TexelSize, half Vector1_DB8E128A, half Vector1_CFFD6A53, float3 Vector3_32FB76B3, Bindings_CrestEmission_8c56460232fde1e46ae90d905a00f908 IN, out float3 EmittedLight_1)
            {
                float Boolean_6AA51A5 = 0;
                float _Property_101786D0_Out_0 = Vector1_82EC3C0B;
                float3 _Property_833375DE_Out_0 = Vector3_83F0ECB8;
                float3 _Property_83DC9AD9_Out_0 = Vector3_703F2DD;
                float4 _Property_83CEC55B_Out_0 = Vector4_5D0F731B;
                float _Property_37502285_Out_0 = Vector1_73B9F9E8;
                float3 _Property_5935620A_Out_0 = Vector3_D4CABAFD;
                float _Property_AF5C7A5F_Out_0 = Vector1_6C78E163;
                half3 _CustomFunction_F95A252D_SceneColour_5;
                half _CustomFunction_F95A252D_SceneDistance_9;
                half3 _CustomFunction_F95A252D_ScenePositionWS_10;
                CrestNodeSceneColour_half(_Property_101786D0_Out_0, _Property_833375DE_Out_0, _Property_83DC9AD9_Out_0, _Property_83CEC55B_Out_0, _Property_37502285_Out_0, _Property_5935620A_Out_0, _Property_AF5C7A5F_Out_0, _CustomFunction_F95A252D_SceneColour_5, _CustomFunction_F95A252D_SceneDistance_9, _CustomFunction_F95A252D_ScenePositionWS_10);
                half _Split_550754E3_R_1 = _CustomFunction_F95A252D_ScenePositionWS_10[0];
                half _Split_550754E3_G_2 = _CustomFunction_F95A252D_ScenePositionWS_10[1];
                half _Split_550754E3_B_3 = _CustomFunction_F95A252D_ScenePositionWS_10[2];
                half _Split_550754E3_A_4 = 0;
                half2 _Vector2_B1CFC7F6_Out_0 = half2(_Split_550754E3_R_1, _Split_550754E3_B_3);
                Bindings_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d _CrestDrivenData_541C70CC;
                half _CrestDrivenData_541C70CC_MeshScaleAlpha_1;
                half _CrestDrivenData_541C70CC_LodDataTexelSize_8;
                half _CrestDrivenData_541C70CC_GeometryGridSize_2;
                half3 _CrestDrivenData_541C70CC_OceanPosScale0_3;
                half3 _CrestDrivenData_541C70CC_OceanPosScale1_4;
                half4 _CrestDrivenData_541C70CC_OceanParams0_5;
                half4 _CrestDrivenData_541C70CC_OceanParams1_6;
                half _CrestDrivenData_541C70CC_SliceIndex0_7;
                SG_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d(_CrestDrivenData_541C70CC, _CrestDrivenData_541C70CC_MeshScaleAlpha_1, _CrestDrivenData_541C70CC_LodDataTexelSize_8, _CrestDrivenData_541C70CC_GeometryGridSize_2, _CrestDrivenData_541C70CC_OceanPosScale0_3, _CrestDrivenData_541C70CC_OceanPosScale1_4, _CrestDrivenData_541C70CC_OceanParams0_5, _CrestDrivenData_541C70CC_OceanParams1_6, _CrestDrivenData_541C70CC_SliceIndex0_7);
                float _Add_87784A87_Out_2;
                Unity_Add_float(_CrestDrivenData_541C70CC_SliceIndex0_7, 1, _Add_87784A87_Out_2);
                Bindings_CrestSampleOceanDataSingle_a667f031fd6a3dd42beee0ccc432233d _CrestSampleOceanDataSingle_5C7B7E58;
                float3 _CrestSampleOceanDataSingle_5C7B7E58_Displacement_1;
                float _CrestSampleOceanDataSingle_5C7B7E58_OceanWaterDepth_5;
                float _CrestSampleOceanDataSingle_5C7B7E58_Foam_6;
                float2 _CrestSampleOceanDataSingle_5C7B7E58_Shadow_7;
                float2 _CrestSampleOceanDataSingle_5C7B7E58_Flow_8;
                float _CrestSampleOceanDataSingle_5C7B7E58_SubSurfaceScattering_9;
                SG_CrestSampleOceanDataSingle_a667f031fd6a3dd42beee0ccc432233d(_Vector2_B1CFC7F6_Out_0, _CrestDrivenData_541C70CC_OceanPosScale1_4, _CrestDrivenData_541C70CC_OceanParams1_6, _Add_87784A87_Out_2, _CrestSampleOceanDataSingle_5C7B7E58, _CrestSampleOceanDataSingle_5C7B7E58_Displacement_1, _CrestSampleOceanDataSingle_5C7B7E58_OceanWaterDepth_5, _CrestSampleOceanDataSingle_5C7B7E58_Foam_6, _CrestSampleOceanDataSingle_5C7B7E58_Shadow_7, _CrestSampleOceanDataSingle_5C7B7E58_Flow_8, _CrestSampleOceanDataSingle_5C7B7E58_SubSurfaceScattering_9);
                Bindings_CrestOceanGlobals_d50a85284893ec447a25a093505a2120 _CrestOceanGlobals_FCFEE3C8;
                float _CrestOceanGlobals_FCFEE3C8_CrestTime_1;
                float _CrestOceanGlobals_FCFEE3C8_TexelsPerWave_2;
                float3 _CrestOceanGlobals_FCFEE3C8_OceanCenterPosWorld_3;
                float _CrestOceanGlobals_FCFEE3C8_SliceCount_4;
                float _CrestOceanGlobals_FCFEE3C8_MeshScaleLerp_5;
                SG_CrestOceanGlobals_d50a85284893ec447a25a093505a2120(_CrestOceanGlobals_FCFEE3C8, _CrestOceanGlobals_FCFEE3C8_CrestTime_1, _CrestOceanGlobals_FCFEE3C8_TexelsPerWave_2, _CrestOceanGlobals_FCFEE3C8_OceanCenterPosWorld_3, _CrestOceanGlobals_FCFEE3C8_SliceCount_4, _CrestOceanGlobals_FCFEE3C8_MeshScaleLerp_5);
                float3 _Add_13827433_Out_2;
                Unity_Add_float3(_CrestSampleOceanDataSingle_5C7B7E58_Displacement_1, _CrestOceanGlobals_FCFEE3C8_OceanCenterPosWorld_3, _Add_13827433_Out_2);
                float _Split_8D03CDFB_R_1 = _Add_13827433_Out_2[0];
                float _Split_8D03CDFB_G_2 = _Add_13827433_Out_2[1];
                float _Split_8D03CDFB_B_3 = _Add_13827433_Out_2[2];
                float _Split_8D03CDFB_A_4 = 0;
                half3 _Property_513534C6_Out_0 = Vector3_71E7580E;
                half _Property_EF9152A2_Out_0 = Vector1_460D9038;
                half _Property_3D2898B2_Out_0 = Vector1_D5CE42D3;
                half _Property_35078BD5_Out_0 = Vector1_AC9C2A2;
                half _Property_1B866598_Out_0 = Vector1_8DBC6E14;
                half _Property_2016136C_Out_0 = Vector1_EA8F2BEC;
                half _Property_A64ADC3_Out_0 = Vector1_DB8E128A;
                half _Property_DDF09C09_Out_0 = Vector1_CFFD6A53;
                float3 _CustomFunction_2F6A103B_SceneColourOut_8;
                CrestNodeApplyCaustics_float(_CustomFunction_F95A252D_SceneColour_5, _CustomFunction_F95A252D_ScenePositionWS_10, _Split_8D03CDFB_G_2, _Property_513534C6_Out_0, _CustomFunction_F95A252D_SceneDistance_9, Texture2D_BA141407, _Property_EF9152A2_Out_0, _Property_3D2898B2_Out_0, _Property_35078BD5_Out_0, _Property_1B866598_Out_0, _Property_2016136C_Out_0, Texture2D_AC91C4C3, _Property_A64ADC3_Out_0, _Property_DDF09C09_Out_0, _CustomFunction_2F6A103B_SceneColourOut_8);
                #if defined(CREST_CAUSTICS_ON)
                float3 _CAUSTICS_6D445714_Out_0 = _CustomFunction_2F6A103B_SceneColourOut_8;
                #else
                float3 _CAUSTICS_6D445714_Out_0 = _CustomFunction_F95A252D_SceneColour_5;
                #endif
                float3 _Property_78DFA568_Out_0 = Vector3_83F0ECB8;
                float3 _Property_54BACED9_Out_0 = Vector3_32FB76B3;
                float3 _Add_954C4741_Out_2;
                Unity_Add_float3(_Property_78DFA568_Out_0, _Property_54BACED9_Out_0, _Add_954C4741_Out_2);
                float3 _Property_D76B9A0B_Out_0 = Vector3_6C3F4D52;
                float3 _Multiply_C51E63DE_Out_2;
                Unity_Multiply_float((_CustomFunction_F95A252D_SceneDistance_9.xxx), _Property_D76B9A0B_Out_0, _Multiply_C51E63DE_Out_2);
                float3 _Negate_ADFF8761_Out_1;
                Unity_Negate_float3(_Multiply_C51E63DE_Out_2, _Negate_ADFF8761_Out_1);
                float3 _Exponential_6FCB9AC3_Out_1;
                Unity_Exponential_float3(_Negate_ADFF8761_Out_1, _Exponential_6FCB9AC3_Out_1);
                float3 _OneMinus_9962618_Out_1;
                Unity_OneMinus_float3(_Exponential_6FCB9AC3_Out_1, _OneMinus_9962618_Out_1);
                float3 _Lerp_E9270AE8_Out_3;
                Unity_Lerp_float3(_CAUSTICS_6D445714_Out_0, _Add_954C4741_Out_2, _OneMinus_9962618_Out_1, _Lerp_E9270AE8_Out_3);
                float3 _Branch_2D3EE3D3_Out_3;
                Unity_Branch_float3(1, _Lerp_E9270AE8_Out_3, _CAUSTICS_6D445714_Out_0, _Branch_2D3EE3D3_Out_3);
                float3 _Branch_D043DFC1_Out_3;
                Unity_Branch_float3(Boolean_6AA51A5, _CAUSTICS_6D445714_Out_0, _Branch_2D3EE3D3_Out_3, _Branch_D043DFC1_Out_3);
                EmittedLight_1 = _Branch_D043DFC1_Out_3;
            }
            
            void Unity_Divide_float(float A, float B, out float Out)
            {
                Out = A / B;
            }
            
            void Unity_Power_float(float A, float B, out float Out)
            {
                Out = pow(A, B);
            }
            
            // 97e077ca2652cbf427809ae775e45d5a
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeFoam.hlsl"
            
            struct Bindings_CrestFoamWithFlow_3a6c22dceac0847a2a31cb05a577b963
            {
            };
            
            void SG_CrestFoamWithFlow_3a6c22dceac0847a2a31cb05a577b963(TEXTURE2D_PARAM(Texture2D_D9E7A343, samplerTexture2D_D9E7A343), float4 Texture2D_D9E7A343_TexelSize, float2 Vector2_C4E9ED58, float Vector1_7492C815, float Vector1_33DC93D, float Vector1_3439FC0A, float Vector1_FB133018, float Vector1_7CFAFAC1, float Vector1_53F45327, float4 Vector4_2FA9AEA5, float4 Vector4_FD283A50, float Vector1_D6DA4100, float Vector1_13F2A8C8, float2 Vector2_28A2C5B9, float3 Vector3_3AD012AA, float3 Vector3_E4AC4432, float Vector1_3E452608, float2 Vector2_5AD72ED, Bindings_CrestFoamWithFlow_3a6c22dceac0847a2a31cb05a577b963 IN, out float3 Albedo_1, out float3 NormalTS_2, out float3 Emission_3, out float Smoothness_4)
            {
                float2 _Property_B71BFD9B_Out_0 = Vector2_C4E9ED58;
                float _Property_7C437CB0_Out_0 = Vector1_7492C815;
                float _Property_BD5882DA_Out_0 = Vector1_33DC93D;
                float _Property_3EF95B2A_Out_0 = Vector1_3439FC0A;
                float _Property_38B853C9_Out_0 = Vector1_FB133018;
                float _Property_8F25A4DF_Out_0 = Vector1_7CFAFAC1;
                float _Property_561CFE5E_Out_0 = Vector1_53F45327;
                float4 _Property_A1E249A2_Out_0 = Vector4_2FA9AEA5;
                float4 _Property_9A7BA0BB_Out_0 = Vector4_FD283A50;
                float _Property_4C4E1C83_Out_0 = Vector1_D6DA4100;
                float _Property_D81DA51E_Out_0 = Vector1_13F2A8C8;
                float2 _Property_4BF1D6EA_Out_0 = Vector2_5AD72ED;
                float2 _Property_DEC66EB9_Out_0 = Vector2_28A2C5B9;
                Bindings_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1 _CrestFlow_B4596B;
                float2 _CrestFlow_B4596B_DisplacedA_1;
                float _CrestFlow_B4596B_WeightA_3;
                float2 _CrestFlow_B4596B_DisplacedB_2;
                float _CrestFlow_B4596B_WeightB_4;
                SG_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1(_Property_4BF1D6EA_Out_0, _Property_DEC66EB9_Out_0, _CrestFlow_B4596B, _CrestFlow_B4596B_DisplacedA_1, _CrestFlow_B4596B_WeightA_3, _CrestFlow_B4596B_DisplacedB_2, _CrestFlow_B4596B_WeightB_4);
                float3 _Property_EB1DCAFB_Out_0 = Vector3_3AD012AA;
                float3 _Property_A2BD94BA_Out_0 = Vector3_E4AC4432;
                float _Property_7BFA2B51_Out_0 = Vector1_3E452608;
                half3 _CustomFunction_2B0D0960_Albedo_8;
                half3 _CustomFunction_2B0D0960_NormalTS_7;
                half3 _CustomFunction_2B0D0960_Emission_9;
                half _CustomFunction_2B0D0960_Smoothness_10;
                CrestNodeFoam_half(Texture2D_D9E7A343, _Property_B71BFD9B_Out_0, _Property_7C437CB0_Out_0, _Property_BD5882DA_Out_0, _Property_3EF95B2A_Out_0, _Property_38B853C9_Out_0, _Property_8F25A4DF_Out_0, _Property_561CFE5E_Out_0, _Property_A1E249A2_Out_0, _Property_9A7BA0BB_Out_0, _Property_4C4E1C83_Out_0, _Property_D81DA51E_Out_0, _CrestFlow_B4596B_DisplacedA_1, _Property_EB1DCAFB_Out_0, _Property_A2BD94BA_Out_0, _Property_7BFA2B51_Out_0, _CustomFunction_2B0D0960_Albedo_8, _CustomFunction_2B0D0960_NormalTS_7, _CustomFunction_2B0D0960_Emission_9, _CustomFunction_2B0D0960_Smoothness_10);
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_384819B4_Out_0 = _CustomFunction_2B0D0960_Albedo_8;
                #else
                float3 _FOAM_384819B4_Out_0 = float3(0, 0, 0);
                #endif
                float3 _Multiply_278EF57C_Out_2;
                Unity_Multiply_float(_FOAM_384819B4_Out_0, (_CrestFlow_B4596B_WeightA_3.xxx), _Multiply_278EF57C_Out_2);
                float2 _Property_6338038D_Out_0 = Vector2_C4E9ED58;
                float _Property_C8444C80_Out_0 = Vector1_7492C815;
                float _Property_3DF87814_Out_0 = Vector1_33DC93D;
                float _Property_589C4301_Out_0 = Vector1_3439FC0A;
                float _Property_E9D88423_Out_0 = Vector1_FB133018;
                float _Property_366CB823_Out_0 = Vector1_7CFAFAC1;
                float _Property_1F5469F5_Out_0 = Vector1_53F45327;
                float4 _Property_920AF23F_Out_0 = Vector4_2FA9AEA5;
                float4 _Property_37F6AC84_Out_0 = Vector4_FD283A50;
                float _Property_E7E25E74_Out_0 = Vector1_D6DA4100;
                float _Property_FA2913B0_Out_0 = Vector1_13F2A8C8;
                float3 _Property_4E6AF5FF_Out_0 = Vector3_3AD012AA;
                float3 _Property_A2DA52BE_Out_0 = Vector3_E4AC4432;
                float _Property_9DE15AC9_Out_0 = Vector1_3E452608;
                half3 _CustomFunction_16EDEEAC_Albedo_8;
                half3 _CustomFunction_16EDEEAC_NormalTS_7;
                half3 _CustomFunction_16EDEEAC_Emission_9;
                half _CustomFunction_16EDEEAC_Smoothness_10;
                CrestNodeFoam_half(Texture2D_D9E7A343, _Property_6338038D_Out_0, _Property_C8444C80_Out_0, _Property_3DF87814_Out_0, _Property_589C4301_Out_0, _Property_E9D88423_Out_0, _Property_366CB823_Out_0, _Property_1F5469F5_Out_0, _Property_920AF23F_Out_0, _Property_37F6AC84_Out_0, _Property_E7E25E74_Out_0, _Property_FA2913B0_Out_0, _CrestFlow_B4596B_DisplacedB_2, _Property_4E6AF5FF_Out_0, _Property_A2DA52BE_Out_0, _Property_9DE15AC9_Out_0, _CustomFunction_16EDEEAC_Albedo_8, _CustomFunction_16EDEEAC_NormalTS_7, _CustomFunction_16EDEEAC_Emission_9, _CustomFunction_16EDEEAC_Smoothness_10);
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_E9D68DEC_Out_0 = _CustomFunction_16EDEEAC_Albedo_8;
                #else
                float3 _FOAM_E9D68DEC_Out_0 = float3(0, 0, 0);
                #endif
                float3 _Multiply_BCF80692_Out_2;
                Unity_Multiply_float((_CrestFlow_B4596B_WeightB_4.xxx), _FOAM_E9D68DEC_Out_0, _Multiply_BCF80692_Out_2);
                float3 _Add_48FC5557_Out_2;
                Unity_Add_float3(_Multiply_278EF57C_Out_2, _Multiply_BCF80692_Out_2, _Add_48FC5557_Out_2);
                #if defined(CREST_FLOW_ON)
                float3 _FLOW_1260C700_Out_0 = _Add_48FC5557_Out_2;
                #else
                float3 _FLOW_1260C700_Out_0 = _FOAM_384819B4_Out_0;
                #endif
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_14E9F7C1_Out_0 = _CustomFunction_2B0D0960_NormalTS_7;
                #else
                float3 _FOAM_14E9F7C1_Out_0 = _Property_EB1DCAFB_Out_0;
                #endif
                float3 _Multiply_FAB0278F_Out_2;
                Unity_Multiply_float(_FOAM_14E9F7C1_Out_0, (_CrestFlow_B4596B_WeightA_3.xxx), _Multiply_FAB0278F_Out_2);
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_9C6E353_Out_0 = _CustomFunction_16EDEEAC_NormalTS_7;
                #else
                float3 _FOAM_9C6E353_Out_0 = _Property_4E6AF5FF_Out_0;
                #endif
                float3 _Multiply_CE1E9F74_Out_2;
                Unity_Multiply_float((_CrestFlow_B4596B_WeightB_4.xxx), _FOAM_9C6E353_Out_0, _Multiply_CE1E9F74_Out_2);
                float3 _Add_3A03EC0D_Out_2;
                Unity_Add_float3(_Multiply_FAB0278F_Out_2, _Multiply_CE1E9F74_Out_2, _Add_3A03EC0D_Out_2);
                #if defined(CREST_FLOW_ON)
                float3 _FLOW_2D8BA180_Out_0 = _Add_3A03EC0D_Out_2;
                #else
                float3 _FLOW_2D8BA180_Out_0 = _FOAM_14E9F7C1_Out_0;
                #endif
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_D8E821F0_Out_0 = _CustomFunction_2B0D0960_Emission_9;
                #else
                float3 _FOAM_D8E821F0_Out_0 = _Property_A2BD94BA_Out_0;
                #endif
                float3 _Multiply_716921DC_Out_2;
                Unity_Multiply_float(_FOAM_D8E821F0_Out_0, (_CrestFlow_B4596B_WeightA_3.xxx), _Multiply_716921DC_Out_2);
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_9468CE46_Out_0 = _CustomFunction_16EDEEAC_Emission_9;
                #else
                float3 _FOAM_9468CE46_Out_0 = _Property_A2DA52BE_Out_0;
                #endif
                float3 _Multiply_A0DE696C_Out_2;
                Unity_Multiply_float((_CrestFlow_B4596B_WeightB_4.xxx), _FOAM_9468CE46_Out_0, _Multiply_A0DE696C_Out_2);
                float3 _Add_2EBEBFCF_Out_2;
                Unity_Add_float3(_Multiply_716921DC_Out_2, _Multiply_A0DE696C_Out_2, _Add_2EBEBFCF_Out_2);
                #if defined(CREST_FLOW_ON)
                float3 _FLOW_225158E3_Out_0 = _Add_2EBEBFCF_Out_2;
                #else
                float3 _FLOW_225158E3_Out_0 = _FOAM_D8E821F0_Out_0;
                #endif
                #if defined(CREST_FOAM_ON)
                float _FOAM_F0F633C_Out_0 = _CustomFunction_2B0D0960_Smoothness_10;
                #else
                float _FOAM_F0F633C_Out_0 = _Property_7BFA2B51_Out_0;
                #endif
                float _Multiply_C03E7AFC_Out_2;
                Unity_Multiply_float(_FOAM_F0F633C_Out_0, _CrestFlow_B4596B_WeightA_3, _Multiply_C03E7AFC_Out_2);
                #if defined(CREST_FOAM_ON)
                float _FOAM_AB9E199D_Out_0 = _CustomFunction_16EDEEAC_Smoothness_10;
                #else
                float _FOAM_AB9E199D_Out_0 = _Property_9DE15AC9_Out_0;
                #endif
                float _Multiply_8F8BE539_Out_2;
                Unity_Multiply_float(_CrestFlow_B4596B_WeightB_4, _FOAM_AB9E199D_Out_0, _Multiply_8F8BE539_Out_2);
                float _Add_7629FC1B_Out_2;
                Unity_Add_float(_Multiply_C03E7AFC_Out_2, _Multiply_8F8BE539_Out_2, _Add_7629FC1B_Out_2);
                #if defined(CREST_FLOW_ON)
                float _FLOW_386EA56_Out_0 = _Add_7629FC1B_Out_2;
                #else
                float _FLOW_386EA56_Out_0 = _FOAM_F0F633C_Out_0;
                #endif
                Albedo_1 = _FLOW_1260C700_Out_0;
                NormalTS_2 = _FLOW_2D8BA180_Out_0;
                Emission_3 = _FLOW_225158E3_Out_0;
                Smoothness_4 = _FLOW_386EA56_Out_0;
            }
            
            void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
            {
                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            }
            
            struct Bindings_CrestOceanPixel_6f6706d805d8e8649adddaaa94260269
            {
                float3 WorldSpaceViewDirection;
                float3 ViewSpacePosition;
                float3 AbsoluteWorldSpacePosition;
                float4 ScreenPosition;
                float FaceSign;
            };
            
            void SG_CrestOceanPixel_6f6706d805d8e8649adddaaa94260269(TEXTURE2D_PARAM(Texture2D_BE500045, samplerTexture2D_BE500045), float4 Texture2D_BE500045_TexelSize, float2 Vector2_2F51BFFE, float Vector1_1CEB35D8, float Vector1_43921196, float Vector1_E301593B, float Vector1_958E8942, float Vector1_2ED4C943, float Vector1_BF3AF964, float3 Vector3_EEEBAAB5, float Vector1_D3410E3, float Vector1_1EC1FE35, float2 Vector2_9C73A0C6, float Vector1_B01E1A6A, float Vector1_D74C6609, float Vector1_B61034CA, float2 Vector2_AE8873FA, float2 Vector2_69CC43DC, float Vector1_255AB964, float Vector1_47308CC2, float Vector1_26549044, float Vector1_177E111C, float Vector1_33255829, TEXTURE2D_PARAM(Texture2D_40AB1455, samplerTexture2D_40AB1455), float4 Texture2D_40AB1455_TexelSize, float Vector1_23A72EC7, float Vector1_F406EE17, float4 Vector4_2F6E352, float3 Vector3_57B74D6A, float4 Vector4_B3AD63B4, float Vector1_FA688590, float Vector1_9835666E, float Vector1_B331E24E, float Vector1_951CF2DF, float4 Vector4_ADCA8891, float Vector1_2E8E2C59, float Vector1_9BD9C342, float3 Vector3_8228B74C, float3 Vector3_B2D6AD84, float3 Vector3_D2C93D25, TEXTURE2D_PARAM(Texture2D_EB8C8549, samplerTexture2D_EB8C8549), float4 Texture2D_EB8C8549_TexelSize, float Vector1_9AE39B77, half Vector1_1B073674, float Vector1_C885385, float Vector1_90CEE6B8, float Vector1_E27586E2, TEXTURE2D_PARAM(Texture2D_DA8A756A, samplerTexture2D_DA8A756A), float4 Texture2D_DA8A756A_TexelSize, float Vector1_C96A6500, float Vector1_1AD36684, float Vector1_9E87174F, float Vector1_80D0DF9E, Bindings_CrestOceanPixel_6f6706d805d8e8649adddaaa94260269 IN, out float3 Albedo_2, out float3 NormalTS_3, out float3 Emission_4, out float Smoothness_5, out float Alpha_1, out float Specular_6)
            {
                float2 _Property_B9BA8901_Out_0 = Vector2_2F51BFFE;
                float _Property_6AEC3552_Out_0 = Vector1_1CEB35D8;
                float _Property_76EA797B_Out_0 = Vector1_43921196;
                float _Property_83C2E998_Out_0 = Vector1_E301593B;
                float _Property_705FD8D9_Out_0 = Vector1_958E8942;
                float _Property_735B5A53_Out_0 = Vector1_2ED4C943;
                float _Property_EB4C03CF_Out_0 = Vector1_BF3AF964;
                Bindings_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d _CrestDrivenData_6635D6E9;
                half _CrestDrivenData_6635D6E9_MeshScaleAlpha_1;
                half _CrestDrivenData_6635D6E9_LodDataTexelSize_8;
                half _CrestDrivenData_6635D6E9_GeometryGridSize_2;
                half3 _CrestDrivenData_6635D6E9_OceanPosScale0_3;
                half3 _CrestDrivenData_6635D6E9_OceanPosScale1_4;
                half4 _CrestDrivenData_6635D6E9_OceanParams0_5;
                half4 _CrestDrivenData_6635D6E9_OceanParams1_6;
                half _CrestDrivenData_6635D6E9_SliceIndex0_7;
                SG_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d(_CrestDrivenData_6635D6E9, _CrestDrivenData_6635D6E9_MeshScaleAlpha_1, _CrestDrivenData_6635D6E9_LodDataTexelSize_8, _CrestDrivenData_6635D6E9_GeometryGridSize_2, _CrestDrivenData_6635D6E9_OceanPosScale0_3, _CrestDrivenData_6635D6E9_OceanPosScale1_4, _CrestDrivenData_6635D6E9_OceanParams0_5, _CrestDrivenData_6635D6E9_OceanParams1_6, _CrestDrivenData_6635D6E9_SliceIndex0_7);
                float _Property_EE920C2C_Out_0 = Vector1_B61034CA;
                float _Property_8BC6F5AD_Out_0 = Vector1_B01E1A6A;
                float2 _Property_A2CEB215_Out_0 = Vector2_9C73A0C6;
                float _Property_A636CE7E_Out_0 = Vector1_23A72EC7;
                float _Property_C1531E4C_Out_0 = Vector1_F406EE17;
                float _Property_C7723E93_Out_0 = Vector1_B01E1A6A;
                float2 _Property_94C56295_Out_0 = Vector2_9C73A0C6;
                float2 _Property_E65AA85_Out_0 = Vector2_69CC43DC;
                float3 _Normalize_3574419A_Out_1;
                Unity_Normalize_float3(IN.WorldSpaceViewDirection, _Normalize_3574419A_Out_1);
                Bindings_CrestComputeNormal_61b9efc6612ab3b4f84174344af5e12a _CrestComputeNormal_6DAE4B39;
                _CrestComputeNormal_6DAE4B39.FaceSign = IN.FaceSign;
                half3 _CrestComputeNormal_6DAE4B39_Normal_1;
                SG_CrestComputeNormal_61b9efc6612ab3b4f84174344af5e12a(_CrestDrivenData_6635D6E9_OceanPosScale0_3, _CrestDrivenData_6635D6E9_OceanPosScale1_4, _CrestDrivenData_6635D6E9_OceanParams0_5, _CrestDrivenData_6635D6E9_OceanParams1_6, _CrestDrivenData_6635D6E9_SliceIndex0_7, TEXTURE2D_ARGS(Texture2D_40AB1455, samplerTexture2D_40AB1455), Texture2D_40AB1455_TexelSize, _Property_A636CE7E_Out_0, _Property_C1531E4C_Out_0, _Property_C7723E93_Out_0, _Property_94C56295_Out_0, _Property_E65AA85_Out_0, _Normalize_3574419A_Out_1, _CrestComputeNormal_6DAE4B39, _CrestComputeNormal_6DAE4B39_Normal_1);
                float _Property_FCAEBD15_Out_0 = Vector1_9E87174F;
                float _Property_2D376CE_Out_0 = Vector1_80D0DF9E;
                Bindings_CrestFresnel_c6f6c13c4fdb04e42b427e4c2610d3c9 _CrestFresnel_FD3200EB;
                _CrestFresnel_FD3200EB.FaceSign = IN.FaceSign;
                float _CrestFresnel_FD3200EB_LightTransmitted_1;
                float _CrestFresnel_FD3200EB_LightReflected_2;
                SG_CrestFresnel_c6f6c13c4fdb04e42b427e4c2610d3c9(_CrestComputeNormal_6DAE4B39_Normal_1, _Normalize_3574419A_Out_1, _Property_FCAEBD15_Out_0, _Property_2D376CE_Out_0, _CrestFresnel_FD3200EB, _CrestFresnel_FD3200EB_LightTransmitted_1, _CrestFresnel_FD3200EB_LightReflected_2);
                float _Property_2599690E_Out_0 = Vector1_9BD9C342;
                float3 _Property_A57CAD6E_Out_0 = Vector3_8228B74C;
                float4 _Property_479D2E13_Out_0 = Vector4_2F6E352;
                float3 _Property_F631E4E0_Out_0 = Vector3_57B74D6A;
                float4 _Property_D9155CD7_Out_0 = Vector4_B3AD63B4;
                float _Property_D8B923AB_Out_0 = Vector1_FA688590;
                float _Property_F7F4791A_Out_0 = Vector1_9835666E;
                float _Property_2ABF6C61_Out_0 = Vector1_B331E24E;
                float _Property_22A5FA38_Out_0 = Vector1_951CF2DF;
                float4 _Property_C1E8071C_Out_0 = Vector4_ADCA8891;
                float _Property_9AD6466F_Out_0 = Vector1_2E8E2C59;
                float _Property_4D8B881_Out_0 = Vector1_D74C6609;
                float2 _Property_5A879B44_Out_0 = Vector2_AE8873FA;
                float _Property_41C453D9_Out_0 = Vector1_255AB964;
                float3 _CustomFunction_C3448D1A_AmbientLighting_0;
                GetAmbientLighting_float(_CustomFunction_C3448D1A_AmbientLighting_0);
                float3 _Property_13E6764D_Out_0 = Vector3_B2D6AD84;
                float3 _Property_2FA7DB0_Out_0 = Vector3_D2C93D25;
                Bindings_CrestVolumeLighting_e9ed6e11710a50640bb4b811d0fa84f2 _CrestVolumeLighting_5A1A391;
                half3 _CrestVolumeLighting_5A1A391_VolumeLighting_1;
                SG_CrestVolumeLighting_e9ed6e11710a50640bb4b811d0fa84f2(_Property_479D2E13_Out_0, _Property_F631E4E0_Out_0, _Property_D9155CD7_Out_0, _Property_D8B923AB_Out_0, _Property_F7F4791A_Out_0, _Property_2ABF6C61_Out_0, _Property_22A5FA38_Out_0, _Property_C1E8071C_Out_0, _Property_9AD6466F_Out_0, _Property_4D8B881_Out_0, _Property_5A879B44_Out_0, _Property_41C453D9_Out_0, _Normalize_3574419A_Out_1, IN.AbsoluteWorldSpacePosition, _CustomFunction_C3448D1A_AmbientLighting_0, _Property_13E6764D_Out_0, _Property_2FA7DB0_Out_0, _CrestVolumeLighting_5A1A391, _CrestVolumeLighting_5A1A391_VolumeLighting_1);
                float4 _ScreenPosition_42FE0E3E_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                float _Split_66230827_R_1 = IN.ViewSpacePosition[0];
                float _Split_66230827_G_2 = IN.ViewSpacePosition[1];
                float _Split_66230827_B_3 = IN.ViewSpacePosition[2];
                float _Split_66230827_A_4 = 0;
                float _Negate_5F3C7D3D_Out_1;
                Unity_Negate_float(_Split_66230827_B_3, _Negate_5F3C7D3D_Out_1);
                float3 _SceneColor_61626E7C_Out_1;
                Unity_SceneColor_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneColor_61626E7C_Out_1);
                float _SceneDepth_FD35F7D9_Out_1;
                Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_FD35F7D9_Out_1);
                float3 _Property_DC1C088D_Out_0 = Vector3_B2D6AD84;
                float _Property_8BC39E79_Out_0 = Vector1_9AE39B77;
                half _Property_683CAF2_Out_0 = Vector1_1B073674;
                float _Property_B4B35559_Out_0 = Vector1_C885385;
                float _Property_E694F888_Out_0 = Vector1_90CEE6B8;
                float _Property_50A87698_Out_0 = Vector1_E27586E2;
                float _Property_8BC9D755_Out_0 = Vector1_C96A6500;
                float _Property_6F95DFBF_Out_0 = Vector1_1AD36684;
                float3 _Property_4729CD24_Out_0 = Vector3_EEEBAAB5;
                float _Property_C36E9B6_Out_0 = Vector1_D3410E3;
                float _Property_2C173F60_Out_0 = Vector1_1EC1FE35;
                float2 _Property_4258AA49_Out_0 = Vector2_2F51BFFE;
                float _Property_3FC34BC9_Out_0 = Vector1_1CEB35D8;
                float _Property_D42BE95B_Out_0 = Vector1_B61034CA;
                float _Split_CEEBC462_R_1 = IN.AbsoluteWorldSpacePosition[0];
                float _Split_CEEBC462_G_2 = IN.AbsoluteWorldSpacePosition[1];
                float _Split_CEEBC462_B_3 = IN.AbsoluteWorldSpacePosition[2];
                float _Split_CEEBC462_A_4 = 0;
                float2 _Vector2_BB7CEEF5_Out_0 = float2(_Split_CEEBC462_R_1, _Split_CEEBC462_B_3);
                float2 _Property_305FB73_Out_0 = Vector2_9C73A0C6;
                float _Property_88A7570_Out_0 = Vector1_B01E1A6A;
                float2 _Property_5CBA815_Out_0 = Vector2_69CC43DC;
                Bindings_CrestFoamBubblesWithFlow_e132fba35874b4923988ef35a40e48c3 _CrestFoamBubblesWithFlow_F7286BE2;
                float3 _CrestFoamBubblesWithFlow_F7286BE2_Colour_1;
                SG_CrestFoamBubblesWithFlow_e132fba35874b4923988ef35a40e48c3(_Property_4729CD24_Out_0, _Property_C36E9B6_Out_0, _Property_2C173F60_Out_0, TEXTURE2D_ARGS(Texture2D_BE500045, samplerTexture2D_BE500045), Texture2D_BE500045_TexelSize, _Property_4258AA49_Out_0, _Property_3FC34BC9_Out_0, _Property_D42BE95B_Out_0, _CrestComputeNormal_6DAE4B39_Normal_1, _CrestDrivenData_6635D6E9_OceanParams0_5, _CrestDrivenData_6635D6E9_OceanParams1_6, _Vector2_BB7CEEF5_Out_0, _Property_305FB73_Out_0, _Property_88A7570_Out_0, _Normalize_3574419A_Out_1, _Property_5CBA815_Out_0, _CrestFoamBubblesWithFlow_F7286BE2, _CrestFoamBubblesWithFlow_F7286BE2_Colour_1);
                Bindings_CrestEmission_8c56460232fde1e46ae90d905a00f908 _CrestEmission_6580C0F9;
                float3 _CrestEmission_6580C0F9_EmittedLight_1;
                SG_CrestEmission_8c56460232fde1e46ae90d905a00f908(_Property_2599690E_Out_0, _Property_A57CAD6E_Out_0, _CrestVolumeLighting_5A1A391_VolumeLighting_1, _Normalize_3574419A_Out_1, _CrestComputeNormal_6DAE4B39_Normal_1, _ScreenPosition_42FE0E3E_Out_0, _Negate_5F3C7D3D_Out_1, _SceneColor_61626E7C_Out_1, _SceneDepth_FD35F7D9_Out_1, _Property_DC1C088D_Out_0, TEXTURE2D_ARGS(Texture2D_EB8C8549, samplerTexture2D_EB8C8549), Texture2D_EB8C8549_TexelSize, _Property_8BC39E79_Out_0, _Property_683CAF2_Out_0, _Property_B4B35559_Out_0, _Property_E694F888_Out_0, _Property_50A87698_Out_0, TEXTURE2D_ARGS(Texture2D_DA8A756A, samplerTexture2D_DA8A756A), Texture2D_DA8A756A_TexelSize, _Property_8BC9D755_Out_0, _Property_6F95DFBF_Out_0, _CrestFoamBubblesWithFlow_F7286BE2_Colour_1, _CrestEmission_6580C0F9, _CrestEmission_6580C0F9_EmittedLight_1);
                float3 _Multiply_CFF25F4B_Out_2;
                Unity_Multiply_float((_CrestFresnel_FD3200EB_LightTransmitted_1.xxx), _CrestEmission_6580C0F9_EmittedLight_1, _Multiply_CFF25F4B_Out_2);
                float _Property_5DA83C2A_Out_0 = Vector1_47308CC2;
                float _Property_44533AA4_Out_0 = Vector1_26549044;
                float _Property_19CC00AB_Out_0 = Vector1_177E111C;
                float _Divide_6B6C7F25_Out_2;
                Unity_Divide_float(_Negate_5F3C7D3D_Out_1, _Property_19CC00AB_Out_0, _Divide_6B6C7F25_Out_2);
                float _Saturate_D69CDED6_Out_1;
                Unity_Saturate_float(_Divide_6B6C7F25_Out_2, _Saturate_D69CDED6_Out_1);
                float _Property_8033277F_Out_0 = Vector1_33255829;
                float _Power_BC121A67_Out_2;
                Unity_Power_float(_Saturate_D69CDED6_Out_1, _Property_8033277F_Out_0, _Power_BC121A67_Out_2);
                float _Lerp_3E7590A8_Out_3;
                Unity_Lerp_float(_Property_5DA83C2A_Out_0, _Property_44533AA4_Out_0, _Power_BC121A67_Out_2, _Lerp_3E7590A8_Out_3);
                float2 _Property_374C5B7E_Out_0 = Vector2_69CC43DC;
                Bindings_CrestFoamWithFlow_3a6c22dceac0847a2a31cb05a577b963 _CrestFoamWithFlow_193F69CA;
                float3 _CrestFoamWithFlow_193F69CA_Albedo_1;
                float3 _CrestFoamWithFlow_193F69CA_NormalTS_2;
                float3 _CrestFoamWithFlow_193F69CA_Emission_3;
                float _CrestFoamWithFlow_193F69CA_Smoothness_4;
                SG_CrestFoamWithFlow_3a6c22dceac0847a2a31cb05a577b963(TEXTURE2D_ARGS(Texture2D_BE500045, samplerTexture2D_BE500045), Texture2D_BE500045_TexelSize, _Property_B9BA8901_Out_0, _Property_6AEC3552_Out_0, _Property_76EA797B_Out_0, _Property_83C2E998_Out_0, _Property_705FD8D9_Out_0, _Property_735B5A53_Out_0, _Property_EB4C03CF_Out_0, _CrestDrivenData_6635D6E9_OceanParams0_5, _CrestDrivenData_6635D6E9_OceanParams1_6, _Property_EE920C2C_Out_0, _Property_8BC6F5AD_Out_0, _Property_A2CEB215_Out_0, _CrestComputeNormal_6DAE4B39_Normal_1, _Multiply_CFF25F4B_Out_2, _Lerp_3E7590A8_Out_3, _Property_374C5B7E_Out_0, _CrestFoamWithFlow_193F69CA, _CrestFoamWithFlow_193F69CA_Albedo_1, _CrestFoamWithFlow_193F69CA_NormalTS_2, _CrestFoamWithFlow_193F69CA_Emission_3, _CrestFoamWithFlow_193F69CA_Smoothness_4);
                float _Subtract_5BDB5822_Out_2;
                Unity_Subtract_float(_SceneDepth_FD35F7D9_Out_1, _Negate_5F3C7D3D_Out_1, _Subtract_5BDB5822_Out_2);
                float _Remap_D52CFDA9_Out_3;
                Unity_Remap_float(_Subtract_5BDB5822_Out_2, float2 (0, 0.2), float2 (0, 1), _Remap_D52CFDA9_Out_3);
                float _Saturate_896FB384_Out_1;
                Unity_Saturate_float(_Remap_D52CFDA9_Out_3, _Saturate_896FB384_Out_1);
                Albedo_2 = _CrestFoamWithFlow_193F69CA_Albedo_1;
                NormalTS_3 = _CrestFoamWithFlow_193F69CA_NormalTS_2;
                Emission_4 = _CrestFoamWithFlow_193F69CA_Emission_3;
                Smoothness_5 = _CrestFoamWithFlow_193F69CA_Smoothness_4;
                Alpha_1 = _Saturate_896FB384_Out_1;
                Specular_6 = _CrestFresnel_FD3200EB_LightReflected_2;
            }
        
            // Graph Vertex
            struct VertexDescriptionInputs
            {
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 WorldSpaceNormal;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 WorldSpaceTangent;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 ObjectSpaceBiTangent;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 WorldSpaceBiTangent;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 AbsoluteWorldSpacePosition;
                #endif
            };
            
            struct VertexDescription
            {
                float3 VertexPosition;
                float3 VertexNormal;
                float3 VertexTangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                Bindings_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d _CrestDrivenData_A1078169;
                half _CrestDrivenData_A1078169_MeshScaleAlpha_1;
                half _CrestDrivenData_A1078169_LodDataTexelSize_8;
                half _CrestDrivenData_A1078169_GeometryGridSize_2;
                half3 _CrestDrivenData_A1078169_OceanPosScale0_3;
                half3 _CrestDrivenData_A1078169_OceanPosScale1_4;
                half4 _CrestDrivenData_A1078169_OceanParams0_5;
                half4 _CrestDrivenData_A1078169_OceanParams1_6;
                half _CrestDrivenData_A1078169_SliceIndex0_7;
                SG_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d(_CrestDrivenData_A1078169, _CrestDrivenData_A1078169_MeshScaleAlpha_1, _CrestDrivenData_A1078169_LodDataTexelSize_8, _CrestDrivenData_A1078169_GeometryGridSize_2, _CrestDrivenData_A1078169_OceanPosScale0_3, _CrestDrivenData_A1078169_OceanPosScale1_4, _CrestDrivenData_A1078169_OceanParams0_5, _CrestDrivenData_A1078169_OceanParams1_6, _CrestDrivenData_A1078169_SliceIndex0_7);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                Bindings_CrestGeoMorph_9ab91ec3462438049923ca0ff16f68ad _CrestGeoMorph_8F1A4FF1;
                half3 _CrestGeoMorph_8F1A4FF1_MorphedPositionWS_1;
                half _CrestGeoMorph_8F1A4FF1_LodAlpha_2;
                SG_CrestGeoMorph_9ab91ec3462438049923ca0ff16f68ad(IN.AbsoluteWorldSpacePosition, _CrestDrivenData_A1078169_OceanPosScale0_3, _CrestDrivenData_A1078169_MeshScaleAlpha_1, _CrestDrivenData_A1078169_GeometryGridSize_2, _CrestGeoMorph_8F1A4FF1, _CrestGeoMorph_8F1A4FF1_MorphedPositionWS_1, _CrestGeoMorph_8F1A4FF1_LodAlpha_2);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Split_CC063A43_R_1 = _CrestGeoMorph_8F1A4FF1_MorphedPositionWS_1[0];
                float _Split_CC063A43_G_2 = _CrestGeoMorph_8F1A4FF1_MorphedPositionWS_1[1];
                float _Split_CC063A43_B_3 = _CrestGeoMorph_8F1A4FF1_MorphedPositionWS_1[2];
                float _Split_CC063A43_A_4 = 0;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float2 _Vector2_2D46FD43_Out_0 = float2(_Split_CC063A43_R_1, _Split_CC063A43_B_3);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                Bindings_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4 _CrestSampleOceanData_340A6610;
                float3 _CrestSampleOceanData_340A6610_Displacement_1;
                float _CrestSampleOceanData_340A6610_OceanWaterDepth_5;
                float _CrestSampleOceanData_340A6610_Foam_6;
                float2 _CrestSampleOceanData_340A6610_Shadow_7;
                float2 _CrestSampleOceanData_340A6610_Flow_8;
                float _CrestSampleOceanData_340A6610_SubSurfaceScattering_9;
                SG_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4(_Vector2_2D46FD43_Out_0, _CrestGeoMorph_8F1A4FF1_LodAlpha_2, _CrestDrivenData_A1078169_OceanPosScale0_3, _CrestDrivenData_A1078169_OceanPosScale1_4, _CrestDrivenData_A1078169_OceanParams0_5, _CrestDrivenData_A1078169_OceanParams1_6, _CrestDrivenData_A1078169_SliceIndex0_7, _CrestSampleOceanData_340A6610, _CrestSampleOceanData_340A6610_Displacement_1, _CrestSampleOceanData_340A6610_OceanWaterDepth_5, _CrestSampleOceanData_340A6610_Foam_6, _CrestSampleOceanData_340A6610_Shadow_7, _CrestSampleOceanData_340A6610_Flow_8, _CrestSampleOceanData_340A6610_SubSurfaceScattering_9);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 _Add_2D79A354_Out_2;
                Unity_Add_float3(_CrestGeoMorph_8F1A4FF1_MorphedPositionWS_1, _CrestSampleOceanData_340A6610_Displacement_1, _Add_2D79A354_Out_2);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 _Transform_9C2ACF28_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Add_2D79A354_Out_2.xyz));
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 _Transform_86205EE4_Out_1 = TransformWorldToObjectDir(float3 (0, 1, 0).xyz);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 _Transform_22BD1A85_Out_1 = TransformWorldToObjectDir(GetCameraRelativePositionWS(float3 (1, 0, 0).xyz));
                #endif
                description.VertexPosition = _Transform_9C2ACF28_Out_1;
                description.VertexNormal = _Transform_86205EE4_Out_1;
                description.VertexTangent = _Transform_22BD1A85_Out_1;
                return description;
            }
            
            // Graph Pixel
            struct SurfaceDescriptionInputs
            {
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 WorldSpaceViewDirection;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 ViewSpacePosition;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 WorldSpacePosition;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 AbsoluteWorldSpacePosition;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 ScreenPosition;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv0;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv1;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv2;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv3;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float FaceSign;
                #endif
            };
            
            struct SurfaceDescription
            {
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _TexelSize_CA3A0DD6_Width_0 = _TextureFoam_TexelSize.z;
                half _TexelSize_CA3A0DD6_Height_2 = _TextureFoam_TexelSize.w;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half2 _Vector2_15E252FB_Out_0 = half2(_TexelSize_CA3A0DD6_Width_0, _TexelSize_CA3A0DD6_Height_2);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_87E9391A_Out_0 = _FoamScale;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_BC30BCB6_Out_0 = _FoamFeather;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_5E8CB038_Out_0 = _FoamIntensityAlbedo;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_77A524C7_Out_0 = _FoamIntensityEmissive;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_CED296A4_Out_0 = _FoamSmoothness;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_D1CA3C84_Out_0 = _FoamNormalStrength;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half4 _Property_3BAB5FF_Out_0 = _FoamBubbleColor;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_EDC4DC3C_Out_0 = _FoamBubbleParallax;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_E7925FBA_Out_0 = _FoamBubblesCoverage;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                Bindings_CrestUnpackData_5bc4cf08f88035c489658d60edefeec8 _CrestUnpackData_C3998C1C;
                _CrestUnpackData_C3998C1C.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
                _CrestUnpackData_C3998C1C.uv0 = IN.uv0;
                _CrestUnpackData_C3998C1C.uv1 = IN.uv1;
                _CrestUnpackData_C3998C1C.uv2 = IN.uv2;
                float2 _CrestUnpackData_C3998C1C_PositionXZWSUndisp_2;
                float _CrestUnpackData_C3998C1C_LodAlpha_1;
                float _CrestUnpackData_C3998C1C_OceanDepth_3;
                float _CrestUnpackData_C3998C1C_Foam_4;
                float2 _CrestUnpackData_C3998C1C_Shadow_5;
                float2 _CrestUnpackData_C3998C1C_Flow_6;
                float _CrestUnpackData_C3998C1C_SubSurfaceScattering_7;
                SG_CrestUnpackData_5bc4cf08f88035c489658d60edefeec8(_CrestUnpackData_C3998C1C, _CrestUnpackData_C3998C1C_PositionXZWSUndisp_2, _CrestUnpackData_C3998C1C_LodAlpha_1, _CrestUnpackData_C3998C1C_OceanDepth_3, _CrestUnpackData_C3998C1C_Foam_4, _CrestUnpackData_C3998C1C_Shadow_5, _CrestUnpackData_C3998C1C_Flow_6, _CrestUnpackData_C3998C1C_SubSurfaceScattering_7);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_994CB3A3_Out_0 = _Smoothness;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_7079FD32_Out_0 = _SmoothnessFar;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_FAEF961B_Out_0 = _SmoothnessFarDistance;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_35DA1E70_Out_0 = _SmoothnessFalloff;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_D1430252_Out_0 = _NormalsScale;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_B882DB1E_Out_0 = _NormalsStrength;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half4 _Property_B5E474DF_Out_0 = _ScatterColourBase;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 _Property_B98AE6FA_Out_0 = _ScatterColourShallow;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_CF7CEF3A_Out_0 = _ScatterColourShallowDepthMax;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_698A3C81_Out_0 = _ScatterColourShallowDepthFalloff;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_5924F1E9_Out_0 = _SSSIntensityBase;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_67308B5F_Out_0 = _SSSIntensitySun;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half4 _Property_A723E757_Out_0 = _SSSTint;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_5AD6818A_Out_0 = _SSSSunFalloff;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_888FA49_Out_0 = _RefractionStrength;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half3 _Property_F1315B19_Out_0 = _DepthFogDensity;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                Bindings_CrestLightData_b74b6e8c0b489314ca7aea3e2cc9c54c _CrestLightData_5AD806DD;
                half3 _CrestLightData_5AD806DD_Direction_1;
                half3 _CrestLightData_5AD806DD_Intensity_2;
                SG_CrestLightData_b74b6e8c0b489314ca7aea3e2cc9c54c(_CrestLightData_5AD806DD, _CrestLightData_5AD806DD_Direction_1, _CrestLightData_5AD806DD_Intensity_2);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_A26763AB_Out_0 = _CausticsTextureScale;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_3230CB90_Out_0 = _CausticsTextureAverage;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_6B2F7D3E_Out_0 = _CausticsStrength;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_D5C90779_Out_0 = _CausticsFocalDepth;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_2743B36F_Out_0 = _CausticsDepthOfField;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_61877218_Out_0 = _CausticsDistortionStrength;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_5F1E3794_Out_0 = _CausticsDistortionScale;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                Bindings_CrestOceanPixel_6f6706d805d8e8649adddaaa94260269 _CrestOceanPixel_51593A7C;
                _CrestOceanPixel_51593A7C.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
                _CrestOceanPixel_51593A7C.ViewSpacePosition = IN.ViewSpacePosition;
                _CrestOceanPixel_51593A7C.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
                _CrestOceanPixel_51593A7C.ScreenPosition = IN.ScreenPosition;
                _CrestOceanPixel_51593A7C.FaceSign = IN.FaceSign;
                float3 _CrestOceanPixel_51593A7C_Albedo_2;
                float3 _CrestOceanPixel_51593A7C_NormalTS_3;
                float3 _CrestOceanPixel_51593A7C_Emission_4;
                float _CrestOceanPixel_51593A7C_Smoothness_5;
                float _CrestOceanPixel_51593A7C_Alpha_1;
                float _CrestOceanPixel_51593A7C_Specular_6;
                SG_CrestOceanPixel_6f6706d805d8e8649adddaaa94260269(TEXTURE2D_ARGS(_TextureFoam, sampler_TextureFoam), _TextureFoam_TexelSize, _Vector2_15E252FB_Out_0, _Property_87E9391A_Out_0, _Property_BC30BCB6_Out_0, _Property_5E8CB038_Out_0, _Property_77A524C7_Out_0, _Property_CED296A4_Out_0, _Property_D1CA3C84_Out_0, (_Property_3BAB5FF_Out_0.xyz), _Property_EDC4DC3C_Out_0, _Property_E7925FBA_Out_0, _CrestUnpackData_C3998C1C_PositionXZWSUndisp_2, _CrestUnpackData_C3998C1C_LodAlpha_1, _CrestUnpackData_C3998C1C_OceanDepth_3, _CrestUnpackData_C3998C1C_Foam_4, _CrestUnpackData_C3998C1C_Shadow_5, _CrestUnpackData_C3998C1C_Flow_6, _CrestUnpackData_C3998C1C_SubSurfaceScattering_7, _Property_994CB3A3_Out_0, _Property_7079FD32_Out_0, _Property_FAEF961B_Out_0, _Property_35DA1E70_Out_0, TEXTURE2D_ARGS(_TextureNormals, sampler_TextureNormals), _TextureNormals_TexelSize, _Property_D1430252_Out_0, _Property_B882DB1E_Out_0, _Property_B5E474DF_Out_0, float3 (0, 0, 0), _Property_B98AE6FA_Out_0, _Property_CF7CEF3A_Out_0, _Property_698A3C81_Out_0, _Property_5924F1E9_Out_0, _Property_67308B5F_Out_0, _Property_A723E757_Out_0, _Property_5AD6818A_Out_0, _Property_888FA49_Out_0, _Property_F1315B19_Out_0, _CrestLightData_5AD806DD_Direction_1, _CrestLightData_5AD806DD_Intensity_2, TEXTURE2D_ARGS(_CausticsTexture, sampler_CausticsTexture), _CausticsTexture_TexelSize, _Property_A26763AB_Out_0, _Property_3230CB90_Out_0, _Property_6B2F7D3E_Out_0, _Property_D5C90779_Out_0, _Property_2743B36F_Out_0, TEXTURE2D_ARGS(_CausticsDistortionTexture, sampler_CausticsDistortionTexture), _CausticsDistortionTexture_TexelSize, _Property_61877218_Out_0, _Property_5F1E3794_Out_0, 1.33, 1, _CrestOceanPixel_51593A7C, _CrestOceanPixel_51593A7C_Albedo_2, _CrestOceanPixel_51593A7C_NormalTS_3, _CrestOceanPixel_51593A7C_Emission_4, _CrestOceanPixel_51593A7C_Smoothness_5, _CrestOceanPixel_51593A7C_Alpha_1, _CrestOceanPixel_51593A7C_Specular_6);
                #endif
                surface.Alpha = _CrestOceanPixel_51593A7C_Alpha_1;
                surface.AlphaClipThreshold = 0;
                return surface;
            }
        
            // --------------------------------------------------
            // Structs and Packing
        
            // Generated Type: Attributes
            struct Attributes
            {
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 positionOS : POSITION;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 normalOS : NORMAL;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 tangentOS : TANGENT;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv0 : TEXCOORD0;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv1 : TEXCOORD1;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv2 : TEXCOORD2;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv3 : TEXCOORD3;
                #endif
                #if UNITY_ANY_INSTANCING_ENABLED
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                uint instanceID : INSTANCEID_SEMANTIC;
                #endif
                #endif
            };
        
            // Generated Type: Varyings
            struct Varyings
            {
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 positionCS : SV_Position;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 positionWS;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 texCoord0;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 texCoord1;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 texCoord2;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 texCoord3;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 viewDirectionWS;
                #endif
                #if UNITY_ANY_INSTANCING_ENABLED
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #endif
            };
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            // Generated Type: PackedVaryings
            struct PackedVaryings
            {
                float4 positionCS : SV_Position;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                float3 interp00 : TEXCOORD0;
                float4 interp01 : TEXCOORD1;
                float4 interp02 : TEXCOORD2;
                float4 interp03 : TEXCOORD3;
                float4 interp04 : TEXCOORD4;
                float3 interp05 : TEXCOORD5;
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Packed Type: Varyings
            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output;
                output.positionCS = input.positionCS;
                output.interp00.xyz = input.positionWS;
                output.interp01.xyzw = input.texCoord0;
                output.interp02.xyzw = input.texCoord1;
                output.interp03.xyzw = input.texCoord2;
                output.interp04.xyzw = input.texCoord3;
                output.interp05.xyz = input.viewDirectionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                return output;
            }
            
            // Unpacked Type: Varyings
            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.positionWS = input.interp00.xyz;
                output.texCoord0 = input.interp01.xyzw;
                output.texCoord1 = input.interp02.xyzw;
                output.texCoord2 = input.interp03.xyzw;
                output.texCoord3 = input.interp04.xyzw;
                output.viewDirectionWS = input.interp05.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                return output;
            }
            #endif
        
            // --------------------------------------------------
            // Build Graph Inputs
        
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            #endif
            
            
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
            #endif
            
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS.xyz, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
            #endif
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
            #endif
            
            
            
            
            
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
            #endif
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
                return output;
            }
            
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            
            
            
            
            
            
            
            
            
            
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            #endif
            
            
            
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.WorldSpacePosition =          input.positionWS;
            #endif
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.ViewSpacePosition =           TransformWorldToView(input.positionWS);
            #endif
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(input.positionWS);
            #endif
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            #endif
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.uv0 =                         input.texCoord0;
            #endif
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.uv1 =                         input.texCoord1;
            #endif
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.uv2 =                         input.texCoord2;
            #endif
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.uv3 =                         input.texCoord3;
            #endif
            
            
            
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                return output;
            }
            
        
            // --------------------------------------------------
            // Main
        
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
            ENDHLSL
        }
        */

		/*
        Pass
        {
            Name "DepthOnly"
            Tags 
            { 
                "LightMode" = "DepthOnly"
            }
           
            // Render State
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            Cull Off
            ZTest LEqual
            ZWrite On
            ColorMask 0
        
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
        
            // Debug
            // <None>
        
            // --------------------------------------------------
            // Pass
        
            // Pragmas
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            #pragma multi_compile_instancing
        
            // Keywords
            // PassKeywords: <None>
            #pragma shader_feature_local _ CREST_FOAM_ON
            #pragma shader_feature_local _ CREST_CAUSTICS_ON
            #pragma shader_feature_local _ CREST_FLOW_ON
            
            #if defined(CREST_FOAM_ON) && defined(CREST_CAUSTICS_ON) && defined(CREST_FLOW_ON)
                #define KEYWORD_PERMUTATION_0
            #elif defined(CREST_FOAM_ON) && defined(CREST_CAUSTICS_ON)
                #define KEYWORD_PERMUTATION_1
            #elif defined(CREST_FOAM_ON) && defined(CREST_FLOW_ON)
                #define KEYWORD_PERMUTATION_2
            #elif defined(CREST_FOAM_ON)
                #define KEYWORD_PERMUTATION_3
            #elif defined(CREST_CAUSTICS_ON) && defined(CREST_FLOW_ON)
                #define KEYWORD_PERMUTATION_4
            #elif defined(CREST_CAUSTICS_ON)
                #define KEYWORD_PERMUTATION_5
            #elif defined(CREST_FLOW_ON)
                #define KEYWORD_PERMUTATION_6
            #else
                #define KEYWORD_PERMUTATION_7
            #endif
            
            
            // Defines
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define _SURFACE_TYPE_TRANSPARENT 1
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define _NORMALMAP 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define _SPECULAR_SETUP
        #endif
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD2
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD3
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_POSITION_WS 
        #endif
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD2
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD3
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #endif
        
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_CULLFACE
        #endif
        
            #define FEATURES_GRAPH_VERTEX
            #define SHADERPASS_DEPTHONLY
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #define REQUIRE_DEPTH_TEXTURE
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #define REQUIRE_OPAQUE_TEXTURE
            #endif
        
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
            // --------------------------------------------------
            // Graph
        
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            half _Smoothness;
            float _SmoothnessFar;
            float _SmoothnessFarDistance;
            float _SmoothnessFalloff;
            float _Specular;
            float _Occlusion;
            half4 _ScatterColourBase;
            float4 _ScatterColourShallow;
            half _ScatterColourShallowDepthMax;
            half _ScatterColourShallowDepthFalloff;
            half _NormalsScale;
            half _NormalsStrength;
            half _SSSIntensityBase;
            half _SSSIntensitySun;
            half4 _SSSTint;
            half _SSSSunFalloff;
            half _RefractionStrength;
            half3 _DepthFogDensity;
            half _FoamScale;
            half _FoamFeather;
            half _FoamIntensityAlbedo;
            half _FoamIntensityEmissive;
            half _FoamSmoothness;
            half _FoamNormalStrength;
            half4 _FoamBubbleColor;
            half _FoamBubbleParallax;
            half _FoamBubblesCoverage;
            float _CausticsTextureScale;
            float _CausticsTextureAverage;
            float _CausticsStrength;
            float _CausticsFocalDepth;
            float _CausticsDepthOfField;
            float _CausticsDistortionStrength;
            float _CausticsDistortionScale;
            CBUFFER_END
            TEXTURE2D(_TextureNormals); SAMPLER(sampler_TextureNormals); float4 _TextureNormals_TexelSize;
            TEXTURE2D(_TextureFoam); SAMPLER(sampler_TextureFoam); half4 _TextureFoam_TexelSize;
            TEXTURE2D(_CausticsTexture); SAMPLER(sampler_CausticsTexture); float4 _CausticsTexture_TexelSize;
            TEXTURE2D(_CausticsDistortionTexture); SAMPLER(sampler_CausticsDistortionTexture); float4 _CausticsDistortionTexture_TexelSize;
            SAMPLER(SamplerState_Linear_Repeat);
        
            // Graph Functions
            
            // dc55dc563cc13ab0a4a38f335aac9cb2
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeDrivenInputs.hlsl"
            
            struct Bindings_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d
            {
            };
            
            void SG_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d(Bindings_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d IN, out half MeshScaleAlpha_1, out half LodDataTexelSize_8, out half GeometryGridSize_2, out half3 OceanPosScale0_3, out half3 OceanPosScale1_4, out half4 OceanParams0_5, out half4 OceanParams1_6, out half SliceIndex0_7)
            {
                half _CustomFunction_CD9A5F8F_MeshScaleAlpha_9;
                half _CustomFunction_CD9A5F8F_LodDataTexelSize_10;
                half _CustomFunction_CD9A5F8F_GeometryGridSize_14;
                half3 _CustomFunction_CD9A5F8F_OceanPosScale0_7;
                half3 _CustomFunction_CD9A5F8F_OceanPosScale1_8;
                half4 _CustomFunction_CD9A5F8F_OceanParams0_11;
                half4 _CustomFunction_CD9A5F8F_OceanParams1_12;
                half _CustomFunction_CD9A5F8F_SliceIndex0_13;
                CrestOceanSurfaceValues_half(_CustomFunction_CD9A5F8F_MeshScaleAlpha_9, _CustomFunction_CD9A5F8F_LodDataTexelSize_10, _CustomFunction_CD9A5F8F_GeometryGridSize_14, _CustomFunction_CD9A5F8F_OceanPosScale0_7, _CustomFunction_CD9A5F8F_OceanPosScale1_8, _CustomFunction_CD9A5F8F_OceanParams0_11, _CustomFunction_CD9A5F8F_OceanParams1_12, _CustomFunction_CD9A5F8F_SliceIndex0_13);
                MeshScaleAlpha_1 = _CustomFunction_CD9A5F8F_MeshScaleAlpha_9;
                LodDataTexelSize_8 = _CustomFunction_CD9A5F8F_LodDataTexelSize_10;
                GeometryGridSize_2 = _CustomFunction_CD9A5F8F_GeometryGridSize_14;
                OceanPosScale0_3 = _CustomFunction_CD9A5F8F_OceanPosScale0_7;
                OceanPosScale1_4 = _CustomFunction_CD9A5F8F_OceanPosScale1_8;
                OceanParams0_5 = _CustomFunction_CD9A5F8F_OceanParams0_11;
                OceanParams1_6 = _CustomFunction_CD9A5F8F_OceanParams1_12;
                SliceIndex0_7 = _CustomFunction_CD9A5F8F_SliceIndex0_13;
            }
            
            // 0749fb83929f8caedf1bd96120cd0442
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeGeoMorph.hlsl"
            
            struct Bindings_CrestGeoMorph_9ab91ec3462438049923ca0ff16f68ad
            {
            };
            
            void SG_CrestGeoMorph_9ab91ec3462438049923ca0ff16f68ad(float3 Vector3_28A0F264, float3 Vector3_F1111B56, float Vector1_691AFD6A, float Vector1_37DEE8F3, Bindings_CrestGeoMorph_9ab91ec3462438049923ca0ff16f68ad IN, out half3 MorphedPositionWS_1, out half LodAlpha_2)
            {
                float3 _Property_C4B6B1D5_Out_0 = Vector3_28A0F264;
                float3 _Property_13BC6D1A_Out_0 = Vector3_F1111B56;
                float _Property_DE4BC103_Out_0 = Vector1_691AFD6A;
                float _Property_B3D2A4DF_Out_0 = Vector1_37DEE8F3;
                half3 _CustomFunction_C8F1D6C4_MorphedPositionWS_4;
                half _CustomFunction_C8F1D6C4_LodAlpha_5;
                GeoMorph_half(_Property_C4B6B1D5_Out_0, _Property_13BC6D1A_Out_0, _Property_DE4BC103_Out_0, _Property_B3D2A4DF_Out_0, _CustomFunction_C8F1D6C4_MorphedPositionWS_4, _CustomFunction_C8F1D6C4_LodAlpha_5);
                MorphedPositionWS_1 = _CustomFunction_C8F1D6C4_MorphedPositionWS_4;
                LodAlpha_2 = _CustomFunction_C8F1D6C4_LodAlpha_5;
            }
            
            // 280776a3899d7788e7b68f32405fa944
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeSampleOceanData.hlsl"
            
            struct Bindings_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4
            {
            };
            
            void SG_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4(float2 Vector2_3171933F, float Vector1_CD41515B, float3 Vector3_7E91D336, float3 Vector3_3A95DCDF, float4 Vector4_C0B2B5EA, float4 Vector4_9C46108E, float Vector1_8EA8B92B, Bindings_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4 IN, out float3 Displacement_1, out float OceanWaterDepth_5, out float Foam_6, out float2 Shadow_7, out float2 Flow_8, out float SubSurfaceScattering_9)
            {
                float2 _Property_1A287CC6_Out_0 = Vector2_3171933F;
                float _Property_2D1D1700_Out_0 = Vector1_CD41515B;
                float3 _Property_C925A867_Out_0 = Vector3_7E91D336;
                float3 _Property_6C273401_Out_0 = Vector3_3A95DCDF;
                float4 _Property_467D1BE7_Out_0 = Vector4_C0B2B5EA;
                float4 _Property_4E045F45_Out_0 = Vector4_9C46108E;
                float _Property_59E019ED_Out_0 = Vector1_8EA8B92B;
                float3 _CustomFunction_487C31E1_Displacement_3;
                float _CustomFunction_487C31E1_OceanDepth_8;
                float _CustomFunction_487C31E1_Foam_4;
                float2 _CustomFunction_487C31E1_Shadow_5;
                float2 _CustomFunction_487C31E1_Flow_6;
                float _CustomFunction_487C31E1_SSS_17;
                CrestNodeSampleOceanData_float(_Property_1A287CC6_Out_0, _Property_2D1D1700_Out_0, _Property_C925A867_Out_0, _Property_6C273401_Out_0, _Property_467D1BE7_Out_0, _Property_4E045F45_Out_0, _Property_59E019ED_Out_0, _CustomFunction_487C31E1_Displacement_3, _CustomFunction_487C31E1_OceanDepth_8, _CustomFunction_487C31E1_Foam_4, _CustomFunction_487C31E1_Shadow_5, _CustomFunction_487C31E1_Flow_6, _CustomFunction_487C31E1_SSS_17);
                Displacement_1 = _CustomFunction_487C31E1_Displacement_3;
                OceanWaterDepth_5 = _CustomFunction_487C31E1_OceanDepth_8;
                Foam_6 = _CustomFunction_487C31E1_Foam_4;
                Shadow_7 = _CustomFunction_487C31E1_Shadow_5;
                Flow_8 = _CustomFunction_487C31E1_Flow_6;
                SubSurfaceScattering_9 = _CustomFunction_487C31E1_SSS_17;
            }
            
            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
            {
                Out = A + B;
            }
            
            // 25927ab6b885bcd0b86a13376933b174
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeComputeSamplingData.hlsl"
            
            void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
            {
                Out = A - B;
            }
            
            struct Bindings_CrestComputeOceanDataFromDisplacedPosition_1f483fe321b10c64e8b93a023ae60dd6
            {
            };
            
            void SG_CrestComputeOceanDataFromDisplacedPosition_1f483fe321b10c64e8b93a023ae60dd6(float3 Vector3_A7B8495A, Bindings_CrestComputeOceanDataFromDisplacedPosition_1f483fe321b10c64e8b93a023ae60dd6 IN, out float2 UndisplacedPosXZAWS_7, out float LodAlpha_6, out float3 Displacement_8, out float OceanWaterDepth_1, out float Foam_2, out float2 Shadow_3, out float2 Flow_4, out float SubSurfaceScattering_5)
            {
                float3 _Property_232E7FDA_Out_0 = Vector3_A7B8495A;
                float _Split_8E8A6DCA_R_1 = _Property_232E7FDA_Out_0[0];
                float _Split_8E8A6DCA_G_2 = _Property_232E7FDA_Out_0[1];
                float _Split_8E8A6DCA_B_3 = _Property_232E7FDA_Out_0[2];
                float _Split_8E8A6DCA_A_4 = 0;
                float2 _Vector2_A3499051_Out_0 = float2(_Split_8E8A6DCA_R_1, _Split_8E8A6DCA_B_3);
                half _CustomFunction_A082C8F2_LodAlpha_3;
                half3 _CustomFunction_A082C8F2_OceanPosScale0_4;
                half3 _CustomFunction_A082C8F2_OceanPosScale1_5;
                half4 _CustomFunction_A082C8F2_OceanParams0_6;
                half4 _CustomFunction_A082C8F2_OceanParams1_7;
                half _CustomFunction_A082C8F2_Slice0_1;
                half _CustomFunction_A082C8F2_Slice1_2;
                CrestComputeSamplingData_half(_Vector2_A3499051_Out_0, _CustomFunction_A082C8F2_LodAlpha_3, _CustomFunction_A082C8F2_OceanPosScale0_4, _CustomFunction_A082C8F2_OceanPosScale1_5, _CustomFunction_A082C8F2_OceanParams0_6, _CustomFunction_A082C8F2_OceanParams1_7, _CustomFunction_A082C8F2_Slice0_1, _CustomFunction_A082C8F2_Slice1_2);
                Bindings_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4 _CrestSampleOceanData_87ACC65F;
                float3 _CrestSampleOceanData_87ACC65F_Displacement_1;
                float _CrestSampleOceanData_87ACC65F_OceanWaterDepth_5;
                float _CrestSampleOceanData_87ACC65F_Foam_6;
                float2 _CrestSampleOceanData_87ACC65F_Shadow_7;
                float2 _CrestSampleOceanData_87ACC65F_Flow_8;
                float _CrestSampleOceanData_87ACC65F_SubSurfaceScattering_9;
                SG_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4(_Vector2_A3499051_Out_0, _CustomFunction_A082C8F2_LodAlpha_3, _CustomFunction_A082C8F2_OceanPosScale0_4, _CustomFunction_A082C8F2_OceanPosScale1_5, _CustomFunction_A082C8F2_OceanParams0_6, _CustomFunction_A082C8F2_OceanParams1_7, _CustomFunction_A082C8F2_Slice0_1, _CrestSampleOceanData_87ACC65F, _CrestSampleOceanData_87ACC65F_Displacement_1, _CrestSampleOceanData_87ACC65F_OceanWaterDepth_5, _CrestSampleOceanData_87ACC65F_Foam_6, _CrestSampleOceanData_87ACC65F_Shadow_7, _CrestSampleOceanData_87ACC65F_Flow_8, _CrestSampleOceanData_87ACC65F_SubSurfaceScattering_9);
                float _Split_CD3A9051_R_1 = _CrestSampleOceanData_87ACC65F_Displacement_1[0];
                float _Split_CD3A9051_G_2 = _CrestSampleOceanData_87ACC65F_Displacement_1[1];
                float _Split_CD3A9051_B_3 = _CrestSampleOceanData_87ACC65F_Displacement_1[2];
                float _Split_CD3A9051_A_4 = 0;
                float2 _Vector2_B8C0C1F0_Out_0 = float2(_Split_CD3A9051_R_1, _Split_CD3A9051_B_3);
                float2 _Subtract_8977A663_Out_2;
                Unity_Subtract_float2(_Vector2_A3499051_Out_0, _Vector2_B8C0C1F0_Out_0, _Subtract_8977A663_Out_2);
                half _CustomFunction_9D8B14F0_LodAlpha_3;
                half3 _CustomFunction_9D8B14F0_OceanPosScale0_4;
                half3 _CustomFunction_9D8B14F0_OceanPosScale1_5;
                half4 _CustomFunction_9D8B14F0_OceanParams0_6;
                half4 _CustomFunction_9D8B14F0_OceanParams1_7;
                half _CustomFunction_9D8B14F0_Slice0_1;
                half _CustomFunction_9D8B14F0_Slice1_2;
                CrestComputeSamplingData_half(_Subtract_8977A663_Out_2, _CustomFunction_9D8B14F0_LodAlpha_3, _CustomFunction_9D8B14F0_OceanPosScale0_4, _CustomFunction_9D8B14F0_OceanPosScale1_5, _CustomFunction_9D8B14F0_OceanParams0_6, _CustomFunction_9D8B14F0_OceanParams1_7, _CustomFunction_9D8B14F0_Slice0_1, _CustomFunction_9D8B14F0_Slice1_2);
                Bindings_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4 _CrestSampleOceanData_D8619779;
                float3 _CrestSampleOceanData_D8619779_Displacement_1;
                float _CrestSampleOceanData_D8619779_OceanWaterDepth_5;
                float _CrestSampleOceanData_D8619779_Foam_6;
                float2 _CrestSampleOceanData_D8619779_Shadow_7;
                float2 _CrestSampleOceanData_D8619779_Flow_8;
                float _CrestSampleOceanData_D8619779_SubSurfaceScattering_9;
                SG_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4(_Subtract_8977A663_Out_2, _CustomFunction_9D8B14F0_LodAlpha_3, _CustomFunction_9D8B14F0_OceanPosScale0_4, _CustomFunction_9D8B14F0_OceanPosScale1_5, _CustomFunction_9D8B14F0_OceanParams0_6, _CustomFunction_9D8B14F0_OceanParams1_7, _CustomFunction_9D8B14F0_Slice0_1, _CrestSampleOceanData_D8619779, _CrestSampleOceanData_D8619779_Displacement_1, _CrestSampleOceanData_D8619779_OceanWaterDepth_5, _CrestSampleOceanData_D8619779_Foam_6, _CrestSampleOceanData_D8619779_Shadow_7, _CrestSampleOceanData_D8619779_Flow_8, _CrestSampleOceanData_D8619779_SubSurfaceScattering_9);
                float _Split_1616DE7_R_1 = _CrestSampleOceanData_D8619779_Displacement_1[0];
                float _Split_1616DE7_G_2 = _CrestSampleOceanData_D8619779_Displacement_1[1];
                float _Split_1616DE7_B_3 = _CrestSampleOceanData_D8619779_Displacement_1[2];
                float _Split_1616DE7_A_4 = 0;
                float2 _Vector2_B871614F_Out_0 = float2(_Split_1616DE7_R_1, _Split_1616DE7_B_3);
                float2 _Subtract_39E2CE30_Out_2;
                Unity_Subtract_float2(_Vector2_A3499051_Out_0, _Vector2_B871614F_Out_0, _Subtract_39E2CE30_Out_2);
                half _CustomFunction_10AEAD9A_LodAlpha_3;
                half3 _CustomFunction_10AEAD9A_OceanPosScale0_4;
                half3 _CustomFunction_10AEAD9A_OceanPosScale1_5;
                half4 _CustomFunction_10AEAD9A_OceanParams0_6;
                half4 _CustomFunction_10AEAD9A_OceanParams1_7;
                half _CustomFunction_10AEAD9A_Slice0_1;
                half _CustomFunction_10AEAD9A_Slice1_2;
                CrestComputeSamplingData_half(_Subtract_39E2CE30_Out_2, _CustomFunction_10AEAD9A_LodAlpha_3, _CustomFunction_10AEAD9A_OceanPosScale0_4, _CustomFunction_10AEAD9A_OceanPosScale1_5, _CustomFunction_10AEAD9A_OceanParams0_6, _CustomFunction_10AEAD9A_OceanParams1_7, _CustomFunction_10AEAD9A_Slice0_1, _CustomFunction_10AEAD9A_Slice1_2);
                Bindings_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4 _CrestSampleOceanData_A1195FE2;
                float3 _CrestSampleOceanData_A1195FE2_Displacement_1;
                float _CrestSampleOceanData_A1195FE2_OceanWaterDepth_5;
                float _CrestSampleOceanData_A1195FE2_Foam_6;
                float2 _CrestSampleOceanData_A1195FE2_Shadow_7;
                float2 _CrestSampleOceanData_A1195FE2_Flow_8;
                float _CrestSampleOceanData_A1195FE2_SubSurfaceScattering_9;
                SG_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4(_Subtract_39E2CE30_Out_2, _CustomFunction_10AEAD9A_LodAlpha_3, _CustomFunction_10AEAD9A_OceanPosScale0_4, _CustomFunction_10AEAD9A_OceanPosScale1_5, _CustomFunction_10AEAD9A_OceanParams0_6, _CustomFunction_10AEAD9A_OceanParams1_7, _CustomFunction_10AEAD9A_Slice0_1, _CrestSampleOceanData_A1195FE2, _CrestSampleOceanData_A1195FE2_Displacement_1, _CrestSampleOceanData_A1195FE2_OceanWaterDepth_5, _CrestSampleOceanData_A1195FE2_Foam_6, _CrestSampleOceanData_A1195FE2_Shadow_7, _CrestSampleOceanData_A1195FE2_Flow_8, _CrestSampleOceanData_A1195FE2_SubSurfaceScattering_9);
                UndisplacedPosXZAWS_7 = _Subtract_39E2CE30_Out_2;
                LodAlpha_6 = _CustomFunction_10AEAD9A_LodAlpha_3;
                Displacement_8 = _CrestSampleOceanData_A1195FE2_Displacement_1;
                OceanWaterDepth_1 = _CrestSampleOceanData_A1195FE2_OceanWaterDepth_5;
                Foam_2 = _CrestSampleOceanData_A1195FE2_Foam_6;
                Shadow_3 = _CrestSampleOceanData_A1195FE2_Shadow_7;
                Flow_4 = _CrestSampleOceanData_A1195FE2_Flow_8;
                SubSurfaceScattering_5 = _CrestSampleOceanData_A1195FE2_SubSurfaceScattering_9;
            }
            
            struct Bindings_CrestUnpackData_5bc4cf08f88035c489658d60edefeec8
            {
                float3 AbsoluteWorldSpacePosition;
                half4 uv0;
                half4 uv1;
                half4 uv2;
            };
            
            void SG_CrestUnpackData_5bc4cf08f88035c489658d60edefeec8(Bindings_CrestUnpackData_5bc4cf08f88035c489658d60edefeec8 IN, out float2 PositionXZWSUndisp_2, out float LodAlpha_1, out float OceanDepth_3, out float Foam_4, out float2 Shadow_5, out float2 Flow_6, out float SubSurfaceScattering_7)
            {
                float4 _UV_CF6CD5F2_Out_0 = IN.uv0;
                float _Split_B10345C8_R_1 = _UV_CF6CD5F2_Out_0[0];
                float _Split_B10345C8_G_2 = _UV_CF6CD5F2_Out_0[1];
                float _Split_B10345C8_B_3 = _UV_CF6CD5F2_Out_0[2];
                float _Split_B10345C8_A_4 = _UV_CF6CD5F2_Out_0[3];
                float2 _Vector2_552A5E1F_Out_0 = float2(_Split_B10345C8_R_1, _Split_B10345C8_G_2);
                Bindings_CrestComputeOceanDataFromDisplacedPosition_1f483fe321b10c64e8b93a023ae60dd6 _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB;
                float2 _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_UndisplacedPosXZAWS_7;
                float _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_LodAlpha_6;
                float3 _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Displacement_8;
                float _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_OceanWaterDepth_1;
                float _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Foam_2;
                float2 _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Shadow_3;
                float2 _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Flow_4;
                float _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_SubSurfaceScattering_5;
                SG_CrestComputeOceanDataFromDisplacedPosition_1f483fe321b10c64e8b93a023ae60dd6(IN.AbsoluteWorldSpacePosition, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_UndisplacedPosXZAWS_7, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_LodAlpha_6, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Displacement_8, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_OceanWaterDepth_1, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Foam_2, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Shadow_3, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Flow_4, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_SubSurfaceScattering_5);
                #if defined(CREST_GENERATED_SHADER_ON)
                float2 _GENERATEDSHADER_71C0694B_Out_0 = _Vector2_552A5E1F_Out_0;
                #else
                float2 _GENERATEDSHADER_71C0694B_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_UndisplacedPosXZAWS_7;
                #endif
                #if defined(CREST_GENERATED_SHADER_ON)
                float _GENERATEDSHADER_2A933A74_Out_0 = _Split_B10345C8_B_3;
                #else
                float _GENERATEDSHADER_2A933A74_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_LodAlpha_6;
                #endif
                #if defined(CREST_GENERATED_SHADER_ON)
                float _GENERATEDSHADER_EFBF6036_Out_0 = _Split_B10345C8_A_4;
                #else
                float _GENERATEDSHADER_EFBF6036_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_OceanWaterDepth_1;
                #endif
                float4 _UV_39E1D2DF_Out_0 = IN.uv1;
                float _Split_CB2CA9B8_R_1 = _UV_39E1D2DF_Out_0[0];
                float _Split_CB2CA9B8_G_2 = _UV_39E1D2DF_Out_0[1];
                float _Split_CB2CA9B8_B_3 = _UV_39E1D2DF_Out_0[2];
                float _Split_CB2CA9B8_A_4 = _UV_39E1D2DF_Out_0[3];
                #if defined(CREST_GENERATED_SHADER_ON)
                float _GENERATEDSHADER_1BBAE801_Out_0 = _Split_CB2CA9B8_G_2;
                #else
                float _GENERATEDSHADER_1BBAE801_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Foam_2;
                #endif
                float4 _UV_33A67BF5_Out_0 = IN.uv2;
                float _Split_753DFB28_R_1 = _UV_33A67BF5_Out_0[0];
                float _Split_753DFB28_G_2 = _UV_33A67BF5_Out_0[1];
                float _Split_753DFB28_B_3 = _UV_33A67BF5_Out_0[2];
                float _Split_753DFB28_A_4 = _UV_33A67BF5_Out_0[3];
                float2 _Vector2_7883B8A6_Out_0 = float2(_Split_753DFB28_R_1, _Split_753DFB28_G_2);
                #if defined(CREST_GENERATED_SHADER_ON)
                float2 _GENERATEDSHADER_B499BDE6_Out_0 = _Vector2_7883B8A6_Out_0;
                #else
                float2 _GENERATEDSHADER_B499BDE6_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Shadow_3;
                #endif
                float2 _Vector2_3A83E1FC_Out_0 = float2(_Split_753DFB28_B_3, _Split_753DFB28_A_4);
                #if defined(CREST_GENERATED_SHADER_ON)
                float2 _GENERATEDSHADER_84CB20AD_Out_0 = _Vector2_3A83E1FC_Out_0;
                #else
                float2 _GENERATEDSHADER_84CB20AD_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Flow_4;
                #endif
                #if defined(CREST_GENERATED_SHADER_ON)
                float _GENERATEDSHADER_6BDC98D1_Out_0 = _Split_CB2CA9B8_R_1;
                #else
                float _GENERATEDSHADER_6BDC98D1_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_SubSurfaceScattering_5;
                #endif
                PositionXZWSUndisp_2 = _GENERATEDSHADER_71C0694B_Out_0;
                LodAlpha_1 = _GENERATEDSHADER_2A933A74_Out_0;
                OceanDepth_3 = _GENERATEDSHADER_EFBF6036_Out_0;
                Foam_4 = _GENERATEDSHADER_1BBAE801_Out_0;
                Shadow_5 = _GENERATEDSHADER_B499BDE6_Out_0;
                Flow_6 = _GENERATEDSHADER_84CB20AD_Out_0;
                SubSurfaceScattering_7 = _GENERATEDSHADER_6BDC98D1_Out_0;
            }
            
            // 673f3e02c7d6371b4ae419cc02e9dca4
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeLightData.hlsl"
            
            struct Bindings_CrestLightData_b74b6e8c0b489314ca7aea3e2cc9c54c
            {
            };
            
            void SG_CrestLightData_b74b6e8c0b489314ca7aea3e2cc9c54c(Bindings_CrestLightData_b74b6e8c0b489314ca7aea3e2cc9c54c IN, out half3 Direction_1, out half3 Intensity_2)
            {
                half3 _CustomFunction_5D41A6E0_Direction_0;
                half3 _CustomFunction_5D41A6E0_Colour_1;
                CrestNodeLightData_half(_CustomFunction_5D41A6E0_Direction_0, _CustomFunction_5D41A6E0_Colour_1);
                Direction_1 = _CustomFunction_5D41A6E0_Direction_0;
                Intensity_2 = _CustomFunction_5D41A6E0_Colour_1;
            }
            
            void Unity_Normalize_float3(float3 In, out float3 Out)
            {
                Out = normalize(In);
            }
            
            void Unity_Not_float(float In, out float Out)
            {
                Out = !In;
            }
            
            struct Bindings_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2
            {
                float FaceSign;
            };
            
            void SG_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2(Bindings_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2 IN, out float OutBoolean_1)
            {
                float _IsFrontFace_F6DF08D5_Out_0 = max(0, IN.FaceSign);
                float _Not_3B19614D_Out_1;
                Unity_Not_float(_IsFrontFace_F6DF08D5_Out_0, _Not_3B19614D_Out_1);
                OutBoolean_1 = _Not_3B19614D_Out_1;
            }
            
            // 928f91ea5fffaa68cdc1e5110d727baf
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeNormalMapping.hlsl"
            
            struct Bindings_CrestComputeNormal_61b9efc6612ab3b4f84174344af5e12a
            {
                float FaceSign;
            };
            
            void SG_CrestComputeNormal_61b9efc6612ab3b4f84174344af5e12a(float3 Vector3_FE793823, float3 Vector3_C8190B61, float4 Vector4_F18E4948, float4 Vector4_43DD8E03, float Vector1_8771A258, TEXTURE2D_PARAM(Texture2D_6CA3A26C, samplerTexture2D_6CA3A26C), float4 Texture2D_6CA3A26C_TexelSize, float Vector1_418D6270, float Vector1_6EC9A7C0, float Vector1_5D9D8139, float2 Vector2_3ED47A62, float2 Vector2_891575B0, float3 Vector3_A9F402BF, Bindings_CrestComputeNormal_61b9efc6612ab3b4f84174344af5e12a IN, out half3 Normal_1)
            {
                float3 _Property_9021A08B_Out_0 = Vector3_FE793823;
                float3 _Property_9C8BC1F1_Out_0 = Vector3_C8190B61;
                float4 _Property_BA13B38B_Out_0 = Vector4_F18E4948;
                float4 _Property_587E24D5_Out_0 = Vector4_43DD8E03;
                float _Property_1A49C52D_Out_0 = Vector1_8771A258;
                float _Property_514FBFB9_Out_0 = Vector1_418D6270;
                float _Property_27A6DF1E_Out_0 = Vector1_6EC9A7C0;
                float _Property_A277E64F_Out_0 = Vector1_5D9D8139;
                float2 _Property_805F9A1D_Out_0 = Vector2_3ED47A62;
                float2 _Property_100A6EB8_Out_0 = Vector2_891575B0;
                float3 _Property_11AD0CE_Out_0 = Vector3_A9F402BF;
                Bindings_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2 _CrestIsUnderwater_BA18A1A;
                _CrestIsUnderwater_BA18A1A.FaceSign = IN.FaceSign;
                float _CrestIsUnderwater_BA18A1A_OutBoolean_1;
                SG_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2(_CrestIsUnderwater_BA18A1A, _CrestIsUnderwater_BA18A1A_OutBoolean_1);
                half3 _CustomFunction_61A7F8B0_NormalTS_1;
                OceanNormals_half(_Property_9021A08B_Out_0, _Property_9C8BC1F1_Out_0, _Property_BA13B38B_Out_0, _Property_587E24D5_Out_0, _Property_1A49C52D_Out_0, Texture2D_6CA3A26C, _Property_514FBFB9_Out_0, _Property_27A6DF1E_Out_0, _Property_A277E64F_Out_0, _Property_805F9A1D_Out_0, _Property_100A6EB8_Out_0, _Property_11AD0CE_Out_0, _CrestIsUnderwater_BA18A1A_OutBoolean_1, _CustomFunction_61A7F8B0_NormalTS_1);
                Normal_1 = _CustomFunction_61A7F8B0_NormalTS_1;
            }
            
            // 52e02b1b13552331adad44cf4a7ae4a5
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeApplyFresnel.hlsl"
            
            struct Bindings_CrestFresnel_c6f6c13c4fdb04e42b427e4c2610d3c9
            {
                float FaceSign;
            };
            
            void SG_CrestFresnel_c6f6c13c4fdb04e42b427e4c2610d3c9(float3 Vector3_FFFD5D37, float3 Vector3_50713CBB, float Vector1_C2909293, float Vector1_DDF5B66E, Bindings_CrestFresnel_c6f6c13c4fdb04e42b427e4c2610d3c9 IN, out float LightTransmitted_1, out float LightReflected_2)
            {
                float3 _Property_3166A32_Out_0 = Vector3_50713CBB;
                float3 _Property_ED2FFB18_Out_0 = Vector3_FFFD5D37;
                Bindings_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2 _CrestIsUnderwater_291EED16;
                _CrestIsUnderwater_291EED16.FaceSign = IN.FaceSign;
                float _CrestIsUnderwater_291EED16_OutBoolean_1;
                SG_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2(_CrestIsUnderwater_291EED16, _CrestIsUnderwater_291EED16_OutBoolean_1);
                float _Property_D5B7D059_Out_0 = Vector1_DDF5B66E;
                float _Property_2395CED2_Out_0 = Vector1_C2909293;
                float _CustomFunction_6DEBC54E_LightTransmitted_1;
                float _CustomFunction_6DEBC54E_LightReflected_10;
                CrestNodeApplyFresnel_float(_Property_3166A32_Out_0, _Property_ED2FFB18_Out_0, _CrestIsUnderwater_291EED16_OutBoolean_1, _Property_D5B7D059_Out_0, _Property_2395CED2_Out_0, _CustomFunction_6DEBC54E_LightTransmitted_1, _CustomFunction_6DEBC54E_LightReflected_10);
                LightTransmitted_1 = _CustomFunction_6DEBC54E_LightTransmitted_1;
                LightReflected_2 = _CustomFunction_6DEBC54E_LightReflected_10;
            }
            
            void GetAmbientLighting_float(out float3 AmbientLighting)
            {
                AmbientLighting = half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
            }
            
            // 4e36a733a1fa5e9359282bf30157c748
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeLightWaterVolume.hlsl"
            
            struct Bindings_CrestVolumeLighting_e9ed6e11710a50640bb4b811d0fa84f2
            {
            };
            
            void SG_CrestVolumeLighting_e9ed6e11710a50640bb4b811d0fa84f2(float4 Vector4_7C3B7892, float3 Vector3_CB562741, float4 Vector4_1925E051, float Vector1_E556918C, float Vector1_67342C54, float Vector1_D7DF1AB, float Vector1_6823579F, float4 Vector4_79A1BE1F, float Vector1_7223C6AC, float Vector1_66E9E54, float2 Vector2_D3558D33, float Vector1_96B7F6DA, float3 Vector3_1559C54, float3 Vector3_EBF06BD4, float3 Vector3_4BB1E4A, float3 Vector3_938EEF71, float3 Vector3_CAD84B7A, Bindings_CrestVolumeLighting_e9ed6e11710a50640bb4b811d0fa84f2 IN, out half3 VolumeLighting_1)
            {
                float4 _Property_3BF186D2_Out_0 = Vector4_7C3B7892;
                float3 _Property_36BD3B33_Out_0 = Vector3_CB562741;
                float4 _Property_DEEB4017_Out_0 = Vector4_1925E051;
                float _Property_DEF8261_Out_0 = Vector1_E556918C;
                float _Property_E59433A0_Out_0 = Vector1_67342C54;
                float _Property_B909C546_Out_0 = Vector1_D7DF1AB;
                float _Property_E4FBA75D_Out_0 = Vector1_6823579F;
                float4 _Property_856C2495_Out_0 = Vector4_79A1BE1F;
                float _Property_D81EDA3D_Out_0 = Vector1_7223C6AC;
                float _Property_9368CB3D_Out_0 = Vector1_66E9E54;
                float2 _Property_BF038BF7_Out_0 = Vector2_D3558D33;
                float _Property_F35AF73E_Out_0 = Vector1_96B7F6DA;
                float3 _Property_32B01413_Out_0 = Vector3_1559C54;
                float3 _Property_5B1BCADB_Out_0 = Vector3_EBF06BD4;
                float3 _Property_6BBACEFC_Out_0 = Vector3_4BB1E4A;
                float3 _Property_C8DE9461_Out_0 = Vector3_938EEF71;
                float3 _Property_919832B1_Out_0 = Vector3_CAD84B7A;
                half3 _CustomFunction_F6F194A9_VolumeLighting_5;
                CrestNodeLightWaterVolume_half((_Property_3BF186D2_Out_0.xyz), _Property_36BD3B33_Out_0, (_Property_DEEB4017_Out_0.xyz), _Property_DEF8261_Out_0, _Property_E59433A0_Out_0, _Property_B909C546_Out_0, _Property_E4FBA75D_Out_0, (_Property_856C2495_Out_0.xyz), _Property_D81EDA3D_Out_0, _Property_9368CB3D_Out_0, _Property_BF038BF7_Out_0, _Property_F35AF73E_Out_0, _Property_32B01413_Out_0, _Property_5B1BCADB_Out_0, _Property_6BBACEFC_Out_0, _Property_C8DE9461_Out_0, _Property_919832B1_Out_0, _CustomFunction_F6F194A9_VolumeLighting_5);
                VolumeLighting_1 = _CustomFunction_F6F194A9_VolumeLighting_5;
            }
            
            void Unity_Negate_float(float In, out float Out)
            {
                Out = -1 * In;
            }
            
            void Unity_SceneColor_float(float4 UV, out float3 Out)
            {
                Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
            }
            
            void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
            
            // edda0395615fdcd072915b34eccb4069
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeOceanGlobals.hlsl"
            
            struct Bindings_CrestOceanGlobals_d50a85284893ec447a25a093505a2120
            {
            };
            
            void SG_CrestOceanGlobals_d50a85284893ec447a25a093505a2120(Bindings_CrestOceanGlobals_d50a85284893ec447a25a093505a2120 IN, out float CrestTime_1, out float TexelsPerWave_2, out float3 OceanCenterPosWorld_3, out float SliceCount_4, out float MeshScaleLerp_5)
            {
                float _CustomFunction_9ED6B15_CrestTime_0;
                float _CustomFunction_9ED6B15_TexelsPerWave_1;
                float3 _CustomFunction_9ED6B15_OceanCenterPosWorld_2;
                float _CustomFunction_9ED6B15_SliceCount_3;
                float _CustomFunction_9ED6B15_MeshScaleLerp_4;
                CrestNodeOceanGlobals_float(_CustomFunction_9ED6B15_CrestTime_0, _CustomFunction_9ED6B15_TexelsPerWave_1, _CustomFunction_9ED6B15_OceanCenterPosWorld_2, _CustomFunction_9ED6B15_SliceCount_3, _CustomFunction_9ED6B15_MeshScaleLerp_4);
                CrestTime_1 = _CustomFunction_9ED6B15_CrestTime_0;
                TexelsPerWave_2 = _CustomFunction_9ED6B15_TexelsPerWave_1;
                OceanCenterPosWorld_3 = _CustomFunction_9ED6B15_OceanCenterPosWorld_2;
                SliceCount_4 = _CustomFunction_9ED6B15_SliceCount_3;
                MeshScaleLerp_5 = _CustomFunction_9ED6B15_MeshScaleLerp_4;
            }
            
            void Unity_Modulo_float(float A, float B, out float Out)
            {
                Out = fmod(A, B);
            }
            
            void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
            {
                Out = A * B;
            }
            
            void Unity_Comparison_Greater_float(float A, float B, out float Out)
            {
                Out = A > B ? 1 : 0;
            }
            
            void Unity_Subtract_float(float A, float B, out float Out)
            {
                Out = A - B;
            }
            
            void Unity_Branch_float(float Predicate, float True, float False, out float Out)
            {
                Out = lerp(False, True, Predicate);
            }
            
            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }
            
            struct Bindings_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1
            {
            };
            
            void SG_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1(float2 Vector2_B562EFB1, float2 Vector2_83AA31A8, Bindings_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1 IN, out float2 DisplacedA_1, out float WeightA_3, out float2 DisplacedB_2, out float WeightB_4)
            {
                float2 _Property_DB670C03_Out_0 = Vector2_83AA31A8;
                float2 _Property_6ED023E0_Out_0 = Vector2_B562EFB1;
                Bindings_CrestOceanGlobals_d50a85284893ec447a25a093505a2120 _CrestOceanGlobals_40DCBE3E;
                float _CrestOceanGlobals_40DCBE3E_CrestTime_1;
                float _CrestOceanGlobals_40DCBE3E_TexelsPerWave_2;
                float3 _CrestOceanGlobals_40DCBE3E_OceanCenterPosWorld_3;
                float _CrestOceanGlobals_40DCBE3E_SliceCount_4;
                float _CrestOceanGlobals_40DCBE3E_MeshScaleLerp_5;
                SG_CrestOceanGlobals_d50a85284893ec447a25a093505a2120(_CrestOceanGlobals_40DCBE3E, _CrestOceanGlobals_40DCBE3E_CrestTime_1, _CrestOceanGlobals_40DCBE3E_TexelsPerWave_2, _CrestOceanGlobals_40DCBE3E_OceanCenterPosWorld_3, _CrestOceanGlobals_40DCBE3E_SliceCount_4, _CrestOceanGlobals_40DCBE3E_MeshScaleLerp_5);
                float _Modulo_CC9BC285_Out_2;
                Unity_Modulo_float(_CrestOceanGlobals_40DCBE3E_CrestTime_1, 2, _Modulo_CC9BC285_Out_2);
                float2 _Multiply_821FCA56_Out_2;
                Unity_Multiply_float(_Property_6ED023E0_Out_0, (_Modulo_CC9BC285_Out_2.xx), _Multiply_821FCA56_Out_2);
                float2 _Subtract_273125FF_Out_2;
                Unity_Subtract_float2(_Property_DB670C03_Out_0, _Multiply_821FCA56_Out_2, _Subtract_273125FF_Out_2);
                float2 _Property_C2A19C1C_Out_0 = Vector2_83AA31A8;
                #if defined(CREST_FLOW_ON)
                float2 _FLOW_963D27CC_Out_0 = _Subtract_273125FF_Out_2;
                #else
                float2 _FLOW_963D27CC_Out_0 = _Property_C2A19C1C_Out_0;
                #endif
                float _Comparison_67E5EC91_Out_2;
                Unity_Comparison_Greater_float(_Modulo_CC9BC285_Out_2, 1, _Comparison_67E5EC91_Out_2);
                float _Subtract_289E2A26_Out_2;
                Unity_Subtract_float(2, _Modulo_CC9BC285_Out_2, _Subtract_289E2A26_Out_2);
                float _Branch_57B6378F_Out_3;
                Unity_Branch_float(_Comparison_67E5EC91_Out_2, _Subtract_289E2A26_Out_2, _Modulo_CC9BC285_Out_2, _Branch_57B6378F_Out_3);
                #if defined(CREST_FLOW_ON)
                float _FLOW_AB68F2D0_Out_0 = _Branch_57B6378F_Out_3;
                #else
                float _FLOW_AB68F2D0_Out_0 = 0;
                #endif
                float2 _Property_CF607B59_Out_0 = Vector2_83AA31A8;
                float2 _Property_8EFEBF1A_Out_0 = Vector2_B562EFB1;
                float _Add_43F824C8_Out_2;
                Unity_Add_float(_CrestOceanGlobals_40DCBE3E_CrestTime_1, 1, _Add_43F824C8_Out_2);
                float _Modulo_2FF365BF_Out_2;
                Unity_Modulo_float(_Add_43F824C8_Out_2, 2, _Modulo_2FF365BF_Out_2);
                float2 _Multiply_28DD98EB_Out_2;
                Unity_Multiply_float(_Property_8EFEBF1A_Out_0, (_Modulo_2FF365BF_Out_2.xx), _Multiply_28DD98EB_Out_2);
                float2 _Subtract_1C7014D5_Out_2;
                Unity_Subtract_float2(_Property_CF607B59_Out_0, _Multiply_28DD98EB_Out_2, _Subtract_1C7014D5_Out_2);
                #if defined(CREST_FLOW_ON)
                float2 _FLOW_D38C09E5_Out_0 = _Subtract_1C7014D5_Out_2;
                #else
                float2 _FLOW_D38C09E5_Out_0 = _Property_C2A19C1C_Out_0;
                #endif
                float _Subtract_563D329D_Out_2;
                Unity_Subtract_float(1, _Branch_57B6378F_Out_3, _Subtract_563D329D_Out_2);
                #if defined(CREST_FLOW_ON)
                float _FLOW_CB3A12C4_Out_0 = _Subtract_563D329D_Out_2;
                #else
                float _FLOW_CB3A12C4_Out_0 = 0;
                #endif
                DisplacedA_1 = _FLOW_963D27CC_Out_0;
                WeightA_3 = _FLOW_AB68F2D0_Out_0;
                DisplacedB_2 = _FLOW_D38C09E5_Out_0;
                WeightB_4 = _FLOW_CB3A12C4_Out_0;
            }
            
            void Unity_Lerp_float2(float2 A, float2 B, float2 T, out float2 Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Multiply_float(float A, float B, out float Out)
            {
                Out = A * B;
            }
            
            void Unity_Add_float2(float2 A, float2 B, out float2 Out)
            {
                Out = A + B;
            }
            
            void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
            {
                Out = A / B;
            }
            
            void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
            {
                Out = dot(A, B);
            }
            
            void Unity_Lerp_float(float A, float B, float T, out float Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
            {
                Out = A * B;
            }
            
            void Unity_Saturate_float(float In, out float Out)
            {
                Out = saturate(In);
            }
            
            // 77d0d525f8d2ec135aebd23c92ac3bf7
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeAmbientLight.hlsl"
            
            struct Bindings_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744
            {
            };
            
            void SG_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744(float3 Vector3_6BC21072, float Vector1_856C8201, float Vector1_D8FFBADE, TEXTURE2D_PARAM(Texture2D_E5D62D20, samplerTexture2D_E5D62D20), float4 Texture2D_E5D62D20_TexelSize, float2 Vector2_1544647C, float Vector1_563FFC82, float Vector1_50FCE8BC, float3 Vector3_8690BC0A, float4 Vector4_8E91C60A, float4 Vector4_8FA06CD1, float2 Vector2_A796D1D3, float2 Vector2_73579388, float Vector1_5220E305, float3 Vector3_7DE999FE, Bindings_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744 IN, out float3 Colour_1)
            {
                float _Vector1_50808D77_Out_0 = 0.74;
                float2 _Property_1DB3A8DD_Out_0 = Vector2_73579388;
                float2 _Property_4E1B12A2_Out_0 = Vector2_A796D1D3;
                float _Vector1_22194DBD_Out_0 = 0.7;
                float2 _Lerp_24C286E6_Out_3;
                Unity_Lerp_float2(_Property_1DB3A8DD_Out_0, _Property_4E1B12A2_Out_0, (_Vector1_22194DBD_Out_0.xx), _Lerp_24C286E6_Out_3);
                Bindings_CrestOceanGlobals_d50a85284893ec447a25a093505a2120 _CrestOceanGlobals_FD233E7F;
                float _CrestOceanGlobals_FD233E7F_CrestTime_1;
                float _CrestOceanGlobals_FD233E7F_TexelsPerWave_2;
                float3 _CrestOceanGlobals_FD233E7F_OceanCenterPosWorld_3;
                float _CrestOceanGlobals_FD233E7F_SliceCount_4;
                float _CrestOceanGlobals_FD233E7F_MeshScaleLerp_5;
                SG_CrestOceanGlobals_d50a85284893ec447a25a093505a2120(_CrestOceanGlobals_FD233E7F, _CrestOceanGlobals_FD233E7F_CrestTime_1, _CrestOceanGlobals_FD233E7F_TexelsPerWave_2, _CrestOceanGlobals_FD233E7F_OceanCenterPosWorld_3, _CrestOceanGlobals_FD233E7F_SliceCount_4, _CrestOceanGlobals_FD233E7F_MeshScaleLerp_5);
                float _Multiply_8E48D7F_Out_2;
                Unity_Multiply_float(0.5, _CrestOceanGlobals_FD233E7F_CrestTime_1, _Multiply_8E48D7F_Out_2);
                float2 _Vector2_93AF7702_Out_0 = float2(0.866, 0.5);
                float2 _Multiply_E81E304E_Out_2;
                Unity_Multiply_float((_Multiply_8E48D7F_Out_2.xx), _Vector2_93AF7702_Out_0, _Multiply_E81E304E_Out_2);
                float2 _Add_99B474A3_Out_2;
                Unity_Add_float2(_Lerp_24C286E6_Out_3, _Multiply_E81E304E_Out_2, _Add_99B474A3_Out_2);
                float _Property_A5B593BF_Out_0 = Vector1_563FFC82;
                float2 _Divide_6E172BAC_Out_2;
                Unity_Divide_float2(_Add_99B474A3_Out_2, (_Property_A5B593BF_Out_0.xx), _Divide_6E172BAC_Out_2);
                float _Vector1_33088EF8_Out_0 = 0.125;
                float3 _Property_CBFC7F14_Out_0 = Vector3_8690BC0A;
                float _Split_638CEA28_R_1 = _Property_CBFC7F14_Out_0[0];
                float _Split_638CEA28_G_2 = _Property_CBFC7F14_Out_0[1];
                float _Split_638CEA28_B_3 = _Property_CBFC7F14_Out_0[2];
                float _Split_638CEA28_A_4 = 0;
                float2 _Vector2_1CDF6E92_Out_0 = float2(_Split_638CEA28_R_1, _Split_638CEA28_B_3);
                float2 _Multiply_FEAB095D_Out_2;
                Unity_Multiply_float((_Vector1_33088EF8_Out_0.xx), _Vector2_1CDF6E92_Out_0, _Multiply_FEAB095D_Out_2);
                float2 _Add_301F9C93_Out_2;
                Unity_Add_float2(_Divide_6E172BAC_Out_2, _Multiply_FEAB095D_Out_2, _Add_301F9C93_Out_2);
                float2 _Multiply_47C4DD4E_Out_2;
                Unity_Multiply_float((_Vector1_50808D77_Out_0.xx), _Add_301F9C93_Out_2, _Multiply_47C4DD4E_Out_2);
                float _Property_569DF47F_Out_0 = Vector1_856C8201;
                float3 _Property_D240D17_Out_0 = Vector3_7DE999FE;
                float _Split_628EF5DE_R_1 = _Property_D240D17_Out_0[0];
                float _Split_628EF5DE_G_2 = _Property_D240D17_Out_0[1];
                float _Split_628EF5DE_B_3 = _Property_D240D17_Out_0[2];
                float _Split_628EF5DE_A_4 = 0;
                float2 _Vector2_BF066046_Out_0 = float2(_Split_628EF5DE_R_1, _Split_628EF5DE_B_3);
                float2 _Multiply_43CB1359_Out_2;
                Unity_Multiply_float((_Property_569DF47F_Out_0.xx), _Vector2_BF066046_Out_0, _Multiply_43CB1359_Out_2);
                float3 _Property_122053A8_Out_0 = Vector3_8690BC0A;
                float3 _Property_ADBC2425_Out_0 = Vector3_7DE999FE;
                float _DotProduct_B4F8C812_Out_2;
                Unity_DotProduct_float3(_Property_122053A8_Out_0, _Property_ADBC2425_Out_0, _DotProduct_B4F8C812_Out_2);
                float2 _Divide_63189A2B_Out_2;
                Unity_Divide_float2(_Multiply_43CB1359_Out_2, (_DotProduct_B4F8C812_Out_2.xx), _Divide_63189A2B_Out_2);
                float2 _Add_D56F8BCC_Out_2;
                Unity_Add_float2(_Multiply_47C4DD4E_Out_2, _Divide_63189A2B_Out_2, _Add_D56F8BCC_Out_2);
                float _Vector1_4A3115D0_Out_0 = 4;
                float4 _Property_6BB45B70_Out_0 = Vector4_8E91C60A;
                float _Split_128BB5B0_R_1 = _Property_6BB45B70_Out_0[0];
                float _Split_128BB5B0_G_2 = _Property_6BB45B70_Out_0[1];
                float _Split_128BB5B0_B_3 = _Property_6BB45B70_Out_0[2];
                float _Split_128BB5B0_A_4 = _Property_6BB45B70_Out_0[3];
                float _Multiply_338764B5_Out_2;
                Unity_Multiply_float(_Vector1_4A3115D0_Out_0, _Split_128BB5B0_R_1, _Multiply_338764B5_Out_2);
                float _Property_ACBE1A98_Out_0 = Vector1_563FFC82;
                float _Multiply_69F2FFA6_Out_2;
                Unity_Multiply_float(_Multiply_338764B5_Out_2, _Property_ACBE1A98_Out_0, _Multiply_69F2FFA6_Out_2);
                float2 _Divide_FF361B20_Out_2;
                Unity_Divide_float2(_Add_D56F8BCC_Out_2, (_Multiply_69F2FFA6_Out_2.xx), _Divide_FF361B20_Out_2);
                float4 _SampleTexture2DLOD_181D539B_RGBA_0 = SAMPLE_TEXTURE2D_LOD(Texture2D_E5D62D20, SamplerState_Linear_Repeat, _Divide_FF361B20_Out_2, 3);
                float _SampleTexture2DLOD_181D539B_R_5 = _SampleTexture2DLOD_181D539B_RGBA_0.r;
                float _SampleTexture2DLOD_181D539B_G_6 = _SampleTexture2DLOD_181D539B_RGBA_0.g;
                float _SampleTexture2DLOD_181D539B_B_7 = _SampleTexture2DLOD_181D539B_RGBA_0.b;
                float _SampleTexture2DLOD_181D539B_A_8 = _SampleTexture2DLOD_181D539B_RGBA_0.a;
                float _Vector1_C260EA24_Out_0 = 4;
                float4 _Property_1EB65445_Out_0 = Vector4_8FA06CD1;
                float _Split_DFFF5F9B_R_1 = _Property_1EB65445_Out_0[0];
                float _Split_DFFF5F9B_G_2 = _Property_1EB65445_Out_0[1];
                float _Split_DFFF5F9B_B_3 = _Property_1EB65445_Out_0[2];
                float _Split_DFFF5F9B_A_4 = _Property_1EB65445_Out_0[3];
                float _Multiply_FD1848E_Out_2;
                Unity_Multiply_float(_Vector1_C260EA24_Out_0, _Split_DFFF5F9B_R_1, _Multiply_FD1848E_Out_2);
                float _Property_4D74395B_Out_0 = Vector1_563FFC82;
                float _Multiply_BB87C63D_Out_2;
                Unity_Multiply_float(_Multiply_FD1848E_Out_2, _Property_4D74395B_Out_0, _Multiply_BB87C63D_Out_2);
                float2 _Divide_7AE4E36C_Out_2;
                Unity_Divide_float2(_Add_D56F8BCC_Out_2, (_Multiply_BB87C63D_Out_2.xx), _Divide_7AE4E36C_Out_2);
                float4 _SampleTexture2DLOD_F7B977AE_RGBA_0 = SAMPLE_TEXTURE2D_LOD(Texture2D_E5D62D20, SamplerState_Linear_Repeat, _Divide_7AE4E36C_Out_2, 3);
                float _SampleTexture2DLOD_F7B977AE_R_5 = _SampleTexture2DLOD_F7B977AE_RGBA_0.r;
                float _SampleTexture2DLOD_F7B977AE_G_6 = _SampleTexture2DLOD_F7B977AE_RGBA_0.g;
                float _SampleTexture2DLOD_F7B977AE_B_7 = _SampleTexture2DLOD_F7B977AE_RGBA_0.b;
                float _SampleTexture2DLOD_F7B977AE_A_8 = _SampleTexture2DLOD_F7B977AE_RGBA_0.a;
                float _Property_8BDFE27D_Out_0 = Vector1_5220E305;
                float _Lerp_8E281E25_Out_3;
                Unity_Lerp_float(_SampleTexture2DLOD_181D539B_R_5, _SampleTexture2DLOD_F7B977AE_R_5, _Property_8BDFE27D_Out_0, _Lerp_8E281E25_Out_3);
                float3 _Property_76A1927E_Out_0 = Vector3_6BC21072;
                float3 _Multiply_559CF32F_Out_2;
                Unity_Multiply_float((_Lerp_8E281E25_Out_3.xxx), _Property_76A1927E_Out_0, _Multiply_559CF32F_Out_2);
                float _Property_47590F25_Out_0 = Vector1_50FCE8BC;
                float _Property_8CF73BE5_Out_0 = Vector1_D8FFBADE;
                float _Multiply_A19262A8_Out_2;
                Unity_Multiply_float(_Property_47590F25_Out_0, _Property_8CF73BE5_Out_0, _Multiply_A19262A8_Out_2);
                float _Saturate_A17AF199_Out_1;
                Unity_Saturate_float(_Multiply_A19262A8_Out_2, _Saturate_A17AF199_Out_1);
                float3 _Multiply_DCE93606_Out_2;
                Unity_Multiply_float(_Multiply_559CF32F_Out_2, (_Saturate_A17AF199_Out_1.xxx), _Multiply_DCE93606_Out_2);
                half3 _CustomFunction_6C4427EF_AmbientLight_0;
                CrestNodeAmbientLight_half(_CustomFunction_6C4427EF_AmbientLight_0);
                float3 _Multiply_9B6FA71B_Out_2;
                Unity_Multiply_float(_Multiply_DCE93606_Out_2, _CustomFunction_6C4427EF_AmbientLight_0, _Multiply_9B6FA71B_Out_2);
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_B0667840_Out_0 = _Multiply_9B6FA71B_Out_2;
                #else
                float3 _FOAM_B0667840_Out_0 = float3(0, 0, 0);
                #endif
                Colour_1 = _FOAM_B0667840_Out_0;
            }
            
            struct Bindings_CrestFoamBubblesWithFlow_e132fba35874b4923988ef35a40e48c3
            {
            };
            
            void SG_CrestFoamBubblesWithFlow_e132fba35874b4923988ef35a40e48c3(float3 Vector3_6BC21072, float Vector1_856C8201, float Vector1_D8FFBADE, TEXTURE2D_PARAM(Texture2D_E5D62D20, samplerTexture2D_E5D62D20), float4 Texture2D_E5D62D20_TexelSize, float2 Vector2_1544647C, float Vector1_563FFC82, float Vector1_50FCE8BC, float3 Vector3_8690BC0A, float4 Vector4_8E91C60A, float4 Vector4_8FA06CD1, float2 Vector2_A796D1D3, float2 Vector2_73579388, float Vector1_5220E305, float3 Vector3_7DE999FE, float2 Vector2_58330803, Bindings_CrestFoamBubblesWithFlow_e132fba35874b4923988ef35a40e48c3 IN, out float3 Colour_1)
            {
                float3 _Property_943DDE94_Out_0 = Vector3_6BC21072;
                float _Property_2A86C6D_Out_0 = Vector1_856C8201;
                float _Property_742EBA65_Out_0 = Vector1_D8FFBADE;
                float2 _Property_56F70460_Out_0 = Vector2_1544647C;
                float _Property_BBD1954E_Out_0 = Vector1_563FFC82;
                float _Property_63B10EE4_Out_0 = Vector1_50FCE8BC;
                float3 _Property_736DEE08_Out_0 = Vector3_8690BC0A;
                float4 _Property_E1794A68_Out_0 = Vector4_8E91C60A;
                float4 _Property_13FD15E9_Out_0 = Vector4_8FA06CD1;
                float2 _Property_8C400C63_Out_0 = Vector2_A796D1D3;
                float2 _Property_B43D23D2_Out_0 = Vector2_58330803;
                float2 _Property_6AC0F258_Out_0 = Vector2_73579388;
                Bindings_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1 _CrestFlow_2C0F2FAE;
                float2 _CrestFlow_2C0F2FAE_DisplacedA_1;
                float _CrestFlow_2C0F2FAE_WeightA_3;
                float2 _CrestFlow_2C0F2FAE_DisplacedB_2;
                float _CrestFlow_2C0F2FAE_WeightB_4;
                SG_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1(_Property_B43D23D2_Out_0, _Property_6AC0F258_Out_0, _CrestFlow_2C0F2FAE, _CrestFlow_2C0F2FAE_DisplacedA_1, _CrestFlow_2C0F2FAE_WeightA_3, _CrestFlow_2C0F2FAE_DisplacedB_2, _CrestFlow_2C0F2FAE_WeightB_4);
                float _Property_4C00CA0D_Out_0 = Vector1_5220E305;
                float3 _Property_5BF1E9DE_Out_0 = Vector3_7DE999FE;
                Bindings_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744 _CrestFoamBubbles_E18873D;
                float3 _CrestFoamBubbles_E18873D_Colour_1;
                SG_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744(_Property_943DDE94_Out_0, _Property_2A86C6D_Out_0, _Property_742EBA65_Out_0, TEXTURE2D_ARGS(Texture2D_E5D62D20, samplerTexture2D_E5D62D20), Texture2D_E5D62D20_TexelSize, _Property_56F70460_Out_0, _Property_BBD1954E_Out_0, _Property_63B10EE4_Out_0, _Property_736DEE08_Out_0, _Property_E1794A68_Out_0, _Property_13FD15E9_Out_0, _Property_8C400C63_Out_0, _CrestFlow_2C0F2FAE_DisplacedA_1, _Property_4C00CA0D_Out_0, _Property_5BF1E9DE_Out_0, _CrestFoamBubbles_E18873D, _CrestFoamBubbles_E18873D_Colour_1);
                float3 _Multiply_91E077CA_Out_2;
                Unity_Multiply_float(_CrestFoamBubbles_E18873D_Colour_1, (_CrestFlow_2C0F2FAE_WeightA_3.xxx), _Multiply_91E077CA_Out_2);
                float3 _Property_A1641BBA_Out_0 = Vector3_6BC21072;
                float _Property_3D5C8C49_Out_0 = Vector1_856C8201;
                float _Property_212108F5_Out_0 = Vector1_D8FFBADE;
                float2 _Property_E4A605_Out_0 = Vector2_1544647C;
                float _Property_6B5F6C8D_Out_0 = Vector1_563FFC82;
                float _Property_C1EFD93_Out_0 = Vector1_50FCE8BC;
                float3 _Property_374658EE_Out_0 = Vector3_8690BC0A;
                float4 _Property_93465CAB_Out_0 = Vector4_8E91C60A;
                float4 _Property_D292F7E_Out_0 = Vector4_8FA06CD1;
                float2 _Property_41EA12FB_Out_0 = Vector2_A796D1D3;
                float _Property_ACCAE2A2_Out_0 = Vector1_5220E305;
                float3 _Property_419B8C8_Out_0 = Vector3_7DE999FE;
                Bindings_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744 _CrestFoamBubbles_B2999161;
                float3 _CrestFoamBubbles_B2999161_Colour_1;
                SG_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744(_Property_A1641BBA_Out_0, _Property_3D5C8C49_Out_0, _Property_212108F5_Out_0, TEXTURE2D_ARGS(Texture2D_E5D62D20, samplerTexture2D_E5D62D20), Texture2D_E5D62D20_TexelSize, _Property_E4A605_Out_0, _Property_6B5F6C8D_Out_0, _Property_C1EFD93_Out_0, _Property_374658EE_Out_0, _Property_93465CAB_Out_0, _Property_D292F7E_Out_0, _Property_41EA12FB_Out_0, _CrestFlow_2C0F2FAE_DisplacedB_2, _Property_ACCAE2A2_Out_0, _Property_419B8C8_Out_0, _CrestFoamBubbles_B2999161, _CrestFoamBubbles_B2999161_Colour_1);
                float3 _Multiply_B28E3E4F_Out_2;
                Unity_Multiply_float(_CrestFoamBubbles_B2999161_Colour_1, (_CrestFlow_2C0F2FAE_WeightB_4.xxx), _Multiply_B28E3E4F_Out_2);
                float3 _Add_4A081B98_Out_2;
                Unity_Add_float3(_Multiply_91E077CA_Out_2, _Multiply_B28E3E4F_Out_2, _Add_4A081B98_Out_2);
                #if defined(CREST_FLOW_ON)
                float3 _FLOW_3ACDD4E5_Out_0 = _Add_4A081B98_Out_2;
                #else
                float3 _FLOW_3ACDD4E5_Out_0 = _CrestFoamBubbles_E18873D_Colour_1;
                #endif
                Colour_1 = _FLOW_3ACDD4E5_Out_0;
            }
            
            // 11f8e1767f0d2397594b0042f8356f6e
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeVolumeEmission.hlsl"
            
            struct Bindings_CrestSampleOceanDataSingle_a667f031fd6a3dd42beee0ccc432233d
            {
            };
            
            void SG_CrestSampleOceanDataSingle_a667f031fd6a3dd42beee0ccc432233d(float2 Vector2_1BD49B8D, float3 Vector3_7E91D336, float4 Vector4_C0B2B5EA, float Vector1_8EA8B92B, Bindings_CrestSampleOceanDataSingle_a667f031fd6a3dd42beee0ccc432233d IN, out float3 Displacement_1, out float OceanWaterDepth_5, out float Foam_6, out float2 Shadow_7, out float2 Flow_8, out float SubSurfaceScattering_9)
            {
                float2 _Property_FA70A3E6_Out_0 = Vector2_1BD49B8D;
                float3 _Property_C925A867_Out_0 = Vector3_7E91D336;
                float4 _Property_467D1BE7_Out_0 = Vector4_C0B2B5EA;
                float _Property_59E019ED_Out_0 = Vector1_8EA8B92B;
                float3 _CustomFunction_487C31E1_Displacement_3;
                float _CustomFunction_487C31E1_OceanDepth_8;
                float _CustomFunction_487C31E1_Foam_4;
                float2 _CustomFunction_487C31E1_Shadow_5;
                float2 _CustomFunction_487C31E1_Flow_6;
                float _CustomFunction_487C31E1_SSS_17;
                CrestNodeSampleOceanDataSingle_float(_Property_FA70A3E6_Out_0, _Property_C925A867_Out_0, _Property_467D1BE7_Out_0, _Property_59E019ED_Out_0, _CustomFunction_487C31E1_Displacement_3, _CustomFunction_487C31E1_OceanDepth_8, _CustomFunction_487C31E1_Foam_4, _CustomFunction_487C31E1_Shadow_5, _CustomFunction_487C31E1_Flow_6, _CustomFunction_487C31E1_SSS_17);
                Displacement_1 = _CustomFunction_487C31E1_Displacement_3;
                OceanWaterDepth_5 = _CustomFunction_487C31E1_OceanDepth_8;
                Foam_6 = _CustomFunction_487C31E1_Foam_4;
                Shadow_7 = _CustomFunction_487C31E1_Shadow_5;
                Flow_8 = _CustomFunction_487C31E1_Flow_6;
                SubSurfaceScattering_9 = _CustomFunction_487C31E1_SSS_17;
            }
            
            // 733e22c05b4f35356dd63172ccf21370
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeApplyCaustics.hlsl"
            
            void Unity_Negate_float3(float3 In, out float3 Out)
            {
                Out = -1 * In;
            }
            
            void Unity_Exponential_float3(float3 In, out float3 Out)
            {
                Out = exp(In);
            }
            
            void Unity_OneMinus_float3(float3 In, out float3 Out)
            {
                Out = 1 - In;
            }
            
            void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
            {
                Out = lerp(False, True, Predicate);
            }
            
            struct Bindings_CrestEmission_8c56460232fde1e46ae90d905a00f908
            {
            };
            
            void SG_CrestEmission_8c56460232fde1e46ae90d905a00f908(float Vector1_82EC3C0B, float3 Vector3_6C3F4D52, float3 Vector3_83F0ECB8, float3 Vector3_D6B78A76, float3 Vector3_703F2DD, float4 Vector4_5D0F731B, float Vector1_73B9F9E8, float3 Vector3_D4CABAFD, float Vector1_6C78E163, half3 Vector3_71E7580E, TEXTURE2D_PARAM(Texture2D_BA141407, samplerTexture2D_BA141407), float4 Texture2D_BA141407_TexelSize, half Vector1_460D9038, half Vector1_D5CE42D3, half Vector1_AC9C2A2, half Vector1_8DBC6E14, half Vector1_EA8F2BEC, TEXTURE2D_PARAM(Texture2D_AC91C4C3, samplerTexture2D_AC91C4C3), float4 Texture2D_AC91C4C3_TexelSize, half Vector1_DB8E128A, half Vector1_CFFD6A53, float3 Vector3_32FB76B3, Bindings_CrestEmission_8c56460232fde1e46ae90d905a00f908 IN, out float3 EmittedLight_1)
            {
                float Boolean_6AA51A5 = 0;
                float _Property_101786D0_Out_0 = Vector1_82EC3C0B;
                float3 _Property_833375DE_Out_0 = Vector3_83F0ECB8;
                float3 _Property_83DC9AD9_Out_0 = Vector3_703F2DD;
                float4 _Property_83CEC55B_Out_0 = Vector4_5D0F731B;
                float _Property_37502285_Out_0 = Vector1_73B9F9E8;
                float3 _Property_5935620A_Out_0 = Vector3_D4CABAFD;
                float _Property_AF5C7A5F_Out_0 = Vector1_6C78E163;
                half3 _CustomFunction_F95A252D_SceneColour_5;
                half _CustomFunction_F95A252D_SceneDistance_9;
                half3 _CustomFunction_F95A252D_ScenePositionWS_10;
                CrestNodeSceneColour_half(_Property_101786D0_Out_0, _Property_833375DE_Out_0, _Property_83DC9AD9_Out_0, _Property_83CEC55B_Out_0, _Property_37502285_Out_0, _Property_5935620A_Out_0, _Property_AF5C7A5F_Out_0, _CustomFunction_F95A252D_SceneColour_5, _CustomFunction_F95A252D_SceneDistance_9, _CustomFunction_F95A252D_ScenePositionWS_10);
                half _Split_550754E3_R_1 = _CustomFunction_F95A252D_ScenePositionWS_10[0];
                half _Split_550754E3_G_2 = _CustomFunction_F95A252D_ScenePositionWS_10[1];
                half _Split_550754E3_B_3 = _CustomFunction_F95A252D_ScenePositionWS_10[2];
                half _Split_550754E3_A_4 = 0;
                half2 _Vector2_B1CFC7F6_Out_0 = half2(_Split_550754E3_R_1, _Split_550754E3_B_3);
                Bindings_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d _CrestDrivenData_541C70CC;
                half _CrestDrivenData_541C70CC_MeshScaleAlpha_1;
                half _CrestDrivenData_541C70CC_LodDataTexelSize_8;
                half _CrestDrivenData_541C70CC_GeometryGridSize_2;
                half3 _CrestDrivenData_541C70CC_OceanPosScale0_3;
                half3 _CrestDrivenData_541C70CC_OceanPosScale1_4;
                half4 _CrestDrivenData_541C70CC_OceanParams0_5;
                half4 _CrestDrivenData_541C70CC_OceanParams1_6;
                half _CrestDrivenData_541C70CC_SliceIndex0_7;
                SG_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d(_CrestDrivenData_541C70CC, _CrestDrivenData_541C70CC_MeshScaleAlpha_1, _CrestDrivenData_541C70CC_LodDataTexelSize_8, _CrestDrivenData_541C70CC_GeometryGridSize_2, _CrestDrivenData_541C70CC_OceanPosScale0_3, _CrestDrivenData_541C70CC_OceanPosScale1_4, _CrestDrivenData_541C70CC_OceanParams0_5, _CrestDrivenData_541C70CC_OceanParams1_6, _CrestDrivenData_541C70CC_SliceIndex0_7);
                float _Add_87784A87_Out_2;
                Unity_Add_float(_CrestDrivenData_541C70CC_SliceIndex0_7, 1, _Add_87784A87_Out_2);
                Bindings_CrestSampleOceanDataSingle_a667f031fd6a3dd42beee0ccc432233d _CrestSampleOceanDataSingle_5C7B7E58;
                float3 _CrestSampleOceanDataSingle_5C7B7E58_Displacement_1;
                float _CrestSampleOceanDataSingle_5C7B7E58_OceanWaterDepth_5;
                float _CrestSampleOceanDataSingle_5C7B7E58_Foam_6;
                float2 _CrestSampleOceanDataSingle_5C7B7E58_Shadow_7;
                float2 _CrestSampleOceanDataSingle_5C7B7E58_Flow_8;
                float _CrestSampleOceanDataSingle_5C7B7E58_SubSurfaceScattering_9;
                SG_CrestSampleOceanDataSingle_a667f031fd6a3dd42beee0ccc432233d(_Vector2_B1CFC7F6_Out_0, _CrestDrivenData_541C70CC_OceanPosScale1_4, _CrestDrivenData_541C70CC_OceanParams1_6, _Add_87784A87_Out_2, _CrestSampleOceanDataSingle_5C7B7E58, _CrestSampleOceanDataSingle_5C7B7E58_Displacement_1, _CrestSampleOceanDataSingle_5C7B7E58_OceanWaterDepth_5, _CrestSampleOceanDataSingle_5C7B7E58_Foam_6, _CrestSampleOceanDataSingle_5C7B7E58_Shadow_7, _CrestSampleOceanDataSingle_5C7B7E58_Flow_8, _CrestSampleOceanDataSingle_5C7B7E58_SubSurfaceScattering_9);
                Bindings_CrestOceanGlobals_d50a85284893ec447a25a093505a2120 _CrestOceanGlobals_FCFEE3C8;
                float _CrestOceanGlobals_FCFEE3C8_CrestTime_1;
                float _CrestOceanGlobals_FCFEE3C8_TexelsPerWave_2;
                float3 _CrestOceanGlobals_FCFEE3C8_OceanCenterPosWorld_3;
                float _CrestOceanGlobals_FCFEE3C8_SliceCount_4;
                float _CrestOceanGlobals_FCFEE3C8_MeshScaleLerp_5;
                SG_CrestOceanGlobals_d50a85284893ec447a25a093505a2120(_CrestOceanGlobals_FCFEE3C8, _CrestOceanGlobals_FCFEE3C8_CrestTime_1, _CrestOceanGlobals_FCFEE3C8_TexelsPerWave_2, _CrestOceanGlobals_FCFEE3C8_OceanCenterPosWorld_3, _CrestOceanGlobals_FCFEE3C8_SliceCount_4, _CrestOceanGlobals_FCFEE3C8_MeshScaleLerp_5);
                float3 _Add_13827433_Out_2;
                Unity_Add_float3(_CrestSampleOceanDataSingle_5C7B7E58_Displacement_1, _CrestOceanGlobals_FCFEE3C8_OceanCenterPosWorld_3, _Add_13827433_Out_2);
                float _Split_8D03CDFB_R_1 = _Add_13827433_Out_2[0];
                float _Split_8D03CDFB_G_2 = _Add_13827433_Out_2[1];
                float _Split_8D03CDFB_B_3 = _Add_13827433_Out_2[2];
                float _Split_8D03CDFB_A_4 = 0;
                half3 _Property_513534C6_Out_0 = Vector3_71E7580E;
                half _Property_EF9152A2_Out_0 = Vector1_460D9038;
                half _Property_3D2898B2_Out_0 = Vector1_D5CE42D3;
                half _Property_35078BD5_Out_0 = Vector1_AC9C2A2;
                half _Property_1B866598_Out_0 = Vector1_8DBC6E14;
                half _Property_2016136C_Out_0 = Vector1_EA8F2BEC;
                half _Property_A64ADC3_Out_0 = Vector1_DB8E128A;
                half _Property_DDF09C09_Out_0 = Vector1_CFFD6A53;
                float3 _CustomFunction_2F6A103B_SceneColourOut_8;
                CrestNodeApplyCaustics_float(_CustomFunction_F95A252D_SceneColour_5, _CustomFunction_F95A252D_ScenePositionWS_10, _Split_8D03CDFB_G_2, _Property_513534C6_Out_0, _CustomFunction_F95A252D_SceneDistance_9, Texture2D_BA141407, _Property_EF9152A2_Out_0, _Property_3D2898B2_Out_0, _Property_35078BD5_Out_0, _Property_1B866598_Out_0, _Property_2016136C_Out_0, Texture2D_AC91C4C3, _Property_A64ADC3_Out_0, _Property_DDF09C09_Out_0, _CustomFunction_2F6A103B_SceneColourOut_8);
                #if defined(CREST_CAUSTICS_ON)
                float3 _CAUSTICS_6D445714_Out_0 = _CustomFunction_2F6A103B_SceneColourOut_8;
                #else
                float3 _CAUSTICS_6D445714_Out_0 = _CustomFunction_F95A252D_SceneColour_5;
                #endif
                float3 _Property_78DFA568_Out_0 = Vector3_83F0ECB8;
                float3 _Property_54BACED9_Out_0 = Vector3_32FB76B3;
                float3 _Add_954C4741_Out_2;
                Unity_Add_float3(_Property_78DFA568_Out_0, _Property_54BACED9_Out_0, _Add_954C4741_Out_2);
                float3 _Property_D76B9A0B_Out_0 = Vector3_6C3F4D52;
                float3 _Multiply_C51E63DE_Out_2;
                Unity_Multiply_float((_CustomFunction_F95A252D_SceneDistance_9.xxx), _Property_D76B9A0B_Out_0, _Multiply_C51E63DE_Out_2);
                float3 _Negate_ADFF8761_Out_1;
                Unity_Negate_float3(_Multiply_C51E63DE_Out_2, _Negate_ADFF8761_Out_1);
                float3 _Exponential_6FCB9AC3_Out_1;
                Unity_Exponential_float3(_Negate_ADFF8761_Out_1, _Exponential_6FCB9AC3_Out_1);
                float3 _OneMinus_9962618_Out_1;
                Unity_OneMinus_float3(_Exponential_6FCB9AC3_Out_1, _OneMinus_9962618_Out_1);
                float3 _Lerp_E9270AE8_Out_3;
                Unity_Lerp_float3(_CAUSTICS_6D445714_Out_0, _Add_954C4741_Out_2, _OneMinus_9962618_Out_1, _Lerp_E9270AE8_Out_3);
                float3 _Branch_2D3EE3D3_Out_3;
                Unity_Branch_float3(1, _Lerp_E9270AE8_Out_3, _CAUSTICS_6D445714_Out_0, _Branch_2D3EE3D3_Out_3);
                float3 _Branch_D043DFC1_Out_3;
                Unity_Branch_float3(Boolean_6AA51A5, _CAUSTICS_6D445714_Out_0, _Branch_2D3EE3D3_Out_3, _Branch_D043DFC1_Out_3);
                EmittedLight_1 = _Branch_D043DFC1_Out_3;
            }
            
            void Unity_Divide_float(float A, float B, out float Out)
            {
                Out = A / B;
            }
            
            void Unity_Power_float(float A, float B, out float Out)
            {
                Out = pow(A, B);
            }
            
            // 97e077ca2652cbf427809ae775e45d5a
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeFoam.hlsl"
            
            struct Bindings_CrestFoamWithFlow_3a6c22dceac0847a2a31cb05a577b963
            {
            };
            
            void SG_CrestFoamWithFlow_3a6c22dceac0847a2a31cb05a577b963(TEXTURE2D_PARAM(Texture2D_D9E7A343, samplerTexture2D_D9E7A343), float4 Texture2D_D9E7A343_TexelSize, float2 Vector2_C4E9ED58, float Vector1_7492C815, float Vector1_33DC93D, float Vector1_3439FC0A, float Vector1_FB133018, float Vector1_7CFAFAC1, float Vector1_53F45327, float4 Vector4_2FA9AEA5, float4 Vector4_FD283A50, float Vector1_D6DA4100, float Vector1_13F2A8C8, float2 Vector2_28A2C5B9, float3 Vector3_3AD012AA, float3 Vector3_E4AC4432, float Vector1_3E452608, float2 Vector2_5AD72ED, Bindings_CrestFoamWithFlow_3a6c22dceac0847a2a31cb05a577b963 IN, out float3 Albedo_1, out float3 NormalTS_2, out float3 Emission_3, out float Smoothness_4)
            {
                float2 _Property_B71BFD9B_Out_0 = Vector2_C4E9ED58;
                float _Property_7C437CB0_Out_0 = Vector1_7492C815;
                float _Property_BD5882DA_Out_0 = Vector1_33DC93D;
                float _Property_3EF95B2A_Out_0 = Vector1_3439FC0A;
                float _Property_38B853C9_Out_0 = Vector1_FB133018;
                float _Property_8F25A4DF_Out_0 = Vector1_7CFAFAC1;
                float _Property_561CFE5E_Out_0 = Vector1_53F45327;
                float4 _Property_A1E249A2_Out_0 = Vector4_2FA9AEA5;
                float4 _Property_9A7BA0BB_Out_0 = Vector4_FD283A50;
                float _Property_4C4E1C83_Out_0 = Vector1_D6DA4100;
                float _Property_D81DA51E_Out_0 = Vector1_13F2A8C8;
                float2 _Property_4BF1D6EA_Out_0 = Vector2_5AD72ED;
                float2 _Property_DEC66EB9_Out_0 = Vector2_28A2C5B9;
                Bindings_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1 _CrestFlow_B4596B;
                float2 _CrestFlow_B4596B_DisplacedA_1;
                float _CrestFlow_B4596B_WeightA_3;
                float2 _CrestFlow_B4596B_DisplacedB_2;
                float _CrestFlow_B4596B_WeightB_4;
                SG_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1(_Property_4BF1D6EA_Out_0, _Property_DEC66EB9_Out_0, _CrestFlow_B4596B, _CrestFlow_B4596B_DisplacedA_1, _CrestFlow_B4596B_WeightA_3, _CrestFlow_B4596B_DisplacedB_2, _CrestFlow_B4596B_WeightB_4);
                float3 _Property_EB1DCAFB_Out_0 = Vector3_3AD012AA;
                float3 _Property_A2BD94BA_Out_0 = Vector3_E4AC4432;
                float _Property_7BFA2B51_Out_0 = Vector1_3E452608;
                half3 _CustomFunction_2B0D0960_Albedo_8;
                half3 _CustomFunction_2B0D0960_NormalTS_7;
                half3 _CustomFunction_2B0D0960_Emission_9;
                half _CustomFunction_2B0D0960_Smoothness_10;
                CrestNodeFoam_half(Texture2D_D9E7A343, _Property_B71BFD9B_Out_0, _Property_7C437CB0_Out_0, _Property_BD5882DA_Out_0, _Property_3EF95B2A_Out_0, _Property_38B853C9_Out_0, _Property_8F25A4DF_Out_0, _Property_561CFE5E_Out_0, _Property_A1E249A2_Out_0, _Property_9A7BA0BB_Out_0, _Property_4C4E1C83_Out_0, _Property_D81DA51E_Out_0, _CrestFlow_B4596B_DisplacedA_1, _Property_EB1DCAFB_Out_0, _Property_A2BD94BA_Out_0, _Property_7BFA2B51_Out_0, _CustomFunction_2B0D0960_Albedo_8, _CustomFunction_2B0D0960_NormalTS_7, _CustomFunction_2B0D0960_Emission_9, _CustomFunction_2B0D0960_Smoothness_10);
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_384819B4_Out_0 = _CustomFunction_2B0D0960_Albedo_8;
                #else
                float3 _FOAM_384819B4_Out_0 = float3(0, 0, 0);
                #endif
                float3 _Multiply_278EF57C_Out_2;
                Unity_Multiply_float(_FOAM_384819B4_Out_0, (_CrestFlow_B4596B_WeightA_3.xxx), _Multiply_278EF57C_Out_2);
                float2 _Property_6338038D_Out_0 = Vector2_C4E9ED58;
                float _Property_C8444C80_Out_0 = Vector1_7492C815;
                float _Property_3DF87814_Out_0 = Vector1_33DC93D;
                float _Property_589C4301_Out_0 = Vector1_3439FC0A;
                float _Property_E9D88423_Out_0 = Vector1_FB133018;
                float _Property_366CB823_Out_0 = Vector1_7CFAFAC1;
                float _Property_1F5469F5_Out_0 = Vector1_53F45327;
                float4 _Property_920AF23F_Out_0 = Vector4_2FA9AEA5;
                float4 _Property_37F6AC84_Out_0 = Vector4_FD283A50;
                float _Property_E7E25E74_Out_0 = Vector1_D6DA4100;
                float _Property_FA2913B0_Out_0 = Vector1_13F2A8C8;
                float3 _Property_4E6AF5FF_Out_0 = Vector3_3AD012AA;
                float3 _Property_A2DA52BE_Out_0 = Vector3_E4AC4432;
                float _Property_9DE15AC9_Out_0 = Vector1_3E452608;
                half3 _CustomFunction_16EDEEAC_Albedo_8;
                half3 _CustomFunction_16EDEEAC_NormalTS_7;
                half3 _CustomFunction_16EDEEAC_Emission_9;
                half _CustomFunction_16EDEEAC_Smoothness_10;
                CrestNodeFoam_half(Texture2D_D9E7A343, _Property_6338038D_Out_0, _Property_C8444C80_Out_0, _Property_3DF87814_Out_0, _Property_589C4301_Out_0, _Property_E9D88423_Out_0, _Property_366CB823_Out_0, _Property_1F5469F5_Out_0, _Property_920AF23F_Out_0, _Property_37F6AC84_Out_0, _Property_E7E25E74_Out_0, _Property_FA2913B0_Out_0, _CrestFlow_B4596B_DisplacedB_2, _Property_4E6AF5FF_Out_0, _Property_A2DA52BE_Out_0, _Property_9DE15AC9_Out_0, _CustomFunction_16EDEEAC_Albedo_8, _CustomFunction_16EDEEAC_NormalTS_7, _CustomFunction_16EDEEAC_Emission_9, _CustomFunction_16EDEEAC_Smoothness_10);
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_E9D68DEC_Out_0 = _CustomFunction_16EDEEAC_Albedo_8;
                #else
                float3 _FOAM_E9D68DEC_Out_0 = float3(0, 0, 0);
                #endif
                float3 _Multiply_BCF80692_Out_2;
                Unity_Multiply_float((_CrestFlow_B4596B_WeightB_4.xxx), _FOAM_E9D68DEC_Out_0, _Multiply_BCF80692_Out_2);
                float3 _Add_48FC5557_Out_2;
                Unity_Add_float3(_Multiply_278EF57C_Out_2, _Multiply_BCF80692_Out_2, _Add_48FC5557_Out_2);
                #if defined(CREST_FLOW_ON)
                float3 _FLOW_1260C700_Out_0 = _Add_48FC5557_Out_2;
                #else
                float3 _FLOW_1260C700_Out_0 = _FOAM_384819B4_Out_0;
                #endif
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_14E9F7C1_Out_0 = _CustomFunction_2B0D0960_NormalTS_7;
                #else
                float3 _FOAM_14E9F7C1_Out_0 = _Property_EB1DCAFB_Out_0;
                #endif
                float3 _Multiply_FAB0278F_Out_2;
                Unity_Multiply_float(_FOAM_14E9F7C1_Out_0, (_CrestFlow_B4596B_WeightA_3.xxx), _Multiply_FAB0278F_Out_2);
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_9C6E353_Out_0 = _CustomFunction_16EDEEAC_NormalTS_7;
                #else
                float3 _FOAM_9C6E353_Out_0 = _Property_4E6AF5FF_Out_0;
                #endif
                float3 _Multiply_CE1E9F74_Out_2;
                Unity_Multiply_float((_CrestFlow_B4596B_WeightB_4.xxx), _FOAM_9C6E353_Out_0, _Multiply_CE1E9F74_Out_2);
                float3 _Add_3A03EC0D_Out_2;
                Unity_Add_float3(_Multiply_FAB0278F_Out_2, _Multiply_CE1E9F74_Out_2, _Add_3A03EC0D_Out_2);
                #if defined(CREST_FLOW_ON)
                float3 _FLOW_2D8BA180_Out_0 = _Add_3A03EC0D_Out_2;
                #else
                float3 _FLOW_2D8BA180_Out_0 = _FOAM_14E9F7C1_Out_0;
                #endif
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_D8E821F0_Out_0 = _CustomFunction_2B0D0960_Emission_9;
                #else
                float3 _FOAM_D8E821F0_Out_0 = _Property_A2BD94BA_Out_0;
                #endif
                float3 _Multiply_716921DC_Out_2;
                Unity_Multiply_float(_FOAM_D8E821F0_Out_0, (_CrestFlow_B4596B_WeightA_3.xxx), _Multiply_716921DC_Out_2);
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_9468CE46_Out_0 = _CustomFunction_16EDEEAC_Emission_9;
                #else
                float3 _FOAM_9468CE46_Out_0 = _Property_A2DA52BE_Out_0;
                #endif
                float3 _Multiply_A0DE696C_Out_2;
                Unity_Multiply_float((_CrestFlow_B4596B_WeightB_4.xxx), _FOAM_9468CE46_Out_0, _Multiply_A0DE696C_Out_2);
                float3 _Add_2EBEBFCF_Out_2;
                Unity_Add_float3(_Multiply_716921DC_Out_2, _Multiply_A0DE696C_Out_2, _Add_2EBEBFCF_Out_2);
                #if defined(CREST_FLOW_ON)
                float3 _FLOW_225158E3_Out_0 = _Add_2EBEBFCF_Out_2;
                #else
                float3 _FLOW_225158E3_Out_0 = _FOAM_D8E821F0_Out_0;
                #endif
                #if defined(CREST_FOAM_ON)
                float _FOAM_F0F633C_Out_0 = _CustomFunction_2B0D0960_Smoothness_10;
                #else
                float _FOAM_F0F633C_Out_0 = _Property_7BFA2B51_Out_0;
                #endif
                float _Multiply_C03E7AFC_Out_2;
                Unity_Multiply_float(_FOAM_F0F633C_Out_0, _CrestFlow_B4596B_WeightA_3, _Multiply_C03E7AFC_Out_2);
                #if defined(CREST_FOAM_ON)
                float _FOAM_AB9E199D_Out_0 = _CustomFunction_16EDEEAC_Smoothness_10;
                #else
                float _FOAM_AB9E199D_Out_0 = _Property_9DE15AC9_Out_0;
                #endif
                float _Multiply_8F8BE539_Out_2;
                Unity_Multiply_float(_CrestFlow_B4596B_WeightB_4, _FOAM_AB9E199D_Out_0, _Multiply_8F8BE539_Out_2);
                float _Add_7629FC1B_Out_2;
                Unity_Add_float(_Multiply_C03E7AFC_Out_2, _Multiply_8F8BE539_Out_2, _Add_7629FC1B_Out_2);
                #if defined(CREST_FLOW_ON)
                float _FLOW_386EA56_Out_0 = _Add_7629FC1B_Out_2;
                #else
                float _FLOW_386EA56_Out_0 = _FOAM_F0F633C_Out_0;
                #endif
                Albedo_1 = _FLOW_1260C700_Out_0;
                NormalTS_2 = _FLOW_2D8BA180_Out_0;
                Emission_3 = _FLOW_225158E3_Out_0;
                Smoothness_4 = _FLOW_386EA56_Out_0;
            }
            
            void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
            {
                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            }
            
            struct Bindings_CrestOceanPixel_6f6706d805d8e8649adddaaa94260269
            {
                float3 WorldSpaceViewDirection;
                float3 ViewSpacePosition;
                float3 AbsoluteWorldSpacePosition;
                float4 ScreenPosition;
                float FaceSign;
            };
            
            void SG_CrestOceanPixel_6f6706d805d8e8649adddaaa94260269(TEXTURE2D_PARAM(Texture2D_BE500045, samplerTexture2D_BE500045), float4 Texture2D_BE500045_TexelSize, float2 Vector2_2F51BFFE, float Vector1_1CEB35D8, float Vector1_43921196, float Vector1_E301593B, float Vector1_958E8942, float Vector1_2ED4C943, float Vector1_BF3AF964, float3 Vector3_EEEBAAB5, float Vector1_D3410E3, float Vector1_1EC1FE35, float2 Vector2_9C73A0C6, float Vector1_B01E1A6A, float Vector1_D74C6609, float Vector1_B61034CA, float2 Vector2_AE8873FA, float2 Vector2_69CC43DC, float Vector1_255AB964, float Vector1_47308CC2, float Vector1_26549044, float Vector1_177E111C, float Vector1_33255829, TEXTURE2D_PARAM(Texture2D_40AB1455, samplerTexture2D_40AB1455), float4 Texture2D_40AB1455_TexelSize, float Vector1_23A72EC7, float Vector1_F406EE17, float4 Vector4_2F6E352, float3 Vector3_57B74D6A, float4 Vector4_B3AD63B4, float Vector1_FA688590, float Vector1_9835666E, float Vector1_B331E24E, float Vector1_951CF2DF, float4 Vector4_ADCA8891, float Vector1_2E8E2C59, float Vector1_9BD9C342, float3 Vector3_8228B74C, float3 Vector3_B2D6AD84, float3 Vector3_D2C93D25, TEXTURE2D_PARAM(Texture2D_EB8C8549, samplerTexture2D_EB8C8549), float4 Texture2D_EB8C8549_TexelSize, float Vector1_9AE39B77, half Vector1_1B073674, float Vector1_C885385, float Vector1_90CEE6B8, float Vector1_E27586E2, TEXTURE2D_PARAM(Texture2D_DA8A756A, samplerTexture2D_DA8A756A), float4 Texture2D_DA8A756A_TexelSize, float Vector1_C96A6500, float Vector1_1AD36684, float Vector1_9E87174F, float Vector1_80D0DF9E, Bindings_CrestOceanPixel_6f6706d805d8e8649adddaaa94260269 IN, out float3 Albedo_2, out float3 NormalTS_3, out float3 Emission_4, out float Smoothness_5, out float Alpha_1, out float Specular_6)
            {
                float2 _Property_B9BA8901_Out_0 = Vector2_2F51BFFE;
                float _Property_6AEC3552_Out_0 = Vector1_1CEB35D8;
                float _Property_76EA797B_Out_0 = Vector1_43921196;
                float _Property_83C2E998_Out_0 = Vector1_E301593B;
                float _Property_705FD8D9_Out_0 = Vector1_958E8942;
                float _Property_735B5A53_Out_0 = Vector1_2ED4C943;
                float _Property_EB4C03CF_Out_0 = Vector1_BF3AF964;
                Bindings_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d _CrestDrivenData_6635D6E9;
                half _CrestDrivenData_6635D6E9_MeshScaleAlpha_1;
                half _CrestDrivenData_6635D6E9_LodDataTexelSize_8;
                half _CrestDrivenData_6635D6E9_GeometryGridSize_2;
                half3 _CrestDrivenData_6635D6E9_OceanPosScale0_3;
                half3 _CrestDrivenData_6635D6E9_OceanPosScale1_4;
                half4 _CrestDrivenData_6635D6E9_OceanParams0_5;
                half4 _CrestDrivenData_6635D6E9_OceanParams1_6;
                half _CrestDrivenData_6635D6E9_SliceIndex0_7;
                SG_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d(_CrestDrivenData_6635D6E9, _CrestDrivenData_6635D6E9_MeshScaleAlpha_1, _CrestDrivenData_6635D6E9_LodDataTexelSize_8, _CrestDrivenData_6635D6E9_GeometryGridSize_2, _CrestDrivenData_6635D6E9_OceanPosScale0_3, _CrestDrivenData_6635D6E9_OceanPosScale1_4, _CrestDrivenData_6635D6E9_OceanParams0_5, _CrestDrivenData_6635D6E9_OceanParams1_6, _CrestDrivenData_6635D6E9_SliceIndex0_7);
                float _Property_EE920C2C_Out_0 = Vector1_B61034CA;
                float _Property_8BC6F5AD_Out_0 = Vector1_B01E1A6A;
                float2 _Property_A2CEB215_Out_0 = Vector2_9C73A0C6;
                float _Property_A636CE7E_Out_0 = Vector1_23A72EC7;
                float _Property_C1531E4C_Out_0 = Vector1_F406EE17;
                float _Property_C7723E93_Out_0 = Vector1_B01E1A6A;
                float2 _Property_94C56295_Out_0 = Vector2_9C73A0C6;
                float2 _Property_E65AA85_Out_0 = Vector2_69CC43DC;
                float3 _Normalize_3574419A_Out_1;
                Unity_Normalize_float3(IN.WorldSpaceViewDirection, _Normalize_3574419A_Out_1);
                Bindings_CrestComputeNormal_61b9efc6612ab3b4f84174344af5e12a _CrestComputeNormal_6DAE4B39;
                _CrestComputeNormal_6DAE4B39.FaceSign = IN.FaceSign;
                half3 _CrestComputeNormal_6DAE4B39_Normal_1;
                SG_CrestComputeNormal_61b9efc6612ab3b4f84174344af5e12a(_CrestDrivenData_6635D6E9_OceanPosScale0_3, _CrestDrivenData_6635D6E9_OceanPosScale1_4, _CrestDrivenData_6635D6E9_OceanParams0_5, _CrestDrivenData_6635D6E9_OceanParams1_6, _CrestDrivenData_6635D6E9_SliceIndex0_7, TEXTURE2D_ARGS(Texture2D_40AB1455, samplerTexture2D_40AB1455), Texture2D_40AB1455_TexelSize, _Property_A636CE7E_Out_0, _Property_C1531E4C_Out_0, _Property_C7723E93_Out_0, _Property_94C56295_Out_0, _Property_E65AA85_Out_0, _Normalize_3574419A_Out_1, _CrestComputeNormal_6DAE4B39, _CrestComputeNormal_6DAE4B39_Normal_1);
                float _Property_FCAEBD15_Out_0 = Vector1_9E87174F;
                float _Property_2D376CE_Out_0 = Vector1_80D0DF9E;
                Bindings_CrestFresnel_c6f6c13c4fdb04e42b427e4c2610d3c9 _CrestFresnel_FD3200EB;
                _CrestFresnel_FD3200EB.FaceSign = IN.FaceSign;
                float _CrestFresnel_FD3200EB_LightTransmitted_1;
                float _CrestFresnel_FD3200EB_LightReflected_2;
                SG_CrestFresnel_c6f6c13c4fdb04e42b427e4c2610d3c9(_CrestComputeNormal_6DAE4B39_Normal_1, _Normalize_3574419A_Out_1, _Property_FCAEBD15_Out_0, _Property_2D376CE_Out_0, _CrestFresnel_FD3200EB, _CrestFresnel_FD3200EB_LightTransmitted_1, _CrestFresnel_FD3200EB_LightReflected_2);
                float _Property_2599690E_Out_0 = Vector1_9BD9C342;
                float3 _Property_A57CAD6E_Out_0 = Vector3_8228B74C;
                float4 _Property_479D2E13_Out_0 = Vector4_2F6E352;
                float3 _Property_F631E4E0_Out_0 = Vector3_57B74D6A;
                float4 _Property_D9155CD7_Out_0 = Vector4_B3AD63B4;
                float _Property_D8B923AB_Out_0 = Vector1_FA688590;
                float _Property_F7F4791A_Out_0 = Vector1_9835666E;
                float _Property_2ABF6C61_Out_0 = Vector1_B331E24E;
                float _Property_22A5FA38_Out_0 = Vector1_951CF2DF;
                float4 _Property_C1E8071C_Out_0 = Vector4_ADCA8891;
                float _Property_9AD6466F_Out_0 = Vector1_2E8E2C59;
                float _Property_4D8B881_Out_0 = Vector1_D74C6609;
                float2 _Property_5A879B44_Out_0 = Vector2_AE8873FA;
                float _Property_41C453D9_Out_0 = Vector1_255AB964;
                float3 _CustomFunction_C3448D1A_AmbientLighting_0;
                GetAmbientLighting_float(_CustomFunction_C3448D1A_AmbientLighting_0);
                float3 _Property_13E6764D_Out_0 = Vector3_B2D6AD84;
                float3 _Property_2FA7DB0_Out_0 = Vector3_D2C93D25;
                Bindings_CrestVolumeLighting_e9ed6e11710a50640bb4b811d0fa84f2 _CrestVolumeLighting_5A1A391;
                half3 _CrestVolumeLighting_5A1A391_VolumeLighting_1;
                SG_CrestVolumeLighting_e9ed6e11710a50640bb4b811d0fa84f2(_Property_479D2E13_Out_0, _Property_F631E4E0_Out_0, _Property_D9155CD7_Out_0, _Property_D8B923AB_Out_0, _Property_F7F4791A_Out_0, _Property_2ABF6C61_Out_0, _Property_22A5FA38_Out_0, _Property_C1E8071C_Out_0, _Property_9AD6466F_Out_0, _Property_4D8B881_Out_0, _Property_5A879B44_Out_0, _Property_41C453D9_Out_0, _Normalize_3574419A_Out_1, IN.AbsoluteWorldSpacePosition, _CustomFunction_C3448D1A_AmbientLighting_0, _Property_13E6764D_Out_0, _Property_2FA7DB0_Out_0, _CrestVolumeLighting_5A1A391, _CrestVolumeLighting_5A1A391_VolumeLighting_1);
                float4 _ScreenPosition_42FE0E3E_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                float _Split_66230827_R_1 = IN.ViewSpacePosition[0];
                float _Split_66230827_G_2 = IN.ViewSpacePosition[1];
                float _Split_66230827_B_3 = IN.ViewSpacePosition[2];
                float _Split_66230827_A_4 = 0;
                float _Negate_5F3C7D3D_Out_1;
                Unity_Negate_float(_Split_66230827_B_3, _Negate_5F3C7D3D_Out_1);
                float3 _SceneColor_61626E7C_Out_1;
                Unity_SceneColor_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneColor_61626E7C_Out_1);
                float _SceneDepth_FD35F7D9_Out_1;
                Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_FD35F7D9_Out_1);
                float3 _Property_DC1C088D_Out_0 = Vector3_B2D6AD84;
                float _Property_8BC39E79_Out_0 = Vector1_9AE39B77;
                half _Property_683CAF2_Out_0 = Vector1_1B073674;
                float _Property_B4B35559_Out_0 = Vector1_C885385;
                float _Property_E694F888_Out_0 = Vector1_90CEE6B8;
                float _Property_50A87698_Out_0 = Vector1_E27586E2;
                float _Property_8BC9D755_Out_0 = Vector1_C96A6500;
                float _Property_6F95DFBF_Out_0 = Vector1_1AD36684;
                float3 _Property_4729CD24_Out_0 = Vector3_EEEBAAB5;
                float _Property_C36E9B6_Out_0 = Vector1_D3410E3;
                float _Property_2C173F60_Out_0 = Vector1_1EC1FE35;
                float2 _Property_4258AA49_Out_0 = Vector2_2F51BFFE;
                float _Property_3FC34BC9_Out_0 = Vector1_1CEB35D8;
                float _Property_D42BE95B_Out_0 = Vector1_B61034CA;
                float _Split_CEEBC462_R_1 = IN.AbsoluteWorldSpacePosition[0];
                float _Split_CEEBC462_G_2 = IN.AbsoluteWorldSpacePosition[1];
                float _Split_CEEBC462_B_3 = IN.AbsoluteWorldSpacePosition[2];
                float _Split_CEEBC462_A_4 = 0;
                float2 _Vector2_BB7CEEF5_Out_0 = float2(_Split_CEEBC462_R_1, _Split_CEEBC462_B_3);
                float2 _Property_305FB73_Out_0 = Vector2_9C73A0C6;
                float _Property_88A7570_Out_0 = Vector1_B01E1A6A;
                float2 _Property_5CBA815_Out_0 = Vector2_69CC43DC;
                Bindings_CrestFoamBubblesWithFlow_e132fba35874b4923988ef35a40e48c3 _CrestFoamBubblesWithFlow_F7286BE2;
                float3 _CrestFoamBubblesWithFlow_F7286BE2_Colour_1;
                SG_CrestFoamBubblesWithFlow_e132fba35874b4923988ef35a40e48c3(_Property_4729CD24_Out_0, _Property_C36E9B6_Out_0, _Property_2C173F60_Out_0, TEXTURE2D_ARGS(Texture2D_BE500045, samplerTexture2D_BE500045), Texture2D_BE500045_TexelSize, _Property_4258AA49_Out_0, _Property_3FC34BC9_Out_0, _Property_D42BE95B_Out_0, _CrestComputeNormal_6DAE4B39_Normal_1, _CrestDrivenData_6635D6E9_OceanParams0_5, _CrestDrivenData_6635D6E9_OceanParams1_6, _Vector2_BB7CEEF5_Out_0, _Property_305FB73_Out_0, _Property_88A7570_Out_0, _Normalize_3574419A_Out_1, _Property_5CBA815_Out_0, _CrestFoamBubblesWithFlow_F7286BE2, _CrestFoamBubblesWithFlow_F7286BE2_Colour_1);
                Bindings_CrestEmission_8c56460232fde1e46ae90d905a00f908 _CrestEmission_6580C0F9;
                float3 _CrestEmission_6580C0F9_EmittedLight_1;
                SG_CrestEmission_8c56460232fde1e46ae90d905a00f908(_Property_2599690E_Out_0, _Property_A57CAD6E_Out_0, _CrestVolumeLighting_5A1A391_VolumeLighting_1, _Normalize_3574419A_Out_1, _CrestComputeNormal_6DAE4B39_Normal_1, _ScreenPosition_42FE0E3E_Out_0, _Negate_5F3C7D3D_Out_1, _SceneColor_61626E7C_Out_1, _SceneDepth_FD35F7D9_Out_1, _Property_DC1C088D_Out_0, TEXTURE2D_ARGS(Texture2D_EB8C8549, samplerTexture2D_EB8C8549), Texture2D_EB8C8549_TexelSize, _Property_8BC39E79_Out_0, _Property_683CAF2_Out_0, _Property_B4B35559_Out_0, _Property_E694F888_Out_0, _Property_50A87698_Out_0, TEXTURE2D_ARGS(Texture2D_DA8A756A, samplerTexture2D_DA8A756A), Texture2D_DA8A756A_TexelSize, _Property_8BC9D755_Out_0, _Property_6F95DFBF_Out_0, _CrestFoamBubblesWithFlow_F7286BE2_Colour_1, _CrestEmission_6580C0F9, _CrestEmission_6580C0F9_EmittedLight_1);
                float3 _Multiply_CFF25F4B_Out_2;
                Unity_Multiply_float((_CrestFresnel_FD3200EB_LightTransmitted_1.xxx), _CrestEmission_6580C0F9_EmittedLight_1, _Multiply_CFF25F4B_Out_2);
                float _Property_5DA83C2A_Out_0 = Vector1_47308CC2;
                float _Property_44533AA4_Out_0 = Vector1_26549044;
                float _Property_19CC00AB_Out_0 = Vector1_177E111C;
                float _Divide_6B6C7F25_Out_2;
                Unity_Divide_float(_Negate_5F3C7D3D_Out_1, _Property_19CC00AB_Out_0, _Divide_6B6C7F25_Out_2);
                float _Saturate_D69CDED6_Out_1;
                Unity_Saturate_float(_Divide_6B6C7F25_Out_2, _Saturate_D69CDED6_Out_1);
                float _Property_8033277F_Out_0 = Vector1_33255829;
                float _Power_BC121A67_Out_2;
                Unity_Power_float(_Saturate_D69CDED6_Out_1, _Property_8033277F_Out_0, _Power_BC121A67_Out_2);
                float _Lerp_3E7590A8_Out_3;
                Unity_Lerp_float(_Property_5DA83C2A_Out_0, _Property_44533AA4_Out_0, _Power_BC121A67_Out_2, _Lerp_3E7590A8_Out_3);
                float2 _Property_374C5B7E_Out_0 = Vector2_69CC43DC;
                Bindings_CrestFoamWithFlow_3a6c22dceac0847a2a31cb05a577b963 _CrestFoamWithFlow_193F69CA;
                float3 _CrestFoamWithFlow_193F69CA_Albedo_1;
                float3 _CrestFoamWithFlow_193F69CA_NormalTS_2;
                float3 _CrestFoamWithFlow_193F69CA_Emission_3;
                float _CrestFoamWithFlow_193F69CA_Smoothness_4;
                SG_CrestFoamWithFlow_3a6c22dceac0847a2a31cb05a577b963(TEXTURE2D_ARGS(Texture2D_BE500045, samplerTexture2D_BE500045), Texture2D_BE500045_TexelSize, _Property_B9BA8901_Out_0, _Property_6AEC3552_Out_0, _Property_76EA797B_Out_0, _Property_83C2E998_Out_0, _Property_705FD8D9_Out_0, _Property_735B5A53_Out_0, _Property_EB4C03CF_Out_0, _CrestDrivenData_6635D6E9_OceanParams0_5, _CrestDrivenData_6635D6E9_OceanParams1_6, _Property_EE920C2C_Out_0, _Property_8BC6F5AD_Out_0, _Property_A2CEB215_Out_0, _CrestComputeNormal_6DAE4B39_Normal_1, _Multiply_CFF25F4B_Out_2, _Lerp_3E7590A8_Out_3, _Property_374C5B7E_Out_0, _CrestFoamWithFlow_193F69CA, _CrestFoamWithFlow_193F69CA_Albedo_1, _CrestFoamWithFlow_193F69CA_NormalTS_2, _CrestFoamWithFlow_193F69CA_Emission_3, _CrestFoamWithFlow_193F69CA_Smoothness_4);
                float _Subtract_5BDB5822_Out_2;
                Unity_Subtract_float(_SceneDepth_FD35F7D9_Out_1, _Negate_5F3C7D3D_Out_1, _Subtract_5BDB5822_Out_2);
                float _Remap_D52CFDA9_Out_3;
                Unity_Remap_float(_Subtract_5BDB5822_Out_2, float2 (0, 0.2), float2 (0, 1), _Remap_D52CFDA9_Out_3);
                float _Saturate_896FB384_Out_1;
                Unity_Saturate_float(_Remap_D52CFDA9_Out_3, _Saturate_896FB384_Out_1);
                Albedo_2 = _CrestFoamWithFlow_193F69CA_Albedo_1;
                NormalTS_3 = _CrestFoamWithFlow_193F69CA_NormalTS_2;
                Emission_4 = _CrestFoamWithFlow_193F69CA_Emission_3;
                Smoothness_5 = _CrestFoamWithFlow_193F69CA_Smoothness_4;
                Alpha_1 = _Saturate_896FB384_Out_1;
                Specular_6 = _CrestFresnel_FD3200EB_LightReflected_2;
            }
        
            // Graph Vertex
            struct VertexDescriptionInputs
            {
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 WorldSpaceNormal;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 WorldSpaceTangent;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 ObjectSpaceBiTangent;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 WorldSpaceBiTangent;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 AbsoluteWorldSpacePosition;
                #endif
            };
            
            struct VertexDescription
            {
                float3 VertexPosition;
                float3 VertexNormal;
                float3 VertexTangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                Bindings_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d _CrestDrivenData_A1078169;
                half _CrestDrivenData_A1078169_MeshScaleAlpha_1;
                half _CrestDrivenData_A1078169_LodDataTexelSize_8;
                half _CrestDrivenData_A1078169_GeometryGridSize_2;
                half3 _CrestDrivenData_A1078169_OceanPosScale0_3;
                half3 _CrestDrivenData_A1078169_OceanPosScale1_4;
                half4 _CrestDrivenData_A1078169_OceanParams0_5;
                half4 _CrestDrivenData_A1078169_OceanParams1_6;
                half _CrestDrivenData_A1078169_SliceIndex0_7;
                SG_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d(_CrestDrivenData_A1078169, _CrestDrivenData_A1078169_MeshScaleAlpha_1, _CrestDrivenData_A1078169_LodDataTexelSize_8, _CrestDrivenData_A1078169_GeometryGridSize_2, _CrestDrivenData_A1078169_OceanPosScale0_3, _CrestDrivenData_A1078169_OceanPosScale1_4, _CrestDrivenData_A1078169_OceanParams0_5, _CrestDrivenData_A1078169_OceanParams1_6, _CrestDrivenData_A1078169_SliceIndex0_7);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                Bindings_CrestGeoMorph_9ab91ec3462438049923ca0ff16f68ad _CrestGeoMorph_8F1A4FF1;
                half3 _CrestGeoMorph_8F1A4FF1_MorphedPositionWS_1;
                half _CrestGeoMorph_8F1A4FF1_LodAlpha_2;
                SG_CrestGeoMorph_9ab91ec3462438049923ca0ff16f68ad(IN.AbsoluteWorldSpacePosition, _CrestDrivenData_A1078169_OceanPosScale0_3, _CrestDrivenData_A1078169_MeshScaleAlpha_1, _CrestDrivenData_A1078169_GeometryGridSize_2, _CrestGeoMorph_8F1A4FF1, _CrestGeoMorph_8F1A4FF1_MorphedPositionWS_1, _CrestGeoMorph_8F1A4FF1_LodAlpha_2);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Split_CC063A43_R_1 = _CrestGeoMorph_8F1A4FF1_MorphedPositionWS_1[0];
                float _Split_CC063A43_G_2 = _CrestGeoMorph_8F1A4FF1_MorphedPositionWS_1[1];
                float _Split_CC063A43_B_3 = _CrestGeoMorph_8F1A4FF1_MorphedPositionWS_1[2];
                float _Split_CC063A43_A_4 = 0;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float2 _Vector2_2D46FD43_Out_0 = float2(_Split_CC063A43_R_1, _Split_CC063A43_B_3);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                Bindings_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4 _CrestSampleOceanData_340A6610;
                float3 _CrestSampleOceanData_340A6610_Displacement_1;
                float _CrestSampleOceanData_340A6610_OceanWaterDepth_5;
                float _CrestSampleOceanData_340A6610_Foam_6;
                float2 _CrestSampleOceanData_340A6610_Shadow_7;
                float2 _CrestSampleOceanData_340A6610_Flow_8;
                float _CrestSampleOceanData_340A6610_SubSurfaceScattering_9;
                SG_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4(_Vector2_2D46FD43_Out_0, _CrestGeoMorph_8F1A4FF1_LodAlpha_2, _CrestDrivenData_A1078169_OceanPosScale0_3, _CrestDrivenData_A1078169_OceanPosScale1_4, _CrestDrivenData_A1078169_OceanParams0_5, _CrestDrivenData_A1078169_OceanParams1_6, _CrestDrivenData_A1078169_SliceIndex0_7, _CrestSampleOceanData_340A6610, _CrestSampleOceanData_340A6610_Displacement_1, _CrestSampleOceanData_340A6610_OceanWaterDepth_5, _CrestSampleOceanData_340A6610_Foam_6, _CrestSampleOceanData_340A6610_Shadow_7, _CrestSampleOceanData_340A6610_Flow_8, _CrestSampleOceanData_340A6610_SubSurfaceScattering_9);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 _Add_2D79A354_Out_2;
                Unity_Add_float3(_CrestGeoMorph_8F1A4FF1_MorphedPositionWS_1, _CrestSampleOceanData_340A6610_Displacement_1, _Add_2D79A354_Out_2);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 _Transform_9C2ACF28_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Add_2D79A354_Out_2.xyz));
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 _Transform_86205EE4_Out_1 = TransformWorldToObjectDir(float3 (0, 1, 0).xyz);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 _Transform_22BD1A85_Out_1 = TransformWorldToObjectDir(GetCameraRelativePositionWS(float3 (1, 0, 0).xyz));
                #endif
                description.VertexPosition = _Transform_9C2ACF28_Out_1;
                description.VertexNormal = _Transform_86205EE4_Out_1;
                description.VertexTangent = _Transform_22BD1A85_Out_1;
                return description;
            }
            
            // Graph Pixel
            struct SurfaceDescriptionInputs
            {
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 WorldSpaceViewDirection;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 ViewSpacePosition;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 WorldSpacePosition;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 AbsoluteWorldSpacePosition;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 ScreenPosition;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv0;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv1;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv2;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv3;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float FaceSign;
                #endif
            };
            
            struct SurfaceDescription
            {
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _TexelSize_CA3A0DD6_Width_0 = _TextureFoam_TexelSize.z;
                half _TexelSize_CA3A0DD6_Height_2 = _TextureFoam_TexelSize.w;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half2 _Vector2_15E252FB_Out_0 = half2(_TexelSize_CA3A0DD6_Width_0, _TexelSize_CA3A0DD6_Height_2);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_87E9391A_Out_0 = _FoamScale;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_BC30BCB6_Out_0 = _FoamFeather;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_5E8CB038_Out_0 = _FoamIntensityAlbedo;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_77A524C7_Out_0 = _FoamIntensityEmissive;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_CED296A4_Out_0 = _FoamSmoothness;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_D1CA3C84_Out_0 = _FoamNormalStrength;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half4 _Property_3BAB5FF_Out_0 = _FoamBubbleColor;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_EDC4DC3C_Out_0 = _FoamBubbleParallax;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_E7925FBA_Out_0 = _FoamBubblesCoverage;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                Bindings_CrestUnpackData_5bc4cf08f88035c489658d60edefeec8 _CrestUnpackData_C3998C1C;
                _CrestUnpackData_C3998C1C.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
                _CrestUnpackData_C3998C1C.uv0 = IN.uv0;
                _CrestUnpackData_C3998C1C.uv1 = IN.uv1;
                _CrestUnpackData_C3998C1C.uv2 = IN.uv2;
                float2 _CrestUnpackData_C3998C1C_PositionXZWSUndisp_2;
                float _CrestUnpackData_C3998C1C_LodAlpha_1;
                float _CrestUnpackData_C3998C1C_OceanDepth_3;
                float _CrestUnpackData_C3998C1C_Foam_4;
                float2 _CrestUnpackData_C3998C1C_Shadow_5;
                float2 _CrestUnpackData_C3998C1C_Flow_6;
                float _CrestUnpackData_C3998C1C_SubSurfaceScattering_7;
                SG_CrestUnpackData_5bc4cf08f88035c489658d60edefeec8(_CrestUnpackData_C3998C1C, _CrestUnpackData_C3998C1C_PositionXZWSUndisp_2, _CrestUnpackData_C3998C1C_LodAlpha_1, _CrestUnpackData_C3998C1C_OceanDepth_3, _CrestUnpackData_C3998C1C_Foam_4, _CrestUnpackData_C3998C1C_Shadow_5, _CrestUnpackData_C3998C1C_Flow_6, _CrestUnpackData_C3998C1C_SubSurfaceScattering_7);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_994CB3A3_Out_0 = _Smoothness;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_7079FD32_Out_0 = _SmoothnessFar;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_FAEF961B_Out_0 = _SmoothnessFarDistance;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_35DA1E70_Out_0 = _SmoothnessFalloff;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_D1430252_Out_0 = _NormalsScale;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_B882DB1E_Out_0 = _NormalsStrength;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half4 _Property_B5E474DF_Out_0 = _ScatterColourBase;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 _Property_B98AE6FA_Out_0 = _ScatterColourShallow;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_CF7CEF3A_Out_0 = _ScatterColourShallowDepthMax;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_698A3C81_Out_0 = _ScatterColourShallowDepthFalloff;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_5924F1E9_Out_0 = _SSSIntensityBase;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_67308B5F_Out_0 = _SSSIntensitySun;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half4 _Property_A723E757_Out_0 = _SSSTint;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_5AD6818A_Out_0 = _SSSSunFalloff;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_888FA49_Out_0 = _RefractionStrength;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half3 _Property_F1315B19_Out_0 = _DepthFogDensity;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                Bindings_CrestLightData_b74b6e8c0b489314ca7aea3e2cc9c54c _CrestLightData_5AD806DD;
                half3 _CrestLightData_5AD806DD_Direction_1;
                half3 _CrestLightData_5AD806DD_Intensity_2;
                SG_CrestLightData_b74b6e8c0b489314ca7aea3e2cc9c54c(_CrestLightData_5AD806DD, _CrestLightData_5AD806DD_Direction_1, _CrestLightData_5AD806DD_Intensity_2);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_A26763AB_Out_0 = _CausticsTextureScale;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_3230CB90_Out_0 = _CausticsTextureAverage;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_6B2F7D3E_Out_0 = _CausticsStrength;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_D5C90779_Out_0 = _CausticsFocalDepth;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_2743B36F_Out_0 = _CausticsDepthOfField;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_61877218_Out_0 = _CausticsDistortionStrength;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_5F1E3794_Out_0 = _CausticsDistortionScale;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                Bindings_CrestOceanPixel_6f6706d805d8e8649adddaaa94260269 _CrestOceanPixel_51593A7C;
                _CrestOceanPixel_51593A7C.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
                _CrestOceanPixel_51593A7C.ViewSpacePosition = IN.ViewSpacePosition;
                _CrestOceanPixel_51593A7C.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
                _CrestOceanPixel_51593A7C.ScreenPosition = IN.ScreenPosition;
                _CrestOceanPixel_51593A7C.FaceSign = IN.FaceSign;
                float3 _CrestOceanPixel_51593A7C_Albedo_2;
                float3 _CrestOceanPixel_51593A7C_NormalTS_3;
                float3 _CrestOceanPixel_51593A7C_Emission_4;
                float _CrestOceanPixel_51593A7C_Smoothness_5;
                float _CrestOceanPixel_51593A7C_Alpha_1;
                float _CrestOceanPixel_51593A7C_Specular_6;
                SG_CrestOceanPixel_6f6706d805d8e8649adddaaa94260269(TEXTURE2D_ARGS(_TextureFoam, sampler_TextureFoam), _TextureFoam_TexelSize, _Vector2_15E252FB_Out_0, _Property_87E9391A_Out_0, _Property_BC30BCB6_Out_0, _Property_5E8CB038_Out_0, _Property_77A524C7_Out_0, _Property_CED296A4_Out_0, _Property_D1CA3C84_Out_0, (_Property_3BAB5FF_Out_0.xyz), _Property_EDC4DC3C_Out_0, _Property_E7925FBA_Out_0, _CrestUnpackData_C3998C1C_PositionXZWSUndisp_2, _CrestUnpackData_C3998C1C_LodAlpha_1, _CrestUnpackData_C3998C1C_OceanDepth_3, _CrestUnpackData_C3998C1C_Foam_4, _CrestUnpackData_C3998C1C_Shadow_5, _CrestUnpackData_C3998C1C_Flow_6, _CrestUnpackData_C3998C1C_SubSurfaceScattering_7, _Property_994CB3A3_Out_0, _Property_7079FD32_Out_0, _Property_FAEF961B_Out_0, _Property_35DA1E70_Out_0, TEXTURE2D_ARGS(_TextureNormals, sampler_TextureNormals), _TextureNormals_TexelSize, _Property_D1430252_Out_0, _Property_B882DB1E_Out_0, _Property_B5E474DF_Out_0, float3 (0, 0, 0), _Property_B98AE6FA_Out_0, _Property_CF7CEF3A_Out_0, _Property_698A3C81_Out_0, _Property_5924F1E9_Out_0, _Property_67308B5F_Out_0, _Property_A723E757_Out_0, _Property_5AD6818A_Out_0, _Property_888FA49_Out_0, _Property_F1315B19_Out_0, _CrestLightData_5AD806DD_Direction_1, _CrestLightData_5AD806DD_Intensity_2, TEXTURE2D_ARGS(_CausticsTexture, sampler_CausticsTexture), _CausticsTexture_TexelSize, _Property_A26763AB_Out_0, _Property_3230CB90_Out_0, _Property_6B2F7D3E_Out_0, _Property_D5C90779_Out_0, _Property_2743B36F_Out_0, TEXTURE2D_ARGS(_CausticsDistortionTexture, sampler_CausticsDistortionTexture), _CausticsDistortionTexture_TexelSize, _Property_61877218_Out_0, _Property_5F1E3794_Out_0, 1.33, 1, _CrestOceanPixel_51593A7C, _CrestOceanPixel_51593A7C_Albedo_2, _CrestOceanPixel_51593A7C_NormalTS_3, _CrestOceanPixel_51593A7C_Emission_4, _CrestOceanPixel_51593A7C_Smoothness_5, _CrestOceanPixel_51593A7C_Alpha_1, _CrestOceanPixel_51593A7C_Specular_6);
                #endif
                surface.Alpha = _CrestOceanPixel_51593A7C_Alpha_1;
                surface.AlphaClipThreshold = 0;
                return surface;
            }
        
            // --------------------------------------------------
            // Structs and Packing
        
            // Generated Type: Attributes
            struct Attributes
            {
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 positionOS : POSITION;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 normalOS : NORMAL;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 tangentOS : TANGENT;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv0 : TEXCOORD0;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv1 : TEXCOORD1;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv2 : TEXCOORD2;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv3 : TEXCOORD3;
                #endif
                #if UNITY_ANY_INSTANCING_ENABLED
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                uint instanceID : INSTANCEID_SEMANTIC;
                #endif
                #endif
            };
        
            // Generated Type: Varyings
            struct Varyings
            {
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 positionCS : SV_Position;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 positionWS;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 texCoord0;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 texCoord1;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 texCoord2;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 texCoord3;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 viewDirectionWS;
                #endif
                #if UNITY_ANY_INSTANCING_ENABLED
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #endif
            };
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            // Generated Type: PackedVaryings
            struct PackedVaryings
            {
                float4 positionCS : SV_Position;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                float3 interp00 : TEXCOORD0;
                float4 interp01 : TEXCOORD1;
                float4 interp02 : TEXCOORD2;
                float4 interp03 : TEXCOORD3;
                float4 interp04 : TEXCOORD4;
                float3 interp05 : TEXCOORD5;
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Packed Type: Varyings
            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output;
                output.positionCS = input.positionCS;
                output.interp00.xyz = input.positionWS;
                output.interp01.xyzw = input.texCoord0;
                output.interp02.xyzw = input.texCoord1;
                output.interp03.xyzw = input.texCoord2;
                output.interp04.xyzw = input.texCoord3;
                output.interp05.xyz = input.viewDirectionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                return output;
            }
            
            // Unpacked Type: Varyings
            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.positionWS = input.interp00.xyz;
                output.texCoord0 = input.interp01.xyzw;
                output.texCoord1 = input.interp02.xyzw;
                output.texCoord2 = input.interp03.xyzw;
                output.texCoord3 = input.interp04.xyzw;
                output.viewDirectionWS = input.interp05.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                return output;
            }
            #endif
        
            // --------------------------------------------------
            // Build Graph Inputs
        
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            #endif
            
            
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
            #endif
            
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
            #endif
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
            #endif
            
            
            
            
            
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
            #endif
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
                return output;
            }
            
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            
            
            
            
            
            
            
            
            
            
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            #endif
            
            
            
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.WorldSpacePosition =          input.positionWS;
            #endif
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.ViewSpacePosition =           TransformWorldToView(input.positionWS);
            #endif
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(input.positionWS);
            #endif
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            #endif
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.uv0 =                         input.texCoord0;
            #endif
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.uv1 =                         input.texCoord1;
            #endif
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.uv2 =                         input.texCoord2;
            #endif
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.uv3 =                         input.texCoord3;
            #endif
            
            
            
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                return output;
            }
            
        
            // --------------------------------------------------
            // Main
        
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
            ENDHLSL
        }
		*/

        Pass
        {
            Name "Meta"
            Tags 
            { 
                "LightMode" = "Meta"
            }
           
            // Render State
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            Cull Off
            ZTest LEqual
            ZWrite On
            // ColorMask: <None>
        
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
        
            // Debug
            // <None>
        
            // --------------------------------------------------
            // Pass
        
            // Pragmas
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
        
            // Keywords
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local _ CREST_FOAM_ON
            #pragma shader_feature_local _ CREST_CAUSTICS_ON
            #pragma shader_feature_local _ CREST_FLOW_ON
            
            #if defined(CREST_FOAM_ON) && defined(CREST_CAUSTICS_ON) && defined(CREST_FLOW_ON)
                #define KEYWORD_PERMUTATION_0
            #elif defined(CREST_FOAM_ON) && defined(CREST_CAUSTICS_ON)
                #define KEYWORD_PERMUTATION_1
            #elif defined(CREST_FOAM_ON) && defined(CREST_FLOW_ON)
                #define KEYWORD_PERMUTATION_2
            #elif defined(CREST_FOAM_ON)
                #define KEYWORD_PERMUTATION_3
            #elif defined(CREST_CAUSTICS_ON) && defined(CREST_FLOW_ON)
                #define KEYWORD_PERMUTATION_4
            #elif defined(CREST_CAUSTICS_ON)
                #define KEYWORD_PERMUTATION_5
            #elif defined(CREST_FLOW_ON)
                #define KEYWORD_PERMUTATION_6
            #else
                #define KEYWORD_PERMUTATION_7
            #endif
            
            
            // Defines
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define _SURFACE_TYPE_TRANSPARENT 1
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define _NORMALMAP 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define _SPECULAR_SETUP
        #endif
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD2
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD3
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_POSITION_WS 
        #endif
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD2
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD3
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #endif
        
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_CULLFACE
        #endif
        
            #define FEATURES_GRAPH_VERTEX
            #define SHADERPASS_META
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #define REQUIRE_DEPTH_TEXTURE
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #define REQUIRE_OPAQUE_TEXTURE
            #endif
        
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        
            // --------------------------------------------------
            // Graph
        
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            half _Smoothness;
            float _SmoothnessFar;
            float _SmoothnessFarDistance;
            float _SmoothnessFalloff;
            float _Specular;
            float _Occlusion;
            half4 _ScatterColourBase;
            float4 _ScatterColourShallow;
            half _ScatterColourShallowDepthMax;
            half _ScatterColourShallowDepthFalloff;
            half _NormalsScale;
            half _NormalsStrength;
            half _SSSIntensityBase;
            half _SSSIntensitySun;
            half4 _SSSTint;
            half _SSSSunFalloff;
            half _RefractionStrength;
            half3 _DepthFogDensity;
            half _FoamScale;
            half _FoamFeather;
            half _FoamIntensityAlbedo;
            half _FoamIntensityEmissive;
            half _FoamSmoothness;
            half _FoamNormalStrength;
            half4 _FoamBubbleColor;
            half _FoamBubbleParallax;
            half _FoamBubblesCoverage;
            float _CausticsTextureScale;
            float _CausticsTextureAverage;
            float _CausticsStrength;
            float _CausticsFocalDepth;
            float _CausticsDepthOfField;
            float _CausticsDistortionStrength;
            float _CausticsDistortionScale;
            CBUFFER_END
            TEXTURE2D(_TextureNormals); SAMPLER(sampler_TextureNormals); float4 _TextureNormals_TexelSize;
            TEXTURE2D(_TextureFoam); SAMPLER(sampler_TextureFoam); half4 _TextureFoam_TexelSize;
            TEXTURE2D(_CausticsTexture); SAMPLER(sampler_CausticsTexture); float4 _CausticsTexture_TexelSize;
            TEXTURE2D(_CausticsDistortionTexture); SAMPLER(sampler_CausticsDistortionTexture); float4 _CausticsDistortionTexture_TexelSize;
            SAMPLER(SamplerState_Linear_Repeat);
        
            // Graph Functions
            
            // dc55dc563cc13ab0a4a38f335aac9cb2
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeDrivenInputs.hlsl"
            
            struct Bindings_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d
            {
            };
            
            void SG_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d(Bindings_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d IN, out half MeshScaleAlpha_1, out half LodDataTexelSize_8, out half GeometryGridSize_2, out half3 OceanPosScale0_3, out half3 OceanPosScale1_4, out half4 OceanParams0_5, out half4 OceanParams1_6, out half SliceIndex0_7)
            {
                half _CustomFunction_CD9A5F8F_MeshScaleAlpha_9;
                half _CustomFunction_CD9A5F8F_LodDataTexelSize_10;
                half _CustomFunction_CD9A5F8F_GeometryGridSize_14;
                half3 _CustomFunction_CD9A5F8F_OceanPosScale0_7;
                half3 _CustomFunction_CD9A5F8F_OceanPosScale1_8;
                half4 _CustomFunction_CD9A5F8F_OceanParams0_11;
                half4 _CustomFunction_CD9A5F8F_OceanParams1_12;
                half _CustomFunction_CD9A5F8F_SliceIndex0_13;
                CrestOceanSurfaceValues_half(_CustomFunction_CD9A5F8F_MeshScaleAlpha_9, _CustomFunction_CD9A5F8F_LodDataTexelSize_10, _CustomFunction_CD9A5F8F_GeometryGridSize_14, _CustomFunction_CD9A5F8F_OceanPosScale0_7, _CustomFunction_CD9A5F8F_OceanPosScale1_8, _CustomFunction_CD9A5F8F_OceanParams0_11, _CustomFunction_CD9A5F8F_OceanParams1_12, _CustomFunction_CD9A5F8F_SliceIndex0_13);
                MeshScaleAlpha_1 = _CustomFunction_CD9A5F8F_MeshScaleAlpha_9;
                LodDataTexelSize_8 = _CustomFunction_CD9A5F8F_LodDataTexelSize_10;
                GeometryGridSize_2 = _CustomFunction_CD9A5F8F_GeometryGridSize_14;
                OceanPosScale0_3 = _CustomFunction_CD9A5F8F_OceanPosScale0_7;
                OceanPosScale1_4 = _CustomFunction_CD9A5F8F_OceanPosScale1_8;
                OceanParams0_5 = _CustomFunction_CD9A5F8F_OceanParams0_11;
                OceanParams1_6 = _CustomFunction_CD9A5F8F_OceanParams1_12;
                SliceIndex0_7 = _CustomFunction_CD9A5F8F_SliceIndex0_13;
            }
            
            // 0749fb83929f8caedf1bd96120cd0442
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeGeoMorph.hlsl"
            
            struct Bindings_CrestGeoMorph_9ab91ec3462438049923ca0ff16f68ad
            {
            };
            
            void SG_CrestGeoMorph_9ab91ec3462438049923ca0ff16f68ad(float3 Vector3_28A0F264, float3 Vector3_F1111B56, float Vector1_691AFD6A, float Vector1_37DEE8F3, Bindings_CrestGeoMorph_9ab91ec3462438049923ca0ff16f68ad IN, out half3 MorphedPositionWS_1, out half LodAlpha_2)
            {
                float3 _Property_C4B6B1D5_Out_0 = Vector3_28A0F264;
                float3 _Property_13BC6D1A_Out_0 = Vector3_F1111B56;
                float _Property_DE4BC103_Out_0 = Vector1_691AFD6A;
                float _Property_B3D2A4DF_Out_0 = Vector1_37DEE8F3;
                half3 _CustomFunction_C8F1D6C4_MorphedPositionWS_4;
                half _CustomFunction_C8F1D6C4_LodAlpha_5;
                GeoMorph_half(_Property_C4B6B1D5_Out_0, _Property_13BC6D1A_Out_0, _Property_DE4BC103_Out_0, _Property_B3D2A4DF_Out_0, _CustomFunction_C8F1D6C4_MorphedPositionWS_4, _CustomFunction_C8F1D6C4_LodAlpha_5);
                MorphedPositionWS_1 = _CustomFunction_C8F1D6C4_MorphedPositionWS_4;
                LodAlpha_2 = _CustomFunction_C8F1D6C4_LodAlpha_5;
            }
            
            // 280776a3899d7788e7b68f32405fa944
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeSampleOceanData.hlsl"
            
            struct Bindings_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4
            {
            };
            
            void SG_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4(float2 Vector2_3171933F, float Vector1_CD41515B, float3 Vector3_7E91D336, float3 Vector3_3A95DCDF, float4 Vector4_C0B2B5EA, float4 Vector4_9C46108E, float Vector1_8EA8B92B, Bindings_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4 IN, out float3 Displacement_1, out float OceanWaterDepth_5, out float Foam_6, out float2 Shadow_7, out float2 Flow_8, out float SubSurfaceScattering_9)
            {
                float2 _Property_1A287CC6_Out_0 = Vector2_3171933F;
                float _Property_2D1D1700_Out_0 = Vector1_CD41515B;
                float3 _Property_C925A867_Out_0 = Vector3_7E91D336;
                float3 _Property_6C273401_Out_0 = Vector3_3A95DCDF;
                float4 _Property_467D1BE7_Out_0 = Vector4_C0B2B5EA;
                float4 _Property_4E045F45_Out_0 = Vector4_9C46108E;
                float _Property_59E019ED_Out_0 = Vector1_8EA8B92B;
                float3 _CustomFunction_487C31E1_Displacement_3;
                float _CustomFunction_487C31E1_OceanDepth_8;
                float _CustomFunction_487C31E1_Foam_4;
                float2 _CustomFunction_487C31E1_Shadow_5;
                float2 _CustomFunction_487C31E1_Flow_6;
                float _CustomFunction_487C31E1_SSS_17;
                CrestNodeSampleOceanData_float(_Property_1A287CC6_Out_0, _Property_2D1D1700_Out_0, _Property_C925A867_Out_0, _Property_6C273401_Out_0, _Property_467D1BE7_Out_0, _Property_4E045F45_Out_0, _Property_59E019ED_Out_0, _CustomFunction_487C31E1_Displacement_3, _CustomFunction_487C31E1_OceanDepth_8, _CustomFunction_487C31E1_Foam_4, _CustomFunction_487C31E1_Shadow_5, _CustomFunction_487C31E1_Flow_6, _CustomFunction_487C31E1_SSS_17);
                Displacement_1 = _CustomFunction_487C31E1_Displacement_3;
                OceanWaterDepth_5 = _CustomFunction_487C31E1_OceanDepth_8;
                Foam_6 = _CustomFunction_487C31E1_Foam_4;
                Shadow_7 = _CustomFunction_487C31E1_Shadow_5;
                Flow_8 = _CustomFunction_487C31E1_Flow_6;
                SubSurfaceScattering_9 = _CustomFunction_487C31E1_SSS_17;
            }
            
            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
            {
                Out = A + B;
            }
            
            // 25927ab6b885bcd0b86a13376933b174
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeComputeSamplingData.hlsl"
            
            void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
            {
                Out = A - B;
            }
            
            struct Bindings_CrestComputeOceanDataFromDisplacedPosition_1f483fe321b10c64e8b93a023ae60dd6
            {
            };
            
            void SG_CrestComputeOceanDataFromDisplacedPosition_1f483fe321b10c64e8b93a023ae60dd6(float3 Vector3_A7B8495A, Bindings_CrestComputeOceanDataFromDisplacedPosition_1f483fe321b10c64e8b93a023ae60dd6 IN, out float2 UndisplacedPosXZAWS_7, out float LodAlpha_6, out float3 Displacement_8, out float OceanWaterDepth_1, out float Foam_2, out float2 Shadow_3, out float2 Flow_4, out float SubSurfaceScattering_5)
            {
                float3 _Property_232E7FDA_Out_0 = Vector3_A7B8495A;
                float _Split_8E8A6DCA_R_1 = _Property_232E7FDA_Out_0[0];
                float _Split_8E8A6DCA_G_2 = _Property_232E7FDA_Out_0[1];
                float _Split_8E8A6DCA_B_3 = _Property_232E7FDA_Out_0[2];
                float _Split_8E8A6DCA_A_4 = 0;
                float2 _Vector2_A3499051_Out_0 = float2(_Split_8E8A6DCA_R_1, _Split_8E8A6DCA_B_3);
                half _CustomFunction_A082C8F2_LodAlpha_3;
                half3 _CustomFunction_A082C8F2_OceanPosScale0_4;
                half3 _CustomFunction_A082C8F2_OceanPosScale1_5;
                half4 _CustomFunction_A082C8F2_OceanParams0_6;
                half4 _CustomFunction_A082C8F2_OceanParams1_7;
                half _CustomFunction_A082C8F2_Slice0_1;
                half _CustomFunction_A082C8F2_Slice1_2;
                CrestComputeSamplingData_half(_Vector2_A3499051_Out_0, _CustomFunction_A082C8F2_LodAlpha_3, _CustomFunction_A082C8F2_OceanPosScale0_4, _CustomFunction_A082C8F2_OceanPosScale1_5, _CustomFunction_A082C8F2_OceanParams0_6, _CustomFunction_A082C8F2_OceanParams1_7, _CustomFunction_A082C8F2_Slice0_1, _CustomFunction_A082C8F2_Slice1_2);
                Bindings_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4 _CrestSampleOceanData_87ACC65F;
                float3 _CrestSampleOceanData_87ACC65F_Displacement_1;
                float _CrestSampleOceanData_87ACC65F_OceanWaterDepth_5;
                float _CrestSampleOceanData_87ACC65F_Foam_6;
                float2 _CrestSampleOceanData_87ACC65F_Shadow_7;
                float2 _CrestSampleOceanData_87ACC65F_Flow_8;
                float _CrestSampleOceanData_87ACC65F_SubSurfaceScattering_9;
                SG_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4(_Vector2_A3499051_Out_0, _CustomFunction_A082C8F2_LodAlpha_3, _CustomFunction_A082C8F2_OceanPosScale0_4, _CustomFunction_A082C8F2_OceanPosScale1_5, _CustomFunction_A082C8F2_OceanParams0_6, _CustomFunction_A082C8F2_OceanParams1_7, _CustomFunction_A082C8F2_Slice0_1, _CrestSampleOceanData_87ACC65F, _CrestSampleOceanData_87ACC65F_Displacement_1, _CrestSampleOceanData_87ACC65F_OceanWaterDepth_5, _CrestSampleOceanData_87ACC65F_Foam_6, _CrestSampleOceanData_87ACC65F_Shadow_7, _CrestSampleOceanData_87ACC65F_Flow_8, _CrestSampleOceanData_87ACC65F_SubSurfaceScattering_9);
                float _Split_CD3A9051_R_1 = _CrestSampleOceanData_87ACC65F_Displacement_1[0];
                float _Split_CD3A9051_G_2 = _CrestSampleOceanData_87ACC65F_Displacement_1[1];
                float _Split_CD3A9051_B_3 = _CrestSampleOceanData_87ACC65F_Displacement_1[2];
                float _Split_CD3A9051_A_4 = 0;
                float2 _Vector2_B8C0C1F0_Out_0 = float2(_Split_CD3A9051_R_1, _Split_CD3A9051_B_3);
                float2 _Subtract_8977A663_Out_2;
                Unity_Subtract_float2(_Vector2_A3499051_Out_0, _Vector2_B8C0C1F0_Out_0, _Subtract_8977A663_Out_2);
                half _CustomFunction_9D8B14F0_LodAlpha_3;
                half3 _CustomFunction_9D8B14F0_OceanPosScale0_4;
                half3 _CustomFunction_9D8B14F0_OceanPosScale1_5;
                half4 _CustomFunction_9D8B14F0_OceanParams0_6;
                half4 _CustomFunction_9D8B14F0_OceanParams1_7;
                half _CustomFunction_9D8B14F0_Slice0_1;
                half _CustomFunction_9D8B14F0_Slice1_2;
                CrestComputeSamplingData_half(_Subtract_8977A663_Out_2, _CustomFunction_9D8B14F0_LodAlpha_3, _CustomFunction_9D8B14F0_OceanPosScale0_4, _CustomFunction_9D8B14F0_OceanPosScale1_5, _CustomFunction_9D8B14F0_OceanParams0_6, _CustomFunction_9D8B14F0_OceanParams1_7, _CustomFunction_9D8B14F0_Slice0_1, _CustomFunction_9D8B14F0_Slice1_2);
                Bindings_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4 _CrestSampleOceanData_D8619779;
                float3 _CrestSampleOceanData_D8619779_Displacement_1;
                float _CrestSampleOceanData_D8619779_OceanWaterDepth_5;
                float _CrestSampleOceanData_D8619779_Foam_6;
                float2 _CrestSampleOceanData_D8619779_Shadow_7;
                float2 _CrestSampleOceanData_D8619779_Flow_8;
                float _CrestSampleOceanData_D8619779_SubSurfaceScattering_9;
                SG_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4(_Subtract_8977A663_Out_2, _CustomFunction_9D8B14F0_LodAlpha_3, _CustomFunction_9D8B14F0_OceanPosScale0_4, _CustomFunction_9D8B14F0_OceanPosScale1_5, _CustomFunction_9D8B14F0_OceanParams0_6, _CustomFunction_9D8B14F0_OceanParams1_7, _CustomFunction_9D8B14F0_Slice0_1, _CrestSampleOceanData_D8619779, _CrestSampleOceanData_D8619779_Displacement_1, _CrestSampleOceanData_D8619779_OceanWaterDepth_5, _CrestSampleOceanData_D8619779_Foam_6, _CrestSampleOceanData_D8619779_Shadow_7, _CrestSampleOceanData_D8619779_Flow_8, _CrestSampleOceanData_D8619779_SubSurfaceScattering_9);
                float _Split_1616DE7_R_1 = _CrestSampleOceanData_D8619779_Displacement_1[0];
                float _Split_1616DE7_G_2 = _CrestSampleOceanData_D8619779_Displacement_1[1];
                float _Split_1616DE7_B_3 = _CrestSampleOceanData_D8619779_Displacement_1[2];
                float _Split_1616DE7_A_4 = 0;
                float2 _Vector2_B871614F_Out_0 = float2(_Split_1616DE7_R_1, _Split_1616DE7_B_3);
                float2 _Subtract_39E2CE30_Out_2;
                Unity_Subtract_float2(_Vector2_A3499051_Out_0, _Vector2_B871614F_Out_0, _Subtract_39E2CE30_Out_2);
                half _CustomFunction_10AEAD9A_LodAlpha_3;
                half3 _CustomFunction_10AEAD9A_OceanPosScale0_4;
                half3 _CustomFunction_10AEAD9A_OceanPosScale1_5;
                half4 _CustomFunction_10AEAD9A_OceanParams0_6;
                half4 _CustomFunction_10AEAD9A_OceanParams1_7;
                half _CustomFunction_10AEAD9A_Slice0_1;
                half _CustomFunction_10AEAD9A_Slice1_2;
                CrestComputeSamplingData_half(_Subtract_39E2CE30_Out_2, _CustomFunction_10AEAD9A_LodAlpha_3, _CustomFunction_10AEAD9A_OceanPosScale0_4, _CustomFunction_10AEAD9A_OceanPosScale1_5, _CustomFunction_10AEAD9A_OceanParams0_6, _CustomFunction_10AEAD9A_OceanParams1_7, _CustomFunction_10AEAD9A_Slice0_1, _CustomFunction_10AEAD9A_Slice1_2);
                Bindings_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4 _CrestSampleOceanData_A1195FE2;
                float3 _CrestSampleOceanData_A1195FE2_Displacement_1;
                float _CrestSampleOceanData_A1195FE2_OceanWaterDepth_5;
                float _CrestSampleOceanData_A1195FE2_Foam_6;
                float2 _CrestSampleOceanData_A1195FE2_Shadow_7;
                float2 _CrestSampleOceanData_A1195FE2_Flow_8;
                float _CrestSampleOceanData_A1195FE2_SubSurfaceScattering_9;
                SG_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4(_Subtract_39E2CE30_Out_2, _CustomFunction_10AEAD9A_LodAlpha_3, _CustomFunction_10AEAD9A_OceanPosScale0_4, _CustomFunction_10AEAD9A_OceanPosScale1_5, _CustomFunction_10AEAD9A_OceanParams0_6, _CustomFunction_10AEAD9A_OceanParams1_7, _CustomFunction_10AEAD9A_Slice0_1, _CrestSampleOceanData_A1195FE2, _CrestSampleOceanData_A1195FE2_Displacement_1, _CrestSampleOceanData_A1195FE2_OceanWaterDepth_5, _CrestSampleOceanData_A1195FE2_Foam_6, _CrestSampleOceanData_A1195FE2_Shadow_7, _CrestSampleOceanData_A1195FE2_Flow_8, _CrestSampleOceanData_A1195FE2_SubSurfaceScattering_9);
                UndisplacedPosXZAWS_7 = _Subtract_39E2CE30_Out_2;
                LodAlpha_6 = _CustomFunction_10AEAD9A_LodAlpha_3;
                Displacement_8 = _CrestSampleOceanData_A1195FE2_Displacement_1;
                OceanWaterDepth_1 = _CrestSampleOceanData_A1195FE2_OceanWaterDepth_5;
                Foam_2 = _CrestSampleOceanData_A1195FE2_Foam_6;
                Shadow_3 = _CrestSampleOceanData_A1195FE2_Shadow_7;
                Flow_4 = _CrestSampleOceanData_A1195FE2_Flow_8;
                SubSurfaceScattering_5 = _CrestSampleOceanData_A1195FE2_SubSurfaceScattering_9;
            }
            
            struct Bindings_CrestUnpackData_5bc4cf08f88035c489658d60edefeec8
            {
                float3 AbsoluteWorldSpacePosition;
                half4 uv0;
                half4 uv1;
                half4 uv2;
            };
            
            void SG_CrestUnpackData_5bc4cf08f88035c489658d60edefeec8(Bindings_CrestUnpackData_5bc4cf08f88035c489658d60edefeec8 IN, out float2 PositionXZWSUndisp_2, out float LodAlpha_1, out float OceanDepth_3, out float Foam_4, out float2 Shadow_5, out float2 Flow_6, out float SubSurfaceScattering_7)
            {
                float4 _UV_CF6CD5F2_Out_0 = IN.uv0;
                float _Split_B10345C8_R_1 = _UV_CF6CD5F2_Out_0[0];
                float _Split_B10345C8_G_2 = _UV_CF6CD5F2_Out_0[1];
                float _Split_B10345C8_B_3 = _UV_CF6CD5F2_Out_0[2];
                float _Split_B10345C8_A_4 = _UV_CF6CD5F2_Out_0[3];
                float2 _Vector2_552A5E1F_Out_0 = float2(_Split_B10345C8_R_1, _Split_B10345C8_G_2);
                Bindings_CrestComputeOceanDataFromDisplacedPosition_1f483fe321b10c64e8b93a023ae60dd6 _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB;
                float2 _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_UndisplacedPosXZAWS_7;
                float _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_LodAlpha_6;
                float3 _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Displacement_8;
                float _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_OceanWaterDepth_1;
                float _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Foam_2;
                float2 _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Shadow_3;
                float2 _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Flow_4;
                float _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_SubSurfaceScattering_5;
                SG_CrestComputeOceanDataFromDisplacedPosition_1f483fe321b10c64e8b93a023ae60dd6(IN.AbsoluteWorldSpacePosition, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_UndisplacedPosXZAWS_7, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_LodAlpha_6, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Displacement_8, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_OceanWaterDepth_1, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Foam_2, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Shadow_3, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Flow_4, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_SubSurfaceScattering_5);
                #if defined(CREST_GENERATED_SHADER_ON)
                float2 _GENERATEDSHADER_71C0694B_Out_0 = _Vector2_552A5E1F_Out_0;
                #else
                float2 _GENERATEDSHADER_71C0694B_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_UndisplacedPosXZAWS_7;
                #endif
                #if defined(CREST_GENERATED_SHADER_ON)
                float _GENERATEDSHADER_2A933A74_Out_0 = _Split_B10345C8_B_3;
                #else
                float _GENERATEDSHADER_2A933A74_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_LodAlpha_6;
                #endif
                #if defined(CREST_GENERATED_SHADER_ON)
                float _GENERATEDSHADER_EFBF6036_Out_0 = _Split_B10345C8_A_4;
                #else
                float _GENERATEDSHADER_EFBF6036_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_OceanWaterDepth_1;
                #endif
                float4 _UV_39E1D2DF_Out_0 = IN.uv1;
                float _Split_CB2CA9B8_R_1 = _UV_39E1D2DF_Out_0[0];
                float _Split_CB2CA9B8_G_2 = _UV_39E1D2DF_Out_0[1];
                float _Split_CB2CA9B8_B_3 = _UV_39E1D2DF_Out_0[2];
                float _Split_CB2CA9B8_A_4 = _UV_39E1D2DF_Out_0[3];
                #if defined(CREST_GENERATED_SHADER_ON)
                float _GENERATEDSHADER_1BBAE801_Out_0 = _Split_CB2CA9B8_G_2;
                #else
                float _GENERATEDSHADER_1BBAE801_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Foam_2;
                #endif
                float4 _UV_33A67BF5_Out_0 = IN.uv2;
                float _Split_753DFB28_R_1 = _UV_33A67BF5_Out_0[0];
                float _Split_753DFB28_G_2 = _UV_33A67BF5_Out_0[1];
                float _Split_753DFB28_B_3 = _UV_33A67BF5_Out_0[2];
                float _Split_753DFB28_A_4 = _UV_33A67BF5_Out_0[3];
                float2 _Vector2_7883B8A6_Out_0 = float2(_Split_753DFB28_R_1, _Split_753DFB28_G_2);
                #if defined(CREST_GENERATED_SHADER_ON)
                float2 _GENERATEDSHADER_B499BDE6_Out_0 = _Vector2_7883B8A6_Out_0;
                #else
                float2 _GENERATEDSHADER_B499BDE6_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Shadow_3;
                #endif
                float2 _Vector2_3A83E1FC_Out_0 = float2(_Split_753DFB28_B_3, _Split_753DFB28_A_4);
                #if defined(CREST_GENERATED_SHADER_ON)
                float2 _GENERATEDSHADER_84CB20AD_Out_0 = _Vector2_3A83E1FC_Out_0;
                #else
                float2 _GENERATEDSHADER_84CB20AD_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Flow_4;
                #endif
                #if defined(CREST_GENERATED_SHADER_ON)
                float _GENERATEDSHADER_6BDC98D1_Out_0 = _Split_CB2CA9B8_R_1;
                #else
                float _GENERATEDSHADER_6BDC98D1_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_SubSurfaceScattering_5;
                #endif
                PositionXZWSUndisp_2 = _GENERATEDSHADER_71C0694B_Out_0;
                LodAlpha_1 = _GENERATEDSHADER_2A933A74_Out_0;
                OceanDepth_3 = _GENERATEDSHADER_EFBF6036_Out_0;
                Foam_4 = _GENERATEDSHADER_1BBAE801_Out_0;
                Shadow_5 = _GENERATEDSHADER_B499BDE6_Out_0;
                Flow_6 = _GENERATEDSHADER_84CB20AD_Out_0;
                SubSurfaceScattering_7 = _GENERATEDSHADER_6BDC98D1_Out_0;
            }
            
            // 673f3e02c7d6371b4ae419cc02e9dca4
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeLightData.hlsl"
            
            struct Bindings_CrestLightData_b74b6e8c0b489314ca7aea3e2cc9c54c
            {
            };
            
            void SG_CrestLightData_b74b6e8c0b489314ca7aea3e2cc9c54c(Bindings_CrestLightData_b74b6e8c0b489314ca7aea3e2cc9c54c IN, out half3 Direction_1, out half3 Intensity_2)
            {
                half3 _CustomFunction_5D41A6E0_Direction_0;
                half3 _CustomFunction_5D41A6E0_Colour_1;
                CrestNodeLightData_half(_CustomFunction_5D41A6E0_Direction_0, _CustomFunction_5D41A6E0_Colour_1);
                Direction_1 = _CustomFunction_5D41A6E0_Direction_0;
                Intensity_2 = _CustomFunction_5D41A6E0_Colour_1;
            }
            
            void Unity_Normalize_float3(float3 In, out float3 Out)
            {
                Out = normalize(In);
            }
            
            void Unity_Not_float(float In, out float Out)
            {
                Out = !In;
            }
            
            struct Bindings_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2
            {
                float FaceSign;
            };
            
            void SG_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2(Bindings_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2 IN, out float OutBoolean_1)
            {
                float _IsFrontFace_F6DF08D5_Out_0 = max(0, IN.FaceSign);
                float _Not_3B19614D_Out_1;
                Unity_Not_float(_IsFrontFace_F6DF08D5_Out_0, _Not_3B19614D_Out_1);
                OutBoolean_1 = _Not_3B19614D_Out_1;
            }
            
            // 928f91ea5fffaa68cdc1e5110d727baf
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeNormalMapping.hlsl"
            
            struct Bindings_CrestComputeNormal_61b9efc6612ab3b4f84174344af5e12a
            {
                float FaceSign;
            };
            
            void SG_CrestComputeNormal_61b9efc6612ab3b4f84174344af5e12a(float3 Vector3_FE793823, float3 Vector3_C8190B61, float4 Vector4_F18E4948, float4 Vector4_43DD8E03, float Vector1_8771A258, TEXTURE2D_PARAM(Texture2D_6CA3A26C, samplerTexture2D_6CA3A26C), float4 Texture2D_6CA3A26C_TexelSize, float Vector1_418D6270, float Vector1_6EC9A7C0, float Vector1_5D9D8139, float2 Vector2_3ED47A62, float2 Vector2_891575B0, float3 Vector3_A9F402BF, Bindings_CrestComputeNormal_61b9efc6612ab3b4f84174344af5e12a IN, out half3 Normal_1)
            {
                float3 _Property_9021A08B_Out_0 = Vector3_FE793823;
                float3 _Property_9C8BC1F1_Out_0 = Vector3_C8190B61;
                float4 _Property_BA13B38B_Out_0 = Vector4_F18E4948;
                float4 _Property_587E24D5_Out_0 = Vector4_43DD8E03;
                float _Property_1A49C52D_Out_0 = Vector1_8771A258;
                float _Property_514FBFB9_Out_0 = Vector1_418D6270;
                float _Property_27A6DF1E_Out_0 = Vector1_6EC9A7C0;
                float _Property_A277E64F_Out_0 = Vector1_5D9D8139;
                float2 _Property_805F9A1D_Out_0 = Vector2_3ED47A62;
                float2 _Property_100A6EB8_Out_0 = Vector2_891575B0;
                float3 _Property_11AD0CE_Out_0 = Vector3_A9F402BF;
                Bindings_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2 _CrestIsUnderwater_BA18A1A;
                _CrestIsUnderwater_BA18A1A.FaceSign = IN.FaceSign;
                float _CrestIsUnderwater_BA18A1A_OutBoolean_1;
                SG_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2(_CrestIsUnderwater_BA18A1A, _CrestIsUnderwater_BA18A1A_OutBoolean_1);
                half3 _CustomFunction_61A7F8B0_NormalTS_1;
                OceanNormals_half(_Property_9021A08B_Out_0, _Property_9C8BC1F1_Out_0, _Property_BA13B38B_Out_0, _Property_587E24D5_Out_0, _Property_1A49C52D_Out_0, Texture2D_6CA3A26C, _Property_514FBFB9_Out_0, _Property_27A6DF1E_Out_0, _Property_A277E64F_Out_0, _Property_805F9A1D_Out_0, _Property_100A6EB8_Out_0, _Property_11AD0CE_Out_0, _CrestIsUnderwater_BA18A1A_OutBoolean_1, _CustomFunction_61A7F8B0_NormalTS_1);
                Normal_1 = _CustomFunction_61A7F8B0_NormalTS_1;
            }
            
            // 52e02b1b13552331adad44cf4a7ae4a5
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeApplyFresnel.hlsl"
            
            struct Bindings_CrestFresnel_c6f6c13c4fdb04e42b427e4c2610d3c9
            {
                float FaceSign;
            };
            
            void SG_CrestFresnel_c6f6c13c4fdb04e42b427e4c2610d3c9(float3 Vector3_FFFD5D37, float3 Vector3_50713CBB, float Vector1_C2909293, float Vector1_DDF5B66E, Bindings_CrestFresnel_c6f6c13c4fdb04e42b427e4c2610d3c9 IN, out float LightTransmitted_1, out float LightReflected_2)
            {
                float3 _Property_3166A32_Out_0 = Vector3_50713CBB;
                float3 _Property_ED2FFB18_Out_0 = Vector3_FFFD5D37;
                Bindings_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2 _CrestIsUnderwater_291EED16;
                _CrestIsUnderwater_291EED16.FaceSign = IN.FaceSign;
                float _CrestIsUnderwater_291EED16_OutBoolean_1;
                SG_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2(_CrestIsUnderwater_291EED16, _CrestIsUnderwater_291EED16_OutBoolean_1);
                float _Property_D5B7D059_Out_0 = Vector1_DDF5B66E;
                float _Property_2395CED2_Out_0 = Vector1_C2909293;
                float _CustomFunction_6DEBC54E_LightTransmitted_1;
                float _CustomFunction_6DEBC54E_LightReflected_10;
                CrestNodeApplyFresnel_float(_Property_3166A32_Out_0, _Property_ED2FFB18_Out_0, _CrestIsUnderwater_291EED16_OutBoolean_1, _Property_D5B7D059_Out_0, _Property_2395CED2_Out_0, _CustomFunction_6DEBC54E_LightTransmitted_1, _CustomFunction_6DEBC54E_LightReflected_10);
                LightTransmitted_1 = _CustomFunction_6DEBC54E_LightTransmitted_1;
                LightReflected_2 = _CustomFunction_6DEBC54E_LightReflected_10;
            }
            
            void GetAmbientLighting_float(out float3 AmbientLighting)
            {
                AmbientLighting = half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
            }
            
            // 4e36a733a1fa5e9359282bf30157c748
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeLightWaterVolume.hlsl"
            
            struct Bindings_CrestVolumeLighting_e9ed6e11710a50640bb4b811d0fa84f2
            {
            };
            
            void SG_CrestVolumeLighting_e9ed6e11710a50640bb4b811d0fa84f2(float4 Vector4_7C3B7892, float3 Vector3_CB562741, float4 Vector4_1925E051, float Vector1_E556918C, float Vector1_67342C54, float Vector1_D7DF1AB, float Vector1_6823579F, float4 Vector4_79A1BE1F, float Vector1_7223C6AC, float Vector1_66E9E54, float2 Vector2_D3558D33, float Vector1_96B7F6DA, float3 Vector3_1559C54, float3 Vector3_EBF06BD4, float3 Vector3_4BB1E4A, float3 Vector3_938EEF71, float3 Vector3_CAD84B7A, Bindings_CrestVolumeLighting_e9ed6e11710a50640bb4b811d0fa84f2 IN, out half3 VolumeLighting_1)
            {
                float4 _Property_3BF186D2_Out_0 = Vector4_7C3B7892;
                float3 _Property_36BD3B33_Out_0 = Vector3_CB562741;
                float4 _Property_DEEB4017_Out_0 = Vector4_1925E051;
                float _Property_DEF8261_Out_0 = Vector1_E556918C;
                float _Property_E59433A0_Out_0 = Vector1_67342C54;
                float _Property_B909C546_Out_0 = Vector1_D7DF1AB;
                float _Property_E4FBA75D_Out_0 = Vector1_6823579F;
                float4 _Property_856C2495_Out_0 = Vector4_79A1BE1F;
                float _Property_D81EDA3D_Out_0 = Vector1_7223C6AC;
                float _Property_9368CB3D_Out_0 = Vector1_66E9E54;
                float2 _Property_BF038BF7_Out_0 = Vector2_D3558D33;
                float _Property_F35AF73E_Out_0 = Vector1_96B7F6DA;
                float3 _Property_32B01413_Out_0 = Vector3_1559C54;
                float3 _Property_5B1BCADB_Out_0 = Vector3_EBF06BD4;
                float3 _Property_6BBACEFC_Out_0 = Vector3_4BB1E4A;
                float3 _Property_C8DE9461_Out_0 = Vector3_938EEF71;
                float3 _Property_919832B1_Out_0 = Vector3_CAD84B7A;
                half3 _CustomFunction_F6F194A9_VolumeLighting_5;
                CrestNodeLightWaterVolume_half((_Property_3BF186D2_Out_0.xyz), _Property_36BD3B33_Out_0, (_Property_DEEB4017_Out_0.xyz), _Property_DEF8261_Out_0, _Property_E59433A0_Out_0, _Property_B909C546_Out_0, _Property_E4FBA75D_Out_0, (_Property_856C2495_Out_0.xyz), _Property_D81EDA3D_Out_0, _Property_9368CB3D_Out_0, _Property_BF038BF7_Out_0, _Property_F35AF73E_Out_0, _Property_32B01413_Out_0, _Property_5B1BCADB_Out_0, _Property_6BBACEFC_Out_0, _Property_C8DE9461_Out_0, _Property_919832B1_Out_0, _CustomFunction_F6F194A9_VolumeLighting_5);
                VolumeLighting_1 = _CustomFunction_F6F194A9_VolumeLighting_5;
            }
            
            void Unity_Negate_float(float In, out float Out)
            {
                Out = -1 * In;
            }
            
            void Unity_SceneColor_float(float4 UV, out float3 Out)
            {
                Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
            }
            
            void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
            
            // edda0395615fdcd072915b34eccb4069
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeOceanGlobals.hlsl"
            
            struct Bindings_CrestOceanGlobals_d50a85284893ec447a25a093505a2120
            {
            };
            
            void SG_CrestOceanGlobals_d50a85284893ec447a25a093505a2120(Bindings_CrestOceanGlobals_d50a85284893ec447a25a093505a2120 IN, out float CrestTime_1, out float TexelsPerWave_2, out float3 OceanCenterPosWorld_3, out float SliceCount_4, out float MeshScaleLerp_5)
            {
                float _CustomFunction_9ED6B15_CrestTime_0;
                float _CustomFunction_9ED6B15_TexelsPerWave_1;
                float3 _CustomFunction_9ED6B15_OceanCenterPosWorld_2;
                float _CustomFunction_9ED6B15_SliceCount_3;
                float _CustomFunction_9ED6B15_MeshScaleLerp_4;
                CrestNodeOceanGlobals_float(_CustomFunction_9ED6B15_CrestTime_0, _CustomFunction_9ED6B15_TexelsPerWave_1, _CustomFunction_9ED6B15_OceanCenterPosWorld_2, _CustomFunction_9ED6B15_SliceCount_3, _CustomFunction_9ED6B15_MeshScaleLerp_4);
                CrestTime_1 = _CustomFunction_9ED6B15_CrestTime_0;
                TexelsPerWave_2 = _CustomFunction_9ED6B15_TexelsPerWave_1;
                OceanCenterPosWorld_3 = _CustomFunction_9ED6B15_OceanCenterPosWorld_2;
                SliceCount_4 = _CustomFunction_9ED6B15_SliceCount_3;
                MeshScaleLerp_5 = _CustomFunction_9ED6B15_MeshScaleLerp_4;
            }
            
            void Unity_Modulo_float(float A, float B, out float Out)
            {
                Out = fmod(A, B);
            }
            
            void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
            {
                Out = A * B;
            }
            
            void Unity_Comparison_Greater_float(float A, float B, out float Out)
            {
                Out = A > B ? 1 : 0;
            }
            
            void Unity_Subtract_float(float A, float B, out float Out)
            {
                Out = A - B;
            }
            
            void Unity_Branch_float(float Predicate, float True, float False, out float Out)
            {
                Out = lerp(False, True, Predicate);
            }
            
            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }
            
            struct Bindings_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1
            {
            };
            
            void SG_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1(float2 Vector2_B562EFB1, float2 Vector2_83AA31A8, Bindings_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1 IN, out float2 DisplacedA_1, out float WeightA_3, out float2 DisplacedB_2, out float WeightB_4)
            {
                float2 _Property_DB670C03_Out_0 = Vector2_83AA31A8;
                float2 _Property_6ED023E0_Out_0 = Vector2_B562EFB1;
                Bindings_CrestOceanGlobals_d50a85284893ec447a25a093505a2120 _CrestOceanGlobals_40DCBE3E;
                float _CrestOceanGlobals_40DCBE3E_CrestTime_1;
                float _CrestOceanGlobals_40DCBE3E_TexelsPerWave_2;
                float3 _CrestOceanGlobals_40DCBE3E_OceanCenterPosWorld_3;
                float _CrestOceanGlobals_40DCBE3E_SliceCount_4;
                float _CrestOceanGlobals_40DCBE3E_MeshScaleLerp_5;
                SG_CrestOceanGlobals_d50a85284893ec447a25a093505a2120(_CrestOceanGlobals_40DCBE3E, _CrestOceanGlobals_40DCBE3E_CrestTime_1, _CrestOceanGlobals_40DCBE3E_TexelsPerWave_2, _CrestOceanGlobals_40DCBE3E_OceanCenterPosWorld_3, _CrestOceanGlobals_40DCBE3E_SliceCount_4, _CrestOceanGlobals_40DCBE3E_MeshScaleLerp_5);
                float _Modulo_CC9BC285_Out_2;
                Unity_Modulo_float(_CrestOceanGlobals_40DCBE3E_CrestTime_1, 2, _Modulo_CC9BC285_Out_2);
                float2 _Multiply_821FCA56_Out_2;
                Unity_Multiply_float(_Property_6ED023E0_Out_0, (_Modulo_CC9BC285_Out_2.xx), _Multiply_821FCA56_Out_2);
                float2 _Subtract_273125FF_Out_2;
                Unity_Subtract_float2(_Property_DB670C03_Out_0, _Multiply_821FCA56_Out_2, _Subtract_273125FF_Out_2);
                float2 _Property_C2A19C1C_Out_0 = Vector2_83AA31A8;
                #if defined(CREST_FLOW_ON)
                float2 _FLOW_963D27CC_Out_0 = _Subtract_273125FF_Out_2;
                #else
                float2 _FLOW_963D27CC_Out_0 = _Property_C2A19C1C_Out_0;
                #endif
                float _Comparison_67E5EC91_Out_2;
                Unity_Comparison_Greater_float(_Modulo_CC9BC285_Out_2, 1, _Comparison_67E5EC91_Out_2);
                float _Subtract_289E2A26_Out_2;
                Unity_Subtract_float(2, _Modulo_CC9BC285_Out_2, _Subtract_289E2A26_Out_2);
                float _Branch_57B6378F_Out_3;
                Unity_Branch_float(_Comparison_67E5EC91_Out_2, _Subtract_289E2A26_Out_2, _Modulo_CC9BC285_Out_2, _Branch_57B6378F_Out_3);
                #if defined(CREST_FLOW_ON)
                float _FLOW_AB68F2D0_Out_0 = _Branch_57B6378F_Out_3;
                #else
                float _FLOW_AB68F2D0_Out_0 = 0;
                #endif
                float2 _Property_CF607B59_Out_0 = Vector2_83AA31A8;
                float2 _Property_8EFEBF1A_Out_0 = Vector2_B562EFB1;
                float _Add_43F824C8_Out_2;
                Unity_Add_float(_CrestOceanGlobals_40DCBE3E_CrestTime_1, 1, _Add_43F824C8_Out_2);
                float _Modulo_2FF365BF_Out_2;
                Unity_Modulo_float(_Add_43F824C8_Out_2, 2, _Modulo_2FF365BF_Out_2);
                float2 _Multiply_28DD98EB_Out_2;
                Unity_Multiply_float(_Property_8EFEBF1A_Out_0, (_Modulo_2FF365BF_Out_2.xx), _Multiply_28DD98EB_Out_2);
                float2 _Subtract_1C7014D5_Out_2;
                Unity_Subtract_float2(_Property_CF607B59_Out_0, _Multiply_28DD98EB_Out_2, _Subtract_1C7014D5_Out_2);
                #if defined(CREST_FLOW_ON)
                float2 _FLOW_D38C09E5_Out_0 = _Subtract_1C7014D5_Out_2;
                #else
                float2 _FLOW_D38C09E5_Out_0 = _Property_C2A19C1C_Out_0;
                #endif
                float _Subtract_563D329D_Out_2;
                Unity_Subtract_float(1, _Branch_57B6378F_Out_3, _Subtract_563D329D_Out_2);
                #if defined(CREST_FLOW_ON)
                float _FLOW_CB3A12C4_Out_0 = _Subtract_563D329D_Out_2;
                #else
                float _FLOW_CB3A12C4_Out_0 = 0;
                #endif
                DisplacedA_1 = _FLOW_963D27CC_Out_0;
                WeightA_3 = _FLOW_AB68F2D0_Out_0;
                DisplacedB_2 = _FLOW_D38C09E5_Out_0;
                WeightB_4 = _FLOW_CB3A12C4_Out_0;
            }
            
            void Unity_Lerp_float2(float2 A, float2 B, float2 T, out float2 Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Multiply_float(float A, float B, out float Out)
            {
                Out = A * B;
            }
            
            void Unity_Add_float2(float2 A, float2 B, out float2 Out)
            {
                Out = A + B;
            }
            
            void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
            {
                Out = A / B;
            }
            
            void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
            {
                Out = dot(A, B);
            }
            
            void Unity_Lerp_float(float A, float B, float T, out float Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
            {
                Out = A * B;
            }
            
            void Unity_Saturate_float(float In, out float Out)
            {
                Out = saturate(In);
            }
            
            // 77d0d525f8d2ec135aebd23c92ac3bf7
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeAmbientLight.hlsl"
            
            struct Bindings_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744
            {
            };
            
            void SG_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744(float3 Vector3_6BC21072, float Vector1_856C8201, float Vector1_D8FFBADE, TEXTURE2D_PARAM(Texture2D_E5D62D20, samplerTexture2D_E5D62D20), float4 Texture2D_E5D62D20_TexelSize, float2 Vector2_1544647C, float Vector1_563FFC82, float Vector1_50FCE8BC, float3 Vector3_8690BC0A, float4 Vector4_8E91C60A, float4 Vector4_8FA06CD1, float2 Vector2_A796D1D3, float2 Vector2_73579388, float Vector1_5220E305, float3 Vector3_7DE999FE, Bindings_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744 IN, out float3 Colour_1)
            {
                float _Vector1_50808D77_Out_0 = 0.74;
                float2 _Property_1DB3A8DD_Out_0 = Vector2_73579388;
                float2 _Property_4E1B12A2_Out_0 = Vector2_A796D1D3;
                float _Vector1_22194DBD_Out_0 = 0.7;
                float2 _Lerp_24C286E6_Out_3;
                Unity_Lerp_float2(_Property_1DB3A8DD_Out_0, _Property_4E1B12A2_Out_0, (_Vector1_22194DBD_Out_0.xx), _Lerp_24C286E6_Out_3);
                Bindings_CrestOceanGlobals_d50a85284893ec447a25a093505a2120 _CrestOceanGlobals_FD233E7F;
                float _CrestOceanGlobals_FD233E7F_CrestTime_1;
                float _CrestOceanGlobals_FD233E7F_TexelsPerWave_2;
                float3 _CrestOceanGlobals_FD233E7F_OceanCenterPosWorld_3;
                float _CrestOceanGlobals_FD233E7F_SliceCount_4;
                float _CrestOceanGlobals_FD233E7F_MeshScaleLerp_5;
                SG_CrestOceanGlobals_d50a85284893ec447a25a093505a2120(_CrestOceanGlobals_FD233E7F, _CrestOceanGlobals_FD233E7F_CrestTime_1, _CrestOceanGlobals_FD233E7F_TexelsPerWave_2, _CrestOceanGlobals_FD233E7F_OceanCenterPosWorld_3, _CrestOceanGlobals_FD233E7F_SliceCount_4, _CrestOceanGlobals_FD233E7F_MeshScaleLerp_5);
                float _Multiply_8E48D7F_Out_2;
                Unity_Multiply_float(0.5, _CrestOceanGlobals_FD233E7F_CrestTime_1, _Multiply_8E48D7F_Out_2);
                float2 _Vector2_93AF7702_Out_0 = float2(0.866, 0.5);
                float2 _Multiply_E81E304E_Out_2;
                Unity_Multiply_float((_Multiply_8E48D7F_Out_2.xx), _Vector2_93AF7702_Out_0, _Multiply_E81E304E_Out_2);
                float2 _Add_99B474A3_Out_2;
                Unity_Add_float2(_Lerp_24C286E6_Out_3, _Multiply_E81E304E_Out_2, _Add_99B474A3_Out_2);
                float _Property_A5B593BF_Out_0 = Vector1_563FFC82;
                float2 _Divide_6E172BAC_Out_2;
                Unity_Divide_float2(_Add_99B474A3_Out_2, (_Property_A5B593BF_Out_0.xx), _Divide_6E172BAC_Out_2);
                float _Vector1_33088EF8_Out_0 = 0.125;
                float3 _Property_CBFC7F14_Out_0 = Vector3_8690BC0A;
                float _Split_638CEA28_R_1 = _Property_CBFC7F14_Out_0[0];
                float _Split_638CEA28_G_2 = _Property_CBFC7F14_Out_0[1];
                float _Split_638CEA28_B_3 = _Property_CBFC7F14_Out_0[2];
                float _Split_638CEA28_A_4 = 0;
                float2 _Vector2_1CDF6E92_Out_0 = float2(_Split_638CEA28_R_1, _Split_638CEA28_B_3);
                float2 _Multiply_FEAB095D_Out_2;
                Unity_Multiply_float((_Vector1_33088EF8_Out_0.xx), _Vector2_1CDF6E92_Out_0, _Multiply_FEAB095D_Out_2);
                float2 _Add_301F9C93_Out_2;
                Unity_Add_float2(_Divide_6E172BAC_Out_2, _Multiply_FEAB095D_Out_2, _Add_301F9C93_Out_2);
                float2 _Multiply_47C4DD4E_Out_2;
                Unity_Multiply_float((_Vector1_50808D77_Out_0.xx), _Add_301F9C93_Out_2, _Multiply_47C4DD4E_Out_2);
                float _Property_569DF47F_Out_0 = Vector1_856C8201;
                float3 _Property_D240D17_Out_0 = Vector3_7DE999FE;
                float _Split_628EF5DE_R_1 = _Property_D240D17_Out_0[0];
                float _Split_628EF5DE_G_2 = _Property_D240D17_Out_0[1];
                float _Split_628EF5DE_B_3 = _Property_D240D17_Out_0[2];
                float _Split_628EF5DE_A_4 = 0;
                float2 _Vector2_BF066046_Out_0 = float2(_Split_628EF5DE_R_1, _Split_628EF5DE_B_3);
                float2 _Multiply_43CB1359_Out_2;
                Unity_Multiply_float((_Property_569DF47F_Out_0.xx), _Vector2_BF066046_Out_0, _Multiply_43CB1359_Out_2);
                float3 _Property_122053A8_Out_0 = Vector3_8690BC0A;
                float3 _Property_ADBC2425_Out_0 = Vector3_7DE999FE;
                float _DotProduct_B4F8C812_Out_2;
                Unity_DotProduct_float3(_Property_122053A8_Out_0, _Property_ADBC2425_Out_0, _DotProduct_B4F8C812_Out_2);
                float2 _Divide_63189A2B_Out_2;
                Unity_Divide_float2(_Multiply_43CB1359_Out_2, (_DotProduct_B4F8C812_Out_2.xx), _Divide_63189A2B_Out_2);
                float2 _Add_D56F8BCC_Out_2;
                Unity_Add_float2(_Multiply_47C4DD4E_Out_2, _Divide_63189A2B_Out_2, _Add_D56F8BCC_Out_2);
                float _Vector1_4A3115D0_Out_0 = 4;
                float4 _Property_6BB45B70_Out_0 = Vector4_8E91C60A;
                float _Split_128BB5B0_R_1 = _Property_6BB45B70_Out_0[0];
                float _Split_128BB5B0_G_2 = _Property_6BB45B70_Out_0[1];
                float _Split_128BB5B0_B_3 = _Property_6BB45B70_Out_0[2];
                float _Split_128BB5B0_A_4 = _Property_6BB45B70_Out_0[3];
                float _Multiply_338764B5_Out_2;
                Unity_Multiply_float(_Vector1_4A3115D0_Out_0, _Split_128BB5B0_R_1, _Multiply_338764B5_Out_2);
                float _Property_ACBE1A98_Out_0 = Vector1_563FFC82;
                float _Multiply_69F2FFA6_Out_2;
                Unity_Multiply_float(_Multiply_338764B5_Out_2, _Property_ACBE1A98_Out_0, _Multiply_69F2FFA6_Out_2);
                float2 _Divide_FF361B20_Out_2;
                Unity_Divide_float2(_Add_D56F8BCC_Out_2, (_Multiply_69F2FFA6_Out_2.xx), _Divide_FF361B20_Out_2);
                float4 _SampleTexture2DLOD_181D539B_RGBA_0 = SAMPLE_TEXTURE2D_LOD(Texture2D_E5D62D20, SamplerState_Linear_Repeat, _Divide_FF361B20_Out_2, 3);
                float _SampleTexture2DLOD_181D539B_R_5 = _SampleTexture2DLOD_181D539B_RGBA_0.r;
                float _SampleTexture2DLOD_181D539B_G_6 = _SampleTexture2DLOD_181D539B_RGBA_0.g;
                float _SampleTexture2DLOD_181D539B_B_7 = _SampleTexture2DLOD_181D539B_RGBA_0.b;
                float _SampleTexture2DLOD_181D539B_A_8 = _SampleTexture2DLOD_181D539B_RGBA_0.a;
                float _Vector1_C260EA24_Out_0 = 4;
                float4 _Property_1EB65445_Out_0 = Vector4_8FA06CD1;
                float _Split_DFFF5F9B_R_1 = _Property_1EB65445_Out_0[0];
                float _Split_DFFF5F9B_G_2 = _Property_1EB65445_Out_0[1];
                float _Split_DFFF5F9B_B_3 = _Property_1EB65445_Out_0[2];
                float _Split_DFFF5F9B_A_4 = _Property_1EB65445_Out_0[3];
                float _Multiply_FD1848E_Out_2;
                Unity_Multiply_float(_Vector1_C260EA24_Out_0, _Split_DFFF5F9B_R_1, _Multiply_FD1848E_Out_2);
                float _Property_4D74395B_Out_0 = Vector1_563FFC82;
                float _Multiply_BB87C63D_Out_2;
                Unity_Multiply_float(_Multiply_FD1848E_Out_2, _Property_4D74395B_Out_0, _Multiply_BB87C63D_Out_2);
                float2 _Divide_7AE4E36C_Out_2;
                Unity_Divide_float2(_Add_D56F8BCC_Out_2, (_Multiply_BB87C63D_Out_2.xx), _Divide_7AE4E36C_Out_2);
                float4 _SampleTexture2DLOD_F7B977AE_RGBA_0 = SAMPLE_TEXTURE2D_LOD(Texture2D_E5D62D20, SamplerState_Linear_Repeat, _Divide_7AE4E36C_Out_2, 3);
                float _SampleTexture2DLOD_F7B977AE_R_5 = _SampleTexture2DLOD_F7B977AE_RGBA_0.r;
                float _SampleTexture2DLOD_F7B977AE_G_6 = _SampleTexture2DLOD_F7B977AE_RGBA_0.g;
                float _SampleTexture2DLOD_F7B977AE_B_7 = _SampleTexture2DLOD_F7B977AE_RGBA_0.b;
                float _SampleTexture2DLOD_F7B977AE_A_8 = _SampleTexture2DLOD_F7B977AE_RGBA_0.a;
                float _Property_8BDFE27D_Out_0 = Vector1_5220E305;
                float _Lerp_8E281E25_Out_3;
                Unity_Lerp_float(_SampleTexture2DLOD_181D539B_R_5, _SampleTexture2DLOD_F7B977AE_R_5, _Property_8BDFE27D_Out_0, _Lerp_8E281E25_Out_3);
                float3 _Property_76A1927E_Out_0 = Vector3_6BC21072;
                float3 _Multiply_559CF32F_Out_2;
                Unity_Multiply_float((_Lerp_8E281E25_Out_3.xxx), _Property_76A1927E_Out_0, _Multiply_559CF32F_Out_2);
                float _Property_47590F25_Out_0 = Vector1_50FCE8BC;
                float _Property_8CF73BE5_Out_0 = Vector1_D8FFBADE;
                float _Multiply_A19262A8_Out_2;
                Unity_Multiply_float(_Property_47590F25_Out_0, _Property_8CF73BE5_Out_0, _Multiply_A19262A8_Out_2);
                float _Saturate_A17AF199_Out_1;
                Unity_Saturate_float(_Multiply_A19262A8_Out_2, _Saturate_A17AF199_Out_1);
                float3 _Multiply_DCE93606_Out_2;
                Unity_Multiply_float(_Multiply_559CF32F_Out_2, (_Saturate_A17AF199_Out_1.xxx), _Multiply_DCE93606_Out_2);
                half3 _CustomFunction_6C4427EF_AmbientLight_0;
                CrestNodeAmbientLight_half(_CustomFunction_6C4427EF_AmbientLight_0);
                float3 _Multiply_9B6FA71B_Out_2;
                Unity_Multiply_float(_Multiply_DCE93606_Out_2, _CustomFunction_6C4427EF_AmbientLight_0, _Multiply_9B6FA71B_Out_2);
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_B0667840_Out_0 = _Multiply_9B6FA71B_Out_2;
                #else
                float3 _FOAM_B0667840_Out_0 = float3(0, 0, 0);
                #endif
                Colour_1 = _FOAM_B0667840_Out_0;
            }
            
            struct Bindings_CrestFoamBubblesWithFlow_e132fba35874b4923988ef35a40e48c3
            {
            };
            
            void SG_CrestFoamBubblesWithFlow_e132fba35874b4923988ef35a40e48c3(float3 Vector3_6BC21072, float Vector1_856C8201, float Vector1_D8FFBADE, TEXTURE2D_PARAM(Texture2D_E5D62D20, samplerTexture2D_E5D62D20), float4 Texture2D_E5D62D20_TexelSize, float2 Vector2_1544647C, float Vector1_563FFC82, float Vector1_50FCE8BC, float3 Vector3_8690BC0A, float4 Vector4_8E91C60A, float4 Vector4_8FA06CD1, float2 Vector2_A796D1D3, float2 Vector2_73579388, float Vector1_5220E305, float3 Vector3_7DE999FE, float2 Vector2_58330803, Bindings_CrestFoamBubblesWithFlow_e132fba35874b4923988ef35a40e48c3 IN, out float3 Colour_1)
            {
                float3 _Property_943DDE94_Out_0 = Vector3_6BC21072;
                float _Property_2A86C6D_Out_0 = Vector1_856C8201;
                float _Property_742EBA65_Out_0 = Vector1_D8FFBADE;
                float2 _Property_56F70460_Out_0 = Vector2_1544647C;
                float _Property_BBD1954E_Out_0 = Vector1_563FFC82;
                float _Property_63B10EE4_Out_0 = Vector1_50FCE8BC;
                float3 _Property_736DEE08_Out_0 = Vector3_8690BC0A;
                float4 _Property_E1794A68_Out_0 = Vector4_8E91C60A;
                float4 _Property_13FD15E9_Out_0 = Vector4_8FA06CD1;
                float2 _Property_8C400C63_Out_0 = Vector2_A796D1D3;
                float2 _Property_B43D23D2_Out_0 = Vector2_58330803;
                float2 _Property_6AC0F258_Out_0 = Vector2_73579388;
                Bindings_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1 _CrestFlow_2C0F2FAE;
                float2 _CrestFlow_2C0F2FAE_DisplacedA_1;
                float _CrestFlow_2C0F2FAE_WeightA_3;
                float2 _CrestFlow_2C0F2FAE_DisplacedB_2;
                float _CrestFlow_2C0F2FAE_WeightB_4;
                SG_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1(_Property_B43D23D2_Out_0, _Property_6AC0F258_Out_0, _CrestFlow_2C0F2FAE, _CrestFlow_2C0F2FAE_DisplacedA_1, _CrestFlow_2C0F2FAE_WeightA_3, _CrestFlow_2C0F2FAE_DisplacedB_2, _CrestFlow_2C0F2FAE_WeightB_4);
                float _Property_4C00CA0D_Out_0 = Vector1_5220E305;
                float3 _Property_5BF1E9DE_Out_0 = Vector3_7DE999FE;
                Bindings_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744 _CrestFoamBubbles_E18873D;
                float3 _CrestFoamBubbles_E18873D_Colour_1;
                SG_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744(_Property_943DDE94_Out_0, _Property_2A86C6D_Out_0, _Property_742EBA65_Out_0, TEXTURE2D_ARGS(Texture2D_E5D62D20, samplerTexture2D_E5D62D20), Texture2D_E5D62D20_TexelSize, _Property_56F70460_Out_0, _Property_BBD1954E_Out_0, _Property_63B10EE4_Out_0, _Property_736DEE08_Out_0, _Property_E1794A68_Out_0, _Property_13FD15E9_Out_0, _Property_8C400C63_Out_0, _CrestFlow_2C0F2FAE_DisplacedA_1, _Property_4C00CA0D_Out_0, _Property_5BF1E9DE_Out_0, _CrestFoamBubbles_E18873D, _CrestFoamBubbles_E18873D_Colour_1);
                float3 _Multiply_91E077CA_Out_2;
                Unity_Multiply_float(_CrestFoamBubbles_E18873D_Colour_1, (_CrestFlow_2C0F2FAE_WeightA_3.xxx), _Multiply_91E077CA_Out_2);
                float3 _Property_A1641BBA_Out_0 = Vector3_6BC21072;
                float _Property_3D5C8C49_Out_0 = Vector1_856C8201;
                float _Property_212108F5_Out_0 = Vector1_D8FFBADE;
                float2 _Property_E4A605_Out_0 = Vector2_1544647C;
                float _Property_6B5F6C8D_Out_0 = Vector1_563FFC82;
                float _Property_C1EFD93_Out_0 = Vector1_50FCE8BC;
                float3 _Property_374658EE_Out_0 = Vector3_8690BC0A;
                float4 _Property_93465CAB_Out_0 = Vector4_8E91C60A;
                float4 _Property_D292F7E_Out_0 = Vector4_8FA06CD1;
                float2 _Property_41EA12FB_Out_0 = Vector2_A796D1D3;
                float _Property_ACCAE2A2_Out_0 = Vector1_5220E305;
                float3 _Property_419B8C8_Out_0 = Vector3_7DE999FE;
                Bindings_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744 _CrestFoamBubbles_B2999161;
                float3 _CrestFoamBubbles_B2999161_Colour_1;
                SG_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744(_Property_A1641BBA_Out_0, _Property_3D5C8C49_Out_0, _Property_212108F5_Out_0, TEXTURE2D_ARGS(Texture2D_E5D62D20, samplerTexture2D_E5D62D20), Texture2D_E5D62D20_TexelSize, _Property_E4A605_Out_0, _Property_6B5F6C8D_Out_0, _Property_C1EFD93_Out_0, _Property_374658EE_Out_0, _Property_93465CAB_Out_0, _Property_D292F7E_Out_0, _Property_41EA12FB_Out_0, _CrestFlow_2C0F2FAE_DisplacedB_2, _Property_ACCAE2A2_Out_0, _Property_419B8C8_Out_0, _CrestFoamBubbles_B2999161, _CrestFoamBubbles_B2999161_Colour_1);
                float3 _Multiply_B28E3E4F_Out_2;
                Unity_Multiply_float(_CrestFoamBubbles_B2999161_Colour_1, (_CrestFlow_2C0F2FAE_WeightB_4.xxx), _Multiply_B28E3E4F_Out_2);
                float3 _Add_4A081B98_Out_2;
                Unity_Add_float3(_Multiply_91E077CA_Out_2, _Multiply_B28E3E4F_Out_2, _Add_4A081B98_Out_2);
                #if defined(CREST_FLOW_ON)
                float3 _FLOW_3ACDD4E5_Out_0 = _Add_4A081B98_Out_2;
                #else
                float3 _FLOW_3ACDD4E5_Out_0 = _CrestFoamBubbles_E18873D_Colour_1;
                #endif
                Colour_1 = _FLOW_3ACDD4E5_Out_0;
            }
            
            // 11f8e1767f0d2397594b0042f8356f6e
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeVolumeEmission.hlsl"
            
            struct Bindings_CrestSampleOceanDataSingle_a667f031fd6a3dd42beee0ccc432233d
            {
            };
            
            void SG_CrestSampleOceanDataSingle_a667f031fd6a3dd42beee0ccc432233d(float2 Vector2_1BD49B8D, float3 Vector3_7E91D336, float4 Vector4_C0B2B5EA, float Vector1_8EA8B92B, Bindings_CrestSampleOceanDataSingle_a667f031fd6a3dd42beee0ccc432233d IN, out float3 Displacement_1, out float OceanWaterDepth_5, out float Foam_6, out float2 Shadow_7, out float2 Flow_8, out float SubSurfaceScattering_9)
            {
                float2 _Property_FA70A3E6_Out_0 = Vector2_1BD49B8D;
                float3 _Property_C925A867_Out_0 = Vector3_7E91D336;
                float4 _Property_467D1BE7_Out_0 = Vector4_C0B2B5EA;
                float _Property_59E019ED_Out_0 = Vector1_8EA8B92B;
                float3 _CustomFunction_487C31E1_Displacement_3;
                float _CustomFunction_487C31E1_OceanDepth_8;
                float _CustomFunction_487C31E1_Foam_4;
                float2 _CustomFunction_487C31E1_Shadow_5;
                float2 _CustomFunction_487C31E1_Flow_6;
                float _CustomFunction_487C31E1_SSS_17;
                CrestNodeSampleOceanDataSingle_float(_Property_FA70A3E6_Out_0, _Property_C925A867_Out_0, _Property_467D1BE7_Out_0, _Property_59E019ED_Out_0, _CustomFunction_487C31E1_Displacement_3, _CustomFunction_487C31E1_OceanDepth_8, _CustomFunction_487C31E1_Foam_4, _CustomFunction_487C31E1_Shadow_5, _CustomFunction_487C31E1_Flow_6, _CustomFunction_487C31E1_SSS_17);
                Displacement_1 = _CustomFunction_487C31E1_Displacement_3;
                OceanWaterDepth_5 = _CustomFunction_487C31E1_OceanDepth_8;
                Foam_6 = _CustomFunction_487C31E1_Foam_4;
                Shadow_7 = _CustomFunction_487C31E1_Shadow_5;
                Flow_8 = _CustomFunction_487C31E1_Flow_6;
                SubSurfaceScattering_9 = _CustomFunction_487C31E1_SSS_17;
            }
            
            // 733e22c05b4f35356dd63172ccf21370
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeApplyCaustics.hlsl"
            
            void Unity_Negate_float3(float3 In, out float3 Out)
            {
                Out = -1 * In;
            }
            
            void Unity_Exponential_float3(float3 In, out float3 Out)
            {
                Out = exp(In);
            }
            
            void Unity_OneMinus_float3(float3 In, out float3 Out)
            {
                Out = 1 - In;
            }
            
            void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
            {
                Out = lerp(False, True, Predicate);
            }
            
            struct Bindings_CrestEmission_8c56460232fde1e46ae90d905a00f908
            {
            };
            
            void SG_CrestEmission_8c56460232fde1e46ae90d905a00f908(float Vector1_82EC3C0B, float3 Vector3_6C3F4D52, float3 Vector3_83F0ECB8, float3 Vector3_D6B78A76, float3 Vector3_703F2DD, float4 Vector4_5D0F731B, float Vector1_73B9F9E8, float3 Vector3_D4CABAFD, float Vector1_6C78E163, half3 Vector3_71E7580E, TEXTURE2D_PARAM(Texture2D_BA141407, samplerTexture2D_BA141407), float4 Texture2D_BA141407_TexelSize, half Vector1_460D9038, half Vector1_D5CE42D3, half Vector1_AC9C2A2, half Vector1_8DBC6E14, half Vector1_EA8F2BEC, TEXTURE2D_PARAM(Texture2D_AC91C4C3, samplerTexture2D_AC91C4C3), float4 Texture2D_AC91C4C3_TexelSize, half Vector1_DB8E128A, half Vector1_CFFD6A53, float3 Vector3_32FB76B3, Bindings_CrestEmission_8c56460232fde1e46ae90d905a00f908 IN, out float3 EmittedLight_1)
            {
                float Boolean_6AA51A5 = 0;
                float _Property_101786D0_Out_0 = Vector1_82EC3C0B;
                float3 _Property_833375DE_Out_0 = Vector3_83F0ECB8;
                float3 _Property_83DC9AD9_Out_0 = Vector3_703F2DD;
                float4 _Property_83CEC55B_Out_0 = Vector4_5D0F731B;
                float _Property_37502285_Out_0 = Vector1_73B9F9E8;
                float3 _Property_5935620A_Out_0 = Vector3_D4CABAFD;
                float _Property_AF5C7A5F_Out_0 = Vector1_6C78E163;
                half3 _CustomFunction_F95A252D_SceneColour_5;
                half _CustomFunction_F95A252D_SceneDistance_9;
                half3 _CustomFunction_F95A252D_ScenePositionWS_10;
                CrestNodeSceneColour_half(_Property_101786D0_Out_0, _Property_833375DE_Out_0, _Property_83DC9AD9_Out_0, _Property_83CEC55B_Out_0, _Property_37502285_Out_0, _Property_5935620A_Out_0, _Property_AF5C7A5F_Out_0, _CustomFunction_F95A252D_SceneColour_5, _CustomFunction_F95A252D_SceneDistance_9, _CustomFunction_F95A252D_ScenePositionWS_10);
                half _Split_550754E3_R_1 = _CustomFunction_F95A252D_ScenePositionWS_10[0];
                half _Split_550754E3_G_2 = _CustomFunction_F95A252D_ScenePositionWS_10[1];
                half _Split_550754E3_B_3 = _CustomFunction_F95A252D_ScenePositionWS_10[2];
                half _Split_550754E3_A_4 = 0;
                half2 _Vector2_B1CFC7F6_Out_0 = half2(_Split_550754E3_R_1, _Split_550754E3_B_3);
                Bindings_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d _CrestDrivenData_541C70CC;
                half _CrestDrivenData_541C70CC_MeshScaleAlpha_1;
                half _CrestDrivenData_541C70CC_LodDataTexelSize_8;
                half _CrestDrivenData_541C70CC_GeometryGridSize_2;
                half3 _CrestDrivenData_541C70CC_OceanPosScale0_3;
                half3 _CrestDrivenData_541C70CC_OceanPosScale1_4;
                half4 _CrestDrivenData_541C70CC_OceanParams0_5;
                half4 _CrestDrivenData_541C70CC_OceanParams1_6;
                half _CrestDrivenData_541C70CC_SliceIndex0_7;
                SG_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d(_CrestDrivenData_541C70CC, _CrestDrivenData_541C70CC_MeshScaleAlpha_1, _CrestDrivenData_541C70CC_LodDataTexelSize_8, _CrestDrivenData_541C70CC_GeometryGridSize_2, _CrestDrivenData_541C70CC_OceanPosScale0_3, _CrestDrivenData_541C70CC_OceanPosScale1_4, _CrestDrivenData_541C70CC_OceanParams0_5, _CrestDrivenData_541C70CC_OceanParams1_6, _CrestDrivenData_541C70CC_SliceIndex0_7);
                float _Add_87784A87_Out_2;
                Unity_Add_float(_CrestDrivenData_541C70CC_SliceIndex0_7, 1, _Add_87784A87_Out_2);
                Bindings_CrestSampleOceanDataSingle_a667f031fd6a3dd42beee0ccc432233d _CrestSampleOceanDataSingle_5C7B7E58;
                float3 _CrestSampleOceanDataSingle_5C7B7E58_Displacement_1;
                float _CrestSampleOceanDataSingle_5C7B7E58_OceanWaterDepth_5;
                float _CrestSampleOceanDataSingle_5C7B7E58_Foam_6;
                float2 _CrestSampleOceanDataSingle_5C7B7E58_Shadow_7;
                float2 _CrestSampleOceanDataSingle_5C7B7E58_Flow_8;
                float _CrestSampleOceanDataSingle_5C7B7E58_SubSurfaceScattering_9;
                SG_CrestSampleOceanDataSingle_a667f031fd6a3dd42beee0ccc432233d(_Vector2_B1CFC7F6_Out_0, _CrestDrivenData_541C70CC_OceanPosScale1_4, _CrestDrivenData_541C70CC_OceanParams1_6, _Add_87784A87_Out_2, _CrestSampleOceanDataSingle_5C7B7E58, _CrestSampleOceanDataSingle_5C7B7E58_Displacement_1, _CrestSampleOceanDataSingle_5C7B7E58_OceanWaterDepth_5, _CrestSampleOceanDataSingle_5C7B7E58_Foam_6, _CrestSampleOceanDataSingle_5C7B7E58_Shadow_7, _CrestSampleOceanDataSingle_5C7B7E58_Flow_8, _CrestSampleOceanDataSingle_5C7B7E58_SubSurfaceScattering_9);
                Bindings_CrestOceanGlobals_d50a85284893ec447a25a093505a2120 _CrestOceanGlobals_FCFEE3C8;
                float _CrestOceanGlobals_FCFEE3C8_CrestTime_1;
                float _CrestOceanGlobals_FCFEE3C8_TexelsPerWave_2;
                float3 _CrestOceanGlobals_FCFEE3C8_OceanCenterPosWorld_3;
                float _CrestOceanGlobals_FCFEE3C8_SliceCount_4;
                float _CrestOceanGlobals_FCFEE3C8_MeshScaleLerp_5;
                SG_CrestOceanGlobals_d50a85284893ec447a25a093505a2120(_CrestOceanGlobals_FCFEE3C8, _CrestOceanGlobals_FCFEE3C8_CrestTime_1, _CrestOceanGlobals_FCFEE3C8_TexelsPerWave_2, _CrestOceanGlobals_FCFEE3C8_OceanCenterPosWorld_3, _CrestOceanGlobals_FCFEE3C8_SliceCount_4, _CrestOceanGlobals_FCFEE3C8_MeshScaleLerp_5);
                float3 _Add_13827433_Out_2;
                Unity_Add_float3(_CrestSampleOceanDataSingle_5C7B7E58_Displacement_1, _CrestOceanGlobals_FCFEE3C8_OceanCenterPosWorld_3, _Add_13827433_Out_2);
                float _Split_8D03CDFB_R_1 = _Add_13827433_Out_2[0];
                float _Split_8D03CDFB_G_2 = _Add_13827433_Out_2[1];
                float _Split_8D03CDFB_B_3 = _Add_13827433_Out_2[2];
                float _Split_8D03CDFB_A_4 = 0;
                half3 _Property_513534C6_Out_0 = Vector3_71E7580E;
                half _Property_EF9152A2_Out_0 = Vector1_460D9038;
                half _Property_3D2898B2_Out_0 = Vector1_D5CE42D3;
                half _Property_35078BD5_Out_0 = Vector1_AC9C2A2;
                half _Property_1B866598_Out_0 = Vector1_8DBC6E14;
                half _Property_2016136C_Out_0 = Vector1_EA8F2BEC;
                half _Property_A64ADC3_Out_0 = Vector1_DB8E128A;
                half _Property_DDF09C09_Out_0 = Vector1_CFFD6A53;
                float3 _CustomFunction_2F6A103B_SceneColourOut_8;
                CrestNodeApplyCaustics_float(_CustomFunction_F95A252D_SceneColour_5, _CustomFunction_F95A252D_ScenePositionWS_10, _Split_8D03CDFB_G_2, _Property_513534C6_Out_0, _CustomFunction_F95A252D_SceneDistance_9, Texture2D_BA141407, _Property_EF9152A2_Out_0, _Property_3D2898B2_Out_0, _Property_35078BD5_Out_0, _Property_1B866598_Out_0, _Property_2016136C_Out_0, Texture2D_AC91C4C3, _Property_A64ADC3_Out_0, _Property_DDF09C09_Out_0, _CustomFunction_2F6A103B_SceneColourOut_8);
                #if defined(CREST_CAUSTICS_ON)
                float3 _CAUSTICS_6D445714_Out_0 = _CustomFunction_2F6A103B_SceneColourOut_8;
                #else
                float3 _CAUSTICS_6D445714_Out_0 = _CustomFunction_F95A252D_SceneColour_5;
                #endif
                float3 _Property_78DFA568_Out_0 = Vector3_83F0ECB8;
                float3 _Property_54BACED9_Out_0 = Vector3_32FB76B3;
                float3 _Add_954C4741_Out_2;
                Unity_Add_float3(_Property_78DFA568_Out_0, _Property_54BACED9_Out_0, _Add_954C4741_Out_2);
                float3 _Property_D76B9A0B_Out_0 = Vector3_6C3F4D52;
                float3 _Multiply_C51E63DE_Out_2;
                Unity_Multiply_float((_CustomFunction_F95A252D_SceneDistance_9.xxx), _Property_D76B9A0B_Out_0, _Multiply_C51E63DE_Out_2);
                float3 _Negate_ADFF8761_Out_1;
                Unity_Negate_float3(_Multiply_C51E63DE_Out_2, _Negate_ADFF8761_Out_1);
                float3 _Exponential_6FCB9AC3_Out_1;
                Unity_Exponential_float3(_Negate_ADFF8761_Out_1, _Exponential_6FCB9AC3_Out_1);
                float3 _OneMinus_9962618_Out_1;
                Unity_OneMinus_float3(_Exponential_6FCB9AC3_Out_1, _OneMinus_9962618_Out_1);
                float3 _Lerp_E9270AE8_Out_3;
                Unity_Lerp_float3(_CAUSTICS_6D445714_Out_0, _Add_954C4741_Out_2, _OneMinus_9962618_Out_1, _Lerp_E9270AE8_Out_3);
                float3 _Branch_2D3EE3D3_Out_3;
                Unity_Branch_float3(1, _Lerp_E9270AE8_Out_3, _CAUSTICS_6D445714_Out_0, _Branch_2D3EE3D3_Out_3);
                float3 _Branch_D043DFC1_Out_3;
                Unity_Branch_float3(Boolean_6AA51A5, _CAUSTICS_6D445714_Out_0, _Branch_2D3EE3D3_Out_3, _Branch_D043DFC1_Out_3);
                EmittedLight_1 = _Branch_D043DFC1_Out_3;
            }
            
            void Unity_Divide_float(float A, float B, out float Out)
            {
                Out = A / B;
            }
            
            void Unity_Power_float(float A, float B, out float Out)
            {
                Out = pow(A, B);
            }
            
            // 97e077ca2652cbf427809ae775e45d5a
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeFoam.hlsl"
            
            struct Bindings_CrestFoamWithFlow_3a6c22dceac0847a2a31cb05a577b963
            {
            };
            
            void SG_CrestFoamWithFlow_3a6c22dceac0847a2a31cb05a577b963(TEXTURE2D_PARAM(Texture2D_D9E7A343, samplerTexture2D_D9E7A343), float4 Texture2D_D9E7A343_TexelSize, float2 Vector2_C4E9ED58, float Vector1_7492C815, float Vector1_33DC93D, float Vector1_3439FC0A, float Vector1_FB133018, float Vector1_7CFAFAC1, float Vector1_53F45327, float4 Vector4_2FA9AEA5, float4 Vector4_FD283A50, float Vector1_D6DA4100, float Vector1_13F2A8C8, float2 Vector2_28A2C5B9, float3 Vector3_3AD012AA, float3 Vector3_E4AC4432, float Vector1_3E452608, float2 Vector2_5AD72ED, Bindings_CrestFoamWithFlow_3a6c22dceac0847a2a31cb05a577b963 IN, out float3 Albedo_1, out float3 NormalTS_2, out float3 Emission_3, out float Smoothness_4)
            {
                float2 _Property_B71BFD9B_Out_0 = Vector2_C4E9ED58;
                float _Property_7C437CB0_Out_0 = Vector1_7492C815;
                float _Property_BD5882DA_Out_0 = Vector1_33DC93D;
                float _Property_3EF95B2A_Out_0 = Vector1_3439FC0A;
                float _Property_38B853C9_Out_0 = Vector1_FB133018;
                float _Property_8F25A4DF_Out_0 = Vector1_7CFAFAC1;
                float _Property_561CFE5E_Out_0 = Vector1_53F45327;
                float4 _Property_A1E249A2_Out_0 = Vector4_2FA9AEA5;
                float4 _Property_9A7BA0BB_Out_0 = Vector4_FD283A50;
                float _Property_4C4E1C83_Out_0 = Vector1_D6DA4100;
                float _Property_D81DA51E_Out_0 = Vector1_13F2A8C8;
                float2 _Property_4BF1D6EA_Out_0 = Vector2_5AD72ED;
                float2 _Property_DEC66EB9_Out_0 = Vector2_28A2C5B9;
                Bindings_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1 _CrestFlow_B4596B;
                float2 _CrestFlow_B4596B_DisplacedA_1;
                float _CrestFlow_B4596B_WeightA_3;
                float2 _CrestFlow_B4596B_DisplacedB_2;
                float _CrestFlow_B4596B_WeightB_4;
                SG_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1(_Property_4BF1D6EA_Out_0, _Property_DEC66EB9_Out_0, _CrestFlow_B4596B, _CrestFlow_B4596B_DisplacedA_1, _CrestFlow_B4596B_WeightA_3, _CrestFlow_B4596B_DisplacedB_2, _CrestFlow_B4596B_WeightB_4);
                float3 _Property_EB1DCAFB_Out_0 = Vector3_3AD012AA;
                float3 _Property_A2BD94BA_Out_0 = Vector3_E4AC4432;
                float _Property_7BFA2B51_Out_0 = Vector1_3E452608;
                half3 _CustomFunction_2B0D0960_Albedo_8;
                half3 _CustomFunction_2B0D0960_NormalTS_7;
                half3 _CustomFunction_2B0D0960_Emission_9;
                half _CustomFunction_2B0D0960_Smoothness_10;
                CrestNodeFoam_half(Texture2D_D9E7A343, _Property_B71BFD9B_Out_0, _Property_7C437CB0_Out_0, _Property_BD5882DA_Out_0, _Property_3EF95B2A_Out_0, _Property_38B853C9_Out_0, _Property_8F25A4DF_Out_0, _Property_561CFE5E_Out_0, _Property_A1E249A2_Out_0, _Property_9A7BA0BB_Out_0, _Property_4C4E1C83_Out_0, _Property_D81DA51E_Out_0, _CrestFlow_B4596B_DisplacedA_1, _Property_EB1DCAFB_Out_0, _Property_A2BD94BA_Out_0, _Property_7BFA2B51_Out_0, _CustomFunction_2B0D0960_Albedo_8, _CustomFunction_2B0D0960_NormalTS_7, _CustomFunction_2B0D0960_Emission_9, _CustomFunction_2B0D0960_Smoothness_10);
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_384819B4_Out_0 = _CustomFunction_2B0D0960_Albedo_8;
                #else
                float3 _FOAM_384819B4_Out_0 = float3(0, 0, 0);
                #endif
                float3 _Multiply_278EF57C_Out_2;
                Unity_Multiply_float(_FOAM_384819B4_Out_0, (_CrestFlow_B4596B_WeightA_3.xxx), _Multiply_278EF57C_Out_2);
                float2 _Property_6338038D_Out_0 = Vector2_C4E9ED58;
                float _Property_C8444C80_Out_0 = Vector1_7492C815;
                float _Property_3DF87814_Out_0 = Vector1_33DC93D;
                float _Property_589C4301_Out_0 = Vector1_3439FC0A;
                float _Property_E9D88423_Out_0 = Vector1_FB133018;
                float _Property_366CB823_Out_0 = Vector1_7CFAFAC1;
                float _Property_1F5469F5_Out_0 = Vector1_53F45327;
                float4 _Property_920AF23F_Out_0 = Vector4_2FA9AEA5;
                float4 _Property_37F6AC84_Out_0 = Vector4_FD283A50;
                float _Property_E7E25E74_Out_0 = Vector1_D6DA4100;
                float _Property_FA2913B0_Out_0 = Vector1_13F2A8C8;
                float3 _Property_4E6AF5FF_Out_0 = Vector3_3AD012AA;
                float3 _Property_A2DA52BE_Out_0 = Vector3_E4AC4432;
                float _Property_9DE15AC9_Out_0 = Vector1_3E452608;
                half3 _CustomFunction_16EDEEAC_Albedo_8;
                half3 _CustomFunction_16EDEEAC_NormalTS_7;
                half3 _CustomFunction_16EDEEAC_Emission_9;
                half _CustomFunction_16EDEEAC_Smoothness_10;
                CrestNodeFoam_half(Texture2D_D9E7A343, _Property_6338038D_Out_0, _Property_C8444C80_Out_0, _Property_3DF87814_Out_0, _Property_589C4301_Out_0, _Property_E9D88423_Out_0, _Property_366CB823_Out_0, _Property_1F5469F5_Out_0, _Property_920AF23F_Out_0, _Property_37F6AC84_Out_0, _Property_E7E25E74_Out_0, _Property_FA2913B0_Out_0, _CrestFlow_B4596B_DisplacedB_2, _Property_4E6AF5FF_Out_0, _Property_A2DA52BE_Out_0, _Property_9DE15AC9_Out_0, _CustomFunction_16EDEEAC_Albedo_8, _CustomFunction_16EDEEAC_NormalTS_7, _CustomFunction_16EDEEAC_Emission_9, _CustomFunction_16EDEEAC_Smoothness_10);
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_E9D68DEC_Out_0 = _CustomFunction_16EDEEAC_Albedo_8;
                #else
                float3 _FOAM_E9D68DEC_Out_0 = float3(0, 0, 0);
                #endif
                float3 _Multiply_BCF80692_Out_2;
                Unity_Multiply_float((_CrestFlow_B4596B_WeightB_4.xxx), _FOAM_E9D68DEC_Out_0, _Multiply_BCF80692_Out_2);
                float3 _Add_48FC5557_Out_2;
                Unity_Add_float3(_Multiply_278EF57C_Out_2, _Multiply_BCF80692_Out_2, _Add_48FC5557_Out_2);
                #if defined(CREST_FLOW_ON)
                float3 _FLOW_1260C700_Out_0 = _Add_48FC5557_Out_2;
                #else
                float3 _FLOW_1260C700_Out_0 = _FOAM_384819B4_Out_0;
                #endif
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_14E9F7C1_Out_0 = _CustomFunction_2B0D0960_NormalTS_7;
                #else
                float3 _FOAM_14E9F7C1_Out_0 = _Property_EB1DCAFB_Out_0;
                #endif
                float3 _Multiply_FAB0278F_Out_2;
                Unity_Multiply_float(_FOAM_14E9F7C1_Out_0, (_CrestFlow_B4596B_WeightA_3.xxx), _Multiply_FAB0278F_Out_2);
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_9C6E353_Out_0 = _CustomFunction_16EDEEAC_NormalTS_7;
                #else
                float3 _FOAM_9C6E353_Out_0 = _Property_4E6AF5FF_Out_0;
                #endif
                float3 _Multiply_CE1E9F74_Out_2;
                Unity_Multiply_float((_CrestFlow_B4596B_WeightB_4.xxx), _FOAM_9C6E353_Out_0, _Multiply_CE1E9F74_Out_2);
                float3 _Add_3A03EC0D_Out_2;
                Unity_Add_float3(_Multiply_FAB0278F_Out_2, _Multiply_CE1E9F74_Out_2, _Add_3A03EC0D_Out_2);
                #if defined(CREST_FLOW_ON)
                float3 _FLOW_2D8BA180_Out_0 = _Add_3A03EC0D_Out_2;
                #else
                float3 _FLOW_2D8BA180_Out_0 = _FOAM_14E9F7C1_Out_0;
                #endif
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_D8E821F0_Out_0 = _CustomFunction_2B0D0960_Emission_9;
                #else
                float3 _FOAM_D8E821F0_Out_0 = _Property_A2BD94BA_Out_0;
                #endif
                float3 _Multiply_716921DC_Out_2;
                Unity_Multiply_float(_FOAM_D8E821F0_Out_0, (_CrestFlow_B4596B_WeightA_3.xxx), _Multiply_716921DC_Out_2);
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_9468CE46_Out_0 = _CustomFunction_16EDEEAC_Emission_9;
                #else
                float3 _FOAM_9468CE46_Out_0 = _Property_A2DA52BE_Out_0;
                #endif
                float3 _Multiply_A0DE696C_Out_2;
                Unity_Multiply_float((_CrestFlow_B4596B_WeightB_4.xxx), _FOAM_9468CE46_Out_0, _Multiply_A0DE696C_Out_2);
                float3 _Add_2EBEBFCF_Out_2;
                Unity_Add_float3(_Multiply_716921DC_Out_2, _Multiply_A0DE696C_Out_2, _Add_2EBEBFCF_Out_2);
                #if defined(CREST_FLOW_ON)
                float3 _FLOW_225158E3_Out_0 = _Add_2EBEBFCF_Out_2;
                #else
                float3 _FLOW_225158E3_Out_0 = _FOAM_D8E821F0_Out_0;
                #endif
                #if defined(CREST_FOAM_ON)
                float _FOAM_F0F633C_Out_0 = _CustomFunction_2B0D0960_Smoothness_10;
                #else
                float _FOAM_F0F633C_Out_0 = _Property_7BFA2B51_Out_0;
                #endif
                float _Multiply_C03E7AFC_Out_2;
                Unity_Multiply_float(_FOAM_F0F633C_Out_0, _CrestFlow_B4596B_WeightA_3, _Multiply_C03E7AFC_Out_2);
                #if defined(CREST_FOAM_ON)
                float _FOAM_AB9E199D_Out_0 = _CustomFunction_16EDEEAC_Smoothness_10;
                #else
                float _FOAM_AB9E199D_Out_0 = _Property_9DE15AC9_Out_0;
                #endif
                float _Multiply_8F8BE539_Out_2;
                Unity_Multiply_float(_CrestFlow_B4596B_WeightB_4, _FOAM_AB9E199D_Out_0, _Multiply_8F8BE539_Out_2);
                float _Add_7629FC1B_Out_2;
                Unity_Add_float(_Multiply_C03E7AFC_Out_2, _Multiply_8F8BE539_Out_2, _Add_7629FC1B_Out_2);
                #if defined(CREST_FLOW_ON)
                float _FLOW_386EA56_Out_0 = _Add_7629FC1B_Out_2;
                #else
                float _FLOW_386EA56_Out_0 = _FOAM_F0F633C_Out_0;
                #endif
                Albedo_1 = _FLOW_1260C700_Out_0;
                NormalTS_2 = _FLOW_2D8BA180_Out_0;
                Emission_3 = _FLOW_225158E3_Out_0;
                Smoothness_4 = _FLOW_386EA56_Out_0;
            }
            
            void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
            {
                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            }
            
            struct Bindings_CrestOceanPixel_6f6706d805d8e8649adddaaa94260269
            {
                float3 WorldSpaceViewDirection;
                float3 ViewSpacePosition;
                float3 AbsoluteWorldSpacePosition;
                float4 ScreenPosition;
                float FaceSign;
            };
            
            void SG_CrestOceanPixel_6f6706d805d8e8649adddaaa94260269(TEXTURE2D_PARAM(Texture2D_BE500045, samplerTexture2D_BE500045), float4 Texture2D_BE500045_TexelSize, float2 Vector2_2F51BFFE, float Vector1_1CEB35D8, float Vector1_43921196, float Vector1_E301593B, float Vector1_958E8942, float Vector1_2ED4C943, float Vector1_BF3AF964, float3 Vector3_EEEBAAB5, float Vector1_D3410E3, float Vector1_1EC1FE35, float2 Vector2_9C73A0C6, float Vector1_B01E1A6A, float Vector1_D74C6609, float Vector1_B61034CA, float2 Vector2_AE8873FA, float2 Vector2_69CC43DC, float Vector1_255AB964, float Vector1_47308CC2, float Vector1_26549044, float Vector1_177E111C, float Vector1_33255829, TEXTURE2D_PARAM(Texture2D_40AB1455, samplerTexture2D_40AB1455), float4 Texture2D_40AB1455_TexelSize, float Vector1_23A72EC7, float Vector1_F406EE17, float4 Vector4_2F6E352, float3 Vector3_57B74D6A, float4 Vector4_B3AD63B4, float Vector1_FA688590, float Vector1_9835666E, float Vector1_B331E24E, float Vector1_951CF2DF, float4 Vector4_ADCA8891, float Vector1_2E8E2C59, float Vector1_9BD9C342, float3 Vector3_8228B74C, float3 Vector3_B2D6AD84, float3 Vector3_D2C93D25, TEXTURE2D_PARAM(Texture2D_EB8C8549, samplerTexture2D_EB8C8549), float4 Texture2D_EB8C8549_TexelSize, float Vector1_9AE39B77, half Vector1_1B073674, float Vector1_C885385, float Vector1_90CEE6B8, float Vector1_E27586E2, TEXTURE2D_PARAM(Texture2D_DA8A756A, samplerTexture2D_DA8A756A), float4 Texture2D_DA8A756A_TexelSize, float Vector1_C96A6500, float Vector1_1AD36684, float Vector1_9E87174F, float Vector1_80D0DF9E, Bindings_CrestOceanPixel_6f6706d805d8e8649adddaaa94260269 IN, out float3 Albedo_2, out float3 NormalTS_3, out float3 Emission_4, out float Smoothness_5, out float Alpha_1, out float Specular_6)
            {
                float2 _Property_B9BA8901_Out_0 = Vector2_2F51BFFE;
                float _Property_6AEC3552_Out_0 = Vector1_1CEB35D8;
                float _Property_76EA797B_Out_0 = Vector1_43921196;
                float _Property_83C2E998_Out_0 = Vector1_E301593B;
                float _Property_705FD8D9_Out_0 = Vector1_958E8942;
                float _Property_735B5A53_Out_0 = Vector1_2ED4C943;
                float _Property_EB4C03CF_Out_0 = Vector1_BF3AF964;
                Bindings_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d _CrestDrivenData_6635D6E9;
                half _CrestDrivenData_6635D6E9_MeshScaleAlpha_1;
                half _CrestDrivenData_6635D6E9_LodDataTexelSize_8;
                half _CrestDrivenData_6635D6E9_GeometryGridSize_2;
                half3 _CrestDrivenData_6635D6E9_OceanPosScale0_3;
                half3 _CrestDrivenData_6635D6E9_OceanPosScale1_4;
                half4 _CrestDrivenData_6635D6E9_OceanParams0_5;
                half4 _CrestDrivenData_6635D6E9_OceanParams1_6;
                half _CrestDrivenData_6635D6E9_SliceIndex0_7;
                SG_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d(_CrestDrivenData_6635D6E9, _CrestDrivenData_6635D6E9_MeshScaleAlpha_1, _CrestDrivenData_6635D6E9_LodDataTexelSize_8, _CrestDrivenData_6635D6E9_GeometryGridSize_2, _CrestDrivenData_6635D6E9_OceanPosScale0_3, _CrestDrivenData_6635D6E9_OceanPosScale1_4, _CrestDrivenData_6635D6E9_OceanParams0_5, _CrestDrivenData_6635D6E9_OceanParams1_6, _CrestDrivenData_6635D6E9_SliceIndex0_7);
                float _Property_EE920C2C_Out_0 = Vector1_B61034CA;
                float _Property_8BC6F5AD_Out_0 = Vector1_B01E1A6A;
                float2 _Property_A2CEB215_Out_0 = Vector2_9C73A0C6;
                float _Property_A636CE7E_Out_0 = Vector1_23A72EC7;
                float _Property_C1531E4C_Out_0 = Vector1_F406EE17;
                float _Property_C7723E93_Out_0 = Vector1_B01E1A6A;
                float2 _Property_94C56295_Out_0 = Vector2_9C73A0C6;
                float2 _Property_E65AA85_Out_0 = Vector2_69CC43DC;
                float3 _Normalize_3574419A_Out_1;
                Unity_Normalize_float3(IN.WorldSpaceViewDirection, _Normalize_3574419A_Out_1);
                Bindings_CrestComputeNormal_61b9efc6612ab3b4f84174344af5e12a _CrestComputeNormal_6DAE4B39;
                _CrestComputeNormal_6DAE4B39.FaceSign = IN.FaceSign;
                half3 _CrestComputeNormal_6DAE4B39_Normal_1;
                SG_CrestComputeNormal_61b9efc6612ab3b4f84174344af5e12a(_CrestDrivenData_6635D6E9_OceanPosScale0_3, _CrestDrivenData_6635D6E9_OceanPosScale1_4, _CrestDrivenData_6635D6E9_OceanParams0_5, _CrestDrivenData_6635D6E9_OceanParams1_6, _CrestDrivenData_6635D6E9_SliceIndex0_7, TEXTURE2D_ARGS(Texture2D_40AB1455, samplerTexture2D_40AB1455), Texture2D_40AB1455_TexelSize, _Property_A636CE7E_Out_0, _Property_C1531E4C_Out_0, _Property_C7723E93_Out_0, _Property_94C56295_Out_0, _Property_E65AA85_Out_0, _Normalize_3574419A_Out_1, _CrestComputeNormal_6DAE4B39, _CrestComputeNormal_6DAE4B39_Normal_1);
                float _Property_FCAEBD15_Out_0 = Vector1_9E87174F;
                float _Property_2D376CE_Out_0 = Vector1_80D0DF9E;
                Bindings_CrestFresnel_c6f6c13c4fdb04e42b427e4c2610d3c9 _CrestFresnel_FD3200EB;
                _CrestFresnel_FD3200EB.FaceSign = IN.FaceSign;
                float _CrestFresnel_FD3200EB_LightTransmitted_1;
                float _CrestFresnel_FD3200EB_LightReflected_2;
                SG_CrestFresnel_c6f6c13c4fdb04e42b427e4c2610d3c9(_CrestComputeNormal_6DAE4B39_Normal_1, _Normalize_3574419A_Out_1, _Property_FCAEBD15_Out_0, _Property_2D376CE_Out_0, _CrestFresnel_FD3200EB, _CrestFresnel_FD3200EB_LightTransmitted_1, _CrestFresnel_FD3200EB_LightReflected_2);
                float _Property_2599690E_Out_0 = Vector1_9BD9C342;
                float3 _Property_A57CAD6E_Out_0 = Vector3_8228B74C;
                float4 _Property_479D2E13_Out_0 = Vector4_2F6E352;
                float3 _Property_F631E4E0_Out_0 = Vector3_57B74D6A;
                float4 _Property_D9155CD7_Out_0 = Vector4_B3AD63B4;
                float _Property_D8B923AB_Out_0 = Vector1_FA688590;
                float _Property_F7F4791A_Out_0 = Vector1_9835666E;
                float _Property_2ABF6C61_Out_0 = Vector1_B331E24E;
                float _Property_22A5FA38_Out_0 = Vector1_951CF2DF;
                float4 _Property_C1E8071C_Out_0 = Vector4_ADCA8891;
                float _Property_9AD6466F_Out_0 = Vector1_2E8E2C59;
                float _Property_4D8B881_Out_0 = Vector1_D74C6609;
                float2 _Property_5A879B44_Out_0 = Vector2_AE8873FA;
                float _Property_41C453D9_Out_0 = Vector1_255AB964;
                float3 _CustomFunction_C3448D1A_AmbientLighting_0;
                GetAmbientLighting_float(_CustomFunction_C3448D1A_AmbientLighting_0);
                float3 _Property_13E6764D_Out_0 = Vector3_B2D6AD84;
                float3 _Property_2FA7DB0_Out_0 = Vector3_D2C93D25;
                Bindings_CrestVolumeLighting_e9ed6e11710a50640bb4b811d0fa84f2 _CrestVolumeLighting_5A1A391;
                half3 _CrestVolumeLighting_5A1A391_VolumeLighting_1;
                SG_CrestVolumeLighting_e9ed6e11710a50640bb4b811d0fa84f2(_Property_479D2E13_Out_0, _Property_F631E4E0_Out_0, _Property_D9155CD7_Out_0, _Property_D8B923AB_Out_0, _Property_F7F4791A_Out_0, _Property_2ABF6C61_Out_0, _Property_22A5FA38_Out_0, _Property_C1E8071C_Out_0, _Property_9AD6466F_Out_0, _Property_4D8B881_Out_0, _Property_5A879B44_Out_0, _Property_41C453D9_Out_0, _Normalize_3574419A_Out_1, IN.AbsoluteWorldSpacePosition, _CustomFunction_C3448D1A_AmbientLighting_0, _Property_13E6764D_Out_0, _Property_2FA7DB0_Out_0, _CrestVolumeLighting_5A1A391, _CrestVolumeLighting_5A1A391_VolumeLighting_1);
                float4 _ScreenPosition_42FE0E3E_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                float _Split_66230827_R_1 = IN.ViewSpacePosition[0];
                float _Split_66230827_G_2 = IN.ViewSpacePosition[1];
                float _Split_66230827_B_3 = IN.ViewSpacePosition[2];
                float _Split_66230827_A_4 = 0;
                float _Negate_5F3C7D3D_Out_1;
                Unity_Negate_float(_Split_66230827_B_3, _Negate_5F3C7D3D_Out_1);
                float3 _SceneColor_61626E7C_Out_1;
                Unity_SceneColor_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneColor_61626E7C_Out_1);
                float _SceneDepth_FD35F7D9_Out_1;
                Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_FD35F7D9_Out_1);
                float3 _Property_DC1C088D_Out_0 = Vector3_B2D6AD84;
                float _Property_8BC39E79_Out_0 = Vector1_9AE39B77;
                half _Property_683CAF2_Out_0 = Vector1_1B073674;
                float _Property_B4B35559_Out_0 = Vector1_C885385;
                float _Property_E694F888_Out_0 = Vector1_90CEE6B8;
                float _Property_50A87698_Out_0 = Vector1_E27586E2;
                float _Property_8BC9D755_Out_0 = Vector1_C96A6500;
                float _Property_6F95DFBF_Out_0 = Vector1_1AD36684;
                float3 _Property_4729CD24_Out_0 = Vector3_EEEBAAB5;
                float _Property_C36E9B6_Out_0 = Vector1_D3410E3;
                float _Property_2C173F60_Out_0 = Vector1_1EC1FE35;
                float2 _Property_4258AA49_Out_0 = Vector2_2F51BFFE;
                float _Property_3FC34BC9_Out_0 = Vector1_1CEB35D8;
                float _Property_D42BE95B_Out_0 = Vector1_B61034CA;
                float _Split_CEEBC462_R_1 = IN.AbsoluteWorldSpacePosition[0];
                float _Split_CEEBC462_G_2 = IN.AbsoluteWorldSpacePosition[1];
                float _Split_CEEBC462_B_3 = IN.AbsoluteWorldSpacePosition[2];
                float _Split_CEEBC462_A_4 = 0;
                float2 _Vector2_BB7CEEF5_Out_0 = float2(_Split_CEEBC462_R_1, _Split_CEEBC462_B_3);
                float2 _Property_305FB73_Out_0 = Vector2_9C73A0C6;
                float _Property_88A7570_Out_0 = Vector1_B01E1A6A;
                float2 _Property_5CBA815_Out_0 = Vector2_69CC43DC;
                Bindings_CrestFoamBubblesWithFlow_e132fba35874b4923988ef35a40e48c3 _CrestFoamBubblesWithFlow_F7286BE2;
                float3 _CrestFoamBubblesWithFlow_F7286BE2_Colour_1;
                SG_CrestFoamBubblesWithFlow_e132fba35874b4923988ef35a40e48c3(_Property_4729CD24_Out_0, _Property_C36E9B6_Out_0, _Property_2C173F60_Out_0, TEXTURE2D_ARGS(Texture2D_BE500045, samplerTexture2D_BE500045), Texture2D_BE500045_TexelSize, _Property_4258AA49_Out_0, _Property_3FC34BC9_Out_0, _Property_D42BE95B_Out_0, _CrestComputeNormal_6DAE4B39_Normal_1, _CrestDrivenData_6635D6E9_OceanParams0_5, _CrestDrivenData_6635D6E9_OceanParams1_6, _Vector2_BB7CEEF5_Out_0, _Property_305FB73_Out_0, _Property_88A7570_Out_0, _Normalize_3574419A_Out_1, _Property_5CBA815_Out_0, _CrestFoamBubblesWithFlow_F7286BE2, _CrestFoamBubblesWithFlow_F7286BE2_Colour_1);
                Bindings_CrestEmission_8c56460232fde1e46ae90d905a00f908 _CrestEmission_6580C0F9;
                float3 _CrestEmission_6580C0F9_EmittedLight_1;
                SG_CrestEmission_8c56460232fde1e46ae90d905a00f908(_Property_2599690E_Out_0, _Property_A57CAD6E_Out_0, _CrestVolumeLighting_5A1A391_VolumeLighting_1, _Normalize_3574419A_Out_1, _CrestComputeNormal_6DAE4B39_Normal_1, _ScreenPosition_42FE0E3E_Out_0, _Negate_5F3C7D3D_Out_1, _SceneColor_61626E7C_Out_1, _SceneDepth_FD35F7D9_Out_1, _Property_DC1C088D_Out_0, TEXTURE2D_ARGS(Texture2D_EB8C8549, samplerTexture2D_EB8C8549), Texture2D_EB8C8549_TexelSize, _Property_8BC39E79_Out_0, _Property_683CAF2_Out_0, _Property_B4B35559_Out_0, _Property_E694F888_Out_0, _Property_50A87698_Out_0, TEXTURE2D_ARGS(Texture2D_DA8A756A, samplerTexture2D_DA8A756A), Texture2D_DA8A756A_TexelSize, _Property_8BC9D755_Out_0, _Property_6F95DFBF_Out_0, _CrestFoamBubblesWithFlow_F7286BE2_Colour_1, _CrestEmission_6580C0F9, _CrestEmission_6580C0F9_EmittedLight_1);
                float3 _Multiply_CFF25F4B_Out_2;
                Unity_Multiply_float((_CrestFresnel_FD3200EB_LightTransmitted_1.xxx), _CrestEmission_6580C0F9_EmittedLight_1, _Multiply_CFF25F4B_Out_2);
                float _Property_5DA83C2A_Out_0 = Vector1_47308CC2;
                float _Property_44533AA4_Out_0 = Vector1_26549044;
                float _Property_19CC00AB_Out_0 = Vector1_177E111C;
                float _Divide_6B6C7F25_Out_2;
                Unity_Divide_float(_Negate_5F3C7D3D_Out_1, _Property_19CC00AB_Out_0, _Divide_6B6C7F25_Out_2);
                float _Saturate_D69CDED6_Out_1;
                Unity_Saturate_float(_Divide_6B6C7F25_Out_2, _Saturate_D69CDED6_Out_1);
                float _Property_8033277F_Out_0 = Vector1_33255829;
                float _Power_BC121A67_Out_2;
                Unity_Power_float(_Saturate_D69CDED6_Out_1, _Property_8033277F_Out_0, _Power_BC121A67_Out_2);
                float _Lerp_3E7590A8_Out_3;
                Unity_Lerp_float(_Property_5DA83C2A_Out_0, _Property_44533AA4_Out_0, _Power_BC121A67_Out_2, _Lerp_3E7590A8_Out_3);
                float2 _Property_374C5B7E_Out_0 = Vector2_69CC43DC;
                Bindings_CrestFoamWithFlow_3a6c22dceac0847a2a31cb05a577b963 _CrestFoamWithFlow_193F69CA;
                float3 _CrestFoamWithFlow_193F69CA_Albedo_1;
                float3 _CrestFoamWithFlow_193F69CA_NormalTS_2;
                float3 _CrestFoamWithFlow_193F69CA_Emission_3;
                float _CrestFoamWithFlow_193F69CA_Smoothness_4;
                SG_CrestFoamWithFlow_3a6c22dceac0847a2a31cb05a577b963(TEXTURE2D_ARGS(Texture2D_BE500045, samplerTexture2D_BE500045), Texture2D_BE500045_TexelSize, _Property_B9BA8901_Out_0, _Property_6AEC3552_Out_0, _Property_76EA797B_Out_0, _Property_83C2E998_Out_0, _Property_705FD8D9_Out_0, _Property_735B5A53_Out_0, _Property_EB4C03CF_Out_0, _CrestDrivenData_6635D6E9_OceanParams0_5, _CrestDrivenData_6635D6E9_OceanParams1_6, _Property_EE920C2C_Out_0, _Property_8BC6F5AD_Out_0, _Property_A2CEB215_Out_0, _CrestComputeNormal_6DAE4B39_Normal_1, _Multiply_CFF25F4B_Out_2, _Lerp_3E7590A8_Out_3, _Property_374C5B7E_Out_0, _CrestFoamWithFlow_193F69CA, _CrestFoamWithFlow_193F69CA_Albedo_1, _CrestFoamWithFlow_193F69CA_NormalTS_2, _CrestFoamWithFlow_193F69CA_Emission_3, _CrestFoamWithFlow_193F69CA_Smoothness_4);
                float _Subtract_5BDB5822_Out_2;
                Unity_Subtract_float(_SceneDepth_FD35F7D9_Out_1, _Negate_5F3C7D3D_Out_1, _Subtract_5BDB5822_Out_2);
                float _Remap_D52CFDA9_Out_3;
                Unity_Remap_float(_Subtract_5BDB5822_Out_2, float2 (0, 0.2), float2 (0, 1), _Remap_D52CFDA9_Out_3);
                float _Saturate_896FB384_Out_1;
                Unity_Saturate_float(_Remap_D52CFDA9_Out_3, _Saturate_896FB384_Out_1);
                Albedo_2 = _CrestFoamWithFlow_193F69CA_Albedo_1;
                NormalTS_3 = _CrestFoamWithFlow_193F69CA_NormalTS_2;
                Emission_4 = _CrestFoamWithFlow_193F69CA_Emission_3;
                Smoothness_5 = _CrestFoamWithFlow_193F69CA_Smoothness_4;
                Alpha_1 = _Saturate_896FB384_Out_1;
                Specular_6 = _CrestFresnel_FD3200EB_LightReflected_2;
            }
        
            // Graph Vertex
            struct VertexDescriptionInputs
            {
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 WorldSpaceNormal;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 WorldSpaceTangent;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 ObjectSpaceBiTangent;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 WorldSpaceBiTangent;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 AbsoluteWorldSpacePosition;
                #endif
            };
            
            struct VertexDescription
            {
                float3 VertexPosition;
                float3 VertexNormal;
                float3 VertexTangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                Bindings_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d _CrestDrivenData_A1078169;
                half _CrestDrivenData_A1078169_MeshScaleAlpha_1;
                half _CrestDrivenData_A1078169_LodDataTexelSize_8;
                half _CrestDrivenData_A1078169_GeometryGridSize_2;
                half3 _CrestDrivenData_A1078169_OceanPosScale0_3;
                half3 _CrestDrivenData_A1078169_OceanPosScale1_4;
                half4 _CrestDrivenData_A1078169_OceanParams0_5;
                half4 _CrestDrivenData_A1078169_OceanParams1_6;
                half _CrestDrivenData_A1078169_SliceIndex0_7;
                SG_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d(_CrestDrivenData_A1078169, _CrestDrivenData_A1078169_MeshScaleAlpha_1, _CrestDrivenData_A1078169_LodDataTexelSize_8, _CrestDrivenData_A1078169_GeometryGridSize_2, _CrestDrivenData_A1078169_OceanPosScale0_3, _CrestDrivenData_A1078169_OceanPosScale1_4, _CrestDrivenData_A1078169_OceanParams0_5, _CrestDrivenData_A1078169_OceanParams1_6, _CrestDrivenData_A1078169_SliceIndex0_7);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                Bindings_CrestGeoMorph_9ab91ec3462438049923ca0ff16f68ad _CrestGeoMorph_8F1A4FF1;
                half3 _CrestGeoMorph_8F1A4FF1_MorphedPositionWS_1;
                half _CrestGeoMorph_8F1A4FF1_LodAlpha_2;
                SG_CrestGeoMorph_9ab91ec3462438049923ca0ff16f68ad(IN.AbsoluteWorldSpacePosition, _CrestDrivenData_A1078169_OceanPosScale0_3, _CrestDrivenData_A1078169_MeshScaleAlpha_1, _CrestDrivenData_A1078169_GeometryGridSize_2, _CrestGeoMorph_8F1A4FF1, _CrestGeoMorph_8F1A4FF1_MorphedPositionWS_1, _CrestGeoMorph_8F1A4FF1_LodAlpha_2);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Split_CC063A43_R_1 = _CrestGeoMorph_8F1A4FF1_MorphedPositionWS_1[0];
                float _Split_CC063A43_G_2 = _CrestGeoMorph_8F1A4FF1_MorphedPositionWS_1[1];
                float _Split_CC063A43_B_3 = _CrestGeoMorph_8F1A4FF1_MorphedPositionWS_1[2];
                float _Split_CC063A43_A_4 = 0;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float2 _Vector2_2D46FD43_Out_0 = float2(_Split_CC063A43_R_1, _Split_CC063A43_B_3);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                Bindings_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4 _CrestSampleOceanData_340A6610;
                float3 _CrestSampleOceanData_340A6610_Displacement_1;
                float _CrestSampleOceanData_340A6610_OceanWaterDepth_5;
                float _CrestSampleOceanData_340A6610_Foam_6;
                float2 _CrestSampleOceanData_340A6610_Shadow_7;
                float2 _CrestSampleOceanData_340A6610_Flow_8;
                float _CrestSampleOceanData_340A6610_SubSurfaceScattering_9;
                SG_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4(_Vector2_2D46FD43_Out_0, _CrestGeoMorph_8F1A4FF1_LodAlpha_2, _CrestDrivenData_A1078169_OceanPosScale0_3, _CrestDrivenData_A1078169_OceanPosScale1_4, _CrestDrivenData_A1078169_OceanParams0_5, _CrestDrivenData_A1078169_OceanParams1_6, _CrestDrivenData_A1078169_SliceIndex0_7, _CrestSampleOceanData_340A6610, _CrestSampleOceanData_340A6610_Displacement_1, _CrestSampleOceanData_340A6610_OceanWaterDepth_5, _CrestSampleOceanData_340A6610_Foam_6, _CrestSampleOceanData_340A6610_Shadow_7, _CrestSampleOceanData_340A6610_Flow_8, _CrestSampleOceanData_340A6610_SubSurfaceScattering_9);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 _Add_2D79A354_Out_2;
                Unity_Add_float3(_CrestGeoMorph_8F1A4FF1_MorphedPositionWS_1, _CrestSampleOceanData_340A6610_Displacement_1, _Add_2D79A354_Out_2);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 _Transform_9C2ACF28_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Add_2D79A354_Out_2.xyz));
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 _Transform_86205EE4_Out_1 = TransformWorldToObjectDir(float3 (0, 1, 0).xyz);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 _Transform_22BD1A85_Out_1 = TransformWorldToObjectDir(GetCameraRelativePositionWS(float3 (1, 0, 0).xyz));
                #endif
                description.VertexPosition = _Transform_9C2ACF28_Out_1;
                description.VertexNormal = _Transform_86205EE4_Out_1;
                description.VertexTangent = _Transform_22BD1A85_Out_1;
                return description;
            }
            
            // Graph Pixel
            struct SurfaceDescriptionInputs
            {
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 WorldSpaceViewDirection;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 ViewSpacePosition;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 WorldSpacePosition;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 AbsoluteWorldSpacePosition;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 ScreenPosition;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv0;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv1;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv2;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv3;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float FaceSign;
                #endif
            };
            
            struct SurfaceDescription
            {
                float3 Albedo;
                float3 Emission;
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _TexelSize_CA3A0DD6_Width_0 = _TextureFoam_TexelSize.z;
                half _TexelSize_CA3A0DD6_Height_2 = _TextureFoam_TexelSize.w;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half2 _Vector2_15E252FB_Out_0 = half2(_TexelSize_CA3A0DD6_Width_0, _TexelSize_CA3A0DD6_Height_2);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_87E9391A_Out_0 = _FoamScale;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_BC30BCB6_Out_0 = _FoamFeather;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_5E8CB038_Out_0 = _FoamIntensityAlbedo;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_77A524C7_Out_0 = _FoamIntensityEmissive;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_CED296A4_Out_0 = _FoamSmoothness;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_D1CA3C84_Out_0 = _FoamNormalStrength;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half4 _Property_3BAB5FF_Out_0 = _FoamBubbleColor;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_EDC4DC3C_Out_0 = _FoamBubbleParallax;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_E7925FBA_Out_0 = _FoamBubblesCoverage;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                Bindings_CrestUnpackData_5bc4cf08f88035c489658d60edefeec8 _CrestUnpackData_C3998C1C;
                _CrestUnpackData_C3998C1C.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
                _CrestUnpackData_C3998C1C.uv0 = IN.uv0;
                _CrestUnpackData_C3998C1C.uv1 = IN.uv1;
                _CrestUnpackData_C3998C1C.uv2 = IN.uv2;
                float2 _CrestUnpackData_C3998C1C_PositionXZWSUndisp_2;
                float _CrestUnpackData_C3998C1C_LodAlpha_1;
                float _CrestUnpackData_C3998C1C_OceanDepth_3;
                float _CrestUnpackData_C3998C1C_Foam_4;
                float2 _CrestUnpackData_C3998C1C_Shadow_5;
                float2 _CrestUnpackData_C3998C1C_Flow_6;
                float _CrestUnpackData_C3998C1C_SubSurfaceScattering_7;
                SG_CrestUnpackData_5bc4cf08f88035c489658d60edefeec8(_CrestUnpackData_C3998C1C, _CrestUnpackData_C3998C1C_PositionXZWSUndisp_2, _CrestUnpackData_C3998C1C_LodAlpha_1, _CrestUnpackData_C3998C1C_OceanDepth_3, _CrestUnpackData_C3998C1C_Foam_4, _CrestUnpackData_C3998C1C_Shadow_5, _CrestUnpackData_C3998C1C_Flow_6, _CrestUnpackData_C3998C1C_SubSurfaceScattering_7);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_994CB3A3_Out_0 = _Smoothness;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_7079FD32_Out_0 = _SmoothnessFar;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_FAEF961B_Out_0 = _SmoothnessFarDistance;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_35DA1E70_Out_0 = _SmoothnessFalloff;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_D1430252_Out_0 = _NormalsScale;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_B882DB1E_Out_0 = _NormalsStrength;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half4 _Property_B5E474DF_Out_0 = _ScatterColourBase;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 _Property_B98AE6FA_Out_0 = _ScatterColourShallow;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_CF7CEF3A_Out_0 = _ScatterColourShallowDepthMax;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_698A3C81_Out_0 = _ScatterColourShallowDepthFalloff;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_5924F1E9_Out_0 = _SSSIntensityBase;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_67308B5F_Out_0 = _SSSIntensitySun;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half4 _Property_A723E757_Out_0 = _SSSTint;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_5AD6818A_Out_0 = _SSSSunFalloff;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_888FA49_Out_0 = _RefractionStrength;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half3 _Property_F1315B19_Out_0 = _DepthFogDensity;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                Bindings_CrestLightData_b74b6e8c0b489314ca7aea3e2cc9c54c _CrestLightData_5AD806DD;
                half3 _CrestLightData_5AD806DD_Direction_1;
                half3 _CrestLightData_5AD806DD_Intensity_2;
                SG_CrestLightData_b74b6e8c0b489314ca7aea3e2cc9c54c(_CrestLightData_5AD806DD, _CrestLightData_5AD806DD_Direction_1, _CrestLightData_5AD806DD_Intensity_2);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_A26763AB_Out_0 = _CausticsTextureScale;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_3230CB90_Out_0 = _CausticsTextureAverage;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_6B2F7D3E_Out_0 = _CausticsStrength;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_D5C90779_Out_0 = _CausticsFocalDepth;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_2743B36F_Out_0 = _CausticsDepthOfField;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_61877218_Out_0 = _CausticsDistortionStrength;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_5F1E3794_Out_0 = _CausticsDistortionScale;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                Bindings_CrestOceanPixel_6f6706d805d8e8649adddaaa94260269 _CrestOceanPixel_51593A7C;
                _CrestOceanPixel_51593A7C.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
                _CrestOceanPixel_51593A7C.ViewSpacePosition = IN.ViewSpacePosition;
                _CrestOceanPixel_51593A7C.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
                _CrestOceanPixel_51593A7C.ScreenPosition = IN.ScreenPosition;
                _CrestOceanPixel_51593A7C.FaceSign = IN.FaceSign;
                float3 _CrestOceanPixel_51593A7C_Albedo_2;
                float3 _CrestOceanPixel_51593A7C_NormalTS_3;
                float3 _CrestOceanPixel_51593A7C_Emission_4;
                float _CrestOceanPixel_51593A7C_Smoothness_5;
                float _CrestOceanPixel_51593A7C_Alpha_1;
                float _CrestOceanPixel_51593A7C_Specular_6;
                SG_CrestOceanPixel_6f6706d805d8e8649adddaaa94260269(TEXTURE2D_ARGS(_TextureFoam, sampler_TextureFoam), _TextureFoam_TexelSize, _Vector2_15E252FB_Out_0, _Property_87E9391A_Out_0, _Property_BC30BCB6_Out_0, _Property_5E8CB038_Out_0, _Property_77A524C7_Out_0, _Property_CED296A4_Out_0, _Property_D1CA3C84_Out_0, (_Property_3BAB5FF_Out_0.xyz), _Property_EDC4DC3C_Out_0, _Property_E7925FBA_Out_0, _CrestUnpackData_C3998C1C_PositionXZWSUndisp_2, _CrestUnpackData_C3998C1C_LodAlpha_1, _CrestUnpackData_C3998C1C_OceanDepth_3, _CrestUnpackData_C3998C1C_Foam_4, _CrestUnpackData_C3998C1C_Shadow_5, _CrestUnpackData_C3998C1C_Flow_6, _CrestUnpackData_C3998C1C_SubSurfaceScattering_7, _Property_994CB3A3_Out_0, _Property_7079FD32_Out_0, _Property_FAEF961B_Out_0, _Property_35DA1E70_Out_0, TEXTURE2D_ARGS(_TextureNormals, sampler_TextureNormals), _TextureNormals_TexelSize, _Property_D1430252_Out_0, _Property_B882DB1E_Out_0, _Property_B5E474DF_Out_0, float3 (0, 0, 0), _Property_B98AE6FA_Out_0, _Property_CF7CEF3A_Out_0, _Property_698A3C81_Out_0, _Property_5924F1E9_Out_0, _Property_67308B5F_Out_0, _Property_A723E757_Out_0, _Property_5AD6818A_Out_0, _Property_888FA49_Out_0, _Property_F1315B19_Out_0, _CrestLightData_5AD806DD_Direction_1, _CrestLightData_5AD806DD_Intensity_2, TEXTURE2D_ARGS(_CausticsTexture, sampler_CausticsTexture), _CausticsTexture_TexelSize, _Property_A26763AB_Out_0, _Property_3230CB90_Out_0, _Property_6B2F7D3E_Out_0, _Property_D5C90779_Out_0, _Property_2743B36F_Out_0, TEXTURE2D_ARGS(_CausticsDistortionTexture, sampler_CausticsDistortionTexture), _CausticsDistortionTexture_TexelSize, _Property_61877218_Out_0, _Property_5F1E3794_Out_0, 1.33, 1, _CrestOceanPixel_51593A7C, _CrestOceanPixel_51593A7C_Albedo_2, _CrestOceanPixel_51593A7C_NormalTS_3, _CrestOceanPixel_51593A7C_Emission_4, _CrestOceanPixel_51593A7C_Smoothness_5, _CrestOceanPixel_51593A7C_Alpha_1, _CrestOceanPixel_51593A7C_Specular_6);
                #endif
                surface.Albedo = _CrestOceanPixel_51593A7C_Albedo_2;
                surface.Emission = _CrestOceanPixel_51593A7C_Emission_4;
                surface.Alpha = _CrestOceanPixel_51593A7C_Alpha_1;
                surface.AlphaClipThreshold = 0;
                return surface;
            }
        
            // --------------------------------------------------
            // Structs and Packing
        
            // Generated Type: Attributes
            struct Attributes
            {
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 positionOS : POSITION;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 normalOS : NORMAL;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 tangentOS : TANGENT;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv0 : TEXCOORD0;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv1 : TEXCOORD1;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv2 : TEXCOORD2;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv3 : TEXCOORD3;
                #endif
                #if UNITY_ANY_INSTANCING_ENABLED
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                uint instanceID : INSTANCEID_SEMANTIC;
                #endif
                #endif
            };
        
            // Generated Type: Varyings
            struct Varyings
            {
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 positionCS : SV_Position;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 positionWS;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 texCoord0;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 texCoord1;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 texCoord2;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 texCoord3;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 viewDirectionWS;
                #endif
                #if UNITY_ANY_INSTANCING_ENABLED
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #endif
            };
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            // Generated Type: PackedVaryings
            struct PackedVaryings
            {
                float4 positionCS : SV_Position;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                float3 interp00 : TEXCOORD0;
                float4 interp01 : TEXCOORD1;
                float4 interp02 : TEXCOORD2;
                float4 interp03 : TEXCOORD3;
                float4 interp04 : TEXCOORD4;
                float3 interp05 : TEXCOORD5;
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Packed Type: Varyings
            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output;
                output.positionCS = input.positionCS;
                output.interp00.xyz = input.positionWS;
                output.interp01.xyzw = input.texCoord0;
                output.interp02.xyzw = input.texCoord1;
                output.interp03.xyzw = input.texCoord2;
                output.interp04.xyzw = input.texCoord3;
                output.interp05.xyz = input.viewDirectionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                return output;
            }
            
            // Unpacked Type: Varyings
            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.positionWS = input.interp00.xyz;
                output.texCoord0 = input.interp01.xyzw;
                output.texCoord1 = input.interp02.xyzw;
                output.texCoord2 = input.interp03.xyzw;
                output.texCoord3 = input.interp04.xyzw;
                output.viewDirectionWS = input.interp05.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                return output;
            }
            #endif
        
            // --------------------------------------------------
            // Build Graph Inputs
        
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            #endif
            
            
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
            #endif
            
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS.xyz, input.tangentOS.xyz) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
            #endif
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
            #endif
            
            
            
            
            
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
            #endif
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
                return output;
            }
            
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            
            
            
            
            
            
            
            
            
            
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            #endif
            
            
            
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.WorldSpacePosition =          input.positionWS;
            #endif
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.ViewSpacePosition =           TransformWorldToView(input.positionWS);
            #endif
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(input.positionWS);
            #endif
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            #endif
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.uv0 =                         input.texCoord0;
            #endif
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.uv1 =                         input.texCoord1;
            #endif
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.uv2 =                         input.texCoord2;
            #endif
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.uv3 =                         input.texCoord3;
            #endif
            
            
            
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                return output;
            }
            
        
            // --------------------------------------------------
            // Main
        
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
            ENDHLSL
        }

		/*
        Pass
        {
            // Name: <None>
            Tags 
            { 
                "LightMode" = "Universal2D"
            }
           
            // Render State
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            Cull Off
            ZTest LEqual
            ZWrite Off
            // ColorMask: <None>
        
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
        
            // Debug
            // <None>
        
            // --------------------------------------------------
            // Pass
        
            // Pragmas
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            #pragma multi_compile_instancing
        
            // Keywords
            // PassKeywords: <None>
            #pragma shader_feature_local _ CREST_FOAM_ON
            #pragma shader_feature_local _ CREST_CAUSTICS_ON
            #pragma shader_feature_local _ CREST_FLOW_ON
            
            #if defined(CREST_FOAM_ON) && defined(CREST_CAUSTICS_ON) && defined(CREST_FLOW_ON)
                #define KEYWORD_PERMUTATION_0
            #elif defined(CREST_FOAM_ON) && defined(CREST_CAUSTICS_ON)
                #define KEYWORD_PERMUTATION_1
            #elif defined(CREST_FOAM_ON) && defined(CREST_FLOW_ON)
                #define KEYWORD_PERMUTATION_2
            #elif defined(CREST_FOAM_ON)
                #define KEYWORD_PERMUTATION_3
            #elif defined(CREST_CAUSTICS_ON) && defined(CREST_FLOW_ON)
                #define KEYWORD_PERMUTATION_4
            #elif defined(CREST_CAUSTICS_ON)
                #define KEYWORD_PERMUTATION_5
            #elif defined(CREST_FLOW_ON)
                #define KEYWORD_PERMUTATION_6
            #else
                #define KEYWORD_PERMUTATION_7
            #endif
            
            
            // Defines
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define _SURFACE_TYPE_TRANSPARENT 1
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define _NORMALMAP 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define _SPECULAR_SETUP
        #endif
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD2
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define ATTRIBUTES_NEED_TEXCOORD3
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_POSITION_WS 
        #endif
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD2
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_TEXCOORD3
        #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #endif
        
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
        #define VARYINGS_NEED_CULLFACE
        #endif
        
            #define FEATURES_GRAPH_VERTEX
            #define SHADERPASS_2D
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #define REQUIRE_DEPTH_TEXTURE
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            #define REQUIRE_OPAQUE_TEXTURE
            #endif
        
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
            // --------------------------------------------------
            // Graph
        
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            half _Smoothness;
            float _SmoothnessFar;
            float _SmoothnessFarDistance;
            float _SmoothnessFalloff;
            float _Specular;
            float _Occlusion;
            half4 _ScatterColourBase;
            float4 _ScatterColourShallow;
            half _ScatterColourShallowDepthMax;
            half _ScatterColourShallowDepthFalloff;
            half _NormalsScale;
            half _NormalsStrength;
            half _SSSIntensityBase;
            half _SSSIntensitySun;
            half4 _SSSTint;
            half _SSSSunFalloff;
            half _RefractionStrength;
            half3 _DepthFogDensity;
            half _FoamScale;
            half _FoamFeather;
            half _FoamIntensityAlbedo;
            half _FoamIntensityEmissive;
            half _FoamSmoothness;
            half _FoamNormalStrength;
            half4 _FoamBubbleColor;
            half _FoamBubbleParallax;
            half _FoamBubblesCoverage;
            float _CausticsTextureScale;
            float _CausticsTextureAverage;
            float _CausticsStrength;
            float _CausticsFocalDepth;
            float _CausticsDepthOfField;
            float _CausticsDistortionStrength;
            float _CausticsDistortionScale;
            CBUFFER_END
            TEXTURE2D(_TextureNormals); SAMPLER(sampler_TextureNormals); float4 _TextureNormals_TexelSize;
            TEXTURE2D(_TextureFoam); SAMPLER(sampler_TextureFoam); half4 _TextureFoam_TexelSize;
            TEXTURE2D(_CausticsTexture); SAMPLER(sampler_CausticsTexture); float4 _CausticsTexture_TexelSize;
            TEXTURE2D(_CausticsDistortionTexture); SAMPLER(sampler_CausticsDistortionTexture); float4 _CausticsDistortionTexture_TexelSize;
            SAMPLER(SamplerState_Linear_Repeat);
        
            // Graph Functions
            
            // dc55dc563cc13ab0a4a38f335aac9cb2
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeDrivenInputs.hlsl"
            
            struct Bindings_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d
            {
            };
            
            void SG_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d(Bindings_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d IN, out half MeshScaleAlpha_1, out half LodDataTexelSize_8, out half GeometryGridSize_2, out half3 OceanPosScale0_3, out half3 OceanPosScale1_4, out half4 OceanParams0_5, out half4 OceanParams1_6, out half SliceIndex0_7)
            {
                half _CustomFunction_CD9A5F8F_MeshScaleAlpha_9;
                half _CustomFunction_CD9A5F8F_LodDataTexelSize_10;
                half _CustomFunction_CD9A5F8F_GeometryGridSize_14;
                half3 _CustomFunction_CD9A5F8F_OceanPosScale0_7;
                half3 _CustomFunction_CD9A5F8F_OceanPosScale1_8;
                half4 _CustomFunction_CD9A5F8F_OceanParams0_11;
                half4 _CustomFunction_CD9A5F8F_OceanParams1_12;
                half _CustomFunction_CD9A5F8F_SliceIndex0_13;
                CrestOceanSurfaceValues_half(_CustomFunction_CD9A5F8F_MeshScaleAlpha_9, _CustomFunction_CD9A5F8F_LodDataTexelSize_10, _CustomFunction_CD9A5F8F_GeometryGridSize_14, _CustomFunction_CD9A5F8F_OceanPosScale0_7, _CustomFunction_CD9A5F8F_OceanPosScale1_8, _CustomFunction_CD9A5F8F_OceanParams0_11, _CustomFunction_CD9A5F8F_OceanParams1_12, _CustomFunction_CD9A5F8F_SliceIndex0_13);
                MeshScaleAlpha_1 = _CustomFunction_CD9A5F8F_MeshScaleAlpha_9;
                LodDataTexelSize_8 = _CustomFunction_CD9A5F8F_LodDataTexelSize_10;
                GeometryGridSize_2 = _CustomFunction_CD9A5F8F_GeometryGridSize_14;
                OceanPosScale0_3 = _CustomFunction_CD9A5F8F_OceanPosScale0_7;
                OceanPosScale1_4 = _CustomFunction_CD9A5F8F_OceanPosScale1_8;
                OceanParams0_5 = _CustomFunction_CD9A5F8F_OceanParams0_11;
                OceanParams1_6 = _CustomFunction_CD9A5F8F_OceanParams1_12;
                SliceIndex0_7 = _CustomFunction_CD9A5F8F_SliceIndex0_13;
            }
            
            // 0749fb83929f8caedf1bd96120cd0442
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeGeoMorph.hlsl"
            
            struct Bindings_CrestGeoMorph_9ab91ec3462438049923ca0ff16f68ad
            {
            };
            
            void SG_CrestGeoMorph_9ab91ec3462438049923ca0ff16f68ad(float3 Vector3_28A0F264, float3 Vector3_F1111B56, float Vector1_691AFD6A, float Vector1_37DEE8F3, Bindings_CrestGeoMorph_9ab91ec3462438049923ca0ff16f68ad IN, out half3 MorphedPositionWS_1, out half LodAlpha_2)
            {
                float3 _Property_C4B6B1D5_Out_0 = Vector3_28A0F264;
                float3 _Property_13BC6D1A_Out_0 = Vector3_F1111B56;
                float _Property_DE4BC103_Out_0 = Vector1_691AFD6A;
                float _Property_B3D2A4DF_Out_0 = Vector1_37DEE8F3;
                half3 _CustomFunction_C8F1D6C4_MorphedPositionWS_4;
                half _CustomFunction_C8F1D6C4_LodAlpha_5;
                GeoMorph_half(_Property_C4B6B1D5_Out_0, _Property_13BC6D1A_Out_0, _Property_DE4BC103_Out_0, _Property_B3D2A4DF_Out_0, _CustomFunction_C8F1D6C4_MorphedPositionWS_4, _CustomFunction_C8F1D6C4_LodAlpha_5);
                MorphedPositionWS_1 = _CustomFunction_C8F1D6C4_MorphedPositionWS_4;
                LodAlpha_2 = _CustomFunction_C8F1D6C4_LodAlpha_5;
            }
            
            // 280776a3899d7788e7b68f32405fa944
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeSampleOceanData.hlsl"
            
            struct Bindings_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4
            {
            };
            
            void SG_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4(float2 Vector2_3171933F, float Vector1_CD41515B, float3 Vector3_7E91D336, float3 Vector3_3A95DCDF, float4 Vector4_C0B2B5EA, float4 Vector4_9C46108E, float Vector1_8EA8B92B, Bindings_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4 IN, out float3 Displacement_1, out float OceanWaterDepth_5, out float Foam_6, out float2 Shadow_7, out float2 Flow_8, out float SubSurfaceScattering_9)
            {
                float2 _Property_1A287CC6_Out_0 = Vector2_3171933F;
                float _Property_2D1D1700_Out_0 = Vector1_CD41515B;
                float3 _Property_C925A867_Out_0 = Vector3_7E91D336;
                float3 _Property_6C273401_Out_0 = Vector3_3A95DCDF;
                float4 _Property_467D1BE7_Out_0 = Vector4_C0B2B5EA;
                float4 _Property_4E045F45_Out_0 = Vector4_9C46108E;
                float _Property_59E019ED_Out_0 = Vector1_8EA8B92B;
                float3 _CustomFunction_487C31E1_Displacement_3;
                float _CustomFunction_487C31E1_OceanDepth_8;
                float _CustomFunction_487C31E1_Foam_4;
                float2 _CustomFunction_487C31E1_Shadow_5;
                float2 _CustomFunction_487C31E1_Flow_6;
                float _CustomFunction_487C31E1_SSS_17;
                CrestNodeSampleOceanData_float(_Property_1A287CC6_Out_0, _Property_2D1D1700_Out_0, _Property_C925A867_Out_0, _Property_6C273401_Out_0, _Property_467D1BE7_Out_0, _Property_4E045F45_Out_0, _Property_59E019ED_Out_0, _CustomFunction_487C31E1_Displacement_3, _CustomFunction_487C31E1_OceanDepth_8, _CustomFunction_487C31E1_Foam_4, _CustomFunction_487C31E1_Shadow_5, _CustomFunction_487C31E1_Flow_6, _CustomFunction_487C31E1_SSS_17);
                Displacement_1 = _CustomFunction_487C31E1_Displacement_3;
                OceanWaterDepth_5 = _CustomFunction_487C31E1_OceanDepth_8;
                Foam_6 = _CustomFunction_487C31E1_Foam_4;
                Shadow_7 = _CustomFunction_487C31E1_Shadow_5;
                Flow_8 = _CustomFunction_487C31E1_Flow_6;
                SubSurfaceScattering_9 = _CustomFunction_487C31E1_SSS_17;
            }
            
            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
            {
                Out = A + B;
            }
            
            // 25927ab6b885bcd0b86a13376933b174
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeComputeSamplingData.hlsl"
            
            void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
            {
                Out = A - B;
            }
            
            struct Bindings_CrestComputeOceanDataFromDisplacedPosition_1f483fe321b10c64e8b93a023ae60dd6
            {
            };
            
            void SG_CrestComputeOceanDataFromDisplacedPosition_1f483fe321b10c64e8b93a023ae60dd6(float3 Vector3_A7B8495A, Bindings_CrestComputeOceanDataFromDisplacedPosition_1f483fe321b10c64e8b93a023ae60dd6 IN, out float2 UndisplacedPosXZAWS_7, out float LodAlpha_6, out float3 Displacement_8, out float OceanWaterDepth_1, out float Foam_2, out float2 Shadow_3, out float2 Flow_4, out float SubSurfaceScattering_5)
            {
                float3 _Property_232E7FDA_Out_0 = Vector3_A7B8495A;
                float _Split_8E8A6DCA_R_1 = _Property_232E7FDA_Out_0[0];
                float _Split_8E8A6DCA_G_2 = _Property_232E7FDA_Out_0[1];
                float _Split_8E8A6DCA_B_3 = _Property_232E7FDA_Out_0[2];
                float _Split_8E8A6DCA_A_4 = 0;
                float2 _Vector2_A3499051_Out_0 = float2(_Split_8E8A6DCA_R_1, _Split_8E8A6DCA_B_3);
                half _CustomFunction_A082C8F2_LodAlpha_3;
                half3 _CustomFunction_A082C8F2_OceanPosScale0_4;
                half3 _CustomFunction_A082C8F2_OceanPosScale1_5;
                half4 _CustomFunction_A082C8F2_OceanParams0_6;
                half4 _CustomFunction_A082C8F2_OceanParams1_7;
                half _CustomFunction_A082C8F2_Slice0_1;
                half _CustomFunction_A082C8F2_Slice1_2;
                CrestComputeSamplingData_half(_Vector2_A3499051_Out_0, _CustomFunction_A082C8F2_LodAlpha_3, _CustomFunction_A082C8F2_OceanPosScale0_4, _CustomFunction_A082C8F2_OceanPosScale1_5, _CustomFunction_A082C8F2_OceanParams0_6, _CustomFunction_A082C8F2_OceanParams1_7, _CustomFunction_A082C8F2_Slice0_1, _CustomFunction_A082C8F2_Slice1_2);
                Bindings_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4 _CrestSampleOceanData_87ACC65F;
                float3 _CrestSampleOceanData_87ACC65F_Displacement_1;
                float _CrestSampleOceanData_87ACC65F_OceanWaterDepth_5;
                float _CrestSampleOceanData_87ACC65F_Foam_6;
                float2 _CrestSampleOceanData_87ACC65F_Shadow_7;
                float2 _CrestSampleOceanData_87ACC65F_Flow_8;
                float _CrestSampleOceanData_87ACC65F_SubSurfaceScattering_9;
                SG_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4(_Vector2_A3499051_Out_0, _CustomFunction_A082C8F2_LodAlpha_3, _CustomFunction_A082C8F2_OceanPosScale0_4, _CustomFunction_A082C8F2_OceanPosScale1_5, _CustomFunction_A082C8F2_OceanParams0_6, _CustomFunction_A082C8F2_OceanParams1_7, _CustomFunction_A082C8F2_Slice0_1, _CrestSampleOceanData_87ACC65F, _CrestSampleOceanData_87ACC65F_Displacement_1, _CrestSampleOceanData_87ACC65F_OceanWaterDepth_5, _CrestSampleOceanData_87ACC65F_Foam_6, _CrestSampleOceanData_87ACC65F_Shadow_7, _CrestSampleOceanData_87ACC65F_Flow_8, _CrestSampleOceanData_87ACC65F_SubSurfaceScattering_9);
                float _Split_CD3A9051_R_1 = _CrestSampleOceanData_87ACC65F_Displacement_1[0];
                float _Split_CD3A9051_G_2 = _CrestSampleOceanData_87ACC65F_Displacement_1[1];
                float _Split_CD3A9051_B_3 = _CrestSampleOceanData_87ACC65F_Displacement_1[2];
                float _Split_CD3A9051_A_4 = 0;
                float2 _Vector2_B8C0C1F0_Out_0 = float2(_Split_CD3A9051_R_1, _Split_CD3A9051_B_3);
                float2 _Subtract_8977A663_Out_2;
                Unity_Subtract_float2(_Vector2_A3499051_Out_0, _Vector2_B8C0C1F0_Out_0, _Subtract_8977A663_Out_2);
                half _CustomFunction_9D8B14F0_LodAlpha_3;
                half3 _CustomFunction_9D8B14F0_OceanPosScale0_4;
                half3 _CustomFunction_9D8B14F0_OceanPosScale1_5;
                half4 _CustomFunction_9D8B14F0_OceanParams0_6;
                half4 _CustomFunction_9D8B14F0_OceanParams1_7;
                half _CustomFunction_9D8B14F0_Slice0_1;
                half _CustomFunction_9D8B14F0_Slice1_2;
                CrestComputeSamplingData_half(_Subtract_8977A663_Out_2, _CustomFunction_9D8B14F0_LodAlpha_3, _CustomFunction_9D8B14F0_OceanPosScale0_4, _CustomFunction_9D8B14F0_OceanPosScale1_5, _CustomFunction_9D8B14F0_OceanParams0_6, _CustomFunction_9D8B14F0_OceanParams1_7, _CustomFunction_9D8B14F0_Slice0_1, _CustomFunction_9D8B14F0_Slice1_2);
                Bindings_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4 _CrestSampleOceanData_D8619779;
                float3 _CrestSampleOceanData_D8619779_Displacement_1;
                float _CrestSampleOceanData_D8619779_OceanWaterDepth_5;
                float _CrestSampleOceanData_D8619779_Foam_6;
                float2 _CrestSampleOceanData_D8619779_Shadow_7;
                float2 _CrestSampleOceanData_D8619779_Flow_8;
                float _CrestSampleOceanData_D8619779_SubSurfaceScattering_9;
                SG_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4(_Subtract_8977A663_Out_2, _CustomFunction_9D8B14F0_LodAlpha_3, _CustomFunction_9D8B14F0_OceanPosScale0_4, _CustomFunction_9D8B14F0_OceanPosScale1_5, _CustomFunction_9D8B14F0_OceanParams0_6, _CustomFunction_9D8B14F0_OceanParams1_7, _CustomFunction_9D8B14F0_Slice0_1, _CrestSampleOceanData_D8619779, _CrestSampleOceanData_D8619779_Displacement_1, _CrestSampleOceanData_D8619779_OceanWaterDepth_5, _CrestSampleOceanData_D8619779_Foam_6, _CrestSampleOceanData_D8619779_Shadow_7, _CrestSampleOceanData_D8619779_Flow_8, _CrestSampleOceanData_D8619779_SubSurfaceScattering_9);
                float _Split_1616DE7_R_1 = _CrestSampleOceanData_D8619779_Displacement_1[0];
                float _Split_1616DE7_G_2 = _CrestSampleOceanData_D8619779_Displacement_1[1];
                float _Split_1616DE7_B_3 = _CrestSampleOceanData_D8619779_Displacement_1[2];
                float _Split_1616DE7_A_4 = 0;
                float2 _Vector2_B871614F_Out_0 = float2(_Split_1616DE7_R_1, _Split_1616DE7_B_3);
                float2 _Subtract_39E2CE30_Out_2;
                Unity_Subtract_float2(_Vector2_A3499051_Out_0, _Vector2_B871614F_Out_0, _Subtract_39E2CE30_Out_2);
                half _CustomFunction_10AEAD9A_LodAlpha_3;
                half3 _CustomFunction_10AEAD9A_OceanPosScale0_4;
                half3 _CustomFunction_10AEAD9A_OceanPosScale1_5;
                half4 _CustomFunction_10AEAD9A_OceanParams0_6;
                half4 _CustomFunction_10AEAD9A_OceanParams1_7;
                half _CustomFunction_10AEAD9A_Slice0_1;
                half _CustomFunction_10AEAD9A_Slice1_2;
                CrestComputeSamplingData_half(_Subtract_39E2CE30_Out_2, _CustomFunction_10AEAD9A_LodAlpha_3, _CustomFunction_10AEAD9A_OceanPosScale0_4, _CustomFunction_10AEAD9A_OceanPosScale1_5, _CustomFunction_10AEAD9A_OceanParams0_6, _CustomFunction_10AEAD9A_OceanParams1_7, _CustomFunction_10AEAD9A_Slice0_1, _CustomFunction_10AEAD9A_Slice1_2);
                Bindings_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4 _CrestSampleOceanData_A1195FE2;
                float3 _CrestSampleOceanData_A1195FE2_Displacement_1;
                float _CrestSampleOceanData_A1195FE2_OceanWaterDepth_5;
                float _CrestSampleOceanData_A1195FE2_Foam_6;
                float2 _CrestSampleOceanData_A1195FE2_Shadow_7;
                float2 _CrestSampleOceanData_A1195FE2_Flow_8;
                float _CrestSampleOceanData_A1195FE2_SubSurfaceScattering_9;
                SG_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4(_Subtract_39E2CE30_Out_2, _CustomFunction_10AEAD9A_LodAlpha_3, _CustomFunction_10AEAD9A_OceanPosScale0_4, _CustomFunction_10AEAD9A_OceanPosScale1_5, _CustomFunction_10AEAD9A_OceanParams0_6, _CustomFunction_10AEAD9A_OceanParams1_7, _CustomFunction_10AEAD9A_Slice0_1, _CrestSampleOceanData_A1195FE2, _CrestSampleOceanData_A1195FE2_Displacement_1, _CrestSampleOceanData_A1195FE2_OceanWaterDepth_5, _CrestSampleOceanData_A1195FE2_Foam_6, _CrestSampleOceanData_A1195FE2_Shadow_7, _CrestSampleOceanData_A1195FE2_Flow_8, _CrestSampleOceanData_A1195FE2_SubSurfaceScattering_9);
                UndisplacedPosXZAWS_7 = _Subtract_39E2CE30_Out_2;
                LodAlpha_6 = _CustomFunction_10AEAD9A_LodAlpha_3;
                Displacement_8 = _CrestSampleOceanData_A1195FE2_Displacement_1;
                OceanWaterDepth_1 = _CrestSampleOceanData_A1195FE2_OceanWaterDepth_5;
                Foam_2 = _CrestSampleOceanData_A1195FE2_Foam_6;
                Shadow_3 = _CrestSampleOceanData_A1195FE2_Shadow_7;
                Flow_4 = _CrestSampleOceanData_A1195FE2_Flow_8;
                SubSurfaceScattering_5 = _CrestSampleOceanData_A1195FE2_SubSurfaceScattering_9;
            }
            
            struct Bindings_CrestUnpackData_5bc4cf08f88035c489658d60edefeec8
            {
                float3 AbsoluteWorldSpacePosition;
                half4 uv0;
                half4 uv1;
                half4 uv2;
            };
            
            void SG_CrestUnpackData_5bc4cf08f88035c489658d60edefeec8(Bindings_CrestUnpackData_5bc4cf08f88035c489658d60edefeec8 IN, out float2 PositionXZWSUndisp_2, out float LodAlpha_1, out float OceanDepth_3, out float Foam_4, out float2 Shadow_5, out float2 Flow_6, out float SubSurfaceScattering_7)
            {
                float4 _UV_CF6CD5F2_Out_0 = IN.uv0;
                float _Split_B10345C8_R_1 = _UV_CF6CD5F2_Out_0[0];
                float _Split_B10345C8_G_2 = _UV_CF6CD5F2_Out_0[1];
                float _Split_B10345C8_B_3 = _UV_CF6CD5F2_Out_0[2];
                float _Split_B10345C8_A_4 = _UV_CF6CD5F2_Out_0[3];
                float2 _Vector2_552A5E1F_Out_0 = float2(_Split_B10345C8_R_1, _Split_B10345C8_G_2);
                Bindings_CrestComputeOceanDataFromDisplacedPosition_1f483fe321b10c64e8b93a023ae60dd6 _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB;
                float2 _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_UndisplacedPosXZAWS_7;
                float _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_LodAlpha_6;
                float3 _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Displacement_8;
                float _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_OceanWaterDepth_1;
                float _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Foam_2;
                float2 _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Shadow_3;
                float2 _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Flow_4;
                float _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_SubSurfaceScattering_5;
                SG_CrestComputeOceanDataFromDisplacedPosition_1f483fe321b10c64e8b93a023ae60dd6(IN.AbsoluteWorldSpacePosition, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_UndisplacedPosXZAWS_7, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_LodAlpha_6, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Displacement_8, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_OceanWaterDepth_1, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Foam_2, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Shadow_3, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Flow_4, _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_SubSurfaceScattering_5);
                #if defined(CREST_GENERATED_SHADER_ON)
                float2 _GENERATEDSHADER_71C0694B_Out_0 = _Vector2_552A5E1F_Out_0;
                #else
                float2 _GENERATEDSHADER_71C0694B_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_UndisplacedPosXZAWS_7;
                #endif
                #if defined(CREST_GENERATED_SHADER_ON)
                float _GENERATEDSHADER_2A933A74_Out_0 = _Split_B10345C8_B_3;
                #else
                float _GENERATEDSHADER_2A933A74_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_LodAlpha_6;
                #endif
                #if defined(CREST_GENERATED_SHADER_ON)
                float _GENERATEDSHADER_EFBF6036_Out_0 = _Split_B10345C8_A_4;
                #else
                float _GENERATEDSHADER_EFBF6036_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_OceanWaterDepth_1;
                #endif
                float4 _UV_39E1D2DF_Out_0 = IN.uv1;
                float _Split_CB2CA9B8_R_1 = _UV_39E1D2DF_Out_0[0];
                float _Split_CB2CA9B8_G_2 = _UV_39E1D2DF_Out_0[1];
                float _Split_CB2CA9B8_B_3 = _UV_39E1D2DF_Out_0[2];
                float _Split_CB2CA9B8_A_4 = _UV_39E1D2DF_Out_0[3];
                #if defined(CREST_GENERATED_SHADER_ON)
                float _GENERATEDSHADER_1BBAE801_Out_0 = _Split_CB2CA9B8_G_2;
                #else
                float _GENERATEDSHADER_1BBAE801_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Foam_2;
                #endif
                float4 _UV_33A67BF5_Out_0 = IN.uv2;
                float _Split_753DFB28_R_1 = _UV_33A67BF5_Out_0[0];
                float _Split_753DFB28_G_2 = _UV_33A67BF5_Out_0[1];
                float _Split_753DFB28_B_3 = _UV_33A67BF5_Out_0[2];
                float _Split_753DFB28_A_4 = _UV_33A67BF5_Out_0[3];
                float2 _Vector2_7883B8A6_Out_0 = float2(_Split_753DFB28_R_1, _Split_753DFB28_G_2);
                #if defined(CREST_GENERATED_SHADER_ON)
                float2 _GENERATEDSHADER_B499BDE6_Out_0 = _Vector2_7883B8A6_Out_0;
                #else
                float2 _GENERATEDSHADER_B499BDE6_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Shadow_3;
                #endif
                float2 _Vector2_3A83E1FC_Out_0 = float2(_Split_753DFB28_B_3, _Split_753DFB28_A_4);
                #if defined(CREST_GENERATED_SHADER_ON)
                float2 _GENERATEDSHADER_84CB20AD_Out_0 = _Vector2_3A83E1FC_Out_0;
                #else
                float2 _GENERATEDSHADER_84CB20AD_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_Flow_4;
                #endif
                #if defined(CREST_GENERATED_SHADER_ON)
                float _GENERATEDSHADER_6BDC98D1_Out_0 = _Split_CB2CA9B8_R_1;
                #else
                float _GENERATEDSHADER_6BDC98D1_Out_0 = _CrestComputeOceanDataFromDisplacedPosition_3B9EB7BB_SubSurfaceScattering_5;
                #endif
                PositionXZWSUndisp_2 = _GENERATEDSHADER_71C0694B_Out_0;
                LodAlpha_1 = _GENERATEDSHADER_2A933A74_Out_0;
                OceanDepth_3 = _GENERATEDSHADER_EFBF6036_Out_0;
                Foam_4 = _GENERATEDSHADER_1BBAE801_Out_0;
                Shadow_5 = _GENERATEDSHADER_B499BDE6_Out_0;
                Flow_6 = _GENERATEDSHADER_84CB20AD_Out_0;
                SubSurfaceScattering_7 = _GENERATEDSHADER_6BDC98D1_Out_0;
            }
            
            // 673f3e02c7d6371b4ae419cc02e9dca4
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeLightData.hlsl"
            
            struct Bindings_CrestLightData_b74b6e8c0b489314ca7aea3e2cc9c54c
            {
            };
            
            void SG_CrestLightData_b74b6e8c0b489314ca7aea3e2cc9c54c(Bindings_CrestLightData_b74b6e8c0b489314ca7aea3e2cc9c54c IN, out half3 Direction_1, out half3 Intensity_2)
            {
                half3 _CustomFunction_5D41A6E0_Direction_0;
                half3 _CustomFunction_5D41A6E0_Colour_1;
                CrestNodeLightData_half(_CustomFunction_5D41A6E0_Direction_0, _CustomFunction_5D41A6E0_Colour_1);
                Direction_1 = _CustomFunction_5D41A6E0_Direction_0;
                Intensity_2 = _CustomFunction_5D41A6E0_Colour_1;
            }
            
            void Unity_Normalize_float3(float3 In, out float3 Out)
            {
                Out = normalize(In);
            }
            
            void Unity_Not_float(float In, out float Out)
            {
                Out = !In;
            }
            
            struct Bindings_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2
            {
                float FaceSign;
            };
            
            void SG_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2(Bindings_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2 IN, out float OutBoolean_1)
            {
                float _IsFrontFace_F6DF08D5_Out_0 = max(0, IN.FaceSign);
                float _Not_3B19614D_Out_1;
                Unity_Not_float(_IsFrontFace_F6DF08D5_Out_0, _Not_3B19614D_Out_1);
                OutBoolean_1 = _Not_3B19614D_Out_1;
            }
            
            // 928f91ea5fffaa68cdc1e5110d727baf
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeNormalMapping.hlsl"
            
            struct Bindings_CrestComputeNormal_61b9efc6612ab3b4f84174344af5e12a
            {
                float FaceSign;
            };
            
            void SG_CrestComputeNormal_61b9efc6612ab3b4f84174344af5e12a(float3 Vector3_FE793823, float3 Vector3_C8190B61, float4 Vector4_F18E4948, float4 Vector4_43DD8E03, float Vector1_8771A258, TEXTURE2D_PARAM(Texture2D_6CA3A26C, samplerTexture2D_6CA3A26C), float4 Texture2D_6CA3A26C_TexelSize, float Vector1_418D6270, float Vector1_6EC9A7C0, float Vector1_5D9D8139, float2 Vector2_3ED47A62, float2 Vector2_891575B0, float3 Vector3_A9F402BF, Bindings_CrestComputeNormal_61b9efc6612ab3b4f84174344af5e12a IN, out half3 Normal_1)
            {
                float3 _Property_9021A08B_Out_0 = Vector3_FE793823;
                float3 _Property_9C8BC1F1_Out_0 = Vector3_C8190B61;
                float4 _Property_BA13B38B_Out_0 = Vector4_F18E4948;
                float4 _Property_587E24D5_Out_0 = Vector4_43DD8E03;
                float _Property_1A49C52D_Out_0 = Vector1_8771A258;
                float _Property_514FBFB9_Out_0 = Vector1_418D6270;
                float _Property_27A6DF1E_Out_0 = Vector1_6EC9A7C0;
                float _Property_A277E64F_Out_0 = Vector1_5D9D8139;
                float2 _Property_805F9A1D_Out_0 = Vector2_3ED47A62;
                float2 _Property_100A6EB8_Out_0 = Vector2_891575B0;
                float3 _Property_11AD0CE_Out_0 = Vector3_A9F402BF;
                Bindings_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2 _CrestIsUnderwater_BA18A1A;
                _CrestIsUnderwater_BA18A1A.FaceSign = IN.FaceSign;
                float _CrestIsUnderwater_BA18A1A_OutBoolean_1;
                SG_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2(_CrestIsUnderwater_BA18A1A, _CrestIsUnderwater_BA18A1A_OutBoolean_1);
                half3 _CustomFunction_61A7F8B0_NormalTS_1;
                OceanNormals_half(_Property_9021A08B_Out_0, _Property_9C8BC1F1_Out_0, _Property_BA13B38B_Out_0, _Property_587E24D5_Out_0, _Property_1A49C52D_Out_0, Texture2D_6CA3A26C, _Property_514FBFB9_Out_0, _Property_27A6DF1E_Out_0, _Property_A277E64F_Out_0, _Property_805F9A1D_Out_0, _Property_100A6EB8_Out_0, _Property_11AD0CE_Out_0, _CrestIsUnderwater_BA18A1A_OutBoolean_1, _CustomFunction_61A7F8B0_NormalTS_1);
                Normal_1 = _CustomFunction_61A7F8B0_NormalTS_1;
            }
            
            // 52e02b1b13552331adad44cf4a7ae4a5
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeApplyFresnel.hlsl"
            
            struct Bindings_CrestFresnel_c6f6c13c4fdb04e42b427e4c2610d3c9
            {
                float FaceSign;
            };
            
            void SG_CrestFresnel_c6f6c13c4fdb04e42b427e4c2610d3c9(float3 Vector3_FFFD5D37, float3 Vector3_50713CBB, float Vector1_C2909293, float Vector1_DDF5B66E, Bindings_CrestFresnel_c6f6c13c4fdb04e42b427e4c2610d3c9 IN, out float LightTransmitted_1, out float LightReflected_2)
            {
                float3 _Property_3166A32_Out_0 = Vector3_50713CBB;
                float3 _Property_ED2FFB18_Out_0 = Vector3_FFFD5D37;
                Bindings_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2 _CrestIsUnderwater_291EED16;
                _CrestIsUnderwater_291EED16.FaceSign = IN.FaceSign;
                float _CrestIsUnderwater_291EED16_OutBoolean_1;
                SG_CrestIsUnderwater_52f7750f15e114937b54a0fd27f0d2f2(_CrestIsUnderwater_291EED16, _CrestIsUnderwater_291EED16_OutBoolean_1);
                float _Property_D5B7D059_Out_0 = Vector1_DDF5B66E;
                float _Property_2395CED2_Out_0 = Vector1_C2909293;
                float _CustomFunction_6DEBC54E_LightTransmitted_1;
                float _CustomFunction_6DEBC54E_LightReflected_10;
                CrestNodeApplyFresnel_float(_Property_3166A32_Out_0, _Property_ED2FFB18_Out_0, _CrestIsUnderwater_291EED16_OutBoolean_1, _Property_D5B7D059_Out_0, _Property_2395CED2_Out_0, _CustomFunction_6DEBC54E_LightTransmitted_1, _CustomFunction_6DEBC54E_LightReflected_10);
                LightTransmitted_1 = _CustomFunction_6DEBC54E_LightTransmitted_1;
                LightReflected_2 = _CustomFunction_6DEBC54E_LightReflected_10;
            }
            
            void GetAmbientLighting_float(out float3 AmbientLighting)
            {
                AmbientLighting = half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
            }
            
            // 4e36a733a1fa5e9359282bf30157c748
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeLightWaterVolume.hlsl"
            
            struct Bindings_CrestVolumeLighting_e9ed6e11710a50640bb4b811d0fa84f2
            {
            };
            
            void SG_CrestVolumeLighting_e9ed6e11710a50640bb4b811d0fa84f2(float4 Vector4_7C3B7892, float3 Vector3_CB562741, float4 Vector4_1925E051, float Vector1_E556918C, float Vector1_67342C54, float Vector1_D7DF1AB, float Vector1_6823579F, float4 Vector4_79A1BE1F, float Vector1_7223C6AC, float Vector1_66E9E54, float2 Vector2_D3558D33, float Vector1_96B7F6DA, float3 Vector3_1559C54, float3 Vector3_EBF06BD4, float3 Vector3_4BB1E4A, float3 Vector3_938EEF71, float3 Vector3_CAD84B7A, Bindings_CrestVolumeLighting_e9ed6e11710a50640bb4b811d0fa84f2 IN, out half3 VolumeLighting_1)
            {
                float4 _Property_3BF186D2_Out_0 = Vector4_7C3B7892;
                float3 _Property_36BD3B33_Out_0 = Vector3_CB562741;
                float4 _Property_DEEB4017_Out_0 = Vector4_1925E051;
                float _Property_DEF8261_Out_0 = Vector1_E556918C;
                float _Property_E59433A0_Out_0 = Vector1_67342C54;
                float _Property_B909C546_Out_0 = Vector1_D7DF1AB;
                float _Property_E4FBA75D_Out_0 = Vector1_6823579F;
                float4 _Property_856C2495_Out_0 = Vector4_79A1BE1F;
                float _Property_D81EDA3D_Out_0 = Vector1_7223C6AC;
                float _Property_9368CB3D_Out_0 = Vector1_66E9E54;
                float2 _Property_BF038BF7_Out_0 = Vector2_D3558D33;
                float _Property_F35AF73E_Out_0 = Vector1_96B7F6DA;
                float3 _Property_32B01413_Out_0 = Vector3_1559C54;
                float3 _Property_5B1BCADB_Out_0 = Vector3_EBF06BD4;
                float3 _Property_6BBACEFC_Out_0 = Vector3_4BB1E4A;
                float3 _Property_C8DE9461_Out_0 = Vector3_938EEF71;
                float3 _Property_919832B1_Out_0 = Vector3_CAD84B7A;
                half3 _CustomFunction_F6F194A9_VolumeLighting_5;
                CrestNodeLightWaterVolume_half((_Property_3BF186D2_Out_0.xyz), _Property_36BD3B33_Out_0, (_Property_DEEB4017_Out_0.xyz), _Property_DEF8261_Out_0, _Property_E59433A0_Out_0, _Property_B909C546_Out_0, _Property_E4FBA75D_Out_0, (_Property_856C2495_Out_0.xyz), _Property_D81EDA3D_Out_0, _Property_9368CB3D_Out_0, _Property_BF038BF7_Out_0, _Property_F35AF73E_Out_0, _Property_32B01413_Out_0, _Property_5B1BCADB_Out_0, _Property_6BBACEFC_Out_0, _Property_C8DE9461_Out_0, _Property_919832B1_Out_0, _CustomFunction_F6F194A9_VolumeLighting_5);
                VolumeLighting_1 = _CustomFunction_F6F194A9_VolumeLighting_5;
            }
            
            void Unity_Negate_float(float In, out float Out)
            {
                Out = -1 * In;
            }
            
            void Unity_SceneColor_float(float4 UV, out float3 Out)
            {
                Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
            }
            
            void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
            
            // edda0395615fdcd072915b34eccb4069
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeOceanGlobals.hlsl"
            
            struct Bindings_CrestOceanGlobals_d50a85284893ec447a25a093505a2120
            {
            };
            
            void SG_CrestOceanGlobals_d50a85284893ec447a25a093505a2120(Bindings_CrestOceanGlobals_d50a85284893ec447a25a093505a2120 IN, out float CrestTime_1, out float TexelsPerWave_2, out float3 OceanCenterPosWorld_3, out float SliceCount_4, out float MeshScaleLerp_5)
            {
                float _CustomFunction_9ED6B15_CrestTime_0;
                float _CustomFunction_9ED6B15_TexelsPerWave_1;
                float3 _CustomFunction_9ED6B15_OceanCenterPosWorld_2;
                float _CustomFunction_9ED6B15_SliceCount_3;
                float _CustomFunction_9ED6B15_MeshScaleLerp_4;
                CrestNodeOceanGlobals_float(_CustomFunction_9ED6B15_CrestTime_0, _CustomFunction_9ED6B15_TexelsPerWave_1, _CustomFunction_9ED6B15_OceanCenterPosWorld_2, _CustomFunction_9ED6B15_SliceCount_3, _CustomFunction_9ED6B15_MeshScaleLerp_4);
                CrestTime_1 = _CustomFunction_9ED6B15_CrestTime_0;
                TexelsPerWave_2 = _CustomFunction_9ED6B15_TexelsPerWave_1;
                OceanCenterPosWorld_3 = _CustomFunction_9ED6B15_OceanCenterPosWorld_2;
                SliceCount_4 = _CustomFunction_9ED6B15_SliceCount_3;
                MeshScaleLerp_5 = _CustomFunction_9ED6B15_MeshScaleLerp_4;
            }
            
            void Unity_Modulo_float(float A, float B, out float Out)
            {
                Out = fmod(A, B);
            }
            
            void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
            {
                Out = A * B;
            }
            
            void Unity_Comparison_Greater_float(float A, float B, out float Out)
            {
                Out = A > B ? 1 : 0;
            }
            
            void Unity_Subtract_float(float A, float B, out float Out)
            {
                Out = A - B;
            }
            
            void Unity_Branch_float(float Predicate, float True, float False, out float Out)
            {
                Out = lerp(False, True, Predicate);
            }
            
            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }
            
            struct Bindings_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1
            {
            };
            
            void SG_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1(float2 Vector2_B562EFB1, float2 Vector2_83AA31A8, Bindings_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1 IN, out float2 DisplacedA_1, out float WeightA_3, out float2 DisplacedB_2, out float WeightB_4)
            {
                float2 _Property_DB670C03_Out_0 = Vector2_83AA31A8;
                float2 _Property_6ED023E0_Out_0 = Vector2_B562EFB1;
                Bindings_CrestOceanGlobals_d50a85284893ec447a25a093505a2120 _CrestOceanGlobals_40DCBE3E;
                float _CrestOceanGlobals_40DCBE3E_CrestTime_1;
                float _CrestOceanGlobals_40DCBE3E_TexelsPerWave_2;
                float3 _CrestOceanGlobals_40DCBE3E_OceanCenterPosWorld_3;
                float _CrestOceanGlobals_40DCBE3E_SliceCount_4;
                float _CrestOceanGlobals_40DCBE3E_MeshScaleLerp_5;
                SG_CrestOceanGlobals_d50a85284893ec447a25a093505a2120(_CrestOceanGlobals_40DCBE3E, _CrestOceanGlobals_40DCBE3E_CrestTime_1, _CrestOceanGlobals_40DCBE3E_TexelsPerWave_2, _CrestOceanGlobals_40DCBE3E_OceanCenterPosWorld_3, _CrestOceanGlobals_40DCBE3E_SliceCount_4, _CrestOceanGlobals_40DCBE3E_MeshScaleLerp_5);
                float _Modulo_CC9BC285_Out_2;
                Unity_Modulo_float(_CrestOceanGlobals_40DCBE3E_CrestTime_1, 2, _Modulo_CC9BC285_Out_2);
                float2 _Multiply_821FCA56_Out_2;
                Unity_Multiply_float(_Property_6ED023E0_Out_0, (_Modulo_CC9BC285_Out_2.xx), _Multiply_821FCA56_Out_2);
                float2 _Subtract_273125FF_Out_2;
                Unity_Subtract_float2(_Property_DB670C03_Out_0, _Multiply_821FCA56_Out_2, _Subtract_273125FF_Out_2);
                float2 _Property_C2A19C1C_Out_0 = Vector2_83AA31A8;
                #if defined(CREST_FLOW_ON)
                float2 _FLOW_963D27CC_Out_0 = _Subtract_273125FF_Out_2;
                #else
                float2 _FLOW_963D27CC_Out_0 = _Property_C2A19C1C_Out_0;
                #endif
                float _Comparison_67E5EC91_Out_2;
                Unity_Comparison_Greater_float(_Modulo_CC9BC285_Out_2, 1, _Comparison_67E5EC91_Out_2);
                float _Subtract_289E2A26_Out_2;
                Unity_Subtract_float(2, _Modulo_CC9BC285_Out_2, _Subtract_289E2A26_Out_2);
                float _Branch_57B6378F_Out_3;
                Unity_Branch_float(_Comparison_67E5EC91_Out_2, _Subtract_289E2A26_Out_2, _Modulo_CC9BC285_Out_2, _Branch_57B6378F_Out_3);
                #if defined(CREST_FLOW_ON)
                float _FLOW_AB68F2D0_Out_0 = _Branch_57B6378F_Out_3;
                #else
                float _FLOW_AB68F2D0_Out_0 = 0;
                #endif
                float2 _Property_CF607B59_Out_0 = Vector2_83AA31A8;
                float2 _Property_8EFEBF1A_Out_0 = Vector2_B562EFB1;
                float _Add_43F824C8_Out_2;
                Unity_Add_float(_CrestOceanGlobals_40DCBE3E_CrestTime_1, 1, _Add_43F824C8_Out_2);
                float _Modulo_2FF365BF_Out_2;
                Unity_Modulo_float(_Add_43F824C8_Out_2, 2, _Modulo_2FF365BF_Out_2);
                float2 _Multiply_28DD98EB_Out_2;
                Unity_Multiply_float(_Property_8EFEBF1A_Out_0, (_Modulo_2FF365BF_Out_2.xx), _Multiply_28DD98EB_Out_2);
                float2 _Subtract_1C7014D5_Out_2;
                Unity_Subtract_float2(_Property_CF607B59_Out_0, _Multiply_28DD98EB_Out_2, _Subtract_1C7014D5_Out_2);
                #if defined(CREST_FLOW_ON)
                float2 _FLOW_D38C09E5_Out_0 = _Subtract_1C7014D5_Out_2;
                #else
                float2 _FLOW_D38C09E5_Out_0 = _Property_C2A19C1C_Out_0;
                #endif
                float _Subtract_563D329D_Out_2;
                Unity_Subtract_float(1, _Branch_57B6378F_Out_3, _Subtract_563D329D_Out_2);
                #if defined(CREST_FLOW_ON)
                float _FLOW_CB3A12C4_Out_0 = _Subtract_563D329D_Out_2;
                #else
                float _FLOW_CB3A12C4_Out_0 = 0;
                #endif
                DisplacedA_1 = _FLOW_963D27CC_Out_0;
                WeightA_3 = _FLOW_AB68F2D0_Out_0;
                DisplacedB_2 = _FLOW_D38C09E5_Out_0;
                WeightB_4 = _FLOW_CB3A12C4_Out_0;
            }
            
            void Unity_Lerp_float2(float2 A, float2 B, float2 T, out float2 Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Multiply_float(float A, float B, out float Out)
            {
                Out = A * B;
            }
            
            void Unity_Add_float2(float2 A, float2 B, out float2 Out)
            {
                Out = A + B;
            }
            
            void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
            {
                Out = A / B;
            }
            
            void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
            {
                Out = dot(A, B);
            }
            
            void Unity_Lerp_float(float A, float B, float T, out float Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
            {
                Out = A * B;
            }
            
            void Unity_Saturate_float(float In, out float Out)
            {
                Out = saturate(In);
            }
            
            // 77d0d525f8d2ec135aebd23c92ac3bf7
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeAmbientLight.hlsl"
            
            struct Bindings_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744
            {
            };
            
            void SG_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744(float3 Vector3_6BC21072, float Vector1_856C8201, float Vector1_D8FFBADE, TEXTURE2D_PARAM(Texture2D_E5D62D20, samplerTexture2D_E5D62D20), float4 Texture2D_E5D62D20_TexelSize, float2 Vector2_1544647C, float Vector1_563FFC82, float Vector1_50FCE8BC, float3 Vector3_8690BC0A, float4 Vector4_8E91C60A, float4 Vector4_8FA06CD1, float2 Vector2_A796D1D3, float2 Vector2_73579388, float Vector1_5220E305, float3 Vector3_7DE999FE, Bindings_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744 IN, out float3 Colour_1)
            {
                float _Vector1_50808D77_Out_0 = 0.74;
                float2 _Property_1DB3A8DD_Out_0 = Vector2_73579388;
                float2 _Property_4E1B12A2_Out_0 = Vector2_A796D1D3;
                float _Vector1_22194DBD_Out_0 = 0.7;
                float2 _Lerp_24C286E6_Out_3;
                Unity_Lerp_float2(_Property_1DB3A8DD_Out_0, _Property_4E1B12A2_Out_0, (_Vector1_22194DBD_Out_0.xx), _Lerp_24C286E6_Out_3);
                Bindings_CrestOceanGlobals_d50a85284893ec447a25a093505a2120 _CrestOceanGlobals_FD233E7F;
                float _CrestOceanGlobals_FD233E7F_CrestTime_1;
                float _CrestOceanGlobals_FD233E7F_TexelsPerWave_2;
                float3 _CrestOceanGlobals_FD233E7F_OceanCenterPosWorld_3;
                float _CrestOceanGlobals_FD233E7F_SliceCount_4;
                float _CrestOceanGlobals_FD233E7F_MeshScaleLerp_5;
                SG_CrestOceanGlobals_d50a85284893ec447a25a093505a2120(_CrestOceanGlobals_FD233E7F, _CrestOceanGlobals_FD233E7F_CrestTime_1, _CrestOceanGlobals_FD233E7F_TexelsPerWave_2, _CrestOceanGlobals_FD233E7F_OceanCenterPosWorld_3, _CrestOceanGlobals_FD233E7F_SliceCount_4, _CrestOceanGlobals_FD233E7F_MeshScaleLerp_5);
                float _Multiply_8E48D7F_Out_2;
                Unity_Multiply_float(0.5, _CrestOceanGlobals_FD233E7F_CrestTime_1, _Multiply_8E48D7F_Out_2);
                float2 _Vector2_93AF7702_Out_0 = float2(0.866, 0.5);
                float2 _Multiply_E81E304E_Out_2;
                Unity_Multiply_float((_Multiply_8E48D7F_Out_2.xx), _Vector2_93AF7702_Out_0, _Multiply_E81E304E_Out_2);
                float2 _Add_99B474A3_Out_2;
                Unity_Add_float2(_Lerp_24C286E6_Out_3, _Multiply_E81E304E_Out_2, _Add_99B474A3_Out_2);
                float _Property_A5B593BF_Out_0 = Vector1_563FFC82;
                float2 _Divide_6E172BAC_Out_2;
                Unity_Divide_float2(_Add_99B474A3_Out_2, (_Property_A5B593BF_Out_0.xx), _Divide_6E172BAC_Out_2);
                float _Vector1_33088EF8_Out_0 = 0.125;
                float3 _Property_CBFC7F14_Out_0 = Vector3_8690BC0A;
                float _Split_638CEA28_R_1 = _Property_CBFC7F14_Out_0[0];
                float _Split_638CEA28_G_2 = _Property_CBFC7F14_Out_0[1];
                float _Split_638CEA28_B_3 = _Property_CBFC7F14_Out_0[2];
                float _Split_638CEA28_A_4 = 0;
                float2 _Vector2_1CDF6E92_Out_0 = float2(_Split_638CEA28_R_1, _Split_638CEA28_B_3);
                float2 _Multiply_FEAB095D_Out_2;
                Unity_Multiply_float((_Vector1_33088EF8_Out_0.xx), _Vector2_1CDF6E92_Out_0, _Multiply_FEAB095D_Out_2);
                float2 _Add_301F9C93_Out_2;
                Unity_Add_float2(_Divide_6E172BAC_Out_2, _Multiply_FEAB095D_Out_2, _Add_301F9C93_Out_2);
                float2 _Multiply_47C4DD4E_Out_2;
                Unity_Multiply_float((_Vector1_50808D77_Out_0.xx), _Add_301F9C93_Out_2, _Multiply_47C4DD4E_Out_2);
                float _Property_569DF47F_Out_0 = Vector1_856C8201;
                float3 _Property_D240D17_Out_0 = Vector3_7DE999FE;
                float _Split_628EF5DE_R_1 = _Property_D240D17_Out_0[0];
                float _Split_628EF5DE_G_2 = _Property_D240D17_Out_0[1];
                float _Split_628EF5DE_B_3 = _Property_D240D17_Out_0[2];
                float _Split_628EF5DE_A_4 = 0;
                float2 _Vector2_BF066046_Out_0 = float2(_Split_628EF5DE_R_1, _Split_628EF5DE_B_3);
                float2 _Multiply_43CB1359_Out_2;
                Unity_Multiply_float((_Property_569DF47F_Out_0.xx), _Vector2_BF066046_Out_0, _Multiply_43CB1359_Out_2);
                float3 _Property_122053A8_Out_0 = Vector3_8690BC0A;
                float3 _Property_ADBC2425_Out_0 = Vector3_7DE999FE;
                float _DotProduct_B4F8C812_Out_2;
                Unity_DotProduct_float3(_Property_122053A8_Out_0, _Property_ADBC2425_Out_0, _DotProduct_B4F8C812_Out_2);
                float2 _Divide_63189A2B_Out_2;
                Unity_Divide_float2(_Multiply_43CB1359_Out_2, (_DotProduct_B4F8C812_Out_2.xx), _Divide_63189A2B_Out_2);
                float2 _Add_D56F8BCC_Out_2;
                Unity_Add_float2(_Multiply_47C4DD4E_Out_2, _Divide_63189A2B_Out_2, _Add_D56F8BCC_Out_2);
                float _Vector1_4A3115D0_Out_0 = 4;
                float4 _Property_6BB45B70_Out_0 = Vector4_8E91C60A;
                float _Split_128BB5B0_R_1 = _Property_6BB45B70_Out_0[0];
                float _Split_128BB5B0_G_2 = _Property_6BB45B70_Out_0[1];
                float _Split_128BB5B0_B_3 = _Property_6BB45B70_Out_0[2];
                float _Split_128BB5B0_A_4 = _Property_6BB45B70_Out_0[3];
                float _Multiply_338764B5_Out_2;
                Unity_Multiply_float(_Vector1_4A3115D0_Out_0, _Split_128BB5B0_R_1, _Multiply_338764B5_Out_2);
                float _Property_ACBE1A98_Out_0 = Vector1_563FFC82;
                float _Multiply_69F2FFA6_Out_2;
                Unity_Multiply_float(_Multiply_338764B5_Out_2, _Property_ACBE1A98_Out_0, _Multiply_69F2FFA6_Out_2);
                float2 _Divide_FF361B20_Out_2;
                Unity_Divide_float2(_Add_D56F8BCC_Out_2, (_Multiply_69F2FFA6_Out_2.xx), _Divide_FF361B20_Out_2);
                float4 _SampleTexture2DLOD_181D539B_RGBA_0 = SAMPLE_TEXTURE2D_LOD(Texture2D_E5D62D20, SamplerState_Linear_Repeat, _Divide_FF361B20_Out_2, 3);
                float _SampleTexture2DLOD_181D539B_R_5 = _SampleTexture2DLOD_181D539B_RGBA_0.r;
                float _SampleTexture2DLOD_181D539B_G_6 = _SampleTexture2DLOD_181D539B_RGBA_0.g;
                float _SampleTexture2DLOD_181D539B_B_7 = _SampleTexture2DLOD_181D539B_RGBA_0.b;
                float _SampleTexture2DLOD_181D539B_A_8 = _SampleTexture2DLOD_181D539B_RGBA_0.a;
                float _Vector1_C260EA24_Out_0 = 4;
                float4 _Property_1EB65445_Out_0 = Vector4_8FA06CD1;
                float _Split_DFFF5F9B_R_1 = _Property_1EB65445_Out_0[0];
                float _Split_DFFF5F9B_G_2 = _Property_1EB65445_Out_0[1];
                float _Split_DFFF5F9B_B_3 = _Property_1EB65445_Out_0[2];
                float _Split_DFFF5F9B_A_4 = _Property_1EB65445_Out_0[3];
                float _Multiply_FD1848E_Out_2;
                Unity_Multiply_float(_Vector1_C260EA24_Out_0, _Split_DFFF5F9B_R_1, _Multiply_FD1848E_Out_2);
                float _Property_4D74395B_Out_0 = Vector1_563FFC82;
                float _Multiply_BB87C63D_Out_2;
                Unity_Multiply_float(_Multiply_FD1848E_Out_2, _Property_4D74395B_Out_0, _Multiply_BB87C63D_Out_2);
                float2 _Divide_7AE4E36C_Out_2;
                Unity_Divide_float2(_Add_D56F8BCC_Out_2, (_Multiply_BB87C63D_Out_2.xx), _Divide_7AE4E36C_Out_2);
                float4 _SampleTexture2DLOD_F7B977AE_RGBA_0 = SAMPLE_TEXTURE2D_LOD(Texture2D_E5D62D20, SamplerState_Linear_Repeat, _Divide_7AE4E36C_Out_2, 3);
                float _SampleTexture2DLOD_F7B977AE_R_5 = _SampleTexture2DLOD_F7B977AE_RGBA_0.r;
                float _SampleTexture2DLOD_F7B977AE_G_6 = _SampleTexture2DLOD_F7B977AE_RGBA_0.g;
                float _SampleTexture2DLOD_F7B977AE_B_7 = _SampleTexture2DLOD_F7B977AE_RGBA_0.b;
                float _SampleTexture2DLOD_F7B977AE_A_8 = _SampleTexture2DLOD_F7B977AE_RGBA_0.a;
                float _Property_8BDFE27D_Out_0 = Vector1_5220E305;
                float _Lerp_8E281E25_Out_3;
                Unity_Lerp_float(_SampleTexture2DLOD_181D539B_R_5, _SampleTexture2DLOD_F7B977AE_R_5, _Property_8BDFE27D_Out_0, _Lerp_8E281E25_Out_3);
                float3 _Property_76A1927E_Out_0 = Vector3_6BC21072;
                float3 _Multiply_559CF32F_Out_2;
                Unity_Multiply_float((_Lerp_8E281E25_Out_3.xxx), _Property_76A1927E_Out_0, _Multiply_559CF32F_Out_2);
                float _Property_47590F25_Out_0 = Vector1_50FCE8BC;
                float _Property_8CF73BE5_Out_0 = Vector1_D8FFBADE;
                float _Multiply_A19262A8_Out_2;
                Unity_Multiply_float(_Property_47590F25_Out_0, _Property_8CF73BE5_Out_0, _Multiply_A19262A8_Out_2);
                float _Saturate_A17AF199_Out_1;
                Unity_Saturate_float(_Multiply_A19262A8_Out_2, _Saturate_A17AF199_Out_1);
                float3 _Multiply_DCE93606_Out_2;
                Unity_Multiply_float(_Multiply_559CF32F_Out_2, (_Saturate_A17AF199_Out_1.xxx), _Multiply_DCE93606_Out_2);
                half3 _CustomFunction_6C4427EF_AmbientLight_0;
                CrestNodeAmbientLight_half(_CustomFunction_6C4427EF_AmbientLight_0);
                float3 _Multiply_9B6FA71B_Out_2;
                Unity_Multiply_float(_Multiply_DCE93606_Out_2, _CustomFunction_6C4427EF_AmbientLight_0, _Multiply_9B6FA71B_Out_2);
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_B0667840_Out_0 = _Multiply_9B6FA71B_Out_2;
                #else
                float3 _FOAM_B0667840_Out_0 = float3(0, 0, 0);
                #endif
                Colour_1 = _FOAM_B0667840_Out_0;
            }
            
            struct Bindings_CrestFoamBubblesWithFlow_e132fba35874b4923988ef35a40e48c3
            {
            };
            
            void SG_CrestFoamBubblesWithFlow_e132fba35874b4923988ef35a40e48c3(float3 Vector3_6BC21072, float Vector1_856C8201, float Vector1_D8FFBADE, TEXTURE2D_PARAM(Texture2D_E5D62D20, samplerTexture2D_E5D62D20), float4 Texture2D_E5D62D20_TexelSize, float2 Vector2_1544647C, float Vector1_563FFC82, float Vector1_50FCE8BC, float3 Vector3_8690BC0A, float4 Vector4_8E91C60A, float4 Vector4_8FA06CD1, float2 Vector2_A796D1D3, float2 Vector2_73579388, float Vector1_5220E305, float3 Vector3_7DE999FE, float2 Vector2_58330803, Bindings_CrestFoamBubblesWithFlow_e132fba35874b4923988ef35a40e48c3 IN, out float3 Colour_1)
            {
                float3 _Property_943DDE94_Out_0 = Vector3_6BC21072;
                float _Property_2A86C6D_Out_0 = Vector1_856C8201;
                float _Property_742EBA65_Out_0 = Vector1_D8FFBADE;
                float2 _Property_56F70460_Out_0 = Vector2_1544647C;
                float _Property_BBD1954E_Out_0 = Vector1_563FFC82;
                float _Property_63B10EE4_Out_0 = Vector1_50FCE8BC;
                float3 _Property_736DEE08_Out_0 = Vector3_8690BC0A;
                float4 _Property_E1794A68_Out_0 = Vector4_8E91C60A;
                float4 _Property_13FD15E9_Out_0 = Vector4_8FA06CD1;
                float2 _Property_8C400C63_Out_0 = Vector2_A796D1D3;
                float2 _Property_B43D23D2_Out_0 = Vector2_58330803;
                float2 _Property_6AC0F258_Out_0 = Vector2_73579388;
                Bindings_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1 _CrestFlow_2C0F2FAE;
                float2 _CrestFlow_2C0F2FAE_DisplacedA_1;
                float _CrestFlow_2C0F2FAE_WeightA_3;
                float2 _CrestFlow_2C0F2FAE_DisplacedB_2;
                float _CrestFlow_2C0F2FAE_WeightB_4;
                SG_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1(_Property_B43D23D2_Out_0, _Property_6AC0F258_Out_0, _CrestFlow_2C0F2FAE, _CrestFlow_2C0F2FAE_DisplacedA_1, _CrestFlow_2C0F2FAE_WeightA_3, _CrestFlow_2C0F2FAE_DisplacedB_2, _CrestFlow_2C0F2FAE_WeightB_4);
                float _Property_4C00CA0D_Out_0 = Vector1_5220E305;
                float3 _Property_5BF1E9DE_Out_0 = Vector3_7DE999FE;
                Bindings_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744 _CrestFoamBubbles_E18873D;
                float3 _CrestFoamBubbles_E18873D_Colour_1;
                SG_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744(_Property_943DDE94_Out_0, _Property_2A86C6D_Out_0, _Property_742EBA65_Out_0, TEXTURE2D_ARGS(Texture2D_E5D62D20, samplerTexture2D_E5D62D20), Texture2D_E5D62D20_TexelSize, _Property_56F70460_Out_0, _Property_BBD1954E_Out_0, _Property_63B10EE4_Out_0, _Property_736DEE08_Out_0, _Property_E1794A68_Out_0, _Property_13FD15E9_Out_0, _Property_8C400C63_Out_0, _CrestFlow_2C0F2FAE_DisplacedA_1, _Property_4C00CA0D_Out_0, _Property_5BF1E9DE_Out_0, _CrestFoamBubbles_E18873D, _CrestFoamBubbles_E18873D_Colour_1);
                float3 _Multiply_91E077CA_Out_2;
                Unity_Multiply_float(_CrestFoamBubbles_E18873D_Colour_1, (_CrestFlow_2C0F2FAE_WeightA_3.xxx), _Multiply_91E077CA_Out_2);
                float3 _Property_A1641BBA_Out_0 = Vector3_6BC21072;
                float _Property_3D5C8C49_Out_0 = Vector1_856C8201;
                float _Property_212108F5_Out_0 = Vector1_D8FFBADE;
                float2 _Property_E4A605_Out_0 = Vector2_1544647C;
                float _Property_6B5F6C8D_Out_0 = Vector1_563FFC82;
                float _Property_C1EFD93_Out_0 = Vector1_50FCE8BC;
                float3 _Property_374658EE_Out_0 = Vector3_8690BC0A;
                float4 _Property_93465CAB_Out_0 = Vector4_8E91C60A;
                float4 _Property_D292F7E_Out_0 = Vector4_8FA06CD1;
                float2 _Property_41EA12FB_Out_0 = Vector2_A796D1D3;
                float _Property_ACCAE2A2_Out_0 = Vector1_5220E305;
                float3 _Property_419B8C8_Out_0 = Vector3_7DE999FE;
                Bindings_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744 _CrestFoamBubbles_B2999161;
                float3 _CrestFoamBubbles_B2999161_Colour_1;
                SG_CrestFoamBubbles_655a97f40c5d44ade931b6a5e4048744(_Property_A1641BBA_Out_0, _Property_3D5C8C49_Out_0, _Property_212108F5_Out_0, TEXTURE2D_ARGS(Texture2D_E5D62D20, samplerTexture2D_E5D62D20), Texture2D_E5D62D20_TexelSize, _Property_E4A605_Out_0, _Property_6B5F6C8D_Out_0, _Property_C1EFD93_Out_0, _Property_374658EE_Out_0, _Property_93465CAB_Out_0, _Property_D292F7E_Out_0, _Property_41EA12FB_Out_0, _CrestFlow_2C0F2FAE_DisplacedB_2, _Property_ACCAE2A2_Out_0, _Property_419B8C8_Out_0, _CrestFoamBubbles_B2999161, _CrestFoamBubbles_B2999161_Colour_1);
                float3 _Multiply_B28E3E4F_Out_2;
                Unity_Multiply_float(_CrestFoamBubbles_B2999161_Colour_1, (_CrestFlow_2C0F2FAE_WeightB_4.xxx), _Multiply_B28E3E4F_Out_2);
                float3 _Add_4A081B98_Out_2;
                Unity_Add_float3(_Multiply_91E077CA_Out_2, _Multiply_B28E3E4F_Out_2, _Add_4A081B98_Out_2);
                #if defined(CREST_FLOW_ON)
                float3 _FLOW_3ACDD4E5_Out_0 = _Add_4A081B98_Out_2;
                #else
                float3 _FLOW_3ACDD4E5_Out_0 = _CrestFoamBubbles_E18873D_Colour_1;
                #endif
                Colour_1 = _FLOW_3ACDD4E5_Out_0;
            }
            
            // 11f8e1767f0d2397594b0042f8356f6e
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeVolumeEmission.hlsl"
            
            struct Bindings_CrestSampleOceanDataSingle_a667f031fd6a3dd42beee0ccc432233d
            {
            };
            
            void SG_CrestSampleOceanDataSingle_a667f031fd6a3dd42beee0ccc432233d(float2 Vector2_1BD49B8D, float3 Vector3_7E91D336, float4 Vector4_C0B2B5EA, float Vector1_8EA8B92B, Bindings_CrestSampleOceanDataSingle_a667f031fd6a3dd42beee0ccc432233d IN, out float3 Displacement_1, out float OceanWaterDepth_5, out float Foam_6, out float2 Shadow_7, out float2 Flow_8, out float SubSurfaceScattering_9)
            {
                float2 _Property_FA70A3E6_Out_0 = Vector2_1BD49B8D;
                float3 _Property_C925A867_Out_0 = Vector3_7E91D336;
                float4 _Property_467D1BE7_Out_0 = Vector4_C0B2B5EA;
                float _Property_59E019ED_Out_0 = Vector1_8EA8B92B;
                float3 _CustomFunction_487C31E1_Displacement_3;
                float _CustomFunction_487C31E1_OceanDepth_8;
                float _CustomFunction_487C31E1_Foam_4;
                float2 _CustomFunction_487C31E1_Shadow_5;
                float2 _CustomFunction_487C31E1_Flow_6;
                float _CustomFunction_487C31E1_SSS_17;
                CrestNodeSampleOceanDataSingle_float(_Property_FA70A3E6_Out_0, _Property_C925A867_Out_0, _Property_467D1BE7_Out_0, _Property_59E019ED_Out_0, _CustomFunction_487C31E1_Displacement_3, _CustomFunction_487C31E1_OceanDepth_8, _CustomFunction_487C31E1_Foam_4, _CustomFunction_487C31E1_Shadow_5, _CustomFunction_487C31E1_Flow_6, _CustomFunction_487C31E1_SSS_17);
                Displacement_1 = _CustomFunction_487C31E1_Displacement_3;
                OceanWaterDepth_5 = _CustomFunction_487C31E1_OceanDepth_8;
                Foam_6 = _CustomFunction_487C31E1_Foam_4;
                Shadow_7 = _CustomFunction_487C31E1_Shadow_5;
                Flow_8 = _CustomFunction_487C31E1_Flow_6;
                SubSurfaceScattering_9 = _CustomFunction_487C31E1_SSS_17;
            }
            
            // 733e22c05b4f35356dd63172ccf21370
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeApplyCaustics.hlsl"
            
            void Unity_Negate_float3(float3 In, out float3 Out)
            {
                Out = -1 * In;
            }
            
            void Unity_Exponential_float3(float3 In, out float3 Out)
            {
                Out = exp(In);
            }
            
            void Unity_OneMinus_float3(float3 In, out float3 Out)
            {
                Out = 1 - In;
            }
            
            void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
            {
                Out = lerp(False, True, Predicate);
            }
            
            struct Bindings_CrestEmission_8c56460232fde1e46ae90d905a00f908
            {
            };
            
            void SG_CrestEmission_8c56460232fde1e46ae90d905a00f908(float Vector1_82EC3C0B, float3 Vector3_6C3F4D52, float3 Vector3_83F0ECB8, float3 Vector3_D6B78A76, float3 Vector3_703F2DD, float4 Vector4_5D0F731B, float Vector1_73B9F9E8, float3 Vector3_D4CABAFD, float Vector1_6C78E163, half3 Vector3_71E7580E, TEXTURE2D_PARAM(Texture2D_BA141407, samplerTexture2D_BA141407), float4 Texture2D_BA141407_TexelSize, half Vector1_460D9038, half Vector1_D5CE42D3, half Vector1_AC9C2A2, half Vector1_8DBC6E14, half Vector1_EA8F2BEC, TEXTURE2D_PARAM(Texture2D_AC91C4C3, samplerTexture2D_AC91C4C3), float4 Texture2D_AC91C4C3_TexelSize, half Vector1_DB8E128A, half Vector1_CFFD6A53, float3 Vector3_32FB76B3, Bindings_CrestEmission_8c56460232fde1e46ae90d905a00f908 IN, out float3 EmittedLight_1)
            {
                float Boolean_6AA51A5 = 0;
                float _Property_101786D0_Out_0 = Vector1_82EC3C0B;
                float3 _Property_833375DE_Out_0 = Vector3_83F0ECB8;
                float3 _Property_83DC9AD9_Out_0 = Vector3_703F2DD;
                float4 _Property_83CEC55B_Out_0 = Vector4_5D0F731B;
                float _Property_37502285_Out_0 = Vector1_73B9F9E8;
                float3 _Property_5935620A_Out_0 = Vector3_D4CABAFD;
                float _Property_AF5C7A5F_Out_0 = Vector1_6C78E163;
                half3 _CustomFunction_F95A252D_SceneColour_5;
                half _CustomFunction_F95A252D_SceneDistance_9;
                half3 _CustomFunction_F95A252D_ScenePositionWS_10;
                CrestNodeSceneColour_half(_Property_101786D0_Out_0, _Property_833375DE_Out_0, _Property_83DC9AD9_Out_0, _Property_83CEC55B_Out_0, _Property_37502285_Out_0, _Property_5935620A_Out_0, _Property_AF5C7A5F_Out_0, _CustomFunction_F95A252D_SceneColour_5, _CustomFunction_F95A252D_SceneDistance_9, _CustomFunction_F95A252D_ScenePositionWS_10);
                half _Split_550754E3_R_1 = _CustomFunction_F95A252D_ScenePositionWS_10[0];
                half _Split_550754E3_G_2 = _CustomFunction_F95A252D_ScenePositionWS_10[1];
                half _Split_550754E3_B_3 = _CustomFunction_F95A252D_ScenePositionWS_10[2];
                half _Split_550754E3_A_4 = 0;
                half2 _Vector2_B1CFC7F6_Out_0 = half2(_Split_550754E3_R_1, _Split_550754E3_B_3);
                Bindings_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d _CrestDrivenData_541C70CC;
                half _CrestDrivenData_541C70CC_MeshScaleAlpha_1;
                half _CrestDrivenData_541C70CC_LodDataTexelSize_8;
                half _CrestDrivenData_541C70CC_GeometryGridSize_2;
                half3 _CrestDrivenData_541C70CC_OceanPosScale0_3;
                half3 _CrestDrivenData_541C70CC_OceanPosScale1_4;
                half4 _CrestDrivenData_541C70CC_OceanParams0_5;
                half4 _CrestDrivenData_541C70CC_OceanParams1_6;
                half _CrestDrivenData_541C70CC_SliceIndex0_7;
                SG_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d(_CrestDrivenData_541C70CC, _CrestDrivenData_541C70CC_MeshScaleAlpha_1, _CrestDrivenData_541C70CC_LodDataTexelSize_8, _CrestDrivenData_541C70CC_GeometryGridSize_2, _CrestDrivenData_541C70CC_OceanPosScale0_3, _CrestDrivenData_541C70CC_OceanPosScale1_4, _CrestDrivenData_541C70CC_OceanParams0_5, _CrestDrivenData_541C70CC_OceanParams1_6, _CrestDrivenData_541C70CC_SliceIndex0_7);
                float _Add_87784A87_Out_2;
                Unity_Add_float(_CrestDrivenData_541C70CC_SliceIndex0_7, 1, _Add_87784A87_Out_2);
                Bindings_CrestSampleOceanDataSingle_a667f031fd6a3dd42beee0ccc432233d _CrestSampleOceanDataSingle_5C7B7E58;
                float3 _CrestSampleOceanDataSingle_5C7B7E58_Displacement_1;
                float _CrestSampleOceanDataSingle_5C7B7E58_OceanWaterDepth_5;
                float _CrestSampleOceanDataSingle_5C7B7E58_Foam_6;
                float2 _CrestSampleOceanDataSingle_5C7B7E58_Shadow_7;
                float2 _CrestSampleOceanDataSingle_5C7B7E58_Flow_8;
                float _CrestSampleOceanDataSingle_5C7B7E58_SubSurfaceScattering_9;
                SG_CrestSampleOceanDataSingle_a667f031fd6a3dd42beee0ccc432233d(_Vector2_B1CFC7F6_Out_0, _CrestDrivenData_541C70CC_OceanPosScale1_4, _CrestDrivenData_541C70CC_OceanParams1_6, _Add_87784A87_Out_2, _CrestSampleOceanDataSingle_5C7B7E58, _CrestSampleOceanDataSingle_5C7B7E58_Displacement_1, _CrestSampleOceanDataSingle_5C7B7E58_OceanWaterDepth_5, _CrestSampleOceanDataSingle_5C7B7E58_Foam_6, _CrestSampleOceanDataSingle_5C7B7E58_Shadow_7, _CrestSampleOceanDataSingle_5C7B7E58_Flow_8, _CrestSampleOceanDataSingle_5C7B7E58_SubSurfaceScattering_9);
                Bindings_CrestOceanGlobals_d50a85284893ec447a25a093505a2120 _CrestOceanGlobals_FCFEE3C8;
                float _CrestOceanGlobals_FCFEE3C8_CrestTime_1;
                float _CrestOceanGlobals_FCFEE3C8_TexelsPerWave_2;
                float3 _CrestOceanGlobals_FCFEE3C8_OceanCenterPosWorld_3;
                float _CrestOceanGlobals_FCFEE3C8_SliceCount_4;
                float _CrestOceanGlobals_FCFEE3C8_MeshScaleLerp_5;
                SG_CrestOceanGlobals_d50a85284893ec447a25a093505a2120(_CrestOceanGlobals_FCFEE3C8, _CrestOceanGlobals_FCFEE3C8_CrestTime_1, _CrestOceanGlobals_FCFEE3C8_TexelsPerWave_2, _CrestOceanGlobals_FCFEE3C8_OceanCenterPosWorld_3, _CrestOceanGlobals_FCFEE3C8_SliceCount_4, _CrestOceanGlobals_FCFEE3C8_MeshScaleLerp_5);
                float3 _Add_13827433_Out_2;
                Unity_Add_float3(_CrestSampleOceanDataSingle_5C7B7E58_Displacement_1, _CrestOceanGlobals_FCFEE3C8_OceanCenterPosWorld_3, _Add_13827433_Out_2);
                float _Split_8D03CDFB_R_1 = _Add_13827433_Out_2[0];
                float _Split_8D03CDFB_G_2 = _Add_13827433_Out_2[1];
                float _Split_8D03CDFB_B_3 = _Add_13827433_Out_2[2];
                float _Split_8D03CDFB_A_4 = 0;
                half3 _Property_513534C6_Out_0 = Vector3_71E7580E;
                half _Property_EF9152A2_Out_0 = Vector1_460D9038;
                half _Property_3D2898B2_Out_0 = Vector1_D5CE42D3;
                half _Property_35078BD5_Out_0 = Vector1_AC9C2A2;
                half _Property_1B866598_Out_0 = Vector1_8DBC6E14;
                half _Property_2016136C_Out_0 = Vector1_EA8F2BEC;
                half _Property_A64ADC3_Out_0 = Vector1_DB8E128A;
                half _Property_DDF09C09_Out_0 = Vector1_CFFD6A53;
                float3 _CustomFunction_2F6A103B_SceneColourOut_8;
                CrestNodeApplyCaustics_float(_CustomFunction_F95A252D_SceneColour_5, _CustomFunction_F95A252D_ScenePositionWS_10, _Split_8D03CDFB_G_2, _Property_513534C6_Out_0, _CustomFunction_F95A252D_SceneDistance_9, Texture2D_BA141407, _Property_EF9152A2_Out_0, _Property_3D2898B2_Out_0, _Property_35078BD5_Out_0, _Property_1B866598_Out_0, _Property_2016136C_Out_0, Texture2D_AC91C4C3, _Property_A64ADC3_Out_0, _Property_DDF09C09_Out_0, _CustomFunction_2F6A103B_SceneColourOut_8);
                #if defined(CREST_CAUSTICS_ON)
                float3 _CAUSTICS_6D445714_Out_0 = _CustomFunction_2F6A103B_SceneColourOut_8;
                #else
                float3 _CAUSTICS_6D445714_Out_0 = _CustomFunction_F95A252D_SceneColour_5;
                #endif
                float3 _Property_78DFA568_Out_0 = Vector3_83F0ECB8;
                float3 _Property_54BACED9_Out_0 = Vector3_32FB76B3;
                float3 _Add_954C4741_Out_2;
                Unity_Add_float3(_Property_78DFA568_Out_0, _Property_54BACED9_Out_0, _Add_954C4741_Out_2);
                float3 _Property_D76B9A0B_Out_0 = Vector3_6C3F4D52;
                float3 _Multiply_C51E63DE_Out_2;
                Unity_Multiply_float((_CustomFunction_F95A252D_SceneDistance_9.xxx), _Property_D76B9A0B_Out_0, _Multiply_C51E63DE_Out_2);
                float3 _Negate_ADFF8761_Out_1;
                Unity_Negate_float3(_Multiply_C51E63DE_Out_2, _Negate_ADFF8761_Out_1);
                float3 _Exponential_6FCB9AC3_Out_1;
                Unity_Exponential_float3(_Negate_ADFF8761_Out_1, _Exponential_6FCB9AC3_Out_1);
                float3 _OneMinus_9962618_Out_1;
                Unity_OneMinus_float3(_Exponential_6FCB9AC3_Out_1, _OneMinus_9962618_Out_1);
                float3 _Lerp_E9270AE8_Out_3;
                Unity_Lerp_float3(_CAUSTICS_6D445714_Out_0, _Add_954C4741_Out_2, _OneMinus_9962618_Out_1, _Lerp_E9270AE8_Out_3);
                float3 _Branch_2D3EE3D3_Out_3;
                Unity_Branch_float3(1, _Lerp_E9270AE8_Out_3, _CAUSTICS_6D445714_Out_0, _Branch_2D3EE3D3_Out_3);
                float3 _Branch_D043DFC1_Out_3;
                Unity_Branch_float3(Boolean_6AA51A5, _CAUSTICS_6D445714_Out_0, _Branch_2D3EE3D3_Out_3, _Branch_D043DFC1_Out_3);
                EmittedLight_1 = _Branch_D043DFC1_Out_3;
            }
            
            void Unity_Divide_float(float A, float B, out float Out)
            {
                Out = A / B;
            }
            
            void Unity_Power_float(float A, float B, out float Out)
            {
                Out = pow(A, B);
            }
            
            // 97e077ca2652cbf427809ae775e45d5a
            #include "Assets/Crest/Crest/Shaders/ShadergraphFramework/CrestNodeFoam.hlsl"
            
            struct Bindings_CrestFoamWithFlow_3a6c22dceac0847a2a31cb05a577b963
            {
            };
            
            void SG_CrestFoamWithFlow_3a6c22dceac0847a2a31cb05a577b963(TEXTURE2D_PARAM(Texture2D_D9E7A343, samplerTexture2D_D9E7A343), float4 Texture2D_D9E7A343_TexelSize, float2 Vector2_C4E9ED58, float Vector1_7492C815, float Vector1_33DC93D, float Vector1_3439FC0A, float Vector1_FB133018, float Vector1_7CFAFAC1, float Vector1_53F45327, float4 Vector4_2FA9AEA5, float4 Vector4_FD283A50, float Vector1_D6DA4100, float Vector1_13F2A8C8, float2 Vector2_28A2C5B9, float3 Vector3_3AD012AA, float3 Vector3_E4AC4432, float Vector1_3E452608, float2 Vector2_5AD72ED, Bindings_CrestFoamWithFlow_3a6c22dceac0847a2a31cb05a577b963 IN, out float3 Albedo_1, out float3 NormalTS_2, out float3 Emission_3, out float Smoothness_4)
            {
                float2 _Property_B71BFD9B_Out_0 = Vector2_C4E9ED58;
                float _Property_7C437CB0_Out_0 = Vector1_7492C815;
                float _Property_BD5882DA_Out_0 = Vector1_33DC93D;
                float _Property_3EF95B2A_Out_0 = Vector1_3439FC0A;
                float _Property_38B853C9_Out_0 = Vector1_FB133018;
                float _Property_8F25A4DF_Out_0 = Vector1_7CFAFAC1;
                float _Property_561CFE5E_Out_0 = Vector1_53F45327;
                float4 _Property_A1E249A2_Out_0 = Vector4_2FA9AEA5;
                float4 _Property_9A7BA0BB_Out_0 = Vector4_FD283A50;
                float _Property_4C4E1C83_Out_0 = Vector1_D6DA4100;
                float _Property_D81DA51E_Out_0 = Vector1_13F2A8C8;
                float2 _Property_4BF1D6EA_Out_0 = Vector2_5AD72ED;
                float2 _Property_DEC66EB9_Out_0 = Vector2_28A2C5B9;
                Bindings_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1 _CrestFlow_B4596B;
                float2 _CrestFlow_B4596B_DisplacedA_1;
                float _CrestFlow_B4596B_WeightA_3;
                float2 _CrestFlow_B4596B_DisplacedB_2;
                float _CrestFlow_B4596B_WeightB_4;
                SG_CrestFlow_f9c7f2c7774dd4b5bad87d6a350b47f1(_Property_4BF1D6EA_Out_0, _Property_DEC66EB9_Out_0, _CrestFlow_B4596B, _CrestFlow_B4596B_DisplacedA_1, _CrestFlow_B4596B_WeightA_3, _CrestFlow_B4596B_DisplacedB_2, _CrestFlow_B4596B_WeightB_4);
                float3 _Property_EB1DCAFB_Out_0 = Vector3_3AD012AA;
                float3 _Property_A2BD94BA_Out_0 = Vector3_E4AC4432;
                float _Property_7BFA2B51_Out_0 = Vector1_3E452608;
                half3 _CustomFunction_2B0D0960_Albedo_8;
                half3 _CustomFunction_2B0D0960_NormalTS_7;
                half3 _CustomFunction_2B0D0960_Emission_9;
                half _CustomFunction_2B0D0960_Smoothness_10;
                CrestNodeFoam_half(Texture2D_D9E7A343, _Property_B71BFD9B_Out_0, _Property_7C437CB0_Out_0, _Property_BD5882DA_Out_0, _Property_3EF95B2A_Out_0, _Property_38B853C9_Out_0, _Property_8F25A4DF_Out_0, _Property_561CFE5E_Out_0, _Property_A1E249A2_Out_0, _Property_9A7BA0BB_Out_0, _Property_4C4E1C83_Out_0, _Property_D81DA51E_Out_0, _CrestFlow_B4596B_DisplacedA_1, _Property_EB1DCAFB_Out_0, _Property_A2BD94BA_Out_0, _Property_7BFA2B51_Out_0, _CustomFunction_2B0D0960_Albedo_8, _CustomFunction_2B0D0960_NormalTS_7, _CustomFunction_2B0D0960_Emission_9, _CustomFunction_2B0D0960_Smoothness_10);
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_384819B4_Out_0 = _CustomFunction_2B0D0960_Albedo_8;
                #else
                float3 _FOAM_384819B4_Out_0 = float3(0, 0, 0);
                #endif
                float3 _Multiply_278EF57C_Out_2;
                Unity_Multiply_float(_FOAM_384819B4_Out_0, (_CrestFlow_B4596B_WeightA_3.xxx), _Multiply_278EF57C_Out_2);
                float2 _Property_6338038D_Out_0 = Vector2_C4E9ED58;
                float _Property_C8444C80_Out_0 = Vector1_7492C815;
                float _Property_3DF87814_Out_0 = Vector1_33DC93D;
                float _Property_589C4301_Out_0 = Vector1_3439FC0A;
                float _Property_E9D88423_Out_0 = Vector1_FB133018;
                float _Property_366CB823_Out_0 = Vector1_7CFAFAC1;
                float _Property_1F5469F5_Out_0 = Vector1_53F45327;
                float4 _Property_920AF23F_Out_0 = Vector4_2FA9AEA5;
                float4 _Property_37F6AC84_Out_0 = Vector4_FD283A50;
                float _Property_E7E25E74_Out_0 = Vector1_D6DA4100;
                float _Property_FA2913B0_Out_0 = Vector1_13F2A8C8;
                float3 _Property_4E6AF5FF_Out_0 = Vector3_3AD012AA;
                float3 _Property_A2DA52BE_Out_0 = Vector3_E4AC4432;
                float _Property_9DE15AC9_Out_0 = Vector1_3E452608;
                half3 _CustomFunction_16EDEEAC_Albedo_8;
                half3 _CustomFunction_16EDEEAC_NormalTS_7;
                half3 _CustomFunction_16EDEEAC_Emission_9;
                half _CustomFunction_16EDEEAC_Smoothness_10;
                CrestNodeFoam_half(Texture2D_D9E7A343, _Property_6338038D_Out_0, _Property_C8444C80_Out_0, _Property_3DF87814_Out_0, _Property_589C4301_Out_0, _Property_E9D88423_Out_0, _Property_366CB823_Out_0, _Property_1F5469F5_Out_0, _Property_920AF23F_Out_0, _Property_37F6AC84_Out_0, _Property_E7E25E74_Out_0, _Property_FA2913B0_Out_0, _CrestFlow_B4596B_DisplacedB_2, _Property_4E6AF5FF_Out_0, _Property_A2DA52BE_Out_0, _Property_9DE15AC9_Out_0, _CustomFunction_16EDEEAC_Albedo_8, _CustomFunction_16EDEEAC_NormalTS_7, _CustomFunction_16EDEEAC_Emission_9, _CustomFunction_16EDEEAC_Smoothness_10);
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_E9D68DEC_Out_0 = _CustomFunction_16EDEEAC_Albedo_8;
                #else
                float3 _FOAM_E9D68DEC_Out_0 = float3(0, 0, 0);
                #endif
                float3 _Multiply_BCF80692_Out_2;
                Unity_Multiply_float((_CrestFlow_B4596B_WeightB_4.xxx), _FOAM_E9D68DEC_Out_0, _Multiply_BCF80692_Out_2);
                float3 _Add_48FC5557_Out_2;
                Unity_Add_float3(_Multiply_278EF57C_Out_2, _Multiply_BCF80692_Out_2, _Add_48FC5557_Out_2);
                #if defined(CREST_FLOW_ON)
                float3 _FLOW_1260C700_Out_0 = _Add_48FC5557_Out_2;
                #else
                float3 _FLOW_1260C700_Out_0 = _FOAM_384819B4_Out_0;
                #endif
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_14E9F7C1_Out_0 = _CustomFunction_2B0D0960_NormalTS_7;
                #else
                float3 _FOAM_14E9F7C1_Out_0 = _Property_EB1DCAFB_Out_0;
                #endif
                float3 _Multiply_FAB0278F_Out_2;
                Unity_Multiply_float(_FOAM_14E9F7C1_Out_0, (_CrestFlow_B4596B_WeightA_3.xxx), _Multiply_FAB0278F_Out_2);
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_9C6E353_Out_0 = _CustomFunction_16EDEEAC_NormalTS_7;
                #else
                float3 _FOAM_9C6E353_Out_0 = _Property_4E6AF5FF_Out_0;
                #endif
                float3 _Multiply_CE1E9F74_Out_2;
                Unity_Multiply_float((_CrestFlow_B4596B_WeightB_4.xxx), _FOAM_9C6E353_Out_0, _Multiply_CE1E9F74_Out_2);
                float3 _Add_3A03EC0D_Out_2;
                Unity_Add_float3(_Multiply_FAB0278F_Out_2, _Multiply_CE1E9F74_Out_2, _Add_3A03EC0D_Out_2);
                #if defined(CREST_FLOW_ON)
                float3 _FLOW_2D8BA180_Out_0 = _Add_3A03EC0D_Out_2;
                #else
                float3 _FLOW_2D8BA180_Out_0 = _FOAM_14E9F7C1_Out_0;
                #endif
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_D8E821F0_Out_0 = _CustomFunction_2B0D0960_Emission_9;
                #else
                float3 _FOAM_D8E821F0_Out_0 = _Property_A2BD94BA_Out_0;
                #endif
                float3 _Multiply_716921DC_Out_2;
                Unity_Multiply_float(_FOAM_D8E821F0_Out_0, (_CrestFlow_B4596B_WeightA_3.xxx), _Multiply_716921DC_Out_2);
                #if defined(CREST_FOAM_ON)
                float3 _FOAM_9468CE46_Out_0 = _CustomFunction_16EDEEAC_Emission_9;
                #else
                float3 _FOAM_9468CE46_Out_0 = _Property_A2DA52BE_Out_0;
                #endif
                float3 _Multiply_A0DE696C_Out_2;
                Unity_Multiply_float((_CrestFlow_B4596B_WeightB_4.xxx), _FOAM_9468CE46_Out_0, _Multiply_A0DE696C_Out_2);
                float3 _Add_2EBEBFCF_Out_2;
                Unity_Add_float3(_Multiply_716921DC_Out_2, _Multiply_A0DE696C_Out_2, _Add_2EBEBFCF_Out_2);
                #if defined(CREST_FLOW_ON)
                float3 _FLOW_225158E3_Out_0 = _Add_2EBEBFCF_Out_2;
                #else
                float3 _FLOW_225158E3_Out_0 = _FOAM_D8E821F0_Out_0;
                #endif
                #if defined(CREST_FOAM_ON)
                float _FOAM_F0F633C_Out_0 = _CustomFunction_2B0D0960_Smoothness_10;
                #else
                float _FOAM_F0F633C_Out_0 = _Property_7BFA2B51_Out_0;
                #endif
                float _Multiply_C03E7AFC_Out_2;
                Unity_Multiply_float(_FOAM_F0F633C_Out_0, _CrestFlow_B4596B_WeightA_3, _Multiply_C03E7AFC_Out_2);
                #if defined(CREST_FOAM_ON)
                float _FOAM_AB9E199D_Out_0 = _CustomFunction_16EDEEAC_Smoothness_10;
                #else
                float _FOAM_AB9E199D_Out_0 = _Property_9DE15AC9_Out_0;
                #endif
                float _Multiply_8F8BE539_Out_2;
                Unity_Multiply_float(_CrestFlow_B4596B_WeightB_4, _FOAM_AB9E199D_Out_0, _Multiply_8F8BE539_Out_2);
                float _Add_7629FC1B_Out_2;
                Unity_Add_float(_Multiply_C03E7AFC_Out_2, _Multiply_8F8BE539_Out_2, _Add_7629FC1B_Out_2);
                #if defined(CREST_FLOW_ON)
                float _FLOW_386EA56_Out_0 = _Add_7629FC1B_Out_2;
                #else
                float _FLOW_386EA56_Out_0 = _FOAM_F0F633C_Out_0;
                #endif
                Albedo_1 = _FLOW_1260C700_Out_0;
                NormalTS_2 = _FLOW_2D8BA180_Out_0;
                Emission_3 = _FLOW_225158E3_Out_0;
                Smoothness_4 = _FLOW_386EA56_Out_0;
            }
            
            void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
            {
                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            }
            
            struct Bindings_CrestOceanPixel_6f6706d805d8e8649adddaaa94260269
            {
                float3 WorldSpaceViewDirection;
                float3 ViewSpacePosition;
                float3 AbsoluteWorldSpacePosition;
                float4 ScreenPosition;
                float FaceSign;
            };
            
            void SG_CrestOceanPixel_6f6706d805d8e8649adddaaa94260269(TEXTURE2D_PARAM(Texture2D_BE500045, samplerTexture2D_BE500045), float4 Texture2D_BE500045_TexelSize, float2 Vector2_2F51BFFE, float Vector1_1CEB35D8, float Vector1_43921196, float Vector1_E301593B, float Vector1_958E8942, float Vector1_2ED4C943, float Vector1_BF3AF964, float3 Vector3_EEEBAAB5, float Vector1_D3410E3, float Vector1_1EC1FE35, float2 Vector2_9C73A0C6, float Vector1_B01E1A6A, float Vector1_D74C6609, float Vector1_B61034CA, float2 Vector2_AE8873FA, float2 Vector2_69CC43DC, float Vector1_255AB964, float Vector1_47308CC2, float Vector1_26549044, float Vector1_177E111C, float Vector1_33255829, TEXTURE2D_PARAM(Texture2D_40AB1455, samplerTexture2D_40AB1455), float4 Texture2D_40AB1455_TexelSize, float Vector1_23A72EC7, float Vector1_F406EE17, float4 Vector4_2F6E352, float3 Vector3_57B74D6A, float4 Vector4_B3AD63B4, float Vector1_FA688590, float Vector1_9835666E, float Vector1_B331E24E, float Vector1_951CF2DF, float4 Vector4_ADCA8891, float Vector1_2E8E2C59, float Vector1_9BD9C342, float3 Vector3_8228B74C, float3 Vector3_B2D6AD84, float3 Vector3_D2C93D25, TEXTURE2D_PARAM(Texture2D_EB8C8549, samplerTexture2D_EB8C8549), float4 Texture2D_EB8C8549_TexelSize, float Vector1_9AE39B77, half Vector1_1B073674, float Vector1_C885385, float Vector1_90CEE6B8, float Vector1_E27586E2, TEXTURE2D_PARAM(Texture2D_DA8A756A, samplerTexture2D_DA8A756A), float4 Texture2D_DA8A756A_TexelSize, float Vector1_C96A6500, float Vector1_1AD36684, float Vector1_9E87174F, float Vector1_80D0DF9E, Bindings_CrestOceanPixel_6f6706d805d8e8649adddaaa94260269 IN, out float3 Albedo_2, out float3 NormalTS_3, out float3 Emission_4, out float Smoothness_5, out float Alpha_1, out float Specular_6)
            {
                float2 _Property_B9BA8901_Out_0 = Vector2_2F51BFFE;
                float _Property_6AEC3552_Out_0 = Vector1_1CEB35D8;
                float _Property_76EA797B_Out_0 = Vector1_43921196;
                float _Property_83C2E998_Out_0 = Vector1_E301593B;
                float _Property_705FD8D9_Out_0 = Vector1_958E8942;
                float _Property_735B5A53_Out_0 = Vector1_2ED4C943;
                float _Property_EB4C03CF_Out_0 = Vector1_BF3AF964;
                Bindings_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d _CrestDrivenData_6635D6E9;
                half _CrestDrivenData_6635D6E9_MeshScaleAlpha_1;
                half _CrestDrivenData_6635D6E9_LodDataTexelSize_8;
                half _CrestDrivenData_6635D6E9_GeometryGridSize_2;
                half3 _CrestDrivenData_6635D6E9_OceanPosScale0_3;
                half3 _CrestDrivenData_6635D6E9_OceanPosScale1_4;
                half4 _CrestDrivenData_6635D6E9_OceanParams0_5;
                half4 _CrestDrivenData_6635D6E9_OceanParams1_6;
                half _CrestDrivenData_6635D6E9_SliceIndex0_7;
                SG_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d(_CrestDrivenData_6635D6E9, _CrestDrivenData_6635D6E9_MeshScaleAlpha_1, _CrestDrivenData_6635D6E9_LodDataTexelSize_8, _CrestDrivenData_6635D6E9_GeometryGridSize_2, _CrestDrivenData_6635D6E9_OceanPosScale0_3, _CrestDrivenData_6635D6E9_OceanPosScale1_4, _CrestDrivenData_6635D6E9_OceanParams0_5, _CrestDrivenData_6635D6E9_OceanParams1_6, _CrestDrivenData_6635D6E9_SliceIndex0_7);
                float _Property_EE920C2C_Out_0 = Vector1_B61034CA;
                float _Property_8BC6F5AD_Out_0 = Vector1_B01E1A6A;
                float2 _Property_A2CEB215_Out_0 = Vector2_9C73A0C6;
                float _Property_A636CE7E_Out_0 = Vector1_23A72EC7;
                float _Property_C1531E4C_Out_0 = Vector1_F406EE17;
                float _Property_C7723E93_Out_0 = Vector1_B01E1A6A;
                float2 _Property_94C56295_Out_0 = Vector2_9C73A0C6;
                float2 _Property_E65AA85_Out_0 = Vector2_69CC43DC;
                float3 _Normalize_3574419A_Out_1;
                Unity_Normalize_float3(IN.WorldSpaceViewDirection, _Normalize_3574419A_Out_1);
                Bindings_CrestComputeNormal_61b9efc6612ab3b4f84174344af5e12a _CrestComputeNormal_6DAE4B39;
                _CrestComputeNormal_6DAE4B39.FaceSign = IN.FaceSign;
                half3 _CrestComputeNormal_6DAE4B39_Normal_1;
                SG_CrestComputeNormal_61b9efc6612ab3b4f84174344af5e12a(_CrestDrivenData_6635D6E9_OceanPosScale0_3, _CrestDrivenData_6635D6E9_OceanPosScale1_4, _CrestDrivenData_6635D6E9_OceanParams0_5, _CrestDrivenData_6635D6E9_OceanParams1_6, _CrestDrivenData_6635D6E9_SliceIndex0_7, TEXTURE2D_ARGS(Texture2D_40AB1455, samplerTexture2D_40AB1455), Texture2D_40AB1455_TexelSize, _Property_A636CE7E_Out_0, _Property_C1531E4C_Out_0, _Property_C7723E93_Out_0, _Property_94C56295_Out_0, _Property_E65AA85_Out_0, _Normalize_3574419A_Out_1, _CrestComputeNormal_6DAE4B39, _CrestComputeNormal_6DAE4B39_Normal_1);
                float _Property_FCAEBD15_Out_0 = Vector1_9E87174F;
                float _Property_2D376CE_Out_0 = Vector1_80D0DF9E;
                Bindings_CrestFresnel_c6f6c13c4fdb04e42b427e4c2610d3c9 _CrestFresnel_FD3200EB;
                _CrestFresnel_FD3200EB.FaceSign = IN.FaceSign;
                float _CrestFresnel_FD3200EB_LightTransmitted_1;
                float _CrestFresnel_FD3200EB_LightReflected_2;
                SG_CrestFresnel_c6f6c13c4fdb04e42b427e4c2610d3c9(_CrestComputeNormal_6DAE4B39_Normal_1, _Normalize_3574419A_Out_1, _Property_FCAEBD15_Out_0, _Property_2D376CE_Out_0, _CrestFresnel_FD3200EB, _CrestFresnel_FD3200EB_LightTransmitted_1, _CrestFresnel_FD3200EB_LightReflected_2);
                float _Property_2599690E_Out_0 = Vector1_9BD9C342;
                float3 _Property_A57CAD6E_Out_0 = Vector3_8228B74C;
                float4 _Property_479D2E13_Out_0 = Vector4_2F6E352;
                float3 _Property_F631E4E0_Out_0 = Vector3_57B74D6A;
                float4 _Property_D9155CD7_Out_0 = Vector4_B3AD63B4;
                float _Property_D8B923AB_Out_0 = Vector1_FA688590;
                float _Property_F7F4791A_Out_0 = Vector1_9835666E;
                float _Property_2ABF6C61_Out_0 = Vector1_B331E24E;
                float _Property_22A5FA38_Out_0 = Vector1_951CF2DF;
                float4 _Property_C1E8071C_Out_0 = Vector4_ADCA8891;
                float _Property_9AD6466F_Out_0 = Vector1_2E8E2C59;
                float _Property_4D8B881_Out_0 = Vector1_D74C6609;
                float2 _Property_5A879B44_Out_0 = Vector2_AE8873FA;
                float _Property_41C453D9_Out_0 = Vector1_255AB964;
                float3 _CustomFunction_C3448D1A_AmbientLighting_0;
                GetAmbientLighting_float(_CustomFunction_C3448D1A_AmbientLighting_0);
                float3 _Property_13E6764D_Out_0 = Vector3_B2D6AD84;
                float3 _Property_2FA7DB0_Out_0 = Vector3_D2C93D25;
                Bindings_CrestVolumeLighting_e9ed6e11710a50640bb4b811d0fa84f2 _CrestVolumeLighting_5A1A391;
                half3 _CrestVolumeLighting_5A1A391_VolumeLighting_1;
                SG_CrestVolumeLighting_e9ed6e11710a50640bb4b811d0fa84f2(_Property_479D2E13_Out_0, _Property_F631E4E0_Out_0, _Property_D9155CD7_Out_0, _Property_D8B923AB_Out_0, _Property_F7F4791A_Out_0, _Property_2ABF6C61_Out_0, _Property_22A5FA38_Out_0, _Property_C1E8071C_Out_0, _Property_9AD6466F_Out_0, _Property_4D8B881_Out_0, _Property_5A879B44_Out_0, _Property_41C453D9_Out_0, _Normalize_3574419A_Out_1, IN.AbsoluteWorldSpacePosition, _CustomFunction_C3448D1A_AmbientLighting_0, _Property_13E6764D_Out_0, _Property_2FA7DB0_Out_0, _CrestVolumeLighting_5A1A391, _CrestVolumeLighting_5A1A391_VolumeLighting_1);
                float4 _ScreenPosition_42FE0E3E_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                float _Split_66230827_R_1 = IN.ViewSpacePosition[0];
                float _Split_66230827_G_2 = IN.ViewSpacePosition[1];
                float _Split_66230827_B_3 = IN.ViewSpacePosition[2];
                float _Split_66230827_A_4 = 0;
                float _Negate_5F3C7D3D_Out_1;
                Unity_Negate_float(_Split_66230827_B_3, _Negate_5F3C7D3D_Out_1);
                float3 _SceneColor_61626E7C_Out_1;
                Unity_SceneColor_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneColor_61626E7C_Out_1);
                float _SceneDepth_FD35F7D9_Out_1;
                Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_FD35F7D9_Out_1);
                float3 _Property_DC1C088D_Out_0 = Vector3_B2D6AD84;
                float _Property_8BC39E79_Out_0 = Vector1_9AE39B77;
                half _Property_683CAF2_Out_0 = Vector1_1B073674;
                float _Property_B4B35559_Out_0 = Vector1_C885385;
                float _Property_E694F888_Out_0 = Vector1_90CEE6B8;
                float _Property_50A87698_Out_0 = Vector1_E27586E2;
                float _Property_8BC9D755_Out_0 = Vector1_C96A6500;
                float _Property_6F95DFBF_Out_0 = Vector1_1AD36684;
                float3 _Property_4729CD24_Out_0 = Vector3_EEEBAAB5;
                float _Property_C36E9B6_Out_0 = Vector1_D3410E3;
                float _Property_2C173F60_Out_0 = Vector1_1EC1FE35;
                float2 _Property_4258AA49_Out_0 = Vector2_2F51BFFE;
                float _Property_3FC34BC9_Out_0 = Vector1_1CEB35D8;
                float _Property_D42BE95B_Out_0 = Vector1_B61034CA;
                float _Split_CEEBC462_R_1 = IN.AbsoluteWorldSpacePosition[0];
                float _Split_CEEBC462_G_2 = IN.AbsoluteWorldSpacePosition[1];
                float _Split_CEEBC462_B_3 = IN.AbsoluteWorldSpacePosition[2];
                float _Split_CEEBC462_A_4 = 0;
                float2 _Vector2_BB7CEEF5_Out_0 = float2(_Split_CEEBC462_R_1, _Split_CEEBC462_B_3);
                float2 _Property_305FB73_Out_0 = Vector2_9C73A0C6;
                float _Property_88A7570_Out_0 = Vector1_B01E1A6A;
                float2 _Property_5CBA815_Out_0 = Vector2_69CC43DC;
                Bindings_CrestFoamBubblesWithFlow_e132fba35874b4923988ef35a40e48c3 _CrestFoamBubblesWithFlow_F7286BE2;
                float3 _CrestFoamBubblesWithFlow_F7286BE2_Colour_1;
                SG_CrestFoamBubblesWithFlow_e132fba35874b4923988ef35a40e48c3(_Property_4729CD24_Out_0, _Property_C36E9B6_Out_0, _Property_2C173F60_Out_0, TEXTURE2D_ARGS(Texture2D_BE500045, samplerTexture2D_BE500045), Texture2D_BE500045_TexelSize, _Property_4258AA49_Out_0, _Property_3FC34BC9_Out_0, _Property_D42BE95B_Out_0, _CrestComputeNormal_6DAE4B39_Normal_1, _CrestDrivenData_6635D6E9_OceanParams0_5, _CrestDrivenData_6635D6E9_OceanParams1_6, _Vector2_BB7CEEF5_Out_0, _Property_305FB73_Out_0, _Property_88A7570_Out_0, _Normalize_3574419A_Out_1, _Property_5CBA815_Out_0, _CrestFoamBubblesWithFlow_F7286BE2, _CrestFoamBubblesWithFlow_F7286BE2_Colour_1);
                Bindings_CrestEmission_8c56460232fde1e46ae90d905a00f908 _CrestEmission_6580C0F9;
                float3 _CrestEmission_6580C0F9_EmittedLight_1;
                SG_CrestEmission_8c56460232fde1e46ae90d905a00f908(_Property_2599690E_Out_0, _Property_A57CAD6E_Out_0, _CrestVolumeLighting_5A1A391_VolumeLighting_1, _Normalize_3574419A_Out_1, _CrestComputeNormal_6DAE4B39_Normal_1, _ScreenPosition_42FE0E3E_Out_0, _Negate_5F3C7D3D_Out_1, _SceneColor_61626E7C_Out_1, _SceneDepth_FD35F7D9_Out_1, _Property_DC1C088D_Out_0, TEXTURE2D_ARGS(Texture2D_EB8C8549, samplerTexture2D_EB8C8549), Texture2D_EB8C8549_TexelSize, _Property_8BC39E79_Out_0, _Property_683CAF2_Out_0, _Property_B4B35559_Out_0, _Property_E694F888_Out_0, _Property_50A87698_Out_0, TEXTURE2D_ARGS(Texture2D_DA8A756A, samplerTexture2D_DA8A756A), Texture2D_DA8A756A_TexelSize, _Property_8BC9D755_Out_0, _Property_6F95DFBF_Out_0, _CrestFoamBubblesWithFlow_F7286BE2_Colour_1, _CrestEmission_6580C0F9, _CrestEmission_6580C0F9_EmittedLight_1);
                float3 _Multiply_CFF25F4B_Out_2;
                Unity_Multiply_float((_CrestFresnel_FD3200EB_LightTransmitted_1.xxx), _CrestEmission_6580C0F9_EmittedLight_1, _Multiply_CFF25F4B_Out_2);
                float _Property_5DA83C2A_Out_0 = Vector1_47308CC2;
                float _Property_44533AA4_Out_0 = Vector1_26549044;
                float _Property_19CC00AB_Out_0 = Vector1_177E111C;
                float _Divide_6B6C7F25_Out_2;
                Unity_Divide_float(_Negate_5F3C7D3D_Out_1, _Property_19CC00AB_Out_0, _Divide_6B6C7F25_Out_2);
                float _Saturate_D69CDED6_Out_1;
                Unity_Saturate_float(_Divide_6B6C7F25_Out_2, _Saturate_D69CDED6_Out_1);
                float _Property_8033277F_Out_0 = Vector1_33255829;
                float _Power_BC121A67_Out_2;
                Unity_Power_float(_Saturate_D69CDED6_Out_1, _Property_8033277F_Out_0, _Power_BC121A67_Out_2);
                float _Lerp_3E7590A8_Out_3;
                Unity_Lerp_float(_Property_5DA83C2A_Out_0, _Property_44533AA4_Out_0, _Power_BC121A67_Out_2, _Lerp_3E7590A8_Out_3);
                float2 _Property_374C5B7E_Out_0 = Vector2_69CC43DC;
                Bindings_CrestFoamWithFlow_3a6c22dceac0847a2a31cb05a577b963 _CrestFoamWithFlow_193F69CA;
                float3 _CrestFoamWithFlow_193F69CA_Albedo_1;
                float3 _CrestFoamWithFlow_193F69CA_NormalTS_2;
                float3 _CrestFoamWithFlow_193F69CA_Emission_3;
                float _CrestFoamWithFlow_193F69CA_Smoothness_4;
                SG_CrestFoamWithFlow_3a6c22dceac0847a2a31cb05a577b963(TEXTURE2D_ARGS(Texture2D_BE500045, samplerTexture2D_BE500045), Texture2D_BE500045_TexelSize, _Property_B9BA8901_Out_0, _Property_6AEC3552_Out_0, _Property_76EA797B_Out_0, _Property_83C2E998_Out_0, _Property_705FD8D9_Out_0, _Property_735B5A53_Out_0, _Property_EB4C03CF_Out_0, _CrestDrivenData_6635D6E9_OceanParams0_5, _CrestDrivenData_6635D6E9_OceanParams1_6, _Property_EE920C2C_Out_0, _Property_8BC6F5AD_Out_0, _Property_A2CEB215_Out_0, _CrestComputeNormal_6DAE4B39_Normal_1, _Multiply_CFF25F4B_Out_2, _Lerp_3E7590A8_Out_3, _Property_374C5B7E_Out_0, _CrestFoamWithFlow_193F69CA, _CrestFoamWithFlow_193F69CA_Albedo_1, _CrestFoamWithFlow_193F69CA_NormalTS_2, _CrestFoamWithFlow_193F69CA_Emission_3, _CrestFoamWithFlow_193F69CA_Smoothness_4);
                float _Subtract_5BDB5822_Out_2;
                Unity_Subtract_float(_SceneDepth_FD35F7D9_Out_1, _Negate_5F3C7D3D_Out_1, _Subtract_5BDB5822_Out_2);
                float _Remap_D52CFDA9_Out_3;
                Unity_Remap_float(_Subtract_5BDB5822_Out_2, float2 (0, 0.2), float2 (0, 1), _Remap_D52CFDA9_Out_3);
                float _Saturate_896FB384_Out_1;
                Unity_Saturate_float(_Remap_D52CFDA9_Out_3, _Saturate_896FB384_Out_1);
                Albedo_2 = _CrestFoamWithFlow_193F69CA_Albedo_1;
                NormalTS_3 = _CrestFoamWithFlow_193F69CA_NormalTS_2;
                Emission_4 = _CrestFoamWithFlow_193F69CA_Emission_3;
                Smoothness_5 = _CrestFoamWithFlow_193F69CA_Smoothness_4;
                Alpha_1 = _Saturate_896FB384_Out_1;
                Specular_6 = _CrestFresnel_FD3200EB_LightReflected_2;
            }
        
            // Graph Vertex
            struct VertexDescriptionInputs
            {
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 WorldSpaceNormal;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 WorldSpaceTangent;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 ObjectSpaceBiTangent;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 WorldSpaceBiTangent;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 AbsoluteWorldSpacePosition;
                #endif
            };
            
            struct VertexDescription
            {
                float3 VertexPosition;
                float3 VertexNormal;
                float3 VertexTangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                Bindings_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d _CrestDrivenData_A1078169;
                half _CrestDrivenData_A1078169_MeshScaleAlpha_1;
                half _CrestDrivenData_A1078169_LodDataTexelSize_8;
                half _CrestDrivenData_A1078169_GeometryGridSize_2;
                half3 _CrestDrivenData_A1078169_OceanPosScale0_3;
                half3 _CrestDrivenData_A1078169_OceanPosScale1_4;
                half4 _CrestDrivenData_A1078169_OceanParams0_5;
                half4 _CrestDrivenData_A1078169_OceanParams1_6;
                half _CrestDrivenData_A1078169_SliceIndex0_7;
                SG_CrestDrivenData_40572ccadf7d9704a83d283fb4c9f19d(_CrestDrivenData_A1078169, _CrestDrivenData_A1078169_MeshScaleAlpha_1, _CrestDrivenData_A1078169_LodDataTexelSize_8, _CrestDrivenData_A1078169_GeometryGridSize_2, _CrestDrivenData_A1078169_OceanPosScale0_3, _CrestDrivenData_A1078169_OceanPosScale1_4, _CrestDrivenData_A1078169_OceanParams0_5, _CrestDrivenData_A1078169_OceanParams1_6, _CrestDrivenData_A1078169_SliceIndex0_7);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                Bindings_CrestGeoMorph_9ab91ec3462438049923ca0ff16f68ad _CrestGeoMorph_8F1A4FF1;
                half3 _CrestGeoMorph_8F1A4FF1_MorphedPositionWS_1;
                half _CrestGeoMorph_8F1A4FF1_LodAlpha_2;
                SG_CrestGeoMorph_9ab91ec3462438049923ca0ff16f68ad(IN.AbsoluteWorldSpacePosition, _CrestDrivenData_A1078169_OceanPosScale0_3, _CrestDrivenData_A1078169_MeshScaleAlpha_1, _CrestDrivenData_A1078169_GeometryGridSize_2, _CrestGeoMorph_8F1A4FF1, _CrestGeoMorph_8F1A4FF1_MorphedPositionWS_1, _CrestGeoMorph_8F1A4FF1_LodAlpha_2);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Split_CC063A43_R_1 = _CrestGeoMorph_8F1A4FF1_MorphedPositionWS_1[0];
                float _Split_CC063A43_G_2 = _CrestGeoMorph_8F1A4FF1_MorphedPositionWS_1[1];
                float _Split_CC063A43_B_3 = _CrestGeoMorph_8F1A4FF1_MorphedPositionWS_1[2];
                float _Split_CC063A43_A_4 = 0;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float2 _Vector2_2D46FD43_Out_0 = float2(_Split_CC063A43_R_1, _Split_CC063A43_B_3);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                Bindings_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4 _CrestSampleOceanData_340A6610;
                float3 _CrestSampleOceanData_340A6610_Displacement_1;
                float _CrestSampleOceanData_340A6610_OceanWaterDepth_5;
                float _CrestSampleOceanData_340A6610_Foam_6;
                float2 _CrestSampleOceanData_340A6610_Shadow_7;
                float2 _CrestSampleOceanData_340A6610_Flow_8;
                float _CrestSampleOceanData_340A6610_SubSurfaceScattering_9;
                SG_CrestSampleOceanData_f19d6d2aa60f8294e870f100303ee5a4(_Vector2_2D46FD43_Out_0, _CrestGeoMorph_8F1A4FF1_LodAlpha_2, _CrestDrivenData_A1078169_OceanPosScale0_3, _CrestDrivenData_A1078169_OceanPosScale1_4, _CrestDrivenData_A1078169_OceanParams0_5, _CrestDrivenData_A1078169_OceanParams1_6, _CrestDrivenData_A1078169_SliceIndex0_7, _CrestSampleOceanData_340A6610, _CrestSampleOceanData_340A6610_Displacement_1, _CrestSampleOceanData_340A6610_OceanWaterDepth_5, _CrestSampleOceanData_340A6610_Foam_6, _CrestSampleOceanData_340A6610_Shadow_7, _CrestSampleOceanData_340A6610_Flow_8, _CrestSampleOceanData_340A6610_SubSurfaceScattering_9);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 _Add_2D79A354_Out_2;
                Unity_Add_float3(_CrestGeoMorph_8F1A4FF1_MorphedPositionWS_1, _CrestSampleOceanData_340A6610_Displacement_1, _Add_2D79A354_Out_2);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 _Transform_9C2ACF28_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Add_2D79A354_Out_2.xyz));
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 _Transform_86205EE4_Out_1 = TransformWorldToObjectDir(float3 (0, 1, 0).xyz);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 _Transform_22BD1A85_Out_1 = TransformWorldToObjectDir(GetCameraRelativePositionWS(float3 (1, 0, 0).xyz));
                #endif
                description.VertexPosition = _Transform_9C2ACF28_Out_1;
                description.VertexNormal = _Transform_86205EE4_Out_1;
                description.VertexTangent = _Transform_22BD1A85_Out_1;
                return description;
            }
            
            // Graph Pixel
            struct SurfaceDescriptionInputs
            {
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 WorldSpaceViewDirection;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 ViewSpacePosition;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 WorldSpacePosition;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 AbsoluteWorldSpacePosition;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 ScreenPosition;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv0;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv1;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv2;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv3;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float FaceSign;
                #endif
            };
            
            struct SurfaceDescription
            {
                float3 Albedo;
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _TexelSize_CA3A0DD6_Width_0 = _TextureFoam_TexelSize.z;
                half _TexelSize_CA3A0DD6_Height_2 = _TextureFoam_TexelSize.w;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half2 _Vector2_15E252FB_Out_0 = half2(_TexelSize_CA3A0DD6_Width_0, _TexelSize_CA3A0DD6_Height_2);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_87E9391A_Out_0 = _FoamScale;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_BC30BCB6_Out_0 = _FoamFeather;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_5E8CB038_Out_0 = _FoamIntensityAlbedo;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_77A524C7_Out_0 = _FoamIntensityEmissive;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_CED296A4_Out_0 = _FoamSmoothness;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_D1CA3C84_Out_0 = _FoamNormalStrength;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half4 _Property_3BAB5FF_Out_0 = _FoamBubbleColor;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_EDC4DC3C_Out_0 = _FoamBubbleParallax;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_E7925FBA_Out_0 = _FoamBubblesCoverage;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                Bindings_CrestUnpackData_5bc4cf08f88035c489658d60edefeec8 _CrestUnpackData_C3998C1C;
                _CrestUnpackData_C3998C1C.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
                _CrestUnpackData_C3998C1C.uv0 = IN.uv0;
                _CrestUnpackData_C3998C1C.uv1 = IN.uv1;
                _CrestUnpackData_C3998C1C.uv2 = IN.uv2;
                float2 _CrestUnpackData_C3998C1C_PositionXZWSUndisp_2;
                float _CrestUnpackData_C3998C1C_LodAlpha_1;
                float _CrestUnpackData_C3998C1C_OceanDepth_3;
                float _CrestUnpackData_C3998C1C_Foam_4;
                float2 _CrestUnpackData_C3998C1C_Shadow_5;
                float2 _CrestUnpackData_C3998C1C_Flow_6;
                float _CrestUnpackData_C3998C1C_SubSurfaceScattering_7;
                SG_CrestUnpackData_5bc4cf08f88035c489658d60edefeec8(_CrestUnpackData_C3998C1C, _CrestUnpackData_C3998C1C_PositionXZWSUndisp_2, _CrestUnpackData_C3998C1C_LodAlpha_1, _CrestUnpackData_C3998C1C_OceanDepth_3, _CrestUnpackData_C3998C1C_Foam_4, _CrestUnpackData_C3998C1C_Shadow_5, _CrestUnpackData_C3998C1C_Flow_6, _CrestUnpackData_C3998C1C_SubSurfaceScattering_7);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_994CB3A3_Out_0 = _Smoothness;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_7079FD32_Out_0 = _SmoothnessFar;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_FAEF961B_Out_0 = _SmoothnessFarDistance;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_35DA1E70_Out_0 = _SmoothnessFalloff;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_D1430252_Out_0 = _NormalsScale;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_B882DB1E_Out_0 = _NormalsStrength;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half4 _Property_B5E474DF_Out_0 = _ScatterColourBase;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 _Property_B98AE6FA_Out_0 = _ScatterColourShallow;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_CF7CEF3A_Out_0 = _ScatterColourShallowDepthMax;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_698A3C81_Out_0 = _ScatterColourShallowDepthFalloff;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_5924F1E9_Out_0 = _SSSIntensityBase;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_67308B5F_Out_0 = _SSSIntensitySun;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half4 _Property_A723E757_Out_0 = _SSSTint;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_5AD6818A_Out_0 = _SSSSunFalloff;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half _Property_888FA49_Out_0 = _RefractionStrength;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                half3 _Property_F1315B19_Out_0 = _DepthFogDensity;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                Bindings_CrestLightData_b74b6e8c0b489314ca7aea3e2cc9c54c _CrestLightData_5AD806DD;
                half3 _CrestLightData_5AD806DD_Direction_1;
                half3 _CrestLightData_5AD806DD_Intensity_2;
                SG_CrestLightData_b74b6e8c0b489314ca7aea3e2cc9c54c(_CrestLightData_5AD806DD, _CrestLightData_5AD806DD_Direction_1, _CrestLightData_5AD806DD_Intensity_2);
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_A26763AB_Out_0 = _CausticsTextureScale;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_3230CB90_Out_0 = _CausticsTextureAverage;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_6B2F7D3E_Out_0 = _CausticsStrength;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_D5C90779_Out_0 = _CausticsFocalDepth;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_2743B36F_Out_0 = _CausticsDepthOfField;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_61877218_Out_0 = _CausticsDistortionStrength;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float _Property_5F1E3794_Out_0 = _CausticsDistortionScale;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                Bindings_CrestOceanPixel_6f6706d805d8e8649adddaaa94260269 _CrestOceanPixel_51593A7C;
                _CrestOceanPixel_51593A7C.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
                _CrestOceanPixel_51593A7C.ViewSpacePosition = IN.ViewSpacePosition;
                _CrestOceanPixel_51593A7C.AbsoluteWorldSpacePosition = IN.AbsoluteWorldSpacePosition;
                _CrestOceanPixel_51593A7C.ScreenPosition = IN.ScreenPosition;
                _CrestOceanPixel_51593A7C.FaceSign = IN.FaceSign;
                float3 _CrestOceanPixel_51593A7C_Albedo_2;
                float3 _CrestOceanPixel_51593A7C_NormalTS_3;
                float3 _CrestOceanPixel_51593A7C_Emission_4;
                float _CrestOceanPixel_51593A7C_Smoothness_5;
                float _CrestOceanPixel_51593A7C_Alpha_1;
                float _CrestOceanPixel_51593A7C_Specular_6;
                SG_CrestOceanPixel_6f6706d805d8e8649adddaaa94260269(TEXTURE2D_ARGS(_TextureFoam, sampler_TextureFoam), _TextureFoam_TexelSize, _Vector2_15E252FB_Out_0, _Property_87E9391A_Out_0, _Property_BC30BCB6_Out_0, _Property_5E8CB038_Out_0, _Property_77A524C7_Out_0, _Property_CED296A4_Out_0, _Property_D1CA3C84_Out_0, (_Property_3BAB5FF_Out_0.xyz), _Property_EDC4DC3C_Out_0, _Property_E7925FBA_Out_0, _CrestUnpackData_C3998C1C_PositionXZWSUndisp_2, _CrestUnpackData_C3998C1C_LodAlpha_1, _CrestUnpackData_C3998C1C_OceanDepth_3, _CrestUnpackData_C3998C1C_Foam_4, _CrestUnpackData_C3998C1C_Shadow_5, _CrestUnpackData_C3998C1C_Flow_6, _CrestUnpackData_C3998C1C_SubSurfaceScattering_7, _Property_994CB3A3_Out_0, _Property_7079FD32_Out_0, _Property_FAEF961B_Out_0, _Property_35DA1E70_Out_0, TEXTURE2D_ARGS(_TextureNormals, sampler_TextureNormals), _TextureNormals_TexelSize, _Property_D1430252_Out_0, _Property_B882DB1E_Out_0, _Property_B5E474DF_Out_0, float3 (0, 0, 0), _Property_B98AE6FA_Out_0, _Property_CF7CEF3A_Out_0, _Property_698A3C81_Out_0, _Property_5924F1E9_Out_0, _Property_67308B5F_Out_0, _Property_A723E757_Out_0, _Property_5AD6818A_Out_0, _Property_888FA49_Out_0, _Property_F1315B19_Out_0, _CrestLightData_5AD806DD_Direction_1, _CrestLightData_5AD806DD_Intensity_2, TEXTURE2D_ARGS(_CausticsTexture, sampler_CausticsTexture), _CausticsTexture_TexelSize, _Property_A26763AB_Out_0, _Property_3230CB90_Out_0, _Property_6B2F7D3E_Out_0, _Property_D5C90779_Out_0, _Property_2743B36F_Out_0, TEXTURE2D_ARGS(_CausticsDistortionTexture, sampler_CausticsDistortionTexture), _CausticsDistortionTexture_TexelSize, _Property_61877218_Out_0, _Property_5F1E3794_Out_0, 1.33, 1, _CrestOceanPixel_51593A7C, _CrestOceanPixel_51593A7C_Albedo_2, _CrestOceanPixel_51593A7C_NormalTS_3, _CrestOceanPixel_51593A7C_Emission_4, _CrestOceanPixel_51593A7C_Smoothness_5, _CrestOceanPixel_51593A7C_Alpha_1, _CrestOceanPixel_51593A7C_Specular_6);
                #endif
                surface.Albedo = _CrestOceanPixel_51593A7C_Albedo_2;
                surface.Alpha = _CrestOceanPixel_51593A7C_Alpha_1;
                surface.AlphaClipThreshold = 0;
                return surface;
            }
        
            // --------------------------------------------------
            // Structs and Packing
        
            // Generated Type: Attributes
            struct Attributes
            {
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 positionOS : POSITION;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 normalOS : NORMAL;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 tangentOS : TANGENT;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv0 : TEXCOORD0;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv1 : TEXCOORD1;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv2 : TEXCOORD2;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 uv3 : TEXCOORD3;
                #endif
                #if UNITY_ANY_INSTANCING_ENABLED
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                uint instanceID : INSTANCEID_SEMANTIC;
                #endif
                #endif
            };
        
            // Generated Type: Varyings
            struct Varyings
            {
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 positionCS : SV_Position;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 positionWS;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 texCoord0;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 texCoord1;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 texCoord2;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float4 texCoord3;
                #endif
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                float3 viewDirectionWS;
                #endif
                #if UNITY_ANY_INSTANCING_ENABLED
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #endif
            };
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            // Generated Type: PackedVaryings
            struct PackedVaryings
            {
                float4 positionCS : SV_Position;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                float3 interp00 : TEXCOORD0;
                float4 interp01 : TEXCOORD1;
                float4 interp02 : TEXCOORD2;
                float4 interp03 : TEXCOORD3;
                float4 interp04 : TEXCOORD4;
                float3 interp05 : TEXCOORD5;
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Packed Type: Varyings
            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output;
                output.positionCS = input.positionCS;
                output.interp00.xyz = input.positionWS;
                output.interp01.xyzw = input.texCoord0;
                output.interp02.xyzw = input.texCoord1;
                output.interp03.xyzw = input.texCoord2;
                output.interp04.xyzw = input.texCoord3;
                output.interp05.xyz = input.viewDirectionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                return output;
            }
            
            // Unpacked Type: Varyings
            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.positionWS = input.interp00.xyz;
                output.texCoord0 = input.interp01.xyzw;
                output.texCoord1 = input.interp02.xyzw;
                output.texCoord2 = input.interp03.xyzw;
                output.texCoord3 = input.interp04.xyzw;
                output.viewDirectionWS = input.interp05.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                return output;
            }
            #endif
        
            // --------------------------------------------------
            // Build Graph Inputs
        
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            #endif
            
            
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
            #endif
            
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
            #endif
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
            #endif
            
            
            
            
            
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(TransformObjectToWorld(input.positionOS));
            #endif
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
                return output;
            }
            
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            
            
            
            
            
            
            
            
            
            
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            #endif
            
            
            
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.WorldSpacePosition =          input.positionWS;
            #endif
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.ViewSpacePosition =           TransformWorldToView(input.positionWS);
            #endif
            
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.AbsoluteWorldSpacePosition =  GetAbsolutePositionWS(input.positionWS);
            #endif
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            #endif
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.uv0 =                         input.texCoord0;
            #endif
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.uv1 =                         input.texCoord1;
            #endif
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.uv2 =                         input.texCoord2;
            #endif
            
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            output.uv3 =                         input.texCoord3;
            #endif
            
            
            
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1) || defined(KEYWORD_PERMUTATION_2) || defined(KEYWORD_PERMUTATION_3) || defined(KEYWORD_PERMUTATION_4) || defined(KEYWORD_PERMUTATION_5) || defined(KEYWORD_PERMUTATION_6) || defined(KEYWORD_PERMUTATION_7)
            BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                return output;
            }
            
        
            // --------------------------------------------------
            // Main
        
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
            ENDHLSL
        }
        */
    }
    FallBack "Hidden/Shader Graph/FallbackError"
}
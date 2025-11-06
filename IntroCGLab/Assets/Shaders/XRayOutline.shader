Shader "Custom/XRayOutline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OutlineColor ("Outline Color", Color) = (0,1,1,1)
        _Outline ("Outline Width", Range (-0.01, 0.5)) = .03
    }

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalRenderPipeline" }
        Tags {"Queue"="Geometry" }
    
        Pass
        {
            Name "Texture Color"
            Tags { "LightMode" = "UniversalForward" }
            
            Stencil
            {
                Ref 0
                Comp Always
                Pass Replace
            }
    
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
           
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            struct Attributes
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };
            
            struct Varyings
            {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormalT : TEXCOORD1;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.position = TransformObjectToHClip(IN.vertex);
                OUT.uv = IN.uv;
                OUT.worldNormalT = normalize(TransformObjectToWorldNormal(IN.normal));
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half4 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                Light mainLight = GetMainLight();
                half3 lightDir = normalize(mainLight.direction);
                half3 lightColor = mainLight.color;
                half NdotL = max(dot(IN.worldNormalT, lightDir), 0.0);
                half3 finalColortex = albedo.rgb * lightColor * NdotL;
                return half4(finalColortex, 1.0);
            }
            ENDHLSL
        }
        
        Pass
        {
            Name "OutlineColor"
            Tags { "LightMode" = "SRPDefaultUnlit" }
            Cull Front
            
            Stencil
            {
                Ref 1
                Comp Equal
                Pass Keep
            }
                        
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
           
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            CBUFFER_START(UnityPerMaterial)
            float _Outline;
            half4 _OutlineColor;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };
            
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS);
                float3 norm   = normalize(mul ((float3x3)UNITY_MATRIX_IT_MV, IN.normalOS));
                float2 offset = normalize(mul((float2x2)UNITY_MATRIX_P, norm.xy));
                OUT.positionCS.xy += offset * OUT.positionCS.z * _Outline;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half4 finalColor = _OutlineColor;
                return finalColor;
            }

            ENDHLSL
        }
    }
}
Shader "Custom/FlatShader"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 0, 0, 1)
        _BaseTexture ("Base Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque" "RenderPipeline" = "UniversalRenderPipeline"
        }
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 UV : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 UV : TEXCOORD0;
            };

            float4 _BaseColor;
            TEXTURE2D(_BaseTexture);
            SAMPLER(_BaseTextureSamp);

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.UV = IN.UV;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float4 ColorTexture = SAMPLE_TEXTURE2D(_BaseTexture, _BaseTextureSamp, IN.UV);
                return half4(_BaseColor.rgb, 1); // Use the RGB values from the property,
                return ColorTexture;
            }
            ENDHLSL
        }
    }
}
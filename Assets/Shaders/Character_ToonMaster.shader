Shader "ToonShade/Character_ToonMaster"
{
    Properties
    {
        _ColorTint("Color Tint", Color) = (1,1,1,1)
        _MainTex("Base Color", 2D) = "white"{}
        _ShadowColor("Shadow Color", Color) = (0.48,0.36,0.36,1)
        [HDR]_EmissionColor("Emission Color", Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags{ "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" "LightMode" = "UniversalForward"}
        LOD 100
        
        
        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            CBUFFER_START(UnityPerMaterial)
                half4 _ColorTint;
                float4 _MainTex_ST;
                half4 _ShadowColor;
                float4 _EmissionColor;
            CBUFFER_END

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            struct appdata
            {
                float4 positionOS : POSITION;
                float4 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                VertexPositionInputs  PositionInputs = GetVertexPositionInputs(v.positionOS);
                o.vertex = PositionInputs.positionCS;
                o.positionWS = PositionInputs.positionWS;

                VertexNormalInputs normal_inputs = GetVertexNormalInputs(v.normal);
                o.normalWS = normal_inputs.normalWS;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
			}

            half4 frag(v2f i) : SV_Target
            {
                half4 final_color = 0.f;
                const half4 base_color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);

                Light main_light = GetMainLight(TransformWorldToShadowCoord(i.positionWS.xyz));
                float NdotL = dot(i.normalWS, main_light.direction);
                float ToonShadow = smoothstep(0.2, 0.5 ,NdotL);
                half4 lgiht_color =  lerp(_ShadowColor, float4(main_light.color, 1), ToonShadow);
                final_color = base_color * lgiht_color + _EmissionColor;
                return final_color;
			}
            
            ENDHLSL
		}
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
	}
}

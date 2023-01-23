Shader "ToonShade/Character_ToonMaster"
{
    Properties
    {
        _ColorTint("Color Tint", Color) = (1,1,1,1)
        _MainTex("Base Color", 2D) = "white"{}
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

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            CBUFFER_START(UnityPerMaterial)
                half4 _ColorTint;
                float4 _MainTex_ST;
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
                o.vertex = TransformObjectToHClip(v.positionOS.xyz);
                o.positionWS = TransformObjectToWorld(v.positionOS.xyz);
                o.normalWS = TransformObjectToWorld(v.normal);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
			}

            half4 frag(v2f i) : SV_Target
            {
                half4 final_color = 0.f;
                const half4 base_color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);

                Light main_light = GetMainLight(TransformWorldToShadowCoord(i.positionWS.xyz));
                float NdotL = dot(i.normalWS, main_light.direction);
                float4 ToonShadow = (float4)(NdotL + 1)/2;
                half4 lgiht_color = ToonShadow * float4(main_light.color, 1);
                final_color = base_color * lgiht_color;
                return final_color;
			}
            
            ENDHLSL
		}
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
	}
}

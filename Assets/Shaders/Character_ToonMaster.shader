Shader "ToonShade/Character_ToonMaster"
{
    Properties
    {
        _ColorTint("Color Tint", Color) = (1,1,1,1)
        _MainTex("Base Color", 2D) = "white"{}
    }

    SubShader
    {
        Tags{ "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline"}    //增加标签
        LOD 100
        
        
        Pass
        {
            HLSLPROGRAM                                                      // 使用HLSL语言

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"          // 增加函数库

            CBUFFER_START(UnityPerMaterial)
                half4 _ColorTint;
                float4 _MainTex_ST;
            CBUFFER_END

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            struct appdata
            {
                   // Object Space
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0; // 顶点输入
            };
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;                                                     //定义输出
                o.vertex = TransformObjectToHClip(v.positionOS.xyz);       //读取顶点方式改变
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
			}

            half4 frag(v2f i) : SV_Target
            {
                half4 base_color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                return base_color;
			}


            ENDHLSL
		}
	}
}

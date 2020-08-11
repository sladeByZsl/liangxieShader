Shader "Custom/CommonParticle"
{
    Properties
    {
		[Header(RenderingMode)]
		[Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("Src Blend",int)= 0 
		[Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("Dst Blend",int) = 0
		[Enum(UnityEngine.Rendering.CullMode)]_Cull("Cull",int) = 0
        _MainTex ("Texture", 2D) = "white" {}

		[Header(Base)]
		_Color("Color",Color)=(1,1,1,1)
		_Intensity("Intensity",Range(-4,4))=1
		_MainUVSpeedX("MainUVSpeedX",float) = 0
		_MainUVSpeedY("MainUVSpeedY",float) = 0

		[Header(Mask)]
		[Toggle]_MaskEnabled("Mask Enabled",int) = 0
		_MaskTex("MaskTex", 2D) = "white" {}
		_MaskUVSpeedX("MaskUVSpeedX",float) = 0
		_MaskUVSpeedY("MaskUVSpeedY",float) = 0

		[Header(Distort)]
		[MaterialToggle(DISTORTENABLED)]_DistortEnabled("Distort Enabled",int) = 0
		_DistortTex("DistortTex", 2D) = "white" {}
		_Distort("Distort",Range(0,1)) = 0
		_DistortUVSpeedX("DistortUVSpeedX",float) = 0
		_DistortUVSpeedY("DistortUVSpeedX",float) = 0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" }
		Blend [_SrcBlend] [_DstBlend]
		Cull [_Cull]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma shader_feature _ _MASKENABLED_ON
			#pragma shader_feature _ DISTORTENABLED

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 position : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
				float4 position : SV_POSITION;
                float4 uv : TEXCOORD0;
				float2 uv2: TEXCOORD1;
            };

            sampler2D _MainTex; float4 _MainTex_ST;
			sampler2D _MaskTex; float4 _MaskTex_ST;
			sampler2D _DistortTex; float4 _DistortTex_ST;

			fixed4 _Color;
			half _Intensity;
			float _MainUVSpeedX;
			float _MainUVSpeedY;
			float _MaskUVSpeedX;
			float _MaskUVSpeedY;
			float _Distort;

			float _DistortUVSpeedX;
			float _DistortUVSpeedY;


            v2f vert (appdata v)
            {
                v2f o;
                o.position = UnityObjectToClipPos(v.position);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex) + float2(_MainUVSpeedX, _MainUVSpeedY)*_Time.y;
				o.uv.zw = TRANSFORM_TEX(v.uv, _MaskTex) + float2(_MaskUVSpeedX, _MaskUVSpeedY)*_Time.y;
				o.uv2 = TRANSFORM_TEX(v.uv, _DistortTex) + float2(_DistortUVSpeedX, _DistortUVSpeedY)*_Time.y;;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 c;
				c = _Color * _Intensity;
				float2 distrot = i.uv.xy;

				#if DISTORTENABLED
					fixed4 distortTex = tex2D(_DistortTex,i.uv2);
					distrot = lerp(i.uv.xy, distortTex, _Distort);
				#endif

				
                fixed4 mainTex = tex2D(_MainTex, distrot);
				c *= mainTex;

				#if _MASKENABLED_ON
				fixed4 maskTex = tex2D(_MaskTex, i.uv.zw);
				c *= maskTex;
				#endif

                return c;
            }
            ENDCG
        }
    }
}

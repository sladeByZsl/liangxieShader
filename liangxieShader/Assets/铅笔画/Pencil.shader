Shader "Custom/Pencil"
{
    Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
        // 铅笔效果
        _PencilFactor("PencilFactor",Range(0,0.25)) = 0.01

	}

	SubShader
	{
		Tags
		{ 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}

		Cull Off
		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha

		Pass
		{
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile _ PIXELSNAP_ON
			#include "UnityCG.cginc"
			
			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				float2 texcoord  : TEXCOORD0;
			};
			
			fixed4 _Color;
        

			v2f vert(appdata_t IN)
			{
				v2f OUT;
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color * _Color;
				#ifdef PIXELSNAP_ON
				OUT.vertex = UnityPixelSnap (OUT.vertex);
				#endif

				return OUT;
			}

			sampler2D _MainTex;
			sampler2D _AlphaTex;
			float _AlphaSplitEnabled;
            float _PencilFactor;

            fixed g(fixed4 color)
            {
                return color.r * 0.299 + color.g * 0.587 + color.b * 0.114;
            }

			fixed4 SampleSpriteTexture (float2 uv)
			{
				// 水平卷积核、竖直卷积核
                float offset = _PencilFactor;

                // 左上
                fixed4 edgeX = g(tex2D (_MainTex, float2(uv.x - offset,uv.y - offset))) * -1;
                // 上
                edgeX += g(tex2D(_MainTex,float2(uv.x,uv.y - offset))) * 0;
                // 右上
                edgeX += g(tex2D(_MainTex,float2(uv.x + offset,uv.y + offset))) * -1;
                // 左
                edgeX += g(tex2D(_MainTex,float2(uv.x - offset,uv.y))) * -2;
                // 中
                edgeX += g(tex2D(_MainTex,float2(uv.x,uv.y))) * 0;
                // 右
                edgeX += g(tex2D(_MainTex,float2(uv.x + offset,uv.y))) * 2;
                // 左下
                edgeX += g(tex2D (_MainTex, float2(uv.x - offset,uv.y + offset))) * 1;
                // 下
                edgeX += g(tex2D(_MainTex,float2(uv.x,uv.y + offset))) * 0;
                // 右下
                edgeX += g(tex2D(_MainTex,float2(uv.x,uv.y - offset))) * 1;

                // 左上
                half edgeY = g(tex2D (_MainTex, float2(uv.x - offset,uv.y - offset))) * -1;
                // 上
                edgeY += g(tex2D(_MainTex,float2(uv.x,uv.y - offset))) * -2;
                // 右上
                edgeY += g(tex2D(_MainTex,float2(uv.x + offset,uv.y + offset))) * -1;
                // 左
                edgeY += g(tex2D(_MainTex,float2(uv.x - offset,uv.y))) * 0;
                // 中
                edgeY += g(tex2D(_MainTex,float2(uv.x,uv.y))) * 0;
                // 右
                edgeY += g(tex2D(_MainTex,float2(uv.x + offset,uv.y))) * 0;
                // 左下
                edgeY += g(tex2D(_MainTex, float2(uv.x - offset,uv.y + offset))) * 1;
                // 下
                edgeY += g(tex2D(_MainTex,float2(uv.x,uv.y + offset))) * 2;
                // 右下
                edgeY += g(tex2D(_MainTex,float2(uv.x,uv.y - offset))) * 1;

                half edge = 1- abs(edgeX) - abs(edgeY);

#if UNITY_TEXTURE_ALPHASPLIT_ALLOWED
                if (_AlphaSplitEnabled)
                    color.a = tex2D (_AlphaTex, uv).r;
#endif //UNITY_TEXTURE_ALPHASPLIT_ALLOWED

                fixed4 texColor = tex2D(_MainTex,uv);
                // 乘以一个 alpha 是为了裁减掉透明度为零的部分
                return fixed4(edge,edge,edge,1) * texColor.a;
			}

			fixed4 frag(v2f IN) : SV_Target
			{
				fixed4 c = SampleSpriteTexture (IN.texcoord) * IN.color;
				c.rgb *= c.a;
				return c;
			}
		ENDCG
		}
	}
}

Shader "Custom/ImageSeq"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color Tint",Color) = (1,1,1,1)
        _HorizontalAmount("Horizontal Amount",Float) = 4
        _VerticalAmount("Vertical Amount",Float) = 4
        _Speed ("Speed",Range(1,100))=30
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
        
        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            float _HorizontalAmount;
            float _VerticalAmount;
            float _Speed;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float time = floor(_Time.y*_Speed);
                float row = floor(time/_HorizontalAmount);
                //对行数求余，等价于floor(time%_HorizontalAmount);
                float column = time-row*_HorizontalAmount;

//				half2 uv = float2(i.uv.x /_HorizontalAmount, i.uv.y / _VerticalAmount);
//				uv.x += column / _HorizontalAmount;
//				uv.y -= row / _VerticalAmount;
                half2 uv=i.uv+half2(column,-row);
                uv.x /= _HorizontalAmount;
                uv.y /=_VerticalAmount;

                fixed4 c=tex2D(_MainTex,uv);
                c.rgb*=_Color;
                return c;
            }
            ENDCG
        }
    }
    FallBack "Transparent/VertexLit"
}

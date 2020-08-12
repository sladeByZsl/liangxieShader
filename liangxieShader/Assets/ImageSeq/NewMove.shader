Shader "Unlit/NewMove"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        _FlowLightColor("FlowLightColor",color) = (1,1,1,1)
        _FlowLight("Speed(X) Width(Y) Alpha(Z) Angle(W)",vector) = (0.3,8,0.5,0.45)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color    : COLOR;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 uv : TEXCOORD0;
                fixed4 color    : COLOR;
                float4 worldPosition : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            fixed4 _FlowLightColor;
            float4 _FlowLight;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                //利用UV来做刷光，这里把UV独立开来，以免受主纹理的Tiling和Offset影响
                o.uv.zw = v.uv;
                o.color = v.color * _Color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half4 color = tex2D(_MainTex, i.uv.xy) * i.color;
                float angle = lerp(1-i.uv.x,i.uv.y,_FlowLight.w);
                //不断重复向一个方向刷光
                float offset = sin(frac(angle+_Time.y*_FlowLight.x)*3-1.5)*2;
                //斜线刷光形状
                offset=0.48;
                offset=sin(_Time.y);
                fixed4 light = pow(1-saturate(abs(i.uv.z-i.uv.w+offset)),_FlowLight.y);
                light *= _FlowLightColor;
                color +=light * color.a * _FlowLight.z;
                return i.uv.x-i.uv.y;
            }
            ENDCG
        }
    }
}

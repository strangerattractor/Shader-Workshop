Shader "Unlit/UV_Rotate"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            
            float2x2 rotate2d(float _angle){
                return float2x2(cos(_angle),-sin(_angle),
                            sin(_angle),cos(_angle));
            }
            
            fixed4 frag (v2f i) : SV_Target
            {

                float rez = 20.;
                
                float2 st = i.uv;
                st = abs(st - .5);
                
                float2 ipos = floor(st * rez)/rez;
                ipos = frac(float2(ipos));

                st = mul(st, rotate2d((ipos+1.) * _Time * 10.));
                
                // sample the texture
                float4 col = tex2D(_MainTex, (st + .5 + ipos * 1.)/2.);

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}

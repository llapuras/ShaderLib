// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Lapu/TileBasic"
{
	Properties {
        _MainColor("Mian Color", COLOR) = (1,1,1,1)
		_MainTex ("Main Texture", 2D) = "black" {}
	}


	SubShader
	{
		Tags { "RenderType" = "Opaque"  "Queue" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
		LOD 100
	
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag	
			#include "UnityCG.cginc"

			sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainColor;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD3;
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata_img v) {
			    v2f o;
			    o.vertex = UnityObjectToClipPos(v.vertex);
			    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			    return o;
		    }

			fixed4 frag(v2f i) : SV_Target
			{
				half4 col = tex2D(_MainTex, i.uv);
				return col * _MainColor;
			}
			ENDCG
		}

	}

}
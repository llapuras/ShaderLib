// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Lapu/BackgroundEffect01"
{
	Properties {
		_MainTex ("Main Texture", 2D) = "black" {}
		_Rotation("Rotation",  Range(0,360)) = 45.0				
		[Space(10)]
		_Speed("Progress", Range(0,1))=0
	}


	SubShader
	{
		Tags { "RenderType" = "Opaque"  "Queue" = "Transparent" }
		LOD 100
	
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag	
			#include "UnityCG.cginc"

			float4 _Tint;
			sampler2D _MainTex, _MainTex_ST;
			float _Rotation, _Speed;

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
			    float Rot = _Rotation * (3.1415926f/180.0f);
			    float s = sin(Rot);
			    float c = cos(Rot);
			    o.uv = v.texcoord + fixed2(s,c) * (_Time.y * _Speed);
			    return o;
		    }

			fixed4 frag(v2f i) : SV_Target
			{
				half4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}

	}

}
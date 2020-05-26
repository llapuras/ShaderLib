Shader "Lapu/Water001"
{
	Properties
	{
		_Tint("Tint", Color) = (1, 1, 1, .5)
		_Amount("Wave Amount", Range(0,1)) = 0.5
		_Height("Wave Height", Range(0,1)) = 0.5
		_Speed("Wave Speed", Range(0,1)) = 0.5
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
			float _Speed, _Amount, _Height;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD3;
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				v.vertex.y += sin(_Time.z * _Speed + (v.vertex.x * v.vertex.z * _Amount)) * _Height;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				half4 col = _Tint;
				return   col;
			}
			ENDCG
		}

	}

}
Shader "Lapu/BlurUI000"
{
	Properties
	{
		_Color("Color", COLOR) = (1,1,1,1)
	}

	SubShader
	{
		Tags{ "Queue" = "Transparent"}

		GrabPass{}

	Pass
	{
		
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"

		struct appdata
		{
			float4 vertex : POSITION;
		};

		struct v2f
		{
			float4 vertex : SV_POSITION;
			float4 screenPos : TEXCOORD0;
			float4 grabPos : TEXCOORD1;
		};

		float4 _Color;

		//GrabPass相关变量
		sampler2D _GrabTexture;
		float4 _GrabTexture_TexelSize;

		v2f vert(appdata v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.screenPos = ComputeScreenPos(o.vertex);
			o.grabPos = ComputeGrabScreenPos(o.vertex);
			return o;
		}

		half4 frag(v2f i) : SV_TARGET
		{
			float4 result = tex2Dproj(_GrabTexture, i.screenPos) * _Color;
			return result;
		}
	    ENDCG
	}
	}

}
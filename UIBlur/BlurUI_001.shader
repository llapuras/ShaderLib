Shader "Lapu/BlurUI001"
{
	Properties
	{
		_Color("Color", COLOR) = (1,1,1,1)
		_Radius("Blur Radius", Range(11, 500)) = 11
	}

	SubShader
	{
		Tags{ "Queue" = "Transparent"}

		GrabPass {}

	GrabPass{}
		Pass
		{
		//Blend SrcAlpha OneMinusSrcAlpha

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

		sampler2D _GrabTexture;
		float4 _GrabTexture_TexelSize;

		float4 _Color;
		int _Radius;

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
			float4 result = tex2Dproj(_GrabTexture, i.screenPos);
			float4 grabPos;
			grabPos.zw = i.screenPos.zw;
			for (int rangeX = 1; rangeX <= _Radius; rangeX++)
			{
				for (int rangeY = 1; rangeY < _Radius; rangeY++)
				{
					float2 w1 = i.screenPos.xy + float2(_GrabTexture_TexelSize.x * rangeX, _GrabTexture_TexelSize.y * rangeY);
					grabPos.xy = w1;
					result += tex2Dproj(_GrabTexture, i.screenPos + grabPos);

					float2 w2 = i.screenPos.xy + float2(_GrabTexture_TexelSize.x * rangeX, _GrabTexture_TexelSize.y * -rangeY);
					grabPos.xy = w2;
					result += tex2Dproj(_GrabTexture, i.screenPos + grabPos);
				}
			}
			result /= _Radius * _Radius * 2 + 1;

	        float4 col = half4(_Color.a * _Color.rgb + (1 - _Color.a) * result.rgb, 1.0f);
	 	    return col;
		}
	    ENDCG
	}
	}

}
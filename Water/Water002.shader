Shader "Lapu/Water002"
{
	Properties
	{
		_Tint("Tint", Color) = (1, 1, 1, .5)
		_Amount("Wave Amount", Range(0,1)) = 0.5
		_Height("Wave Height", Range(0,1)) = 0.5
		_Speed("Wave Speed", Range(0,1)) = 0.5
		_FoamThickness("Foam Thickness", Range(0,50)) = 0.5
		_EdgeColor("Edge Color", Color) = (1, 1, 1, .5)
	}


		SubShader
		{
			Tags { "RenderType" = "Opaque"  "Queue" = "Transparent" }
			LOD 100
			Blend SrcAlpha OneMinusSrcAlpha

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag	
				#include "UnityCG.cginc"

				sampler2D _CameraDepthTexture;//unity内置变量，无需在Properties中声明

				float4 _Tint, _EdgeColor;
				float _Speed, _Amount, _Height, _FoamThickness;
					
				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					float4 vertex : SV_POSITION;
					float2 uv : TEXCOORD0;
					float4 screenPos : TEXCOORD1;
					float2 depthtex : TEXCOORD2;
				};

				v2f vert(appdata v)
				{
					v2f o;
					v.vertex.y += sin(_Time.z * _Speed + (v.vertex.x * v.vertex.z * _Amount)) * _Height;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.screenPos = ComputeScreenPos(o.vertex);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					float4 depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, (i.screenPos));
					float depth = LinearEyeDepth(depthSample);
					float foamLine = 1 - saturate(_FoamThickness * (depth - i.screenPos.w));
					half4 col = _Tint + foamLine * _EdgeColor* 0.5;
					return col;
				}
				ENDCG
			}
		}

}
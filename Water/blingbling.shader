Shader "Lapu/Water003"
{
	Properties
	{
		_Tint("Tint", Color) = (1, 1, 1, 1)
		_MainTex("Main Texture", 2D) = "white" {}
		_MainDistortionFactor("Main Distortion Factor", Range(0,10)) = 1
		_Amount("Wave Amount", Range(0,1)) = 0.5
		_Height("Wave Height", Range(0,1)) = 0.5
		_Speed("Wave Speed", Range(0,1)) = 0.5
		_FoamThickness("Foam Thickness", Range(0,10)) = 0.5
		_DistortionMap("Distortion Tex", 2D) = "grey"{}
		_DistortionFactor("Distortion Factor", Range(0.001,10)) = 1
		_EdgeColor("Edge Color", Color) = (1, 1, 1, 1)
	}


		SubShader
		{
			Tags { "RenderType" = "Opaque"  "Queue" = "Transparent" }
			LOD 100
			Blend SrcAlpha OneMinusSrcAlpha

			GrabPass{}

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag	
				#include "UnityCG.cginc"

				float4 _Tint, _EdgeColor;
				float _Speed, _Amount, _Height, _FoamThickness, _DistortionFactor, _MainDistortionFactor;
				sampler2D _DistortionMap, _MainTex;
				sampler2D _CameraDepthTexture, _GrabTexture;//unity内置变量，无需在Properties中声明
				float4 _DistortionMap_ST, _MainTex_ST;
				float4 _GrabTexture_TexelSize;

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
					float4 screenPos : TEXCOORD1;
					float2 depthtex : TEXCOORD2;
					float2 dismap : TEXCOORD3;
					float4 grabtex : TEXCOORD4;
				};

				v2f vert(appdata v)
				{
					v2f o;
					v.vertex.y += sin(_Time.z * _Speed + (v.vertex.x * v.vertex.z * _Amount)) * _Height;
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.screenPos = ComputeScreenPos(o.vertex);
					o.dismap = TRANSFORM_TEX(v.vertex, _DistortionMap);
					o.grabtex = ComputeGrabScreenPos(o.vertex);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					float2 dism = UnpackNormal(tex2D(_DistortionMap, i.dismap + (_Time.x * 0.2)));
					float2 offset = dism * (_DistortionFactor * 10) * _GrabTexture_TexelSize.xy * 10;
					i.grabtex.xy = offset + i.grabtex.xy;
					float4 dis = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.grabtex)) * _EdgeColor;

					float4 depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, (i.screenPos));
					float depth = LinearEyeDepth(depthSample);
					float foamLine = 1 - saturate(_FoamThickness * (depth - i.screenPos.w));

					half4 col = tex2D(_MainTex, i.uv + offset * _MainDistortionFactor / _DistortionFactor) * _Tint;
					col += foamLine * _Tint;
					col = (col + dis) * col.a;

					return col;
				}
				ENDCG
			}
		}

}
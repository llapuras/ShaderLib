Shader "Lapu/LapuSky_step1"
{
	Properties
	{
		_Test("Test",  int) = 1
		_Test02("Test02",  Color) = (1,1,1,0)

		 [Header(Sun Settings)]
		 _SunColor("Sun Color", Color) = (1,1,1,1)
		_SunRadius("Sun Radius",  Range(0, 2)) = 0.1

		[Header(Moon Settings)]
		_MoonColor("Moon Color", Color) = (1,1,1,1)
		_MoonRadius("Moon Radius",  Range(0, 2)) = 0.15
		_MoonOffset("Moon Crescent",  Range(-1, 1)) = -0.1
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }
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
					float3 uv : TEXCOORD0;
				};

				struct v2f
				{
					float3 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
					float3 worldPos : TEXCOORD1;
				};

				float _SunRadius, _MoonRadius, _MoonOffset;
				float4 _SunColor, _MoonColor;
			
				float _Speed;
				float _Test, _Test02;

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = v.uv;
					o.worldPos = mul(unity_ObjectToWorld, v.vertex);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{

				// uv for the sky
				float2 skyUV = i.worldPos.xz / i.worldPos.y;

				// sun
				float sun = distance(i.uv.xyz, _WorldSpaceLightPos0);
				float sunDisc = 1 - (sun / _SunRadius);
				sunDisc = saturate(sunDisc * 50);
				
				// moon
				float moon = distance(i.uv.xyz, -_WorldSpaceLightPos0);
				float moonDisc = 1 - (moon / _MoonRadius);
				moonDisc = saturate(moonDisc * 50);

				float crescentMoon = distance(float3(i.uv.x + _MoonOffset, i.uv.yz), -_WorldSpaceLightPos0);
				float crescentMoonDisc = 1 - (crescentMoon / _MoonRadius);
				crescentMoonDisc = saturate(crescentMoonDisc * 50);

				moonDisc = saturate(moonDisc - crescentMoonDisc);

				float3 sunAndMoon = (sunDisc * _SunColor) + (moonDisc * _MoonColor);

			    return float4(sunAndMoon,1);
		    }
		    ENDCG
	    }
	}
}

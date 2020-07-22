Shader "Tessellation" {

	Properties{
		[Header(Main)]
		[Space]
		[Header(Tesselation)]
		_MaxTessDistance("Max Tessellation Distance", Range(10,100)) = 50
		_Tess("Tessellation", Range(1,32)) = 20
	}

		SubShader{
			Tags{ "RenderType" = "Opaque" }
			LOD 200

			CGPROGRAM

			#pragma surface surf Lambert vertex:vert addshadow nolightmap tessellate:tessDistance fullforwardshadows
			#pragma target 4.0
			#pragma require tessellation tessHW
			#include "Tessellation.cginc"

			float _Tess;
			float _MaxTessDistance;

			float4 tessDistance(appdata_full v0, appdata_full v1, appdata_full v2)
			{
				float minDist = 10.0;
				float maxDist = _MaxTessDistance;

				return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, minDist, maxDist, _Tess);
			}

			struct Input {
				float4 vertexColor : COLOR;
			};

			void vert(inout appdata_full v)
			{

			}

			void surf(Input IN, inout SurfaceOutput o) 
			{
				o.Albedo = IN.vertexColor;
			}
			ENDCG

		}

			Fallback "Diffuse"
}
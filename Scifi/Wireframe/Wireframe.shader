// Wireframe shader based on the the following
// http://developer.download.nvidia.com/SDK/10/direct3d/Source/SolidWireframe/Doc/SolidWireframe.pdf
Shader "Lapu/Wireframe"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_WireThickness("Wire Thickness", RANGE(0, 800)) = 100
		_WireSmoothness("Wire Smoothness", RANGE(0, 20)) = 3
		[HDR]_WireColor("Wire Color", Color) = (0.0, 1.0, 0.0, 1.0)
		_Opacity("Opacity", Range(0 , 1)) = 4.5
		_BaseColor("Base Color", Color) = (0.0, 0.0, 0.0, 1.0)
		_Amount("Amount", Range(0, 2)) = 0.0
	}

		SubShader
		{
			Tags{"RenderType" = "Transparent" "Queue" = "Transparent"}

			Pass
			{
				Cull Off 
				//AlphaToMask On 

				Blend One OneMinusSrcAlpha
				
				CGPROGRAM
				#pragma vertex vert
				#pragma geometry geom
				#pragma fragment frag

				#include "UnityCG.cginc"

				sampler2D _MainTex; 
				float4 _MainTex_ST;
				float _WireThickness;
				float _WireSmoothness;
				float4 _WireColor;
				float4 _BaseColor;
				float _Opacity;
				float _Amount;

				struct appdata
				{
					float4 vertex : POSITION;
					float2 texcoord0 : TEXCOORD0;
					//UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				struct v2g
				{
					float4 vertex : SV_POSITION;
					float2 uv0 : TEXCOORD0;
					float4 worldSpacePosition : TEXCOORD1;
					//UNITY_VERTEX_OUTPUT_STEREO	//声明该顶点是否位于视线域中，来判断这个顶点是否输出到片段着色器。这里不写也没啥影响...
				};

				struct g2f
				{
					float4 vertex : SV_POSITION;
					float2 uv0 : TEXCOORD0;
					float4 worldSpacePosition : TEXCOORD1;
					float4 dist : TEXCOORD2;
					float4 color : COLOR;//Todo：only show rect frame =ω=
					//UNITY_VERTEX_OUTPUT_STEREO
				};

				v2g vert(appdata v)
				{
					v2g o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.worldSpacePosition = mul(unity_ObjectToWorld, v.vertex);
					o.uv0 = TRANSFORM_TEX(v.texcoord0, _MainTex);
					return o;
				}

				[maxvertexcount(3)]
				void geom(triangle v2g i[3], inout TriangleStream<g2f> triangleStream)
				{
					float2 p0 = i[0].vertex.xy;
					float2 p1 = i[1].vertex.xy ;
					float2 p2 = i[2].vertex.xy;

					float2 edge0 = p2 - p1;
					float2 edge1 = p2 - p0;
					float2 edge2 = p1 - p0;

					//get area of triangle frag
					float area = abs(edge1.x * edge2.y - edge1.y * edge2.x);
					float wireThickness = 800 - _WireThickness;

					g2f o;
					float amountfactor = step(i[0].worldSpacePosition.y - _Amount * 4 + 2, 0);
					o.uv0 = i[0].uv0;
					o.worldSpacePosition = i[0].worldSpacePosition;
					o.vertex = i[0].vertex;
					o.dist.xyz = float3((area / length(edge0)), 0.0, 0.0) * wireThickness;
					o.dist.w = 1.0 / o.vertex.w;
					o.color = float4(_WireColor)*amountfactor;
					triangleStream.Append(o);

					amountfactor = step(i[0].worldSpacePosition.y - _Amount * 4 + 2, 0);
					o.uv0 = i[1].uv0;
					o.worldSpacePosition = i[1].worldSpacePosition;
					o.vertex = i[1].vertex;
					o.dist.xyz = float3(0.0, (area / length(edge1)), 0.0)* wireThickness;
					o.dist.w = 1.0 / o.vertex.w;
					o.color = float4(_WireColor)*amountfactor;
					triangleStream.Append(o);

					amountfactor = step(i[0].worldSpacePosition.y - _Amount * 4 + 2, 0);
					o.uv0 = i[2].uv0;
					o.worldSpacePosition = i[2].worldSpacePosition;
					o.vertex = i[2].vertex;
					o.dist.xyz = float3(0.0, 0.0, (area / length(edge2)))* wireThickness;
					o.dist.w = 1.0 / o.vertex.w;
					o.color = float4(_WireColor)*amountfactor;
					triangleStream.Append(o);
				}

				fixed4 frag(g2f i) : SV_Target
				{
					float amountfactor = step(i.worldSpacePosition.y - _Amount * 4 + 2, 0);
					float minDistanceToEdge = min(i.dist[0], min(i.dist[1], i.dist[2]));
					float4 baseColor = _BaseColor * tex2D(_MainTex, i.uv0);

					// Early out if we know we are not on a line segment.
					// 快速筛选距离近的点，直接返回basecolor*tex，这里阈值设为0.9，以此减少后续步骤计算
					if (minDistanceToEdge > 0.9)
					{
						return fixed4(baseColor.rgb,1) * _Opacity * amountfactor;
					}

					// Smooth our line out
					float t = exp2(_WireSmoothness * -1.0 * minDistanceToEdge * minDistanceToEdge);
					fixed4 finalColor = lerp(baseColor, i.color, t) * amountfactor;
					finalColor.a = t * amountfactor;

					return  i.color;
				}
				ENDCG
			}
		}
}

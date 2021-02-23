// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Lapu/AlfxWater"
{
	Properties
	{
		_Tint("Tint", Color) = (1, 1, 1, .5)
		_MainTex("Main Texture", 2D) = "white" {}

		[Header(Flow Map)]
		_FlowMap("Flow Map", 2D) = "black" {}
		_DerivHeightMap("Normal Map", 2D) = "black" {}
		_FlowSpeed("Flow Speed", Float) = 1
		_Tiling("Tiling", Range(0.01, 10)) = 1
		_HeightScale("Height Scale, Constant", Float) = 0.25
		_HeightScaleModulated("Height Scale, Modulated", Float) = 0.75
		[HideInInspector]_FlowStrength("Flow Strength", Float) = 1
		[HideInInspector]_FlowOffset("Flow Offset", Float) = 0
		[HideInInspector]_UJump("U jump per phase", Range(-0.25, 0.25)) = 0.25
		[HideInInspector]_VJump("V jump per phase", Range(-0.25, 0.25)) = 0.25


		[Header(Specular)]
		_SpecularColor("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Glossiness("Glossiness", Range(0,10)) = 0.5
		_SpecularPower("SpecularPower", Float) = 0.5
		
		[Header(UnderwaterFog)]
		_WaterFogColor("Water Fog Color", Color) = (0, 0, 0, 0)
		_WaterFogDensity("Water Fog Density", Range(0, 5)) = 0.1

		[Header(LightAbsorption)]
		_AbsorptionColor("Absorption Color", Color) = (0.45, 0.029, 0.018, 1.0)
		_AbsorptionDepth("Absorption Depth", Float) = 0.1
		_AbsorptionStrength("Absorption Strength", Range(0, 2)) = 0.1
		[HideInInspector]_AbsorptionColorStrength("Absorption Color Strength", Range(0, 2)) = 0.1
		
		[Header(Water Reflection)]
		[MaterialToggle] enableReflection("enableReflection", Float) = 1
		_Cube("Reflection Map", Cube) = "" {}
		_CubemapSmooth("Cubemap Smooth", Range(1, 250)) = 1

		[Header(Water Refraction)]
		_RefractionStrength("Refraction Strength", Range(0, 1)) = 0.25
		
		[Header(Water Caustic)]
		[MaterialToggle] enableCaustics("enableCaustics", Float) = 1
		_CausticsTex("Caustic Texture", 2D) = "white" {}
		_CausticsStrength("Caustics Strength", Float) = 1
		_CausticsAtten("Caustics Attenuation", Range(0,10)) = 1
		_Caustics1_ST("Caustics ST", Vector) = (1,1,0,0)
		_Caustics2_ST("Caustics 1 ST", Vector) = (1,1,0,0)
		_Caustics1_Speed("Caustics 1 Speed", Range(0, 0.1)) = 1
		_Caustics2_Speed("Caustics 2 Speed", Range(-0.1, 0)) = 1
		_SplitRGB("Split RGB", Color) = (0.2, 0.2, 0.6, 1.0)

		[Header(Water Foam)]
		[MaterialToggle] enableFoam("enableFoam", Float) = 1
	    _FoamTex("Foam Texture", 2D) = "white" {}
		_FoamColor("Foam Color", Color) = (0, 0, 0, 0)
		_FoamWidth("Foam Width", Range(0, 50)) = 1
		_FoamCutoff("Foam Cutoff", Range(0, 1)) = 1
		_FoamSpeed("Foam Speed", Vector) = (1, 0.2, 0, 0)

		[Header(Gerstner Waves)]
		[MaterialToggle] enableGerstner("enableGerstner", Float) = 1

		[Header(WaveA)]
		_HeightA("Wave Height A", Range(0,5)) = 5
		_SteepA("Wave Steep A", Range(0,20)) = 0.5
		_WaveA("Wave A (dir, wavelength, speed)", Vector) = (1,0,10,0.5)

		[Header(WaveB)]
		_HeightB("Wave Height B", Range(0,5)) = 2
		_SteepB("Wave Steep B", Range(0,20)) = 0.2
		_WaveB("Wave B", Vector) = (0,1,0.25,20)

		[Header(WaveC)]
		_HeightC("Wave Height C", Range(0,5)) = 2
		_SteepC("Wave Steep C", Range(0,20)) = 0.2
		_WaveC("Wave C", Vector) = (1,1,0.15,10)

		_Test("Test", Float) = 0.1
		_Test2("Test 2", Float) = 0.1

	}

		SubShader
		{
			Tags { "RenderType" = "Transparent"  "Queue" = "Transparent" }
			LOD 300
			Blend SrcAlpha OneMinusSrcAlpha

			GrabPass { "_WaterBackground" }

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"
				#include "Lighting.cginc"

				float4 _Tint, _SpecularColor;
				sampler2D _MainTex, _FlowMap, _DerivHeightMap, _FoamTex;
				float4 _MainTex_ST, _FlowMap_ST, _DerivHeightMap_ST, _FoamTex_ST, _CausticsTex_ST;
				float _Glossiness, _SpecularPower, _CausticsAtten;
				float _FlowOffset, _UJump, _VJump, _Tiling, _FlowSpeed, _HeightScale, _HeightScaleModulated, _FlowStrength;
				
				float4 _WaveA, _WaveB, _WaveC;
				float _HeightA, _HeightB, _HeightC, _SteepA, _SteepB, _SteepC;

				float _FoamWidth, _FoamScale, _FoamCutoff;
				float4 _FoamColor, _FoamSpeed;

				float _RefractionStrength, _CubemapSmooth;

				samplerCUBE _Cube;

				bool enableGerstner, enableCaustics, enableFoam, enableReflection;

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
					float3 normal : NORMAL;
				};

				struct v2f
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
					float3 normal : NORMAL;
					float4 viewInterpolator : TEXCOORD1;
					float4 screenPos : TEXCOORD2;
					float4 grabtex : TEXCOORD3;
					float3 worldPos : TEXCOORD4;
					float3 ray : TEXCOORD5;
				};
				
				float3 UnpackDerivativeHeight(float4 textureData) {
					float3 dh = textureData.agb;
					dh.xy = dh.xy * 2 - 1;
					return dh;
				}

				float3 FlowUVW(
					float2 uv, float2 flowVector, float2 jump,
					float flowOffset, float tiling, float time, bool flowB
				) {
					float phaseOffset = flowB ? 0.5 : 0;
					float progress = frac(time + phaseOffset);
					float3 uvw;
					uvw.xy = uv - flowVector * (progress + flowOffset);
					uvw.xy *= tiling;
					uvw.xy += phaseOffset;
					uvw.xy += (time - progress) * jump;
					uvw.z = 1 - abs(1 - 2 * progress);
					return uvw;
				}

				// Gerstner波
				//  -----------------------------------------------------------------------
				float3 GerstnerWave(float4 wave, float3 p, float height, float steepness, inout float3 tangent, inout float3 binormal, inout float3 normal) {
					float wavelength = wave.z;
					float wavespeed = wave.w;
					float w = 1 / wavelength;
					float phase = wavespeed / wavelength;

					float2 d = normalize(wave.xy);
					float f = w * (dot(d, p.xz) + phase * _Time.y);

					steepness = clamp(0, wavelength / height, steepness);

					float qa = steepness * height;
					float wa = w * height;
					float qwa = w * qa;

					float3 displacement;
					displacement.x = d.x * qa * cos(f);
					displacement.z = d.y * qa * cos(f);
					displacement.y = height * sin(f);

					tangent.x += -d.x * d.y * qwa * sin(f);
					tangent.y += d.y * wa * cos(f);
					tangent.z += -d.y * d.y * qwa * sin(f);

					binormal.x += -d.x * d.x * qwa * sin(f);
					binormal.y += d.x * wa * cos(f);
					binormal.z += -d.x * d.y * qwa * sin(f);

					normal.xy = d.xy * wa * cos(f);
					normal.z = qwa * sin(f) - 1;

					return displacement;
				}

				v2f vert(appdata v)
				{
					v2f o;

					float3 gridPoint = v.vertex.xyz;
					float3 tangent = float3(1, 0, 0);
					float3 binormal = float3(0, 0, 1);
					float3 normal = float3(0, 0, 0);

					// 用三重Gerstner波模拟水面波浪
					//  -----------------------------------------------------------------------
					if (enableGerstner == 1) {
						float3 p = gridPoint;
						p += GerstnerWave(_WaveA, gridPoint, _HeightA, _SteepA, tangent, binormal, normal);
						p += GerstnerWave(_WaveB, gridPoint, _HeightB, _SteepB, tangent, binormal, normal);
						p += GerstnerWave(_WaveC, gridPoint, _HeightC, _SteepC, tangent, binormal, normal);
						normal = normalize(cross(binormal, tangent));
						v.vertex.xyz = p;
					}

					o.normal = normalize(v.normal);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.screenPos = ComputeScreenPos(o.vertex);
					o.grabtex = ComputeGrabScreenPos(o.vertex);
					
					//o.worldPos = mul(unity_CameraToWorld, v.vertex).xyz;
					o.worldPos = mul(unity_ObjectToWorld, v.vertex);
					
					o.viewInterpolator.xyz = o.vertex - _WorldSpaceCameraPos;
					o.ray = mul(UNITY_MATRIX_MV, float4(o.worldPos,1)).xyz * float3(-1, -1, 1);
				
					return o;
				}

				// Underwater水下颜色
				//  -----------------------------------------------------------------------
				// water fog: 调节水下可视度(类似透明度)
				// light absorption: 根据深度调节水下颜色，深水处颜色也更深
				sampler2D _CameraDepthTexture, _WaterBackground;
				float4 _CameraDepthTexture_TexelSize;

				float3 _WaterFogColor, _AbsorptionColor;
				float _WaterFogDensity, _AbsorptionStrength, _AbsorptionDepth, _AbsorptionColorStrength;
				float _Test, _Test2;

				float3 ColorBelowWater(v2f i) {

					float4 screenPos = i.screenPos;

					// Refraction水下折射
					//  -----------------------------------------------------------------------
					// 通过uv位移模拟折射现象
					float2 uvOffset = i.normal.xz * _RefractionStrength;
					
					float2 uv = (screenPos.xy + uvOffset) / screenPos.w;
					
					float backgroundDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv));
					float surfaceDepth = UNITY_Z_0_FAR_FROM_CLIPSPACE(screenPos.z);
					float depthDifference = backgroundDepth - surfaceDepth;

					float3 backgroundColor = tex2D(_WaterBackground, uv).rgb;
					float fogFactor = exp2(-_WaterFogDensity * depthDifference);

					float3 UnderwaterFog = lerp(_WaterFogColor, backgroundColor, fogFactor);

					float3 ColorAbsorption = float3(1, 1, 1) - _AbsorptionColor;
					float d = exp2(-depthDifference * _AbsorptionDepth);
					d = lerp(1, d, _AbsorptionStrength);
					ColorAbsorption = lerp(d, -ColorAbsorption, _AbsorptionColorStrength * (1.0 - d));

					return ColorAbsorption * UnderwaterFog;
				}

				//Caustics焦散
				//  -----------------------------------------------------------------------
				// 浅水处出现焦散现象
				float3 _SplitRGB;
				sampler2D _CausticsTex;
				float4 _Caustics1_ST, _Caustics2_ST;
				float _Caustics1_Speed, _Caustics2_Speed, _CausticsStrength;
				sampler2D _CameraGBufferTexture2;

				float3 CausticsColor(v2f i) {

					float2 uv = i.uv;
					float2 uvscreen = i.screenPos.xy / i.screenPos.w;

					float backgroundDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uvscreen));
					float surfaceDepth = UNITY_Z_0_FAR_FROM_CLIPSPACE(i.screenPos.z);
					float depthDifference = backgroundDepth - surfaceDepth;

					// 焦散会根据深度衰减
					float d = exp2(-depthDifference * _CausticsAtten);
					float3 backgroundColor = tex2D(_WaterBackground, uvscreen).rgb;
					float3 causticsAtten = backgroundColor * d;

					uv = i.uv * _Caustics1_ST.xy + _Caustics1_ST.zw;
					float2 uv2 = i.uv * _Caustics2_ST.xy + _Caustics2_ST.zw;
					uv += _Caustics1_Speed * _Time.y;
					uv2 += _Caustics2_Speed * _Time.y;

					float3 gNormal = tex2Dproj(_CameraGBufferTexture2, UNITY_PROJ_COORD(i.grabtex)).rgb;
					gNormal = gNormal * 2 - 1;

					// RGB splits
					// 通过分离RGB通道模拟虹光色散效果
					// ref:https://www.alanzucconi.com/2019/09/13/believable-caustics-reflections/
					float s1 = _SplitRGB;
					float r1 = tex2D(_CausticsTex, uv + float2(+s1, +s1)).r;
					float g1 = tex2D(_CausticsTex, uv + float2(+s1, -s1)).g;
					float b1 = tex2D(_CausticsTex, uv + float2(-s1, -s1)).b;

					float s2 = _SplitRGB;
					float r2 = tex2D(_CausticsTex, uv2 + float2(+s2, +s2)).r;
					float g2 = tex2D(_CausticsTex, uv2 + float2(+s2, -s2)).g;
					float b2 = tex2D(_CausticsTex, uv2 + float2(-s2, -s2)).b;

					//将焦散定位到水底而非浮在水面（一个大致的位置
					// ref: Lux Water https://assetstore.unity.com/packages/vfx/shaders/lux-water-119244
					float3 caustics1 = float3(r1, g1, b1) * saturate((gNormal.y - 0.125) * _Test);
					float3 caustics2 = float3(r2, g2, b2) * saturate((gNormal.y - 0.125) * 2);
					float3 col1 = min(caustics1, caustics2);

					caustics1 = float3(r1, g1, b1) * saturate((gNormal.y - 0.125) * -100);
					caustics2 = float3(r2, g2, b2) * saturate((gNormal.y - 0.125) * -100);
					float3 col2 = min(caustics1, caustics2);

					float3 col = col1 +col2;

					float3 final = causticsAtten * col * _CausticsStrength;
					return final;
				}

				// Foam
				//  -----------------------------------------------------------------------
				// 物体与水面交界处存在浮沫
				float3 WaterFoam(v2f i) {
					float depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos))); // depth
					
					float4 edgeBlendFactors = 1 - saturate(_FoamWidth * (depth - i.screenPos.w));
					//float4 waterBlendFactors = saturate(_FoamWidth * (depth - i.screenPos.w));
					float2 uv = i.uv * _FoamTex_ST.xy + _FoamTex_ST.zw;
					uv += _FoamSpeed * max(_FlowSpeed, 0.01) * _Time.y;
					float4 foamtex = tex2D(_FoamTex, uv);

					float4 final = _FoamColor * step(_FoamCutoff, foamtex) * foamtex * edgeBlendFactors;
					return final.x;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					float4 lightColor = _LightColor0.rgba;
					float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
					float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
										
					// FlowMap流型图
					//  -----------------------------------------------------------------------
					// 这里用FlowMap来修改水面法线模拟水面波光
					// 通过更改流速也可模拟湍急河流
					// ref: Catlike Coding https://catlikecoding.com/unity/tutorials/flow/looking-through-water/			
					float2 jump = float2(_UJump, _VJump);

					float3 flow = tex2D(_FlowMap, i.uv).rgb;
					flow.xy = flow.xy * 2 - 1;
					flow *= _FlowStrength;

					float noise = tex2D(_FlowMap, i.uv).a;
					float time = _Time.y * _FlowSpeed + noise;

					float finalHeightScale = flow.z * _HeightScaleModulated + _HeightScale;

					float3 uvwA = FlowUVW(i.uv, flow.xy, jump, _FlowOffset, _Tiling, time, false);
					float3 uvwB = FlowUVW(i.uv, flow.xy, jump, _FlowOffset, _Tiling, time, true);

					float3 dhA =
						UnpackDerivativeHeight(tex2D(_DerivHeightMap, uvwA.xy)) *
						(uvwA.z * finalHeightScale);
					float3 dhB =
						UnpackDerivativeHeight(tex2D(_DerivHeightMap, uvwB.xy)) *
						(uvwB.z * finalHeightScale);

					i.normal += (float3(-(dhA.x + dhB.x), 1, -(dhA.y + dhB.y)));
					i.normal = normalize(i.normal);

					float4 texA = tex2D(_MainTex, uvwA.xy) * uvwA.z;
					float4 texB = tex2D(_MainTex, uvwB.xy) * uvwB.z;

					float4 col = 1;
					
					// underwater color
					col.rgb *= ColorBelowWater(i);

					// 光照模型为BlinnPhong
					//  -----------------------------------------------------------------------
					float3 halfVec = normalize(lightDir + viewDir);
					float diff = max(dot(i.normal, lightDir), 0.0001);
					float NdotH = max((dot(i.normal, halfVec)), 0.0001);
					float spec = pow(NdotH, _SpecularPower) * _Glossiness;
					float4 albedo = _Tint * (texA + texB);
					col *= albedo * lightColor * diff;

					col += _SpecularColor * spec;

					// cubemap reflection
					if (enableReflection) {
						float3 reflectedDir = reflect(-viewDir, normalize(i.normal));		
						//float3 envSample = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectedDir, _Test);
						float3 cubetex = texCUBE(_Cube, reflectedDir).rgb;
						col.xyz *= 2 * normalize(saturate(_CubemapSmooth * cubetex));
					}			

					// caustics
					if (enableCaustics) {
						float3 CausticsCol = CausticsColor(i);
						col.rgb += CausticsCol;						
					}

					// foam
					if (enableFoam) {
						float3 FoamCol = WaterFoam(i);
						col.rgb += FoamCol;
					}
					
					col *= lightDir.y;//day scycle

			       
					col.a = albedo.a;

					return col;
				}
				ENDCG
			}
		}

}
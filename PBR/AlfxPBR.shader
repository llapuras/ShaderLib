Shader "Alfx/AlfxPBR"
{
	Properties
	{
		//Debug
		[Header(Debug Mode)]
		[MaterialToggle] EnableDiffuse("Enable Diffuse", Float) = 1
		[MaterialToggle] EnableSpecular("Enable Specular", Float) = 1
		[MaterialToggle] EnableSH("Enable Sphereric Harmonics", Float) = 1
		[MaterialToggle] EnableShadow("Enable Self Shadow", Float) = 1
		[MaterialToggle] EnableDetail("Enable Detail", Float) = 1

		[MaterialToggle] DebugNormalMode("Debug Normal Mode", Float) = 0

		[MaterialToggle] aD("D", Float) = 1
		[MaterialToggle] aF("F", Float) = 1
		[MaterialToggle] aG("G", Float) = 1

		//Param
		[Header(Parameters)]
		_Tint("Tint", Color) = (1 ,1 ,1 ,1)
		_FresnelColor("Fresnel Color (F0)", Color) = (1.0, 1.0, 1.0, 1.0)

		_Metallic("Metallic", Range(0, 1)) = 0
		_Roughness("Roughness", Range(0, 1)) = 0.5

		_Anisotropy("Anisotropy", Range(0,1)) = 0

		_ClearCoat("ClearCoat", Range(0,1)) = 0

		[Header(Textures)]
		_MainTex("Basecolor Map", 2D) = "white" {}
		_DetailTex("Detail Map", 2D) = "white" {}
		_NormalMap("Normal Map", 2D) = "bump" {}
		_DetailNormalMap("Detail Normal Map", 2D) = "bump" {}
		_MetalnessMap("Metalness Map", 2D) = "black" {}
		_RoughnessMap("Roughness Map", 2D) = "black" {}
		_OcclusionMap("Occlusion Map", 2D) = "white" {}

		//unfinished
		_BrdfMap("BRDF Map", 2D) = "white" {}
	}

	SubShader
		{
			Tags { "RenderType" = "Opaque" }

			Pass
			{
				Tags {
					"LightMode" = "ForwardBase"
				}
				CGPROGRAM

				#pragma target 3.0
				#pragma multi_compile_fwdbase

				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"
				#include "AlfxPBRLib.cginc"
				#include "Lighting.cginc"
				#include "AutoLight.cginc" 

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent: TANGENT;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION; //要用unity那套shadow这里必须按appdata_base的结构命名为pos不然会报错 = - =
				float2 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 tangent: TEXCOORD2;
				float3 bitangent: TEXCOORD3;
				float3 worldPos : TEXCOORD4;

				float3 tangentLocal: TEXCOORD5;
				float3 bitangentLocal: TEXCOORD6;

				float2 uv2 : TEXCOORD9;

				LIGHTING_COORDS(7, 8)
				};

				float4 _Tint, _FresnelColor;
				float _ClearCoat, _Metallic, _Roughness, _Anisotropy;
				sampler2D _MainTex, _DetailTex, _RoughnessMap, _NormalMap, _DetailNormalMap, _MetalnessMap, _OcclusionMap, _BrdfMap;
				float4 _MainTex_ST, _DetailTex_ST, _RoughnessMap_ST, _NormalMap_ST, _DetailNormalMap_ST, _MetalnessMap_ST, _OcclusionMap_ST;

				//debug
				int EnableDiffuse, EnableSpecular, aD, aF, aG, DebugNormalMode, EnableSH, EnableShadow, EnableDetail;

				v2f vert(appdata v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.worldPos = mul(unity_ObjectToWorld, v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					o.uv2 = TRANSFORM_TEX(v.uv, _DetailTex);

					// Normal mapping parameters
					half3 wNormal = UnityObjectToWorldNormal(v.normal);
					half3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);
					half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
					half3 wBitangent = cross(wNormal, wTangent) * tangentSign;
					o.tangent = normalize(mul(unity_ObjectToWorld, v.tangent).xyz);
					o.normal = normalize(UnityObjectToWorldNormal(v.normal));
					o.bitangent = normalize(cross(o.normal, o.tangent.xyz));

					o.tangentLocal = o.tangent;
					o.bitangentLocal = normalize(cross(o.normal, o.tangentLocal));

					TRANSFER_VERTEX_TO_FRAGMENT(o);
					return o;
				}

				float4 frag(v2f i) : COLOR
				{
					float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
					float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
					float3 lightColor = _LightColor0.rgb;
					float3 halfVec = normalize(lightDir + viewDir);

					//normal map
					float3x3 TBN = transpose(float3x3(i.tangent, i.bitangent, i.normal));
					float3 normal = UnpackNormal(tex2D(_NormalMap, i.uv)) + ((EnableDetail == 1)?UnpackNormal(tex2D(_DetailNormalMap, i.uv2)):0); //！！！不要忘记unpack= - =
					normal = mul(TBN, normalize(normal));
					i.normal = normal;

					// This assumes that the maximum param is right if both are supplied (range and map)
					float roughness = max(max(_Roughness, tex2D(_RoughnessMap, i.uv).r), EPS);
					float metalness = max(max(_Metallic + EPS, tex2D(_MetalnessMap, i.uv).r), EPS);
					float occlusion = (tex2D(_OcclusionMap, i.uv).r);

					float4 baseColor = tex2D(_MainTex, i.uv) * ((EnableDetail == 1)?tex2D(_DetailTex, i.uv2):1) * _Tint;
					float4 albedo = baseColor * (1.0 - metalness);

					// EPS-防止极值异常情况
					float NdotL = max((dot(i.normal, lightDir)), EPS);
					float NdotH = max((dot(i.normal, halfVec)), EPS);
					float HdotV = max((dot(halfVec, viewDir)), EPS);
					float NdotV = max((dot(i.normal, viewDir)), EPS);
					float HdotL = max((dot(halfVec, lightDir)), EPS);
					float HdotT = dot(halfVec, i.tangentLocal);
					float HdotB = dot(halfVec, i.bitangentLocal);

					//----------------------------------------
					//DisneyDiffuse
					float3 DisneyTerm = DisneyDiffuse(albedo, NdotV, NdotL, HdotV, roughness);

					//----------------------------------------
					//D-法线分布函数
					float D1 = IsotropyNDF1(NdotH, roughness);
					float D2 = IsotropyNDF2(NdotH, roughness);
					float D3 = AnisotropyNDF(NdotH, roughness, _Anisotropy, HdotT, HdotB);//anisptropy
					float D = (_Anisotropy==0?D1:D3) + D1*_ClearCoat;

					//G-遮蔽
					float G = GGX(NdotL, NdotV, roughness);

					//F-fresnel
					float3 F0 = F0_X(0.04, _FresnelColor, metalness);
		    		float3 F = FresnelTerm(F0, HdotV);
					
					//漫反射系数
					float3 kd = (1 - F) * (1 - metalness);

					float3 Gterm = ((G * aG != 0) ? G : 1);
					float3 Dterm = ((D * aD != 0) ? D : 1);
					float3 Fterm = ((F * aF != 0) ? F : 1);
					float3 SpecularResult = (aD + aF + aG == 0 ? 0 : (Gterm * Dterm * Fterm * 0.25) / (NdotV * NdotL));

					float3 diffColor_result = kd * DisneyTerm * EnableDiffuse * lightColor * albedo;
					float3 specColor_result = SpecularResult * EnableSpecular * lightColor * albedo;
					float3 DirectLightResult = diffColor_result + specColor_result;

					//----------------------------------------
					// indirectal light
					//----------------------------------------

					// ibldiffuse
					// SH skylight
					float3 ambient = SH3band(i.normal, albedo, 3);
					
					// BRDF integration Map
					// float2 brdfUV = float2(NdotV, _Roughness);
					// float2 envBRDF = tex2D(_BrdfMap, brdfUV).xy;
					// float3 Flast = fresnelSchlickRoughness(max(NdotV, 0.0), F0, roughness);
					// float kdLast = (1 - Flast) * (1 - _Metallic);

					float mip_roughness = roughness * (1.7 - 0.7 * roughness);
					float3 reflectVec = reflect(-viewDir, i.normal);
					half mip = mip_roughness * UNITY_SPECCUBE_LOD_STEPS;
					float3 envSample = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectVec, mip);//获取当前使用env贴图
					
					float3 iblDiffuseResult = (EnableSH == 1) ? ambient * envSample * albedo : 0;

					// iblspecular-尚未完成
					float3 iblSpecular = 0;
					float3 iblSpecularResult = iblSpecular;
					float3 IndirectResult = iblDiffuseResult + iblSpecularResult;

					// shadow
					float attenuation = LIGHT_ATTENUATION(i) * 1;
					float3 attenColor = (EnableShadow == 1) ? attenuation : 1;

					float4 result = float4((DirectLightResult + IndirectResult) * attenColor * occlusion, 1);
					result.xyz = (DebugNormalMode == 1) ? i.normal * 0.5 + 0.5 : result.xyz;

					return result;
				}
				ENDCG
			}
		}
	FallBack "Legacy Shaders/Diffuse" //for shadow
	
}
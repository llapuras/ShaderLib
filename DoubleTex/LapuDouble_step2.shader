Shader "Lapu/LapuDoubleTex_step2" {
    Properties{
        _Color("Primary Color", Color) = (1,1,1,1)
        _MainTex("Primary (RGB)", 2D) = "white" {}
        _Color2("Secondary Color", Color) = (1,1,1,1)
        _SecondTex("Secondary (RGB)", 2D) = "white" {}
 
        _DisAmount("Noise Texture Opacity", Range(0.01, 1)) = 0.01
        _Radius("Radius", Range(0, 10)) = 0
        _SphereIntensity("Sphere Intensity", Range(0, 10)) = 1
        _EmissionIntensity("Emission Intensity", Range(0, 10)) = 0.5
    }

        SubShader{
            Tags { "RenderType" = "Transparent" }
            LOD 200

        CGPROGRAM

        #pragma surface surf Lambert 

        float3 _Position; // from script

        sampler2D _MainTex, _SecondTex;
        float4 _Color, _Color2;
        float _Radius, _EmissionIntensity, _SphereIntensity, _DisAmount;

        struct Input {
            float2 uv_MainTex : TEXCOORD0;
            float3 worldPos;// built in value to use the world space position
            float3 worldNormal; // built in value for world normal
        };

        void surf(Input IN, inout SurfaceOutput o) {
            half4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            half4 c2 = tex2D(_SecondTex, IN.uv_MainTex) * _Color2;

            float3 dis = distance(_Position, IN.worldPos);
            float3 sphere = 1 - saturate(dis / _Radius);
            sphere = saturate(sphere * _SphereIntensity);

            float3 DissolveLine = step(sphere, _DisAmount) * step(_DisAmount, sphere);

            float3 primaryTex = step(sphere, _DisAmount) * c.rgb;
            float3 secondaryTex = step(_DisAmount, sphere) * c2.rgb;
            float3 resultTex = primaryTex + secondaryTex + DissolveLine;
            o.Albedo = resultTex;

            o.Emission = DissolveLine * _EmissionIntensity;
            o.Alpha = c.a;

        }
        ENDCG

        }

        Fallback "Diffuse"
}
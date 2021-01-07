#define PI 3.14159265359
#define EPS 0.0001

float Pow4(float v)
{
    return v * v * v * v;
}

float Pow5(float v)
{
    return v * v * v * v * v;
}

//NDF
float IsotropyNDF1(float NdotH, float roughness)
{
    float alpha = Pow4(roughness) + 0.005;
    float NdotH2 = NdotH*NdotH;
    float denominator = (alpha-1)*NdotH2+1;
    return (alpha-1)/(log(alpha)*denominator);
}

float IsotropyNDF2(float NdotH, float roughness)
{
    float alpha = Pow4(roughness)  + 0.005;
    float NdotH2 = NdotH*NdotH;
    float denominator = (alpha-1)*NdotH2+1;
    return alpha/(denominator*denominator);
}


float AnisotropyNDF(float NdotH, float roughness, float anisotropy, float HdotT, float HdotB)
{
    float aspect = sqrt(1.0 - 0.9 * anisotropy);
    float alpha = roughness * roughness;

    float roughT = alpha / aspect;
    float roughB = alpha * aspect;
    // roughT = alpha*(1+aspect);
    // roughB = alpha*(1-aspect);

    float alpha2 = alpha * alpha;
    float NdotH2 = NdotH * NdotH;
    float HdotT2 = HdotT * HdotT;
    float HdotB2 = HdotB * HdotB;

    float denominator = roughT * roughB * pow(HdotT2 / (roughT * roughT) + HdotB2 / (roughB * roughB) + NdotH2, 2);
    return 1 / denominator;
} 

// float AnisotropyNDF(float scale, float NdotH, float roughness, float anisotropy, float HdotT, float HdotB)
// {
//     float aspect = sqrt(1.0 - 0.9 * anisotropy);
//     float alpha = roughness * roughness;

//     float roughT = alpha / aspect;
//     float roughB = alpha * aspect;

//     float alpha2 = alpha * alpha;
//     float NdotH2 = NdotH * NdotH;
//     float HdotT2 = HdotT * HdotT;
//     float HdotB2 = HdotB * HdotB;

//     float denominator = roughT * roughB *pow(HdotT2 / (roughT * roughT) + HdotB2 / (roughB * roughB) + NdotH2, 2);
//     return scale / denominator;
// } 



// float AnisotropyNDF(float dotHX, float dotHY, float dotNH, float ax, float ay)
// {
//     float deno = dotHX * dotHX / (ax * ax) + dotHY * dotHY / (ay * ay) + dotNH * dotNH;
//     return 1.0 / (PI * ax * ay * deno * deno);
// }

// Disney漫反射
float3 DisneyDiffuse(float3 col, float HdotV, float NdotV, float NdotL, float roughness)
{
    float F90 = 0.5 + 2 * roughness * HdotV * HdotV;
    float FdV = 1 + (F90 - 1) * Pow5(1 - NdotV);
    float FdL = 1 + (F90 - 1) * Pow5(1 - NdotL);
    return FdV * FdL;
}

// Schlick Fresnel
float3 FresnelTerm(float3 F0, float NdotV)
{
    return F0 + (1 - F0) * Pow5(1 - NdotV);
}

float3 F0_X(float lerpvalue, float3 col, float metalness)
{
    return lerp(float3(lerpvalue, lerpvalue, lerpvalue), col, metalness);
}

// GGX
float GGX(float NdotL, float NdotV, float roughness)
{
    float kInDirectLight = pow(Pow4(roughness) + 1, 2) / 8;
    float kInIBL = pow(Pow4(roughness), 2) / 8;
    float GLeft = NdotL / lerp(NdotL, 1, kInDirectLight);
    float GRight = NdotV / lerp(NdotV, 1, kInDirectLight);
    return GLeft * GRight;
}

//SH
float3 SH3band(float3 normal, float3 albedo, int band) 
{
    float3 skyLightBand2 = SHEvalLinearL0L1(float4(normal, 1));
    float3 skyLightBand3 = ShadeSH9(float4(normal, 1));
    return ((band == 2)? skyLightBand2 : skyLightBand3) * albedo * 50; //*50加大天光影响
}

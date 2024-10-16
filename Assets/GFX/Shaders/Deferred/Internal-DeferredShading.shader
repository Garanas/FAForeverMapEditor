Shader "Hidden/Internal-DeferredShading" {
Properties {
    _LightTexture0 ("", any) = "" {}
    _LightTextureB0 ("", 2D) = "" {}
    _ShadowMapTexture ("", any) = "" {}
    _SrcBlend ("", Float) = 1
    _DstBlend ("", Float) = 1

}
SubShader {

// Pass 1: Lighting pass
//  LDR case - Lighting encoded into a subtractive ARGB8 buffer
//  HDR case - Lighting additively blended into floating point buffer
Pass {
    ZWrite Off
    Blend [_SrcBlend] [_DstBlend]

CGPROGRAM

#define UNITY_BRDF_PBS BRDF_CUSTOM_Unity_PBS

#pragma multi_compile FANCY_STUFF_OFF FANCY_STUFF_ON
#pragma target 3.0
#pragma vertex vert_deferred
#pragma fragment frag
#pragma multi_compile_lightpass
#pragma multi_compile ___ UNITY_HDR_ON

#pragma exclude_renderers nomrt

#include "UnityCG.cginc"
#include "UnityDeferredLibrary.cginc"
//#include "UnityPBSLighting.cginc"
#include "UnityStandardUtils.cginc"
#include "UnityGBuffer.cginc"
#include "UnityStandardBRDF.cginc"
#include "UnityStandardBRDFCustom.cginc"

sampler2D _CameraGBufferTexture0;
sampler2D _CameraGBufferTexture1;
sampler2D _CameraGBufferTexture2;

uniform int _TTerrainXP;
uniform half LightingMultiplier;
uniform fixed4 SunColor;
uniform fixed4 SunDirection;
uniform fixed4 SunAmbience;
uniform fixed4 ShadowFillColor;
uniform fixed4 SpecularColor;



float4 CalculateLighting( float3 inNormal, float3 viewDirection, float3 inAlbedo, float specAmount, float shadow)
{
    float4 color = float4( 0, 0, 0, 0 );

    float SunDotNormal = dot( SunDirection, inNormal);
    float3 R = SunDirection - 2.0f * SunDotNormal * inNormal;
    float specular = pow( saturate( dot(R, viewDirection) ), 80) * SpecularColor.x * specAmount;

    float3 light = SunColor * saturate( SunDotNormal) * shadow + SunAmbience + specular;
    light = LightingMultiplier * light + ShadowFillColor * ( 1 - light );
    color.rgb = light * inAlbedo;
                
    color.a = 0.01f + (specular*SpecularColor.w);
    return color;
}

half4 CalculateLight (unity_v2f_deferred i)
{
    float3 wpos;
    float2 uv;
    float atten, fadeDist;
    UnityLight light;
    UNITY_INITIALIZE_OUTPUT(UnityLight, light);
    UnityDeferredCalculateLightParams (i, wpos, uv, light.dir, atten, fadeDist);

    light.color = _LightColor.rgb * atten;



    // unpack Gbuffer
    half4 gbuffer0 = tex2D (_CameraGBufferTexture0, uv);
    half4 gbuffer1 = tex2D (_CameraGBufferTexture1, uv);
    half4 gbuffer2 = tex2D (_CameraGBufferTexture2, uv);
    UnityStandardData data = UnityStandardDataFromGbuffer(gbuffer0, gbuffer1, gbuffer2);


    float3 eyeVec = normalize(wpos-_WorldSpaceCameraPos);
    half oneMinusReflectivity = 1 - SpecularStrength(data.specularColor.rgb);

    UnityIndirect ind;
    UNITY_INITIALIZE_OUTPUT(UnityIndirect, ind);
    ind.diffuse = 0;
    ind.specular = 0;


	float4 color;
    float3 albedo = gbuffer0.rgb;
    float albedoAlpha = gbuffer0.a;
    float3 waterColor = gbuffer1.rgb;
    float waterAbsorption = gbuffer1.a;
    float3 worldNormal = gbuffer2.rgb;
    float mapShadow = gbuffer2.a;

	color.rgb = albedo;

    worldNormal = worldNormal * 2 - 1;
    // The game is using a different coordinate system, so we need to correct for that
    worldNormal.z = worldNormal.z * -1;

    color.rgb = CalculateLighting(worldNormal, eyeVec, albedo, 1-albedoAlpha, atten);

    if (_TTerrainXP > 0) {
        // darken the color first to simulate the light absorption on the way in and out
        color *= 1 - waterAbsorption;
    }
    color.rgb = lerp(color.rgb, waterColor, waterAbsorption);

	color.a = 1;

    return color;
}

#ifdef UNITY_HDR_ON
half4
#else
fixed4
#endif
frag (unity_v2f_deferred i) : SV_Target
{
    half4 c = CalculateLight(i);
    #ifdef UNITY_HDR_ON
    return c;
    #else
    return exp2(-c);
    #endif
}

ENDCG
}


// Pass 2: Final decode pass.
// Used only with HDR off, to decode the logarithmic buffer into the main RT
Pass {
    ZTest Always Cull Off ZWrite Off
    Stencil {
        ref [_StencilNonBackground]
        readmask [_StencilNonBackground]
        // Normally just comp would be sufficient, but there's a bug and only front face stencil state is set (case 583207)
        compback equal
        compfront equal
    }

CGPROGRAM
#pragma target 3.0
#pragma vertex vert
#pragma fragment frag
#pragma exclude_renderers nomrt

#include "UnityCG.cginc"

sampler2D _LightBuffer;
struct v2f {
    float4 vertex : SV_POSITION;
    float2 texcoord : TEXCOORD0;
};

v2f vert (float4 vertex : POSITION, float2 texcoord : TEXCOORD0)
{
    v2f o;
    o.vertex = UnityObjectToClipPos(vertex);
    o.texcoord = texcoord.xy;
#ifdef UNITY_SINGLE_PASS_STEREO
    o.texcoord = TransformStereoScreenSpaceTex(o.texcoord, 1.0f);
#endif
    return o;
}

fixed4 frag (v2f i) : SV_Target
{
    return -log2(tex2D(_LightBuffer, i.texcoord));
}
ENDCG 
}

}
Fallback Off
}
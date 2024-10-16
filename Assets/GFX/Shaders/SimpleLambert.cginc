// for SurfaceOutputStandardSpecular
#include "UnityPBSLighting.cginc"

			
inline float4 LightingSimpleLambertLight(SurfaceOutputStandardSpecular s, UnityLight light)
{
    float4 c;
	c.rgb = s.Albedo;
	c.a = s.Alpha;
	return c;
}

inline fixed4 LightingSimpleLambert_PrePass(SurfaceOutputStandardSpecular s, half4 light)
{
	fixed4 c;
    c.rgb = s.Albedo;
	c.a = s.Alpha;
	return c;
}

inline fixed4 LightingSimpleLambert(SurfaceOutputStandardSpecular s, UnityGI gi)
{
	fixed4 c;
	c = LightingSimpleLambertLight (s, gi.light);

	return c;
}

inline half4 LightingSimpleLambert_Deferred(SurfaceOutputStandardSpecular s, UnityGI gi, out half4 outGBuffer0, out half4 outGBuffer1, out half4 outGBuffer2)
{
	UnityStandardData data;
	data.diffuseColor   = s.Albedo;
	data.occlusion      = s.Alpha;
    data.specularColor  = s.Specular;
    data.smoothness     = s.Smoothness;
	data.normalWorld    = s.Normal;

    outGBuffer0 = half4(data.diffuseColor, data.occlusion);

    outGBuffer1 = half4(data.specularColor, data.smoothness);

    outGBuffer2 = half4(data.normalWorld * 0.5f + 0.5f, s.Occlusion);

    half4 emission = half4(s.Emission, 1);
	return emission;
}

inline void LightingSimpleLambert_GI (
		SurfaceOutputStandardSpecular s,
		UnityGIInput data,
		inout UnityGI gi)
	{
		gi = UnityGlobalIllumination (data, 1.0, s.Normal);
	}
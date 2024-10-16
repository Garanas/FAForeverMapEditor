
struct CustomSurfaceOutput
{
    fixed3 Albedo;
    fixed3 WaterColor;
    float3 wNormal; // world space normal, we use this one to prevent the automatic tangent to world space conversion
    half3 Emission; // for overlays
    half WaterAbsorption; // how much the WaterColor gets applied
    half MapShadow; // manual terrain shadow that is defined by input texture
    half Roughness; // also used as alpha for transparencies
    
    // these only exist to make the surface shader compile and are unused
    float3 Normal;
    fixed Alpha;
};
			
inline float4 LightingSimpleLambertLight(CustomSurfaceOutput s, UnityLight light)
{
    float4 c;
	c.rgb = s.Albedo;
    c.a = s.Roughness;
	return c;
}

inline fixed4 LightingSimpleLambert_PrePass(CustomSurfaceOutput s, half4 light)
{
	fixed4 c;
    c.rgb = s.Albedo;
    c.a = s.Roughness;
	return c;
}

inline fixed4 LightingSimpleLambert(CustomSurfaceOutput s, UnityGI gi)
{
	fixed4 c;
	c = LightingSimpleLambertLight (s, gi.light);

	return c;
}

inline half4 LightingSimpleLambert_Deferred(CustomSurfaceOutput s, UnityGI gi, out half4 outGBuffer0, out half4 outGBuffer1, out half4 outGBuffer2)
{
    outGBuffer0 = half4(s.Albedo, s.Roughness);

    outGBuffer1 = half4(s.WaterColor, s.WaterAbsorption);

    outGBuffer2 = half4(s.wNormal * 0.5f + 0.5f, s.MapShadow);

    half4 emission = half4(s.Emission, 1);
	return emission;
}

inline void LightingSimpleLambert_GI (
		CustomSurfaceOutput s,
		UnityGIInput data,
		inout UnityGI gi)
	{
		gi = UnityGlobalIllumination (data, 1.0, s.wNormal);
	}
Shader "FAShaders/Water" {
	Properties {
		waterColor  ("waterColor", Color) = (0.0, 0.7, 1.5, 1)
		sunColor  ("Sun Color", Color) = (1.1, 0.7, 0.5, 1)
		_WaterData ("Water Data", 2D) = "white" {}
		SkySampler("SkySampler", CUBE) = "" {}
		ReflectionSampler ("ReflectionSampler", 2D) = "white" {}
		
		NormalSampler0 ("NormalSampler0", 2D) = "white" {}
		NormalSampler1 ("NormalSampler1", 2D) = "white" {}
		NormalSampler2 ("NormalSampler2", 2D) = "white" {}
		NormalSampler3 ("NormalSampler3", 2D) = "white" {}

		_GridScale ("Grid Scale", Range (0, 2048)) = 512
	}
    SubShader {
    	Tags { "Queue"="Transparent+6" "RenderType"="Transparent" }

	    GrabPass 
	     {
	     "RefractionSampler"
	     } 

		//Blend SrcAlpha OneMinusSrcAlpha
		//Offset 0, -20000


		CGPROGRAM
		#pragma target 3.5

		#pragma surface surf Lambert vertex:vert alpha noambient 
			#pragma exclude_renderers gles
			#pragma multi_compile ___ UNITY_HDR_ON


		//************ FA Water Params
		float4 ViewportScaleOffset;

		float waveCrestThreshold = 1;
		float3 waveCrestColor = float3(1,1,1);

		samplerCUBE SkySampler;
	    sampler2D NormalSampler0, NormalSampler1, NormalSampler2, NormalSampler3;
		sampler2D RefractionSampler;
	    sampler2D ReflectionSampler;
		sampler2D UtilitySamplerC;

	    float4 waterColor;
		float2 waterLerp;
		float refractionScale;
		float unitreflectionAmount;
		float skyreflectionAmount;

		float4 normalRepeatRate = float4(0.0009, 0.009, 0.05, 0.5);

		float2 normal1Movement = float2(5.5, -9.95);
		float2 normal2Movement = float2(0.05, -0.095);
		float2 normal3Movement = float2(0.01, 0.03);
		float2 normal4Movement = float2(0.0005, 0.0009);

		float SunShininess;
	    float3 SunDirection;
		float4 SunColor;

		//*********** End FA Water Params

		uniform float _WaterScaleX, _WaterScaleZ;
		half _GridScale;
		int _Area;
		half4 _AreaRect;
		
		sampler2D _WaterGrabTexture;


		struct Input {
	        //float4 position 	: 	SV_POSITION;
			float2 uvUtilitySamplerC : TEXCOORD0;
			float2 mLayer0;
			float2 mLayer1;
			float2 mLayer2;
			float2 mLayer3;
			//float2 mLayer2      : 	TEXCOORD3;
		    //float2 mLayer3      : 	TEXCOORD4;	
			float3 mViewVec     : 	TEXCOORD3;
			float4 mScreenPos	: 	TEXCOORD4;
			float4 AddVar		: 	TEXCOORD5;
			float2 mTexUV;
			float4 grabUV;
			float3 worldPos;
			//float3 viewDir;
		};

		void vert (inout appdata_full v, out Input result){
			UNITY_INITIALIZE_OUTPUT(Input,result);

	        result.mTexUV = v.vertex * float2(-1, 1) + float2(1 / _WaterScaleX + 1, 1 / _WaterScaleZ);
	        
	        result.mScreenPos = ComputeNonStereoScreenPos(UnityObjectToClipPos (v.vertex));

			float2 WaterLayerUv = float2(v.vertex.x * _WaterScaleX, -v.vertex.z * _WaterScaleZ);
			float timer = _Time.y * 10;
			result.mLayer0 = (WaterLayerUv + (normal1Movement * timer)) * normalRepeatRate.x;
	        result.mLayer1 = (WaterLayerUv + (normal2Movement * timer)) * normalRepeatRate.y;
	        result.mLayer2 = (WaterLayerUv + (normal3Movement * timer)) * normalRepeatRate.z;
	        result.mLayer3 = (WaterLayerUv + (normal4Movement * timer)) * normalRepeatRate.w;
	        
	        result.mViewVec = mul (unity_ObjectToWorld, v.vertex).xyz - _WorldSpaceCameraPos;

	        result.AddVar = float4(length(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertex).xyz), 0, 0, 0);
			float4 hpos = UnityObjectToClipPos (v.vertex);
	        result.grabUV = ComputeGrabScreenPos(hpos);
		}

		float FresnelSchlick(float dot, float F0)
		{
			return F0 + (1.0 - F0) * pow(1.0 - dot, 5.0);
		}

		float NormalDistribution(float3 n, float3 h, float roughness)
		{
			float a2 = roughness*roughness;
			float nDotH = max(dot(n, h), 0.0);
			float nDotH2 = nDotH*nDotH;

			float num = a2;
			float denom = nDotH2 * (a2 - 1.0) + 1.0;
			denom = 3.14159265359 * denom * denom;

			return num / denom;
		}

		float GeometrySchlick(float nDotV, float roughness)
		{
			float r = (roughness + 1.0);
			float k = (r*r) / 8.0;

			float num = nDotV;
			float denom = nDotV * (1.0 - k) + k;

			return num / denom;
		}

		float GeometrySmith(float3 n, float nDotV, float3 l, float roughness)
		{
			float nDotL = max(dot(n, l), 0.0);
			float gs2 = GeometrySchlick(nDotV, roughness);
			float gs1 = GeometrySchlick(nDotL, roughness);

			return gs1 * gs2;
		}

		float3 calculateSunReflection(float3 R, float3 v, float3 n)
		{
			float3 color;
			// Legacy fallback for the old behaviour, so we don't change all maps accidentally.
			// This check works because the default sun position is under the horizon.
			if (SunDirection.y < 0.0) {
				float3 sunReflection = pow(saturate(dot(-R, SunDirection)), SunShininess) * SunColor;
				color = sunReflection * FresnelSchlick(max(dot(n, v), 0.0), 0.06);
			} else {
			float roughness = 1.0 / SunShininess;
			float facingSpecular = 0.02;
			float3 l = SunDirection;
			float3 h = normalize(v + l);
			float nDotL = max(dot(n, l), 0.0);
			float nDotV = abs(dot(n, v)) + 0.001;
			float3 F = FresnelSchlick(max(dot(h, v), 0.0), facingSpecular).xxx;
			float NDF = NormalDistribution(n, h, roughness);
			float G = GeometrySmith(n, nDotV, l, roughness);

			float3 numerator = 3.14159265359 * NDF * G * F;
			// add 0.0001 to avoid division by zero
			float denominator = 4.0 * nDotV * nDotL + 0.0001;
			float3 reflected = numerator / denominator;
			color = reflected * SunColor * nDotL;
			}
			return color;
		}
	    
	   void surf (Input inV, inout SurfaceOutput o) {
	    
			// calculate the depth of water at this pixel
			float4 waterTexture = tex2D( UtilitySamplerC, inV.mTexUV );
			float waterDepth =  waterTexture.g;

			float3 viewVector = normalize(inV.mViewVec);

			// get perspective correct coordinate for sampling from the other textures
			// the screenPos is then in 0..1 range with the origin at the top left of the screen
			float OneOverW = 1.0 / inV.mScreenPos.w;
			inV.mScreenPos.xyz *= OneOverW;
			float2 screenPos = inV.mScreenPos.xy * ViewportScaleOffset.xy;
			screenPos += ViewportScaleOffset.zw;

			// get the unaltered sea floor
			float4 backGroundPixels = tex2D(RefractionSampler, screenPos);
			// because the alpha value holds the unit parts above water and uses a small value
			// for the land cutout, we multiply by a large number and then saturate
			float mask = saturate(backGroundPixels.a * 255);

			// calculate the normal we will be using for the water surface
			float4 W0 = tex2D( NormalSampler0, inV.mLayer0 );
			float4 W1 = tex2D( NormalSampler1, inV.mLayer1 );
			float4 W2 = tex2D( NormalSampler2, inV.mLayer2 );
			float4 W3 = tex2D( NormalSampler3, inV.mLayer3 );

			float4 sum = W0 + W1 + W2 + W3;
			float waveCrest = saturate( sum.a - waveCrestThreshold );
    
			// scale, bias and normalize
			float3 N = 2.0 * sum.xyz - 4.0;
			N = normalize(N.xzy); 
        
			float3 R = reflect(-viewVector, N);

			// get the correct coordinate for sampling refraction and reflection
			float2 refractionPos = screenPos;
			refractionPos -= sqrt(waterDepth) * refractionScale * N.xz * OneOverW;

			// keep in mind the alpha channel holds the unit parts above water
			// specifically the alpha channel of that unit's shader
			float4 refractedPixels = tex2D(RefractionSampler, refractionPos);

			// we need to exclude the unit refraction above the water line. This creats small areas with
			// no refraction, but the water color in the next step will make this mostly unnoticeable
			refractedPixels.xyz = lerp(refractedPixels, backGroundPixels, saturate(refractedPixels.a * 255)).xyz;
			// we want to lerp in the water color based on depth, but clamped
			float factor = clamp(waterDepth, waterLerp.x, waterLerp.y);
			refractedPixels.xyz = lerp(refractedPixels.xyz, waterColor, factor);

			// We can't compute wich part of the unit we would hit with our reflection vector,
			// so we have to resort to an approximation using the refractionPos
			float4 reflectedPixels = tex2D(ReflectionSampler, refractionPos);

			float4 skyReflection = texCUBE(SkySampler, R);
			// The alpha channel acts as a mask for unit parts above the water and probably
			// uses unitReflectionAmount as the positive value of the mask
			reflectedPixels.xyz = lerp(skyReflection.xyz, reflectedPixels.xyz, saturate(reflectedPixels.a));
   
   			// Schlick approximation for fresnel
			float NDotV = saturate(dot(viewVector, N));
			float fresnel = FresnelSchlick(NDotV, 0.08);

			// the default value of 1.5 is way to high, but we want to preserve manually set values in existing maps
			if (skyreflectionAmount == 1.5)
				skyreflectionAmount = 1.0;
			refractedPixels = lerp(refractedPixels, reflectedPixels, saturate(fresnel * skyreflectionAmount));

			// add in the sun reflection
			float3 sunReflection = calculateSunReflection(R, viewVector, N);
			// the sun shouldn't be visible where a unit reflection is
			sunReflection *= (1 - saturate(reflectedPixels.a * 4));
			// we can control this value to have terrain cast a shadow on the water surface
			sunReflection *= waterTexture.r;
			refractedPixels.xyz += sunReflection;

			// Lerp in the wave crests
			refractedPixels.xyz = lerp(refractedPixels.xyz, waveCrestColor, (1 - waterTexture.a) * (1 - waterTexture.b) * waveCrest);

			// return the pixels masked out by the water mask
			float4 returnPixels = refractedPixels;
			returnPixels.a = 1 - mask;


			if(_Area > 0){
				fixed3 BlackEmit = -1;
				fixed3 Albedo = 0;
				if(inV.worldPos.x < _AreaRect.x){
					returnPixels.rgb = 0;
				}
				else if(inV.worldPos.x > _AreaRect.z){
					returnPixels.rgb = 0;
				}
				else if(inV.worldPos.z < _AreaRect.y - _GridScale){
					returnPixels.rgb = 0;
				}
				else if(inV.worldPos.z > _AreaRect.w - _GridScale){
					returnPixels.rgb = 0;
				}
			}


			o.Albedo = 0;
			// By using the emission we bypass all shading operations by Unity
			o.Emission = returnPixels.rgb;
			o.Alpha = returnPixels.a;
	    }
    ENDCG  
    }
}
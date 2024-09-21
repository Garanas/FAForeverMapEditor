


Shader "FAShaders/TTerrain"
{
    Properties
    {
        _SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
	    _Shininess ("Shininess", Range (0.03, 1)) = 0.078125
	    [MaterialToggle] _Grid("Grid", Int) = 0
	    _GridType("Grid type", Int) = 0
	    [MaterialToggle] _Slope("Slope", Int) = 0
	    [MaterialToggle] _UseSlopeTex("Use Slope Data", Int) = 0
	    _SlopeTex ("Slope data", 2D) = "black" {}
		
	    // set by terrain engine
	    _Control ("Control (RGBA)", 2D) = "black" {}
	    _ControlXP ("ControlXP (RGBA)", 2D) = "black" {}
	    _Control2XP ("Control2XP (RGBA)", 2D) = "black" {}

	
	    [MaterialToggle] _HideSplat0("Hide splat 2", Int) = 0
	    [MaterialToggle] _HideSplat1("Hide splat 2", Int) = 0
	    [MaterialToggle] _HideSplat2("Hide splat 3", Int) = 0
	    [MaterialToggle] _HideSplat3("Hide splat 4", Int) = 0
	    [MaterialToggle] _HideSplat4("Hide splat 5", Int) = 0
	    [MaterialToggle] _HideSplat5("Hide splat 6", Int) = 0
	    [MaterialToggle] _HideSplat6("Hide splat 7", Int) = 0
	    [MaterialToggle] _HideSplat7("Hide splat 8", Int) = 0
	    [MaterialToggle] _HideSplat8("Hide splat Upper", Int) = 0
	    [MaterialToggle] _HideTerrainType("Hide Terrain Type", Int) = 0

	    _SplatAlbedoArray ("Albedo array", 2DArray) = "" {}
	    _SplatNormalArray ("Normal array", 2DArray) = "" {}


	    _Splat0Scale ("Splat1 Level", Range (1, 1024)) = 10
	    _Splat1Scale ("Splat2 Level", Range (1, 1024)) = 10
	    _Splat2Scale ("Splat3 Level", Range (1, 1024)) = 10
	    _Splat3Scale ("Splat4 Level", Range (1, 1024)) = 10
	    _Splat4Scale ("Splat5 Level", Range (1, 1024)) = 10
	    _Splat5Scale ("Splat6 Level", Range (1, 1024)) = 10
	    _Splat6Scale ("Splat7 Level", Range (1, 1024)) = 10
	    _Splat7Scale ("Splat8 Level", Range (1, 1024)) = 10

	    // set by terrain engine
	    [MaterialToggle] _GeneratingNormal("Generating Normal", Int) = 0
	    _TerrainNormal ("Terrain Normal", 2D) = "bump" {}
	

	    _Splat0ScaleNormal ("Splat1 Normal Level", Range (1, 1024)) = 10
	    _Splat1ScaleNormal ("Splat2 Normal Level", Range (1, 1024)) = 10
	    _Splat2ScaleNormal ("Splat3 Normal Level", Range (1, 1024)) = 10
	    _Splat3ScaleNormal ("Splat4 Normal Level", Range (1, 1024)) = 10
	    _Splat4ScaleNormal ("Splat5 Normal Level", Range (1, 1024)) = 10
	    _Splat5ScaleNormal ("Splat6 Normal Level", Range (1, 1024)) = 10
	    _Splat6ScaleNormal ("Splat7 Normal Level", Range (1, 1024)) = 10
	    _Splat7ScaleNormal ("Splat8 Normal Level", Range (1, 1024)) = 10

	    // used in fallback on old cards & base map
	    [HideInInspector] _MainTex ("BaseMap (RGB)", 2D) = "white" {}
	    [HideInInspector] _Color ("Main Color", Color) = (1,1,1,1)

	    [MaterialToggle] _Brush ("Brush", Int) = 0
	    [MaterialToggle] _BrushPainting ("Brush painting", Int) = 0
	    _BrushTex ("Brush (RGB)", 2D) = "white" {}
	    _BrushSize ("Brush Size", Range (0, 128)) = 0
	    _BrushUvX ("Brush X", Range (0, 1)) = 0
	    _BrushUvY ("Brush Y", Range (0, 1)) = 0

	    //Lower Stratum
	    _SplatLower ("Layer Lower (R)", 2D) = "white" {}
	    _NormalLower ("Normal Lower (R)", 2D) = "bump" {}
	    _LowerScale ("Lower Level", Range (1, 128)) = 1
	    _LowerScaleNormal ("Lower Normal Level", Range (1, 128)) = 1

	    //Upper Stratum
	    _SplatUpper ("Layer Lower (R)", 2D) = "white" {}
	    _NormalUpper ("Normal Lower (R)", 2D) = "bump" {}
	    _UpperScale ("Upper Level", Range (1, 128)) = 1
	    _UpperScaleNormal ("Upper Normal Level", Range (1, 128)) = 1

	    _GridScale ("Grid Scale", Range (0, 2048)) = 512
	    _GridTexture ("Grid Texture", 2D) = "white" {}

	    _TerrainTypeAlbedo ("Terrain Type Albedo", 2D) = "black" {}
	    _TerrainTypeCapacity ("Terrain Type Capacity", Range(0,1)) = 0.228
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex TerrainVS
            #pragma fragment fragmentShader
            #pragma target 3.5


            sampler2D _MyGrabTexture3;
			sampler2D _WaterRam;
			half _Shininess;
			fixed4 _Abyss;
			fixed4 _Deep;
			int _Water;
			float _WaterLevel;
            fixed4 _ShadowColor;

			int _Slope, _UseSlopeTex;
			sampler2D _SlopeTex;

			int _Grid, _GridType;
			half _GridScale;
			half _GridCamDist;
			sampler2D _GridTexture;

			//uniform
			sampler2D _ControlXP;
			sampler2D _Control2XP;
			uniform sampler2D _UtilitySamplerC;
			sampler2D _TerrainNormal;
			sampler2D _SplatLower, _SplatUpper;
			sampler2D _TerrainTypeAlbedo;
			sampler2D  _NormalLower;
			half _Splat0Scale, _Splat1Scale, _Splat2Scale, _Splat3Scale, _Splat4Scale, _Splat5Scale, _Splat6Scale, _Splat7Scale;
			half _Splat0ScaleNormal, _Splat1ScaleNormal, _Splat2ScaleNormal, _Splat3ScaleNormal, _Splat4ScaleNormal, _Splat5ScaleNormal, _Splat6ScaleNormal, _Splat7ScaleNormal;

			UNITY_DECLARE_TEX2DARRAY(_SplatAlbedoArray);
			 UNITY_DECLARE_TEX2DARRAY(_SplatNormalArray);

			int _HideSplat0, _HideSplat1, _HideSplat2, _HideSplat3, _HideSplat4, _HideSplat5, _HideSplat6, _HideSplat7, _HideSplat8;
			int _HideTerrainType;
			float _TerrainTypeCapacity;
		
			half _LowerScale, _UpperScale;
			half _LowerScaleNormal, _UpperScaleNormal;
			uniform int _TTerrainXP;
			uniform float _WaterScaleX, _WaterScaleZ;

			int _Brush, _BrushPainting;
			sampler2D _BrushTex;
			half _BrushSize;
			half _BrushUvX;
			half _BrushUvY;

			uniform int _Area;
			uniform half4 _AreaRect;

            ////////
            // compatibility section
            ////////

            // defined by game settings or console commands
            int ShadowsEnabled;
            float ShadowSize;

            float3 ShadowFillColor = _ShadowColor;
            float LightingMultiplier = _LightingMultiplier;
            float3 SunDirection = ?;
            float3 SunAmbience = _SunAmbience;
            float3 SunColor = _SunColor;
            float4 SpecularColor = _SpecColor;
            float WaterElevation = _WaterLevel;
            float WaterElevationDeep = _Deep;
            float WaterElevationAbyss = _Abyss;

            float4 LowerAlbedoTile = _GridScale / _LowerScale;
            float4 LowerNormalTile  = _GridScale / _LowerScaleNormal;
            float4 Stratum0AlbedoTile = _GridScale / _Splat0Scale;
            float4 Stratum1AlbedoTile = _GridScale / _Splat1Scale;
            float4 Stratum2AlbedoTile = _GridScale / _Splat2Scale;
            float4 Stratum3AlbedoTile = _GridScale / _Splat3Scale;
            float4 Stratum4AlbedoTile = _GridScale / _Splat4Scale;
            float4 Stratum5AlbedoTile = _GridScale / _Splat5Scale;
            float4 Stratum6AlbedoTile = _GridScale / _Splat6Scale;
            float4 Stratum7AlbedoTile = _GridScale / _Splat7Scale;
            float4 Stratum0NormalTile = _GridScale / _Splat0ScaleNormal;
            float4 Stratum1NormalTile = _GridScale / _Splat1ScaleNormal;
            float4 Stratum2NormalTile = _GridScale / _Splat2ScaleNormal;
            float4 Stratum3NormalTile = _GridScale / _Splat3ScaleNormal;
            float4 Stratum4NormalTile = _GridScale / _Splat4ScaleNormal;
            float4 Stratum5NormalTile = _GridScale / _Splat5ScaleNormal;
            float4 Stratum6NormalTile = _GridScale / _Splat6ScaleNormal;
            float4 Stratum7NormalTile = _GridScale / _Splat7ScaleNormal;
            float4 UpperAlbedoTile = _GridScale / _UpperScale;
            float4 UpperNormalTile = _GridScale / _UpperScaleNormal;

            sampler2D Stratum0AlbedoSampler;
            //...

            float4 TerrainScale = 1 / _GridScale; 
            samplerCube environmentSampler;
            sampler2D ShadowSampler;
            // masks of stratum layers 1 - 4
            sampler2D UtilitySamplerA;
            // masks of stratum layers 5 - 8
            sampler2D UtilitySamplerB;
            // red: wave normal strength
            // green: water depth
            // blue: ???
            // alpha: foam reduction
            sampler2D UtilitySamplerC;
            sampler WaterRampSampler;



            

            typedef float4 position_t;


            struct VS_OUTPUT
            {
                float4 mPos                    : POSITION0;
                float4 mTexWT                : TEXCOORD1;
                float4 mTexSS                : TEXCOORD2;
                float4 mShadow              : TEXCOORD3;
                float3 mViewDirection        : TEXCOORD4;
                float4 mTexDecal            : TEXCOORD5;
                // We store some texture scales here to be able to save some memory registers
                // in the pixel shader as the stratumTiles only have one float of actual data,
                // but use four and we are pretty tight on register slots in the new shaders.
                float4 nearScales           : TEXCOORD6;
                float4 farScales            : TEXCOORD7;
            };

            bool IsExperimentalShader() {
                // The tile value basically says how often the texture gets repeated on the map.
                // A value less than one doesn't make sense under normal conditions, so it is
                // relatively save to use it as our switch.

                // in order to trigger this you can set the albedo scale to be bigger than the map 
                // size. Use the value 10000 to be safe for any map
                return UpperAlbedoTile.x < 1.0;
            }

            float3 ApplyWaterColor(float terrainHeight, float waterDepth, float3 color)
            {
                if (waterDepth > 0) {
                    float4 waterColor = tex1D(WaterRampSampler, waterDepth);
                    color = lerp(color.xyz, waterColor.rgb, waterColor.a);
                }
                return color;
            }

            float3 ApplyWaterColorExponentially(float3 viewDirection, float terrainHeight, float waterDepth, float3 color)
            {
                if (waterDepth > 0) {
                    float3 up = float3(0,1,0);
                    // this is the length that the light travels underwater back to the camera
                    float oneOverCosV = 1 / max(dot(up, normalize(viewDirection)), 0.0001);
                    // Light gets absorbed exponentially,
                    // to simplify, we assume that the light enters vertically into the water.
                    // We need to multiply by 2 to reach 98% absorption as the waterDepth can't go over 1.
                    float waterAbsorption = 1 - saturate(exp(-waterDepth * 2 * (1 + oneOverCosV)));
                    // darken the color first to simulate the light absorption on the way in and out
                    color *= 1 - waterAbsorption;
                    // lerp in the watercolor to simulate the scattered light from the dirty water
                    float4 waterColor = tex1D(WaterRampSampler, waterAbsorption);
                    color = lerp(color, waterColor.rgb, waterAbsorption);
                }
                return color;
            }

            float4 CalculateLighting( float3 inNormal, float3 worldTerrain, float3 inAlbedo, float specAmount, float waterDepth, float4 inShadow)
            {
                float4 color = float4( 0, 0, 0, 0 );

                float shadow = ComputeShadow( inShadow );
                if (IsExperimentalShader()) {
                    float3 position = TerrainScale * worldTerrain;
                    float mapShadow = tex2D(UpperAlbedoSampler, position.xy).w;
                    shadow = shadow * mapShadow;
                }

                // calculate some specular
                float3 viewDirection = normalize(worldTerrain.xzy-CameraPosition);

                float SunDotNormal = dot( SunDirection, inNormal);
                float3 R = SunDirection - 2.0f * SunDotNormal * inNormal;
                float specular = pow( saturate( dot(R, viewDirection) ), 80) * SpecularColor.x * specAmount;

                float3 light = SunColor * saturate( SunDotNormal) * shadow + SunAmbience + specular;
                light = LightingMultiplier * light + ShadowFillColor * ( 1 - light );
                color.rgb = light * inAlbedo;

                if (IsExperimentalShader()) {
                    color.rgb = ApplyWaterColorExponentially(-viewDirection, worldTerrain.z, waterDepth, color);
                } else {
                    color.rgb = ApplyWaterColor(worldTerrain.z, waterDepth, color);
                }

                color.a = 0.01f + (specular*SpecularColor.w);
                return color;
            }

            float3 PBR(VS_OUTPUT inV, float4 position, float3 albedo, float3 n, float roughness, float waterDepth) {
                // See https://blog.selfshadow.com/publications/s2013-shading-course/

                float shadow = 1;
                float mapShadow = tex2D(UpperAlbedoSampler, position.xy).w; // 1 where sun is, 0 where shadow is
                shadow = tex2D(ShadowSampler, inV.mShadow.xy).g; // 1 where sun is, 0 where shadow is
                shadow *= mapShadow;


                float facingSpecular = 0.04;
                // using only the texture looks bad when zoomed in, using only the mesh 
                // looks bad when zoomed out, so we interpolate between both
                float underwater = step(inV.mTexWT.z, WaterElevation);
                facingSpecular *= 1 - 0.9 * underwater;

                float3 v = normalize(-inV.mViewDirection);
                float3 F0 = float3(facingSpecular, facingSpecular, facingSpecular);
                float3 l = SunDirection;
                float3 h = normalize(v + l);
                float nDotL = max(dot(n, l), 0.0);
                // Normal maps can cause an angle > 90° betweeen n and v which would 
                // cause artifacts if we don't take some countermeasures
                float nDotV = abs(dot(n, v)) + 0.001;
                float3 sunLight = SunColor * LightingMultiplier * shadow;

                // Cook-Torrance BRDF
                float3 F = FresnelSchlick(max(dot(h, v), 0.0), F0);
                float NDF = NormalDistribution(n, h, roughness);
                float G = GeometrySmith(n, nDotV, l, roughness);

                // For point lights we need to multiply with Pi
                float3 numerator = PI * NDF * G * F;
                // add 0.0001 to avoid division by zero
                float denominator = 4.0 * nDotV * nDotL + 0.0001;
                float3 reflected = numerator / denominator;
    
                float3 kD = float3(1.0, 1.0, 1.0) - F;	
                float3 refracted = kD * albedo;
                float3 irradiance = sunLight * nDotL;
                float3 color = (refracted + reflected) * irradiance;

                float3 shadowColor = (1 - (SunColor * shadow * nDotL + SunAmbience)) * ShadowFillColor;
                float3 ambient = SunAmbience * LightingMultiplier + shadowColor;

                // we simplify here for the ambient lighting
                color += albedo * ambient;

                return color;
            }




            VS_OUTPUT TerrainVS( position_t p : POSITION0, uniform bool shadowed)
            {
                VS_OUTPUT result;

                result.nearScales = float4(Stratum0AlbedoTile.x, Stratum1AlbedoTile.x, Stratum2AlbedoTile.x, Stratum3AlbedoTile.x);
                result.farScales =  float4(Stratum0NormalTile.x, Stratum1NormalTile.x, Stratum2NormalTile.x, Stratum3NormalTile.x);

                float4 position = float4(p);
                position.y *= HeightScale;

                // calculate output position
                result.mPos = calculateHomogenousCoordinate(position);

                // calculate 0..1 uv based on size of map
                result.mTexWT = position.xzyw;
                // caluclate screen space coordinate for sample a frame buffer of this size
                result.mTexSS = result.mPos;
                result.mTexDecal = float4(0,0,0,0);

                result.mViewDirection = normalize(position.xyz-CameraPosition.xyz);

                // if we have shadows enabled fill in the tex coordinate for the shadow projection
                if ( shadowed && ( 1 == ShadowsEnabled ))
                {
                    result.mShadow = mul(position,ShadowMatrix);
                    result.mShadow.x = ( +result.mShadow.x + result.mShadow.w ) * 0.5;
                    result.mShadow.y = ( -result.mShadow.y + result.mShadow.w ) * 0.5;
                    result.mShadow.z -= 0.01f; // put epsilon in vs to save ps instruction
                }
                else
                {
                    result.mShadow = float4( 0, 0, 0, 1);
                }

                return result;
            }

            float4 TerrainNormalsPS( VS_OUTPUT inV ) : COLOR
            {
                // sample all the textures we'll need
                float4 mask = saturate(tex2D( UtilitySamplerA, inV.mTexWT * TerrainScale));

                float4 lowerNormal = normalize(tex2D( LowerNormalSampler, inV.mTexWT  * TerrainScale * LowerNormalTile ) * 2 - 1);
                float4 stratum0Normal = normalize(tex2D( Stratum0NormalSampler, inV.mTexWT  * TerrainScale * Stratum0NormalTile ) * 2 - 1);
                float4 stratum1Normal = normalize(tex2D( Stratum1NormalSampler, inV.mTexWT  * TerrainScale * Stratum1NormalTile ) * 2 - 1);
                float4 stratum2Normal = normalize(tex2D( Stratum2NormalSampler, inV.mTexWT  * TerrainScale * Stratum2NormalTile ) * 2 - 1);
                float4 stratum3Normal = normalize(tex2D( Stratum3NormalSampler, inV.mTexWT  * TerrainScale * Stratum3NormalTile ) * 2 - 1);

                // blend all normals together
                float4 normal = lowerNormal;
                normal = lerp( normal, stratum0Normal, mask.x );
                normal = lerp( normal, stratum1Normal, mask.y );
                normal = lerp( normal, stratum2Normal, mask.z );
                normal = lerp( normal, stratum3Normal, mask.w );
                normal.xyz = normalize( normal.xyz );

                return float4( (normal.xyz * 0.5 + 0.5) , normal.w);
            }

            float4 TerrainPS( VS_OUTPUT inV, uniform bool inShadows ) : COLOR
            {
                // sample all the textures we'll need
                float4 mask = saturate(tex2Dproj( UtilitySamplerA, inV.mTexWT  * TerrainScale)* 2 - 1 );
                float4 upperAlbedo = tex2Dproj( UpperAlbedoSampler, inV.mTexWT  * TerrainScale* UpperAlbedoTile );
                float4 lowerAlbedo = tex2Dproj( LowerAlbedoSampler, inV.mTexWT  * TerrainScale* LowerAlbedoTile );
                float4 stratum0Albedo = tex2Dproj( Stratum0AlbedoSampler, inV.mTexWT  * TerrainScale* Stratum0AlbedoTile );
                float4 stratum1Albedo = tex2Dproj( Stratum1AlbedoSampler, inV.mTexWT  * TerrainScale* Stratum1AlbedoTile );
                float4 stratum2Albedo = tex2Dproj( Stratum2AlbedoSampler, inV.mTexWT  * TerrainScale* Stratum2AlbedoTile );
                float4 stratum3Albedo = tex2Dproj( Stratum3AlbedoSampler, inV.mTexWT  * TerrainScale* Stratum3AlbedoTile );

                float3 normal = TerrainNormalsPS.xyz*2-1;

                // blend all albedos together
                float4 albedo = lowerAlbedo;
                albedo = lerp( albedo, stratum0Albedo, mask.x );
                albedo = lerp( albedo, stratum1Albedo, mask.y );
                albedo = lerp( albedo, stratum2Albedo, mask.z );
                albedo = lerp( albedo, stratum3Albedo, mask.w );
                albedo.xyz = lerp( albedo.xyz, upperAlbedo.xyz, upperAlbedo.w );

                // get the water depth
                float waterDepth = tex2Dproj( UtilitySamplerC, inV.mTexWT * TerrainScale).g;

                // calculate the lit pixel
                float4 outColor = CalculateLighting( normal, inV.mTexWT.xyz, albedo.xyz, 1-albedo.w, waterDepth, inV.mShadow, inShadows);

                return outColor;
            }

            float4 fragmentShader(VS_OUTPUT inV) : COLOR
            {
                float shaderNumber = 0;
                float4 outColor = (1, 0, 1, 1);

                if (shaderNumber == 0)
                {
                    outColor = TerrainPS(inV, true);
                }
                else if (shaderNumber == 1)
                {
                    outColor = TerrainXP(inV, true);
                }
                else if (shaderNumber == 2)
                {
                    outColor = Terrain001PS(inV, true);
                }

                outColor = renderFog(outColor);
                outColor = renderOnlyArea(outColor);
                outColor = renderBrush(outColor);
                outColor = renderSlope(outColor);
                outColor = renderTerrainType(outColor);
                outColor = renderGrid(outColor);
                
                return outColor;
            }
            ENDCG
        }
    }
}




Shader "FAShaders/Terrain"
{
    Properties
    {
        // It is conventional to begin all property names with an underscore.
        // However, to be as close to the FA shader code as possible, we ignore this here.
        // We use underscores only for variables that are introduced by the editor.

        ShadowFillColor ("Shadow Fill Color", Color) = (0.0, 0.0, 0.0, 1)
        LightingMultiplier ("Lighting Multiplier", Float) = 1
        SunDirection ("Sun Direction", Vector) = (0.0, 1.0, 0.0, 1)
        SunAmbience ("Ambient Light Color", Color) = (0.0, 0.0, 0.0, 1)
        SunColor ("Sun Color", Color) = (0.0, 0.0, 0.0, 1)
        SpecularColor ("Specular Color", Color) = (0.0, 0.0, 0.0, 1)
        WaterElevation ("Water Elevation", Float) = 0

        LowerAlbedoTile ("Lower Albedo Tile", Float) = 1
        LowerNormalTile ("Lower Normal Tile", Float) = 1
        Stratum0AlbedoTile ("Stratum 0 Albedo Tile", Float) = 1
        Stratum1AlbedoTile ("Stratum 1 Albedo Tile", Float) = 1
        Stratum2AlbedoTile ("Stratum 2 Albedo Tile", Float) = 1
        Stratum3AlbedoTile ("Stratum 3 Albedo Tile", Float) = 1
        Stratum4AlbedoTile ("Stratum 4 Albedo Tile", Float) = 1
        Stratum5AlbedoTile ("Stratum 5 Albedo Tile", Float) = 1
        Stratum6AlbedoTile ("Stratum 6 Albedo Tile", Float) = 1
        Stratum7AlbedoTile ("Stratum 7 Albedo Tile", Float) = 1
        Stratum0NormalTile ("Stratum 0 Normal Tile", Float) = 1
        Stratum1NormalTile ("Stratum 1 Normal Tile", Float) = 1
        Stratum2NormalTile ("Stratum 2 Normal Tile", Float) = 1
        Stratum3NormalTile ("Stratum 3 Normal Tile", Float) = 1
        Stratum4NormalTile ("Stratum 4 Normal Tile", Float) = 1
        Stratum5NormalTile ("Stratum 5 Normal Tile", Float) = 1
        Stratum6NormalTile ("Stratum 6 Normal Tile", Float) = 1
        Stratum7NormalTile ("Stratum 7 Normal Tile", Float) = 1
        UpperAlbedoTile ("Upper Albedo Tile", Float) = 1
        UpperNormalTile ("Upper Normal Tile", Float) = 1

        // used to generate texture coordinates
        // this is 1/mapresolution
        TerrainScale ("Terrain Scale", Range (0, 1)) = 1

        UtilitySamplerA ("masks of stratum layers 0 - 3", 2D) = "black" {}
        UtilitySamplerB ("masks of stratum layers 4 - 7", 2D) = "black" {}
        UtilitySamplerC ("water properties", 2D) = "black" {}  // not set?

    	LowerAlbedoSampler ("Layer Lower (R)", 2D) = "white" {}
	    LowerNormalSampler ("Normal Lower (R)", 2D) = "bump" {}
    	UpperAlbedoSampler ("Layer Lower (R)", 2D) = "white" {}

        _StratumAlbedoArray ("Albedo array", 2DArray) = "" {}
	    _StratumNormalArray ("Normal array", 2DArray) = "" {}

        [MaterialToggle] _HideStratum0("Hide stratum 0", Integer) = 0
	    [MaterialToggle] _HideStratum1("Hide stratum 1", Integer) = 0
	    [MaterialToggle] _HideStratum2("Hide stratum 2", Integer) = 0
	    [MaterialToggle] _HideStratum3("Hide stratum 3", Integer) = 0
	    [MaterialToggle] _HideStratum4("Hide stratum 4", Integer) = 0
	    [MaterialToggle] _HideStratum5("Hide stratum 5", Integer) = 0
	    [MaterialToggle] _HideStratum6("Hide stratum 6", Integer) = 0
	    [MaterialToggle] _HideStratum7("Hide stratum 7", Integer) = 0
	    [MaterialToggle] _HideStratum8("Hide upper stratum", Integer) = 0

	    [MaterialToggle] _HideTerrainType("Hide Terrain Type", Integer) = 0
       	_TerrainTypeAlbedo ("Terrain Type Albedo", 2D) = "black" {}
	    _TerrainTypeCapacity ("Terrain Type Capacity", Range(0,1)) = 0.228

        [MaterialToggle] _Grid("Grid", Integer) = 0
        _GridType("Grid type", Integer) = 0
        // This should be refactored so we can use TerrainScale instead
        _GridScale ("Grid Scale", Range (0, 2048)) = 512
	    _GridTexture ("Grid Texture", 2D) = "white" {}

        [MaterialToggle] _Slope("Slope", Integer) = 0
	    [MaterialToggle] _UseSlopeTex("Use Slope Data", Integer) = 0
        _SlopeTex ("Slope data", 2D) = "black" {}

      	[MaterialToggle] _Brush ("Brush", Integer) = 0
	    [MaterialToggle] _BrushPainting ("Brush painting", Integer) = 0
	    _BrushTex ("Brush (RGB)", 2D) = "white" {}
	    _BrushSize ("Brush Size", Range (0, 128)) = 0
	    _BrushUvX ("Brush X", Range (0, 1)) = 0
	    _BrushUvY ("Brush Y", Range (0, 1)) = 0

        // Is this still needed?
        [MaterialToggle] _GeneratingNormal("Generating Normal", Integer) = 0
	    _TerrainNormal ("Terrain Normal", 2D) = "bump" {}

    }
    SubShader
    {

            CGPROGRAM
			#pragma surface surf SimpleLambert vertex:TerrainVS exclude_path:forward nometa
            #pragma multi_compile_fog
			#pragma target 3.5
			#include "Assets/GFX/Shaders/SimpleLambert.cginc"

            // include file that contains UnityObjectToWorldNormal helper function
            #include "UnityCG.cginc"


			int _Slope;
            int _UseSlopeTex;
			sampler2D _SlopeTex;

			int _Grid, _GridType;
            half _GridScale;
			half _GridCamDist;
			sampler2D _GridTexture;

			sampler2D _TerrainNormal;
			sampler2D _TerrainTypeAlbedo;

			int _HideStratum0;
            int _HideStratum1;
            int _HideStratum2;
            int _HideStratum3;
            int _HideStratum4;
            int _HideStratum5;
            int _HideStratum6;
            int _HideStratum7;
            int _HideStratum8;
			int _HideTerrainType;
			float _TerrainTypeCapacity;

			int _Brush;
            int _BrushPainting;
			sampler2D _BrushTex;
			half _BrushSize;
			half _BrushUvX;
			half _BrushUvY;

            uniform int _ShaderID;

            float3 ShadowFillColor;
            float LightingMultiplier;
            float3 SunDirection;
            float3 SunAmbience;
            float3 SunColor;
            float4 SpecularColor;
            float WaterElevation;

            float LowerAlbedoTile;
            float LowerNormalTile;
            float Stratum0AlbedoTile;
            float Stratum1AlbedoTile;
            float Stratum2AlbedoTile;
            float Stratum3AlbedoTile;
            float Stratum4AlbedoTile;
            float Stratum5AlbedoTile;
            float Stratum6AlbedoTile;
            float Stratum7AlbedoTile;
            float Stratum0NormalTile;
            float Stratum1NormalTile;
            float Stratum2NormalTile;
            float Stratum3NormalTile;
            float Stratum4NormalTile;
            float Stratum5NormalTile;
            float Stratum6NormalTile;
            float Stratum7NormalTile;
            float UpperAlbedoTile;
            float UpperNormalTile;

            float TerrainScale;

            sampler2D UtilitySamplerA;
            sampler2D UtilitySamplerB;
            sampler2D UtilitySamplerC;
            sampler1D WaterRampSampler;

            sampler2D LowerAlbedoSampler;
            sampler2D UpperAlbedoSampler;
            sampler2D LowerNormalSampler;
       
			UNITY_DECLARE_TEX2DARRAY(_StratumAlbedoArray);
			UNITY_DECLARE_TEX2DARRAY(_StratumNormalArray);

            uniform half4 unity_FogStart;
			uniform half4 unity_FogEnd;

            // This struct has to be named 'Input'. Changing it to VS_OUTPUT does not compile.
            struct Input
            {
                float4 mPos                    : POSITION0;
                // These are absolute world coordinates
                float3 mTexWT                : TEXCOORD1;
                // these three vectors will hold a 3x3 rotation matrix
                // that transforms from tangent to world space
                half3 tspace0 : TEXCOORD2; // tangent.x, bitangent.x, normal.x
                half3 tspace1 : TEXCOORD3; // tangent.y, bitangent.y, normal.y
                half3 tspace2 : TEXCOORD4; // tangent.z, bitangent.z, normal.z
                float3 mViewDirection        : TEXCOORD5;
                float4 nearScales           : TEXCOORD6;
                float4 farScales            : TEXCOORD7;

                float SlopeLerp;
                half fog;
            };

            float4 StratumAlbedoSampler(int layer, float3 uv) {
                return UNITY_SAMPLE_TEX2DARRAY(_StratumAlbedoArray, float3(uv.xy, layer));
            }

            float4 StratumNormalSampler(int layer, float2 uv) {
                return UNITY_SAMPLE_TEX2DARRAY(_StratumNormalArray, float3(uv, layer));
            }

            float3 TangentToWorldSpace(Input v, float3 tnormal) {
                // transform normal from tangent to world space
                float3 worldNormal;
                worldNormal.x = dot(v.tspace0, tnormal);
                worldNormal.y = dot(v.tspace1, tnormal);
                worldNormal.z = dot(v.tspace2, tnormal);
                return worldNormal;
            }

            // Because the underlying engine is different, the vertex shader has to differ considerably from fa.
            // Still, we try to set up things in a way that we only have to minimally modify the fa pixel shaders
            void TerrainVS(inout appdata_full v, out Input result)
            {
                result.nearScales = float4(Stratum0AlbedoTile.x, Stratum1AlbedoTile.x, Stratum2AlbedoTile.x, Stratum3AlbedoTile.x);
                result.farScales =  float4(Stratum0NormalTile.x, Stratum1NormalTile.x, Stratum2NormalTile.x, Stratum3NormalTile.x);

                // calculate output position
                result.mPos = UnityObjectToClipPos(v.vertex);

                // Unity uses lower left origin, fa uses upper left, so we need to invert the y axis
                // and for some ungodly reason we have a scale factor of 10. I don't know where this comes from.
                result.mTexWT = v.vertex.xzy * float3(10, -10, 10);
                // We also need to move the origin from the bottom corner to the top corner
                result.mTexWT.y += 1.0 / TerrainScale;
                
                result.mViewDirection = normalize(v.vertex.xyz - _WorldSpaceCameraPos.xyz);

                half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                half3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                // compute bitangent from cross product of normal and tangent
                half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                half3 worldBitangent = cross(worldNormal, worldTangent) * tangentSign;
                // output the tangent space matrix
                result.tspace0 = half3(worldTangent.x, worldBitangent.x, worldNormal.x);
                result.tspace1 = half3(worldTangent.y, worldBitangent.y, worldNormal.y);
                result.tspace2 = half3(worldTangent.z, worldBitangent.z, worldNormal.z);

                result.SlopeLerp = dot(v.normal, half3(0,1,0));
                float pos = length(UnityObjectToViewPos(v.vertex).xyz);
				float diff = unity_FogEnd.x - unity_FogStart.x;
			    float invDiff = 1.0f / diff;
		    	result.fog = saturate((unity_FogEnd.x - pos) * invDiff);
            }

            float4 GetWaterColor(float waterDepth)
            {
                float4 waterColor = tex1D(WaterRampSampler, waterDepth);
                return waterColor;
            }

            float4 GetExponentialWaterColor(float3 viewDirection, float waterDepth)
            {
                float3 up = float3(0,1,0);
                // this is the length that the light travels underwater back to the camera
                float oneOverCosV = 1 / max(dot(up, normalize(viewDirection)), 0.0001);
                // Light gets absorbed exponentially,
                // to simplify, we assume that the light enters vertically into the water.
                // We need to multiply by 2 to reach 98% absorption as the waterDepth can't go over 1.
                float waterAbsorption = 1 - saturate(exp(-waterDepth * 2 * (1 + oneOverCosV)));
                float4 waterColor = tex1D(WaterRampSampler, waterAbsorption);
                return float4(waterColor.rgb, waterAbsorption);
            }


            float4 TerrainNormalsPS( Input inV )
            {
                // sample all the textures we'll need
                float4 mask = saturate(tex2D( UtilitySamplerA, inV.mTexWT * TerrainScale));

                float4 lowerNormal = normalize(tex2D( LowerNormalSampler, inV.mTexWT * TerrainScale * LowerNormalTile ) * 2 - 1);
                float4 stratum0Normal = normalize(StratumNormalSampler(0, inV.mTexWT * TerrainScale * Stratum0NormalTile) * 2 - 1);
                float4 stratum1Normal = normalize(StratumNormalSampler(1, inV.mTexWT * TerrainScale * Stratum1NormalTile) * 2 - 1);
                float4 stratum2Normal = normalize(StratumNormalSampler(2, inV.mTexWT * TerrainScale * Stratum2NormalTile) * 2 - 1);
                float4 stratum3Normal = normalize(StratumNormalSampler(3, inV.mTexWT * TerrainScale * Stratum3NormalTile) * 2 - 1);

                // blend all normals together
                float4 normal = lowerNormal;
                normal = lerp( normal, stratum0Normal, mask.x );
                normal = lerp( normal, stratum1Normal, mask.y );
                normal = lerp( normal, stratum2Normal, mask.z );
                normal = lerp( normal, stratum3Normal, mask.w );
                normal.xyz = normalize( normal.xyz );

                return normal;
            }

            float4 TerrainPS( Input inV )
            {
                // sample all the textures we'll need
                float4 mask = saturate(tex2D( UtilitySamplerA, inV.mTexWT * TerrainScale) * 2 - 1);
                float4 upperAlbedo = tex2D( UpperAlbedoSampler, inV.mTexWT * TerrainScale * UpperAlbedoTile);
                float4 lowerAlbedo = tex2D( LowerAlbedoSampler, inV.mTexWT * TerrainScale * LowerAlbedoTile);
                float4 stratum0Albedo = StratumAlbedoSampler(0, inV.mTexWT * TerrainScale * Stratum0AlbedoTile);
                float4 stratum1Albedo = StratumAlbedoSampler(1, inV.mTexWT * TerrainScale * Stratum1AlbedoTile);
                float4 stratum2Albedo = StratumAlbedoSampler(2, inV.mTexWT * TerrainScale * Stratum2AlbedoTile);
                float4 stratum3Albedo = StratumAlbedoSampler(3, inV.mTexWT * TerrainScale * Stratum3AlbedoTile);

                // blend all albedos together
                float4 albedo = lowerAlbedo;
                albedo = lerp( albedo, stratum0Albedo, mask.x );
                albedo = lerp( albedo, stratum1Albedo, mask.y );
                albedo = lerp( albedo, stratum2Albedo, mask.z );
                albedo = lerp( albedo, stratum3Albedo, mask.w );
                albedo.xyz = lerp( albedo.xyz, upperAlbedo.xyz, upperAlbedo.w );

                return albedo;
            }

            float4 TerrainNormalsXP( Input pixel )
            {
                float4 mask0 = saturate(tex2D(UtilitySamplerA,pixel.mTexWT*TerrainScale));
                float4 mask1 = saturate(tex2D(UtilitySamplerB,pixel.mTexWT*TerrainScale));

                float4 lowerNormal = normalize(tex2D(LowerNormalSampler,pixel.mTexWT*TerrainScale*LowerNormalTile)*2-1);
                float4 stratum0Normal = normalize(StratumNormalSampler(0,pixel.mTexWT*TerrainScale*Stratum0NormalTile)*2-1);
                float4 stratum1Normal = normalize(StratumNormalSampler(1,pixel.mTexWT*TerrainScale*Stratum1NormalTile)*2-1);
                float4 stratum2Normal = normalize(StratumNormalSampler(2,pixel.mTexWT*TerrainScale*Stratum2NormalTile)*2-1);
                float4 stratum3Normal = normalize(StratumNormalSampler(3,pixel.mTexWT*TerrainScale*Stratum3NormalTile)*2-1);
                float4 stratum4Normal = normalize(StratumNormalSampler(4,pixel.mTexWT*TerrainScale*Stratum4NormalTile)*2-1);
                float4 stratum5Normal = normalize(StratumNormalSampler(5,pixel.mTexWT*TerrainScale*Stratum5NormalTile)*2-1);
                float4 stratum6Normal = normalize(StratumNormalSampler(6,pixel.mTexWT*TerrainScale*Stratum6NormalTile)*2-1);
                float4 stratum7Normal = normalize(StratumNormalSampler(7,pixel.mTexWT*TerrainScale*Stratum7NormalTile)*2-1);

                float4 normal = lowerNormal;
                normal = lerp(normal,stratum0Normal,mask0.x);
                normal = lerp(normal,stratum1Normal,mask0.y);
                normal = lerp(normal,stratum2Normal,mask0.z);
                normal = lerp(normal,stratum3Normal,mask0.w);
                normal = lerp(normal,stratum4Normal,mask1.x);
                normal = lerp(normal,stratum5Normal,mask1.y);
                normal = lerp(normal,stratum6Normal,mask1.z);
                normal = lerp(normal,stratum7Normal,mask1.w);
                normal.xyz = normalize( normal.xyz );

                return normal;
            }
            
            float4 TerrainAlbedoXP( Input pixel)
            {
                float3 position = TerrainScale*pixel.mTexWT;

                float4 mask0 = saturate(tex2D(UtilitySamplerA,position)*2-1);
                float4 mask1 = saturate(tex2D(UtilitySamplerB,position)*2-1);

                float4 lowerAlbedo = tex2D(LowerAlbedoSampler,position*LowerAlbedoTile);
                float4 stratum0Albedo = StratumAlbedoSampler(0,position*Stratum0AlbedoTile);
                float4 stratum1Albedo = StratumAlbedoSampler(1,position*Stratum1AlbedoTile);
                float4 stratum2Albedo = StratumAlbedoSampler(2,position*Stratum2AlbedoTile);
                float4 stratum3Albedo = StratumAlbedoSampler(3,position*Stratum3AlbedoTile);
                float4 stratum4Albedo = StratumAlbedoSampler(4,position*Stratum4AlbedoTile);
                float4 stratum5Albedo = StratumAlbedoSampler(5,position*Stratum5AlbedoTile);
                float4 stratum6Albedo = StratumAlbedoSampler(6,position*Stratum6AlbedoTile);
                float4 stratum7Albedo = StratumAlbedoSampler(7,position*Stratum7AlbedoTile);
                float4 upperAlbedo = tex2D(UpperAlbedoSampler,position*UpperAlbedoTile);

                float4 albedo = lowerAlbedo;
                albedo = lerp(albedo,stratum0Albedo,mask0.x);
                albedo = lerp(albedo,stratum1Albedo,mask0.y);
                albedo = lerp(albedo,stratum2Albedo,mask0.z);
                albedo = lerp(albedo,stratum3Albedo,mask0.w);
                albedo = lerp(albedo,stratum4Albedo,mask1.x);
                albedo = lerp(albedo,stratum5Albedo,mask1.y);
                albedo = lerp(albedo,stratum6Albedo,mask1.z);
                albedo = lerp(albedo,stratum7Albedo,mask1.w);
                albedo.rgb = lerp(albedo.xyz,upperAlbedo.xyz,upperAlbedo.w);

                return albedo;
            }

            float3 renderBrush(float2 uv){
                float3 Emit = 0;
                if (_Brush > 0) {
                    uv.y = 1-uv.y;
					float2 BrushUv = ((uv - float2(_BrushUvX, _BrushUvY)) * _GridScale) / (_BrushSize * _GridScale * 0.002);
					fixed4 BrushColor = tex2D(_BrushTex, BrushUv);

					if (BrushUv.x >= 0 && BrushUv.y >= 0 && BrushUv.x <= 1 && BrushUv.y <= 1) {

						half LerpValue = clamp(_BrushSize / 20, 0, 1);

						half From = 0.1f;
						half To = lerp(0.2f, 0.13f, LerpValue);
						half Range = lerp(0.015f, 0.008f, LerpValue);

						if (BrushColor.r >= From && BrushColor.r <= To) {
							half AA = 1;

							if (BrushColor.r < From + Range)
								AA = (BrushColor.r - From) / Range;
							else if (BrushColor.r > To - Range)
								AA = 1 - (BrushColor.r - (To - Range)) / Range;

							AA = clamp(AA, 0, 1);

							Emit += half3(0, 0.3, 1) * (AA * 0.8);
						}

						if (_BrushPainting <= 0)
							Emit += half3(0, BrushColor.r * 0.1, BrushColor.r * 0.2);
						else
							Emit += half3(0, BrushColor.r * 0.1, BrushColor.r * 0.2) * 0.2;
					}
				}
                return Emit;
            }

            float3 renderSlope(Input IN){
                float3 Emit = 0;
                if (_Slope > 0) {
					half3 SlopeColor = 0;
					if (_UseSlopeTex > 0) {
						float4 splat_control = tex2D(_SlopeTex, IN.mTexWT);
						SlopeColor = splat_control.rgb;

					}
					else {

						if (IN.mTexWT.y * TerrainScale < WaterElevation) {
							if (IN.SlopeLerp > 0.75) SlopeColor = half3(0, 0.4, 1);
							else SlopeColor = half3(0.6, 0, 1);
						}
						else if (IN.SlopeLerp > 0.999) SlopeColor = half3(0, 0.8, 0);
						else if (IN.SlopeLerp > 0.95) SlopeColor = half3(0.3, 0.89, 0);
						else if (IN.SlopeLerp > 0.80) SlopeColor = half3(0.5, 0.8, 0);
						else SlopeColor = half3(1, 0, 0);

					}
					Emit = SlopeColor * 0.8;
					// col.rgb = lerp(col.rgb, 0, 0.8);
				}
                return Emit;
            }

            float3 renderTerrainType(float3 albedo, float2 uv){
                if(_HideTerrainType == 0) {
					float4 TerrainTypeAlbedo = tex2D (_TerrainTypeAlbedo, uv);
					albedo = lerp(albedo, TerrainTypeAlbedo, TerrainTypeAlbedo.a*_TerrainTypeCapacity);
				}
                return albedo;
            }

            float4 RenderGrid(sampler2D _GridTex, float2 uv_Control, float Offset, float GridScale) {
				fixed4 GridColor = tex2D(_GridTex, uv_Control * GridScale + float2(-Offset, Offset));
				fixed4 GridFinal = fixed4(0, 0, 0, GridColor.a);
				if (_GridCamDist < 1) {
					GridFinal.rgb = lerp(GridFinal.rgb, fixed3(1, 1, 1), GridColor.r * lerp(1, 0, _GridCamDist));
					GridFinal.rgb = lerp(GridFinal.rgb, fixed3(0, 1, 0), GridColor.g * lerp(1, 0, _GridCamDist));
					GridFinal.rgb = lerp(GridFinal.rgb, fixed3(0, 1, 0), GridColor.b * lerp(0, 1, _GridCamDist));
				}
				else {
					GridFinal.rgb = lerp(GridFinal.rgb, fixed3(0, 1, 0), GridColor.b);
				}

				GridFinal *= GridColor.a;

				half CenterGridSize = lerp(0.005, 0.015, _GridCamDist) / _GridScale;
				if (uv_Control.x > 0.5 - CenterGridSize && uv_Control.x < 0.5 + CenterGridSize)
					GridFinal.rgb = fixed3(0.4, 1, 0);
				else if (uv_Control.y > 0.5 - CenterGridSize && uv_Control.y < 0.5 + CenterGridSize)
					GridFinal.rgb = fixed3(0.4, 1, 0);

				return GridFinal;
			}

            float3 renderGridOverlay(float2 uv){
                float3 Emit = 0;
                if (_Grid > 0) {
					if(_GridType == 1)
						Emit += RenderGrid(_GridTexture, uv, 0, _GridScale);
					else if (_GridType == 2)
						Emit += RenderGrid(_GridTexture, uv, 0.0015, _GridScale / 5.12);
					else if (_GridType == 3)
						Emit += RenderGrid(_GridTexture, uv, 0.0015, 16);
					else
						Emit += RenderGrid(_GridTexture, uv, 0, _GridScale);
				}
                return Emit;
            }

            // The decals get written directly in the gBuffer, so here we only prepare all necessary terrain inputs.
            // The actual lighting calculations happen in Assets\GFX\Shaders\Deferred\Internal-DeferredShading.shader
            // This way the decals and the terrain have consistent lighting
            void surf(Input inV, inout CustomSurfaceOutput o)
            {
                if (_ShaderID == 0)
                {
                    float4 albedo = TerrainPS(inV);
                    o.Albedo = albedo.rgb;
                    o.Roughness = albedo.a; // for specularity

                    float3 normal = TangentToWorldSpace(inV, TerrainNormalsPS(inV).xyz);
                    o.wNormal = normalize(normal);

                    float4 waterColor = GetWaterColor(tex2D(UtilitySamplerC, inV.mTexWT * TerrainScale).g);
                    o.WaterColor = waterColor.rgb;
                    o.WaterAbsorption = waterColor.a;
                }
                else if (_ShaderID == 1)
                {
                    float4 albedo = TerrainAlbedoXP(inV);
                    o.Albedo = albedo.rgb;
                    o.Roughness = albedo.a; // for specularity

                    float3 normal = TangentToWorldSpace(inV, TerrainNormalsXP(inV).xyz);
                    o.wNormal = normalize(normal);

                    float4 waterColor = GetWaterColor(tex2D(UtilitySamplerC, inV.mTexWT * TerrainScale).g);
                    o.WaterColor = waterColor.rgb;
                    o.WaterAbsorption = waterColor.a;
                }
                // else if (_ShaderID == 3)
                // {
                //     float4 albedo = Terrain101AlbedoPS(inV);
                //     o.Albedo = albedo.rgb;
                //     o.Roughness = albedo.a;

                //     float3 normal = TangentToWorldSpace(inV, Terrain101NormalsPS(inV).xyz);
                //     o.wNormal = normalize(normal);

                //     float4 waterColor = GetExponentialWaterColor(tex2D(UpperAlbedoSampler, inV.mTexWT * TerrainScale).b);
                //     o.WaterColor = waterColor.rgb;
                //     o.WaterAbsorption = waterColor.a;
                    
                //     float3 position = TerrainScale * inV.mTexWT.xyz;
                //     o.MapShadow = tex2D(UpperAlbedoSampler, position.xy).w;
                // }
                else {
                    o.Albedo = float3(1, 0, 1);
                }

                o.Emission = renderBrush(inV.mTexWT.xy * TerrainScale);
                o.Emission += renderSlope(inV);
                o.Albedo = renderTerrainType(o.Albedo, inV.mTexWT.xy * TerrainScale);
                o.Emission += renderGridOverlay(inV.mTexWT.xy * TerrainScale);

                // fog
                o.Albedo = lerp(0, o.Albedo, inV.fog);
				o.Emission = lerp(unity_FogColor, o.Emission, inV.fog);
            }
            ENDCG
    }
}




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

			uniform int _Area;
			uniform half4 _AreaRect;

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

                return float4( (normal.xyz * 0.5 + 0.5) , normal.w);
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

                float3 normal = TerrainNormalsPS(inV).xyz*2-1;
                normal = TangentToWorldSpace(inV, normal);

                // blend all albedos together
                float4 albedo = lowerAlbedo;
                albedo = lerp( albedo, stratum0Albedo, mask.x );
                albedo = lerp( albedo, stratum1Albedo, mask.y );
                albedo = lerp( albedo, stratum2Albedo, mask.z );
                albedo = lerp( albedo, stratum3Albedo, mask.w );
                albedo.xyz = lerp( albedo.xyz, upperAlbedo.xyz, upperAlbedo.w );

                return albedo;
            }

            float4 renderFog(float4 color){
                return color;
            }
            
            float4 renderOnlyArea(float4 worldPos, float4 color){
                if(_Area > 0){
					if(worldPos.x < _AreaRect.x){
                        color.rgb = 0;
					}
					else if(worldPos.x > _AreaRect.z){
						color.rgb = 0;
					}
					else if(worldPos.z < _AreaRect.y - _GridScale){
						color.rgb = 0;
					}
					else if(worldPos.z > _AreaRect.w - _GridScale){
						color.rgb = 0;
					}
				}
                return color;
            }

            float3 renderBrush(float2 uv){
                float3 Emit = 0;
                if (_Brush > 0) {
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

            float4 renderSlope(float4 color){
                return color;
            }

            float4 renderTerrainType(float4 color){
                return color;
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

            void surf(Input inV, inout CustomSurfaceOutput o)
            {
                float shaderNumber = 0;
                float4 outColor;

                if (shaderNumber == 0)
                {
                    outColor = TerrainPS(inV);
                    o.Albedo = outColor.rgb;
                    o.Roughness = outColor.a; // for specularity
                    float3 normal = TangentToWorldSpace(inV, TerrainNormalsPS(inV).xyz*2-1);
                    o.wNormal = normalize(normal);

                    float4 waterColor = GetWaterColor(tex2D(UtilitySamplerC, inV.mTexWT * TerrainScale).g);
                    o.WaterColor = waterColor.rgb;
                    o.WaterAbsorption = waterColor.a;

                    float3 position = TerrainScale * inV.mTexWT.xyz;
                    o.MapShadow = tex2D(UpperAlbedoSampler, position.xy).w;
                }
                // else if (shaderNumber == 1)
                // {
                //     outColor = TerrainXP(inV);
                // }
                // else if (shaderNumber == 2)
                // {
                //     outColor = Terrain001PS(inV);
                // }
                else {
                    o.Albedo = float4(1, 0, 1, 1);
                }

                // outColor = renderFog(outColor);
                // outColor = renderOnlyArea(inV.mPos, outColor);
                // outColor.rgb += renderBrush(inV.mTexWT.xy);
                // outColor = renderSlope(outColor);
                // outColor = renderTerrainType(outColor);
                // outColor.rgb += renderGridOverlay(inV.mTexWT.xy);
                
            }
            ENDCG
    }
}

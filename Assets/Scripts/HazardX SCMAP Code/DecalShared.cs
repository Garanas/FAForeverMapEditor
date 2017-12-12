﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using EditMap;
using OzoneDecals;

public partial class Decal {

	public static HashSet<DecalSharedSettings> AllDecalsShared = new HashSet<DecalSharedSettings>();

	[System.Serializable, PreferBinarySerialization]
	public class DecalSharedSettings
	{
		public TerrainDecalType Type;
		public Texture2D Texture1;
		public string Tex1Path;
		public Texture2D Texture2;
		public string Tex2Path;



		public Material SharedMaterial;
		public List<int> Ids;

		public bool DrawAlbedo;
		public bool DrawNormal;

		public DecalSharedSettings()
		{
			//SharedMaterial = null;
			Ids = new List<int>();
		}

		public void Load(Decal Source)
		{
			Type = Source.Type;
			Tex1Path = Source.TexPathes[0];
			Tex2Path = Source.TexPathes[1];

			UpdateMaterial();
		}

		public void UpdateMaterial()
		{
			if (SharedMaterial == null)
				SharedMaterial = new Material(EditMap.DecalsInfo.Current.AlbedoMaterial);


			if (Type == TerrainDecalType.TYPE_NORMALS)
			{
				Texture1 = DecalsInfo.AssignTextureFromPath(ref SharedMaterial, "_NormalTex", Tex1Path);

				DrawAlbedo = false;
				DrawNormal = true;
			}
			else if (Type == TerrainDecalType.TYPE_GLOW
				|| Type == TerrainDecalType.TYPE_GLOW_MASK)
			{
				Texture1 = DecalsInfo.AssignTextureFromPath(ref SharedMaterial, "_MainTex", Tex1Path);
				Texture2 = DecalsInfo.AssignTextureFromPath(ref SharedMaterial, "_Glow", Tex2Path);

				DrawAlbedo = true;
				DrawNormal = false;
			}
			else // Albedo
			{
				Texture1 = DecalsInfo.AssignTextureFromPath(ref SharedMaterial, "_MainTex", Tex1Path);
				Texture2 = DecalsInfo.AssignTextureFromPath(ref SharedMaterial, "_Mask", Tex2Path);

				DrawAlbedo = true;
				DrawNormal = false;
			}

		}
	}
}
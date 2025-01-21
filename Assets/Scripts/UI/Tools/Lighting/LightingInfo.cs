﻿using UnityEngine;
using UnityEngine.UI;
using System.Collections;
using System.IO;
using Ozone.UI;
using System.Runtime.InteropServices;
using SFB;

namespace EditMap
{
	public class LightingInfo : MonoBehaviour
	{
		public const float SunMultipiler = 1f;
		public const float BloomMultipiler = 1f;

		public ScmapEditor Scmap;

		public UiTextField RA;
		public UiTextField DA;

		public UiTextField LightMultipiler;

		public UiColor LightColor;
		public UiColor AmbienceColor;
		public UiColor ShadowColor;


		public UiTextField Glow;
		public UiTextField Bloom;
		public UiColor Specular;
		public UiTextField SpecularRed;

		public UiColor FogColor;
		public UiTextField FogStart;
		public UiTextField FogEnd;

		// Use this for initialization
		[HideInInspector]
		public bool IgnoreUpdate = true;
		void OnEnable()
		{
			IgnoreUpdate = true;
			if (Scmap.map == null) return;

			LoadValues();
		}


		public void LoadValues()
		{
			Quaternion CheckRot = Scmap.Sun.transform.rotation;

			float RaHold = CheckRot.eulerAngles.y;
			RaHold += 180;
			if (RaHold > 360) RaHold -= 360;
			if (RaHold < 0) RaHold += 360;
			RaHold *= 10;
			RaHold = (int)RaHold;
			RaHold /= 10f;
			RA.SetValue(RaHold);

			float DAHold = CheckRot.eulerAngles.x;
			DAHold *= 10;
			DAHold = (int)DAHold;
			DAHold /= 10f;
			DA.SetValue(DAHold);

			LightMultipiler.SetValue(Scmap.map.LightingMultiplier);

			LightColor.SetColorField(Scmap.map.SunColor.x, Scmap.map.SunColor.y, Scmap.map.SunColor.z); // UpdateColors
			AmbienceColor.SetColorField(Scmap.map.SunAmbience.x, Scmap.map.SunAmbience.y, Scmap.map.SunAmbience.z); // UpdateColors
			ShadowColor.SetColorField(Scmap.map.ShadowFillColor.x, Scmap.map.ShadowFillColor.y, Scmap.map.ShadowFillColor.z); // UpdateColors

			FogColor.SetColorField(Scmap.map.FogColor.x, Scmap.map.FogColor.y, Scmap.map.FogColor.z);
			FogStart.SetValue(Scmap.map.FogStart);
			FogEnd.SetValue(Scmap.map.FogEnd);

			Specular.SetColorField(Scmap.map.SpecularColor.x, Scmap.map.SpecularColor.y, Scmap.map.SpecularColor.z, Scmap.map.SpecularColor.w);
			SpecularRed.SetValue(Scmap.map.SpecularColor.x);

			Bloom.SetValue(Scmap.map.Bloom);

			IgnoreUpdate = false;
			UndoUpdate();
		}

		bool UndoChange = false;
		public void UndoUpdate()
		{
			UndoChange = true;
			UpdateMenu(true);
			UndoChange = false;

		}
		[HideInInspector]
		public bool SliderDrag = false;
		public void EndSliderDrag()
		{
			SliderDrag = false;
			UpdateMenu(false);
		}

		public void UpdateColors()
		{
			UpdateMenu(true);
		}

		public void BeginColorsChange()
		{
			Undo.RegisterUndo(new UndoHistory.HistoryLighting());
		}

		public void FinishColorChange()
		{
			if (IgnoreUpdate) return;

			EndSliderDrag();
			IgnoreUpdate = true;

			Scmap.map.Bloom = Bloom.value;

			RA_Value = RA.intValue;
			DA_Value = RA.intValue;

			IgnoreUpdate = false;
			UpdateLightingData();
		}

		public void BeginUpdateMenu()
		{
			if (IgnoreUpdate)
				return;

			Undo.RegisterUndo(new UndoHistory.HistoryLighting());
		}

		public void UpdateMenu(bool Slider = false)
		{
			if (IgnoreUpdate) return;

			if (!UndoChange && !SliderDrag && !Slider)
			{
				//Debug.Log("Register lighting undo");
				//Undo.Current.RegisterLightingChange();
			}

			if (Slider)
			{
				if (!UndoChange)
					SliderDrag = true;

				UpdateMenu(false);
			}
			else
			{
				//EndSliderDrag();
				SliderDrag = false;
				//IgnoreUpdate = true;

				RA_Value = RA.intValue;
				DA_Value = RA.intValue;

				//IgnoreUpdate = false;
				UpdateLightingData();
			}
		}


		public static int RA_Value = 0;
		public static int DA_Value = 0;
		void UpdateLightingData()
		{
			if (Scmap.map == null) return;

			Scmap.Sun.transform.rotation = Quaternion.Euler(new Vector3(DA.value, -180 + RA.value, 0));
			Vector3 SunDir = Scmap.Sun.transform.rotation * Vector3.back;
			SunDir.z *= -1;
			Scmap.map.SunDirection = SunDir;

            if (MapLuaParser.Current.EditMenu.WaterMenu.AdvancedWaterToggle.isOn)
            {
				// Don't allow changing the multiplier when we need it for the water settings
                LightMultipiler.SetValue(Scmap.map.LightingMultiplier);
            } else {
				Scmap.map.LightingMultiplier = LightMultipiler.value;
			}

			Scmap.map.SunColor = LightColor.GetVectorValue();
			Scmap.map.SunAmbience = AmbienceColor.GetVectorValue();
			Scmap.map.ShadowFillColor = ShadowColor.GetVectorValue();

			Scmap.map.SpecularColor = Specular.GetVector4Value();
			if (SpecularRed.gameObject.activeSelf)
			{
				Scmap.map.SpecularColor.x = SpecularRed.value;
            }

			Scmap.map.FogColor = FogColor.GetVectorValue();
			Scmap.map.FogStart = FogStart.value;
			Scmap.map.FogEnd = FogEnd.value;

			if (Scmap.map.FogStart >= Scmap.map.FogEnd && Scmap.map.FogEnd > 1)
			{
				Scmap.map.FogStart = Scmap.map.FogEnd - 1;
				FogStart.SetValue(Scmap.map.FogStart, false);
			}

			Scmap.map.Bloom = Bloom.value;

			if (MapLuaParser.Current.EditMenu.WaterMenu.UseLightingSettings.isOn)
			{
				MapLuaParser.Current.EditMenu.WaterMenu.WaterSettingsChanged(false);
            }

			Scmap.UpdateLighting();
			Scmap.Skybox.LoadSkybox();

		}

		/* We transform the light values so that we set the shadowFill to
		0 and the lightMultiplier to a given value, without changing the
		visual appearance. Setting shadowFill to 0 makes it easier to
		reason about the lighting, because now we have a physically
		correct light setup.
		A multiplier of 2.2 enables exponential water absorption. */
        public void RecalculateLightSettings(float NewLightMultiplier)
		{
			Vector3 NewSunColor = new Vector3(
				Scmap.map.SunColor.x * (Scmap.map.LightingMultiplier - Scmap.map.ShadowFillColor.x) / NewLightMultiplier,
				Scmap.map.SunColor.y * (Scmap.map.LightingMultiplier - Scmap.map.ShadowFillColor.y) / NewLightMultiplier,
                Scmap.map.SunColor.z * (Scmap.map.LightingMultiplier - Scmap.map.ShadowFillColor.z) / NewLightMultiplier);
            Vector3 NewAmbienceColor = new Vector3(
                (Scmap.map.SunAmbience.x * (Scmap.map.LightingMultiplier - Scmap.map.ShadowFillColor.x) + Scmap.map.ShadowFillColor.x) / NewLightMultiplier,
                (Scmap.map.SunAmbience.y * (Scmap.map.LightingMultiplier - Scmap.map.ShadowFillColor.y) + Scmap.map.ShadowFillColor.y) / NewLightMultiplier,
                (Scmap.map.SunAmbience.z * (Scmap.map.LightingMultiplier - Scmap.map.ShadowFillColor.z) + Scmap.map.ShadowFillColor.z) / NewLightMultiplier);

            Scmap.map.LightingMultiplier = NewLightMultiplier;
            Scmap.map.SunColor = NewSunColor;
            Scmap.map.SunAmbience = NewAmbienceColor;
            Scmap.map.ShadowFillColor = new Vector3(0, 0, 0);

			LoadValues();
        }

		public void ResetLight()
		{
			BeginUpdateMenu();

			RA.SetValue(312);
			DA.SetValue(34);
			LightMultipiler.SetValue(1.54f);
			LightColor.SetColorField(new Color(1.38f, 1.29f, 1.14f, 1));
			AmbienceColor.SetColorField(Color.black);
			ShadowColor.SetColorField(new Color(0.54f, 0.54f, 0.7f));

			UpdateMenu();
		}

		public void ResetFog() {
			BeginUpdateMenu();

			FogColor.SetColorField(new Color(0.37f, 0.49f, 0.45f));
			FogStart.SetValue(0);
			FogEnd.SetValue(750);

			UpdateMenu();
		}

		public void ResetEffects()
		{
			BeginUpdateMenu();

			Bloom.SetValue(0.03f);
			Specular.SetColorField(new Color(0.31f, 0, 0, 0));

			UpdateMenu();
		}


		#region Import/Export
		class LightingData
		{
			public float LightingMultiplier;
			public Vector3 SunDirection;

			public Vector3 SunAmbience;
			public Vector3 SunColor;
			public Vector3 ShadowFillColor;
			public Vector4 SpecularColor;

			public float Bloom;
			public Vector3 FogColor;
			public float FogStart;
			public float FogEnd;
		}

		const string ExportPathKey = "LightingExport";
		const string ExportPathKey2 = "LightingSkyboxExport";
		static string DefaultPath
		{
			get
			{
				return EnvPaths.GetLastPath(ExportPathKey, EnvPaths.GetMapsPath() + MapLuaParser.Current.FolderName);
			}
		}
		static string DefaultPath2
		{
			get
			{
				return EnvPaths.GetLastPath(ExportPathKey2, EnvPaths.GetMapsPath() + MapLuaParser.Current.FolderName);
			}
		}

		public void ExportLightingData()
		{
			var extensions = new[]
			{
				new ExtensionFilter("Lighting settings", "scmlighting")
			};

			var path = StandaloneFileBrowser.SaveFilePanel("Export Lighting", DefaultPath, "", extensions);

			if (string.IsNullOrEmpty(path))
				return;

			LightingData Data = new LightingData();
			Data.LightingMultiplier = Scmap.map.LightingMultiplier;
			Data.SunDirection = Scmap.map.SunDirection;

			Data.SunAmbience = Scmap.map.SunAmbience;
			Data.SunColor = Scmap.map.SunColor;
			Data.ShadowFillColor = Scmap.map.ShadowFillColor;
			Data.SpecularColor = Scmap.map.SpecularColor;

			Data.Bloom = Scmap.map.Bloom;
			Data.FogColor = Scmap.map.FogColor;
			Data.FogStart = Scmap.map.FogStart;
			Data.FogEnd = Scmap.map.FogEnd;

			string DataString = JsonUtility.ToJson(Data, true);
			File.WriteAllText(path, DataString);
			EnvPaths.SetLastPath(ExportPathKey, System.IO.Path.GetDirectoryName(path));
		}

		public void ImportLightingData()
		{

			var extensions = new[]
			{
				new ExtensionFilter("Lighting settings", "scmlighting")
			};

			var paths = StandaloneFileBrowser.OpenFilePanel("Import Lighting", DefaultPath, extensions, false);


			if (paths.Length == 0 || string.IsNullOrEmpty(paths[0]))
				return;

			string data = File.ReadAllText(paths[0]);
			LightingData LightingData = UnityEngine.JsonUtility.FromJson<LightingData>(data);

			BeginUpdateMenu();

			Scmap.map.LightingMultiplier = LightingData.LightingMultiplier;
			Scmap.map.SunDirection = LightingData.SunDirection;

			Scmap.map.SunAmbience = LightingData.SunAmbience;
			Scmap.map.SunColor = LightingData.SunColor;
			Scmap.map.ShadowFillColor = LightingData.ShadowFillColor;
			Scmap.map.SpecularColor = LightingData.SpecularColor;

			Scmap.map.Bloom = LightingData.Bloom;
			Scmap.map.FogColor = LightingData.FogColor;
			Scmap.map.FogStart = LightingData.FogStart;
			Scmap.map.FogEnd = LightingData.FogEnd;


			LoadValues();
			EnvPaths.SetLastPath(ExportPathKey, System.IO.Path.GetDirectoryName(paths[0]));
		}


		public void ExportProceduralSkybox()
		{
			var extensions = new[]
{
				new ExtensionFilter("Procedural skybox", "scmskybox")
			};

			var path = StandaloneFileBrowser.SaveFilePanel("Export skybox", DefaultPath2, "", extensions);

			if (string.IsNullOrEmpty(path))
				return;

			string DataString = JsonUtility.ToJson(Scmap.map.AdditionalSkyboxData, true);
			File.WriteAllText(path, DataString);
			EnvPaths.SetLastPath(ExportPathKey2, System.IO.Path.GetDirectoryName(path));
		}

		public void ImportProceduralSkybox()
		{
			var extensions = new[]
{
				new ExtensionFilter("Procedural skybox", "scmskybox")
			};

			var paths = StandaloneFileBrowser.OpenFilePanel("Import skybox", DefaultPath2, extensions, false);


			if (paths.Length == 0 || string.IsNullOrEmpty(paths[0]))
				return;

			string data = File.ReadAllText(paths[0]);
			Scmap.map.AdditionalSkyboxData = UnityEngine.JsonUtility.FromJson<SkyboxData>(data);
			Scmap.map.AdditionalSkyboxData.Data.UpdateSize();

			Scmap.Skybox.LoadSkybox();
			EnvPaths.SetLastPath(ExportPathKey2, System.IO.Path.GetDirectoryName(paths[0]));
		}
		#endregion
	}
}

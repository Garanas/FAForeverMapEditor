using UnityEngine.UI;
using Ozone.UI;
using UnityEngine;

namespace EditMap
{
	public class MapInfo : ToolPage
	{
		[Header("Map Info")]
		public MapLuaParser Scenario;
		public UiTextField Name;
		public UiTextField Desc;
		public UiTextField Version;
        public UiTextField ShaderName;
        public Toggle[] ScriptToggles;
		public Toggle SaveAsSc;
		public Toggle SaveAsFa;
		

		#region Page

		public static bool MapPageChange = false;
		public override bool ChangePage(int PageId)
		{
			MapPageChange = true;
			bool pageChanged = base.ChangePage(PageId);
			MapPageChange = false;

			return pageChanged;
		}
		#endregion

		void OnEnable()
		{
			UpdateFields();
			ChangePage(CurrentPage);
		}

		public void UpdateFields()
		{
			Name.SetValue(Scenario.ScenarioLuaFile.Data.name);
			Desc.SetValue(Scenario.ScenarioLuaFile.Data.description);
			Version.SetValue(Scenario.ScenarioLuaFile.Data.map_version.ToString());

			//Name.text = Scenario.ScenarioLuaFile.Data.name;
			//Desc.text = Scenario.ScenarioLuaFile.Data.description;
			//Version.text = Scenario.ScenarioLuaFile.Data.map_version.ToString();
		}

		public void UpdateScriptToggles(int id)
		{
			for (int i = 0; i < ScriptToggles.Length; i++)
			{
				if (i == id) ScriptToggles[i].isOn = true;
				else ScriptToggles[i].isOn = false;
			}
		}

		public void EndFieldEdit()
		{
			if (HasChanged()) Undo.RegisterUndo(new UndoHistory.HistoryMapInfo());
			Scenario.ScenarioLuaFile.Data.name = Name.text;
			Scenario.ScenarioLuaFile.Data.description = Desc.text;
			Scenario.ScenarioLuaFile.Data.map_version = float.Parse(Version.text);
		}

		public void ChangeScript(int id = 0)
		{
			if (Scenario.ScriptId != id) Undo.RegisterUndo(new UndoHistory.HistoryMapInfo());
			Scenario.ScriptId = id;
		}



		bool HasChanged()
		{
			if (Scenario.ScenarioLuaFile.Data.name != Name.text) return true;
			if (Scenario.ScenarioLuaFile.Data.description != Desc.text) return true;
			if (Scenario.ScenarioLuaFile.Data.map_version != float.Parse(Version.text)) return true;
			return false;
		}
	}
}

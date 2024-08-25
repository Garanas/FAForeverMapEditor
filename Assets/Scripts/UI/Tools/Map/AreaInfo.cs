using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.UI;

public class AreaInfo : MonoBehaviour {

	public static AreaInfo Current;

	public Toggle BorderRelative;
	public Toggle Rounding;
	public GameObject AreaPrefab;
	public Transform Pivot;
	public ToggleGroup ToggleGrp;

	List<AreaListObject> Created = new List<AreaListObject>();

	
	public static void CleanSelection()
	{
		HideArea = false;
		SelectedArea = null;

		if (Current != null)
		{
			Current.DeselectAll();
		}
	}
	

	private void Awake()
	{
		Current = this;
	}

	private void OnEnable()
	{
		UpdateList();
	}

	private void OnDisable()
	{

	}

	public void SwitchBorderRelative()
	{
		UpdateList();
	}

	public void SwitchPlayableAreaRounding()
	{
		//Rounding.isOn = !Rounding.isOn;

		MapLuaParser.Current.UpdateArea(Rounding.isOn);
	}

	public void UpdateList()
	{
		Clean();
		Generate();

		MapLuaParser.Current.UpdateArea(Rounding.isOn);
	}

	void Clean()
	{
		for(int i = 0; i < Created.Count; i++)
		{
			Destroy(Created[i].gameObject);
		}
		Created = new List<AreaListObject>();
	}

	void Generate()
	{
		MapLua.SaveLua.Areas[] Areas = MapLuaParser.Current.SaveLuaFile.Data.areas;

		bool ToogleFound = false;

		for (int i = 0; i < Areas.Length; i++)
		{
			GameObject NewArea = Instantiate(AreaPrefab, Pivot);
			AreaListObject AreaObject = NewArea.GetComponent<AreaListObject>();

			AreaObject.Controler = this;
			AreaObject.InstanceId = i;
			AreaObject.Name.SetTextWithoutNotify(Areas[i].Name);
			AreaObject.SizeX.SetTextWithoutNotify(Areas[i].rectangle.x.ToString());
			AreaObject.SizeY.SetTextWithoutNotify(Areas[i].rectangle.y.ToString());

			if (BorderRelative.isOn)
			{
				AreaObject.SizeWidth.SetTextWithoutNotify((ScmapEditor.Current.map.Width - Areas[i].rectangle.width).ToString());
				AreaObject.SizeHeight.SetTextWithoutNotify((ScmapEditor.Current.map.Height - Areas[i].rectangle.height).ToString());
			}
			else
			{
				AreaObject.SizeWidth.SetTextWithoutNotify(Areas[i].rectangle.width.ToString());
				AreaObject.SizeHeight.SetTextWithoutNotify(Areas[i].rectangle.height.ToString());
			}

			AreaObject.Selected.group = ToggleGrp;


			if(Areas[i] == SelectedArea)
			{
				AreaObject.Selected.SetIsOnWithoutNotify(true);
				ToogleFound = true;
			}

			Created.Add(AreaObject);
		}

		if (SelectedArea != null && !ToogleFound)
		{
			HideArea = true;
		}
	}


#region Selection
	public static bool HideArea = false;
	public static MapLua.SaveLua.Areas SelectedArea;

	public void ToggleSelected()
	{
		bool anyAreaSelected = IsAnySelected();
		bool noneSelected = !anyAreaSelected;
		HideArea &= noneSelected;
		
		if (noneSelected || HideArea)
		{
			DeselectAll();
		}
		MapLuaParser.Current.UpdateArea(Rounding.isOn);
	}

	public void SelectArea(int InstanceID)
	{
		HideArea = false;
		SelectedArea = MapLuaParser.Current.SaveLuaFile.Data.areas[InstanceID];
		MapLuaParser.Current.UpdateArea(Rounding.isOn);
	}

	public void DeselectArea(int InstanceID)
	{
		if (SelectedArea == MapLuaParser.Current.SaveLuaFile.Data.areas[InstanceID])
			SelectedArea = null;
		if (IsAnySelected())
			return;
		SetSelectionToHide();
	}

	private void DeselectAll()
	{
		foreach (var area in Created)
		{
			area.Selected.SetIsOnWithoutNotify(false);
		}
		SelectedArea = null;
		MapLuaParser.Current.UpdateArea(Rounding.isOn);
	}
	
	private void SetSelectionToDefault()
	{
		HideArea = false;
		DeselectAll();
	}

	private void SetSelectionToHide()
	{
		HideArea = true;
		SelectedArea = null;
		MapLuaParser.Current.UpdateArea(Rounding.isOn);
	}

	private bool IsAnySelected()
	{
		foreach (var area in Created)
		{
			if (area.Selected.isOn)
				return true;
		}

		return false;
	}
#endregion


#region UI
	public void OnValuesChange(int instanceID)
	{
		var editedArea = Created[instanceID];
		var targetDataObject = MapLuaParser.Current.SaveLuaFile.Data.areas[instanceID];
		
		Undo.RegisterUndo(new UndoHistory.HistoryAreaChange(), new UndoHistory.HistoryAreaChange.AreaChangeParam(targetDataObject));

		
		targetDataObject.Name = editedArea.Name.text;

		targetDataObject.rectangle.x = LuaParser.Read.StringToFloat(editedArea.SizeX.text);
		targetDataObject.rectangle.y = LuaParser.Read.StringToFloat(editedArea.SizeY.text);

		if (BorderRelative.isOn)
		{
			targetDataObject.rectangle.width = ScmapEditor.Current.map.Width - LuaParser.Read.StringToFloat(editedArea.SizeWidth.text);
			targetDataObject.rectangle.height = ScmapEditor.Current.map.Height - LuaParser.Read.StringToFloat(editedArea.SizeHeight.text);
		}
		else
		{
			targetDataObject.rectangle.width = LuaParser.Read.StringToFloat(editedArea.SizeWidth.text);
			targetDataObject.rectangle.height = LuaParser.Read.StringToFloat(editedArea.SizeHeight.text);
		}

		if (SelectedArea == targetDataObject)
		{
			MapLuaParser.Current.UpdateArea(Rounding.isOn);
		}
	}
#endregion


	public void AddNew()
	{

		Undo.RegisterUndo(new UndoHistory.HistoryAreasChange());

		List<MapLua.SaveLua.Areas> Areas = MapLuaParser.Current.SaveLuaFile.Data.areas.ToList();
		MapLua.SaveLua.Areas NewArea = new MapLua.SaveLua.Areas();

		string DefaultMapArea = "New Area";
		int NextAreaName = 0;
		bool FoundGoodName = false;
		while (!FoundGoodName)
		{
			FoundGoodName = true;
			string TestName = DefaultMapArea + ((NextAreaName > 0) ? (" " + NextAreaName.ToString()) : (""));
			for (int i = 0; i < MapLuaParser.Current.SaveLuaFile.Data.areas.Length; i++)
			{
				if(MapLuaParser.Current.SaveLuaFile.Data.areas[i].Name == TestName)
				{
					FoundGoodName = false;
					NextAreaName++;
					break;
				}
			}
		}

		NewArea.Name = DefaultMapArea + ((NextAreaName > 0)?(" " + NextAreaName.ToString()) :(""));
		NewArea.rectangle = new Rect(0, 0, ScmapEditor.Current.map.Width, ScmapEditor.Current.map.Height);
		Areas.Add(NewArea);

		MapLuaParser.Current.SaveLuaFile.Data.areas = Areas.ToArray();
		UpdateList();

	}

	public void Remove(int instanceID)
	{
		Undo.RegisterUndo(new UndoHistory.HistoryAreasChange());

		if (SelectedArea == MapLuaParser.Current.SaveLuaFile.Data.areas[instanceID])
		{
			SetSelectionToHide();
		}

		List<MapLua.SaveLua.Areas> Areas = MapLuaParser.Current.SaveLuaFile.Data.areas.ToList();

		Areas.RemoveAt(instanceID);

		MapLuaParser.Current.SaveLuaFile.Data.areas = Areas.ToArray();


		UpdateList();
	}
}

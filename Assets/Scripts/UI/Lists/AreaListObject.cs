using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class AreaListObject : MonoBehaviour {

	public Toggle Selected;

	public int InstanceId;
	public InputField Name;
	public InputField SizeX;
	public InputField SizeY;
	public InputField SizeWidth;
	public InputField SizeHeight;

	public AreaInfo Controler;


	public void OnNameChanged()
	{
		Controler.OnValuesChange(InstanceId);
	}

	public void OnToggle()
	{
		if (Selected.isOn)
		{
			Controler.SelectArea(InstanceId);
		}
		else
		{
			Controler.DeselectArea(InstanceId);
		}
	}

	public void OnRemove()
	{
		Controler.Remove(InstanceId);
	}

	// TODO: We need a top-level input monitor for these type of events
	private void Update()
	{
		if (Input.GetKeyUp(KeyCode.Tab))
		{
			bool next = !Input.GetKey(KeyCode.LeftShift);
			if (Name.isFocused)
			{
				if(next)
					SizeX.Select();
				else
					SizeHeight.Select();
			}else if (SizeX.isFocused)
			{
				if(next)
					SizeY.Select();
				else
					Name.Select();
			}else if (SizeY.isFocused)
			{
				if(next)
					SizeWidth.Select();
				else
					SizeX.Select();
			}else if (SizeWidth.isFocused)
			{
				if(next)
					SizeHeight.Select();
				else
					SizeY.Select();
			}else if (SizeHeight.isFocused)
			{
				if(next)
					Name.Select();
				else
					SizeWidth.Select();
			}
		}
	}
}

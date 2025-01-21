﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

namespace Ozone.UI
{
	public class UiColor : MonoBehaviour
	{
		public float Max = 2;
		public Image ColorPreview;
		public Image AlphaPreview;

		public InputField Red;
		public InputField Green;
		public InputField Blue;
		public InputField Alpha;

		public Slider RedSlider;
		public Slider GreenSlider;
		public Slider BlueSlider;
		public Slider AlphaSlider;

		public UnityEvent OnInputBegin;
		public UnityEvent OnInputFinish;
		public UnityEvent OnValueChanged;

		//System.Action FieldChangedAction;
		bool Loading = false;

		void SetSliderMax()
		{
			RedSlider.maxValue = Max;
			GreenSlider.maxValue = Max;
			BlueSlider.maxValue = Max;
			if (AlphaSlider)
				AlphaSlider.maxValue = Max;
		}

		Vector4 LastValue = Vector4.one;
		void UpdateLastValue()
		{
			LastValue.x = LuaParser.Read.StringToFloat(Red.text);
			LastValue.y = LuaParser.Read.StringToFloat(Green.text);
			LastValue.z = LuaParser.Read.StringToFloat(Blue.text);
			if (AlphaSlider)
				LastValue.w = AlphaSlider.value;
			else
				LastValue.w = 1;
		}

		public Color GetColorValue()
		{
			return new Color(LastValue.x, LastValue.y, LastValue.z, LastValue.w);
		}

		public Vector3 GetVectorValue()
		{
			return LastValue;
		}

		public Vector4 GetVector4Value()
		{
			return LastValue;
		}

		public void SetColorField(float R, float G, float B, float A = 1)
		{
            SetSliderMax();
			Loading = true;
			//if(FieldChangedAction == null)
			//	FieldChangedAction = ChangeAction;

			RedSlider.value = FormatFloat(R);
			GreenSlider.value = FormatFloat(G);
			BlueSlider.value = FormatFloat(B);

			Red.text = FormatFloat(R).ToString();
			Green.text = FormatFloat(G).ToString();
			Blue.text = FormatFloat(B).ToString();

			if (AlphaSlider)
			{
				AlphaSlider.value = FormatFloat(A);
				Alpha.text = AlphaSlider.value.ToString();
			}

			UpdateLastValue();


			UpdateGfx();

			Loading = false;
		}


		public void SetColorField(Color BeginColor)
		{
            SetSliderMax();
			Loading = true;
			//FieldChangedAction = ChangeAction;

			RedSlider.value = BeginColor.r;
			GreenSlider.value = BeginColor.g;
			BlueSlider.value = BeginColor.b;

			Red.text = BeginColor.r.ToString();
			Green.text = BeginColor.g.ToString();
			Blue.text = BeginColor.b.ToString();

			if (AlphaSlider)
			{
				AlphaSlider.value = BeginColor.a;
				Alpha.text = BeginColor.a.ToString();
			}

			UpdateLastValue();


			UpdateGfx();

			Loading = false;
		}

		const float FloatSteps = 10000;
		float FormatFloat(float value)
		{
			return Mathf.RoundToInt(value * FloatSteps) / FloatSteps;
		}


		public void InputFieldUpdate()
		{
			if (Loading)
				return;

			Loading = true;

			RedSlider.value = FormatFloat(LuaParser.Read.StringToFloat(Red.text));
			GreenSlider.value = FormatFloat(LuaParser.Read.StringToFloat(Green.text));
			BlueSlider.value = FormatFloat(LuaParser.Read.StringToFloat(Blue.text));

			if (AlphaSlider)
			{
				AlphaSlider.value = FormatFloat(Mathf.Clamp(LuaParser.Read.StringToFloat(Alpha.text), 0, Max));
				Alpha.text = AlphaSlider.value.ToString();
			}

			UpdateLastValue();

			Loading = false;

			UpdateGfx();
			//FieldChangedAction();
			Begin = false;
			OnInputFinish.Invoke();
		}


		bool UpdatingSlider = false;
		bool Begin = false;
		public void SliderUpdate(bool Finish)
		{
			if (Loading || UpdatingSlider)
				return;

			if (Finish && !Begin)
				return;

			if (!Begin)
			{
				OnInputBegin.Invoke();
				Begin = true;
			}

			UpdatingSlider = true;
			RedSlider.value = FormatFloat(RedSlider.value);
			GreenSlider.value = FormatFloat(GreenSlider.value);
			BlueSlider.value = FormatFloat(BlueSlider.value);

			Red.text = RedSlider.value.ToString();
			Green.text = GreenSlider.value.ToString();
			Blue.text = BlueSlider.value.ToString();

			if (AlphaSlider)
			{
				AlphaSlider.value = FormatFloat(AlphaSlider.value);
				Alpha.text = AlphaSlider.value.ToString();
			}

			UpdateLastValue();

			UpdatingSlider = false;

			UpdateGfx();
			//FieldChangedAction();
			if (Finish)
			{
				OnInputFinish.Invoke();
				Begin = false;
			}
			else
				OnValueChanged.Invoke();
		}

		void UpdateGfx()
		{
			ColorPreview.color = new Color(RedSlider.value / Max, GreenSlider.value / Max, BlueSlider.value / Max, 1);
			if (AlphaPreview)
			{
				AlphaPreview.color = Color.Lerp(Color.black, Color.white, AlphaSlider.value / Max);
			}
		}
	}
}
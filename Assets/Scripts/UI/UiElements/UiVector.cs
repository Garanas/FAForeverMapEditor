using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

namespace Ozone.UI
{
	public class UiVector : MonoBehaviour
	{
		public InputField X;
		public InputField Y;
		public InputField Z;
		public InputField W;

		public bool Normalized = false;

		public UnityEvent OnInputBegin;
		public UnityEvent OnInputFinish;
		public UnityEvent OnValueChanged;

		//System.Action FieldChangedAction;
		bool Loading = false;

		Vector4 LastValue = Vector4.one;
		
		void UpdateLastValue()
		{
			LastValue.x = FormatFloat(LuaParser.Read.StringToFloat(X.text));
			LastValue.y = FormatFloat(LuaParser.Read.StringToFloat(Y.text));
			// Ensure Z/W values are 0f if this is a lower dimensional vector
			LastValue.z = Z ? FormatFloat(LuaParser.Read.StringToFloat(Z.text)) : 0f;
			LastValue.w = W ? FormatFloat(LuaParser.Read.StringToFloat(W.text)) : 0f;
		}

		public Color GetColorValue()
		{
			return new Color(LastValue.x, LastValue.y, LastValue.z, LastValue.w);
		}

		public Vector2 GetVector2Value()
		{
			// Cast LastValue to V2 before normalizing to guarantee the extra dimensions are dropped before normalizing
			var vec2 = (Vector2)LastValue;
			return Normalized ? vec2.normalized : vec2;
		}

		public Vector3 GetVector3Value()
		{
			// Cast LastValue to V3 before normalizing to guarantee the extra dimensions are dropped before normalizing
			var vec3 = (Vector3)LastValue;
			return Normalized ? vec3.normalized : vec3;
		}

		public Vector4 GetVector4Value()
		{
			return Normalized ? LastValue.normalized : LastValue;
		}

		public void SetVectorField(float x, float y, float z = 1f, float w = 1f, bool normalized = false)
		{
			Loading = true;

			X.text = x.ToString();
			Y.text = y.ToString();
			if (Z)
				Z.text = z.ToString();
			if (W)
				W.text = w.ToString();

			Normalized = normalized;

			UpdateLastValue();

			Loading = false;
		}


		public void SetVectorField(Vector4 value, bool normalized = false)
		{
			Loading = true;
			//FieldChangedAction = ChangeAction;

			X.text = value.x.ToString();
			Y.text = value.y.ToString();
			if(Z)
				Z.text = value.z.ToString();
			if(W)
				W.text = value.w.ToString();

			Normalized = normalized;

			LastValue = value;

			UpdateLastValue();

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

			UpdateLastValue();

			Loading = false;

			//Begin = false;
			OnInputFinish.Invoke();
		}


		//bool UpdatingSlider = false;
		//bool Begin = false;

	}
}
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(InputField))]
public class InputDefaultValueOnEnd : MonoBehaviour
{
    [SerializeField] private string DefaultValue = "";
    private InputField field;
    
    private void Awake()
    {
        field = GetComponent<InputField>();
        field.onEndEdit.AddListener(CheckEndVal);
    }

    private void CheckEndVal(string endVal)
    {
        if (string.IsNullOrEmpty(endVal))
            field.SetTextWithoutNotify(DefaultValue);
    }
}

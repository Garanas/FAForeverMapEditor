using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

[RequireComponent(typeof(Button))]
public class ToolTab : MonoBehaviour
{
    public UnityEvent<int> OnTabClicked;

    [SerializeField, ReadOnly] private int index = 0;
    [SerializeField, ReadOnly] private Button button;
    [SerializeField] private GameObject highlight;
    [SerializeField] private Text label;
    
    private void Awake()
    {
        button = GetComponent<Button>();
        button.onClick.AddListener(OnButtonClicked);
    }

    private void OnButtonClicked()
    {
        OnTabClicked?.Invoke(index);
    }

    public void Configure(string tabName, int tabIndex)
    {
        label.text = tabName;
        index = tabIndex;
    }
    
    public void Select() => SetState(true);
    public void Deselect() => SetState(false);

    public void SetState(bool isSelected)
    {
        highlight.SetActive(isSelected);
    }
}

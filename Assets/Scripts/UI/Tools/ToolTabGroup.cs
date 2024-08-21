using System.Collections.Generic;
using UnityEngine;

public class ToolTabGroup : MonoBehaviour
{
    [Header("Setup Refs")]
    [SerializeField] private ToolTab tabPrefab;
    [SerializeField] private RectTransform tabRootTransform;
    [SerializeField] private ToolPage rootPage;
    
    [Header("Runtime View")]
    [SerializeField, ReadOnly] private List<ToolTab> tabs = new List<ToolTab>();

    
    private void Awake()
    {
        // The prefab is left active to clarify the structure in Editor
        tabPrefab.gameObject.SetActive(false);
    }

    public void AddTab(string newTabName)
    {
        var newTab = Instantiate(tabPrefab, tabRootTransform);
        newTab.Configure(newTabName, tabs.Count);
        newTab.OnTabClicked.AddListener(OnTabClicked);
        newTab.gameObject.SetActive(true);
        
        tabs.Add(newTab);
    }

    private void OnTabClicked(int tabIndex)
    {
        rootPage.ChangePage(tabIndex);
    }

    public void SetSelectedTab(int tabIndex)
    {
        for (int i = 0; i < tabs.Count; i++)
        {
            tabs[i].SetState(i == tabIndex);
        }
    }
}

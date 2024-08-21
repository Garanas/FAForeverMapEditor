using UnityEngine;

public abstract class ToolPage : MonoBehaviour
{
    [Header("Tabs")]
    [SerializeField] protected ToolTabGroup tabGroup;
    [SerializeField] protected TabPageIdentifier[] Pages;
    
    protected int PreviousPage = 0;
    protected int CurrentPage = -1;

    public virtual int GetCurrentPage() => CurrentPage;

    public virtual int PreviousCurrentPage() => PreviousPage;


    protected virtual void Awake()
    {
        CreateTabs();
        ChangePage(0);
    }

    private void CreateTabs()
    {
        foreach (var page in Pages)
        {
            tabGroup.AddTab(page.TabName);
        }
    }

    public virtual bool ChangePage(int newPageID)
    {
        if (CurrentPage == newPageID && (CurrentPage != -1 && Pages[CurrentPage].gameObject.activeSelf))
            return false;

        PreviousPage = CurrentPage;
        CurrentPage = newPageID;

        tabGroup.SetSelectedTab(newPageID);
        
        for (int i = 0; i < Pages.Length; i++)
        {
            bool isActivePage = (i == newPageID);
            Pages[i].gameObject.SetActive(isActivePage);
        }

        return true;
    }
}

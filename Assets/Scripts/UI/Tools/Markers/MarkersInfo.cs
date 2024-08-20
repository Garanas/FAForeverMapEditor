using Selection;

namespace EditMap
{
	public class MarkersInfo : ToolPage
	{
		public static MarkersInfo Current;

		public ChainsList ChainsInfo;
		public MarkersList MarkerList;
		
		protected override void Awake()
		{
			base.Awake();
			Current = this;
		}
		
		void OnEnable()
		{
			ChangePage(CurrentPage);
		}

		void OnDisable()
		{
			SelectionManager.Current.ClearAffectedGameObjects();
			MarkerList.Clean();
		}

		public static bool MarkerPageChange = false;
		public override bool ChangePage(int PageId)
		{
			MarkerPageChange = true;
			bool pageChanged = base.ChangePage(PageId);
			MarkerPageChange = false;
			
			return pageChanged;
		}
	}
}

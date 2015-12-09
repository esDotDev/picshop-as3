package ca.esdot.lib.containers
{
	import ca.esdot.lib.containers.layouts.HorizontalLayout;
	import ca.esdot.lib.containers.layouts.VerticalLayout;
	import ca.esdot.lib.view.SizableView;
	
	public class VBox extends SizableView
	{
		public function VBox() {
			layout = new VerticalLayout();
		}
	}
}
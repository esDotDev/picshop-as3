package ca.esdot.picshop.components.containers
{
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.lib.components.layouts.VerticalLayout;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	public class VBox extends SizableView
	{
		public function VBox() {
			layout = new HorizontalLayout();
		}
	}
}
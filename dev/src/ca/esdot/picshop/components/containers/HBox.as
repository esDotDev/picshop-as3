package ca.esdot.picshop.components.containers
{
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.lib.components.layouts.HorizontalLayout;
	import ca.esdot.lib.components.layouts.VerticalLayout;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	public class HBox extends SizableView
	{
		public function HBox() {
			layout = new HorizontalLayout();
		}
	}
}
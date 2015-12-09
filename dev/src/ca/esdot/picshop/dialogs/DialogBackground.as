package ca.esdot.picshop.dialogs
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	import swc.PanelBg;

	public class DialogBackground extends SizableView
	{
		public var outer:Bitmap;
		public var inner:Bitmap;
		public var bg:swc.PanelBg;
		
		public function DialogBackground() {
			
			outer = new Bitmap(SharedBitmaps.backgroundAccent);
			addChild(outer);
			
			inner = new Bitmap(SharedBitmaps.bgColor2);
			addChild(inner);
			
		}
		
		override public function updateLayout():void {
			outer.width = viewWidth;
			outer.height = viewHeight;
			inner.x = inner.y = 1;
			inner.width = viewWidth - 2;
			inner.height = viewHeight - 2;
			
		}
	}
}
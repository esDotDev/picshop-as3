package ca.esdot.picshop.components.buttons
{
	import assets.Bitmaps;
	
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	public class HideButton extends LabelButton
	{
		public var arrow:Bitmap;
		
		public function HideButton() {
			super();
			arrow = new Bitmaps.hideArrow();
			arrow.smoothing = true;
			addChild(arrow);
		}
		
		override public function updateLayout():void {
			super.updateLayout();
			
			arrow.height = bg.height * .4;
			arrow.scaleX = arrow.scaleY;
			
			arrow.x = bg.width - arrow.width >> 1;
			arrow.y = bg.height - arrow.height >> 1;
		}
	}
}
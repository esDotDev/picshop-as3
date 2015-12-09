package ca.esdot.picshop.views
{
	import flash.display.Bitmap;
	
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	public class CoreImageTestView extends SizableView
	{
		protected var bg:Bitmap;
		
		public function CoreImageTestView(){
			
			bg = new Bitmap(SharedBitmaps.bgColor);
			addChild(bg);
		}
		
		override public function updateLayout():void {
			bg.width = viewWidth;
			bg.height = viewHeight;
		}
	}
}
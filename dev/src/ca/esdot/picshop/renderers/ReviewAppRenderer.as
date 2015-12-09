package ca.esdot.picshop.renderers
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	
	import swc.ReviewAppRenderer;
	
	public class ReviewAppRenderer extends Sprite
	{
		public var bg:Bitmap;
		
		public function ReviewAppRenderer(){
			var viewAssets:swc.ReviewAppRenderer = new swc.ReviewAppRenderer();
			addChild(viewAssets.text1);
			addChild(viewAssets.text2);
			
			bg = new Bitmap(new BitmapData(1, 1, true, 0x0));
			bg.height = 58;
			addChild(bg);
			
			mouseChildren = false;
		}	
		
		override public function set width(value:Number):void {
			bg.width = value;
		}
	}
}
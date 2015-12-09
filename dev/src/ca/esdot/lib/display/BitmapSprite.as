package ca.esdot.lib.display
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	
	public class BitmapSprite extends Sprite
	{
		protected var bitmap:Bitmap;
		
		public function BitmapSprite(bitmapData=null, pixelSnapping="auto", smoothing=true){
			mouseChildren = false;
			bitmap = new Bitmap(bitmapData, pixelSnapping, smoothing);
			addChild(bitmap);
		}
		
		public function get bitmapData():BitmapData { return bitmap.bitmapData; }
		public function set bitmapData(value:BitmapData):void {
			bitmap.bitmapData = value;
		}
		
		public function centerVertically():void {
			bitmap.y = -bitmap.height * .5;
		}
	}
}
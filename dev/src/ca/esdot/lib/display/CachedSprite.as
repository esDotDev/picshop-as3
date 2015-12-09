package ca.esdot.lib.display
{
	import ca.esdot.picshop.MainView;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public class CachedSprite extends Sprite
	{
		protected static var dataCache:Object = {};
		
		protected var bitmap:Bitmap;
		protected var container:Sprite;
		
		public function CachedSprite(target:DisplayObject, scale:Number = 2)
		{
			var m:Matrix = new Matrix();
			m.scale(scale, scale);
			m.translate(1, 1);
			
			bitmap = new Bitmap();
			addChild(bitmap);
			
			if(!target || target.width == 0 || target.height == 0){
				return;
			}
			
			bitmap.bitmapData = new BitmapData((target.width + 2) * scale, (target.height + 2) * scale, true, 0x0);
			if(RENDER::GPU) {
				bitmap.bitmapData.drawWithQuality(target, m, null, null, null, true, StageQuality.HIGH_16X16);
			} else {
				bitmap.bitmapData.draw(target, m, null, null, null, true);
			}
			bitmap.smoothing = true;
			bitmap.scaleX = bitmap.scaleY = 1/scale;
		}
	}
}
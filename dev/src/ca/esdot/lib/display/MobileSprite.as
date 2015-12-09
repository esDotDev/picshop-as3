package ca.esdot.lib.display
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	
	public class MobileSprite extends Sprite
	{
		public static const SCALE_CHANGED:String = "scaleChanged";
		
		public static var dispatcher:EventDispatcher = new EventDispatcher();
		
		private static var _globalScale:Number = 1;
		public static function get globalScale():Number	{ return _globalScale; }
		public static function set globalScale(value:Number):void {
			_globalScale = value;
			dispatcher.dispatchEvent(new Event(SCALE_CHANGED));
		}
		
		protected static var scaleMatrix:Matrix;
		
		protected var drawTarget:Sprite;
		protected var cache:Bitmap;
		protected var cacheData:BitmapData;
		
		protected var _scale:Number;

		public function get scale():Number { return _scale; }
		public function set scale(value:Number):void {
			if(_scale == value){ return; }
			_scale = value;
			updateCache();
		}
		
		public function MobileSprite(){
			drawTarget = new Sprite();
			if(!scaleMatrix){
				scaleMatrix = new Matrix();
				scaleMatrix.scale(globalScale, globalScale);
			}
			
			dispatcher.addEventListener(MobileSprite.SCALE_CHANGED, onScaleChanged, false, 0, true);
			
			cache = new Bitmap(null, PixelSnapping.ALWAYS, true);
			addChild(cache);
			
			scale = globalScale;
		}
		
		protected function onScaleChanged(event:Event):void {
			scale = globalScale;
		}
		
		protected function updateCache():void {
			if(!drawTarget || drawTarget.width == 0 || drawTarget.height == 0){ return; }
			
			cacheData = new BitmapData(drawTarget.width * _scale, drawTarget.height * _scale, true, 0x000000);
			cacheData.fillRect(cacheData.rect, 0x0);
			cacheData.drawWithQuality(drawTarget, scaleMatrix, null, null, null, true, StageQuality.HIGH);
			cache.bitmapData = cacheData;
			cache.smoothing = true;			
		}
	}
}
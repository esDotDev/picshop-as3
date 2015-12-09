package ca.esdot.picshop.components
{
	import com.gskinner.motion.GTween;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import ca.esdot.lib.view.SizableView;
	
	import fl.motion.easing.Quadratic;
	
	public class AnimatedDiv extends SizableView
	{
		protected var bitmap:Bitmap;
		protected var _bitmapData:BitmapData;
		protected var tween:GTween;
		protected var bottomAlign:Boolean;
		
		public function AnimatedDiv(bitmapData:BitmapData, height:int = 1, bottomAlign:Boolean = false){
			super();
			this.bottomAlign = bottomAlign;
			mouseEnabled = mouseChildren = false;
			bitmap = new Bitmap();
			addChild(bitmap);
			
			this.bitmapData = bitmapData;
			
			bitmap.height = 1;
			tween = new GTween(bitmap, .35, {}, {ease: Quadratic.easeOut, onChange: onChange});
		}
		
		protected function onChange(tween:GTween):void {
			if(bottomAlign){
				bitmap.y = -bitmap.height + 1;
			}
		}
		
		override public function updateLayout():void {
			bitmap.width = viewWidth;
			if(bitmap.height != viewHeight){
				tween.proxy.height = viewHeight;
			}
		}

		public function get bitmapData():BitmapData { return _bitmapData;	}
		public function set bitmapData(value:BitmapData):void {
			_bitmapData = value;
			bitmap.bitmapData = value;
		}

	}
}
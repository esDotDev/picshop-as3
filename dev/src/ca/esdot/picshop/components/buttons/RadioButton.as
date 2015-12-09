package ca.esdot.picshop.components.buttons
{
	
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.utils.SpriteUtils;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.data.colors.AccentColors;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	
	import swc.RadioBg;
	import swc.RadioDownBg;
	
	public class RadioButton extends LabelButton
	{
		protected static var bgCache:BitmapData;
		protected static var bgDownCache:BitmapData;
		
		public var radioBg:Bitmap;
		public var radioBgDown:Bitmap;
		
		protected var lock:Sprite;
		
		public function RadioButton(label:String="", icon:Bitmap=null) {
			super(label, icon);
			 align = "left";
		}
		
		public function set isLocked(value:Boolean):void {
			if(value){
				if(!lock){
					lock = new swc.LockIcon();
					lock.height = radioBg.height;
					lock.scaleX = lock.scaleY;
				}
				addChild(lock);
				radioBg.visible = radioBgDown.visible = false;
			} else if(lock && contains(lock)){
				removeChild(lock);
			}
			updateLayout();
		}
		
		override protected function createChildren():void {
			//Draw RadioDown
			var size:int = 20;
			
			if(!bgCache){
				var sprite:Sprite = new swc.RadioBg();
				bgCache = SpriteUtils.draw(sprite);
				
				sprite = new swc.RadioDownBg();
				bgDownCache = SpriteUtils.draw(sprite);
			}
			
			var ct:ColorTransform = new ColorTransform(); 
			ct.color = AccentColors.currentColor;
			
			radioBg = new Bitmap(bgCache, "auto", true);
			radioBg.transform.colorTransform = ct;
			
			radioBgDown = new Bitmap(bgDownCache, "auto", true);
			radioBgDown.transform.colorTransform = ct;
			
			super.createChildren();
			
			addChild(radioBg);
			//addChild(radioBgDown);
		}
		
		override public function updateLayout():void {
			super.updateLayout();
			
			labelText.x = 20;
			
			divider.width = viewWidth;
			divider.height = 1;
			divider.x = 0;
			divider.y = bg.height - divider.height;
			
			radioBg.width = radioBg.height = labelText.textHeight;
			radioBg.x = viewWidth - radioBg.width - 10 * DeviceUtils.screenScale;
			radioBg.y = viewHeight - radioBg.height >> 1;
			
			radioBg.width = radioBg.height = radioBg.width;
			radioBgDown.x = radioBg.x + (radioBg.width - radioBgDown.width >> 1);
			radioBgDown.y = viewHeight - radioBgDown.height >> 1;
			
			if(lock){
				lock.x = radioBg.x;
				lock.y = radioBg.y;
			}
		}
		
		
	}
}
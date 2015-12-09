package ca.esdot.picshop.components
{
	import com.gskinner.motion.GTween;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	
	import ca.esdot.lib.components.Image;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.utils.TextFields;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.data.FacebookPhotoData;
	import ca.esdot.picshop.data.colors.ColorTheme;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	import fl.motion.easing.Quadratic;
	
	public class FacebookImage extends SizableView {
		
		protected var image:Image;
		public var photo:FacebookPhotoData;
		protected var size:int;
		
		protected var contents:Sprite;
		
		protected var _cache:BitmapData;
		protected var cacheDisplay:Bitmap;
		
		public function FacebookImage(photo:FacebookPhotoData, size:int, loadDelay:int = 0){
			this.photo = photo;
			this.size = size;
			mouseChildren = false;
			
			contents = new Sprite();
			addChild(contents);
			
			var bottom:Bitmap = new Bitmap(SharedBitmaps.strokeColor);
			bottom.width = size;
			bottom.height = size;
			contents.addChild(bottom);
			
			image = new Image();
			image.setSize(size, size);
			image.addEventListener(Event.COMPLETE, onImageLoadComplete);
			setTimeout(function(target){
				image.source = photo.imageUrl;
				target.visible = true;
				new GTween(target, .350, {y: target.y}, {ease: Quadratic.easeOut});
				new GTween(target, .6, {alpha: 1}, {ease: Quadratic.easeOut});
				target.y += 250;
			}, loadDelay, this);
			this.alpha = 0;
			this.visible = false;
			
			contents.addChild(image);
			cacheDisplay = new Bitmap();
		}
		
		protected function onImageLoadComplete(event:Event):void {
			cache();
		}
		
		override public function destroy():void {
			photo = null;
			if(image){
				image.destroy();
			}
			if(_cache){
				_cache.dispose();
				_cache = null;
			}
			removeChildren();
		}
		
		protected function cache():void {
			_cache = new BitmapData(size, size, false, 0x0);
			if(RENDER::GPU){
				_cache.drawWithQuality(contents, null, null, null, null, true, StageQuality.HIGH);
			} else {
				_cache.draw(contents, null, null, null, null, true);
			}
			cacheDisplay.bitmapData = _cache;
			removeChildren();
			addChild(cacheDisplay);
		}
		
			
	}
}
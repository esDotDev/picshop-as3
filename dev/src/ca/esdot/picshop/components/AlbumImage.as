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
	import ca.esdot.lib.utils.SpriteUtils;
	import ca.esdot.lib.utils.TextFields;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.data.FacebookAlbumData;
	import ca.esdot.picshop.data.colors.ColorTheme;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	import fl.motion.easing.Quadratic;
	
	public class AlbumImage extends SizableView {
		
		protected var image:Image;
		protected var underlay:Bitmap;
		protected var textField:TextField;
		public var album:FacebookAlbumData;
		protected var size:int;
		
		protected var contents:Sprite;
		
		protected var _cache:BitmapData;
		protected var cacheDisplay:Bitmap;
		
		public function AlbumImage(album:FacebookAlbumData, size:int, loadDelay:int = 0){
			this.album = album;
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
			image.source = album.imageUrl;
			
			var target:AlbumImage = this;
			setTimeout(function(target:AlbumImage):void {	
				new GTween(target, .350, {y: target.y}, {ease: Quadratic.easeOut});
				new GTween(target, .6, {alpha: 1}, {ease: Quadratic.easeOut});
				contents.addChild(textField);
				target.y += 250;
			}, loadDelay, this);
			this.alpha = 0;
			
			contents.addChild(image);
			
			underlay = new Bitmap(SharedBitmaps.bgColor);
			underlay.width = size;
			underlay.height = DeviceUtils.fontSize * 2;
			underlay.alpha = .75;
			underlay.y = size - underlay.height;
			contents.addChild(underlay);
			
			textField = TextFields.getRegular(DeviceUtils.fontSize * .75 |0, 0xFFFFFF, "right");
			ColorTheme.colorTextfield(textField);
			
			textField.multiline = false;
			textField.wordWrap = false;
			textField.x = size * .03|0;
			textField.width = size * .96|0;
			var title:String = album.name;
			if(title.length > 24){
				title = title.substr(0, 24);
			}
			textField.text = title;
			textField.y = underlay.y + (underlay.height - textField.textHeight >> 1);
			
			cacheDisplay = new Bitmap();
			
		}
		
		override public function destroy():void {
			album = null;
			if(image){
				image.destroy();
			}
			if(_cache){
				_cache.dispose();
				_cache = null;
			}
			removeChildren();
			ColorTheme.removeSprite(textField);
		}
		
		protected function onImageLoadComplete(event:Event):void {
			setTimeout(cache, 1000);
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
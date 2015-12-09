package ca.esdot.picshop.views
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.utils.SpriteUtils;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.components.ButtonBar;
	import ca.esdot.picshop.data.Strings;
	import ca.esdot.picshop.data.colors.ColorTheme;
	
	public class FullscreenCropView extends SizableView
	{
		public var bitmapData:BitmapData;
		public var cropView:CropView;
		
		protected var bitmap:Bitmap;
		protected var underlay:Sprite;
		
		public var buttonBar:ButtonBar;
		
		public function FullscreenCropView(bitmapData:BitmapData) {
			this.bitmapData = bitmapData;
			
			underlay = SpriteUtils.getUnderlay(ColorTheme.bgColor, 1, 1, 1);
			addChild(underlay);
			
			bitmap = new Bitmap(bitmapData, "auto", true);
			addChild(bitmap);
			
			buttonBar = new ButtonBar();
			buttonBar.setButtons([Strings.DISCARD, Strings.APPLY]);
			addChild(buttonBar);
		}
	
		override public function updateLayout():void {
			if(stage){ stage.addEventListener(Event.RESIZE, onStageResized, false, 0, true); }
			
			underlay.width = viewWidth;
			underlay.height = viewHeight;
			
			buttonBar.setSize(viewWidth, DeviceUtils.hitSize * .75);
			buttonBar.y = viewHeight - buttonBar.height;
			
			var maxHeight:int = viewHeight - buttonBar.height;
			
			var scale:Number = Math.min(viewWidth/bitmapData.width, maxHeight/bitmapData.height);
			bitmap.scaleX = bitmap.scaleY = scale;
			
			bitmap.x = viewWidth - bitmap.width >> 1;
			bitmap.y = maxHeight - bitmap.height >> 1;
			
			if(cropView){ removeChild(cropView); }
			cropView = new CropView(bitmap);
			
			addChild(cropView);
		}
		
		protected function onStageResized(event:Event):void {
			if(!stage){ return; }
			setSize(stage.stageWidth, stage.stageHeight);
		}
	}
}
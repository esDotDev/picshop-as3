package ca.esdot.picshop.dialogs
{
	import assets.Bitmaps;
	
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.components.ColorPanel;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;

	public class ColorDialog extends BaseDialog
	{
		public var panel:ColorPanel;
		public var divider:Bitmap;
		public var colorSwatch:Bitmap;
		
		public function ColorDialog() {
			
		}
		
		override protected function createChildren():void {
			panel = new ColorPanel();
			panel.addEventListener(ChangeEvent.CHANGED, onColorChanged, false, 0, true);
			addChild(panel);
			
			colorSwatch = new Bitmap(new BitmapData(1, 1, false, panel.currentColor));
			addChild(colorSwatch);
			
			divider = new Bitmap(SharedBitmaps.backgroundAccent);
			addChild(divider);
			
			_viewWidth = panel.width + DeviceUtils.hitSize + padding * 2;
			_viewHeight = panel.height + padding * 2 + DeviceUtils.hitSize;
			super.createChildren();
		}
		
		public function get color():uint {
			return panel.currentColor;
		}
		
		protected function onColorChanged(event:ChangeEvent):void {
			colorSwatch.bitmapData.fillRect(colorSwatch.bitmapData.rect, event.newValue as Number);
		}
		
		override public function updateLayout():void {
			super.updateLayout();
			
			panel.y = padding;
			panel.x = padding;
			
			if(panel.width + DeviceUtils.hitSize > viewWidth){
				panel.width = viewWidth - DeviceUtils.hitSize - 20;
				panel.scaleY = panel.scaleX;
			}
			
			divider.width = 1;
			divider.height = viewHeight - buttonHeight;
			divider.x = padding + panel.width + padding;
			
			colorSwatch.width = DeviceUtils.hitSize;
			colorSwatch.height = divider.height;
			colorSwatch.x = divider.x;
			
		}
	}
}
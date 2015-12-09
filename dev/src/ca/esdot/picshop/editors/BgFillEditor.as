package ca.esdot.picshop.editors
{
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.components.buttons.ColorButton;
	import ca.esdot.picshop.views.EditView;
	
	import flash.display.BitmapData;
	
	public class BgFillEditor extends AbstractEditor
	{
		protected var colorButton:ColorButton;
		protected var currentColor:uint;
		
		public function BgFillEditor(editView:EditView){
			super(editView);
		}

		override public function createChildren():void {
			
			colorButton = new ColorButton();
			colorButton.bg.visible = false;
			colorButton.addEventListener(ChangeEvent.CHANGED, onColorChanged, false, 0, true);
			controlsLayer.addChild(colorButton);
			
			sourceDataSmall.fillRect(currentBitmapData.rect, 0xFF000000);
		}
		
		protected function onColorChanged(event:ChangeEvent):void {
			currentColor = event.newValue as uint;
			currentBitmapData.fillRect(currentBitmapData.rect, currentColor);
		}
		
		override protected function updateControlsLayout():void {
			if(viewWidth > viewHeight){
				colorButton.setSize(viewWidth/2, DeviceUtils.hitSize);
			} else {
				colorButton.setSize(viewWidth, DeviceUtils.hitSize);
			}
		}
		
		override public function applyToSource():BitmapData {
			return new BitmapData(sourceData.width, sourceData.height, false, currentColor);
		}
		
	}
}
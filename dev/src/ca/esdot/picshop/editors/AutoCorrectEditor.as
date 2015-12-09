package ca.esdot.picshop.editors
{
	import com.quasimondo.geom.ColorMatrix;
	
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	
	import ca.esdot.lib.image.ImageProcessing;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.components.buttons.CheckBoxButton;
	import ca.esdot.picshop.views.EditView;
	
	public class AutoCorrectEditor extends AbstractEditor
	{
		public var checkBox1:CheckBoxButton;
		public var checkBox2:CheckBoxButton;
		
		public var contrast:Boolean;
		public var brightness:Boolean;
		
		public var colorMatrix:ColorMatrix;
		
		public function AutoCorrectEditor(editView:EditView){
			super(editView);
			colorMatrix = new ColorMatrix()
			processTimer.start();
		}
		
		override public function createChildren():void {
			checkBox1 = new CheckBoxButton("Brightness");
			checkBox1.addEventListener(MouseEvent.CLICK, onBrightnessChanged, false, 0, true);
			controlsLayer.addChild(checkBox1);
			
			checkBox2 = new CheckBoxButton("Contrast");
			checkBox2.addEventListener(MouseEvent.CLICK, onContrastChanged, false, 0, true);
			controlsLayer.addChild(checkBox2);
		}
		
		override protected function updateControlsLayout():void {
			
			checkBox1.setSize(viewWidth/2, DeviceUtils.hitSize);
				
			checkBox2.x = checkBox1.width;
			checkBox2.setSize(viewWidth/2, DeviceUtils.hitSize);
		}
		
		protected function onBrightnessChanged(event:MouseEvent):void {
			settingsDirty = true;
			brightness = checkBox1.isSelected;
		}
		
		protected function onContrastChanged(event:MouseEvent):void {
			settingsDirty = true;
			contrast = checkBox2.isSelected;
		}
		
		override public function destroy():void {
			super.destroy();
			checkBox1.removeEventListener(MouseEvent.CLICK, onBrightnessChanged);
			checkBox1 = null;
			checkBox2.removeEventListener(MouseEvent.CLICK, onContrastChanged);
			checkBox2 = null;
		}
		
		override protected function applyChanges():void {
			if(!settingsDirty){ return; }
			
			var newImage:BitmapData = sourceDataSmall.clone();
			
			if(brightness){
				ImageProcessing.autoBrightness(newImage);
			}
			
			if(contrast){
				ImageProcessing.autoContrast(newImage);
			}
			
			setCurrentBitmapData(newImage);
			settingsDirty = false;
		}
		
		override public function applyToSource():BitmapData {
			var newSource:BitmapData = sourceData.clone();
			if(brightness){
				ImageProcessing.autoBrightness(newSource);
			}
			if(contrast){
				ImageProcessing.autoContrast(newSource);
			}
			return newSource;
		}
	}
}
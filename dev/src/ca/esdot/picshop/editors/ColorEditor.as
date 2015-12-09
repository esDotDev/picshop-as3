package ca.esdot.picshop.editors
{
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.image.ImageProcessing;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.components.Slider;
	import ca.esdot.picshop.views.EditView;
	
	import com.quasimondo.geom.ColorMatrix;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filters.BlurFilter;
	
	public class ColorEditor extends AbstractEditor
	{
		public var slider:Slider;
		public var slider2:Slider;
		
		public var saturation:Number;
		public var hue:Number;
		public var colorMatrix:ColorMatrix;
		
		public function ColorEditor(editView:EditView){
			super(editView);
			colorMatrix = new ColorMatrix()
			processTimer.start();
		}
		
		
		override public function createChildren():void {
			slider = new Slider(.5, "Saturation");
			slider.addEventListener(ChangeEvent.CHANGED, onSlider1Changed, false, 0, true);
			controlsLayer.addChild(slider);
			
			slider2 = new Slider(.5, "Hue");
			slider2.addEventListener(ChangeEvent.CHANGED, onSlider2Changed, false, 0, true);
			controlsLayer.addChild(slider2);
		}
		
		override protected function updateControlsLayout():void {
			
			slider.x = viewWidth * .025;
			slider.width = viewWidth/2 - slider.x * 2;
			
			slider2.x = viewWidth/2;
			slider2.width = viewWidth - slider2.x - viewWidth * .05;
		}
		
		protected function onSlider1Changed(event:ChangeEvent):void {
			saturation = Number(event.newValue) * 2;
			settingsDirty = true;
		}
		
		protected function onSlider2Changed(event:ChangeEvent):void {
			hue = 180 + Number(event.newValue) * 360;
			settingsDirty = true;
		}
		
		override protected function applyChanges():void {
			if(!settingsDirty){ return; }
			
			colorMatrix.reset();
			if(!isNaN(saturation)){
				colorMatrix.adjustSaturation(saturation);
			}
			if(!isNaN(hue)){
				colorMatrix.adjustHue(hue);
			}
			currentBitmapData.applyFilter(sourceDataSmall, currentBitmapData.rect, currentBitmapData.rect.topLeft, colorMatrix.filter);
			
			settingsDirty = false;
		}
		
		override public function applyToSource():BitmapData {
			var newSource:BitmapData = sourceData.clone();
			
			colorMatrix.reset();
			if(!isNaN(saturation)){
				colorMatrix.adjustSaturation(saturation);
			}
			if(!isNaN(hue)){
				colorMatrix.adjustHue(hue);
			}
			newSource.applyFilter(sourceData, newSource.rect, newSource.rect.topLeft, colorMatrix.filter);
			
			return newSource;
		}
	}
}
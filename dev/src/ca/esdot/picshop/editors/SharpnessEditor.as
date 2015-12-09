package ca.esdot.picshop.editors
{
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.image.ImageProcessing;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.components.Slider;
	import ca.esdot.picshop.views.EditView;
	
	import com.gskinner.filters.SharpenFilter;
	import com.quasimondo.geom.ColorMatrix;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filters.BlurFilter;
	
	public class SharpnessEditor extends AbstractEditor
	{
		public var slider:Slider;
		
		public var sharpness:Number;
		public var colorMatrix:ColorMatrix;
		
		protected var sharpenFilter:SharpenFilter = new SharpenFilter(100);
		protected var blurFilter:BlurFilter = new BlurFilter(0, 0, 2);
		
		public function SharpnessEditor(editView:EditView){
			super(editView);
			colorMatrix = new ColorMatrix()
			processTimer.start();
		}
		
		override public function createChildren():void {
			slider = new Slider(.5, "Sharpness");
			slider.addEventListener(ChangeEvent.CHANGED, onSlider1Changed, false, 0, true);
			controlsLayer.addChild(slider);
		}
		
		override protected function updateControlsLayout():void {
			slider.x = viewWidth * .025;
			slider.width = viewWidth - slider.x * 2;
		}
		
		protected function onSlider1Changed(event:ChangeEvent):void {
			
			sharpness = Number(event.newValue) *  100;
			settingsDirty = true;
		}
		
		override protected function applyChanges():void {
			if(!settingsDirty){ return; }
			
			if(!isNaN(sharpness)){
				if(sharpness >= 50){
					sharpenFilter.amount = ((sharpness-50) /  ((sourceDataSmall.width * sourceDataSmall.height) * .0000035));
					currentBitmapData.applyFilter(sourceDataSmall, currentBitmapData.rect, currentBitmapData.rect.topLeft, sharpenFilter);
					//trace("Sharpened: ", sharpenFilter.amount);
				} else {
					blurFilter.blurX = blurFilter.blurY = (50 - sharpness) / (sourceDataSmall.width * sourceDataSmall.height * .000025);
					currentBitmapData.applyFilter(sourceDataSmall, currentBitmapData.rect, currentBitmapData.rect.topLeft, blurFilter);
				}
			}
			settingsDirty = false;
		}
		
		override public function applyToSource():BitmapData {
			var newSource:BitmapData = sourceData.clone();
			
			if(!isNaN(sharpness)){
				if(sharpness >= 50){
					sharpenFilter.amount = ((sharpness-50) /  ((sourceData.width * sourceData.height) * .0000028));
					sharpenFilter.amount *= (sourceData.width/sourceDataSmall.width) * (sourceData.width/sourceDataSmall.width);
					newSource.applyFilter(sourceData, newSource.rect, newSource.rect.topLeft, sharpenFilter);
					//trace("Sharpened: ", sharpenFilter.amount);
				} else {
					blurFilter.blurX = blurFilter.blurY = (50 - sharpness) / (sourceData.width * sourceData.height * .000025);
					newSource.applyFilter(sourceData, newSource.rect, newSource.rect.topLeft, blurFilter);
				}
			}
			return newSource;
		}
	}
}
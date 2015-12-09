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
	
	public class ColorChannelsEditor extends AbstractEditor
	{
		public var slider:Slider;
		public var slider2:Slider;
		public var slider3:Slider;
		
		public var colorMatrix:ColorMatrix;
		public var r:Number = 0;
		public var g:Number = 0;
		public var b:Number = 0;
		
		public function ColorChannelsEditor(editView:EditView){
			super(editView);
			colorMatrix = new ColorMatrix()
			processTimer.start();
		}
		
		override public function createChildren():void {
			slider = new Slider(0, "Red");
			slider.addEventListener(ChangeEvent.CHANGED, onSlider1Changed, false, 0, true);
			controlsLayer.addChild(slider);
			
			slider2 = new Slider(0, "Green");
			slider2.addEventListener(ChangeEvent.CHANGED, onSlider2Changed, false, 0, true);
			controlsLayer.addChild(slider2);
			
			slider3 = new Slider(0, "Blue");
			slider3.addEventListener(ChangeEvent.CHANGED, onSlider3Changed, false, 0, true);
			controlsLayer.addChild(slider3);
		}
		
		override protected function updateControlsLayout():void {
			var w:int = viewWidth * .3;
			slider.x = viewWidth * .025;
			slider.width = w;
			
			//slider2.y = padding;
			slider2.x = (slider.x * 2 + w);
			slider2.width = w;
			
			slider3.x = (slider.x * 2 + w) * 2;
			slider3.width = w;
		}
		
		protected function onSlider1Changed(event:ChangeEvent):void {
			r = Number(event.newValue);
			settingsDirty = true;
		}
		
		protected function onSlider2Changed(event:ChangeEvent):void {
			g = Number(event.newValue);
			settingsDirty = true;
		}
		
		protected function onSlider3Changed(event:ChangeEvent):void {
			b = Number(event.newValue);
			settingsDirty = true;
		}
		
		override protected function applyChanges():void {
			if(!settingsDirty){ return; }
			
			colorMatrix.reset();
			
			colorMatrix.rotateRed(360 * r);
			colorMatrix.rotateGreen(360 * g);
			colorMatrix.rotateBlue(360 * b);
			
			currentBitmapData.applyFilter(sourceDataSmall, sourceDataSmall.rect, sourceDataSmall.rect.topLeft, colorMatrix.filter);
			settingsDirty = false;
		}
		
		override public function applyToSource():BitmapData {
			var newSource:BitmapData = sourceData.clone();
			
			colorMatrix.reset();
			
			colorMatrix.rotateRed(360 * r);
			colorMatrix.rotateGreen(360 * g);
			colorMatrix.rotateBlue(360 * b);
			
			newSource.applyFilter(sourceData, sourceData.rect, sourceData.rect.topLeft, colorMatrix.filter);
			
			return newSource;
		}
	}
}
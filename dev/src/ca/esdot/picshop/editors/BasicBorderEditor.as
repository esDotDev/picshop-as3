package ca.esdot.picshop.editors
{
	import flash.display.BitmapData;
	import flash.display.StageQuality;
	import flash.geom.Matrix;
	
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.image.ImageBorders;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.components.PolaroidTextField;
	import ca.esdot.picshop.components.Slider;
	import ca.esdot.picshop.components.buttons.ColorButton;
	import ca.esdot.picshop.views.EditView;
	
	public class BasicBorderEditor extends AbstractEditor
	{
		protected var filterType:String;
		
		public var slider:Slider;
		public var strength:Number;
		public var colorButton:ColorButton;
		protected var currentColor:uint;
		protected var bottomText:PolaroidTextField;
		
		public function BasicBorderEditor(editView:EditView, filterType:String) {
			super(editView);
			this.filterType = filterType;
		}
		
		override public function createChildren():void {
			
			slider = new Slider(.5, "");
			slider.addEventListener(ChangeEvent.CHANGED, onSlider1Changed, false, 0, true);
			
			colorButton = new ColorButton();
			colorButton.bg.visible = false;
			colorButton.addEventListener(ChangeEvent.CHANGED, onColorChanged, false, 0, true);
		}
		
		protected function onColorChanged(event:ChangeEvent):void {
			currentColor = event.newValue as Number;
			settingsDirty = true;
		}
		
		override protected function updateControlsLayout():void {
			
			if(filterType == ImageBorders.THIN || filterType == ImageBorders.THICK || 
			   filterType == ImageBorders.AURA || filterType == ImageBorders.FEATHERED){	
				slider.visible = true;
				slider.x = viewWidth * .025;
				slider.width = viewWidth/2 - slider.x * 2;
				controlsLayer.addChild(slider);
				
				colorButton.visible = true;
				colorButton.setSize(slider.width, slider.height * .65);
				colorButton.x = viewWidth/2 + slider.x;
				colorButton.y = slider.height - colorButton.height >> 1;
				controlsLayer.addChild(colorButton);
				
			} 
			else if([ImageBorders.TORN, ImageBorders.TORN_2, 
				     ImageBorders.TORN_3, ImageBorders.TORN_4].indexOf(filterType) != -1){
				
				colorButton.visible = true;
				colorButton.setSize(viewWidth/2, DeviceUtils.hitSize * .75);
				colorButton.x = viewWidth - colorButton.width >> 1;
				
				//colorButton.y = colorButton.height >> 1;
				controlsLayer.addChild(colorButton);
				
			}
			else {
				bg.visible = false;
			}
		}
		
		
		
		protected function onSlider1Changed(event:ChangeEvent):void {	
			strength = Number(event.newValue);
			settingsDirty = true;
		}
		
		override public function init():void {
			super.init();
			
			var data:BitmapData = sourceDataSmall.clone();
			applyBorder(data);
			setCurrentBitmapData(data);
			processTimer.start();
			
			switch(filterType){
				case ImageBorders.POLAROID_CLEAN:
				case ImageBorders.POLAROID_DIRTY:
					if(!bottomText){
						bottomText = new PolaroidTextField();
						addChild(bottomText);
					}
					bottomText.width = currentBitmap.width * .9;
					bottomText.x = imageView.container.x + (currentBitmap.width - bottomText.width >> 1);
					bottomText.y = imageView.container.y + editView.marginTop + currentBitmap.height * .78;
					
			}
		}
		
		override protected function applyChanges():void {
			if(!settingsDirty){ return; }
			var data:BitmapData = sourceDataSmall.clone();
			
			applyBorder(data);
			setCurrentBitmapData(data);
			settingsDirty = false;
		}
		
		protected function applyBorder(data:BitmapData, source:Boolean = false):void {
			switch(filterType){
				
				case ImageBorders.THIN:
					ImageBorders.borderOverlay(data, slider.position, currentColor);
					break;
				
				case ImageBorders.THICK:
					ImageBorders.borderOverlay(data, slider.position, currentColor, .1);
					break;
				
				case ImageBorders.AURA:
					ImageBorders.borderOverlay(data, .5, currentColor, slider.position * .2, .1);
					break;
				
				case ImageBorders.FEATHERED:
					ImageBorders.borderOverlay(data, slider.position, currentColor, .065, 0.02);
					break;
				
				
				default:
					ImageBorders.apply(filterType, data, currentColor);
					break;
			}
			
		}
		
		override public function applyToSource():BitmapData {
			var data:BitmapData = sourceData.clone();
			applyBorder(data, true);
			
			switch(filterType){
				case ImageBorders.POLAROID_CLEAN:
				case ImageBorders.POLAROID_DIRTY:
					drawText(data);
					break;
				
			}
			return data;
		}
		
		private function drawText(sourceData:BitmapData):void {
			bottomText.bordersVisible = false;
			bottomText.cacheEnabled = false;
			
			var memeLayer:BitmapData = new BitmapData(sourceData.width, sourceData.height, true, 0x0);
			
			var scale:Number = sourceData.width / imageView.container.width;
			var m:Matrix = new Matrix();
			m.scale(scale, scale);
			m.translate((bottomText.x  - imageView.container.x) * scale, 
				((bottomText.y - editView.marginTop)  - imageView.container.y) * scale);
			
			if(RENDER::GPU) {
				memeLayer.drawWithQuality(bottomText, m, null, null, null, true, StageQuality.HIGH);
			} else {
				memeLayer.draw(bottomText, m, null, null, null, true);
			}
			sourceData.draw(memeLayer);
		}
		
		override public function transitionOut():void {
			super.transitionOut();
			if(bottomText && contains(bottomText)){
				removeChild(bottomText);
			}
		}
	}
}
package ca.esdot.picshop.editors
{
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.utils.getTimer;
	
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.image.ImageFilters;
	import ca.esdot.lib.image.TextureFilters;
	import ca.esdot.picshop.components.Slider;
	import ca.esdot.picshop.views.EditView;
	
	public class NoiseFilterEditor extends AbstractEditor
	{
		private var filterType:String;
		
		public var slider:Slider;
		public var strength:Number;
	
			
		public function NoiseFilterEditor(editView:EditView) {
			processInterval = 100;
			
			super(editView);
			
			processTimer.start();
		}
		
		override public function createChildren():void {
			
			slider = new Slider(.75, "Strength");
			slider.addEventListener(ChangeEvent.CHANGED, onSlider1Changed, false, 0, true);
			controlsLayer.addChild(slider);
			
			strength = slider.position;
		}
	
		
		override protected function updateControlsLayout():void {
			
			slider.x = padding;
			slider.width = viewWidth - padding * 2;
		}
		
		protected function onSlider1Changed(event:ChangeEvent):void {	
			strength = Number(event.newValue);
			settingsDirty = true;
		}
		
		override public function init():void {
			super.init();
			var data:BitmapData = sourceDataSmall.clone();
			applyTexture(data);
			setCurrentBitmapData(data);
			settingsDirty  = true;
		}
		
		override protected function applyChanges():void {
			if(!settingsDirty){ return; }
			var data:BitmapData = sourceDataSmall.clone();
			applyTexture(data);
			setCurrentBitmapData(data);
			settingsDirty = false;
		}
		
		override public function applyToSource():BitmapData {
			var data:BitmapData = sourceData.clone();
			var t:int = getTimer();
			applyTexture(data);
			
			return data;
		}
		
		
		public function applyTexture(data:BitmapData):void {
			TextureFilters.apply(ImageFilters.NOISE, data, strength, BlendMode.OVERLAY, false);
		}
	}
}
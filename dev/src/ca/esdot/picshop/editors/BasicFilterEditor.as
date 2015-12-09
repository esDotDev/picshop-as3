package ca.esdot.picshop.editors
{
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.image.ImageFilters;
	import ca.esdot.lib.image.TextureFilters;
	import ca.esdot.picshop.components.Slider;
	import ca.esdot.picshop.views.EditView;
	
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.utils.getTimer;
	
	public class BasicFilterEditor extends AbstractEditor
	{
		protected var filterType:String;
		
		public var slider:Slider;
		public var strength:Number;
		
		public function BasicFilterEditor(editView:EditView, filterType:String) {
			super(editView);
			this.filterType = filterType;
			processTimer.start();
			
			if(filterType == ImageFilters.EMBOSS || filterType == ImageFilters.INVERT){
				controlsLayer.visible = bg.visible = false;
			}
		}
		
		override public function createChildren():void {
			slider = new Slider(.5, "Amount");
			slider.addEventListener(ChangeEvent.CHANGED, onSlider1Changed, false, 0, true);
			controlsLayer.addChild(slider);
		}
		
		override protected function updateControlsLayout():void {
			if(filterType == ImageFilters.EMBOSS || filterType == ImageFilters.INVERT){
				return;
			}
			slider.x = viewWidth * .025;
			slider.width = viewWidth - slider.x * 2;
		}
		
		protected function onSlider1Changed(event:ChangeEvent):void {	
			strength = Number(event.newValue);
			settingsDirty = true;
		}
		
		override public function init():void {
			super.init();
			var data:BitmapData = sourceDataSmall.clone();
			applyFilter(data);
			setCurrentBitmapData(data);
		}
		
		override protected function applyChanges():void {
			if(!settingsDirty){ return; }
			var data:BitmapData = sourceDataSmall.clone();
			
			applyFilter(data);
			setCurrentBitmapData(data);
			settingsDirty = false;
		}
		
		protected function applyFilter(data:BitmapData):void {
			var source:BitmapData = data.clone();
			if(filterType == TextureFilters.VIGNETTE){
				TextureFilters.apply(filterType, data, slider.position, BlendMode.MULTIPLY);
			}
			else if (filterType == TextureFilters.SPY_CAM){
				filterType == TextureFilters.SPY_CAM;
				TextureFilters.apply(filterType, data, slider.position, BlendMode.OVERLAY);
			}
			else {
				ImageFilters.apply(filterType, data, source, slider.position);
			}
		}
		
		override public function applyToSource():BitmapData {
			var data:BitmapData = sourceData.clone();
			var t:int = getTimer();
			applyFilter(data);
			return data;
		}
	}
}
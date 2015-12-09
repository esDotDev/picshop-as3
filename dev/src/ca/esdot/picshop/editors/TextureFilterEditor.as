package ca.esdot.picshop.editors
{
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.image.TextureFilters;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.components.Slider;
	import ca.esdot.picshop.components.buttons.ComboBoxButton;
	import ca.esdot.picshop.dialogs.OptionsDialog;
	import ca.esdot.picshop.views.EditView;
	
	public class TextureFilterEditor extends AbstractEditor
	{
		private var filterType:String;
		
		public var slider:Slider;
		public var blendModeButton:ComboBoxButton;
		public var textureButton:ComboBoxButton;
		public var strength:Number;
		protected var _currentBlendMode:String;

		protected var currentTextureIndex:int = 0;
		
		protected var blendModes:Array = [
			BlendMode.MULTIPLY,
			BlendMode.OVERLAY,
			BlendMode.ADD,
			BlendMode.SUBTRACT,
			BlendMode.SCREEN
		]
			
		protected var filterList:Array = [
			TextureFilters.AGED_PAPER,
			TextureFilters.CREASED_PAPER,
			TextureFilters.COFFEE_STAIN,
			TextureFilters.INK_ROLLER,
			TextureFilters.DIRT,
			TextureFilters.SLUDGE,
			TextureFilters.PAINT
		];
		
		public function TextureFilterEditor(editView:EditView) {
			_currentBlendMode = BlendMode.MULTIPLY;
			processInterval = 100;
			
			super(editView);
			this.filterType = filterList[0];
			
			processTimer.start();
		}
		
		override public function createChildren():void {
			
			blendModeButton = new ComboBoxButton();
			blendModeButton.addEventListener(MouseEvent.CLICK, onBlendButtonClicked, false, 0, true);
			blendModeButton.fontSize = DeviceUtils.fontSize;
			blendModeButton.label = "Blending: " + currentBlendMode;
			blendModeButton.bg.visible = false;
			controlsLayer.addChild(blendModeButton);
			
			textureButton = new ComboBoxButton();
			textureButton.fontSize = DeviceUtils.fontSize;
			textureButton.addEventListener(MouseEvent.CLICK, onTextureButtonClicked, false, 0, true);
			textureButton.label = filterList[0];
			textureButton.bg.visible = false;
			controlsLayer.addChild(textureButton);
			
			slider = new Slider(.75, "Strength");
			slider.addEventListener(ChangeEvent.CHANGED, onSlider1Changed, false, 0, true);
			controlsLayer.addChild(slider);
		}
		
		protected function onTextureButtonClicked(event:MouseEvent):void {
			var dialog:OptionsDialog = new OptionsDialog(DeviceUtils.dialogWidth, Math.max(DeviceUtils.dialogHeight, viewHeight * .9), "Texture", filterList, currentTextureIndex);
			dialog.setButtons(["Cancel"]);
			dialog.addEventListener(ButtonEvent.CLICKED, onTextureDialogClicked, false, 0, true);
			
			DialogManager.addDialog(dialog);
		}
		
		protected function onTextureDialogClicked(event:ButtonEvent):void {
			DialogManager.removeDialogs();
			if(event.label == "Cancel"){ return; }
			
			currentTextureIndex = filterList.indexOf(event.label);
			filterType = event.label;
			textureButton.label = event.label;
			
			slider.position = .75;
			settingsDirty = true;
			
		}
		
		protected function onBlendButtonClicked(event:MouseEvent):void {
			var index:int = blendModes.indexOf(currentBlendMode);
			
			var dialog:OptionsDialog = new OptionsDialog(DeviceUtils.dialogWidth, Math.max(DeviceUtils.dialogHeight, viewHeight * .9), "Blend Modes", blendModes, index);
			dialog.setButtons(["Cancel"]);
			dialog.addEventListener(ButtonEvent.CLICKED, onBlendDialogClicked, false, 0, true);
			
			DialogManager.addDialog(dialog);
		}
		
		protected function onBlendDialogClicked(event:ButtonEvent):void {
			DialogManager.removeDialogs();
			if(event.label == "Cancel"){ return; }
			
			currentBlendMode = event.label;
			
		}
		
		public function get currentBlendMode():String { return _currentBlendMode; }
		public function set currentBlendMode(value:String):void {
			_currentBlendMode = value;
			settingsDirty = true;
			
			blendModeButton.label = "Blending: " + value;
		}
		
		override protected function updateControlsLayout():void {
			
			textureButton.setSize(viewWidth * .5, controlsLayer.height);
			blendModeButton.setSize(viewWidth * .5, controlsLayer.height);
			blendModeButton.x = viewWidth * .5;
			
			slider.y = textureButton.height;
			slider.x = 20;
			slider.width = viewWidth - 40;
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
			
			var maintainAspectRatio:Boolean = (filterType == TextureFilters.COFFEE_STAIN);
			
			TextureFilters.apply(filterType, data, slider.position, currentBlendMode, maintainAspectRatio);
		}
	}
}
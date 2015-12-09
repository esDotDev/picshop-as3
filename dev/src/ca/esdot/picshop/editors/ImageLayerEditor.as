package ca.esdot.picshop.editors
{
	import com.quasimondo.geom.ColorMatrix;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.components.SizableLayer;
	import ca.esdot.picshop.components.Slider;
	import ca.esdot.picshop.components.TransformBox;
	import ca.esdot.picshop.components.buttons.ComboBoxButton;
	import ca.esdot.picshop.dialogs.OptionsDialog;
	import ca.esdot.picshop.views.EditView;
	
	import qnx.fuse.ui.layouts.Align;
	import qnx.system.Device;
	
	public class ImageLayerEditor extends AbstractEditor
	{
		public static var CONTROLS_NONE:String = "controlsNone";
		public static var CONTROLS_HUE:String = "controlsHue";
		public static var CONTROLS_BLEND:String = "controlsBlend";
		
		public var layer:TransformBox;
		
		public var controlsType:String;
		
		protected var blendModes:Array = [
			BlendMode.NORMAL,
			BlendMode.MULTIPLY,
			BlendMode.OVERLAY,
			BlendMode.ADD,
			BlendMode.SUBTRACT,
			BlendMode.SCREEN
		]
			
		public var slider:Slider;
		public var slider2:Slider;
		public var slider3:Slider;
		
		public var saturation:Number;
		public var hue:Number;
		public var colorMatrix:ColorMatrix;
		
		protected var showColorControls:Boolean;
		protected var showBlendControls:Boolean;
		private var blendModeButton:ComboBoxButton;
		private var opacity:Number = 1;
		private var _currentBlendMode:String;
		
		public function ImageLayerEditor(editView:EditView, image:DisplayObject, controlsType:String = "controlsHue") {
			this.controlsType = controlsType;
			super(editView);
			
			if(image is Bitmap){
				(image as Bitmap).smoothing = true;
			}
			
			if(isPortrait){
				image.width = DeviceUtils.hitSize * 4;
				image.scaleY  = image.scaleX; 
			} else {
				image.height = DeviceUtils.hitSize * 4;
				image.scaleX  = image.scaleY; 
			}
			
			//
			if(image.width < DeviceUtils.hitSize){
				image.width = DeviceUtils.hitSize;
				image.scaleY = image.scaleX;
			}
			else if(image.height < DeviceUtils.hitSize){
				image.height = DeviceUtils.hitSize;
				image.scaleX = image.scaleY;
			}
			
			layer = new TransformBox(image, true);
			layer.setSize(image.width, image.height);
			editView.imageView.layerView.addBox(layer, -1, -1, DeviceUtils.hitSize, DeviceUtils.hitSize);
			
			colorMatrix = new ColorMatrix();
			processTimer.start();
			
			editView.imageView.isPanEnabled = false;
			
			//PicShop.highQuality = true;
			
		}
		
		//Don't need to do anything on init with this editor.
		override public function init():void {}
		
		override public function createChildren():void {
			if(controlsType == CONTROLS_HUE){
				slider = new Slider(.5, "Saturation");
				slider.addEventListener(ChangeEvent.CHANGED, onSlider1Changed, false, 0, true);
				controlsLayer.addChild(slider);
				
				slider2 = new Slider(.5, "Hue");
				slider2.addEventListener(ChangeEvent.CHANGED, onSlider2Changed, false, 0, true);
				controlsLayer.addChild(slider2);
				
				slider3 = new Slider(1, "Opacity");
				slider3.addEventListener(ChangeEvent.CHANGED, onSlider3Changed, false, 0, true);
				controlsLayer.addChild(slider3);
			}
			else if(controlsType == CONTROLS_BLEND){
				slider = new Slider(1, "Opacity");
				slider.addEventListener(ChangeEvent.CHANGED, onSlider1Changed, false, 0, true);
				controlsLayer.addChild(slider);
				
				blendModeButton = new ComboBoxButton();
				blendModeButton.addEventListener(MouseEvent.CLICK, onBlendButtonClicked, false, 0, true);
				blendModeButton.fontSize = DeviceUtils.fontSize;
				
				currentBlendMode = BlendMode.NORMAL;
				blendModeButton.label = "Blending: " + currentBlendMode;
				blendModeButton.bg.visible = false;
				controlsLayer.addChild(blendModeButton);
				
				
			}
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
		
		protected function onSlider1Changed(event:ChangeEvent):void {
			if(controlsType == CONTROLS_HUE){
				saturation = Number(event.newValue) * 2;
			} 
			else if(controlsType == CONTROLS_BLEND){
				opacity = Number(event.newValue);
				settingsDirty = true;
			}
			settingsDirty = true;
		}
		
		protected function onSlider2Changed(event:ChangeEvent):void {
			hue = 180 + Number(event.newValue) * 360;
			settingsDirty = true;
		}
		
		protected function onSlider3Changed(event:ChangeEvent):void {
			opacity = Number(event.newValue);
			settingsDirty = true;
		}
		
		override protected function updateControlsLayout():void {
			var padding:Number = viewWidth * .05;
			if(controlsType == CONTROLS_HUE){
				slider.x = padding;
				slider.width = (viewWidth - padding * 4) / 3;
				
				slider2.x = slider.x + slider.width + padding;
				slider2.width = slider.width;
				
				slider3.x = slider2.x + slider2.width + padding;
				slider3.width = slider.width;
				
			}
			else if(controlsType == CONTROLS_BLEND){
				blendModeButton.setSize(viewWidth * .5, controlsLayer.height);
				blendModeButton.x = viewWidth * .5;
				
				slider.x = 20;
				slider.width = viewWidth * .5 - 40;
			}
		}
		
		override public function discardEdits():void {
			editView.imageView.layerView.removeBox(layer);
			super.discardEdits();
		}
		
		public function set lockRatio(value:Boolean):void {
			layer.lockRatio = value;
		}
		
		override protected function applyChanges():void {
			if(!settingsDirty){ return; }
			
			if(controlsType == CONTROLS_HUE){
				colorMatrix.reset();
				if(!isNaN(saturation)){
					colorMatrix.adjustSaturation(saturation);
				}
				if(!isNaN(hue)){
					colorMatrix.adjustHue(hue);
				}
				layer.imageFilters = [colorMatrix.filter];
				
				layer.imageAlpha = opacity;
				
				//currentBitmapData.applyFilter(sourceDataSmall, currentBitmapData.rect, currentBitmapData.rect.topLeft, colorMatrix.filter);
				settingsDirty = false;
			} 
			else if(controlsType == CONTROLS_BLEND){
				
				layer.image.blendMode = currentBlendMode;
				layer.imageCache.blendMode = currentBlendMode;
				layer.imageAlpha = opacity;
				
				settingsDirty = false;
				
			}
			
		}
		
		override public function applyToSource():BitmapData {
			
			layer.uiContainer.visible = false;
			
			var newData:BitmapData = sourceData.clone();
			var scale:Number = sourceData.width / currentBitmap.width;
			
			//layer.showCache(false);
			
			layer.scaleX *= scale;
			layer.scaleY *= scale;
			layer.x *= scale;
			layer.y *= scale;
			
			var s:Sprite = new Sprite();
			s.addChild(layer);
			
			//var m:Matrix = new Matrix();
			//m.scale(scale, scale);
			//m.translate(layer.x * scale, layer.y * scale);

			newData.draw(s);//, m, null, null, null, true);

			editView.imageView.layerView.removeBox(layer);
			
			//PicShop.highQuality = false;
			return newData;
		}
		
		override protected function onRemovedFromStage(event:Event):void {
			super.onRemovedFromStage(event);
			editView.imageView.isPanEnabled = true;
		}
	}
}
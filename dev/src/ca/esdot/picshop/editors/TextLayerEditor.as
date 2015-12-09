package ca.esdot.picshop.editors
{
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.components.Slider;
	import ca.esdot.picshop.components.TileMenu;
	import ca.esdot.picshop.components.TransformTextBox;
	import ca.esdot.picshop.components.buttons.ColorButton;
	import ca.esdot.picshop.components.buttons.ComboBoxButton;
	import ca.esdot.picshop.dialogs.OptionsDialog;
	import ca.esdot.picshop.views.EditView;
	
	import flash.display.BitmapData;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	
	public class TextLayerEditor extends AbstractEditor
	{
		protected var fontButton:ComboBoxButton;
		protected var colorButton:ColorButton;
		protected var sizeSlider:Slider;
		protected var alphaSlider:Slider;
		
		//protected var alphaSlider:Slider;
		
		protected var currentColor:uint;
		protected var currentSize:int;
		protected var _currentFont:String;
		
		protected var fontList:Array = ["Regular", "Bold", "Cursive", "International", "Oriel", "Ballpark", "1942 Report", "College", "Love", "Hacker", "Scorched Earth", "Fancy", "Old London"]
		
		public var layer:TransformTextBox;
		protected var tileMenu:TileMenu;
		protected var minFont:Number = 14;
		protected var maxFont:Number = 80;
		
		public function TextLayerEditor(editView:EditView) {
			
			layer = new TransformTextBox();
			layer.addEventListener(ChangeEvent.CHANGED, onLayerChanged, false, 0, true);
			
			editView.imageView.isPanEnabled = false;
			editView.imageView.isZoomEnabled = false;
			
			super(editView);
			
			var width:int = DeviceUtils.fontSize * 20;
			var height:int = DeviceUtils.fontSize * 3;
			editView.imageView.layerView.addBox(layer, width, height, editView.viewWidth - width >> 1, editView.viewHeight * .2);
			layer.setSize(width, height);
		}
		
		public function get currentFont():String { return _currentFont; }
		public function set currentFont(value:String):void {
			_currentFont = value;
			settingsDirty = true;
			layer.fontFamily = value;
			fontButton.label = "Font: " + value;
		}
		
		protected function onLayerChanged(event:Event):void {
			
		}
		
		override public function createChildren():void {
			super.createChildren();
			
			_currentFont = fontList[1];
			fontButton = new ComboBoxButton("Font Type: " + _currentFont);
			fontButton.bg.visible = false;
			fontButton.addEventListener(MouseEvent.CLICK, onFontButtonClicked, false, 0, true);
			controlsLayer.addChild(fontButton);
			
			colorButton = new ColorButton();
			colorButton.bg.visible = false;
			colorButton.addEventListener(ChangeEvent.CHANGED, onColorChanged, false, 0, true);
			
			controlsLayer.addChild(colorButton);
			
			sizeSlider = new Slider(.5, "Font Size: ");
			sizeSlider.addEventListener(ChangeEvent.CHANGED, onSizeChanged, false, 0, true);
			controlsLayer.addChild(sizeSlider);
			
			alphaSlider = new Slider(.5, "Alpha: ");
			alphaSlider.addEventListener(ChangeEvent.CHANGED, onAlphaChanged, false, 0, true);
			controlsLayer.addChild(alphaSlider);
			
			currentSize = minFont + sizeSlider.position * (maxFont - minFont);
			layer.fontSize = currentSize;
		}
		
		override protected function updateControlsLayout():void {
			
			var buttonSize:int = (viewWidth - padding * 6) * .5;
			
			sizeSlider.x = padding;
			sizeSlider.width = buttonSize;
			
			alphaSlider.x = buttonSize + padding * 4;
			alphaSlider.width = buttonSize;
			
			fontButton.setSize(buttonSize, DeviceUtils.hitSize);
			fontButton.y = sizeSlider.height;
			
			colorButton.setSize(fontButton.width, DeviceUtils.hitSize);	
			colorButton.y = sizeSlider.height;
			colorButton.x = fontButton.x + fontButton.width + padding;
			
		}
		
		protected function onColorChanged(event:ChangeEvent):void {
			currentColor = event.newValue as Number;
			layer.fontColor = currentColor;
		}
		
		protected function onSizeChanged(event:ChangeEvent = null):void {
			currentSize = minFont + sizeSlider.position * (maxFont - minFont);
			layer.fontSize = currentSize;
		}
		
		protected function onAlphaChanged(event:ChangeEvent = null):void {
			layer.textAlpha = alphaSlider.position;
		}
		
		protected function onFontButtonClicked(event:MouseEvent):void {
			var width:int = Math.min(600, viewWidth * .85);
			var height:int = Math.min(750, viewHeight * .85);
			
			var index:int = fontList.indexOf(currentFont);
			
			var dialog:OptionsDialog = new OptionsDialog(width, height, "Font Type", fontList, index);
			dialog.setButtons(["Cancel"]);
			dialog.addEventListener(ButtonEvent.CLICKED, onFontDialogClicked, false, 0, true);
			
			DialogManager.addDialog(dialog);
		}
		
		protected function onFontDialogClicked(event:ButtonEvent):void {
			DialogManager.removeDialogs();
			if(event.label == "Cancel"){ return; }
			
			currentFont = event.label;
			
		}
		
		//Don't need to do anything on init with this editor.
		override public function init():void {
			//stage.focus = layer.textField;
		}
		
		override public function discardEdits():void {
			editView.imageView.layerView.removeBox(layer);
			super.discardEdits();
		}
		
		override public function applyToSource():BitmapData {
			layer.uiContainer.visible = false;
			layer.borderDown.visible = false;
			layer.textField.border = false;
			
			var newData:BitmapData = sourceData.clone();
			var scale:Number = sourceData.width / currentBitmap.width;
			
			var m:Matrix = new Matrix();
			m.scale(scale, scale);
			m.translate(layer.x * scale, layer.y * scale);
			var ct:ColorTransform = new ColorTransform(1, 1, 1, layer.textAlpha);
			
			if(RENDER::GPU) {
				newData.drawWithQuality(layer, m, ct, null, null, true, StageQuality.HIGH);
			} else {
				newData.draw(layer, m, ct, null, null, true);
			}
			editView.imageView.layerView.removeBox(layer);
			return newData;
		}
		
		override public function transitionOut():void {
			super.transitionOut();
			
			editView.imageView.isPanEnabled = true;
			editView.imageView.isZoomEnabled = true;
			
		}
	}
}
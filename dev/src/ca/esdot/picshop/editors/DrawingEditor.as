package ca.esdot.picshop.editors
{
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.display.MobileSprite;
	import ca.esdot.lib.drawing.Brushes;
	import ca.esdot.lib.drawing.SketchPad;
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.components.Slider;
	import ca.esdot.picshop.components.buttons.ColorButton;
	import ca.esdot.picshop.components.buttons.ComboBoxButton;
	import ca.esdot.picshop.components.buttons.LabelButton;
	import ca.esdot.picshop.dialogs.ColorDialog;
	import ca.esdot.picshop.dialogs.OptionsDialog;
	import ca.esdot.picshop.events.SketchEvent;
	import ca.esdot.picshop.views.EditView;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public class DrawingEditor extends AbstractEditor
	{
		protected var brushButton:ComboBoxButton;
		protected var colorButton:ColorButton;
		protected var sizeSlider:Slider;
		//protected var alphaSlider:Slider;
		
		protected var currentColor:int;
		protected var currentThickness:int;
		
		protected var sketchPad:SketchPad;
		
		protected var _currentBrush:String;
		protected var currentTextureIndex:int = 0;
		protected var brushes:Array = [
			Brushes.SIMPLE,
			Brushes.CHROME,
			Brushes.FAN,
			Brushes.FUR,
			Brushes.GRID,
			Brushes.LONG_FUR,
			Brushes.RIBBON,
			Brushes.SHADED,
			Brushes.SKETCHY,
			Brushes.SQUARES,
			Brushes.WEB
		]

		protected var colorDialog:ColorDialog;
		protected var currentAlpha:Number;
			
		public function DrawingEditor(editView:EditView) {
			super(editView);
		}
		
		override public function init():void {
			super.init();
			
			var pt:Point = currentBitmap.localToGlobal(new Point());
			pt = globalToLocal(pt);
			
			sketchPad = new SketchPad(stage);
			sketchPad.setSize(currentBitmap.width, currentBitmap.height);
			sketchPad.x = pt.x;
			sketchPad.y = pt.y;
			addChildAt(sketchPad, 0);
			
			onSizeChanged();
			sketchPad.thickness = currentThickness;
			sketchPad.color = currentColor;
			
			sketchPad.addEventListener(SketchEvent.STROKE_STARTED, onStrokeStarted, false, 0, true);
			sketchPad.addEventListener(SketchEvent.STROKE_COMPLETE, onStrokeComplete, false, 0, true);
		}
		
		protected function onStrokeStarted(event:Event):void {
			var g:Graphics = sketchPad.currentGraphics;
			historyStates.push(g);
			controlsLayer.visible = false;
			bg.visible = false;
			hideButton.visible = false;
		}
		
		protected function onStrokeComplete(event:Event):void {
			showUndo();
			controlsLayer.visible = true;
			bg.visible = true;
			hideButton.visible = true;
		}
		
		override protected function onUndoClicked(event:MouseEvent):void {
			if(undoIsDragging){ undoIsDragging = false; return; }
			if(!historyStates || historyStates.length == 0){ return; }
			sketchPad.currentGraphics = historyStates.pop();
			if(historyStates.length == 0){
				undoButton.hide();
			}
		}
		
		override public function createChildren():void {
			
			_currentBrush = brushes[0];
			brushButton = new ComboBoxButton("Brush: " + _currentBrush);
			brushButton.bg.visible = false;
			brushButton.addEventListener(MouseEvent.CLICK, onBrushButtonClicked, false, 0, true);
			controlsLayer.addChild(brushButton);
			
			colorButton = new ColorButton();
			colorButton.bg.visible = false;
			colorButton.addEventListener(ChangeEvent.CHANGED, onColorChanged, false, 0, true);
			
			controlsLayer.addChild(colorButton);
			
			sizeSlider = new Slider(.5, "Brush Size");
			sizeSlider.addEventListener(ChangeEvent.CHANGED, onSizeChanged, false, 0, true);
			controlsLayer.addChild(sizeSlider);
			
			//alphaSlider = new Slider(1, "Opacity");
			//alphaSlider.addEventListener(ChangeEvent.CHANGED, onAlphaChanged, false, 0, true);
			//childrenContainer.addChild(alphaSlider);
			
		}
		
		protected function onColorChanged(event:ChangeEvent):void {
			sketchPad.color = event.newValue as Number;
		}
		
		protected function onSizeChanged(event:ChangeEvent = null):void {
			currentThickness = 2 + sizeSlider.position * 8;
			sketchPad.thickness = currentThickness;
		}
		
		//protected function onAlphaChanged(event:ChangeEvent = null):void {
		//	currentAlpha = .25 + alphaSlider.position;
		//	sketchPad.opacity = currentAlpha;
		//}
		
		override protected function updateControlsLayout():void {
			
			
			
			//alphaSlider.x = viewWidth/2 + padding * 2;
			//alphaSlider.y = brushButton.height + padding;
			//alphaSlider.width = viewWidth/2 - padding * 4;
			
			brushButton.setSize(viewWidth/3 - padding, DeviceUtils.hitSize);
			
			colorButton.x = brushButton.x + brushButton.width + padding;
			colorButton.setSize(brushButton.width, DeviceUtils.hitSize);	
			
			sizeSlider.x = colorButton.x + colorButton.width + padding;
			sizeSlider.y = colorButton.height - sizeSlider.height >> 1;
			sizeSlider.width = viewWidth - sizeSlider.x - padding * 3;
		}
		
		public function get currentBrush():String { return _currentBrush; }
		public function set currentBrush(value:String):void {
			_currentBrush = value;
			settingsDirty = true;
			sketchPad.currenBrush = value;
			brushButton.label = "Brush: " + value;
		}
		
		override public function transitionOut():void {
			super.transitionOut();
			if(sketchPad){
				removeChild(sketchPad);
			}
		}
		
		protected function onBrushButtonClicked(event:MouseEvent):void {
			var width:int = Math.min(600, viewWidth * .9);
			var height:int = Math.min((brushes.length + 2)  * DeviceUtils.hitSize, viewHeight * .9);
			
			var index:int = brushes.indexOf(currentBrush);
			
			var dialog:OptionsDialog = new OptionsDialog(width, height, "Brush Type", brushes, index);
			dialog.setButtons(["Cancel"]);
			dialog.addEventListener(ButtonEvent.CLICKED, onBlendDialogClicked, false, 0, true);
			
			DialogManager.addDialog(dialog);
		}
		
		protected function onBlendDialogClicked(event:ButtonEvent):void {
			DialogManager.removeDialogs();
			if(event.label == "Cancel"){ return; }
			
			currentBrush = event.label;
			
		}
		
		override public function applyToSource():BitmapData {
			var data:BitmapData = sourceData.clone();
			var scale:Number = sourceData.width/currentBitmap.width;
			var m:Matrix = new Matrix();
			m.scale(scale,scale);
			//m.translate(0, -sketchPad.y);
			if(RENDER::GPU) {
				data.drawWithQuality(sketchPad.currentSprite, m, null, null, null, true, StageQuality.HIGH);
			} else {
				data.draw(sketchPad.currentSprite, m, null, null, null, true);
			}
			return data;
		}
	}
}
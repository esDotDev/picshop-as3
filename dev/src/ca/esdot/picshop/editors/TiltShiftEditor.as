package ca.esdot.picshop.editors
{
	import ca.esdot.lib.data.TweenConstants;
	import ca.esdot.lib.display.CachedSprite;
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.image.ImageProcessing;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.utils.SpriteUtils;
	import ca.esdot.picshop.components.Slider;
	import ca.esdot.picshop.components.buttons.CheckBoxButton;
	import ca.esdot.picshop.data.colors.AccentColors;
	import ca.esdot.picshop.views.EditView;
	import ca.esdot.picshop.views.TiltLinesView;
	
	import com.gskinner.motion.GTween;
	import com.quasimondo.geom.ColorMatrix;
	
	import de.popforge.imageprocessing.filters.render.Tile;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.ReturnKeyLabel;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import swc.LargeCircleMarker;
	
	public class TiltShiftEditor extends AbstractEditor
	{
		public var slider:Slider;
		public var slider2:Slider;
		
		protected var squareBlur:Sprite;
		protected var squareBlur2:Sprite;
		
		protected var blurData:BitmapData;
		protected var blurDataSmall:BitmapData;
		
		protected var blur:int = 10;
		protected var manualPosition:Boolean;
		
		protected var underlay:Sprite;
		
		protected var prevTime:int;
		private var hideOnApply:Boolean;
		private var isMouseDown:Boolean;

		private var circlePoint:Point;
		protected var linesView:TiltLinesView;
		
		protected var verticalButton:CheckBoxButton;
		protected var colorShift:Number;

		public function TiltShiftEditor(editView:EditView){
			squareBlur = new Sprite();
			super(editView);
		}
		
		override public function createChildren():void {
			slider = new Slider(.5, "Blur Strength");
			slider.addEventListener(ChangeEvent.CHANGED, onSlider1Changed, false, 0, true);
			controlsLayer.addChild(slider);
			slider.addEventListener(MouseEvent.MOUSE_UP, onSliderUp, false, 0, true);	
			
			slider2 = new Slider(.5, "Color Shift");
			slider2.addEventListener(ChangeEvent.CHANGED, onSlider2Changed, false, 0, true);
			controlsLayer.addChild(slider2);
			slider2.addEventListener(MouseEvent.MOUSE_UP, onSliderUp, false, 0, true);	
			
			verticalButton = new CheckBoxButton("Vertical");
			controlsLayer.addChild(verticalButton);
			verticalButton.addEventListener(MouseEvent.CLICK, onVerticalChanged, false, 0, true);
		}
		
		protected function onVerticalChanged(event:MouseEvent):void {
			 linesView.verticalMode = verticalButton.isSelected;
			 settingsDirty = true;
		}
		
		override protected function updateControlsLayout():void {
			//slider.y = padding;
			slider.x = viewWidth * .025;
			slider.width = (viewWidth * .3);
			
			slider2.x = (viewWidth * .375);
			slider2.width = (viewWidth * .3);
			
			verticalButton.setSize(viewWidth * .3, slider.height);
			verticalButton.x = slider2.width + slider2.x;
			
			if(linesView){
				linesView.setSize(currentBitmap.width, currentBitmap.height);
				positionLines();
			}
		}
		
		protected function positionLines():void {
			linesView.x = imageView.container.x + currentBitmap.x;
			linesView.y = imageView.container.y + currentBitmap.y + editView.marginTop;
		}
		
		protected function onSliderUp(event:MouseEvent):void {
			hideOnApply = true;
			settingsDirty = true;
		}
		
		override public function init():void {
			super.init();
			
			linesView = new TiltLinesView();
			linesView.setSize(currentBitmap.width, currentBitmap.height);
			positionLines();
			linesView.addEventListener(Event.CHANGE, onLinesChanged, false, 0, true);
			addChild(linesView);
			
			drawBlurBox();
			centerBlur();
			
			onSlider1Changed();
			centerBlur();
			
			underlay = SpriteUtils.getUnderlay(0xFF, 0, editView.viewWidth, controlsLayer.y - editView.marginTop);
			underlay.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			underlay.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			underlay.y = editView.marginTop;
			addChildAt(underlay, 0);
			
			prevTime = getTimer();
			processTimer.start();
		}
		
		public function drawBlurBox():void {
			var m:Matrix = new Matrix();
			var top:int = 255 * linesView.topRatio;
			var bottom:int = 255 * linesView.bottomRatio;
			
			var rotation:Number = 1.57;
			if(linesView.verticalMode){
				rotation = 0;
			}
			m.createGradientBox(currentBitmap.width, currentBitmap.height, rotation);
			squareBlur.graphics.clear();
			squareBlur.graphics.beginGradientFill(GradientType.LINEAR, 
				[0xFF0000, 0xFF0000, 0xFF0000, 0xFF0000, 0xFF0000, 0xFF0000],
				[1, .8, 0, 0, .8, 1], 
				[0, top - Math.min(top, 20), top, bottom, bottom + Math.min(255-bottom, 20), 255], 
				m);
			squareBlur.graphics.drawRect(0, 0, currentBitmap.width, currentBitmap.height);
		}
		
		protected function onLinesChanged(event:Event):void {
			drawBlurBox();
			settingsDirty = true;
			
		}
		
		protected function onMouseDown(event:MouseEvent):void {
			isMouseDown = true;
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
			onMouseMove();
		}
		
		protected function onMouseMove(event:MouseEvent = null):void {
			if(!isMouseDown){ return; }
			manualPosition = true;
			
			centerBlur();
			
			prevTime = getTimer();
		}
		
		protected function onMouseUp(event:MouseEvent):void {
			isMouseDown = false;
			settingsDirty = true;
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			hideOnApply = true;
		}
		
		protected function centerBlur():void {
			if(!manualPosition){ 
				squareBlur.x = currentBitmap.width/2 - squareBlur.width/2;
				squareBlur.y = currentBitmap.height/2 - squareBlur.height/2;
			}
		}
		
		
		protected function onSlider1Changed(event:ChangeEvent = null):void {
			blur = slider.position * 10 * DeviceUtils.screenScale;
			blurData  = sourceDataSmall.clone();
			blurData.applyFilter(sourceDataSmall, blurData.rect, new Point(), new BlurFilter(blur, blur, 3));
			settingsDirty = true;
		}
		
		protected function onSlider2Changed(event:ChangeEvent = null):void {
			colorShift = Number(event.newValue) - .5;
			settingsDirty = true;
		}
		
		override protected function applyChanges():void {
			if(!settingsDirty){ 
				return; 
			}
			
			prevTime = getTimer();
			var imageSource:BitmapData = sourceDataSmall.clone();
			
			drawBlur(imageSource);
			
			//imageSource.draw(alphaMask);
			setCurrentBitmapData(imageSource);
			
			if(hideOnApply){
				hideOnApply = false;
			}
			settingsDirty = false;
		}
		
		private function drawBlur(imageSource:BitmapData):void {
			
			//Create big square
			var scale:Number = squareBlur.width / imageSource.width;
			var alphaMask:BitmapData = new BitmapData(imageSource.width, imageSource.height, true, 0x0);
			
			var m:Matrix = new Matrix();
			m.scale(1/scale, 1/scale);
			m.scale(1.01, 1.01);
			if(RENDER::GPU) {
				alphaMask.drawWithQuality(squareBlur, m, null, null, null, false, StageQuality.HIGH);
			} else {
				alphaMask.draw(squareBlur, m, null, null, null, false);
			}
			var blur:BitmapData = blurData.clone();
			if(colorShift < -.1){
				ImageProcessing.lowSaturation(imageSource, imageSource.clone(), 1 - Math.abs(colorShift * 2));	
			} 
			else if(colorShift > .1){
				ImageProcessing.lowSaturation(blur, blurData, 1 - Math.abs(colorShift * 2));	
			}
			
			imageSource.copyPixels(blur, imageSource.rect, new Point(), alphaMask, new Point(), true); 
			
		}
		
		override public function applyToSource():BitmapData {
			var newSource:BitmapData = sourceData.clone();
			
			blurData  = sourceData.clone();
			var b:Number = blur/editingDownscale;
			b *= (1.05 * (sourceData.width/1000));
			blurData.applyFilter(blurData, blurData.rect, new Point(), new BlurFilter(b, b, 3));
			
			drawBlur(newSource);
			
			//newSource.applyFilter(sourceData, sourceData.rect, sourceData.rect.topLeft, colorMatrix.filter);
			return newSource;
		}
		
		override public function transitionOut():void { 
			super.transitionOut();
			removeChild(underlay);
			removeChild(linesView);
			
		}
	}
}
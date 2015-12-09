package ca.esdot.picshop.editors
{
	import ca.esdot.lib.data.TweenConstants;
	import ca.esdot.lib.display.CachedSprite;
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.image.ImageFilters;
	import ca.esdot.lib.image.ImageProcessing;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.utils.SpriteUtils;
	import ca.esdot.picshop.components.Slider;
	import ca.esdot.picshop.data.colors.AccentColors;
	import ca.esdot.picshop.views.EditView;
	
	import com.gskinner.motion.GTween;
	import com.quasimondo.geom.ColorMatrix;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.display.StageQuality;
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
	
	public class FocusEditor extends AbstractEditor
	{
		public var slider:Slider;
		public var slider2:Slider;
		public var slider3:Slider;
		
		protected var squareBlur:Sprite;
		protected var blurData:BitmapData;
		protected var blurDataSmall:BitmapData;
		protected var circleMarker:CachedSprite;
		
		protected var blur:int;
		protected var size:Number;
		protected var manualPosition:Boolean;
		protected var underlay:Sprite;
		protected var markerTween:GTween;
		protected var prevTime:int;
		private var hideOnApply:Boolean;
		private var isMouseDown:Boolean;

		private var circlePoint:Point;
		private var colorShift:Number;

		public function FocusEditor(editView:EditView){
			squareBlur = new Sprite();
			squareBlur.mouseEnabled = squareBlur.mouseChildren = false;
			//addChild(squareBlur);
			
			circleMarker = new CachedSprite(new swc.LargeCircleMarker(), 1);
			var ct:ColorTransform = circleMarker.transform.colorTransform;
			ct.color = AccentColors.currentColor;
			circleMarker.transform.colorTransform = ct;
			super(editView);
		}
		
		override public function createChildren():void {
			slider = new Slider(.5, "Focal Size");
			slider.addEventListener(ChangeEvent.CHANGED, onSlider1Changed, false, 0, true);
			controlsLayer.addChild(slider);
			slider.addEventListener(MouseEvent.MOUSE_UP, onSliderUp, false, 0, true);
			
			slider2 = new Slider(.5, "Blur Amount");
			slider2.addEventListener(ChangeEvent.CHANGED, onSlider2Changed, false, 0, true);
			controlsLayer.addChild(slider2);
			slider2.addEventListener(MouseEvent.MOUSE_UP, onSliderUp, false, 0, true);
			
			slider3 = new Slider(.5, "Color Shift");
			slider3.addEventListener(ChangeEvent.CHANGED, onSlider3Changed, false, 0, true);
			controlsLayer.addChild(slider3);
			slider3.addEventListener(MouseEvent.MOUSE_UP, onSliderUp, false, 0, true);
			
		}
		
		override protected function updateControlsLayout():void {
			//slider.y = padding;
			slider.x = viewWidth * .025;
			slider.width = viewWidth/3 - slider.x * 2;
			
			//slider2.y = padding;
			slider2.x = viewWidth * .33;
			slider2.width = slider2.x - viewWidth * .05;
			
			slider3.x = viewWidth * .65;
			slider3.width = viewWidth - slider3.x - viewWidth * .05;
		}
		
		protected function onSliderUp(event:MouseEvent):void {
			hideOnApply = true;
			settingsDirty = true;
		}
		
		override public function init():void {
			super.init();
			
			onSlider1Changed();
			centerBlur();
			
			underlay = SpriteUtils.getUnderlay(0xFF, 0, editView.viewWidth, controlsLayer.y - editView.marginTop);
			underlay.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			underlay.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			underlay.y = editView.marginTop;
			addChildAt(underlay, 0);
			
			addChildAt(circleMarker, 1);
			circleMarker.mouseEnabled = false;
			circleMarker.alpha = 0;
			markerTween  = new GTween(circleMarker, TweenConstants.NORMAL, {}, {ease: TweenConstants.EASE_OUT});
			
			onSlider2Changed();
			
			setInstructions("Tap on the image to position the focal point.");
			
			prevTime = getTimer();
			processTimer.start();
		}
		
		protected function onMouseDown(event:MouseEvent):void {
			isMouseDown = true;
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
			markerTween.paused = true;
			circleMarker.alpha = 1;
			
			onMouseMove();
		}
		
		protected function onMouseMove(event:MouseEvent = null):void {
			if(!isMouseDown){ return; }
			manualPosition = true;
			
			circlePoint = new Point(mouseX, mouseY);
			//circlePoint = imageView.globalToLocal(circlePoint);
			//circlePoint.x -= imageView.container.x;
			//circlePoint.y -= editView.marginTop;
			
			
			squareBlur.x = circlePoint.x - squareBlur.width/2;
			squareBlur.y = circlePoint.y - squareBlur.height/2;
			
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
				circlePoint = currentBitmap.localToGlobal(new Point(currentBitmap.width * .5, currentBitmap.height * .4));
				squareBlur.x = circlePoint.x - squareBlur.width/2;
				squareBlur.y = circlePoint.y - squareBlur.height/2;
			}
			
			circleMarker.width = circleMarker.height = squareBlur.width;
			circleMarker.x = squareBlur.x;
			circleMarker.y = squareBlur.y;
		}
		
		protected function onSlider1Changed(event:ChangeEvent = null):void {
			var delta:Number = size;
			size = (.25 + slider.position * 1.25) * Math.min(currentBitmap.width, currentBitmap.height);
			delta = isNaN(delta)? 0 : size - delta;
			
			squareBlur.x -= delta/2;
			squareBlur.y -= delta/2;
			
			var m:Matrix = new Matrix();
			squareBlur.graphics.clear();
			m.createGradientBox(size, size);
			squareBlur.graphics.beginGradientFill(GradientType.RADIAL, [0x0, 0x0],[0, 1], [150, 255], m);
			squareBlur.graphics.drawRect(0, 0, size, size);
			centerBlur();
			
			if(markerTween){
				markerTween.paused = true;
				circleMarker.alpha = 1;
			}	
			settingsDirty = true;
		}
		
		protected function onSlider2Changed(event:ChangeEvent = null):void {
			blur = slider2.position * 8 * DeviceUtils.screenScale;

			blurData  = sourceDataSmall.clone();
			blurData.applyFilter(sourceDataSmall, blurData.rect, new Point(), new BlurFilter(blur, blur, 3));
			
			settingsDirty = true;
		}
		
		protected function onSlider3Changed(event:ChangeEvent = null):void {
			colorShift = slider3.position - .5;
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
				markerTween.proxy.alpha = 0;
				hideOnApply = false;
			}
			settingsDirty = false;
		}
		
		private function drawBlur(imageSource:BitmapData, offset:int = 0):void {
			//Create big black square
			var scale:Number = (imageSource.width / currentBitmap.width);
			var size:int = (squareBlur.width * scale) | 0;
			
			var alphaMask:BitmapData = new BitmapData(imageSource.width, imageSource.height, true, 0xFF000000);
			
			var pt:Point = currentBitmap.globalToLocal(circleMarker.localToGlobal(new Point(0, offset)));
			
			//Chp out a section and make it transparent
			alphaMask.fillRect(new Rectangle(
				pt.x, 
				pt.y, size, size), 0x0);
			
			//Draw a faded circle into the empty box
			var m:Matrix = new Matrix();
			m.scale(scale + .01, scale + .01);
			m.translate(pt.x-1, pt.y-1);
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
			
			//Copy the blur on top of the source image
			imageSource.copyPixels(blur, imageSource.rect, new Point(), alphaMask, new Point(), true); 
			//imageSource.draw(alphaMask);
		}
		
		override public function applyToSource():BitmapData {
			var newSource:BitmapData = sourceData.clone();
			
			blurData  = sourceData.clone();
			var b:Number = blur/editingDownscale;
			b *= (1.05 * (sourceData.width/1000));
			blurData.applyFilter(blurData, blurData.rect, new Point(), new BlurFilter(b, b, 3));
			
			var prevWidth:int = currentBitmap.width;
			currentBitmap.bitmapData = sourceData;
			currentBitmap.width = prevWidth;
			currentBitmap.scaleY = currentBitmap.scaleX;
			
			squareBlur.x = circlePoint.x - squareBlur.width/2;
			squareBlur.y = circlePoint.y - squareBlur.height/2;
			centerBlur();
			
			drawBlur(newSource, -editView.marginTop);
			
			//newSource.applyFilter(sourceData, sourceData.rect, sourceData.rect.topLeft, colorMatrix.filter);
			return newSource;
		}
		
		override public function transitionOut():void { 
			super.transitionOut();
			removeChild(underlay);
			removeChild(circleMarker);
			
		}
	}
}
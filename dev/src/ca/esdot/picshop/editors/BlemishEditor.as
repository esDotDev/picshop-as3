package ca.esdot.picshop.editors
{
	import ca.esdot.lib.data.TweenConstants;
	import ca.esdot.lib.display.SpriteSheetClip;
	import ca.esdot.lib.image.ImageProcessing;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.utils.TextFields;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.components.ClickAnimation;
	import ca.esdot.picshop.components.Slider;
	import ca.esdot.picshop.components.buttons.UndoButton;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	import ca.esdot.picshop.views.EditView;
	
	import com.gskinner.filters.SharpenFilter;
	import com.gskinner.motion.GTween;
	import com.quasimondo.geom.ColorMatrix;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TransformGestureEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	
	public class BlemishEditor extends AbstractEditor
	{
		public var slider:Slider;
		public var slider2:Slider;
		
		public var colorMatrix:ColorMatrix;
		
		protected var markerSprite:Sprite;
		
		protected var previewSprite:Sprite;
		protected var previewMask:Sprite;
		protected var previewBitmap:Bitmap;

		private var previewStroke:Sprite;
		
		public function BlemishEditor(editView:EditView){
			super(editView);
			setInstructions("Touch a blemish to fix it. Use the sliders for fine tuning. Use 3 fingers to pan.");
			
			editingDownscale = 1;
			
			colorMatrix = new ColorMatrix()
			processTimer.start();
			
			historyStates = [];
			
			editView.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			editView.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			editView.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
			
			imageView.panGesture.minNumTouchesRequired = imageView.panGesture.maxNumTouchesRequired = 3;
			imageView.imagePanned.add(onZoomPan);
			imageView.imageZoomed.add(onZoomPan);
			
			markerSprite = new ClickAnimation(false);
			
			previewSprite = new Sprite();
			previewSprite.mouseEnabled = previewSprite.mouseChildren = false;
			
			previewBitmap = new Bitmap(new BitmapData(DeviceUtils.hitSize * 1.25, DeviceUtils.hitSize * 1.25, true, 0x0));
			previewSprite.addChild(previewBitmap);
			
			previewMask = new Sprite();
			previewMask.graphics.beginFill(0xFF0000, 1);
			previewMask.graphics.drawCircle(previewBitmap.width >> 1, previewBitmap.width >> 1, previewBitmap.width >> 1);
			previewMask.graphics.endFill();
			previewSprite.addChild(previewMask);
			
			var stroke:Sprite = new Sprite();
			stroke.graphics.lineStyle(4);
			stroke.graphics.lineBitmapStyle(SharedBitmaps.accentColor);
			stroke.graphics.drawCircle(previewBitmap.width >> 1, previewBitmap.width >> 1, previewBitmap.width >> 1);
			previewSprite.addChild(stroke);
			
			previewStroke = new Sprite();
			previewStroke.graphics.lineStyle(2);
			previewStroke.graphics.lineBitmapStyle(SharedBitmaps.accentColor);
			previewStroke.graphics.drawCircle(previewBitmap.width >> 1, previewBitmap.width >> 1, 20);
			previewSprite.addChild(previewStroke);
			
			previewBitmap.mask = previewMask;
		}
		
		override public function transitionIn():void {
			super.transitionIn();
		}
		
		
		override public function transitionOut():void {
			super.transitionOut();
			
			editView.imageView.resetPosition(.01);
			imageView.panGesture.minNumTouchesRequired = 1;
			imageView.panGesture.maxNumTouchesRequired = 1;
			imageView.imageZoomed.remove(onZoomPan);
			imageView.imagePanned.remove(onZoomPan);
			
			editView.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			editView.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			editView.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			undoButton.hide();
		}
		
		override public function createChildren():void {
			slider = new Slider(.25, "Size");
			controlsLayer.addChild(slider);
			
			slider2 = new Slider(.85, "Strength");
			controlsLayer.addChild(slider2);
		}
		
		override protected function updateControlsLayout():void {
			
			slider.x = viewWidth * .025;
			slider.width = viewWidth/2 - slider.x * 2;
			
			slider2.x = viewWidth/2 + viewWidth * .025;
			slider2.width = slider.width;
			
		}
		
		protected function onZoomPan():void {
			if(markerSprite && editView.contains(markerSprite)){
				editView.removeChild(markerSprite);
				editView.removeChild(previewSprite);
			}
		}
		
		protected function onMouseDown(event:MouseEvent):void {
			if(event.target.parent != editView.imageView.container){ return; }
			
			markerSprite.width = DeviceUtils.hitSize * .35 + DeviceUtils.hitSize * slider.position * .75;
			markerSprite.height = markerSprite.width;
			
			var strokeRadius:int = (markerSprite.width / imageView.container.scaleX)/2;
			previewStroke.graphics.clear();
			previewStroke.graphics.lineStyle(3);
			previewStroke.graphics.lineBitmapStyle(SharedBitmaps.accentColor);
			previewStroke.graphics.drawCircle(strokeRadius, strokeRadius, strokeRadius);
			previewStroke.x = previewStroke.y = previewBitmap.width - markerSprite.width >> 1;
			
			editView.addChildAt(markerSprite, editView.getChildIndex(editView.imageView) + 1);
			editView.addChildAt(previewSprite, editView.getChildIndex(editView.imageView) + 1);
			markerSprite.alpha = .5;
			positionMarker();
		}
		
		protected function onMouseMove(event:MouseEvent):void {
			positionMarker();
		}
		
		protected function positionMarker():void {
			markerSprite.x = editView.mouseX;
			markerSprite.y = editView.mouseY;
			
			previewSprite.x = markerSprite.x - previewSprite.width * 1.25;//(markerSprite.x - markerSprite.width / 2) + markerSprite.width * .75;
			previewSprite.y = markerSprite.y - previewSprite.height * 1.25;
			
			//Fix blemish
			
			//m.scale(currentBitmap.scaleX, currentBitmap.scaleX);
			var pt:Point = currentBitmap.globalToLocal(markerSprite.localToGlobal(new Point()));
			var m:Matrix = new Matrix();
			m.translate(-pt.x + markerSprite.width/2 - (markerSprite.width - previewBitmap.width >> 1), 
				-pt.y + markerSprite.width/2 - (markerSprite.width - previewBitmap.width >> 1));
			
			previewBitmap.bitmapData.fillRect(previewBitmap.bitmapData.rect, 0x0);
			previewBitmap.bitmapData.draw(currentBitmapData, m);
			
		}
		
		protected function onMouseUp(event:MouseEvent):void {
			if(!editView.contains(markerSprite)){ return; }
			
			var size:Number = (markerSprite.width / imageView.container.scaleX)/2;
			var pt:Point = currentBitmap.globalToLocal(markerSprite.localToGlobal(new Point()));
			pt.x -= size;
			pt.y -= size;
			
			editView.removeChild(markerSprite);
			editView.removeChild(previewSprite);
			
			//Out of bounds? We don't want to add to our history if are...
			if(pt.x < 0 || pt.y < 0 || pt.x > currentBitmapData.width || pt.y > currentBitmapData.height){
				return;
			}
			
			historyStates.push(currentBitmapData.clone());
			if(historyStates.length > 8){
				historyStates.shift();
			}
			
			ImageProcessing.fixBlemish(currentBitmapData, pt, size, slider2.position);
			
			//Show Undo Button
			showUndo();
			//Click animation...
			MainView.click();
			
		}
	
		override public function applyToSource():BitmapData {
			return currentBitmapData.clone();
		}
		
	}
}
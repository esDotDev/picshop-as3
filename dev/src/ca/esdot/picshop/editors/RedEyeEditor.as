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
	import ca.esdot.picshop.views.EditView;
	
	import com.gskinner.filters.SharpenFilter;
	import com.gskinner.motion.GTween;
	import com.quasimondo.geom.ColorMatrix;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.MouseEvent;
	import flash.events.TransformGestureEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	public class RedEyeEditor extends AbstractEditor
	{
		public var slider:Slider;
		public var slider2:Slider;
		
		public var colorMatrix:ColorMatrix;
		
		protected var markerSprite:Sprite;
		
		public function RedEyeEditor(editView:EditView){
			super(editView);
			setInstructions("Touch a problem area to remove the Red Eye. Increase sensitivity to get dark red areas.");
			
			editingDownscale = 1;
			
			colorMatrix = new ColorMatrix()
			processTimer.start();
			
			historyStates = [];
			
			editView.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			editView.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			editView.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
			editView.imageView.isPanEnabled = false;
			
			imageView.addEventListener(TransformGestureEvent.GESTURE_ZOOM, onZoomPan, false, 0, true);
			imageView.addEventListener(TransformGestureEvent.GESTURE_PAN, onZoomPan, false, 0, true);
			
			markerSprite = new ClickAnimation(false);
		}
		
		override public function createChildren():void {
			slider = new Slider(.5, "Size");
			controlsLayer.addChild(slider);
			
			slider2 = new Slider(.5, "Sensitivity");
			controlsLayer.addChild(slider2);
		}
		
		override public function transitionIn():void {
			super.transitionIn();
			
		}
		
		override public function transitionOut():void {
			super.transitionOut();
			
			editView.imageView.resetPosition(.01);
			editView.imageView.isPanEnabled = true;
			
			editView.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			editView.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			editView.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			undoButton.hide();
		}
		
		override protected function updateControlsLayout():void {
			
			slider.x = viewWidth * .025;
			slider.width = viewWidth/2 - slider.x * 2;
			
			slider2.x = viewWidth/2 + viewWidth * .025;
			slider2.width = slider.width;
			
		}
		
		protected function onZoomPan(event:TransformGestureEvent):void {
			if(markerSprite && editView.contains(markerSprite)){
				editView.removeChild(markerSprite);
			}
		}
		
		protected function onMouseDown(event:MouseEvent):void {
			if(event.target.parent != editView.imageView.container){ return; }
			
			markerSprite.width = DeviceUtils.hitSize/2 + DeviceUtils.hitSize * slider.position * .75;
			markerSprite.height = markerSprite.width;
			
			editView.addChildAt(markerSprite, editView.getChildIndex(editView.imageView) + 1);
			markerSprite.alpha = .5;
			positionMarker();
		}
		
		protected function onMouseMove(event:MouseEvent):void {
			positionMarker();
		}
		
		protected function positionMarker():void {
			markerSprite.x = editView.mouseX;
			markerSprite.y = editView.mouseY;
		}
		
		protected function onMouseUp(event:MouseEvent):void {
			if(!editView.contains(markerSprite)){ return; }
			
			var pt:Point = currentBitmap.globalToLocal(markerSprite.localToGlobal(new Point()));
			//pt.x -= markerSprite.width/2;
			//pt.y -= markerSprite.height/2;
			
			editView.removeChild(markerSprite);
			//Out of bounds? We don't want to add to our history if are...
			if(pt.x < 0 || pt.y < 0 || pt.x > currentBitmapData.width || pt.y > currentBitmapData.height){
				return;
			}
			
			historyStates.push(currentBitmapData.clone());
			if(historyStates.length > 8){
				historyStates.length = 8;
			}
			//Fix RedEye
			var scale:Number = 1/currentBitmap.scaleX/imageView.container.scaleX;
			
			var circleData:BitmapData = new BitmapData(currentBitmapData.width, currentBitmapData.height, true, 0x0);
			
			var matrix:Matrix = new Matrix();
			matrix.scale(markerSprite.scaleX * scale, markerSprite.scaleY * scale);
			matrix.translate(pt.x, pt.y);
			circleData.draw(markerSprite, matrix, null, null, null, true);
			
			//currentBitmapData.draw(circleData);
			//return;
			
			var size:int = markerSprite.width/imageView.container.scaleX;
			var strength:Number = 2.2 - slider2.position * .95;
			var pixel:uint;
			for(var i:int = pt.x - size, l:int = i + size * 2; i < l; i++){
				for(var j:int = pt.y - size, m:int = j + size * 2; j < m; j++){
					pixel = circleData.getPixel(i, j);
					//If alpha is 0, skip this pixel
					if(pixel == 0){ continue; }
					
					pixel = currentBitmapData.getPixel(i, j);
					var R:Number = pixel >> 16 & 0xFF;
					var G:Number = pixel >> 8  & 0xFF;
					var B:Number = pixel & 0xFF;
					
					var redIntensity:Number = R / ((G + B) / 2);
					if (redIntensity > strength)  // 1.5 because it gives the best results
					{
						R = G + B >> 1;
						pixel = (R << 16 | G << 8 | B);
						currentBitmapData.setPixel(i, j, pixel);
					}
					//currentBitmapData.setPixel(i, j, 0xFFFFFFFF);
				}
			}
			
			
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
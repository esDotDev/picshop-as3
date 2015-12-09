package ca.esdot.picshop.editors
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.image.ImageProcessing;
	import ca.esdot.lib.utils.ColorUtils;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.components.Slider;
	import ca.esdot.picshop.views.EditView;
	
	public class TeethWhiteningEditor extends AbstractEditor
	{
		public var slider:Slider;
		public var slider2:Slider;
		public var slider3:Slider;
		public var slider4:Slider;
		public var slider5:Slider;
		private var isMouseDown:Boolean;
		protected var scratchData:BitmapData;
		protected var scratchImage:Bitmap;
		private var scratchSprite:Sprite;
		private var slidersDirty:Boolean;
		

		public function TeethWhiteningEditor(editView:EditView){
			super(editView);
			setInstructions("Use your finger and draw over the area to be whitened. \nIf you're picking up skin tones, try reducing the 'sensitivity'.");
			
			editingDownscale = 1;
			
			processTimer.start();
			
			historyStates = [];
			
			editView.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			editView.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
			
			imageView.isPanEnabled = false;
			imageView.isZoomEnabled = false;
			
		}
		
		override public function transitionIn():void {
			super.transitionIn();
			addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
			
			//DEBUG: Apply filters on spaceBar
			PicShop.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		protected function onKeyDown(event:KeyboardEvent):void {
			if(event.keyCode == Keyboard.SPACE){
				var t:int = getTimer();
				
				currentBitmapData.draw(sourceData);
				currentBitmapData.lock();
				
				var color:uint, color2:uint;
				for(var x:int = 0, l:int = currentBitmapData.width; x < l; x++){
					for(var y:int = 0, l2:int = currentBitmapData.height; y < l2; y++){
						
						color = currentBitmapData.getPixel(x, y);
						color2 = ColorUtils.whitenIfYellow(color, slider.position);
						if(color2 != color){
							currentBitmapData.setPixel(x, y, color2);
						}
						
					}
				}
				currentBitmapData.unlock();
				
				slidersDirty = false;
			}
		}
		
		protected function onEnterFrame(event:Event):void {
			if(isMouseDown){
				var size:Number = (DeviceUtils.hitSize * .25);
				scratchSprite.graphics.beginFill(0xFF0000);
				scratchSprite.graphics.drawCircle(imageView.container.mouseX, imageView.container.mouseY, size);
				scratchSprite.graphics.endFill();
			}
		}		
		
		override public function transitionOut():void {
			super.transitionOut();
			
			imageView.isPanEnabled = true;
			imageView.isZoomEnabled = true;
			
			editView.imageView.resetPosition(.01);
			
			if(scratchImage.parent){
				scratchImage.parent.removeChild(scratchImage);
			}
			
			slider.removeEventListener(ChangeEvent.CHANGED, onSliderChanged);
			slider2.removeEventListener(ChangeEvent.CHANGED, onSliderChanged);
			slider3.removeEventListener(ChangeEvent.CHANGED, onSliderChanged);
			slider4.removeEventListener(ChangeEvent.CHANGED, onSliderChanged);
			slider5.removeEventListener(ChangeEvent.CHANGED, onSliderChanged);
			
			editView.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			editView.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			undoButton.hide();
			
			PicShop.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		override public function createChildren():void {
			slider = new Slider(.5, "Sensitivity");
			slider.addEventListener(ChangeEvent.CHANGED, onSliderChanged, false, 0, true);
			controlsLayer.addChild(slider);
			
			slider2 = new Slider(.5, "Whitening Strength");
			slider2.addEventListener(ChangeEvent.CHANGED, onSliderChanged, false, 0, true);
			controlsLayer.addChild(slider2);
			
			slider3 = new Slider(.25, "Soften Edges");
			slider3.addEventListener(ChangeEvent.CHANGED, onSliderChanged, false, 0, true);
			//childrenContainer.addChild(slider3);
			
			slider4 = new Slider(.5, "S-MAX");
			slider4.addEventListener(ChangeEvent.CHANGED, onSliderChanged, false, 0, true);
			//childrenContainer.addChild(slider4);
			
			slider5 = new Slider(.5, "V-MIN");
			slider5.addEventListener(ChangeEvent.CHANGED, onSliderChanged, false, 0, true);
			//childrenContainer.addChild(slider5);
			
			scratchData = new BitmapData(editView.imageView.container.width * .25, editView.imageView.container.height * .25, true, 0x0);
			scratchImage = new Bitmap(scratchData);
			scratchSprite = new Sprite();
			//scratchSprite.scaleX = scratchSprite.scaleY = 16;
			
			//scratchSprite.scaleX = scratchSprite.scaleY = 4;
			editView.imageView.container.addChild(scratchSprite);
		}

		protected function onSliderChanged(event:Event):void {
			slidersDirty = true;
		}
		
		override protected function updateControlsLayout():void {
			
			slider.x = viewWidth * .025;
			slider.width = (viewWidth - slider.x * 3) * .5;
			
			slider2.x = slider.x + slider.width + slider.x;
			slider2.width = slider.width;
			
			/*
			slider3.x = slider2.x + slider2.width + slider.x;
			slider3.width = slider.width;
			
			slider4.x = viewWidth/2 + viewWidth * .025;
			slider4.y = slider.y + slider.height;
			slider4.width = slider.width;
			
			slider5.x = viewWidth * .025;
			slider5.y = slider3.y + slider3.height;
			slider5.width = viewWidth/2 - slider.x * 2;
			
			*/
		}
		

		
		protected function onMouseDown(event:MouseEvent):void {
			if(event.target.parent != editView.imageView.container){ return; }
			
			isMouseDown = true;
			
		}
		
		
		
		protected function onMouseUp(event:MouseEvent):void {
			
			if(!isMouseDown){ 
				return; 
			}
			
			isMouseDown = false;
			
			var upscaleAmount:Number = 1/currentBitmap.scaleX;
			scratchData = new BitmapData(imageView.bitmap.bitmapData.width, imageView.bitmap.bitmapData.height, true, 0x0);
			var m:Matrix = new Matrix();
			m.scale(upscaleAmount, upscaleAmount);
			scratchData.draw(scratchSprite, m);
			
			trace("scratchData.width" + scratchData.width);
			trace("imageView.bitmap.bitmapData.width: " + imageView.bitmap.bitmapData.width);
			trace("sourceData.width: " + sourceData.width);
			
			var bounds:Rectangle = scratchSprite.getBounds(scratchSprite);
			bounds.x *= upscaleAmount;
			bounds.y *= upscaleAmount;
			bounds.width *= upscaleAmount;
			bounds.height *= upscaleAmount;
			trace("bounds: " + bounds);
			
			scratchImage.scaleX = scratchImage.scaleY = currentBitmap.scaleX;
			scratchImage.bitmapData = scratchData;
			//imageView.container.addChild(scratchImage);
			
			var maxX:int = bounds.x + bounds.width;
			var maxY:int = bounds.y + bounds.height;
			var color:uint, color2:uint, color32:uint;
			
			//Save history state
			historyStates.push(currentBitmapData.clone());
			if(historyStates.length > 4){
				historyStates.splice(1, 1);
			}
			
			//Show Undo Button
			showUndo();
			
			//Create a transparent bitmap to draw into, and stamp on top of original
			var blurPadding:int = Math.max(currentBitmapData.width, currentBitmapData.height) * .02;
			var buffer1:BitmapData = new BitmapData(bounds.width + blurPadding * 2, bounds.height + blurPadding * 2, true, 0x0);
			var buffer2:BitmapData = new BitmapData(bounds.width + blurPadding * 2, bounds.height + blurPadding * 2, true, 0x0);
			
			//Go through image, and draw each white pixel into the blurTarget
			//currentBitmapData.lock();
			var t:int = getTimer();
			for(var x:int = bounds.x; x < maxX; x++){
				
				for(var y:int = bounds.y; y < maxY; y++){
					
					if(scratchData.getPixel(x, y) != 0){
						color = currentBitmapData.getPixel(x, y);
						color2 = ColorUtils.whitenIfYellow(color, slider.position, slider2.position);
						if(color2 != color){
							currentBitmapData.setPixel(x, y, color2);
							/*
							color32 = 0;
							color32 += (0xFF << 24);
							color32 += color2;
							//Draw white pixels into buffer1
							buffer1.setPixel32(x - bounds.x + blurPadding, y - bounds.y + blurPadding, color32);
							*/
						}
					}
				}
			}
			trace("WHITEN COMPLETE: " + (getTimer() - t));
			//currentBitmapData.unlock();
			
			/*
			//Blur the blurTarget
			if(slider3.position > .05){
				
				//Check buffer1, and draw edge pixels to buffer2
				maxX = buffer1.width; 
				maxY = buffer1.height;
				for(x = 0; x < maxX; x++){
					for(y = 0; y < maxY; y++){
						color = buffer1.getPixel(x, y);
						
						//Check if this pixel is next to an edge
						if(color != 0){
							if(buffer1.getPixel(x-1, y) == 0 || buffer1.getPixel(x+1, y) == 0 || 
								buffer1.getPixel(x, y-1) == 0 || buffer1.getPixel(x, y + 1) == 0){
								//Remove from buffer 1
								buffer1.setPixel32(x, y, 0x01FFFFFF);
								
								//Draw Edge Pixel to buffer2
								color32 = 0;
								color32 += 0xFF << 24;
								color32 += color;
								buffer2.setPixel32(x, y, color32);
								
							}
						}
						
					}
				}
				
				var blurFilter:BlurFilter = new BlurFilter(slider3.position * 4, slider3.position * 4, 3);
				buffer2.applyFilter(buffer2, buffer2.rect, new Point(), blurFilter);
			}
			
			//Stamp buffer1 && buffer2 onto image
			m.identity();
			m.translate(bounds.x - blurPadding, bounds.y - blurPadding);
			currentBitmapData.draw(buffer1, m);
			currentBitmapData.draw(buffer2, m);
			*/
			
			scratchSprite.graphics.clear();
			
		}
	
		override public function applyToSource():BitmapData {
			return currentBitmapData.clone();
		}
		
	}
}
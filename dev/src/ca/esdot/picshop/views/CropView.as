package ca.esdot.picshop.views
{
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.utils.TextFields;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.data.CropModes;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.events.TransformGestureEvent;
	import flash.filesystem.File;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class CropView extends SizableView
	{
		/**
		 * Variables used for cropping.
		 */
		protected var cropContainer:Sprite;
		public var cropTL:Sprite;
		public var cropTR:Sprite;
		public var cropBL:Sprite;
		public var cropBR:Sprite;
		
		protected var topBorder:Bitmap = new Bitmap(SharedBitmaps.accentColor);
		protected var bottomBorder:Bitmap = new Bitmap(SharedBitmaps.accentColor);
		protected var leftBorder:Bitmap = new Bitmap(SharedBitmaps.accentColor);
		protected var rightBorder:Bitmap = new Bitmap(SharedBitmaps.accentColor);
		
		protected var leftLine:Bitmap = new Bitmap(SharedBitmaps.accentColor);
		protected var rightLine:Bitmap = new Bitmap(SharedBitmaps.accentColor);
		protected var topLine:Bitmap = new Bitmap(SharedBitmaps.accentColor);
		protected var bottomLine:Bitmap = new Bitmap(SharedBitmaps.accentColor);
		
		protected var leftHit:Sprite;
		protected var rightHit:Sprite;
		protected var topHit:Sprite;
		protected var bottomHit:Sprite;
		
		protected var centerSprite:Sprite;
		protected var dragTarget:Sprite;
		protected var cropPadding:int = 35;
		private var target:Bitmap;
		private var borderAlpha:Number = .35;

		protected var leftDiamond:Sprite;
		protected var rightDiamond:Sprite;
		protected var topDiamond:Sprite;
		protected var bottomDiamond:Sprite;
		private var _cropMode:String;
		private var sizeText:TextField;
		
		public var onChangeCallback:Function;
		
		public function CropView(target:Bitmap) {
			
			this.x = target.x;
			this.y = target.y;
			
			this.target = target;
			cropContainer = new Sprite();
			
			//Borders
			topBorder.alpha = borderAlpha;
			addChild(topBorder);
			
			bottomBorder.alpha = borderAlpha;
			addChild(bottomBorder);
			
			leftBorder.alpha = borderAlpha;
			addChild(leftBorder);
			
			rightBorder.alpha = borderAlpha;
			addChild(rightBorder);
			
			//Outlines
			addChild(leftLine);
			addChild(rightLine);
			addChild(topLine);
			addChild(bottomLine);
			
			//Middle
			centerSprite = new Sprite();
			centerSprite.addChild(new Bitmap(SharedBitmaps.clear));
			centerSprite.alpha = .5;
			centerSprite.addEventListener(MouseEvent.MOUSE_DOWN, onDragStarted, false, 0, true);
			cropContainer.addChild(centerSprite);
			
			//Side hit Areas
			leftHit = new Sprite();
			leftHit.addChild(new Bitmap(SharedBitmaps.clear));
			leftHit.addEventListener(MouseEvent.MOUSE_DOWN, onDragStarted, false, 0, true);
			cropContainer.addChild(leftHit);
			
			rightHit = new Sprite();
			rightHit.addChild(new Bitmap(SharedBitmaps.clear));
			rightHit.addEventListener(MouseEvent.MOUSE_DOWN, onDragStarted, false, 0, true);
			cropContainer.addChild(rightHit);
			
			topHit = new Sprite();
			topHit.addChild(new Bitmap(SharedBitmaps.clear));
			topHit.addEventListener(MouseEvent.MOUSE_DOWN, onDragStarted, false, 0, true);
			cropContainer.addChild(topHit);
			
			bottomHit = new Sprite();
			bottomHit.addChild(new Bitmap(SharedBitmaps.clear));
			bottomHit.addEventListener(MouseEvent.MOUSE_DOWN, onDragStarted, false, 0, true);
			cropContainer.addChild(bottomHit);
			
			//Circles
			cropTL = createCropCorner();
			cropContainer.addChild(cropTL);
			
			cropTR = createCropCorner();
			cropContainer.addChild(cropTR);
			
			cropBL = createCropCorner();
			cropContainer.addChild(cropBL);
			
			cropBR = createCropCorner();
			cropContainer.addChild(cropBR);
			
			//Diamonds
			leftDiamond = createDiamond();
			addChild(leftDiamond);
			
			rightDiamond = createDiamond();
			addChild(rightDiamond);
			
			topDiamond = createDiamond();
			addChild(topDiamond);
			
			bottomDiamond = createDiamond();
			addChild(bottomDiamond);
			
			addChild(cropContainer);
			initCrop();
			
			sizeText = TextFields.getBold(24, 0xFFFFFF, "center");
			sizeText.width = 200;
			sizeText.visible = false;
			addChild(sizeText);
			
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
		}
		
		protected function onMouseDown(event:MouseEvent):void {
			trace("Down");
		}
		
		public function set cropMode(value:String):void {
			if(_cropMode == value){ return; }
			
			_cropMode = value;
			if(_cropMode == CropModes.FREEFORM){ return; }
			
			var isLandscape:Boolean = target.width > target.height;
			centerSprite.x = target.width * .05;
			centerSprite.y = target.height * .05;
			centerSprite.width = target.width * .5;
			centerSprite.height = target.height * .5;
			
			enforceAspectRatio();
			positionCornersToCenter();
			positionBorders();
			positionHitAreas();
			
		}
		
		protected function createDiamond():Sprite {
			var sprite:Sprite = new Sprite();
			var bitmap:Bitmap = new Bitmap(SharedBitmaps.accentColor);
			bitmap.width = bitmap.height = 20;
			bitmap.rotation = 45;
			bitmap.x += bitmap.width/2;
			bitmap.y -= bitmap.height/2;
			sprite.addChild(bitmap);
			return sprite;
		}
		
		protected function createCropCorner():Sprite {
			var size:int = 32 * DeviceUtils.screenScale;
			var corner:Sprite = new Sprite();
			var bitmap:Bitmap = new Bitmap(SharedBitmaps.clear);
			bitmap.width = bitmap.height = size;
			bitmap.x = bitmap.y = -size/2;
			corner.addChild(bitmap);
			corner.mouseChildren = false;
			corner.addEventListener(MouseEvent.MOUSE_DOWN, onDragStarted, false, 0, true);
			return corner;
		}
		
		public function get cropBounds():Rectangle {
			var scale:Number = 1/target.scaleX;
			var bounds:Rectangle = new Rectangle(
				(cropTL.x - target.x) * scale|0, 
				(cropTL.y - target.y) * scale|0, 
				(cropTR.x - cropTL.x) * scale|0, 
				(cropBR.y - cropTR.y) * scale|0
			);
			return bounds; 
		}
		
		
		protected function onDragStarted(event:MouseEvent):void {
			dragTarget = event.target as Sprite;
			var bounds:Rectangle = new Rectangle();
			event.stopImmediatePropagation();
			
			sizeText.text = (centerSprite.width|0) + "w by " + (centerSprite.height|0) + "h";
			sizeText.y = 20;
			sizeText.x = target.x;
			sizeText.width = target.width;
			if(dragTarget != centerSprite){
				sizeText.visible = true;
			}
			switch(dragTarget){
				
				case topHit:
					bounds.x = cropTL.x + cropTL.width/2;
					bounds.y = target.y - topHit.height/2;
					bounds.height = cropBL.y - topHit.height;
					bounds.width = 0;
					showDiamond(topDiamond);
					break;
				
				case bottomHit:
					bounds.x = cropTL.x + cropTL.width/2;
					bounds.y = topHit.y + topHit.height;
					bounds.height = target.height - bounds.y - topHit.height/2;
					bounds.width = 0;
					showDiamond(bottomDiamond);
					break;
				
				case leftHit:
					bounds.x = -leftHit.width/2;
					bounds.y = cropTL.y + cropTL.height/2
					bounds.height = 0;
					bounds.width = cropTR.x - target.x - cropPadding;
					showDiamond(leftDiamond);
					break;
				
				case rightHit:
					bounds.x = leftHit.x + cropPadding/2;
					bounds.y = cropTL.y + cropTL.height/2;
					bounds.height = 0;
					bounds.width = target.width - (cropTL.x - target.x) - rightHit.width/2;
					showDiamond(rightDiamond);
					break;
				
				case centerSprite:
					bounds.x = 0;
					bounds.y = 0;
					bounds.width = target.width - centerSprite.width;
					bounds.height = target.height - centerSprite.height;
					break;
				
				case cropTL:
					bounds.x = target.x;
					bounds.width = cropTR.x - target.x - cropPadding;
					bounds.y = target.y;
					bounds.height = cropBL.y - target.y - cropPadding;
					break;
				
				case cropTR:
					bounds.x = cropTL.x + cropPadding;
					bounds.width = target.width - (cropTL.x - target.x) - cropPadding;
					bounds.y = target.y;
					bounds.height = cropBL.y - target.y - cropPadding;
					break;
				
				case cropBL:
					bounds.x = target.x;
					bounds.width = cropTR.x - target.x - cropPadding;
					bounds.y = cropTR.y + cropPadding;
					bounds.height = target.height - (bounds.y - target.y);
					break;
				
				case cropBR:
					bounds.x = cropTL.x + cropPadding;
					bounds.width = target.width - (cropTL.x - target.x) - cropPadding;
					bounds.y = cropTR.y + cropPadding;
					bounds.height = target.height - (bounds.y - target.y);
					break;
			}
			
			dragTarget.startDrag(false, bounds);
			stage.addEventListener(MouseEvent.MOUSE_UP, onCornerUp, false, 0, true);	
			stage.addEventListener(Event.ENTER_FRAME, updateCrop, false, 0, true);	
		}
		
		protected function onCornerUp(event:MouseEvent):void {
			dragTarget.stopDrag();
			//positionCenterToCorners();
			positionBorders();
			positionHitAreas();
			showDiamond();
			sizeText.visible = false;
			stage.removeEventListener(MouseEvent.MOUSE_UP, onCornerUp);	
			stage.removeEventListener(Event.ENTER_FRAME, updateCrop);	
		}
		
		protected function showDiamond(diamond:Sprite = null):void {
			var diamonds:Array = [leftDiamond, rightDiamond, topDiamond, bottomDiamond];
			for(var i:int = 0, l:int = diamonds.length; i < l; i++){
				if(!diamond || diamonds[i] == diamond){
					diamonds[i].visible = true;
				} else {
					diamonds[i].visible = false;
				}
			}
		}
		
		protected function updateCrop(event:Event):void {
			positionCorners();
			if(_cropMode != CropModes.FREEFORM){
				enforceAspectRatio();
			}
			positionBorders();
			positionHitAreas();
			sizeText.text = (centerSprite.width|0) + "px by " + (centerSprite.height|0) + "px";
			if(onChangeCallback){
				onChangeCallback();
			}
		}
		
		protected function enforceAspectRatio():void {
			var isLandscape:Boolean = target.width > target.height;
			if(_cropMode == CropModes.SQUARE){
				if(isLandscape && centerSprite.width != centerSprite.height){
					centerSprite.width = centerSprite.height;
				} 
				else if (!isLandscape && centerSprite.width != centerSprite.height) {
					centerSprite.height = centerSprite.width;
				}
			}
			else if(_cropMode == CropModes.GOLDEN){
				if(isLandscape && centerSprite.width != (centerSprite.height * 1.61|0)){
					centerSprite.width = centerSprite.height * 1.61|0;
				} else if(!isLandscape && centerSprite.height != (centerSprite.width * 1.61|0)){
					centerSprite.height = centerSprite.width * 1.61|0;
				}
			}
			else if(_cropMode == CropModes.FOUR_BY_THREE){
				if(isLandscape && centerSprite.width != (centerSprite.height * 1.33|0)){
					centerSprite.width = centerSprite.height * 1.33|0;
				} else if(!isLandscape && centerSprite.height != (centerSprite.width * 1.33|0)){
					centerSprite.height = centerSprite.width * 1.33|0;
				}
			}
			else if(_cropMode == CropModes.FOUR_BY_SIX){
				if(isLandscape && centerSprite.width != (centerSprite.height * 1.5|0)){
					centerSprite.width = centerSprite.height * 1.5|0; 
				} else if(!isLandscape && centerSprite.height != (centerSprite.width * 1.5|0)){
					centerSprite.height = centerSprite.width * 1.5|0;
				}
			}
			else if(_cropMode == CropModes.FIVE_BY_SEVEN){
				if(isLandscape && centerSprite.width != (centerSprite.height * 1.4|0)){
					centerSprite.width = centerSprite.height * 1.4|0; 
				} else if(!isLandscape && centerSprite.height != (centerSprite.width * 1.4|0)){
					centerSprite.height = centerSprite.width * 1.4|0;
				}
			}
			else if(_cropMode == CropModes.EIGHT_BY_TEN){
				if(isLandscape && centerSprite.width != (centerSprite.height * 1.25|0)){
					centerSprite.width = centerSprite.height * 1.25|0; 
				} else if(!isLandscape && centerSprite.height != (centerSprite.width * 1.25|0)){
					centerSprite.height = centerSprite.width * 1.25|0;
				}
			}
			
			var maxX:int = target.width - centerSprite.width;
			var maxY:int = target.height - centerSprite.height;
			
			if(centerSprite.x < 0){ centerSprite.x = 0; }
			if(centerSprite.y < 0){ centerSprite.y = 0; }
			if(centerSprite.x > maxX){ maxX; }
			if(centerSprite.y < maxY){ maxY; }
			if(centerSprite.x + centerSprite.width > target.x + target.width){
				centerSprite.x = target.x + target.width - centerSprite.width;
			}
			if(centerSprite.y + centerSprite.height > target.y + target.height){
				centerSprite.y = target.y + target.height - centerSprite.height;
			}
			if(centerSprite.width > target.width){
				centerSprite.width = target.width;
			}
			if(centerSprite.height > target.height){
				centerSprite.height = target.height;
			}
			
			positionCornersToCenter();
		}
		
		protected function initCrop():void {
			
			//Middle
			centerSprite.y = cropPadding;
			centerSprite.x = cropPadding;
			centerSprite.width = target.width - cropPadding * 2;
			centerSprite.height = target.height - cropPadding * 2;
			
			positionCornersToCenter();
			positionHitAreas();
			positionBorders();
		}
		
		protected function positionHitAreas():void {
			//Side Hit Areas
			if(dragTarget != leftHit){
				leftHit.y = centerSprite.y + cropTL.height/2;
				leftHit.x = centerSprite.x  - cropTR.width/2;
				leftHit.height = centerSprite.height - cropBL.height;
				leftHit.width = cropTL.width;
			}
			
			if(dragTarget != rightHit){
				rightHit.y = centerSprite.y + cropTL.height/2;
				rightHit.x = centerSprite.x  + centerSprite.width - cropTR.width/2;
				rightHit.height = centerSprite.height - cropBL.height;
				rightHit.width = cropTL.width;
			}
			
			if(dragTarget != topHit){
				topHit.y = centerSprite.y - cropTL.height/2;
				topHit.x = centerSprite.x + cropTL.width/2;
				topHit.height = cropTL.height;
				topHit.width = centerSprite.width - cropBL.width;
			}
			
			if(dragTarget != bottomHit){
				bottomHit.y = centerSprite.y + centerSprite.height - cropBL.height/2;
				bottomHit.x = centerSprite.x + cropTL.width/2;
				bottomHit.height = cropTL.height;
				bottomHit.width = centerSprite.width - cropBL.width;
			}
		}
		
		protected function positionBorders():void {
			//Borders
			topBorder.width = target.width + 1;
			topBorder.height = centerSprite.y;
			
			bottomBorder.y = centerSprite.y + centerSprite.height;
			bottomBorder.width = topBorder.width;
			bottomBorder.height = target.height - centerSprite.y - centerSprite.height;
			
			leftBorder.y = topBorder.height;
			leftBorder.height = cropBL.y - cropTL.y;
			leftBorder.width = cropBL.x;
			
			rightBorder.y = topBorder.height;
			rightBorder.x = cropBR.x;
			rightBorder.height = cropBL.y - cropTL.y;
			rightBorder.width = topBorder.width - cropBR.x;
			
			//Outlines
			topLine.x = leftBorder.width;
			topLine.y = topBorder.height;
			topLine.width = topBorder.width - leftBorder.width - rightBorder.width;
			
			bottomLine.x = leftBorder.width;
			bottomLine.y = target.height - bottomBorder.height;
			bottomLine.width = topBorder.width - leftBorder.width - rightBorder.width;
			
			leftLine.x = leftBorder.width;
			leftLine.y = topBorder.height;
			leftLine.height = target.height - topBorder.height - bottomBorder.height;
			
			rightLine.x = topBorder.width - rightBorder.width;
			rightLine.y = topBorder.height;
			rightLine.height = target.height - topBorder.height - bottomBorder.height;
			
			//Diamonds
			leftDiamond.x = leftLine.x - leftDiamond.width/2;
			leftDiamond.y = leftLine.y + leftLine.height/2;
			
			rightDiamond.x = rightLine.x - rightDiamond.width/2;
			rightDiamond.y = rightLine.y + rightLine.height/2;
			
			topDiamond.x = topLine.x + topLine.width/2 - topDiamond.width/2;
			topDiamond.y = topLine.y + topLine.height/2;
			
			bottomDiamond.x = bottomLine.x + bottomLine.width/2 - bottomDiamond.width/2;
			bottomDiamond.y = bottomLine.y + bottomLine.height/2;
		}
		
		protected function positionCorners():void {
			
			if(dragTarget == centerSprite){
				positionCornersToCenter();
			} 
			else if(dragTarget != centerSprite){
				if(dragTarget == leftHit){
					cropTL.x = leftHit.x + cropTL.height/2;
					cropBL.x = leftHit.x + cropTL.height/2;
				} 
				else if(dragTarget == rightHit){
					cropTR.x = rightHit.x + cropTL.height/2;
					cropBR.x = rightHit.x + cropTL.height/2;
				} 
				else if(dragTarget == topHit){
					cropTL.y = topHit.y + cropTL.height/2;
					cropTR.y = topHit.y + cropTL.height/2;
				} 
				else if(dragTarget == bottomHit){
					cropBL.y = bottomHit.y + cropTL.height/2;
					cropBR.y = bottomHit.y + cropTL.height/2;
				} 
				else if(dragTarget == cropTL){
					cropBL.x = cropTL.x;
					cropTR.y = cropTL.y;
				} 
				else if(dragTarget == cropTR){
					cropBR.x = cropTR.x;
					cropTL.y = cropTR.y;
				} 
				else if(dragTarget == cropBL){
					cropTL.x = cropBL.x;
					cropBR.y = cropBL.y;
				} 
				else if(dragTarget == cropBR){
					cropTR.x = cropBR.x;
					cropBL.y = cropBR.y;
				} 
				positionCenterToCorners();
			}
		}
		
		protected function positionCenterToCorners():void {	
			snapToPixel(cropTL);
			snapToPixel(cropTR);
			snapToPixel(cropBL);
			snapToPixel(cropBR);
			
			centerSprite.y = cropTL.y
			centerSprite.x = cropTL.x;
			centerSprite.width = cropTR.x - cropTL.x;
			centerSprite.height = cropBR.y - cropTR.y;
		}
		
		protected function positionCornersToCenter():void {
			snapToPixel(centerSprite);
			
			cropTL.x = centerSprite.x;
			cropTL.y = centerSprite.y;
			
			cropTR.x = centerSprite.x + centerSprite.width;
			cropTR.y = centerSprite.y;
			
			cropBL.x = centerSprite.x;
			cropBL.y = centerSprite.y + centerSprite.height;
			
			cropBR.x = centerSprite.x + centerSprite.width;
			cropBR.y = centerSprite.y + centerSprite.height;	
		}		
		
		protected function snapToPixel(target:Sprite):void {
			target.x = Math.round(target.x);
			target.y = Math.round(target.y);
			target.width = Math.round(target.width);
			target.height = Math.round(target.height);
		}
		
		override public function updateLayout():void {
			
			cropTL.scaleX = cropTL.scaleY = DeviceUtils.screenScale;
			cropBL.scaleX = cropBL.scaleY = DeviceUtils.screenScale;
			cropTR.scaleX = cropTR.scaleY = DeviceUtils.screenScale;
			cropBR.scaleX = cropBR.scaleY = DeviceUtils.screenScale;

		}
		
		public function get cropX():Number {
			return centerSprite.x / target.width;
		}
		
		public function get cropY():Number {
			return centerSprite.y / target.height;
		}
		
		public function get cropWidth():Number {
			return centerSprite.width / target.width;
		}
		
		public function get cropHeight():Number {
			return centerSprite.height / target.height;
		}
	}
}
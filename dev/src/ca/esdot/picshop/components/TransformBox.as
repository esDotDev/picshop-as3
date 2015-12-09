package ca.esdot.picshop.components
{
	import com.gskinner.motion.GTween;
	import com.gskinner.ui.touchscroller.TouchScrollEvent;
	import com.gskinner.ui.touchscroller.TouchScrollListener;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import assets.Bitmaps;
	
	import ca.esdot.lib.data.TweenConstants;
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.components.buttons.LabelButton;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	import swc.ButtonBarBg;
	import swc.FlipIconHz;

	public class TransformBox extends SizableView
	{
		protected const DELAY:Number = 3000;
		
		protected var _alwaysShowBorder:Boolean = false;
		
		protected var prevSize:Point;
		protected var scrollListener:TouchScrollListener;
		protected var imageContainer:Sprite;
		public var uiContainer:Sprite;
		protected var buttonSize:int;
		protected var alphaTween:GTween;
		
		protected var timer:Timer;
		
		protected var scaleStarted:Boolean;
		protected var hideOnUp:Boolean;
		protected var _deleteEnabled:Boolean;
		protected var _rotateEnabled:Boolean = true;
		
		protected var originalRatio:Number;
		
		public var image:DisplayObject;
		
		public var buttonsBgBottom:Sprite;
		public var buttonsBgTop:Sprite;
		
		public var bg:Bitmap;
		public var borderDown:BorderBox;
		public var resizeButton:LabelButton;
		public var rotateButton:LabelButton;
		public var deleteButton:LabelButton;
		public var alignTop:Boolean = false;
		
		public var flipButton:LabelButton;
		
		public var externalScale:Number = 1;
		public var lockRatio:Boolean;
		public var imageCache:Bitmap;
		protected var _imageFilters:Array;
		protected var cacheEnabled:Boolean;
		private var isFlipped:Boolean;
		protected var isMouseDown:Boolean;
		
		override public function set x(value:Number):void {
			super.x = value;
		}
		
		public function set imageAlpha(value:Number):void {
			if(image){
				image.alpha = value;
			}
			if(imageCache){
				imageCache.alpha = value;
			}
		}
		
		public function TransformBox(image:DisplayObject, cacheEnabled:Boolean = false):void {
			this.image = image;
			this.cacheEnabled = cacheEnabled;
			if(image is DisplayObjectContainer){
				(image as DisplayObjectContainer).mouseChildren = false;
			}
			image.width = DeviceUtils.hitSize * 4;
			image.scaleY = image.scaleX;
			image.visible = !cacheEnabled;
			originalRatio = image.height / image.width;
			
			createChildren();
			
			buttonSize = DeviceUtils.hitSize/2;
			
			scrollListener = new TouchScrollListener(this, true, true);
			scrollListener.scrollThreshold = 3;
			scrollListener.addEventListener(TouchScrollEvent.SCROLL, onScroll, false, 0, true);
			scrollListener.addEventListener(TouchScrollEvent.MOUSE_UP, onMouseUp, false, 0, true);
			scrollListener.addEventListener(TouchScrollEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			
			deleteButton.addEventListener(MouseEvent.CLICK, onDeleteClicked, false, 0, true);
			
			timer = new Timer(DELAY, 1);
			timer.addEventListener(TimerEvent.TIMER, onTimer, false, 0, true);
			timer.start();
			
			alphaTween = new GTween(uiContainer, .15, {}, {ease: TweenConstants.EASE_OUT});
		}
		
		public function showCache(value:Boolean):void {
			image.visible = !value;
			if(cacheEnabled){
				imageCache.visible = value;
			}
		}

		public function get imageFilters():Array { return _imageFilters; }
		public function set imageFilters(value:Array):void {
			_imageFilters = value;
			updateImageCache();
		}
		
		protected function onDeleteClicked(event:MouseEvent):void {
			dispatchEvent(new TransformBoxEvent(TransformBoxEvent.DELETE));
		}
		
		override public function destroy():void {
			scrollListener.removeEventListener(TouchScrollEvent.SCROLL, onScroll);
			scrollListener.removeEventListener(TouchScrollEvent.MOUSE_UP, onMouseUp);
			scrollListener.removeEventListener(TouchScrollEvent.MOUSE_DOWN, onMouseDown);
			scrollListener.destroy();
			
			try {
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				timer.stop();
			} catch(e:Error){}
			
			removeChildren();
		}
		
		public function get rotateEnabled():Boolean { return _rotateEnabled; 		}
		public function set rotateEnabled(value:Boolean):void {
			_rotateEnabled = value;
			rotateButton.visible = false;
			updateLayout();
		}
		
		public function get deleteEnabled():Boolean { return _deleteEnabled; 		}
		public function set deleteEnabled(value:Boolean):void {
			_deleteEnabled = value;
			updateLayout();
		}
		
		public function get alwaysShowBorder():Boolean { return _alwaysShowBorder; }
		public function set alwaysShowBorder(value:Boolean):void {
			_alwaysShowBorder = value;
			
			if(value){ borderDown.visible = value; }
		}

		public function get imageWidth():int {
			return image.width;
		}
		
		public function get imageHeight():int {
			return image.height;
		}
		
		protected function onTimer(event:TimerEvent):void{
			alphaTween.proxy.alpha = 0;
		}		
		
		protected function createChildren():void {
			bg = new Bitmap(SharedBitmaps.clear);
			addChild(bg);
			
			imageContainer = new Sprite();
			addChild(imageContainer);
			
			image.x = -image.width/2;
			image.y = -image.height/2;
			imageContainer.addChild(image);
			
			if(cacheEnabled){
				imageCache = new Bitmap();
				imageContainer.addChild(imageCache);
			}
			
			borderDown = new BorderBox(5);//6 * DeviceUtils.screenScale);
			borderDown.visible = alwaysShowBorder; 
			addChild(borderDown);
			
			uiContainer  = new Sprite();
			addChild(uiContainer);
			
			buttonsBgBottom = new swc.ButtonBarBg();
			uiContainer.addChild(buttonsBgBottom);
			
			buttonsBgTop = new swc.ButtonBarBg();
			uiContainer.addChild(buttonsBgTop);
			
			resizeButton = new LabelButton("", new Bitmaps.resizeCornerIcon());	
			uiContainer.addChild(resizeButton);
				
			rotateButton = new LabelButton("", new Bitmaps.rotateCornerIcon());	
			uiContainer.addChild(rotateButton);
			
			deleteButton = new LabelButton("", new Bitmaps.deleteCornerIcon());	
			uiContainer.addChild(deleteButton);
			
			flipButton = new LabelButton("", new swc.FlipIconHz());
			flipButton.addEventListener(MouseEvent.CLICK, onFlipClicked, false, 0, true);
			uiContainer.addChild(flipButton);
		}
		
		protected function onFlipClicked(event:MouseEvent):void {
			imageContainer.scaleX = -imageContainer.scaleX;
			isFlipped = imageContainer.scaleX < 0;
			//var r:int = imageContainer.rotation;
			//imageContainer.rotation = 0;
			//image.x = (image.scaleX > 0)? -image.width/2 : image.width/2;
			//imageContainer.rotation = r;
			
			//image.y = (image.scaleX < 1)? -image.height/2 : image.height/2;
		}
		
		override public function updateLayout():void {
			if(prevSize){
				//this.x -= (viewWidth - prevSize.x)/2;
				//this.y -= (viewHeight - prevSize.y)/2;
			}
			prevSize = new Point(viewWidth, viewHeight);
			
			bg.width = viewWidth;
			bg.height = viewHeight;
			
			var r:int = imageContainer.rotation;
			imageContainer.rotation = 0;
			
			imageContainer.height = viewHeight;
			if(scaleStarted){
				imageContainer.width = viewWidth;
			} else {
				imageContainer.scaleX = imageContainer.scaleY;	
			}
			if(isFlipped){ imageContainer.scaleX *= -1; }
			
			updateImageCache();
			
			imageContainer.x = imageContainer.width/2;
			imageContainer.y = imageContainer.height/2;

			borderDown.setSize(imageContainer.width, imageContainer.height);
			
			imageContainer.rotation = r;
			
			deleteButton.alpha = (deleteEnabled)? 1 : .25;
			deleteButton.bg.visible = false;
			deleteButton.mouseEnabled = deleteEnabled;
			deleteButton.setSize(buttonSize, buttonSize);
			deleteButton.y = viewHeight;
			
			rotateButton.setSize(buttonSize, buttonSize);
			rotateButton.bg.visible = false;
			rotateButton.x = imageContainer.width - rotateButton.width >> 1;
			rotateButton.y = viewHeight;
			
			//DISABLE DELETE BUTTON FOR NOW
			rotateButton.x = deleteButton.x;
			deleteButton.visible = false;
			
			resizeButton.setSize(buttonSize, buttonSize);
			resizeButton.bg.visible = false;
			resizeButton.y = viewHeight;
			resizeButton.x = imageContainer.width - buttonSize;
			
			var bgPadding:int = 4;
			
			buttonsBgBottom.x = -bgPadding;
			buttonsBgBottom.y = viewHeight - bgPadding - 1;
			buttonsBgBottom.height = buttonSize + bgPadding * 2;
			buttonsBgBottom.width = imageContainer.width + bgPadding * 2;
			
			if(!rotateEnabled){
				buttonsBgBottom.width = buttonSize * 2;
				buttonsBgBottom.x = resizeButton.x + buttonSize/2 - buttonsBgBottom.width/2;
			}
			
			flipButton.setSize(buttonSize * 2, buttonSize);
			flipButton.bg.visible = false;
			flipButton.y = -buttonSize/2 - 1;
			flipButton.x = imageContainer.width - flipButton.width >> 1;
			
			buttonsBgTop.x = flipButton.x-bgPadding;
			buttonsBgTop.y = flipButton.y - bgPadding;
			buttonsBgTop.width = flipButton.width + bgPadding * 2;
			buttonsBgTop.height = buttonSize + bgPadding * 2;
			
			
		}
		
		protected function updateImageCache():void {
			if(!cacheEnabled){ return; }
			var r:int = imageContainer.rotation;
			imageCache.bitmapData = null;
			
			var data:BitmapData = new BitmapData(viewWidth, viewHeight, true, 0x0);
			
			var m:Matrix = new Matrix();
			m.scale(imageContainer.scaleX * image.scaleX, imageContainer.scaleY * image.scaleY);
			data.draw(image, m, null, null, null, true);
			
			imageCache.x = image.x;
			imageCache.y = image.y;
			imageCache.scaleX = 1/imageContainer.scaleX;
			imageCache.scaleY = 1/imageContainer.scaleY;
			imageCache.bitmapData = data;
			
			if(imageFilters){
				for(var i:int = 0; i < imageFilters.length; i++){
					data.applyFilter(imageCache.bitmapData, data.rect, new Point(), imageFilters[i]);
				}
			}
		}
		
		protected function onMouseDown(event:TouchScrollEvent):void {
			timer.delay = DELAY;
			alphaTween.proxy.alpha = 1;
			borderDown.visible = true;
			isMouseDown = true;
			if(uiContainer.alpha == 1){
				hideOnUp = true;
			}
		}
		
		protected function onScroll(event:TouchScrollEvent):void {
			timer.delay = DELAY;
			hideOnUp = false;
			uiContainer.visible = false;
			//event.mouseDeltaX = event.mouseDeltaX * externalScale;
			//event.mouseDeltaY = event.mouseDeltaY * externalScale;
			var delta:int = event.mouseDeltaX + event.mouseDeltaY;
			var newWidth:Number, newHeight:Number;
			if(event.clickTarget == resizeButton){
				scaleStarted = true;
				
				if(lockRatio){
					var d:Number = (event.mouseDeltaX + event.mouseDeltaY)/2;
					var scale:Number  = 1 - d/200;
					trace(scale);
					newWidth = viewWidth * scale;
					newHeight = newWidth * originalRatio;
					if(newWidth < buttonSize * 2 || newHeight < buttonSize){ 
						return; 
					}
				} else {
					newWidth = viewWidth - event.mouseDeltaX;
					if(newWidth < buttonSize * 2){
						newWidth = buttonSize * 2;
					}
					newHeight = viewHeight - event.mouseDeltaY;
					if(newHeight < buttonSize){
						newHeight = buttonSize;
					}
				}
				setSize(newWidth, newHeight);
				dispatchEvent(new ChangeEvent(ChangeEvent.CHANGED));
			}
			else if(event.clickTarget == rotateButton){
				if(mouseY > imageContainer.y){
					event.mouseDeltaX = -1 * event.mouseDeltaX;
				}
				if(mouseX < imageContainer.x){
					event.mouseDeltaY = -1 * event.mouseDeltaY;
				}
				delta = event.mouseDeltaX + event.mouseDeltaY;
				
				imageContainer.rotation -= delta/4;
				dispatchEvent(new ChangeEvent(ChangeEvent.CHANGED));
				
			} else {
				this.x -= event.mouseDeltaX;
				this.y -= event.mouseDeltaY;
				dispatchEvent(new ChangeEvent(ChangeEvent.CHANGED));
			}
		}
		
		protected function onMouseUp(event:TouchScrollEvent):void {
			if(hideOnUp && event.clickTarget != flipButton){
				timer.delay = 1;
				hideOnUp = false;
			}
			uiContainer.visible = true;
			borderDown.visible = alwaysShowBorder;
			isMouseDown = false;
			if(event.clickTarget == resizeButton){
				updateLayout();
			}
			timer.start();
		}
	}
}


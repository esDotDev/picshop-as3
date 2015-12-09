package ca.esdot.picshop.views
{
	import com.gskinner.motion.GTween;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	
	import ca.esdot.lib.data.TweenConstants;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.events.ImageViewEvent;
	
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.PanGesture;
	import org.gestouch.gestures.TapGesture;
	import org.gestouch.gestures.ZoomGesture;
	import org.osflash.signals.Signal;
	import org.osmf.utils.OSMFStrings;
	
	public class ImageView extends SizableView
	{
		protected var _isZoomEnabled:Boolean = true;
		protected var _isPanEnabled:Boolean = true;
		
		protected var scaleTween:GTween;
		protected var _currentBitmap:BitmapData;
		
		public var container:Sprite;
		protected var canvas:Sprite;
		
		public var bitmap:Bitmap;
		
		public var layerView:LayerView;
		
		protected var tween:GTween;
		protected var bitmapSprite:Sprite;
		
		public var zoomGesture:ZoomGesture;
		public var tapGesture:TapGesture;
		public var panGesture:PanGesture;
		
		protected var previousScale:Number;
		protected var previousWidth:Number;
		
		public var imageZoomed:Signal;
		public var imagePanned:Signal;
		
		public function ImageView() {
			super();
			container = new Sprite();
			addChild(container);
			
			imageZoomed = new Signal();
			imagePanned = new Signal();
			
			zoomGesture = new ZoomGesture(container);
			zoomGesture.addEventListener(GestureEvent.GESTURE_BEGAN, onZoom);
			zoomGesture.addEventListener(GestureEvent.GESTURE_CHANGED, onZoom);
			
			tapGesture = new TapGesture(container);
			tapGesture.addEventListener(GestureEvent.GESTURE_RECOGNIZED, onImageTap);
			
			panGesture = new PanGesture(container);
			panGesture.canBePreventedByGesture(zoomGesture);
			panGesture.minNumTouchesRequired = 1;
			panGesture.maxNumTouchesRequired = 1;
			panGesture.addEventListener(GestureEvent.GESTURE_BEGAN, onPan);
			panGesture.addEventListener(GestureEvent.GESTURE_CHANGED, onPan);
			
			//Main Bitmap
			bitmap = new Bitmap();
			bitmapSprite = new Sprite();
			bitmapSprite.addChild(bitmap);
			container.addChild(bitmapSprite);
			
			
			//Stickers and other BitmapLayers
			layerView = new LayerView();
			container.addChild(layerView);
			
			isZoomEnabled = true;
			isPanEnabled = true;
			tween = new GTween(bitmap, TweenConstants.NORMAL, {}, {onChange: onChange});
		}
		
		public function set isFullScreenEnabled(value:Boolean):void {
			setTimeout(function(){
				tapGesture.enabled = value;
			}, 1000);
		}
		
		protected function onImageTap(event:GestureEvent):void {
			dispatchEvent(new ImageViewEvent(ImageViewEvent.IMAGE_CLICKED, true));
		}
		
		protected function onPan(event:GestureEvent):void {
			if(!isPanEnabled){ return; }
			container.x += panGesture.offsetX;
			container.y += panGesture.offsetY;	
			imagePanned.dispatch();
		}
		
		protected function onZoom(event:GestureEvent):void {
			if(!isZoomEnabled){ return; }
			var matrix:Matrix = container.transform.matrix;
			var transformPoint:Point = matrix.transformPoint(container.globalToLocal(zoomGesture.location));
			matrix.translate(-transformPoint.x, -transformPoint.y);
			matrix.scale(zoomGesture.scaleX, zoomGesture.scaleY);
			matrix.translate(transformPoint.x, transformPoint.y);
			container.transform.matrix = matrix;
			imageZoomed.dispatch();
		}
		
		public function get isZoomEnabled():Boolean { return _isZoomEnabled; }
		public function set isZoomEnabled(value:Boolean):void {
			_isZoomEnabled = value;
		}
		
		public function get isPanEnabled():Boolean { return _isPanEnabled; }
		public function set isPanEnabled(value:Boolean):void {
			_isPanEnabled = value;
		}
	
		public function resetPosition(duration:Number = 1):void {
			var x:int = viewWidth - (container.width / container.scaleX) >> 1;
			var y:int = viewHeight - (container.height / container.scaleY) >> 1;
			new GTween(container, duration, {scaleX: 1, scaleY: 1, x: x, y: y}); 
		}
		
		public function get currentBitmap():BitmapData { return _currentBitmap; }
		public function setCurrentBitmap(value:BitmapData, size:Boolean = true):void {
			_currentBitmap = value;
			bitmap.bitmapData = value;
			bitmap.smoothing = true;
			if(size && value){
				sizeBitmap();
			}
		}
		
		public function scaleView(width:int, height:int, skipTween:Boolean = false):void {
			if(width <= 0 || height <= 0){ return; }
			_viewWidth = width;
			_viewHeight = height;
			
			var scale:Number = Math.min(width/bitmap.width, height / bitmap.height);
			
			var x:int = viewWidth - (bitmap.width * scale) >> 1;
			var y:int = viewHeight - (bitmap.height * scale) >> 1;
			if(!skipTween){
				scaleTween = new GTween(container, TweenConstants.SHORT, {scaleX: scale, scaleY: scale, x: x, y: y}, {ease: TweenConstants.EASE_OUT}); 
			} else {
				container.scaleX = container.scaleY = scale;
				container.x = x;
				container.y = y;
			}
			
			layerView.layerScale = scale;
		}
		
		public function resetZoom():void {
			container.scaleX = container.scaleY = 1;
			container.x = viewWidth - container.width >> 1;
			container.y = viewHeight - container.height >> 1;
		}
		
		override public function updateLayout():void {
			if(!_currentBitmap){ return; }
			
			if(scaleTween){ scaleTween.paused = true; }
			
			var oldWidth:int = bitmap.width;
			sizeBitmap();
			var scaleNew:Number = bitmap.width / oldWidth;
			layerView.scaleLayers(previousScale);
			
			//container.scaleX = container.scaleY = 1;
			container.x = viewWidth - container.width >> 1;
			container.y = viewHeight - container.height >> 1;

		}
		
		public function sizeBitmap():void {
			if(!_currentBitmap){ return; }
			
			var scale:Number = Math.min(viewWidth/_currentBitmap.width, viewHeight/_currentBitmap.height);
			if(bitmap.width == viewWidth * scale){ return; }
			previousScale = container.scaleX;
			previousWidth = bitmap.width;
			
			container.scaleX = container.scaleY = 1;
			bitmap.width = _currentBitmap.width * scale;
			bitmap.height = _currentBitmap.height * scale;
			trace("[Size bitmap] bitmap:", bitmap.width, bitmap.height, "container:", container.width, container.height, container.scaleX);
		}
		
		protected function onChange(tween:GTween):void {
			//bitmap.x = viewWidth/2 - bitmap.width / 2;
		}
		
		
		protected function checkBounds():void {
			if(container.y > 0 && container.height < viewHeight){ 
				container.y = 0;
			} else if(container.x < 0 && container.width < viewWidth){
				container.x = 0;
			}
			
		}	
	
	}
}
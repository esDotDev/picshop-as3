package ca.esdot.lib.components
{
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.AsyncErrorEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	public class Image extends Sprite {
		
		private static var IDS:uint = 0;
		public var id:uint = IDS++;
		
		// Static
		protected static const DEFAULT_LOAD_DELAY_DURATION:int = 500;
		
		//Protected
		protected var imgLoader:Loader;
		protected var timeoutTimer:Timer;
		protected var distractor:Sprite;
		protected var cachedBitmapData:BitmapData;
		protected var loadTimer:Timer;
		protected var _sourceData:BitmapData;
		protected var sizeInvalid:Boolean = false;
		
		protected var _centerImage:Boolean = true;
		protected var _clipEdges:Boolean = true;
		protected var _autoSize:Boolean = false;
		protected var _width:Number = -1;
		protected var _height:Number = -1;
		protected var _snapToPixel:Boolean = false;
		protected var _source:String;
		//protected var displayMask:Shape;
		
		private var _forceCacheAsBitmapFalse:Boolean;
		
		//Public 
		public var smoothing:Boolean = true;
		public var timeoutDuration:int = 20000;
		public var loadDelayDuration:int = DEFAULT_LOAD_DELAY_DURATION;
		public var _bitmap:Bitmap;
		public var loading:Boolean;
		public var useScrollRect:Boolean = true;
		
		public function Image(source:String = null){
			timeoutTimer = new Timer(timeoutDuration, 1);
			timeoutTimer.addEventListener(TimerEvent.TIMER, onTimeoutTimer, false, 0, true);
			
			loadTimer = new Timer(loadDelayDuration, 1);
			loadTimer.addEventListener(TimerEvent.TIMER, onLoadTimer, false, 0, true);
			
			//displayMask = new Shape();
			if(source){
				this.source = source;
			}
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		public function get sourceWidth():int { return _sourceData? _sourceData.width : 0; }
		public function get sourceHeight():int { return _sourceData? _sourceData.height : 0; }
		
		/*
		//DEBUG USE
		public function get _width():Number {
			return __width;
		}
		public function set _width(value:Number):void {			trace("_width: ", value);
			__width = value;
		}
		*/
	/***************************************
	 * ACCESSORS
	 ***************************************/
		
		public function set forceCacheAsBitmapFalse(value:Boolean):void {
			_forceCacheAsBitmapFalse = value;
			if (value) super.cacheAsBitmap = false;
		}
		
		override public function set cacheAsBitmap(value:Boolean):void {
			if (_forceCacheAsBitmapFalse) { return; }
			super.cacheAsBitmap = cacheAsBitmap;
		}
		
		public function get bitmapWidth():Number { return _bitmap.width; }
		public function get bitmapHeight():Number { return _bitmap.height; }
		
		public function get centerImage():Boolean { return _centerImage; }
		public function set centerImage(value:Boolean):void {
			_centerImage = value;
			sizeImage();
		}
		
		public function get clipEdges():Boolean { return _clipEdges; }
		public function set clipEdges(value:Boolean):void {
			_clipEdges = value;
			sizeImage();
		}
		
		public function get bitmap():Bitmap {
			return _bitmap;
		}
		
		public function get autoSize():Boolean { return _autoSize; }
		public function set autoSize(value:Boolean):void {
			_autoSize = value;
			if (value && _bitmap) {
				_width = _bitmap.width;
				_height = _bitmap.height;
			}
			sizeImage();
		}
		
		public function get displayWidth():Number { return super.width; }
		public function get displayHeight():Number { return super.height; }
		
		override public function get width():Number { return (sizeInvalid)? _width : super.width; }
		override public function set width(value:Number):void { 
			_width = value; 
			sizeImage()
		}
		
		override public function get height():Number { return (sizeInvalid)? _height : super.height; }
		override public function set height(value:Number):void { 
			_height = value; 
			sizeImage();
		}
		
		public function get snapToPixel():Boolean { return _snapToPixel; }
		public function set snapToPixel(value:Boolean):void {
			_snapToPixel = value;
			move(x, y);
		}
		
		public function setSize(width:Number, height:Number):void {
			_width = width;
			_height = height;
			sizeImage();
		}
		
		override public function set x(value:Number):void {
			if (_snapToPixel) {
				super.x = value+.5|0;
			} else {
				super.x = value;
			}
		}
		
		override public function set y(value:Number):void {
			if (_snapToPixel) {
				super.y = value+.5|0;
			} else {
				super.y = value;
			}
		}
		
		public function get source():String { return _source; }
		public function set source(value:String):void {
			
			loadTimer.stop();
			
			if (imgLoader && _source != value) {
				try {
					imgLoader.close();
				} catch (e:*) { }
				
				timeoutTimer.stop();
			} else if (_source == value) {
				return;
			}
			
			_source = value;
			loading = false;
			if(!value || value == ""){
				return; 
			}
			
			loadTimer.delay = loadDelayDuration;
			loadTimer.reset();
			loadTimer.start();
			
			if(_bitmap && contains(_bitmap)){
				removeChild(_bitmap);
			}
			_bitmap = null;
		}
		
	/************************************************
	 * PUBLIC
	 ************************************************/
		
		public function load():void {
			loading = true;
			if (imgLoader) { 
				imgLoader.load(new URLRequest(_source));
			}
		}
		
		
		
		public function move(x:Number, y:Number):void {
			this.x = x;
			this.y = y;
		}
		
		public function match(img:Sprite):void {
			this.move(img.x, img.y);
			this.setSize(img.width, img.height);
		}
		
		override public function set visible(value:Boolean):void {
			super.visible = value;
		}
		
		public function get bitmapData():BitmapData { return (_bitmap)? _bitmap.bitmapData : null; }
		public function set bitmapData(value:BitmapData):void {
			if(!_bitmap){
				_bitmap = new Bitmap();
			}
			if(value == null){ 
				_bitmap = null;
				return;
			}
			//_bitmap.mask = displayMask;
			_sourceData = value;
			_bitmap.bitmapData = value;
			_bitmap.smoothing = smoothing;
			//addChild(displayMask);
			addChild(_bitmap);
			
			if (_width <= 0) { _width = _bitmap.width; }
			if (_height <= 0) { _height = _bitmap.height; }
			
			if (_autoSize) {
				autoSize = true; // For recycling purposes, only set if _autoSize is true.
			} else {
				sizeImage();
			}
			
			//Remove placeholder rect
			removeShim();
		}

	/*************************************
	 * PROTECTED
	 **************************************/
	
		protected function createLoader():void {
			if (imgLoader) { return; }
			
			imgLoader = new Loader();
			
			// Add complete listener.
			imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete, false, 0, true);
			//Progress
			imgLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, this.dispatchEvent, false, 0, true);
			
			// Add Error Handlers:
			imgLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError, false, 0, true);
			imgLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
			imgLoader.contentLoaderInfo.addEventListener(ErrorEvent.ERROR, onError, false, 0, true);
			imgLoader.contentLoaderInfo.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError, false, 0, true);
		}
		
		protected function onLoadTimer(event:Event):void {
			
			timeoutTimer.delay = timeoutDuration;
			timeoutTimer.reset();
			timeoutTimer.start();
			
			createLoader();
			load();
			
		}
		
		private function onRemovedFromStage(event:Event):void {
			if (loadTimer.running) {
				source = null;
			}
			loadTimer.stop();
			timeoutTimer.stop();
		}
		
		protected function onLoadComplete(event:Event):void {
			loading = false;
			
			if(imgLoader == null){ return; }
			
			try {
				bitmapData = (event.target.content as Bitmap).bitmapData;
			} catch (error:Error) {
				loadFailed();
				return;
			}
			cacheAsBitmap = true;
			
			//Clear image loader
			imgLoader.unload();
			imgLoader = null;
			
			//Notify listeners that load has completed
			timeoutTimer.stop();
			loadTimer.stop();
			dispatchEvent(new Event(Event.COMPLETE));
			
		}
		
		/*
		protected function drawMask():void {
			if(_width == displayMask.width && _height == displayMask.height){ return; }
			if(_width > 0 && _height > 0){
				displayMask.graphics.clear();
				displayMask.graphics.beginFill(0x0);
				displayMask.graphics.drawRect(0, 0, _width, _height);
				displayMask.graphics.endFill();
			}
		}
		*/
		
		protected function sizeImage():void {
			if(clipEdges){
				//Add placeholder rect
				addShim();
			}
			
			if(!_bitmap){ 
				return; 
			}
			
			if(_width == -1){ _width = _bitmap.bitmapData.width; }
			if(_height == -1){ _height = _bitmap.bitmapData.height; }
			
			
			//Scale / Crop
			var widthRatio:Number = _width / _bitmap.bitmapData.width;
			var heightRatio:Number = _height / _bitmap.bitmapData.height;
			var scale:Number = (clipEdges)? Math.max(widthRatio, heightRatio) : Math.min(widthRatio, heightRatio);
			
			//[SB] Using two method here, as OS 1.7 can lock up when we resize too many bitmap's. 
			//For Grid Lists, with many images we have to use scrollRect. For other lists, we should resize the bitmapData
			//as there's resize issues relating to using scrollRect (takes a frame to report the correct height)
			if(useScrollRect){
				_bitmap.bitmapData = _sourceData;
				_bitmap.scaleX = _bitmap.scaleY = scale;
				_bitmap.x = (centerImage)? _width/2 - _bitmap.width/2 : 0;
				_bitmap.y = (centerImage)? _height/2 - _bitmap.height/2 : 0;
				_bitmap.smoothing = true;
				if(clipEdges){
					scrollRect = new Rectangle(0, 0, _width, _height);
					sizeInvalid = true;
					//It takes one frame for scrollRect to take affect, during that time the displayListSize is invalid
					setTimeout(sizeValidated, 1);
				} 
			} else {
				var m:Matrix = new Matrix();
				m.scale(scale, scale);
				//trace("scale: ", scale);
				
				var bmpData:BitmapData;
				
				//[SB] BitmapData can never be less than 1px or the earth will end....
				var newWidth:int = Math.max(_sourceData.width * scale, 10);
				var newHeight:int = Math.max(_sourceData.height * scale, 10);
				if(!clipEdges){
					bmpData = new BitmapData(newWidth, newHeight, true, 0x0);
				} else {
					if(centerImage){
						m.translate(_width/2 - newWidth/2, _height/2 - newHeight/2);
						//trace("translate:", _width/2 - (_sourceData.width * scale)/2, _height/2 - (_sourceData.height * scale)/2);
					}
					bmpData = new BitmapData(_width, _height, true, 0x0);
				}
				
				bmpData.draw(_sourceData, m, null, null, null, true);
				_bitmap.bitmapData = bmpData;
			}
		
		}
		
		protected function sizeValidated():void {
			sizeInvalid = false;
		}
		
		protected function onProgress(event:ProgressEvent):void {
			timeoutTimer.stop();
			dispatchEvent(event);
		}
		
		protected function onError(event:ErrorEvent):void {
			trace("[ImageLoader] onError: " + event.type);
			loadFailed();
		}
		
		protected function onAsyncError(event:AsyncErrorEvent):void {
			trace("[ImageLoader] onAsyncError: " + event);
			loadFailed();
		}
		
		protected function onSecurityError(event:SecurityErrorEvent):void {
			trace("[ImageLoader] securityErrorHandler: " + event);
			loadFailed();
		}
		
		protected function onIOError(event:IOErrorEvent):void {
			trace("[ImageLoader] ioErrorHandler: " + event);
			loadFailed();
		}
		
		protected function onTimeoutTimer(event:TimerEvent):void {
			trace("[ImageLoader] Image Load Timed Out (" + _source + ")");
			loadFailed();
		}
		
		protected function loadFailed():void {
			loading = false;
			
			timeoutTimer.stop();
			
			if(hasEventListener(IOErrorEvent.IO_ERROR)){
				dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
			}
		}
		

		protected function addShim():void {
			if(isNaN(_width) || isNaN(_height)){ return; }
			graphics.clear();
			graphics.beginFill(0x0, 0);
			graphics.drawRect(0, 0, _width, _height);
		}
		
		protected function removeShim():void {
			graphics.clear();
		}
		
		public function destroy():void {
			if(_bitmap != null && _bitmap.bitmapData) { _bitmap.bitmapData.dispose(); }
			_bitmap = null;
			
			if(imgLoader != null){
				try{ 
					imgLoader.unload();
				} catch(error:Event){ }
			}
		}
	}
	
}
package ca.esdot.lib.display
{
	import avmplus.getQualifiedClassName;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	public class SpriteSheetClip extends Bitmap
	{
		public static var drawScale:Number = 1;
		public static var frameCacheByAsset:Object = {};
		
		protected var _currentStartFrame:int = 1;
		protected var _currentEndFrame:int = 20;
		protected var _currentFrame:int = 1;
		protected var _currentLabel:String;
		
		protected var frameCache:Object;
		protected var frameLabels:Object;
		protected var _isPlaying:Boolean;
		protected var _frameWidth:int;
		protected var _frameHeight:int;
		protected var isLooping:Boolean;
		protected var numFrames:int;
		
		public var velX:Number;
		public var velY:Number;
		
		public function SpriteSheetClip(bitmapAsset:Class, jsonAsset:Class){
			
			_currentStartFrame = 1;
			var assetName:String = getQualifiedClassName(bitmapAsset);
			//Check cache, if cached, do nothing
			if(frameCacheByAsset[assetName]){
				frameCache = frameCacheByAsset[assetName].frames;
				frameLabels = frameCacheByAsset[assetName].labels;
				
				_frameWidth = frameCache[0].width;
				_frameHeight = frameCache[0].height;
			} 
			//If not cached, rip frames from bitmapData and grab json
			else {
				//rip clip!
				var data:Object = JSON.parse(new jsonAsset().toString());
				var bitmap:Bitmap = new bitmapAsset();
				var spriteSheet:BitmapData = bitmap.bitmapData;
				
				_frameWidth = data.frames.width;
				_frameHeight = data.frames.height;
				
				frameLabels = data.animations;
				
				var cols:int = spriteSheet.width/_frameWidth|0;
				var rows:int = spriteSheet.height/_frameHeight|0;
				var p:Point = new Point();
				
				var l:int = cols * rows;
				frameCache = [];
				
				_currentStartFrame = 1;
				
				var scale:Number = drawScale;
				var m:Matrix = new Matrix();
				
				//Loop through all frames...
				for(var i:int = 0; i < l; i++){
					var col:int = i%cols;
					var row:int = i/cols|0;
					
					m.identity(); //Reset matrix
					m.tx = -_frameWidth * col;
					m.ty = -_frameHeight * row;
					m.scale(scale, scale);
					//Draw one frame and cache it
					var bmpData:BitmapData = new BitmapData(_frameWidth * scale, _frameHeight * scale, true, 0x0);
					if(RENDER::GPU) {
						bmpData.drawWithQuality(spriteSheet, m, null, null, null, true, StageQuality.HIGH);
					} else {
						bmpData.draw(spriteSheet, m, null, null, null, true);
					}
					frameCache[i] = bmpData;
				}
				
				_currentEndFrame = i;
				numFrames = _currentEndFrame;
				
				_frameWidth *= scale;
				_frameHeight *= scale;
				
				//Cache frameData
				frameCacheByAsset[assetName] = {
					frames: frameCache, //Cache bitmapData's
					labels: frameLabels //Cache frameLabels
				};
			}
			//Show frame 1
			this.bitmapData = frameCache[_currentStartFrame-1];
			
		}
		
		public function get currentFrameData():BitmapData {
			return frameCache[_currentFrame-1];
		}
		
		public function get currentLabel():String {
			return _currentLabel;
		}

		public function set currentLabel(value:String):void {
			_currentLabel = value;
		}

		public function get currentEndFrame():int{
			return _currentEndFrame;
		}

		public function set currentEndFrame(value:int):void{
			_currentEndFrame = value;
		}

		public function get frameHeight():int
		{
			return _frameHeight / drawScale;
		}

		public function get frameWidth():int
		{
			return _frameWidth / drawScale;
		}

		public function get isPlaying():Boolean
		{
			return _isPlaying;
		}

		override public function set bitmapData(value:BitmapData):void {
			super.bitmapData = value;
			smoothing = true;
		}
		
		public function play():void {
			_isPlaying = true;
			_currentEndFrame = numFrames;
		}
		
		public function stop():void {
			_isPlaying= false;
		}
		
		public function gotoAndPlay(frame:Object, loop:Boolean = false):void {
			
			isLooping = loop;
			if(frame is String && frameLabels && frameLabels[frame]){
				_currentLabel = frame as String;
				_currentStartFrame = _currentFrame = frameLabels[frame][0] + 1;
				_currentEndFrame = frameLabels[frame][1] + 1;
				//trace("Playing: ", frame, _currentStartFrame, _currentEndFrame);
				currentFrame = _currentStartFrame;
				_isPlaying = true;
				
			} else if(int(frame) > 0){
				currentFrame = int(frame);
				_isPlaying = true;
			} 
		}
		
		public function gotoAndStop(frame:Object):void {
			gotoAndPlay(frame);
			_isPlaying = false;
		}
		
		public function step():void {
			if(!_isPlaying){
				return;
			}
			if(_currentFrame >= _currentEndFrame){
				_currentFrame = _currentStartFrame;
				if(!isLooping){
					_currentFrame = 1;
					_isPlaying = false;
					dispatchEvent(new Event(Event.COMPLETE));
				}
			} 
			currentFrame = _currentFrame;
			_currentFrame++;
			
		}
		
		public function get currentFrame():int { return _currentFrame; }
		public function set currentFrame(value:int):void {
			_currentFrame = Math.max(1, Math.min(_currentEndFrame, value));
			this.bitmapData = frameCache[_currentFrame-1];
		}
	}
}
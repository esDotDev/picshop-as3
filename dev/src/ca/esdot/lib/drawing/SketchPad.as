package ca.esdot.lib.drawing
{
	import ca.esdot.lib.drawing.brushes.*;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.events.SketchEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageQuality;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.utils.getTimer;

	public class SketchPad extends SizableView
	{
		//Protected var 
		protected var cachedBrushList:Vector.<IBrush>;
		protected var displayBrushList:Vector.<IBrush>;
		protected var brushTypes:Array;
		
		protected var _stage:Stage;
		protected var _currentCachedBrush:AbstractBrush;
		protected var _currentDisplayBrush:AbstractBrush;
		
		//Detect mouse
		protected var bg:Sprite;
				
		protected var cachedCanvas:Sprite;
		protected var displayCanvas:Sprite;
		
		protected var bitmapCache:Bitmap;
		
		protected var isDrawing:Boolean;
		
		protected var _opacity:Number = 1;
		protected var _color:int = 0;
		protected var _thickness:int;
		
		
		public function SketchPad(stage:Stage){
			_stage = stage;
			bg = new Sprite();
			bg.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			bg.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			addChild(bg);
			
			//canvas for frame drawing
			displayCanvas = new Sprite();
			displayCanvas.mouseEnabled = false;
			addChild(displayCanvas); 
			
			cachedCanvas = new Sprite();
			
			bitmapCache = new Bitmap();
			addChild(bitmapCache);
			
			isDrawing = false;
			
			///////////////////////
			// create GUIs and Brushes
			currenBrush = Brushes.SIMPLE;
			
			//currentDisplayBrush.style.thickness = 5;
			//currentCacheBrush.style.thickness = 5;
			
		}
		
		public function get currentSprite():Sprite {
			var s:Sprite = new Sprite();
			var g:Graphics = s.graphics;
			g.copyFrom(cachedCanvas.graphics);
			return s;
		}
		
		public function get currentGraphics():Graphics {
			var s:Sprite = new Sprite();
			var g:Graphics = s.graphics;
			g.copyFrom(cachedCanvas.graphics);
			return g;
		}
		
		public function set currentGraphics(value:Graphics):void {
			if(!value){ return; }
			cachedCanvas.graphics.clear();
			cachedCanvas.graphics.copyFrom(value);
			
			var bd:BitmapData = bitmapCache.bitmapData;
			bd.fillRect(bd.rect, 0x0);
			
			if(RENDER::GPU) {
				bd.drawWithQuality(cachedCanvas, null, null, null, null, false, StageQuality.HIGH);
			} else {
				bd.draw(cachedCanvas, null, null, null, null, false);
			}
		}

		public function get thickness():int { return _thickness; }
		public function set thickness(value:int):void {
			_thickness = value;
			currentCacheBrush.style.thickness = thickness;
			currentDisplayBrush.style.thickness = thickness;
		}
		
		public function get opacity():Number { return _opacity; }
		public function set opacity(value:Number):void {
			_opacity = value;
			currentCacheBrush.style.alpha = opacity;
			currentDisplayBrush.style.alpha = opacity;
		}

		public function get color():int { return _color; }
		public function set color(value:int):void {
			_color = value;
			currentCacheBrush.style.color = value;
			currentDisplayBrush.style.color = value;
		}

		public function set currenBrush(value:Object):void {
			if(value is String){
				_currentDisplayBrush = Brushes.getBrush(value as String, displayCanvas, stage);
				_currentCachedBrush = Brushes.getBrush(value as String, cachedCanvas, stage);
			} else if(value is AbstractBrush){
				_currentCachedBrush = value as AbstractBrush;
			}
			color = color;
			thickness = thickness;
			opacity = opacity;
		}
		
		public function get currentDisplayBrush():AbstractBrush {
			return _currentDisplayBrush;
		}
		
		public function get currentCacheBrush():AbstractBrush {
			return _currentCachedBrush;
		}
		
		override public function updateLayout():void {
			bg.graphics.clear();
			bg.graphics.beginFill(0x0, 0);
			bg.graphics.drawRect(0, 0, viewWidth, viewHeight);
			bg.graphics.endFill();
			
			bitmapCache.bitmapData = new BitmapData(viewWidth, viewHeight, true, 0x0);
		}
		
		public function setColor():void{
			if(currentCacheBrush){
				currentCacheBrush.style.setHexColor(color);
				currentDisplayBrush.style.setHexColor(color);
			}
		}
		
		protected function onMouseDown(event:MouseEvent):void {
			_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			(currentCacheBrush as IBrush).strokeStart(displayCanvas.mouseX,displayCanvas.mouseY);
			(currentDisplayBrush as IBrush).strokeStart(displayCanvas.mouseX,displayCanvas.mouseY);
			
			isDrawing = true;
			dispatchEvent(new SketchEvent(SketchEvent.STROKE_STARTED));
		}
		
		protected function onMouseMove(event:MouseEvent):void {			
			if(isDrawing) {
				// draw the stroke for one(!) frame
				var t:int = getTimer();
				(currentDisplayBrush as IBrush).stroke(event.target.mouseX, event.target.mouseY);
				t = getTimer();
				(currentCacheBrush as IBrush).stroke(event.target.mouseX, event.target.mouseY);
				
				if(RENDER::GPU) {
					bitmapCache.bitmapData.drawWithQuality(displayCanvas, null, null, null, null, false, StageQuality.HIGH);
				} else {
					bitmapCache.bitmapData.draw(displayCanvas, null, null, null, null, false);
				}
				// clean the canvas again for new drawings. Too much drawing decrease the performance very fast
				displayCanvas.graphics.clear();
			}
		}
		
		protected function onMouseUp(event:MouseEvent):void {
			(currentCacheBrush as IBrush).strokeEnd();
			(currentDisplayBrush as IBrush).strokeEnd();
			
			isDrawing = false;
			dispatchEvent(new SketchEvent(SketchEvent.STROKE_COMPLETE));
			
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		public function getCache(scale:Number = 1):BitmapData {
			var bitmapData:BitmapData = new BitmapData(bitmapCache.width * scale, bitmapCache.height * scale, true, 0x0);
			var m:Matrix = new Matrix();
			m.scale(scale, scale);
			bitmapData.draw(cachedCanvas, m, null, null, null, true);
			return bitmapData;
		}
	}
}
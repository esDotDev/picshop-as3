package ca.esdot.lib.components
{
	import com.gskinner.motion.GTween;
	import com.gskinner.ui.touchscroller.TouchScrollEvent;
	import com.gskinner.ui.touchscroller.TouchScrollListener;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.Capabilities;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import ca.esdot.lib.data.TweenConstants;
	import ca.esdot.lib.view.SizableView;
	
	import fl.motion.easing.Quadratic;
	
	public class MaskedTouchScroller extends SizableView
	{
		protected var target:InteractiveObject;
		protected var maskSprite:Sprite;
		protected var scrollListener:TouchScrollListener;
		protected var _maxScrollX:Number;
		protected var _maxScrollY:Number;
		
		public var isScrolling:Boolean = false;
		
		protected var velX:Number = 0;
		protected var velY:Number = 0;
		
		protected var lastScrollTime:int = 0;
		protected var lastDeltaX:Number;
		protected var lastDeltaY:Number;
		
		protected var inBoundsLeft:Boolean;
		protected var inBoundsRight:Boolean;
		protected var inBoundsTop:Boolean;
		protected var inBoundsBottom:Boolean;
		protected var scrollHorizontal:Boolean;
		protected var scrollVertical:Boolean;
		
		public var boundsSprite:DisplayObject;
		
		public function MaskedTouchScroller(target:InteractiveObject, scrollVertical:Boolean = true, scrollHorizontal:Boolean = true, useMask:Boolean = true){
			this.target = target;
			addChild(target);
			
			this.scrollVertical = scrollVertical;
			this.scrollHorizontal = scrollHorizontal;
			
			maskSprite = new Sprite();
			maskSprite.graphics.beginBitmapFill(new BitmapData(1, 1, false, 0x0));
			maskSprite.graphics.drawRect(0, 0, 100, 100);
			maskSprite.graphics.endFill();
			
			this.useMask = useMask;
			
			scrollListener = new TouchScrollListener(target, scrollVertical, scrollHorizontal);
			scrollListener.addEventListener(TouchScrollEvent.MOUSE_DOWN, onTouchScrollDown, false, 0, true);
			scrollListener.addEventListener(TouchScrollEvent.MOUSE_UP, onTouchScrollUp, false, 0, true);
			scrollListener.addEventListener(TouchScrollEvent.SCROLL, onTouchScroll, false, 0, true);
		}
		
		public function setScroll(horizontal:Boolean, vertical:Boolean):void {
			
			scrollListener.scrollHorizontal = scrollHorizontal = horizontal;
			scrollListener.scrollVertical = scrollVertical = vertical;
			
		}
		
		public function set useMask(value:Boolean):void {
			target.mask = value? maskSprite : null;
			maskSprite.visible = value;
		}
		
		protected function onTouchScrollDown(event:Event):void {
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		protected function onTouchScrollUp(event:Event):void {
			checkBounds();
			if(scrollHorizontal && (!inBoundsRight || !inBoundsLeft)){
				tweenInBounds();
			} 
			else if(scrollVertical && (!inBoundsTop || !inBoundsBottom)){
				tweenInBounds();
			}
			else if(scrollListener.scrollTriggered && getTimer() - lastScrollTime < 50){
				if(scrollVertical){
					velY = lastDeltaY;
				}
				if(scrollHorizontal){
					velX = lastDeltaX;
				}
				addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
			}
			setTimeout(function(){
				isScrolling = false;
			}, 50);
		}
		
		protected function onEnterFrame(event:Event):void {
			checkBounds();
			
			if(Math.abs(velX) > 0 && scrollHorizontal){
				target.x -= velX;
				velX *= .96;
				
				if(Math.abs(velX) < 1){ 
					velX = 0; 
				}
				
				if(!inBoundsLeft || !inBoundsRight){
					tweenInBounds();
					velX = 0;
				}
			}
			
			if(Math.abs(velY) > 0 && scrollVertical){
				target.y -= velY;
				velY *= .96;
				if(Math.abs(velY) < 1){ 
					velY = 0; 
				}
				
				if(!inBoundsTop || !inBoundsBottom){
					tweenInBounds();
					velY = 0;
				}
			}
			
			if(velX == 0 && velY == 0){
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}
		
		
		public function tweenInBounds(speed:Number = .35):void {
			
			if(!inBoundsLeft){
				new GTween(target, speed, {x: 0}, {ease: Quadratic.easeOut});
			} else if(!inBoundsRight){
				if(maxScrollX < 0){
					new GTween(target, speed, {x: maxScrollX}, {ease: Quadratic.easeOut});
				} else {
					new GTween(target, speed, {x: 0}, {ease: Quadratic.easeOut});
				}
			}
			
			if(!inBoundsTop){
				new GTween(target, speed, {y: 0}, {ease: Quadratic.easeOut});
			} else if(!inBoundsBottom){
				if(maxScrollY < 0){
					new GTween(target, speed, {y: maxScrollY}, {ease: Quadratic.easeOut});
				} else {
					new GTween(target, speed, {y: 0}, {ease: Quadratic.easeOut});
				}
			}
		}
		
		protected function onTouchScroll(event:TouchScrollEvent):void {
			checkBounds();
			isScrolling = true;
			
			lastScrollTime = getTimer();
			lastDeltaX = event.mouseDeltaX;
			lastDeltaY = event.mouseDeltaY;
			
			var delta:int = event.mouseDeltaX;
			if(!inBoundsLeft && delta < 0 || !inBoundsRight && delta > 0){ delta *= .3; }
			target.x -= delta;
			
			delta = event.mouseDeltaY;
			if(!inBoundsTop && delta < 0 || !inBoundsBottom && delta > 0){ delta *= .3; }
			target.y -= delta;
			
			dispatchEvent(event);
		}
		
		override public function updateLayout():void {
			maskSprite.width = viewWidth;
			maskSprite.height = viewHeight;
			addChild(maskSprite);
			
			calculateBounds();
		}
		
		public function calculateBounds():void {
			if(boundsSprite){
				_maxScrollX = -boundsSprite.width + viewWidth;
				_maxScrollY = -boundsSprite.height + viewHeight;
			} else {
				_maxScrollX = -target.width + viewWidth;
				_maxScrollY = -target.height + viewHeight;
			}
			if(_maxScrollX > 0){ 
				_maxScrollX = 0; 
			}
			if(_maxScrollY > 0){
				_maxScrollY = 0; 
			}
			
		}
		
		public function checkBounds():void {
			inBoundsLeft = (target.x <= 0);
			inBoundsRight = (target.x >= maxScrollX);
			
			//trace("inBoundsBottom: ", inBoundsBottom);
			inBoundsTop = target.y <= 0;
			inBoundsBottom = (target.y >= maxScrollY);
		}
		
		public function get maxScrollX():Number {
			return _maxScrollX;
		}
		
		public function get maxScrollY():Number {
			return _maxScrollY;
		}
		
		
	}
}
import ca.esdot.lib.components;


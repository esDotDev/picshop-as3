/**
 * Easing equations adapted from Robert Penner's easing equations.
 * 
 * Copyright (c) 2009 Grant Skinner
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 **/

package com.gskinner.ui.touchscroller
{
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	import flash.text.TextField;
	import flash.utils.getTimer;
	
	public class TouchScroller extends Sprite
	{
		//A constant found in Penners Back.easeOut function, determines the amount of overshoot on the Back.easeOut. 
		//We'll tweak this depending on the distance travelled to give nicer easing.
		protected const EASE_OVERSHOOT:Number = 1.25; // Original value: 1.70158
		
		protected var easeOvershoot:Number = EASE_OVERSHOOT; 
		
		protected var _target:InteractiveObject;
		
		protected var minScrollX:Number = 0;
		protected var maxScrollX:Number = 0;
		
		protected var minScrollY:Number = 0;
		protected var maxScrollY:Number = 0;
		
		protected var viewportOffsetX:Number = 0;
		protected var viewportOffsetY:Number = 0;
		
		protected var contentScrollRect:Rectangle;
		protected var gestureListener:TouchScrollListener;
		
		protected var _scrollHorizontal:Boolean = true;
		protected var _scrollVertical:Boolean = true;
		
		protected var _mouseDown:Boolean;
		public function get mouseDown():Boolean{ return _mouseDown; }
		
		protected var _isScrolling:Boolean;
		public function get isScrolling():Boolean { return _isScrolling; }
		
		public function get scrollTriggered():Boolean { return gestureListener.scrollTriggered; }
		
		protected var _flickDuration:Number = 0.5;
		/** Normalized value between .01 - 1 which determines the relative scroll speed. A higher duration will give you a slower scroll tween. <br />Default: 0.5  **/
		public function get flickDuration():Number { return _flickDuration; }
		public function set flickDuration(value:Number):void {
			_flickDuration = (value <= 0)? .01 : Math.min(value, 1);
			easeOvershoot = EASE_OVERSHOOT / (_flickDistance + _flickDuration + .25);
		}
		
		protected var _flickDistance:Number = 0.25;
		/** Value between .01 - 1 which determines how far the content will move on a  flick event. <br />Default: 0.25 **/
		public function get flickDistance():Number { return _flickDistance; }
		public function set flickDistance(value:Number):void {
			_flickDistance = (value <= 0)? .01 : Math.min(value, 1);
			easeOvershoot = EASE_OVERSHOOT / (_flickDistance + _flickDuration + .25);
		}
		
		protected var _defaultEaseDuration:Number = 1;
		/** Duration used for automated tweens. ie when using setPosition or when an object is autoTweened back in bounds) **/
		public function get defaultEaseDuration():Number { return _defaultEaseDuration; }
		public function set defaultEaseDuration(value:Number):void { 
			_defaultEaseDuration = Math.abs(value);
		}
		
		protected var _positionX:Number = 0;
		public function get positionX():Number { return _positionX; }
		public function set positionX(value:Number):void { setPositionX(value); }
		
		protected var _positionY:Number = 0;
		public function get positionY():Number { return _positionY; }
		public function set positionY(value:Number):void { setPositionY(value); }
		
		/** Allow horizontal scrolling **/
		public function set scrollHorizontal(value:Boolean):void { gestureListener.scrollHorizontal = value; _scrollHorizontal = value; }
		public function get scrollHorizontal():Boolean { return _scrollHorizontal; }
		
		/** Allow vertical scrolling **/
		public function set scrollVertical(value:Boolean):void { gestureListener.scrollVertical = value; _scrollVertical = value; }
		public function get scrollVertical():Boolean { return _scrollVertical; }
		
		/** Minimum value (in pixels) that the finger can move, before it is considered a scroll action. 
		 * Anything less than this will register as a click when the user releases their finger. **/
		public function set scrollThreshold(value:int):void { gestureListener.scrollThreshold = value; }
		
		/** Minimum value (in pixels) between mouse_move events before a flick event will be dispatched. This is determined on MOUSE_UP. **/
		public function set flickThreshold(value:int):void { gestureListener.scrollThreshold = value; }
		
		protected var contentBounds:Rectangle;
		/** Returns the actual width of the content Display Object */
		public function get contentWidth():Number { return contentBounds.width; }
		/** Returns the actual height of the content Display Object */
		public function get contentHeight():Number { return contentBounds.height; }
		
		protected var _hitObject:InteractiveObject;
		/** Optional hitObject to initiate drag (if you'd like something in addition to the target itself) **/
		public function set hitObject(value:InteractiveObject):void {
			_hitObject = value;
			if(gestureListener){ gestureListener.hitObject = value; }
		}
		
		/** callback(clickTarget:Object, mouseDeltaX:Number, mouseDeltaY:Number); **/
		public var onMouseDownCallback:Function;
		/** callback(clickTarget:Object, mouseDeltaX:Number, mouseDeltaY:Number); **/
		public var onMouseUpCallback:Function;
		/** callback(clickTarget:Object, mouseDeltaX:Number, mouseDeltaY:Number); **/
		public var onClickCallback:Function;
		/** callback(clickTarget:Object, mouseDeltaX:Number, mouseDeltaY:Number); **/
		public var onScrollCallback:Function;
		/** callback(clickTarget:Object, mouseDeltaX:Number, mouseDeltaY:Number); **/
		public var onFlickCallback:Function;
		/** callback(positionX:int, positionY:int){} **/
		public var onTweenCallback:Function;
		
		/** Supports all standard as3 easing equations. **/
		public var ease:Function;
		
		/** Allow target area to be dragged past it's min/max Y boundary. <br />Default: true **/
		public var allowOverscrollY:Boolean = true;
		
		/** Allow target area to be dragged past it's min/max X boundary. <br />Default: true **/
		public var allowOverscrollX:Boolean = true;
		
		public function TouchScroller(target:InteractiveObject, viewport:Rectangle, scrollVertical:Boolean = true, scrollHorizontal:Boolean = true){
			super();
			contentScrollRect = new Rectangle(0, 0, 0, 0);
			_scrollHorizontal = scrollHorizontal;
			_scrollVertical = scrollVertical;
			
			setTarget(target);
			setViewport(viewport);
		}
		
		public function setTarget(target:InteractiveObject):void {
			//Remove scrollRect from the previous target
			if(_target != null){ _target.scrollRect = null; }
			
			_target = target;
			updateScrollRect(0, 0, contentScrollRect.width, contentScrollRect.height);
			
			if(gestureListener == null){ 
				gestureListener = new TouchScrollListener(_target, _scrollVertical, _scrollHorizontal); 
				gestureListener.onClickCallback = onClick;
				gestureListener.onFlickCallback = onFlick;
				gestureListener.onMouseDownCallback = onTargetMouseDown;
				gestureListener.onScrollCallback = onTargetScroll;
				gestureListener.onMouseUpCallback = onTargetMouseUp;
			} else {
				gestureListener.setTarget(target);
			}
			if(_hitObject != null){
				hitObject = _hitObject;
			}
		}
		
		public function setPositionY(position:Number, tween:Boolean=true, tweenDuration:Number = -1):void {
			//Position should not be less than 0 or greater than 1.
			position = (position < 0 || isNaN(position))? 0 : Math.min(position, 1);
			var targetY:Number = minScrollY + (maxScrollY - minScrollY) * position;
			
			var deltaY:Number = Math.abs(contentScrollRect.y - targetY);
			var duration:Number = (tweenDuration == -1)? _defaultEaseDuration : tweenDuration;
			if(tween) { 
				tweenTarget(contentScrollRect.x, targetY, duration); 
			} else {
				contentScrollRect.y = targetY;
				updateScrollRect(contentScrollRect.x, contentScrollRect.y);
			}
		}
		
		public function setPositionX(position:Number, tween:Boolean=true, tweenDuration:Number = -1):void {
			
			position = (position < 0 || isNaN(position))? 0 : Math.min(position, 1);
			var targetX:Number = minScrollX + (maxScrollX - minScrollX) * position;
			
			var deltaX:Number = Math.abs(contentScrollRect.x - targetX)
			var duration:Number = (tweenDuration == -1)? _defaultEaseDuration : tweenDuration;
			if(tween) { 
				tweenTarget(targetX, contentScrollRect.y, duration); 
			} else {
				contentScrollRect.x = targetX;
				updateScrollRect(contentScrollRect.x, contentScrollRect.y);
			}
		}
		
		public function refresh(updatePosition:Boolean = true):void {
			calculateBounds();
			if(!updatePosition){ return; }
			
			var newScrollY:Number = minScrollY + (maxScrollY - minScrollY)  * _positionY;
			var newScrollX:Number = minScrollX + (maxScrollX - minScrollX)  * _positionX;
			updateScrollRect(newScrollX, newScrollY, contentScrollRect.width, contentScrollRect.height);
		}
		
		public function setViewport(viewport:Rectangle):void {
			contentScrollRect.width = viewport.width;
			contentScrollRect.height = viewport.height;
			viewportOffsetX = -viewport.x;
			viewportOffsetY = -viewport.y;
			refresh();
		}
		
		public function releaseTarget():void {
			if(_target == null){ return; }
			_target.scrollRect = null;
			_hitObject = null;
			gestureListener.destroy();
			gestureListener = null;
		}
		
		public function stopTween():void {
			removeEventListener(Event.ENTER_FRAME, onTweenTick);
		}
		
		protected function updateScrollRect(x:Number, y:Number, width:Number=0, height:Number=0):void {
			contentScrollRect.x = x;
			contentScrollRect.y = y;
			if(width != 0){ contentScrollRect.width = width; }
			if(height != 0){ contentScrollRect.height = height; }
			
			calculatePosition();
			_target.scrollRect = contentScrollRect;
		}
		
		protected function calculatePosition():void {
			_positionX = (maxScrollX == minScrollX)? 0 : (contentScrollRect.x - minScrollX)/(maxScrollX - minScrollX);
			_positionY = (maxScrollY == minScrollY)? 0 : (contentScrollRect.y - minScrollY)/(maxScrollY - minScrollY);
		}
		
		protected function calculateBounds():void {
			if(!_target){ return; }
			contentBounds = getRealBounds(_target);
			maxScrollX = Math.max(contentBounds.width - contentScrollRect.width - viewportOffsetX, minScrollX);
			maxScrollY = Math.max(contentBounds.height - contentScrollRect.height - viewportOffsetY, minScrollY);

			minScrollX = viewportOffsetX;
			minScrollY = viewportOffsetY;
		}
		
		// Determine the actual size of a displayObject using scrollRect. 
		// This method does not suffer from the inconsistencies associated with the transform.pixelBounds() method.
		protected function getRealBounds(displayObject:InteractiveObject) :Rectangle{
				//Textfield need special consideration, maybe other non-DisplayObjectContainer's do too?
				if(displayObject is TextField){
					return new Rectangle(0, 0, (displayObject as TextField).textWidth, (displayObject as TextField).textHeight);
				} else {
					var bounds:Rectangle, transform:Transform,
					globalMatrix:Matrix, currentMatrix:Matrix;
					
					transform = displayObject.transform;
					currentMatrix = transform.matrix;
					globalMatrix = transform.concatenatedMatrix;
					globalMatrix.invert();
					transform.matrix = globalMatrix;
					
					bounds = transform.pixelBounds.clone();
					transform.matrix = currentMatrix;
					return bounds;
				}
		}

/***********************************
 * MOUSE INTERACTION
 ***********************************/
		
		protected function onClick(clickTarget:Object, mouseDeltaX:Number, mouseDeltaY:Number):void {
			dispatchEvent(new TouchScrollEvent(TouchScrollEvent.CLICK, clickTarget, mouseDeltaX, mouseDeltaY));
			if(onClickCallback != null){
				onClickCallback(clickTarget, mouseDeltaX, mouseDeltaY);
			}
		}
		
		protected function onTargetMouseDown(clickTarget:Object, mouseDeltaX:Number, mouseDeltaY:Number):void {
			_mouseDown = true;
			removeEventListener( Event.ENTER_FRAME, onTweenTick );
			dispatchEvent(new TouchScrollEvent(TouchScrollEvent.MOUSE_DOWN, clickTarget, mouseDeltaX, mouseDeltaY));
			if(onMouseDownCallback != null){
				onMouseDownCallback(clickTarget, mouseDeltaX, mouseDeltaY);
			}
		}
		
		protected function onTargetScroll(clickTarget:Object, mouseDeltaX:Number, mouseDeltaY:Number):void {
			var targetX:Number = contentScrollRect.x + mouseDeltaX;
			var targetY:Number = contentScrollRect.y + mouseDeltaY;
			if(!allowOverscrollX){
				targetX = (targetX < minScrollX)? minScrollX : Math.min(maxScrollX, targetX);
			}
			if(!allowOverscrollY){
				targetY = (targetY < minScrollY)? minScrollY :  Math.min(maxScrollY, targetY);
			}
			updateScrollRect(targetX, targetY);
			dispatchEvent(new TouchScrollEvent(TouchScrollEvent.SCROLL, clickTarget, mouseDeltaX, mouseDeltaY));
			if(onScrollCallback != null){
				onScrollCallback(clickTarget, mouseDeltaX, mouseDeltaY);
			}
		}
		
		protected function onTargetMouseUp(clickTarget:Object, mouseDeltaX:Number, mouseDeltaY:Number):void {
			var outOfBounds:Boolean = true;
			var targetX:Number = (contentScrollRect.x < minScrollX)? minScrollX : Math.min(contentScrollRect.x, maxScrollX);
			var targetY:Number = (contentScrollRect.y < minScrollY)? minScrollY : Math.min(contentScrollRect.y, maxScrollY);
			
			_mouseDown = false;
			dispatchEvent(new TouchScrollEvent(TouchScrollEvent.MOUSE_UP, clickTarget, mouseDeltaX, mouseDeltaY));
			if(onMouseUpCallback != null){
				onMouseUpCallback(clickTarget, mouseDeltaX, mouseDeltaY);
			}
			//Tween target back in bounds if it's out
			if(contentScrollRect.y < minScrollY || contentScrollRect.y > maxScrollY || contentScrollRect.x < minScrollX || contentScrollRect.x > maxScrollX){
				tweenTarget(targetX, targetY, _defaultEaseDuration);
			}
		}
		
		protected function onFlick(clickTarget:Object, mouseDeltaX:Number, mouseDeltaY:Number):void {
			var targetX:Number = contentScrollRect.x + (mouseDeltaX * 40 * _flickDistance);
			targetX = (targetX < minScrollX)? minScrollX : Math.min(targetX, maxScrollX);
			
			var targetY:Number = contentScrollRect.y + (mouseDeltaY * 40 * _flickDistance);
			targetY = (targetY < minScrollY)? minScrollY : Math.min(targetY, maxScrollY);
			
			var duration:Number = calculateDuration(mouseDeltaX, mouseDeltaY);
			tweenTarget(targetX, targetY, duration);
			
			_isScrolling = true;
			dispatchEvent(new TouchScrollEvent(TouchScrollEvent.FLICK, clickTarget, mouseDeltaX, mouseDeltaY));
			if(onFlickCallback != null){
				onMouseUpCallback(clickTarget, mouseDeltaX, mouseDeltaY);
			}
		}
		
		protected function calculateDuration(mouseDeltaX:Number, mouseDeltaY:Number):Number {
			return (_defaultEaseDuration + Math.abs(Math.max(mouseDeltaX, mouseDeltaY)) / 125) * _flickDuration;
		}

/***********************************
 * TWEENING 
***********************************/
		
		protected var tweenStartX:Number;
		protected var tweenEndX:Number;
		protected var tweenStartY:Number;
		protected var tweenEndY:Number;
		protected var tweenStartTime:int;
		protected var tweenCurrentTime:int;
		protected var tweenDuration:int;
		
		protected function tweenTarget(targetX:Number, targetY:Number, duration:Number):void {
			_isScrolling = true;
			tweenDuration = duration * 1000;
			
			tweenStartY = contentScrollRect.y;
			tweenEndY = targetY;
			
			tweenStartX = contentScrollRect.x;
			tweenEndX = targetX;
			tweenStartTime = getTimer();
			stopTween();
			addEventListener( Event.ENTER_FRAME, onTweenTick, false, 0, true);
			onTweenStart();
		}
		
		protected function onTweenTick(event:Event):void{
			tweenCurrentTime = getTimer();
			if (tweenCurrentTime - tweenStartTime <= tweenDuration){
				//Use internal easing functions?
				if(ease == null){
					contentScrollRect.y = backEaseOut(tweenCurrentTime - tweenStartTime,tweenStartY,tweenEndY - tweenStartY, tweenDuration);
					contentScrollRect.x = backEaseOut(tweenCurrentTime - tweenStartTime,tweenStartX,tweenEndX - tweenStartX, tweenDuration);
				} else {
					contentScrollRect.y = ease(tweenCurrentTime - tweenStartTime,tweenStartY,tweenEndY - tweenStartY, tweenDuration);
					contentScrollRect.x = ease(tweenCurrentTime - tweenStartTime,tweenStartX,tweenEndX - tweenStartX, tweenDuration);
				}
				
				if(onTweenCallback != null){
					onTweenCallback(positionX, positionY);
				}
			}else{
				contentScrollRect.y = tweenEndY;
				contentScrollRect.x = tweenEndX;
				_isScrolling = false;
				removeEventListener( Event.ENTER_FRAME, onTweenTick );
				onTweenComplete();
			}
			updateScrollRect(contentScrollRect.x, contentScrollRect.y);
			
		}

		protected function backEaseOut (time:Number, positionStart:Number, positionDelta:Number, duration:Number, overshoot:Number=1.70158):Number {
			return positionDelta*((time=time/duration-1)*time*((easeOvershoot+1)*time + easeOvershoot) + 1) + positionStart;
		}
		
		protected function onTweenStart():void {
			dispatchEvent(new TouchScrollEvent(TouchScrollEvent.TWEEN_STARTED));
			//Want to do something when the tween has started? Do it here.
		}
		
		protected function onTweenComplete():void {
			_isScrolling = false;
			dispatchEvent(new TouchScrollEvent(TouchScrollEvent.TWEEN_COMPLETED));
			//Want to do something when the tween has finished? Do it here.
		}

	}
}
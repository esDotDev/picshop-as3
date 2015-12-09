/**
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
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	public class TouchScrollListener extends EventDispatcher
	{
		protected var _scrollTarget:InteractiveObject;
		protected var _clickTarget:Object;
		public function get clickTarget():Object { return _clickTarget; }
		
		public var scrollThreshold:int = 20;
		public var flickThreshold:int = 20;
		
		public var scrollVertical:Boolean = true;
		public var scrollHorizontal:Boolean = true;
		
		protected var mouseDown:Boolean = true;
		protected var _scrollTriggered:Boolean;

		public function get scrollTriggered():Boolean{ return _scrollTriggered; }

		public function set scrollTriggered(value:Boolean):void {
			_scrollTriggered = value;
		}

		
		protected var mouseStartX:Number;
		protected var mouseStartY:Number;
		
		protected var mouseDeltaX:Number;
		protected var mouseDeltaY:Number;
		
		protected var mousePreviousX:Number;
		protected var mousePreviousY:Number;
		
		protected var stage:Stage;
		
		public var _hitObject:InteractiveObject;
		/** Optional hitObject to initiate drag (if you'd like something other than the target itself) **/
		public function set hitObject(value:InteractiveObject):void {
			if(_hitObject){ _hitObject.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown); }
			_hitObject = value;
			_hitObject.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
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
		
		public function TouchScrollListener(scrollTarget:InteractiveObject, scrollVertical:Boolean = true, scrollHorizontal:Boolean = true){
			setTarget(scrollTarget);
			this.scrollVertical = scrollVertical;
			this.scrollHorizontal = scrollHorizontal;
		}
		
		public function setTarget(scrollTarget:InteractiveObject):void {
			if(_scrollTarget){ removeListeners(); }
			_scrollTarget = scrollTarget;
			_scrollTarget.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		public function destroy():void {
			removeListeners();
			removeCallbacks();
		}
		
		protected function onMouseDown(event:MouseEvent):void {
			mouseDown = true;
			stage = event.target.stage;
			
			mouseStartY = mousePreviousY = stage.mouseY;
			mouseDeltaY = 0;
			
			mouseStartX = mousePreviousX = stage.mouseX;
			mouseDeltaX = 0;
			
			_clickTarget = event.target;
			dispatchEvent(new TouchScrollEvent(TouchScrollEvent.MOUSE_DOWN, _clickTarget, mouseDeltaX, mouseDeltaY));
			callBack(onMouseDownCallback);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, true, 0, true);
		}
		
		protected function onMouseMove(event:MouseEvent):void {
			if(!mouseDown){ return; }
			if(!scrollTriggered){
				if(scrollVertical){
					scrollTriggered = (Math.abs(mouseStartY - stage.mouseY) > scrollThreshold)? true : false;
					mousePreviousY = stage.mouseY;
					if(scrollTriggered){ return; }
				} 
				if(scrollHorizontal){
					scrollTriggered = (Math.abs(mouseStartX - stage.mouseX) > scrollThreshold)? true : false;
					mousePreviousX = stage.mouseX;
				}
				return;
			}
			mouseDeltaX = (scrollHorizontal)? mousePreviousX - stage.mouseX : 0;
			mouseDeltaY = (scrollVertical)? mousePreviousY - stage.mouseY : 0;
			
			mousePreviousY = stage.mouseY;
			mousePreviousX = stage.mouseX;
			
			dispatchEvent(new TouchScrollEvent(TouchScrollEvent.SCROLL, _clickTarget, mouseDeltaX, mouseDeltaY));
			callBack(onScrollCallback);
		}
		
		protected function onMouseUp(event:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp, true);
			
			dispatchEvent(new TouchScrollEvent(TouchScrollEvent.MOUSE_UP, _clickTarget, mouseDeltaX, mouseDeltaY));
			callBack(onMouseUpCallback);
			
			//If a click was detected.
			if(!scrollTriggered){
				dispatchEvent(new TouchScrollEvent(TouchScrollEvent.CLICK, _clickTarget, mouseDeltaX, mouseDeltaY));
				callBack(onClickCallback);
			}
			//TODO: Speed/velocity based delta:
			else {
				//If a flick was detected
				if(Math.abs(mouseDeltaX) > flickThreshold && scrollHorizontal){
					dispatchEvent(new TouchScrollEvent(TouchScrollEvent.FLICK, _clickTarget, mouseDeltaX, mouseDeltaY));
					callBack(onFlickCallback);
				} else if(Math.abs(mouseDeltaY) > flickThreshold && scrollVertical){
					dispatchEvent(new TouchScrollEvent(TouchScrollEvent.FLICK, _clickTarget, mouseDeltaX, mouseDeltaY));
					callBack(onFlickCallback);
				}
			}
			mouseDown = false;
			setTimeout(function(){
				scrollTriggered = false;
			}, 1);
		}
		
		protected function callBack(callback:Function = null):void {
			if(callback == null){ return; }
			callback(_clickTarget, mouseDeltaX, mouseDeltaY);
		}
		
		protected function removeListeners():void {
			if(_scrollTarget){
				_scrollTarget.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				_scrollTarget = null;
			}
			if(stage){
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp, true);
				stage = null;
			}
			if(_hitObject){
				_hitObject.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				_hitObject = null;
			}
		}
		
		protected function removeCallbacks():void {
			_clickTarget = null;
			onMouseDownCallback = null;
			onMouseUpCallback = null;
			onClickCallback = null;
			onScrollCallback = null;
			onFlickCallback = null;
		}
	}
}
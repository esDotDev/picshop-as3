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
	import flash.events.Event;
	
	public class TouchScrollEvent extends Event
	{
		public static const MOUSE_DOWN:String = "TouchScrollEvent.mouseDown";
		public static const SCROLL:String = "TouchScrollEvent.scroll";
		public static const CLICK:String = "TouchScrollEvent.click";
		public static const FLICK:String = "TouchScrollEvent.flick";
		public static const MOUSE_UP:String = "TouchScrollEvent.mouseUp";
		
		public static const TWEEN_STARTED:String = "TouchScrollEvent.tweenStarted";
		public static const TWEEN_COMPLETED:String = "TouchScrollEvent.tweenCompleted";
		
		public var mouseDeltaX:Number;
		public var mouseDeltaY:Number;
		public var clickTarget:Object;
		
		public function TouchScrollEvent(type:String, clickTarget:Object = null, mouseDeltaX:Number = 0, mouseDeltaY:Number = 0, bubbles:Boolean=false, cancelable:Boolean=false){
			this.clickTarget = clickTarget;
			this.mouseDeltaX = mouseDeltaX;
			this.mouseDeltaY = mouseDeltaY;
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event {
			return new TouchScrollEvent(type, clickTarget, mouseDeltaX, mouseDeltaY, bubbles, cancelable);
		}
	}
}
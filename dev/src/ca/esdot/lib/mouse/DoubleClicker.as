package ca.esdot.lib.mouse
{
	import flash.display.InteractiveObject;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	
	public class DoubleClicker extends EventDispatcher
	{
		
		public function DoubleClicker(target:InteractiveObject){
			target.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
		}
		
		protected var lastClick:Number;
		protected function onClick(event:MouseEvent):void {
			if(!isNaN(lastClick) && getTimer() - lastClick < 500){
				trace("DoubleClick?");
			}
			lastClick = getTimer();			
		}
		
		
		
	}
}
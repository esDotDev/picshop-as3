package ca.esdot.lib.components.events
{
	import flash.events.Event;
	
	public class SliderEvent extends Event
	{
		public static const SLIDER_CHANGED:String = "slideChanged";
		
		public var value:Number; 
		
		public function SliderEvent(type:String, value:Number, bubbles:Boolean=false, cancelable:Boolean=false) {
			this.value = value;
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event {
			return new SliderEvent(type, value, bubbles, cancelable);
		}
	}
}
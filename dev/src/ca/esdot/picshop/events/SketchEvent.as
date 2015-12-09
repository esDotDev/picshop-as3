package ca.esdot.picshop.events
{
	import flash.events.Event;
	
	public class SketchEvent extends Event
	{
		public static var STROKE_STARTED:String = "strokeStarted";
		public static var STROKE_COMPLETE:String = "strokeComplete";
		
		public function SketchEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event {
			return new SketchEvent(type, bubbles, cancelable);
		}
	}
	
}
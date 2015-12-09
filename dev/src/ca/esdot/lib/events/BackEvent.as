package ca.esdot.lib.events
{
	import flash.events.Event;
	
	public class BackEvent extends Event
	{
		public static var BACK:String = "back";
		
		public function BackEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
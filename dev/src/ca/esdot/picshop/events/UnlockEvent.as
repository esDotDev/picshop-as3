package ca.esdot.picshop.events
{
	import flash.events.Event;
	
	public class UnlockEvent extends Event
	{
		public static var UNLOCK:String = "unlock";
		
		public function UnlockEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false){
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event {
			return new UnlockEvent(type, bubbles, cancelable);
		}
	}
}
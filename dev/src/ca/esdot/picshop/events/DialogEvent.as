package ca.esdot.picshop.events
{
	import flash.events.Event;
	
	public class DialogEvent extends Event
	{
		public function DialogEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event {
			return new DialogEvent(type, bubbles, cancelable);
		}
	}
	
}
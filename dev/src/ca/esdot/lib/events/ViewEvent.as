package ca.esdot.lib.events
{
	import flash.events.Event;
	
	public class ViewEvent extends Event
	{
		
		public static var TRANSITION_IN_COMPLETE:String = 'transitionInComplete';
		public static var TRANSITION_OUT_COMPLETE:String = 'transitionOutComplete';
		
		public function ViewEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
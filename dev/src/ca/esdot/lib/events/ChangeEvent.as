package ca.esdot.lib.events
{
	import flash.events.Event;
	
	public class ChangeEvent extends Event
	{
		
		public static const CHANGED:String = "changed";
		
		public var newValue:Object;
		public var oldValue:Object;
		
		public function ChangeEvent(type:String, newValue:Object=null, oldValue:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.newValue = newValue;
			this.oldValue = oldValue;
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event {
			return new ChangeEvent(type, newValue, oldValue, bubbles, cancelable);
		}
	}
}
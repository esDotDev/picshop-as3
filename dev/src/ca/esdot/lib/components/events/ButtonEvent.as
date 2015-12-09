package ca.esdot.lib.components.events
{
	import flash.events.Event;
	
	public class ButtonEvent extends Event
	{
		public var label:String;
		
		public static const CLICKED:String = "ButtonEvent.clicked";
		
		public function ButtonEvent(type:String, label:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.label = label;
			super(type, bubbles, cancelable);
		}
	}
}
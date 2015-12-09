package ca.esdot.lib.components.events
{
	import flash.events.Event;
	
	public class ToasterEvent extends Event
	{
		public static var SHOW_TOAST:String = "showToast";
		
		public var message:String;
		
		public function ToasterEvent(type:String, message:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.message = message;
			super(type, bubbles, cancelable);
		}
	}
}
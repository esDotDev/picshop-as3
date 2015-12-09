package ca.esdot.picshop.events
{
	import flash.events.Event;
	
	public class EditorEvent extends Event
	{
		public static var APPLY:String = "apply";
		public static var DISCARD:String = "discard";
		public static var UNDO:String = "undo";
		
		public function EditorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
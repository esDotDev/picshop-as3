package ca.esdot.picshop.commands.events
{
	import flash.events.Event;
	
	public class ChangeViewEvent extends Event
	{
		public static var CHANGE:String = "change";
		public static var BACK:String = "back";
		
		public var viewType:String;
		
		public function ChangeViewEvent(type:String, viewType:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.viewType = viewType;
			super(type, bubbles, cancelable);
		}
	}
}
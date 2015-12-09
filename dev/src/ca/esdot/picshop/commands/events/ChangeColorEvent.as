package ca.esdot.picshop.commands.events
{
	import flash.events.Event;
	
	public class ChangeColorEvent extends Event
	{
		public static var CHANGE_ACCENT:String = "changeAccent";
		
		public var color:int;
		
		public function ChangeColorEvent(type:String, color:int, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.color = color;
			super(type, bubbles, cancelable);
		}
	}
}
package ca.esdot.picshop.commands.events
{
	import flash.events.Event;
	
	public class SettingsEvent extends Event
	{
		public static var SAVE:String = "save";
		public static var LOAD:String = "load";
				
		public function SettingsEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
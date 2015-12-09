package ca.esdot.picshop.events
{
	import flash.events.Event;
	
	public class ShowMenuEvent extends Event
	{
		
		public static const SHOW_SECONDARY:String = "showSecondary";
		public var menuType:String;
		
		public function ShowMenuEvent(type:String, menuType:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			this.menuType = menuType;
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event {
			return new ShowMenuEvent(type, menuType, bubbles, cancelable);
		}
	}
	
}
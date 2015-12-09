package ca.esdot.lib.events
{
	import flash.events.Event;
	
	public class ListEvent extends Event
	{
		
		public static const ITEM_CLICKED:String = "itemClicked";
		
		public var data:Object;
		
		public function ListEvent(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false){
			this.data = data;
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event {
			return new ChangeEvent(type, data, bubbles, cancelable);
		}
	}
}
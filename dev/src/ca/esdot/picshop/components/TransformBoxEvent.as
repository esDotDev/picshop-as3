package ca.esdot.picshop.components
{
	import flash.events.Event;
	
	public class TransformBoxEvent extends Event
	{
		public static var DELETE:String = "deleteBox";
		public static var MOVE:String = "move";
		public static var ROTATE:String = "rotate";
		public static var SCALE:String = "scale";
		
		public function TransformBoxEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event {
			return new TransformBoxEvent(type, bubbles, cancelable);
		}
	}
	
}
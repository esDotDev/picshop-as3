package ca.esdot.picshop.commands.events
{
	import ca.esdot.lib.view.SizableView;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	public class StartEditEvent extends Event
	{
		public static var BASIC:String = "basic";
		public static var FILTER:String = "filter";
		public static var BORDER:String = "border";
		public static var EXTRAS:String = "extras";
		
		public var editType:String;
		
		public var image:DisplayObject;
		
		public function StartEditEvent(type:String, editType:String, image:DisplayObject=null, bubbles:Boolean=false, cancelable:Boolean=false) {
			this.image = image;
			this.editType = editType;
			super(type, bubbles, cancelable);
		}
	}
}
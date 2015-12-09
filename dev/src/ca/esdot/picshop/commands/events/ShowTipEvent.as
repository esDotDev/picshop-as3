package ca.esdot.picshop.commands.events
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	public class ShowTipEvent extends Event
	{
		public static var OPEN_IMAGE:String = "openImage";
		public static var UNDO_BUTTON_DRAG:String = "undoButton";
		public static var SETTINGS:String = "settings";
		public static var PINCH_TO_ZOOM:String = "fullscreen";
		public static var EDIT_MENU:String = "editMenu";
		public static var MEME:String = "meme";
		public static var SAVE:String = "save";
		public static var COMPARE:String = "compare";
		
		public var tipTarget:DisplayObject;
		
		
		public function ShowTipEvent(type:String, tipTarget:DisplayObject=null, bubbles:Boolean=false, cancelable:Boolean=false) {
			this.tipTarget = tipTarget;
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event {
			return new ShowTipEvent(type, tipTarget, bubbles, cancelable);
		}
	}
	
}
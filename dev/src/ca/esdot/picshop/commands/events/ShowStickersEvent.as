package ca.esdot.picshop.commands.events
{
	import ca.esdot.lib.view.SizableView;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	public class ShowStickersEvent extends Event
	{
		public static var SHOW_DIALOG:String = "showDialog";
		
		public var stickerType:String;
		
		public var image:DisplayObject;
		
		public function ShowStickersEvent(type:String, editType:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			this.image = image;
			this.stickerType = editType;
			super(type, bubbles, cancelable);
		}
	}
}
package ca.esdot.picshop.commands.events
{
	import ca.esdot.lib.view.SizableView;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	public class AddLayerEvent extends Event
	{
		public static var IMAGE:String = "image";
		public static var SPEECH_BUBBLE:String = "speechBubble";
		
		public var image:DisplayObject;
		
		public function AddLayerEvent(type:String, image:DisplayObject = null, bubbles:Boolean=false, cancelable:Boolean=false) {
			this.image = image;
			super(type, bubbles, cancelable);
		}
	}
}
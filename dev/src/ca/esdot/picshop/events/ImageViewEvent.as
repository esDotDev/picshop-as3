package ca.esdot.picshop.events
{
	import flash.events.Event;
	
	public class ImageViewEvent extends Event
	{
		public static var IMAGE_CLICKED:String = "imageClicked";
		public function ImageViewEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event {
			return new ImageViewEvent(type, bubbles, cancelable);
		}
	}
}
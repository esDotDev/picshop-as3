package ca.esdot.picshop.commands.events
{
	import flash.display.BitmapData;
	import flash.events.Event;
	
	public class PostEvent extends Event
	{
		public static var FACEBOOK:String = "facebook";
		public static var TWITTER:String = "twitter";
		
		public var bitmapData:BitmapData;
		private var message:String;
		
		public function PostEvent(type:String, bitmapData:BitmapData, message:String = "", bubbles:Boolean=false, cancelable:Boolean=false) {
			this.bitmapData = bitmapData;
			this.message = message;
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event {
			return new PostEvent(type, bubbles, cancelable);
		}
	}
	
}
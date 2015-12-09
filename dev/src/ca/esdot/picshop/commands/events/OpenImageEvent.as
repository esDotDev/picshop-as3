package ca.esdot.picshop.commands.events
{
	import flash.display.BitmapData;
	import flash.events.Event;

	public class OpenImageEvent extends Event
	{
		public static var CAMERA:String = "camera";
		public static var GALLERY:String = "gallery";
		public static var FACEBOOK:String = "facebook";
		public static var BITMAP_DATA:String = "bitmapData";
		public static var URL:String = "url";
		public static var TEST:String = "test";
		
		public var data:BitmapData;
		public var url:String;
		
		public function OpenImageEvent(type:String, data:BitmapData = null, url:String = "", bubbles:Boolean=false, cancelable:Boolean=false){
			super(type, bubbles, cancelable);
			this.data = data;
			this.url = url;
		}
	}
}
package ca.esdot.lib.events
{
	import flash.display.BitmapData;
	import flash.events.Event;
	
	public class ShareEvent extends Event
	{
		public static var FACEBOOK:String = "facebook";
		public static var FACEBOOK_POST:String = "facebookPost";
		
		public static var INSTAGRAM:String = "instagram";
		public static var INSTAGRAM_POST:String = "instagramPost";
		
		public static var TWITTER:String = "twitter";
		public static var TWITTER_POST:String = "twitterPost";
		
		public static var EMAIL:String = "email";
		public static var EMAIL_POST:String = "emailPost";
		
		public static var ANDROID:String = "android";
		
		public var subject:String;
		public var message:String;
		public var footer:String;
		public var bitmapData:BitmapData;
		public var url:String;
		
		public function ShareEvent(type:String, message:String = "", bitmapData:BitmapData = null, subject:String = "", footer:String = "", url:String = "", cancelable:Boolean=false) {
			this.message = message;
			this.bitmapData = bitmapData;
			this.subject = subject;
			this.footer = footer;
			this.url = url;
			super(type, bubbles, cancelable);
		}
	}
}
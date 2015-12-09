package ca.esdot.picshop.services
{
	import flash.events.Event;
	
	public class TwitterServiceEvent extends Event
	{
		public static var INIT_COMPLETE:String = "initComplete";
		public static var ACCESS_GRANTED:String = "accessGranted";
		public static var ACCESS_FAILED:String = "accessFailed";
		public static var UPLOAD_FAILED:String = "uploadFailed";
		public static var UPLOAD_COMPLETE:String = "uploadComplete";
		
		public function TwitterServiceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
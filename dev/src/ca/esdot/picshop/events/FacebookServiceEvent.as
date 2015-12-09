package ca.esdot.picshop.events
{
	import flash.events.Event;
	
	public class FacebookServiceEvent extends Event
	{
		
		public static var LOGIN_COMPLETE:String = "loginComplete";
		public static var LOGIN_FAILED:String = "loginFailed";
		public static var LOGIN_CANCELED:String = "loginCanceled";
		
		public static var ALBUMS_LOADED:String = "albumsLoaded";
		public static var ALBUMS_FAILED:String = "albumsFailed";
		
		public static var PHOTOS_LOADED:String = "photosLoaded";
		public static var PHOTOS_FAILED:String = "photosFailed";
		
		public static var HI_RES_PHOTO_LOADED:String = "hiResPhotoLoaded";
		public static var HI_RES_PHOTO_FAILED:String = "hiResPhotoFailed";
		
		public static var POST_PHOTO_COMPLETE:String = "postPhotoComplete";
		public static var POST_PHOTO_FAILED:String = "postPhotoFailed";
		
		public var data:Object;
		
		public function FacebookServiceEvent(type:String, data:Object = null, bubbles:Boolean=false, cancelable:Boolean=false) {
			this.data = data;
			super(type, bubbles, cancelable);
		}
	}
}
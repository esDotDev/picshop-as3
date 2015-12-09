package ca.esdot.picshop.commands.events
{
	import flash.events.Event;
	
	public class CommandEvent extends Event
	{
		public static var OPEN_FRAMESHOP_LINK:String = "openFrameShopLink";
		public static var OPEN_PURCHASE_LINK:String = "openPurchaseLink";
		public static var OPEN_REVIEW_LINK:String = "openReviewLink";
		public static var SHOW_INTRO_VIDEO:String = "showIntroVideo";
		public static var PROMPT_FOR_REVIEW:String = "promptForReview";
		
		public static var IN_APP_PURCHASE:String = "inAppPurchase";
		public static var IN_APP_RESTORE:String = "inAppRestore";
		
		public static var SHOW_VERSION_DIALOG:String = "showVersionDialog";
		public static var RESIZE_APP:String = "resizeApp";
		public static var ADD_IMAGE_LAYER:String = "addImage";
		public static var SHOW_OFFERWALL:String = "showOfferwall";
		
		public var data:Object;
		
		public function CommandEvent(type:String, data:Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.data = data;
			super(type, bubbles, cancelable);
		}
	}
}
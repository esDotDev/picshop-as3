package ca.esdot.picshop.utils
{
	import ca.esdot.lib.net.AnalyticsTracker;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.MainModel;
	
	import flash.display.Stage;
	import flash.events.EventDispatcher;

	public class AnalyticsManager
	{
		protected static var tracker:AnalyticsTracker;
		protected static var device:String;
		protected static var version:Object;
		
		public static function init(stage:Stage, trial:Boolean):void {
			AnalyticsManager.tracker = new AnalyticsTracker(stage, false);
			
			device = DeviceUtils.deviceName;
			version = trial? "Trial" : "Paid";
		}
		
		public static function firstInstall():void {
			tracker.event("Install", version + ": " + device, device);  	
		}
		
		public static function frameShopDownload(accepted:Boolean = false):void {
			tracker.event("Download-Frameshop", accepted? "yes" : "no");   	
		}
		
		public static function upgradePurchased():void {
			tracker.event("Install", "IAP" + ": " + device, device);  	
		}
		
		public static function upgradeFailed():void {
			tracker.event("Error", "IAP Failed" + ": " + device, device);  	
		}
		
		public static function startup():void {
			tracker.event("StartUp", version + ": " + device, device);  	
		}
		
		public static function imageSaved():void {
			tracker.event("Save", version + ": " + device, device);  	
		}
		
		public static function imageOpened():void {
			tracker.event("Image Opened", version + ": " + device, device);  	
		}
		
		public static function imageShared():void {
			tracker.event("Share", version + ": " + device, device);  	
		}
		
		public static function pageView(value:String):void {
			tracker.pageView(value);  	
		}
	}
}
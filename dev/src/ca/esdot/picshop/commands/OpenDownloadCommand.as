package ca.esdot.picshop.commands
{
	import flash.desktop.NativeApplication;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import ca.esdot.lib.payments.InAppPurchaseEvent;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.commands.events.CommandEvent;
	
	import org.robotlegs.mvcs.Command;

	
	public class OpenDownloadCommand extends Command
	{
		public static var iosID:String = "502430343";
		
		[Inject]
		public var appModel:MainModel;
		
		[Inject]
		public var event:CommandEvent;
		
		override public function execute():void {
			
			var url:String;
			
			if(event.type == CommandEvent.OPEN_FRAMESHOP_LINK){
				url = DeviceUtils.getAndroidMarketURL("ca.esdot.FrameShop.Lite");
				if(DeviceUtils.onIOS){
					url = DeviceUtils.getITunesMarketURL("807366225")
				} else if(DeviceUtils.onPlayBook){
					url = DeviceUtils.getPlayBookMarketURL("47523890");
					
				} else if(DeviceUtils.onBB10){
					//invokeBB10("47523890");
					return; 
					
				} else if(DeviceUtils.onAmazon){
					url = DeviceUtils.getAmazonMarketURL("ca.esdot.FrameShop.Lite");
				}
			} else {
				
				/**
				 * All other devices will kick out to their respective market's.
				 * Includes legacy support for iOS
				 **/
				if(PicShop.FULL_VERSION || event.type == CommandEvent.OPEN_PURCHASE_LINK){
					url = DeviceUtils.getAndroidMarketURL("ca.esdot.PicShop");
					if(DeviceUtils.onIOS){
						url = DeviceUtils.getITunesMarketURL(iosID)
					} else if(DeviceUtils.onPlayBook){
						url = DeviceUtils.getPlayBookMarketURL("87956");
						
					} else if(DeviceUtils.onBB10){
						//invokeBB10("87956");
						return; 
						
					} else if(DeviceUtils.onAmazon){
						url = DeviceUtils.getAmazonMarketURL("ca.esdot.PicShop");
					}
				}
				else {
					url = DeviceUtils.getAndroidMarketURL("ca.esdot.PicShop.Lite");
					if(DeviceUtils.onIOS){
						url = DeviceUtils.getITunesMarketURL("505766376")
					} else if(DeviceUtils.onPlayBook){
						url = DeviceUtils.getPlayBookMarketURL("92432");
					} else if(DeviceUtils.onBB10){
						//invokeBB10("92432");
						return; 
						
					} else if(DeviceUtils.onAmazon){
						url = DeviceUtils.getAmazonMarketURL("ca.esdot.PicShop.Lite");
					}
				}
				
				try {
					navigateToURL(new URLRequest(url));
					//NativeApplication.nativeApplication.exit();
				} catch(e:Error){ trace("[OpenDownloadCommand] Unable to openMarketLink on Desktop"); }
			}
			
		}
		
	}
}
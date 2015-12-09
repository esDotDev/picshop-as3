package ca.esdot.picshop.services
{
	/*
	import com.tapjoy.extensions.ITapjoyConnectRequestCallback;
	import com.tapjoy.extensions.TapjoyAIR;
	import com.tapjoy.extensions.TapjoyDisplayAdEvent;
	import com.tapjoy.extensions.TapjoyEvent;
	import com.tapjoy.extensions.TapjoyMacAddressOption;
	import com.tapjoy.extensions.TapjoyPointsEvent;
	import com.tapjoy.extensions.TapjoyTransition;
	import com.tapjoy.extensions.TapjoyViewChangedEvent;
	
	import flash.events.Event;
	import flash.system.Capabilities;
	
	import ca.esdot.picshop.MainModel;
	
	import org.robotlegs.mvcs.Actor;

	public class TapjoyService extends Actor implements ITapjoyConnectRequestCallback
	{
		public static var isSupported:Boolean;

		protected var extension:TapjoyAIR;
		protected var isAndroid:Boolean;
		
		[Inject]
		public var mainModel:MainModel;
		
		public function TapjoyService(){
			init();
		}
		
		public function init():void {
			
			var connectFlags:Object = { };
			if (Capabilities.manufacturer.search("iOS") != -1)
			{
				// iOS platform
				// If you are not using Tapjoy Managed currency, you would set your own user ID here.
				//  connectFlags["TJC_OPTION_USER_ID"] ="A_UNIQUE_USER_ID";
				
				// You can also set your event segmentation parameters here.
				//  var segmentationParams:Object = { "iap": true }
				//  connectFlags["TJC_OPTION_SEGMENTATION_PARAMS"] = segmentationParams;
				
				// Enable logging
				connectFlags["TJC_OPTION_ENABLE_LOGGING"] = true;
				
				// Pass option to toggle the collection of MAC address
				connectFlags["TJC_OPTION_COLLECT_MAC_ADDRESS"] = TapjoyMacAddressOption.MacAddressOptionOffWithVersionCheck;
				
				TapjoyAIR.requestTapjoyConnect("2c7dd3ef-22fc-4f9c-af70-5437b13e3ba4", "8To93Dvj0vNEDZFuwKJE", connectFlags, this);
			}
			else
			{
				// Android platform
				
				// If you are not using Tapjoy Managed currency, you would set your own user ID here.
				//  connectFlags["user_id"] ="esdot";
				
				// You can also set your event segmentation parameters here.
				//  var segmentationParams:Object = { "iap": true }
				//  connectFlags["segmentation_params"] = segmentationParams;
				
				// Enable logging
				connectFlags["enable_logging"] = true;
				
				TapjoyAIR.requestTapjoyConnect("2c7dd3ef-22fc-4f9c-af70-5437b13e3ba4", "8To93Dvj0vNEDZFuwKJE", connectFlags, this);
				isAndroid = true;
			}
		}
		
		public function showOfferwall():void {
			extension.showOffers();
		}
		
		public function connectSucceeded():void {
			trace("Tapjoy Sample App - Tapjoy Connect SUCCEEDED");
			
			extension = TapjoyAIR.getTapjoyConnectInstance();
			// SDK is enabled
			isSupported = true;
			
			// Event listeners for Views opening/closing
			
			//extension.addEventListener(TapjoyViewChangedEvent.TJ_VIEW_OPENING, tapViewChangedEvents);
			//extension.addEventListener(TapjoyViewChangedEvent.TJ_VIEW_OPENED, tapViewChangedEvents);
			
			extension.addEventListener(TapjoyViewChangedEvent.TJ_VIEW_CLOSING, onTapViewClosing);
			//extension.addEventListener(TapjoyViewChangedEvent.TJ_VIEW_CLOSED, tapViewChangedEvents);
			
			// Event listeners for get/award/spend points.
			extension.addEventListener(TapjoyPointsEvent.TJ_TAP_POINTS, tapPointsEvents);
			extension.addEventListener(TapjoyEvent.TJ_TAP_POINTS_FAILED, tapEvents);
			extension.addEventListener(TapjoyPointsEvent.TJ_SPENT_TAP_POINTS, tapPointsEvents);
			extension.addEventListener(TapjoyEvent.TJ_SPENT_TAP_POINTS_FAILED, tapEvents);
			extension.addEventListener(TapjoyPointsEvent.TJ_AWARDED_TAP_POINTS, tapPointsEvents);
			extension.addEventListener(TapjoyEvent.TJ_AWARDED_TAP_POINTS_FAILED, tapEvents);
			
			// Event listener for earned points.
			extension.addEventListener(TapjoyEvent.TJ_EARNED_TAP_POINTS, tapEvents);
			
			// Event listener for show offers (only triggered on iOS).
			extension.addEventListener(TapjoyEvent.TJ_SHOW_OFFERWALL_FAILED, tapEvents);
			
			extension.getTapPoints();
			
		}
		
		public function connectFailed():void {
			trace("Tapjoy Sample App - Tapjoy Connect FAILED");	
		}
		
		protected function onTapViewClosing(event:Event):void {
			extension.getTapPoints();
		}
		
		protected function tapEvents(event:TapjoyEvent):void {
			trace("Tapjoy Sample App - event listener for ", event.type, ", ", event.value);
			switch (event.type)
			{
				case TapjoyEvent.TJ_EARNED_TAP_POINTS:
					trace("Tapjoy Sample App - You can notify user's here that they've just earned ", event.value, " points");
					mainModel.numCoins += int(event.value);
					break;
			}
		}
		
		protected function tapPointsEvents(event:TapjoyPointsEvent):void {
			trace("Tapjoy Sample App - event listener for ", event.type, ", ", event.pointTotal, ", ", event.currencyName);
			//mainModel.numCoins = event.pointTotal;
		}
		
		public function spendPoints(value:int):void {
			//extension.spendTapPoints(value);
		}
		
	}
	*/
}
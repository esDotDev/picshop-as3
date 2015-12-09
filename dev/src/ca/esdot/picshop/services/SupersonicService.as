package ca.esdot.picshop.services
{
	import com.supersonic.air.SupersonicEvent;
	import com.supersonic.air.SupersonicManager;
	
	import flash.system.Capabilities;
	import flash.utils.Dictionary;
	
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.commands.events.SettingsEvent;
	
	import org.osflash.signals.Signal;
	import org.robotlegs.mvcs.Actor;
	
	public class SupersonicService extends Actor 
	{
		/*
		- InitComplete event would be nice, or at least a SuperSoniceManager.canShowOfferwall property.
		- OW_SHOW_FAIL_EVENT doesn't seem to be firing when debugging on desktop
		- Testing mode behaves differently than production, when testing 
		*/
		
		public static var isSupported:Boolean;
		
		[Inject]
		public var mainModel:MainModel;
		
		protected var offerwallOpts:Dictionary;
		
		public var creditsEarned:Signal = new Signal(int);
		public var offerwallOpened:Signal = new Signal();
		public var offerwallClosed:Signal = new Signal();
		public var offerwallFailed:Signal = new Signal();
		
		protected function get manager():SupersonicManager { return SupersonicManager.getInstance; }
		
		public function SupersonicService(){
			init();
		}
		public function init():void {
			try {
				manager.Init(); 
				manager.addEventListener( SupersonicManager.OW_AD_CREDITED_EVENT, OWAdCredited );
				manager.addEventListener( SupersonicManager.OW_AD_CREDITED_FAILED_EVENT, OWAdCreditedFailed);
				manager.addEventListener( SupersonicManager.OW_SHOW_FAIL_EVENT, OWShowFail);
				manager.addEventListener( SupersonicManager.OW_SHOW_SUCCESS_EVENT, OWShowSuccess);
				manager.addEventListener( SupersonicManager.OW_DID_CLOSE_EVENT, OWDidClose);
				isSupported = true;
			} catch(e:Error) {
				isSupported = false;
			}
		}
		
		public function get AppKey():String {
			return DeviceUtils.onIOS? "3ca41c79" : "3ca45601";
		}
		
		public function showOfferwall():void {
			offerwallOpts = new Dictionary();
			offerwallOpts["useClientSideCallbacks"] = true;
			offerwallOpts["language"] = Capabilities.language;
			manager.showOfferWall(AppKey, 
				mainModel.settings.userId, offerwallOpts);
		}
		
		protected function OWAdCredited(event:SupersonicEvent):void {
			trace("[SuperSonicService] Credited");
			mainModel.numCoins += int(event.messageArray["credits"]);
			dispatch(new SettingsEvent(SettingsEvent.SAVE));
		}
		
		protected function OWAdCreditedFailed(event:SupersonicEvent):void {
			trace("[SuperSonicService] Failed Credit");
		}
		
		protected function OWShowFail(event:SupersonicEvent):void {
			trace("[SuperSonicService] Failed Show");
			offerwallFailed.dispatch();
		}
		
		protected function OWShowSuccess(event:SupersonicEvent):void {
			trace("[SuperSonicService] Show!");
			offerwallOpened.dispatch();
		}
		
		protected function OWDidClose(event:SupersonicEvent):void {
			trace("[SuperSonicService] Closed");
			offerwallClosed.dispatch();
		}
		
		
	}
}
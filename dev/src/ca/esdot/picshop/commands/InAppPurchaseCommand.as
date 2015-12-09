package ca.esdot.picshop.commands
{
	import com.milkmangames.nativeextensions.android.AndroidIAB;
	import com.milkmangames.nativeextensions.ios.StoreKit;
	
	import flash.events.Event;
	import flash.system.Capabilities;
	
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.commands.events.CommandEvent;
	import ca.esdot.picshop.data.Strings;
	import ca.esdot.picshop.data.UnlockableFeatures;
	import ca.esdot.picshop.dialogs.TitleDialog;
	import ca.esdot.picshop.services.AndroidPurchaseService;
	import ca.esdot.picshop.services.IOSPurchaseService;
	import ca.esdot.picshop.utils.AnalyticsManager;
	
	import org.robotlegs.mvcs.Command;
	
	public class InAppPurchaseCommand extends Command
	{
		[Inject]
		public var mainModel:MainModel;
		
		[Inject]
		public var androidService:AndroidPurchaseService;
		
		[Inject]
		public var iosService:IOSPurchaseService;
		
		[Inject]
		public var event:CommandEvent;
		
		public var mainView:MainView;
		
		/* BB10 Platform
		protected var paymentSystem:PaymentSystem;
		*/
		
		override public function execute():void {
			mainView = (contextView as MainView);
			
			if (AndroidIAB.isSupported()){
				commandMap.detain(this);
				mainView.isLoading = true;
				
				androidService.onComplete.add(onPurchaseSuccess);
				androidService.onError.add(onPurchaseFailed);
				androidService.onCancel.add(onPurchaseCancelled);
				
				//if(Capabilities.isDebugger){
				//	androidService.purchase(AndroidPurchaseService.ANDROID_TEST_ID);	
				//} else {
					if(event.data == UnlockableFeatures.FULL_UNLOCK){
						androidService.purchase(AndroidPurchaseService.FULL_UNLOCK_ID);	
					}
					if(event.data == UnlockableFeatures.EXTRAS){
						androidService.purchase(AndroidPurchaseService.UNLOCK_EXTRAS_ID);	
					}
					else if(event.data == UnlockableFeatures.FRAMES){
						androidService.purchase(AndroidPurchaseService.UNLOCK_FRAMES_ID);	
					}
					else if(event.data == UnlockableFeatures.FILTERS){
						androidService.purchase(AndroidPurchaseService.UNLOCK_FILTERS_ID);	
					}
				//}
				
				
			}
			else if(StoreKit.isSupported()){
				
				commandMap.detain(this);
				mainView.isLoading = true;
				
				iosService.onComplete.add(onPurchaseSuccess);
				iosService.onError.add(onPurchaseFailed);
				iosService.onCancel.add(onPurchaseCancelled);
				iosService.purchase(IOSPurchaseService.UNLOCK_ID);
			} 
			else if(Capabilities.isDebugger){
				mainModel.isAppLocked = false;
			}
		}
		/* BB10 Platform
		protected function onBB10Success(event:PaymentSuccessEvent = null):void {
			mainModel.isAppLocked = false;
			onPurchaseSuccess();
		}
		*/
		
		/********************
		 * COMPLETE HANDLERS
		 ********************/
		
		protected function onPurchaseFailed(event:Event = null):void {
			
			/* BB10 Platform
			if(event is PaymentErrorEvent){
				var bb10Event:PaymentErrorEvent = event as PaymentErrorEvent;
				if(bb10Event.errorID == 5){
					onBB10Success();
					return;
				}
			}
			*/
			
			var dialog:TitleDialog = new TitleDialog(DeviceUtils.dialogWidth, DeviceUtils.dialogHeight, "Problem", "There was a problem with the In App Upgrade. Would you like to download the full version instead?");
			dialog.setButtons([Strings.CANCEL, Strings.OK]);
			dialog.addEventListener(ButtonEvent.CLICKED, function(event:ButtonEvent){
				DialogManager.addDialog(dialog, true);
				if(event.label == Strings.OK){
					dispatch(new CommandEvent(CommandEvent.OPEN_PURCHASE_LINK));
				}
				releaseCommand();
			});
			DialogManager.addDialog(dialog);
			//ANALYTICS
			AnalyticsManager.upgradeFailed();
		}
		
		protected function onPurchaseSuccess(event:Event = null):void {
			var dialog:TitleDialog = new TitleDialog(DeviceUtils.dialogWidth, DeviceUtils.dialogHeight, "Purchase Complete", "Thanks for choosing PicShop, don't forget to rate the app!");
			dialog.setButtons([Strings.OK]);
			dialog.addEventListener(ButtonEvent.CLICKED, releaseCommand, false, 0, true);
			DialogManager.addDialog(dialog, true);
			
			
			AnalyticsManager.upgradePurchased();
		}
		
		protected function onPurchaseCancelled(event:Event = null):void {
			releaseCommand();
		}
		
		protected function releaseCommand(event:Event = null):void {
			DialogManager.removeDialogs();
			commandMap.release(this);
			mainView.isLoading = false;
			
			androidService.onComplete.removeAll();
			androidService.onError.removeAll();
			androidService.onCancel.removeAll();
			
		}
	}
}
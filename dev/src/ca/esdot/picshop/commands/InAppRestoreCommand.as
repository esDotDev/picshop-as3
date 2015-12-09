package ca.esdot.picshop.commands
{
	
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.commands.events.CommandEvent;
	import ca.esdot.picshop.services.AndroidPurchaseService;
	import ca.esdot.picshop.services.IOSPurchaseService;
	
	/* BB10 Platform
	import net.rim.blackberry.events.PaymentErrorEvent;
	import net.rim.blackberry.events.PaymentSuccessEvent;
	import net.rim.blackberry.payment.PaymentSystem;
	*/
	
	import org.robotlegs.mvcs.Command;
	
	public class InAppRestoreCommand extends Command
	{
		[Inject]
		public var event:CommandEvent;
		
		[Inject]
		public var androidService:AndroidPurchaseService;
		
		[Inject]
		public var iOSService:IOSPurchaseService;
		
		[Inject]
		public var mainModel:MainModel;
		
		protected var ignoreErrors:Boolean;
		/* BB10 Platform
		protected var paymentSystem:PaymentSystem;
		*/
		protected var mainView:MainView;
		
		override public function execute():void {
			trace("Restoring purchases...");
			ignoreErrors = event.data == true;
			mainView = (contextView as MainView);
			
			if(DeviceUtils.onIOS){
				iOSService.onError.add(onError);
				iOSService.onComplete.add(onComplete);
				iOSService.onCancel.add(onCancel);
				(contextView as MainView).isLoading = true;
				commandMap.detain(this);
				
				iOSService.restorePurchases();
				
			} else if(DeviceUtils.onAndroid) {
				androidService.onError.add(onError);
				androidService.onComplete.add(onComplete);
				iOSService.onCancel.add(onCancel);
				(contextView as MainView).isLoading = true;
				commandMap.detain(this);
				
				androidService.restorePurchases();
				
			} 
			else if(!ignoreErrors){
				DialogManager.alert("Error", "Unable to restore transactions on this Device.");
			}
			
		}
		
		/* BB10 Platform
		protected function onBB10Failed(event:PaymentErrorEvent):void {
			mainView.isLoading = false;
			onError();
		}
		
		protected function onBB10Success(event:PaymentSuccessEvent):void {
			if(event.subscriptionExists){
				mainModel.isAppLocked = false;
				mainView.isLoading = false;
			}
		}
		*/
		
		protected function onError():void {
			if(!ignoreErrors){
				DialogManager.alert("Error", "Unable to restore transactions...");
			}
			releaseCommand();
		}
		
		protected function onCancel():void {
			releaseCommand();
		}
		
		protected function onComplete():void {
			releaseCommand();
		}
		
		protected function releaseCommand():void {
			iOSService.onError.removeAll();
			iOSService.onComplete.removeAll();
			
			androidService.onError.removeAll();
			androidService.onComplete.removeAll();
			
			(contextView as MainView).isLoading = false;
			commandMap.release(this);
		}
	}
}
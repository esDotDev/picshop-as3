package ca.esdot.picshop.services
{
	import com.milkmangames.nativeextensions.android.AndroidIAB;
	import com.milkmangames.nativeextensions.android.AndroidPurchase;
	import com.milkmangames.nativeextensions.android.events.AndroidBillingErrorEvent;
	import com.milkmangames.nativeextensions.android.events.AndroidBillingEvent;
	
	import flash.events.Event;
	
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.data.UnlockableFeatures;
	
	import org.osflash.signals.Signal;
	import org.robotlegs.mvcs.Actor;
	
	public class AndroidPurchaseService extends Actor
	{
		[Inject]
		public var mainModel:MainModel;
		
		public static var FULL_UNLOCK_ID:String = "full_unlock";
		public static var UNLOCK_EXTRAS_ID:String = "unlock_extras";
		public static var UNLOCK_FILTERS_ID:String = "unlock_filters";
		public static var UNLOCK_FRAMES_ID:String = "unlock_frames";
		public static var ANDROID_TEST_ID:String = "android.test.purchased";
		
		public var key:String = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAiDGSE2aZPizwBnFHYUWrIf7fCle1AYaTh6n9nmb9IZkucAAQMlgok4J0iCOmIwscHYqKF2SqvJWVombyQtBeGIghEr8Lewn4wVVxuZDM+pr82DlcPVetQYYxFymScnx0guT8GhfJfn7Hdq6yxBNZf0CQfEDswjt2XHVXndLXjZEtR4LIuiW3s+FU0uMMAZ+BoO8ilB8vdwUE7uEaGl2veqfFcOFmJRkJP5RGEcNQVLa3/rosaT9bW0aD05vQKbQ6sLwhVTKV6GFaL/st7IhDIV6cR+op8Vfs6NUWWUCSCUdicseBDbfDCiT76qCpNDEmKv287hg/alqQ6U+9mSq30wIDAQAB"
		
		public var onComplete:Signal;
		public var onError:Signal;
		public var onCancel:Signal;
		
		public var isReady:Boolean;
		public var restoreWhenReady:Object;
		
		public function AndroidPurchaseService(){
			super();
			
			onComplete = new Signal();
			onError = new Signal();
			onCancel = new Signal();
		}
		
		public function init():void {
			AndroidIAB.create();
			
			// billing service ready listeners
			AndroidIAB.androidIAB.addEventListener(AndroidBillingEvent.SERVICE_READY,onAndroidReady, false, 0, true);
			AndroidIAB.androidIAB.addEventListener(AndroidBillingEvent.SERVICE_NOT_SUPPORTED,onPurchaseFailed, false, 0, true);
			
			// purchase listeners
			AndroidIAB.androidIAB.addEventListener(AndroidBillingEvent.PURCHASE_SUCCEEDED,onPurchaseSuccess, false, 0, true);
			AndroidIAB.androidIAB.addEventListener(AndroidBillingEvent.INVENTORY_LOADED, onInventoryLoaded, false, 0, true);
			//AndroidIAB.androidIAB.addEventListener(AndroidBillingEvent.PURCHASE_REFUNDED,onPurchaseRefunded);
			//AndroidIAB.androidIAB.addEventListener(AndroidBillingEvent.PURCHASE_CANCELLED,onPurchaseCancelled, false, 0, true);
			AndroidIAB.androidIAB.addEventListener(AndroidBillingErrorEvent.PURCHASE_FAILED,onPurchaseFailed, false, 0, true);
			AndroidIAB.androidIAB.addEventListener(AndroidBillingErrorEvent.LOAD_INVENTORY_FAILED,onTransactionsRestoreFailed, false, 0, true);
			//AndroidIAB.androidIAB.addEventListener(AndroidBillingEvent.TRANSACTIONS_RESTORED,onPurchaseSuccess, false, 0, true);
			
			AndroidIAB.androidIAB.startBillingService(key);
			
		}
		
		public function purchase(id:String):void {
			if(!isReady){ onError.dispatch(); return; }
			AndroidIAB.androidIAB.purchaseItem(id);
		}
		
		public function restorePurchases():void {
			if(!isReady){ onError.dispatch(); return; }
			AndroidIAB.androidIAB.loadPlayerInventory();
		}
		
		
		public function onTransactionsRestoreFailed(event:*):void {
			onError.dispatch();
		}
		
		protected function onAndroidReady(event:Event):void {
			isReady = true;
			if(restoreWhenReady){
				restorePurchases();
			}
		}
		
		protected function onPurchaseFailed(event:*):void {
			onError.dispatch();
			
		}
		
		protected function onInventoryLoaded(e:AndroidBillingEvent):void {
			for each(var purchase:AndroidPurchase in e.purchases){
				unlockItem(purchase.itemId);
			}
		}
		
		protected function onPurchaseSuccess(event:AndroidBillingEvent):void {
			onComplete.dispatch();
			unlockItem(event.itemId);
		}
		
		protected function unlockItem(itemId:String):void {
			switch(itemId){
				
				case FULL_UNLOCK_ID:
				//case ANDROID_TEST_ID:
					mainModel.isAppLocked = false;
					break;
				
				case UNLOCK_EXTRAS_ID:
					mainModel.unlockFeature(UnlockableFeatures.EXTRAS);
					break;
				
				case UNLOCK_FILTERS_ID:
					mainModel.unlockFeature(UnlockableFeatures.FILTERS);
					break;
				
				case UNLOCK_FRAMES_ID:
					mainModel.unlockFeature(UnlockableFeatures.FRAMES);
					break;
			}
		}
		
		protected function onPurchaseCancelled(event:*):void {
			onCancel.dispatch();
		}
	}
}
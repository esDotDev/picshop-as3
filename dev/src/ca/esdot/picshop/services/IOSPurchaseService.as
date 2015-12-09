package ca.esdot.picshop.services
{
	import ca.esdot.picshop.MainModel;
	
	import com.milkmangames.nativeextensions.ios.StoreKit;
	import com.milkmangames.nativeextensions.ios.StoreKitProduct;
	import com.milkmangames.nativeextensions.ios.events.StoreKitErrorEvent;
	import com.milkmangames.nativeextensions.ios.events.StoreKitEvent;
	
	import org.osflash.signals.Signal;
	import org.robotlegs.mvcs.Actor;
	
	public class IOSPurchaseService extends Actor
	{
		public static var UNLOCK_ID:String = "ca.esdot.PicShop.Lite.Unlock";
		
		[Inject]
		public var mainModel:MainModel;
		
		public var onComplete:Signal;
		public var onError:Signal;
		public var onCancel:Signal;
		
		public var isReady:Boolean;
		
		public function IOSPurchaseService(){
			super();
			
			onComplete = new Signal();
			onError = new Signal();
			onCancel = new Signal();
		}
		
		public function init(productIdList:Vector.<String>):void {
			StoreKit.create();
			
			// Listen for events.
			//StoreKit.storeKit.addEventListener(StoreKitEvent.PRODUCT_DETAILS_LOADED,onProductsLoaded2);
			StoreKit.storeKit.addEventListener(StoreKitEvent.PURCHASE_SUCCEEDED,onPurchaseSuccess);
			StoreKit.storeKit.addEventListener(StoreKitEvent.PURCHASE_CANCELLED,onPurchaseCancelled);
			StoreKit.storeKit.addEventListener(StoreKitEvent.TRANSACTIONS_RESTORED,onTransactionsRestored);
			// adding error events. always listen for these to avoid your program failing.
			StoreKit.storeKit.addEventListener(StoreKitErrorEvent.PRODUCT_DETAILS_FAILED,onPurchaseFailed);
			StoreKit.storeKit.addEventListener(StoreKitErrorEvent.PURCHASE_FAILED,onPurchaseFailed);
			//StoreKit.storeKit.addEventListener(StoreKitErrorEvent.TRANSACTION_RESTORE_FAILED,onTransactionRestoreFailed);
			
			if(!isAvailable){ return; }
			
			StoreKit.storeKit.loadProductDetails(productIdList);
		}
		
		protected function onTransactionsRestored(event:StoreKitEvent):void {
			mainModel.settings.isPromo = false;
			mainModel.isAppLocked = false;
		}
		
		protected function get isAvailable():Boolean {
			return StoreKit.storeKit.isStoreKitAvailable();
		}
		
		public function purchase(id:String):void {
			if(!isAvailable){ return; }
			
			StoreKit.storeKit.purchaseProduct(id);
		}
		
		public function restorePurchases():void {
			if(!isAvailable){ return; }
			
			StoreKit.storeKit.restoreTransactions();
		}
		
		protected function onPurchaseFailed(event:StoreKitErrorEvent):void {
			onError.dispatch();
		}
		
		protected function onPurchaseSuccess(event:StoreKitEvent):void {
			onComplete.dispatch();
			mainModel.settings.isPromo = false;
			mainModel.isAppLocked = false;
		}
		
		protected function onPurchaseCancelled(event:StoreKitEvent):void {
			onCancel.dispatch();
		}
	}
}
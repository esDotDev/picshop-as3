package ca.esdot.lib.payments
{
	import com.adobe.nativeExtensions.AppPurchase;
	import com.adobe.nativeExtensions.AppPurchaseEvent;
	import com.adobe.nativeExtensions.Transaction;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;

	public class InAppPurchase extends EventDispatcher
	{
		protected var extension:AppPurchase = AppPurchase.manager;
		
		public function InAppPurchase(){
			extension.addEventListener(AppPurchaseEvent.UPDATED_TRANSACTIONS, onUpdate);
			extension.addEventListener(AppPurchaseEvent.RESTORE_FAILED, onRestoreFailed, false, 0, true);
			extension.addEventListener(AppPurchaseEvent.RESTORE_COMPLETE, onRestoreComplete, false, 0, true);
			extension.addEventListener(AppPurchaseEvent.REMOVED_TRANSACTIONS, onRemovedTransactions, false, 0, true);
			extension.addEventListener(AppPurchaseEvent.PRODUCTS_RECEIVED,onProducts);
		}
		
		public function getProducts(ids:Array):void {
			extension.getProducts(ids);
		}
		
		public function restorePurchases():void {
			extension.restoreTransactions();
		}
		
		protected function onRemovedTransactions(event:AppPurchaseEvent):void{
			for each(var t:Transaction in event.transactions){
				trace ("[InAppPurchase] Removed: " + t.transactionIdentifier);
			}
			dispatchEvent(event);
		}

		protected function onRestoreComplete(event:AppPurchaseEvent):void{
			dispatchEvent(event);
		}
		
		protected function onRestoreFailed(event:AppPurchaseEvent):void{
			trace("[InAppPurchase] Failed to restore transactions :( ");
			dispatchEvent(event);
		}
		
		protected function onProducts(event:AppPurchaseEvent):void{
			trace("Products retrieved...", event.products);
			if(event.products){
				for(var i:int = 0; i < event.products.length; i++){ // Products received populate the list
					trace("[InAppPurchase] VALID: ", event.products[i]);
				}
			}
			for each(var s:String in event.invalidIdentifiers){ // List of ids for which products could not be retrieved.
				trace("[InAppPurchase] INVALID: ", s);
			}
			dispatchEvent(event);
		}
		
		protected function onUpdate(event:AppPurchaseEvent):void{
			for each(var t:Transaction in event.transactions){ // Iterate over transactions whose status changed
				trace("[InAppPurchase] State: ", t.state);
				if(t.state == Transaction.TRANSACTION_STATE_PUCHASED){
					// Verify that this receipt came from apple and is not forged
					var req:URLRequest = new URLRequest("https://sandbox.itunes.apple.com/verifyReceipt");
					req.method = URLRequestMethod.POST;
					req.data = "{\"receipt-data\" : \""+ t.receipt +"\"}";
					var ldr:URLLoader = new URLLoader(req);
					ldr.load(req);
					ldr.addEventListener(Event.COMPLETE,function(e:Event):void{
						trace("[InAppPurchase] LOAD COMPLETE: " + ldr.data); // status property in retrieved JSON is 0 then success
						
						// Provide the purchased functionality/service/product/subscription to user.
						AppPurchase.manager.finishTransaction(t.transactionIdentifier); // Finish the transaction completely
						dispatchEvent(new InAppPurchaseEvent(InAppPurchaseEvent.PURCHASE_COMPLETE, t.productIdentifier));
					});
				} else if(t.state == Transaction.TRANSACTION_STATE_RESTORED){
					// Useful for restoring Non-Consumable purchases made by user. Read programming guide for more details.
					if(t.originalTransaction.state == Transaction.TRANSACTION_STATE_PUCHASED){
						trace("[InAppPurchase] Restored Transaction Finish on " + t.transactionIdentifier);
						
						AppPurchase.manager.finishTransaction(t.originalTransaction.transactionIdentifier);
						dispatchEvent(new InAppPurchaseEvent(InAppPurchaseEvent.PURCHASE_COMPLETE, t.productIdentifier));
					}
				} else if(t.state == Transaction.TRANSACTION_STATE_FAILED){
					dispatchEvent(new InAppPurchaseEvent(InAppPurchaseEvent.PURCHASE_FAILED, t.productIdentifier));
				}
			}
			dispatchEvent(event);
		}
		
		public function purchase(id:String, quantity:int = 1):void {
			extension.startPayment(id, quantity);
		}
	}
}
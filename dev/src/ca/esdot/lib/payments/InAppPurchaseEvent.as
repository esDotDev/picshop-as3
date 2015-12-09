
package ca.esdot.lib.payments
{
	import flash.events.Event;
	
	public class InAppPurchaseEvent extends Event
	{
		public static const PURCHASE_COMPLETE:String = "purchaseComplete";
		public static const PURCHASE_FAILED:String = "purchaseFailed";
		
		public var id:String;
		
		public function InAppPurchaseEvent(type:String, id:String = "", bubbles:Boolean=false, cancelable:Boolean=false) {
			this.id = id;
			super(type, bubbles, cancelable);
		}
	}
}
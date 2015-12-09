package ca.esdot.picshop.events
{
	import flash.events.Event;
	
	public class ModelEvent extends Event
	{
		public static var VIEW_CHANGED:String = "viewChanged";
		public static var SOURCE_CHANGED:String = "sourceChanged";
		public static var HISTORY_INDEX_CHANGED:String = "historyIndexChanged";
		public static var BACK:String = "back";
		
		public static var APP_UNLOCKED:String = "appUnlocked";
		
		public static var FILTERS_UNLOCKED:String = "filtersUnlocked";
		public static var FRAMES_UNLOCKED:String = "framesUnlocked";
		public static var EXTRAS_UNLOCKED:String = "extrasUnlocked";
		public static var COINS_ADDED:String = "coinsAdded";
		public static var COINS_REMOVED:String = "coinsRemoved";
		
		public function ModelEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
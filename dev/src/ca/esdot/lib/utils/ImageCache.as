package ca.esdot.lib.utils
{
	import ca.esdot.lib.components.Image;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.utils.Dictionary;

	public class ImageCache
	{
		protected static var poolList:Dictionary = new Dictionary();
		
		protected var pool:Object;
		
		public function init():void {
			if(pool){
				delete poolList[pool];
			}
			pool = {};
			poolList[pool] = pool;
		}
		
		public function addImage(bitmapData:BitmapData, url:String):void {
			if(!pool){ init(); }
			pool[url] = bitmapData;
		}
		
		public function getImage(url:String):BitmapData {
			if(!pool){ init(); }
			//Is the bitmapData in this pool?
			var bmpData:BitmapData = pool[url];
			if(bmpData == null){
				//If not, is it any other pools?
				for (var otherPool:Object in poolList) {
					if(poolList[otherPool][url]){
						//Yes, we found the image, add to this pool
						pool[url] = bmpData;
						bmpData = poolList[otherPool][url];
						break;
					}
				}
			}
			return bmpData;
		}
		
		public function dispose():void {
			var safeToDispose:Boolean;
			for(var p:String in pool){
				safeToDispose = true;
				//Is this image being used in any other pools
				for (var otherPool:Object in poolList) {
					if(otherPool != pool && poolList[otherPool][p]){
						safeToDispose = false;
						break;
					}
				}
				//Dispose if it's not being used anywhere else
				if(safeToDispose && pool[p] is BitmapData){
					//[SB] This implementation is not working properly, not sure why.
					//disable for now these will get reclaimed eventually anyways.
					//(pool[p] as BitmapData).dispose();
					delete pool[p];
				}
			}
			//Delete pool object.
			delete poolList[pool];
		}
	}
}
package ca.esdot.lib.net
{

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.events.IOErrorEvent;
	
	import com.adobe.serialization.json.JSON;
	
	/**
	 * @author Andy Jones, Arcimedia
	 */
	
	public class JSONLoader extends Sprite
	{
		
		private var loader:URLLoader = new URLLoader() ;
		private var request:URLRequest = new URLRequest();
		public var jsonDecoded:Object = new Object();
		
		public function load(DataURL:String):void
		{
			
			var JSONString:String = DataURL;
			//trace("JSONLoader - JSONString = "+JSONString);
			
			var urlRequest:URLRequest = new URLRequest(JSONString);
			
			//var urlLoader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, decodeJSON);
			loader.addEventListener(IOErrorEvent.IO_ERROR, urlLoadErrorHandler);
			loader.load(urlRequest);
			
			loader.addEventListener(Event.COMPLETE, decodeJSON) ;
			
		}
		
		public function close():void {
			try {
				loader.close();
			} catch(e:Error){}
		}
		
		public function decodeJSON(event:Event):void
		{
			jsonDecoded = JSON.decode(event.target.data);
			dispatchEvent (event);
			
			removeListeners();
		}
		
		public function urlLoadErrorHandler(event:IOErrorEvent):void
		{
			dispatchEvent (event);
			removeListeners();
		}
		
		public function removeListeners():void
		{
			loader.removeEventListener(Event.COMPLETE, decodeJSON) ;
			loader.removeEventListener(IOErrorEvent.IO_ERROR, urlLoadErrorHandler);
		}
		
		public function returnJsonDecoded():Object
		{
			trace("Jason jsonDecoded - "+jsonDecoded);
			return jsonDecoded
		}
		
	}
}
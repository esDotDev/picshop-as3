package ca.esdot.lib.scoreoid
{
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	public class ScoreoidService extends EventDispatcher
	{
		protected var API_KEY:String = "25fc0ce4b5c3c009d5cb73592436249bd529c75e";
		protected var gameId:String = "B6cf3O3um";
		
		public static var PLATFORM_IOS:String = "ios";
		public static var PLATFORM_ANDROID:String = "android";
		public static var PLATFORM_BLACKBERRY:String = "blackberry";
		
		public function ScoreoidService(gameId:String) {
			this.gameId = gameId;
			super();
		}
		
		/**
		 * Create Scores
		 **/
		
		public function createScore(userName:String, score:int):void {
			
			var data:Object = {score: score, username: userName};
			var request:URLRequest = getRequest("createScore", data);
			
			var loader:URLLoader = getLoader();
			loader.addEventListener(Event.COMPLETE, onCreateScoreComplete, false, 0, true);
			loader.load(request);
		}
		
		protected function onCreateScoreComplete(event:Event):void{
			dispatchEvent(new ScoreoidServiceEvent(ScoreoidServiceEvent.CREATE_SCORE_COMPLETE));
		}
		
		/**
		 * Get Scores
		 **/
		
		public function getScores(offset:int, limit:int):void {
			var data:Object = {order_by: "score", order: "desc", limit: offset + "," + limit};
			var request:URLRequest = getRequest("getScores", data);
			
			var loader:URLLoader = getLoader();
			loader.addEventListener(Event.COMPLETE, onGetScoresComplete, false, 0, true);
			loader.load(request);
		}
		
		
		protected function onGetScoresComplete(event:Event):void{
			
			var result:Object = getJSONFromLoader(event.target as URLLoader);
			if(result is Array){
				var data:ScoreoidServiceData = new ScoreoidServiceData();
				data.scoreList = new Vector.<ScoreoidScore>();
				for(var i:int = 0, l:int = result.length; i < l; i++){
					data.scoreList.push(new ScoreoidScore(result[i].Player.id, result[i].Player.username, result[i].Score.score));
				}
				dispatchEvent(new ScoreoidServiceEvent(ScoreoidServiceEvent.GET_SCORES_COMPLETE, data));
			} else {
				onLoadFailed();
			}
		}
		
		
		/**
		 * Get Rank
		 **/
		public function getRank(score:int):void {
			
		}
		
		
		public function getNotifications():void {
			var request:URLRequest = getRequest("getNotification");
			
			var loader:URLLoader = getLoader();
			loader.addEventListener(Event.COMPLETE, onGetNotificationsComplete, false, 0, true);
			loader.load(request);
		}
		
		protected function onGetNotificationsComplete(event:Event):void{
			
			var result:Object = getJSONFromLoader(event.target as URLLoader);
			if(result is Array){
				var data:ScoreoidServiceData = new ScoreoidServiceData();
				var notificationList:Array = [];
				for(var i:int = 0, l:int= result.length; i < l; i++){
					notificationList[i] = new ScoreoidNotification(result[0].GameNotification.content);
				}
				data.notificationList = notificationList;
				dispatchEvent(new ScoreoidServiceEvent(ScoreoidServiceEvent.GET_NOTIFICATIONS_COMPLETE, data));
			} else {
				onLoadFailed();
			}
		}
		
		
		/** 
		 * Helper Functions
		 **/
		
		protected function onLoadFailed(event:IOErrorEvent = null):void{
			dispatchEvent(new ScoreoidServiceEvent(ScoreoidServiceEvent.LOAD_FAILED));
		}
		
		protected function getJSONFromLoader(loader:URLLoader):Object {
			var data:Object;
			try { data = com.adobe.serialization.json.JSON.decode(loader.data); } //JSON.parse(loader.data); } 
			catch(e:Error){
				trace(e.message);
			}
			return data;
		}
		
		protected function getRequest(api:String, data:Object = null):URLRequest {
			
			var vars:URLVariables = new URLVariables();
			vars.api_key = API_KEY;
			vars.game_id = gameId;
			vars.response ="json";
				
			for(var s:String in data){
				vars[s] = data[s];
			}
			
			var request:URLRequest = new URLRequest("https://www.scoreoid.com/api/" + api);
			request.data = vars;
			request.method = URLRequestMethod.POST;
			
			return request;
		}
		
		protected function getLoader():URLLoader {
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadFailed, false, 0, true);
			return loader;
		}
	}
}
package ca.esdot.lib.scoreoid
{
	import flash.events.Event;
	
	public class ScoreoidServiceEvent extends Event
	{
		public static var CREATE_SCORE_COMPLETE:String = "createScoreComplete";
		
		public static var GET_SCORES_COMPLETE:String = "getScoresComplete";
		public static var GET_RANK_COMPLETE:String = "getRankComplete";
		public static var GET_NOTIFICATIONS_COMPLETE:String = "getNotificationsComplete";
		
		public static var LOAD_FAILED:String = "loadFailed";
		
		public var data:ScoreoidServiceData;
		
		public function ScoreoidServiceEvent(type:String, data:ScoreoidServiceData = null, bubbles:Boolean=false, cancelable:Boolean=false){
			this.data = data;
			super(type, bubbles, cancelable);
		}
	}
}
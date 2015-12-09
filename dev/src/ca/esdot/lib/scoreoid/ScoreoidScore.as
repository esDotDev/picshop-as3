package ca.esdot.lib.scoreoid
{
	public class ScoreoidScore
	{
		public var id:String;
		public var name:String;
		public var score:int;
		
		public function ScoreoidScore(id:String, name:String, score:Number) {
			this.id = id;
			this.name = name;
			this.score = score;
		}
	}
}
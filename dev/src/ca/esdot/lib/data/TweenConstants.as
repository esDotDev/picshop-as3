package ca.esdot.lib.data
{
	import fl.motion.easing.Quadratic;

	public class TweenConstants
	{
		public static var SHORT:Number = .35;
		public static var NORMAL:Number = .55;
		public static var LONG:Number = .8;
		
		public static var EASE_OUT:Function = Quadratic.easeOut;
		public static var EASE_IN:Function = Quadratic.easeIn;
	}
}
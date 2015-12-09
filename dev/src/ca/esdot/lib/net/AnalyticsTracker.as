package ca.esdot.lib.net
{
	import ca.esdot.lib.utils.DeviceUtils;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.system.Capabilities;

	public class AnalyticsTracker
	{
		import com.google.analytics.AnalyticsTracker;
		import com.google.analytics.GATracker;
		
		protected var tracker:com.google.analytics.AnalyticsTracker;
		protected var log:Boolean = true;
		protected var debugPrefix:String;
		
		public function AnalyticsTracker(stage:DisplayObject, debug:Boolean = false, log:Boolean = true){
			this.log = log;
			debugPrefix = (Capabilities.isDebugger)? "debug:" : "";
			tracker = new GATracker(stage, "UA-20462486-8", "AS3", debug);
		}
		
		public function pageView(id:String):void {
			//if(log){
				trace("[Analytics] PageView: ", DeviceUtils.deviceName + "/" + debugPrefix + id);
			//}
			tracker.trackPageview("/" + debugPrefix + id);
		}
		
		public function event(category:String, action:String, label:String="", value:Number=NaN):void {
			//if(log){
				trace("[Analytics] Event: ", category, debugPrefix + action, label, value);
			//}
			tracker.trackEvent(category, debugPrefix + action, label, value);
		}
		
		public function error(type:String, message:String="", value:Number=NaN):void {
			//if(log){
			trace("[Analytics] Error: ", type, message);
			//}
			tracker.trackEvent("Error Log: " + DeviceUtils.deviceName, type, message, value);
		}
	}
}
package ca.esdot.picshop.services
{
	import com.davikingcode.nativeExtensions.instagram.Instagram;
	import com.davikingcode.nativeExtensions.instagram.InstagramEvent;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	
	import org.robotlegs.mvcs.Actor;

	public class InstagramService extends Actor
	{
		public static var isSupported:Boolean = false;

		protected var extension:Instagram;
		
		public function InstagramService(){
			extension = new Instagram();
			extension.addEventListener(InstagramEvent.OK, onShareOk);
			
			if (extension.isInstalled()){
				isSupported = true;
			}
		}
		
		protected function onShareOk(event:Event):void {
			trace("Share Complete!");
		}
		
		public function share(bmpData:BitmapData, caption:String = ""):void {
			if(!isSupported){ return; }
			
			extension.share(bmpData, caption);
		}
	}
}
package ca.esdot.picshop.commands.events
{
	import ca.esdot.picshop.data.SaveImageOptions;
	import ca.esdot.picshop.data.SaveQuality;
	
	import flash.events.Event;

	public class SaveImageEvent extends Event
	{
		public static var SAVE_IMAGE:String = "cameraRoll";
		
		public var options:SaveImageOptions;
		
		public function SaveImageEvent(type:String, options:SaveImageOptions, bubbles:Boolean=false, cancelable:Boolean=false) {
			this.options = options ;
			
			super(type, bubbles, cancelable);
		}
	}
}
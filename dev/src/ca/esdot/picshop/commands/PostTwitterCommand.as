package ca.esdot.picshop.commands
{
	import com.milkmangames.nativeextensions.GoViral;
	
	import flash.filesystem.File;
	
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.events.ShareEvent;
	
	import org.robotlegs.mvcs.Command;
	
	
		
		public class PostTwitterCommand extends Command
		{
			[Inject]
			public var event:ShareEvent;
			
			protected var file:File;
			
			override public function execute():void {
			
				if(GoViral.isSupported() == false){ return; }
				var goViral:GoViral = GoViral.goViral;
				if(GoViral.goViral.isTweetSheetAvailable()){ //<!-- This seems to always return true!?
					goViral.showTweetSheetWithImage(event.message, event.bitmapData);
				} else {
					DialogManager.alert("Woops: Can't find Twitter", "In order to share to Twitter, you must have the Twitter app installed and be using iOS 5 or higher.");
				}
			
				
				
			}
		
				
		}
}



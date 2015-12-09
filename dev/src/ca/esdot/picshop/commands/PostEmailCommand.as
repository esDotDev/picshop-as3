package ca.esdot.picshop.commands
{
	import com.milkmangames.nativeextensions.GoViral;
	import com.milkmangames.nativeextensions.events.GVMailEvent;
	
	import flash.events.Event;
	
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.events.ShareEvent;
	import ca.esdot.picshop.utils.AnalyticsManager;
	
	import org.robotlegs.mvcs.Command;
	
	public class PostEmailCommand extends Command
	{
		[Inject]
		public var event:ShareEvent;
		
		override public function execute():void {
			if(GoViral.isSupported() == false){ return; }
			var goViral:GoViral = GoViral.goViral;
			
			//(contextView as MainView).isLoading = true;
			goViral.addEventListener(GVMailEvent.MAIL_SENT, onMailComplete, false, 0, true);
			goViral.addEventListener(GVMailEvent.MAIL_SAVED, onEmailFailed, false, 0, true);
			goViral.addEventListener(GVMailEvent.MAIL_CANCELED,onEmailFailed, false, 0, true);
			goViral.addEventListener(GVMailEvent.MAIL_FAILED, onEmailFailed, false, 0, true);
			goViral.showEmailComposerWithBitmap(event.subject, "", event.message, false, event.bitmapData);
		}
		
		protected function onMailComplete(event:Event):void{
			AnalyticsManager.pageView("/share-email");
			AnalyticsManager.imageShared();
			
			destroyCommand();
			/*
			var dialog:TitleDialog = new TitleDialog(DeviceUtils.dialogWidth, DeviceUtils.dialogHeight, "Email Sent", "Your email has been sent. Thanks for choosing PicShop!");
			dialog.setButtons(["Ok"]);
			dialog.addEventListener(ButtonEvent.CLICKED, function():void{ 
				DialogManager.removeDialogs(); 
			});
			DialogManager.showDialog(dialog, true);
			*/
		}
		
		protected function onEmailFailed(event:Event):void {
			destroyCommand();
		}
		
		protected function destroyCommand(event:Event = null):void {
			DialogManager.removeDialogs();
			//(contextView as MainView).isLoading = false;
			commandMap.release(this);
		}
	}
}
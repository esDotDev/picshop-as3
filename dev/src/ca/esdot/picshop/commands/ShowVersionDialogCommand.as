package ca.esdot.picshop.commands
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.data.Strings;
	import ca.esdot.picshop.dialogs.VersionDialog;
	import ca.esdot.picshop.services.InstagramService;
	
	import org.robotlegs.mvcs.Command;
	
	import swc.CloseButton;
	
	public class ShowVersionDialogCommand extends Command
	{	
		[Inject]
		public var mainModel:MainModel;
		protected var showAppGratis:Boolean;
		
		protected var stageWidth:int;

		protected var stageHeight:int;

		private var appGratisDialog:Sprite;
		
		override public function execute():void {
			stageWidth = contextView.stage.stageWidth;
			stageHeight = contextView.stage.stageHeight;
			
			//Low res device... fuck it.
			if(stageWidth < 500 && stageHeight < 500){ return; }
			
			var text:String = "";
			var title:String = "Check out what's new in 3.0!";
			var features:Array = [];
			
			
			if(DeviceUtils.onIOS){
				//features.unshift("New iOS7 Redesign!");
			}
			
			
			if(DeviceUtils.onPlayBook || DeviceUtils.onAmazon){
				features = features.concat([
					//"Facebook Upload Fixed! (Sorry guys)"
				]);
			}
			
			
			if(DeviceUtils.onAndroid){
				features = features.concat([ 
					"Can now load images from Google Photos, Picasa etc"
				]);
				if(!PicShop.FULL_VERSION){
					features = features.concat([ 
						"Fixed In-App Purchases & Restored Purchases"
					]);
				}
			}
			
			//Exit if we have no new features
			if(features.length == 0){ return; }
			
			//Show Dialog
			text += "  *  " + features.join("\n  *  ");  
			text += "\n\nEnjoy PicShop and please tell your friends :) ";
		
			var fontSize:Number = (DeviceUtils.ANDROID)? DeviceUtils.fontSize * .85 : DeviceUtils.fontSize * .8;
			
			var dialogWidth:int = MainView.instance.isPortrait? stageWidth * 1 : stageWidth * .8;
			var dialogHeight:int = stageHeight * .9;
			if(DeviceUtils.isTablet){
				dialogWidth *= .8;
				dialogHeight *= .8;
			}
			
			var dialog:VersionDialog = new VersionDialog(dialogWidth, dialogHeight, title, text, fontSize);
			dialog.buttonHeight *= .8;
			dialog.setButtons([Strings.OK]);
			dialog.addEventListener(ButtonEvent.CLICKED, function(){
				releaseCommand();
			});
			DialogManager.addDialog(dialog, true);
			
			dialog.shrinkToText();
			DialogManager.center(DialogManager.currentDialog);
			
		}

		protected function releaseCommand():void {
			DialogManager.removeDialogs();
			commandMap.release(this);
		}
		
	}
}
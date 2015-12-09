package ca.esdot.picshop.views
{
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.utils.ImageWriter;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.commands.events.CommandEvent;
	import ca.esdot.picshop.commands.events.SettingsEvent;
	import ca.esdot.picshop.dialogs.TitleDialog;
	import ca.esdot.picshop.services.TwitterService;
	import ca.esdot.picshop.services.TwitterServiceEvent;
	import ca.esdot.picshop.utils.AnalyticsManager;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.utils.setTimeout;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class TwitterAuthFormMediator extends Mediator
	{
		[Inject]
		public var view:TwitterAuthForm;
		
		[Inject]
		public var mainModel:MainModel;
		
		protected var imageWriter:ImageWriter;
		protected var uploadFile:File;
		
		public var twitter:TwitterService;
		
		override public function onRegister():void {
			twitter = new TwitterService();
			
			eventMap.mapListener(twitter, TwitterServiceEvent.UPLOAD_COMPLETE, onUploadComplete);
			eventMap.mapListener(twitter, TwitterServiceEvent.UPLOAD_FAILED, onUploadFailed);
			
			eventMap.mapListener(view.signInButton, MouseEvent.CLICK, onSignInClicked);
			
			view.isLoading = true;
			setTimeout(writeImage, 1000);
		}
		
		protected function writeImage():void {
			//Write Image
			uploadFile = File.applicationStorageDirectory.resolvePath("upload.png");
			imageWriter = new ImageWriter();
			imageWriter.addEventListener(Event.COMPLETE, onImageComplete, false, 0, true);
			imageWriter.write(view.bitmapData, uploadFile);
		}		
		
		protected function onImageComplete(event:Event):void {
			initView();
		}
		
		protected function initView():void {
			//Start uploading immediately
			if(mainModel.settings.t1 && mainModel.settings.t2){
				view.userNameText.text = mainModel.settings.t1;
				view.maskPassword();
				twitter.uploadWithTwitPic(mainModel.settings.t1,  mainModel.settings.t2, view.message, uploadFile);
			} 
			//Need login info...
			else {
				view.isLoading = false;
			}
		}
		
		private function onUploadFailed(event:TwitterServiceEvent):void {
			view.isLoading = false;
		}
		
		private function onUploadComplete(event:TwitterServiceEvent):void {
			
			mainModel.settings.numSaves++;
			
			var dialog:TitleDialog = new TitleDialog(DeviceUtils.dialogWidth, DeviceUtils.dialogHeight, "Upload Complete", "Tweet Complete! Thanks for choosing PicShop.");
			dialog.setButtons(["Ok"]);
			dialog.addEventListener(ButtonEvent.CLICKED, function():void{ 
				DialogManager.removeDialogs();
				dispatch(new CommandEvent(CommandEvent.PROMPT_FOR_REVIEW));
			});
			
			AnalyticsManager.pageView("/share-twitter");
			AnalyticsManager.imageShared();
			
			DialogManager.addDialog(dialog, true);
		}
		
		protected function onSignInClicked(event:MouseEvent):void {
			if(u == "" || p == ""){ return; }
			
			view.isLoading = true;
			
			var u:String = view.userNameText.text;
			var p:String = view.passwordText.text;
			
			mainModel.settings.t1 = u;
			if(p == view.passwordMask){
				p = mainModel.settings.t2;
			}
			mainModel.settings.t2 = p;
			
			dispatch(new SettingsEvent(SettingsEvent.SAVE));
			twitter.uploadWithTwitPic(view.userName, view.password, view.message, uploadFile);
		}
	}
}
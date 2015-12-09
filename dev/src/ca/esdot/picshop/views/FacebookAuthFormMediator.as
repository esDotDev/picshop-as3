package ca.esdot.picshop.views
{
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.utils.ImageWriter;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.commands.events.CommandEvent;
	import ca.esdot.picshop.dialogs.ShareDialog;
	import ca.esdot.picshop.dialogs.TitleDialog;
	import ca.esdot.picshop.utils.AnalyticsManager;
	
	import com.facebook.graph.FacebookMobile;
	import com.facebook.graph.net.FacebookRequest;
	
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.utils.setTimeout;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class FacebookAuthFormMediator extends Mediator
	{
		[Inject]
		public var view:FacebookAuthForm;
		
		[Inject]
		public var mainModel:MainModel;
		
		protected var imageWriter:ImageWriter;
		protected var uploadFile:File;
		protected var isPosting:Boolean;
		private var request:FacebookRequest;
		
		override public function onRegister():void {
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
			FacebookMobile.init("287066698013735", onInitComplete, null);
		}
		
		protected function onInitComplete(result:Object, error:Object):void {
			if(!result){
				FacebookMobile.login(onLoginComplete, view.stage, ["publish_stream"], view.stageWebView);
			} else {
				postMessage();
			}
		}
		
		protected function onLoginComplete(result:Object, error:Object=null):void {
			if(result){
				postMessage();
			} else {
				FacebookMobile.logout(onLogout);
			}
		}
		
		protected function onLogout(result:Object, error:Object=null):void {
			FacebookMobile.login(onLoginComplete, view.stage, ["publish_stream"], view.stageWebView);
		}
		
		protected function removeView():void {
			view.stageWebView.stage = null;
			view.parent.removeChild(view);
		}
		
		public function postMessage():void {
			if(isPosting){ return; }
			
			//Hide Cancel button...
			if(DialogManager.currentDialog is ShareDialog){
				(DialogManager.currentDialog as ShareDialog).setButtons([]);
			}
			view.text = "Uploading your image, be patient...";
			isPosting = true;
			
			var params:Object = {
				source: uploadFile, 
				message: view.message, 
				fileName: uploadFile.name
			};
			
			FacebookMobile.api('/me/photos', onUploadComplete, params, "POST");
		}
		
		private function onUploadComplete(result:Object, error:Object):void {
			if(!result){ 
				removeView();
			}
			mainModel.settings.numSaves++;
			
			var dialog:TitleDialog = new TitleDialog(DeviceUtils.dialogWidth, DeviceUtils.dialogHeight, "Upload Complete", "Post Complete! Thanks for choosing PicShop.");
			dialog.setButtons(["Ok"]);
			dialog.addEventListener(ButtonEvent.CLICKED, function():void{ 
				DialogManager.removeDialogs();
				dispatch(new CommandEvent(CommandEvent.PROMPT_FOR_REVIEW));
			});
			
			AnalyticsManager.pageView("/share-facebook");
			AnalyticsManager.imageShared();
			
			DialogManager.addDialog(dialog, true);
		}
	}
}
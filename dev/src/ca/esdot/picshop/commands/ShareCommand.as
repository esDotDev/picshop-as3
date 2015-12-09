package ca.esdot.picshop.commands
{
	import com.gskinner.motion.GTween;
	import com.milkmangames.nativeextensions.GoViral;
	import com.milkmangames.nativeextensions.events.GVMailEvent;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.data.TweenConstants;
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.events.ShareEvent;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.data.Strings;
	import ca.esdot.picshop.dialogs.ShareDialog;
	import ca.esdot.picshop.dialogs.TitleDialog;
	import ca.esdot.picshop.services.InstagramService;
	import ca.esdot.picshop.utils.AnalyticsManager;
	
	import org.robotlegs.mvcs.Command;
	
	public class ShareCommand extends Command
	{
		[Inject]
		public var shareEvent:ShareEvent;
		
		[Inject]
		public var mainModel:MainModel;
		
		[Inject]
		public var instagramService:InstagramService;
		
		protected var goViral:GoViral;
		protected var shareDialog:ShareDialog;
		
		override public function execute():void {
			commandMap.detain(this);
			
			
			switch(shareEvent.type){
				case ShareEvent.EMAIL:
					dispatch(new ShareEvent(ShareEvent.EMAIL_POST, "", shareEvent.bitmapData));
					break;
				
				case ShareEvent.TWITTER:
					dispatch(new ShareEvent(ShareEvent.TWITTER_POST, "", shareEvent.bitmapData));
					//showShareDialog(ShareEvent.TWITTER, event.bitmapData);
					break;
					
				case ShareEvent.FACEBOOK:
					showShareDialog(ShareEvent.FACEBOOK, shareEvent.bitmapData);
					break;
				
				case ShareEvent.INSTAGRAM:
					instagrameShare();
					break;
				
			}
		}
		
		protected function instagrameShare():void {
			if(InstagramService.isSupported){
				instagramService.share(shareEvent.bitmapData, shareEvent.message);
			}
		}
		
		protected function showShareDialog(type:String, bitmapData:BitmapData):void {
			shareDialog = new ShareDialog(type, bitmapData);
			var w:int = Math.max(DeviceUtils.dialogWidth * 1.3, 480);
			var h:int = Math.max(DeviceUtils.dialogHeight * 1.3, 320);
			
			shareDialog.setSize(w, h);
			shareDialog.addEventListener(ButtonEvent.CLICKED, onShareDialogClicked, false, 0, true);
			DialogManager.addDialog(shareDialog, true);
			
			new GTween(shareDialog, TweenConstants.NORMAL, {y: shareDialog.y}, {ease: TweenConstants.EASE_OUT});
			shareDialog.y = contextView.stage.stageHeight;
		}		
		
		protected function onShareDialogClicked(event:ButtonEvent):void {
			if(event.label == Strings.DISCARD){ 
				destroyCommand();
				return; 
			}
			
			var source:BitmapData = shareEvent.bitmapData;
			var scale:Number = 1000 / Math.max(source.width, source.height);
			
			var m:Matrix = new Matrix();
			m.scale(scale, scale);
				
			var data:BitmapData = new BitmapData(source.width * scale, source.height * scale, false, 0x0);
			data.draw(source, m, null, null, null, true);
			
			destroyCommand();
			
			if(shareEvent.type == ShareEvent.FACEBOOK){
				dispatch(new ShareEvent(ShareEvent.FACEBOOK_POST, shareDialog.message, shareEvent.bitmapData));
			} 
			
		}	
		
		protected function destroyCommand(event:Event = null):void {
			DialogManager.removeDialogs();
			(contextView as MainView).isLoading = false;
			
			commandMap.release(this);
		}
	}
}
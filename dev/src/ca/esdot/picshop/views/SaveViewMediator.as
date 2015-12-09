package ca.esdot.picshop.views
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.setTimeout;
	
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.events.ShareEvent;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.commands.events.ChangeViewEvent;
	import ca.esdot.picshop.commands.events.SaveImageEvent;
	import ca.esdot.picshop.data.SaveImageOptions;
	import ca.esdot.picshop.data.SaveQuality;
	import ca.esdot.picshop.data.Strings;
	import ca.esdot.picshop.dialogs.AdvancedSaveDialog;
	import ca.esdot.picshop.dialogs.OptionsDialog;
	import ca.esdot.picshop.dialogs.SaveDialog;
	import ca.esdot.picshop.dialogs.TitleDialog;
	import ca.esdot.picshop.events.ModelEvent;
	import ca.esdot.picshop.events.UnlockEvent;
	import ca.esdot.picshop.menus.SaveMenuTypes;
	import ca.esdot.picshop.services.InstagramService;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class SaveViewMediator extends Mediator
	{
		[Inject]
		public var view:SaveView;
		
		[Inject]
		public var mainModel:MainModel;
		private var advancedSaveDialog:AdvancedSaveDialog;
		
		
		override public function onRegister():void {
			eventMap.mapListener(view.bottomMenu, ChangeEvent.CHANGED, onMenuChanged, ChangeEvent);
			eventMap.mapListener(view.bottomMenu.backButton, MouseEvent.CLICK, onBackClicked, MouseEvent);
			
			view.preview = mainModel.sourceData;
			view.updateLayout();
			setTimeout(view.transitionIn, 500);
		}
		
		protected function onBackClicked(event:MouseEvent):void {
			dispatch(new ChangeViewEvent(ChangeViewEvent.BACK, null));
		}
		
		protected function onMenuChanged(event:ChangeEvent):void {
			switch (event.newValue) {
				case SaveMenuTypes.SAVE:
					showQualityDialog();
					break;
				
				case SaveMenuTypes.EMAIL:
					dispatch(new ShareEvent(ShareEvent.EMAIL, "", mainModel.sourceData, "Check this out..."));
					break;
				
				case SaveMenuTypes.SHARE:
					dispatch(new ShareEvent(ShareEvent.ANDROID, "", mainModel.sourceData, "Check this out..."));
					break;
				
				case SaveMenuTypes.TWITTER:
					dispatch(new ShareEvent(ShareEvent.TWITTER, "", mainModel.sourceData, "Check this out..."));
					break;
				
				case SaveMenuTypes.FACEBOOK:
					dispatch(new ShareEvent(ShareEvent.FACEBOOK, "", mainModel.sourceData, "Check this out...")); //}
					break;
				
				case SaveMenuTypes.INSTAGRAM:
					if(InstagramService.isSupported){
						dispatch(new ShareEvent(ShareEvent.INSTAGRAM, "", mainModel.sourceData, "Check this out...")); //}
					} else {
						var dialog:TitleDialog = new TitleDialog(DeviceUtils.dialogWidth * .8, DeviceUtils.dialogHeight * .8, 
							"Instagram is missing...", "Woops, we can't find the native Instagram App. You'll need to install it before this feature will work.");
						dialog.setButtons([Strings.CANCEL, "Install Now"]); 
						dialog.addEventListener(ButtonEvent.CLICKED, onInstagramClicked);
						DialogManager.addDialog(dialog);
					}
					break;
			}
		}
		
		protected function onInstagramClicked(event:ButtonEvent):void {
			if(event.label != Strings.CANCEL){
				var url:String = DeviceUtils.onIOS? 
					"http://itunes.apple.com/us/app/id389801252" : 
					"market://details?id=com.instagram.android";
				
				navigateToURL(new URLRequest(url));
				
			}
			DialogManager.removeDialogs();
		}
		
		protected function showQualityDialog():void {
			var dialog:SaveDialog = new SaveDialog(DeviceUtils.dialogWidth, Math.min(DeviceUtils.hitSize * 7, view.viewHeight * .98), "Image Size", 
				[SaveQuality.LOW, SaveQuality.MEDIUM, SaveQuality.HIGH, SaveQuality.ULTRA, SaveQuality.ADVANCED], -1);
			dialog.setButtons([Strings.CANCEL]);
			dialog.addEventListener(ButtonEvent.CLICKED, function(event:ButtonEvent):void {
				DialogManager.removeDialogs();
				if(event.label == Strings.CANCEL){ return; }
				
				if(event.label == SaveQuality.ADVANCED){
					advancedSaveDialog = new AdvancedSaveDialog(mainModel.sourceData.width, mainModel.sourceData.height);
					advancedSaveDialog.addEventListener(ButtonEvent.CLICKED, onAdvancedSaveDialogClosed, false, 0, true);
					DialogManager.addDialog(advancedSaveDialog, true);
				} 
					//Save Image.
				else {
					var low:int = 800, 
					medium:int = 1200, 
					high:int = 1600, 
					ultra:int = 2000;
					
					var quality:String = event.label;
					var sourceData:BitmapData = mainModel.sourceData;
					//Default to low
					var scale:Number = low / Math.max(sourceData.width, sourceData.height);
					if(quality == SaveQuality.MEDIUM){
						scale = medium / Math.max(sourceData.width, sourceData.height);
					}
					else if(quality == SaveQuality.HIGH){
						scale = high / Math.max(sourceData.width, sourceData.height);
					}
					else if(quality == SaveQuality.ULTRA){
						scale = ultra / Math.max(sourceData.width, sourceData.height);
					}
					
					dispatch(new SaveImageEvent(SaveImageEvent.SAVE_IMAGE, new SaveImageOptions(sourceData.width * scale, sourceData.height * scale)));
				}
			})
				
			DialogManager.addDialog(dialog);
		}
		
		protected function onAdvancedSaveDialogClosed(event:ButtonEvent):void {
			DialogManager.removeDialogs();
			if(event.label == Strings.CANCEL){ return; }
			
			dispatch(new SaveImageEvent(SaveImageEvent.SAVE_IMAGE, advancedSaveDialog.options));
			
		}
	}
}
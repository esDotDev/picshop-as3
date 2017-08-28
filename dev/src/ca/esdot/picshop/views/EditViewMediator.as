package ca.esdot.picshop.views
{
	import flash.events.MouseEvent;
	import flash.media.CameraUI;
	import flash.utils.setTimeout;
	
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.commands.events.ChangeViewEvent;
	import ca.esdot.picshop.commands.events.CommandEvent;
	import ca.esdot.picshop.commands.events.OpenImageEvent;
	import ca.esdot.picshop.commands.events.ShowTipEvent;
	import ca.esdot.picshop.commands.events.StartEditEvent;
	import ca.esdot.picshop.data.Strings;
	import ca.esdot.picshop.data.UnlockableFeatures;
	import ca.esdot.picshop.data.ViewTypes;
	import ca.esdot.picshop.dialogs.OptionsDialog;
	import ca.esdot.picshop.events.ModelEvent;
	import ca.esdot.picshop.events.ShowMenuEvent;
	import ca.esdot.picshop.events.UnlockEvent;
	import ca.esdot.picshop.menus.EditMenuTypes;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class EditViewMediator extends Mediator
	{
		[Inject]
		public var view:EditView;
		
		[Inject]
		public var mainModel:MainModel;
		private var pendingMenuUnlock:String;
		
		
		override public function onRegister():void {
			if(mainModel.sourceData){
				view.imageView.setCurrentBitmap(mainModel.sourceData);
				view.editMenu.toolsEnabled = true;
			} else {
				/*
				if(mainModel.settings.imageCount == 0){
					var dialog:TitleDialog = new TitleDialog(DeviceUtils.hitSize * 6, DeviceUtils.hitSize * 4, "Welcome to PicShop!", "You're going to love this app :) \n\nWould you like to watch a quick video walkthough?");
					dialog.setButtons(["Cancel", "Ok"]);
					DialogManager.showDialog(dialog);
					dialog.addEventListener(ButtonEvent.CLICKED, function(event:ButtonEvent){
						DialogManager.removeDialogs();
						if(event.label == "Ok"){
							dispatch(new CommandEvent(CommandEvent.SHOW_INTRO_VIDEO));
						} else {
							dispatch(new ShowTipEvent(ShowTipEvent.OPEN_IMAGE, view.editMenu.imageButton));
						}
					});
				} else {
					dispatch(new ShowTipEvent(ShowTipEvent.OPEN_IMAGE, view.editMenu.imageButton));
				}
				*/
			}
			
			view.editMenu.openImageClicked.add(onImageClicked);
			view.editMenu.unlockFeatureClicked.add(onUnlockFeatureClicked);
			
			eventMap.mapListener(view.editMenu.saveButton, MouseEvent.CLICK, onSaveClicked, MouseEvent);
			
			addContextListener(ModelEvent.SOURCE_CHANGED, onSourceChanged, ModelEvent);
			addContextListener(ShowMenuEvent.SHOW_SECONDARY, onShowSecondaryMenu, ShowMenuEvent);
			
			//Global unlock 
			addContextListener(ModelEvent.APP_UNLOCKED, onAppUnlocked, ModelEvent);
			
			//Individual app upgrades
			addContextListener(ModelEvent.FILTERS_UNLOCKED, onFeatureUnlocked, ModelEvent);
			addContextListener(ModelEvent.FRAMES_UNLOCKED, onFeatureUnlocked, ModelEvent);
			addContextListener(ModelEvent.EXTRAS_UNLOCKED, onFeatureUnlocked, ModelEvent);
			
			//App is fully unlocked
			if(mainModel.isAppLocked == false){
				view.editMenu.unlockAll();
			}
			//Restore individual upgrades
			else {
				if(mainModel.isFeatureLocked(UnlockableFeatures.EXTRAS)){
					view.editMenu.lockFeature(UnlockableFeatures.EXTRAS);
				}
				if(mainModel.isFeatureLocked(UnlockableFeatures.FRAMES)){
					view.editMenu.lockFeature(UnlockableFeatures.FRAMES);
				}
				if(mainModel.isFeatureLocked(UnlockableFeatures.FILTERS)){
					view.editMenu.lockFeature(UnlockableFeatures.FILTERS);
				}
			}
		}
		
		protected function onFeatureUnlocked(event:ModelEvent):void {
			if(event.type == ModelEvent.EXTRAS_UNLOCKED){
				view.editMenu.unlockFeature(UnlockableFeatures.EXTRAS);
			}
			else if(event.type == ModelEvent.FRAMES_UNLOCKED){
				view.editMenu.unlockFeature(UnlockableFeatures.FRAMES);
			}
			else if(event.type == ModelEvent.FILTERS_UNLOCKED){
				view.editMenu.unlockFeature(UnlockableFeatures.FILTERS);
			}
			
			MainView.instance.removeUpgradeOffer();
			if(pendingMenuUnlock){
				view.editMenu.setMenuType(pendingMenuUnlock);
				pendingMenuUnlock = null;
			}
		}
		
		protected function onUnlockFeatureClicked(feature:String):void {
			
			pendingMenuUnlock = EditMenuTypes.BORDERS;
			if(feature == UnlockableFeatures.EXTRAS){
				pendingMenuUnlock = EditMenuTypes.EXTRAS;
			}
			else if(feature == UnlockableFeatures.FILTERS){
				pendingMenuUnlock = EditMenuTypes.FILTERS;
			}
			
			//FAKE IT!
			//mainModel.unlockFeature(feature);
			
			//Show Appropriate View
			MainView.instance.showUpgradeOffer(feature);
			
			
		}
		
		protected function onAppUnlocked(event:ModelEvent):void {
			view.editMenu.unlockAll();
		}
		
		protected function onShowSecondaryMenu(event:ShowMenuEvent):void {
			view.showSecondaryMenu(event.menuType);
		}
		
		protected function onImageClicked():void {
			MainView.click();
			
			var options:Array = [Strings.GALLERY];
			if(CameraUI.isSupported){
				options.unshift(Strings.CAMERA);
			}
			
			var height:int = DeviceUtils.dialogHeight * .9;
			//BB10 Doesn't support Facebook API (Feb 2014)
			//if(!DeviceUtils.onBB10){
				options.push(Strings.FACEBOOK);
				height = DeviceUtils.dialogHeight * 1.2;
			//}
			var dialog:OptionsDialog = new OptionsDialog(DeviceUtils.dialogWidth, height, 
				"Open Image From...", 
				options);
			dialog.setButtons(["Cancel"]);
			dialog.addEventListener(ButtonEvent.CLICKED, onOpenOptionsClick, false, 0, true);
			DialogManager.addDialog(dialog);
		}
		
		protected function onOpenOptionsClick(event:ButtonEvent):void {
			DialogManager.removeDialogs();
			if(event.label == Strings.CAMERA){
				if(!CameraUI.isSupported){
					dispatch(new OpenImageEvent(OpenImageEvent.GALLERY));
				} else {
					dispatch(new OpenImageEvent(OpenImageEvent.CAMERA));
				}
			} 
			else if(event.label == Strings.GALLERY){
				if(!CameraUI.isSupported){
					dispatch(new OpenImageEvent(OpenImageEvent.GALLERY));
				} else {
					dispatch(new OpenImageEvent(OpenImageEvent.GALLERY));
				}
			} else if(event.label == Strings.FACEBOOK){
				dispatch(new OpenImageEvent(OpenImageEvent.FACEBOOK));
			}
		}
		
		protected function onSaveClicked(event:MouseEvent):void {
			dispatch(new ChangeViewEvent(ChangeViewEvent.CHANGE, ViewTypes.SAVE));
			MainView.click();
		}
		
		private function onSourceChanged(event:ModelEvent):void {
			if(mainModel.sourceData){
				view.imageView.setCurrentBitmap(mainModel.sourceData);
				view.imageView.updateLayout();
				view.editMenu.toolsEnabled = true;
			} else {
				view.imageView.setCurrentBitmap(null);
				view.editMenu.toolsEnabled = false;
				view.hideCurrentMenu();
			}
		}
	}
}
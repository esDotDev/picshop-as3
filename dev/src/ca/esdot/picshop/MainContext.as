package ca.esdot.picshop
{
	import com.milkmangames.nativeextensions.GoViral;
	
	import flash.display.DisplayObjectContainer;
	
	import ca.esdot.lib.events.ShareEvent;
	import ca.esdot.picshop.commands.AddImageLayerCommand;
	import ca.esdot.picshop.commands.ChangeColorCommand;
	import ca.esdot.picshop.commands.ChangeViewCommand;
	import ca.esdot.picshop.commands.EditImageCommand;
	import ca.esdot.picshop.commands.InAppPurchaseCommand;
	import ca.esdot.picshop.commands.InAppRestoreCommand;
	import ca.esdot.picshop.commands.OpenDownloadCommand;
	import ca.esdot.picshop.commands.OpenFacebookImageCommand;
	import ca.esdot.picshop.commands.OpenImageCommand;
	import ca.esdot.picshop.commands.PostEmailCommand;
	import ca.esdot.picshop.commands.PostFacebookCommand;
	import ca.esdot.picshop.commands.PostTwitterCommand;
	import ca.esdot.picshop.commands.PromptForReviewCommand;
	import ca.esdot.picshop.commands.ResizeAppCommand;
	import ca.esdot.picshop.commands.SaveImageCommand;
	import ca.esdot.picshop.commands.SettingsCommand;
	import ca.esdot.picshop.commands.ShareAndroidCommand;
	import ca.esdot.picshop.commands.ShareCommand;
	import ca.esdot.picshop.commands.ShowIntroVideoCommand;
	import ca.esdot.picshop.commands.ShowOfferwallCommand;
	import ca.esdot.picshop.commands.ShowStickersCommand;
	import ca.esdot.picshop.commands.ShowTipCommand;
	import ca.esdot.picshop.commands.ShowVersionDialogCommand;
	import ca.esdot.picshop.commands.StartupCommand;
	import ca.esdot.picshop.commands.UpgradeDialogCommand;
	import ca.esdot.picshop.commands.events.ChangeColorEvent;
	import ca.esdot.picshop.commands.events.ChangeViewEvent;
	import ca.esdot.picshop.commands.events.CommandEvent;
	import ca.esdot.picshop.commands.events.OpenImageEvent;
	import ca.esdot.picshop.commands.events.SaveImageEvent;
	import ca.esdot.picshop.commands.events.SettingsEvent;
	import ca.esdot.picshop.commands.events.ShowStickersEvent;
	import ca.esdot.picshop.commands.events.ShowTipEvent;
	import ca.esdot.picshop.commands.events.StartEditEvent;
	import ca.esdot.picshop.events.UnlockEvent;
	import ca.esdot.picshop.menus.BasicToolsMenu;
	import ca.esdot.picshop.menus.BasicToolsMenuMediator;
	import ca.esdot.picshop.menus.BordersMenu;
	import ca.esdot.picshop.menus.BordersMenuMediator;
	import ca.esdot.picshop.menus.ExtrasMenu;
	import ca.esdot.picshop.menus.ExtrasMenuMediator;
	import ca.esdot.picshop.menus.FiltersMenu;
	import ca.esdot.picshop.menus.FiltersMenuMediator;
	import ca.esdot.picshop.menus.StickersMenu;
	import ca.esdot.picshop.menus.StickersMenuMediator;
	import ca.esdot.picshop.menus.TopMenu;
	import ca.esdot.picshop.menus.TopMenuMediator;
	import ca.esdot.picshop.services.AndroidPurchaseService;
	import ca.esdot.picshop.services.FacebookAS3Service;
	import ca.esdot.picshop.services.FacebookGoViralService;
	import ca.esdot.picshop.services.IFacebookService;
	import ca.esdot.picshop.services.IOSPurchaseService;
	import ca.esdot.picshop.services.InstagramService;
	import ca.esdot.picshop.services.SupersonicService;
	import ca.esdot.picshop.services.TapjoyService;
	import ca.esdot.picshop.views.EditView;
	import ca.esdot.picshop.views.EditViewMediator;
	import ca.esdot.picshop.views.FacebookAuthForm;
	import ca.esdot.picshop.views.FacebookAuthFormMediator;
	import ca.esdot.picshop.views.FacebookBrowser;
	import ca.esdot.picshop.views.FacebookBrowserMediator;
	import ca.esdot.picshop.views.FullScreenCropViewMediator;
	import ca.esdot.picshop.views.FullscreenCropView;
	import ca.esdot.picshop.views.SaveView;
	import ca.esdot.picshop.views.SaveViewMediator;
	import ca.esdot.picshop.views.SettingsPanel;
	import ca.esdot.picshop.views.SettingsPanelMediator;
	import ca.esdot.picshop.views.TwitterAuthForm;
	import ca.esdot.picshop.views.TwitterAuthFormMediator;
	import ca.esdot.picshop.views.UnlockFeaturesView;
	import ca.esdot.picshop.views.UnlockFeaturesViewMediator;
	
	import org.robotlegs.base.ContextEvent;
	import org.robotlegs.mvcs.Context;
	
	public class MainContext extends Context
	{
		public function MainContext(contextView:DisplayObjectContainer=null, autoStartup:Boolean=true) {
			super(contextView, autoStartup);
		}
		
		override public function startup():void {
			
		//Injections
			injector.mapSingleton(MainModel);
			injector.mapSingleton(AndroidPurchaseService);
			injector.mapSingleton(IOSPurchaseService);
			injector.mapSingleton(InstagramService);
			injector.mapSingleton(SupersonicService);
			
			//Map facebook service
			if(GoViral.isSupported()){
				//injector.mapSingletonOf(IFacebookService, FacebookAS3Service);
				injector.mapSingletonOf(IFacebookService, FacebookGoViralService);
				
			} else {
				injector.mapSingletonOf(IFacebookService, FacebookAS3Service);
			}
			
		//Mediators
			//Main View
			mediatorMap.mapView(MainView, MainViewMediator);
			
			//Top Menu
			mediatorMap.mapView(TopMenu, TopMenuMediator);
			
			//Editing View
			mediatorMap.mapView(EditView, EditViewMediator);
			
			//UnlockFeatures View (IAP)
			mediatorMap.mapView(UnlockFeaturesView, UnlockFeaturesViewMediator);
			
			//Facewbook Browser
			mediatorMap.mapView(FacebookBrowser, FacebookBrowserMediator);
			
			//Fullscreen Crop View
			mediatorMap.mapView(FullscreenCropView, FullScreenCropViewMediator);
			
			//Save View
			mediatorMap.mapView(SaveView, SaveViewMediator);
			
			//Settings/Options
			mediatorMap.mapView(SettingsPanel, SettingsPanelMediator);
			
			//Basic Tools
			mediatorMap.mapView(BasicToolsMenu, BasicToolsMenuMediator);
			
			//Filters
			mediatorMap.mapView(FiltersMenu, FiltersMenuMediator);
			
			//Borders
			mediatorMap.mapView(BordersMenu, BordersMenuMediator);
			
			//Extras
			mediatorMap.mapView(ExtrasMenu, ExtrasMenuMediator);
			
			//Stickers
			mediatorMap.mapView(StickersMenu, StickersMenuMediator);
			
			//Twitter
			mediatorMap.mapView(TwitterAuthForm, TwitterAuthFormMediator);
			
			//Facebook
			mediatorMap.mapView(FacebookAuthForm, FacebookAuthFormMediator);
		
		//Commands
			
			//Intro Video
			commandMap.mapEvent(CommandEvent.SHOW_INTRO_VIDEO, ShowIntroVideoCommand, CommandEvent);
			
			//App Resize 
			commandMap.mapEvent(CommandEvent.RESIZE_APP, ResizeAppCommand, CommandEvent);
			
			//Tips
			commandMap.mapEvent(ShowTipEvent.SAVE, ShowTipCommand, ShowTipEvent);
			//commandMap.mapEvent(ShowTipEvent.MEME, ShowTipCommand, ShowTipEvent);
			commandMap.mapEvent(ShowTipEvent.COMPARE, ShowTipCommand, ShowTipEvent);
			commandMap.mapEvent(ShowTipEvent.OPEN_IMAGE, ShowTipCommand, ShowTipEvent);
			commandMap.mapEvent(ShowTipEvent.SETTINGS, ShowTipCommand, ShowTipEvent);
			commandMap.mapEvent(ShowTipEvent.UNDO_BUTTON_DRAG, ShowTipCommand, ShowTipEvent);
			commandMap.mapEvent(ShowTipEvent.PINCH_TO_ZOOM, ShowTipCommand, ShowTipEvent);
			commandMap.mapEvent(ShowTipEvent.EDIT_MENU, ShowTipCommand, ShowTipEvent);
			
			//Change Color
			commandMap.mapEvent(ChangeColorEvent.CHANGE_ACCENT, ChangeColorCommand, ChangeColorEvent);
			
			//Image Edits
			commandMap.mapEvent(StartEditEvent.BASIC, EditImageCommand, StartEditEvent);
			commandMap.mapEvent(StartEditEvent.FILTER, EditImageCommand, StartEditEvent);
			commandMap.mapEvent(StartEditEvent.BORDER, EditImageCommand, StartEditEvent);
			commandMap.mapEvent(StartEditEvent.EXTRAS, EditImageCommand, StartEditEvent);
			
			//Add a new Image Layer
			commandMap.mapEvent(CommandEvent.ADD_IMAGE_LAYER, AddImageLayerCommand, CommandEvent);
			commandMap.mapEvent(ShowStickersEvent.SHOW_DIALOG, ShowStickersCommand, ShowStickersEvent);
			
			//Save & Share Image
			commandMap.mapEvent(SaveImageEvent.SAVE_IMAGE, SaveImageCommand, SaveImageEvent);
			
			commandMap.mapEvent(ShareEvent.EMAIL, ShareCommand, ShareEvent);
			commandMap.mapEvent(ShareEvent.EMAIL_POST, PostEmailCommand, ShareEvent);
			
			commandMap.mapEvent(ShareEvent.FACEBOOK, ShareCommand, ShareEvent);
			commandMap.mapEvent(ShareEvent.FACEBOOK_POST, PostFacebookCommand, ShareEvent);
			
			commandMap.mapEvent(ShareEvent.INSTAGRAM, ShareCommand, ShareEvent);
			
			commandMap.mapEvent(ShareEvent.TWITTER, ShareCommand, ShareEvent);
			commandMap.mapEvent(ShareEvent.TWITTER_POST, PostTwitterCommand, ShareEvent);
			
			commandMap.mapEvent(ShareEvent.ANDROID, ShareAndroidCommand, ShareEvent);

			//Manage Views
			commandMap.mapEvent(ChangeViewEvent.CHANGE, ChangeViewCommand, ChangeViewEvent);
			commandMap.mapEvent(ChangeViewEvent.BACK, ChangeViewCommand, ChangeViewEvent);
			
			//Settings
			commandMap.mapEvent(SettingsEvent.SAVE, SettingsCommand, SettingsEvent);
			commandMap.mapEvent(SettingsEvent.LOAD, SettingsCommand, SettingsEvent);
			
			//Open Image
			commandMap.mapEvent(OpenImageEvent.TEST, OpenImageCommand, OpenImageEvent);
			commandMap.mapEvent(OpenImageEvent.CAMERA, OpenImageCommand, OpenImageEvent);
			commandMap.mapEvent(OpenImageEvent.GALLERY, OpenImageCommand, OpenImageEvent);
			commandMap.mapEvent(OpenImageEvent.BITMAP_DATA, OpenImageCommand, OpenImageEvent);
			
			commandMap.mapEvent(OpenImageEvent.FACEBOOK, OpenFacebookImageCommand, OpenImageEvent);
			
			//Market Links
			commandMap.mapEvent(CommandEvent.OPEN_PURCHASE_LINK, OpenDownloadCommand, CommandEvent);
			commandMap.mapEvent(CommandEvent.OPEN_REVIEW_LINK, OpenDownloadCommand, CommandEvent);
			commandMap.mapEvent(CommandEvent.OPEN_FRAMESHOP_LINK, OpenDownloadCommand, CommandEvent);
			
			//IAPS
			commandMap.mapEvent(CommandEvent.IN_APP_PURCHASE, InAppPurchaseCommand, CommandEvent);
			commandMap.mapEvent(CommandEvent.IN_APP_RESTORE, InAppRestoreCommand, CommandEvent);

			//Ads / OFferwall 
			commandMap.mapEvent(CommandEvent.SHOW_OFFERWALL, ShowOfferwallCommand, CommandEvent);
			
			//Upgrade Prompt
			commandMap.mapEvent(UnlockEvent.UNLOCK, UpgradeDialogCommand, UnlockEvent);
			
			
			//Review Prompt
			commandMap.mapEvent(CommandEvent.PROMPT_FOR_REVIEW, PromptForReviewCommand, CommandEvent);
			
			commandMap.mapEvent(CommandEvent.SHOW_VERSION_DIALOG, ShowVersionDialogCommand, CommandEvent);
			
		//Trigger StartupCommand
			commandMap.mapEvent(ContextEvent.STARTUP_COMPLETE, StartupCommand, ContextEvent);
			super.startup();
		}
		
		public function openImageUrl(invokeUrl:String):void {
			if(!invokeUrl){ return; }
			var openEvent:OpenImageEvent = new OpenImageEvent(OpenImageEvent.URL, null, invokeUrl);
			commandMap.execute(OpenImageCommand, openEvent, OpenImageEvent);
		}
	}
}
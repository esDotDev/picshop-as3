package ca.esdot.picshop.commands
{
	import com.doitflash.air.extensions.packagemanager.PackageManager;
	
	import flash.desktop.NativeApplication;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.net.SharedObject;
	import flash.utils.setTimeout;
	
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.image.CoreImage;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.commands.events.ChangeColorEvent;
	import ca.esdot.picshop.commands.events.ChangeViewEvent;
	import ca.esdot.picshop.commands.events.CommandEvent;
	import ca.esdot.picshop.commands.events.OpenImageEvent;
	import ca.esdot.picshop.commands.events.SettingsEvent;
	import ca.esdot.picshop.commands.events.ShowTipEvent;
	import ca.esdot.picshop.components.Slider;
	import ca.esdot.picshop.data.UnlockableFeatures;
	import ca.esdot.picshop.data.ViewTypes;
	import ca.esdot.picshop.dialogs.TitleDialog;
	import ca.esdot.picshop.services.AndroidPurchaseService;
	import ca.esdot.picshop.services.IFacebookService;
	import ca.esdot.picshop.services.IOSPurchaseService;
	import ca.esdot.picshop.services.InstagramService;
	import ca.esdot.picshop.services.TapjoyService;
	import ca.esdot.picshop.utils.AnalyticsManager;
	
	import org.robotlegs.mvcs.Command;
	
	public class StartupCommand extends Command
	{
		[Inject]
		public var mainModel:MainModel;
		
		[Inject]
		public var androidPurchases:AndroidPurchaseService;
		
		[Inject]
		public var iosPurchases:IOSPurchaseService;
		
		[Inject]
		public var facebookService:IFacebookService;
		
		[Inject]
		public var instagramService:InstagramService;
		
		override public function execute():void {
			//Clear saved history
			var so:SharedObject = SharedObject.getLocal("data");
			so.data.history = [];
			so.flush();
	
			//Load saved settings
			dispatch(new SettingsEvent(SettingsEvent.LOAD));
			
			//Bootstrap analytics
			AnalyticsManager.init(contextView.stage, mainModel.isAppLocked);
			AnalyticsManager.startup();
			if(mainModel.isFirstInstall){
				AnalyticsManager.firstInstall(); 
			}
			
			//Get appId
			var appXml:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appXml.namespace();
			var appId:String = appXml.ns::id[0];
			
			if(appId.indexOf("Lite") == -1){
				facebookService.init("287066698013735");
			} else {
				facebookService.init("121564374665935");
			}
			
			//Init Android Purchase
			if(DeviceUtils.onAndroid){
				androidPurchases.restoreWhenReady = mainModel.isFirstInstall;
				androidPurchases.init();
			}
			
			if(DeviceUtils.onIOS){
				//Init IOS Purchase
				var productIdList:Vector.<String>=new Vector.<String>();
				productIdList.push(IOSPurchaseService.UNLOCK_ID);
				iosPurchases.init(productIdList);
				
				//Init CoreImage library
				//CoreImage.init();
			}
			
			//Init components
			DeviceUtils.init(contextView.stage);
			Slider.radius = DeviceUtils.hitSize * .25;
			
			//Restore accent color
			if(mainModel.settings){
				dispatch(new ChangeColorEvent(ChangeColorEvent.CHANGE_ACCENT, mainModel.settings.accentColor));
				mainModel.settings.numStartups++;
				trace("SETTINGS LOADED. Num Startups: " + mainModel.settings.numStartups);
			}
			
			//Load initial View
			dispatch(new ChangeViewEvent(ChangeViewEvent.CHANGE, ViewTypes.EDIT));
			
			//Check scratchData
			var scratchData:BitmapData = mainModel.loadScratchFile();
			if(scratchData){
				var openImageEvent:OpenImageEvent = new OpenImageEvent(OpenImageEvent.BITMAP_DATA, scratchData);
				dispatch(openImageEvent);
			}
			
			//Show initial start tip
			if(!scratchData && mainModel.settings.numSaves < 5){
				dispatch(new ShowTipEvent(ShowTipEvent.OPEN_IMAGE, (contextView as MainView).editView.editMenu.imageButton));
			}
			
			//APPGRATIS Unlock Check
			var skipVersionCheck:Boolean = false;
			
			if(mainModel.settings.numSaves >= 2 && mainModel.settings.numFrameshopPrompts < 3){
				(contextView as MainView).showFrameshopPrompt();
				mainModel.settings.numFrameshopPrompts++;
				skipVersionCheck = true;
			}
			
			//Check for first install of this version?
			if(!mainModel.settings.versionHash){ mainModel.settings.versionHash = {}; }
			if(!skipVersionCheck){
				checkVersion();
			}
			
			//Record startup version
			dispatch(new SettingsEvent(SettingsEvent.SAVE));
			
			
			trace("[StartupCommand] Startup Complete");
		}
		
		protected function onFreeUnlockDialogClosed(event:Event):void {
			setTimeout(checkVersion, 50);
			commandMap.release(this);
		}
		
		protected function checkVersion():void {
			if(!mainModel.settings.versionHash[mainModel.versionNumber]){
				dispatch(new CommandEvent(CommandEvent.SHOW_VERSION_DIALOG));
			}
			mainModel.settings.versionHash[mainModel.versionNumber] = true;
			dispatch(new SettingsEvent(SettingsEvent.SAVE));
		}
		
	}
}
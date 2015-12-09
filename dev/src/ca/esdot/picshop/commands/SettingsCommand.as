package ca.esdot.picshop.commands
{
	import ca.esdot.lib.net.AnalyticsTracker;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.commands.events.SettingsEvent;
	import ca.esdot.picshop.data.SettingsData;
	import ca.esdot.picshop.utils.AnalyticsManager;
	
	import flash.net.SharedObject;
	import flash.net.registerClassAlias;
	
	import org.robotlegs.mvcs.Command;
	
	public class SettingsCommand extends Command
	{
		[Inject]
		public var event:SettingsEvent;
		
		[Inject]
		public var model:MainModel;
		
		override public function execute():void {
			registerClassAlias("ca.esdot.picshop.data.SettingsData", ca.esdot.picshop.data.SettingsData);
			var so:SharedObject = SharedObject.getLocal("data");
			//SAVE
			if(event.type == SettingsEvent.SAVE){
				so.data.settings = model.settings;
				so.flush();
			} 
			//LOAD
			else {
				so = SharedObject.getLocal("data");
				var settings:SettingsData = new SettingsData();
				if(so.data.settings) {
					settings.t1 = so.data.settings.t1;
					settings.t2 = so.data.settings.t2;
					settings.f1 = so.data.settings.f1;
					settings.f2 = so.data.settings.f2;
					settings.accentColor = so.data.settings.accentColor;
					settings.bgType = so.data.settings.bgType;
					settings.numSaves = so.data.settings.numSaves;
					settings.numOpenImage = so.data.settings.numOpenImage;
					settings.numFrameshopPrompts = so.data.settings.numFrameshopPrompts;
					settings.numUndo = so.data.settings.numUndo;
					settings.numStartups = so.data.settings.numStartups;
					settings.numSettingsOpened = so.data.settings.numSettingsOpened;
					settings.isAppLocked = so.data.settings.isAppLocked;
					settings.isPromo = so.data.settings.isPromo;
					settings.versionHash = so.data.settings.versionHash;
					settings.reviewAccepted = so.data.settings.reviewAccepted;
					
				//ADDED in v3.0 
					settings.unlockedFeatures = so.data.settings.unlockedFeatures;
					settings.numCoins = so.data.settings.numCoins;
					
				} else {
					model.isFirstInstall = true;
				}
				trace("Startup: ", settings.numStartups);
				settings.numStartups++;
				model.settings = settings;
			}
		}
		
		
	}
}
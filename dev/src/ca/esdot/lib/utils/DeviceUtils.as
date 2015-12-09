package ca.esdot.lib.utils {
	
	import flash.display.Stage;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	
	public class DeviceUtils
	{
		public static const DESKTOP:String = "Desktop";
		public static const ANDROID:String = "Android";
		public static const AMAZON:String = "Amazon";
		public static const NOOK:String = "Nook";
		public static const PLAYBOOK:String = "PlayBook";
		public static const IPAD:String = "iPad";
		public static const IPHONE:String = "iPhone";
		public static const BB10:String = "bb10";
		
		public static var defaultDevice:String = BB10;
		public static var deviceOverride:String;
		
		protected static var _dialogSize:Rectangle;
		protected static var _deviceName:String;
		protected static var _stage:Stage;
		protected static var _screenScale:Number;
		protected static var stageWidth:Number;
		
		public static function get fontSize():Number {
			var size:Number = Capabilities.screenDPI / 10;
			size = size * tabletScale;
			return size;
		}
		
		public static function init(stage:Stage):void {
			_stage = stage;
			stageWidth = Math.max(_stage.stageWidth, _stage.stageHeight);
		}
		
		/********************************
		 * DETERMINE DEVICE TYPE
		 ********************************/
		
		public static function get deviceName():String {
			if(!_deviceName){
				_deviceName = defaultDevice;
				var os:String = Capabilities.os.toLowerCase();
				if(os.indexOf("playbook") > -1){
					_deviceName = PLAYBOOK;
				} else if(os.indexOf("blackberry") > -1){
					_deviceName = BB10;
				} else if(os.indexOf("iphone") > -1){
					//iPhone OS 4.3.3 iPad2,1
					_deviceName = (os.indexOf("ipad") > -1) ? IPAD : IPHONE;
				} else if(Capabilities.manufacturer.toLowerCase().indexOf("android") > -1 || 
					os.indexOf("android") > -1){
					_deviceName = ANDROID;
				}
			}
			
			if(deviceOverride){
				_deviceName = deviceOverride;
			}
			
			return _deviceName;
		}
		
		public static function get isRetina():Boolean {
			return stageWidth > 1600;
		}
		
		public static function get divSize():int {
			return isRetina? 2 : 1;
		}
		
		public static function get dialogWidth():int { return dialogSize.width; }
		public static function get dialogHeight():int { return dialogSize.height; }
		public static function get dialogSize():Rectangle {
			if(!_dialogSize){
				_dialogSize = new Rectangle();
				var minWidth:int = Capabilities.screenDPI * 2.5;
				_dialogSize.width = Math.max(minWidth, stageWidth * .65);
				_dialogSize.height = _dialogSize.width * .6;
				if(_dialogSize.height < 250){
					_dialogSize.height = 250;
				}
			}
			return _dialogSize;	
		}
		
		public static function get onDesktop():Boolean { return deviceName == DESKTOP; }
		public static function get onPlayBook():Boolean { return deviceName == PLAYBOOK; }	
		public static function get onBB10():Boolean { return deviceName == BB10; }	
		public static function get onAndroid():Boolean { return deviceName == ANDROID; }	
		public static function get onAmazon():Boolean { return deviceName == AMAZON; }
		public static function get onNook():Boolean { return deviceName == NOOK; }
		public static function get onIOS():Boolean { return deviceName == IPHONE || deviceName == IPAD; }
		
		public static function get isTablet():Boolean { 
			//The following conditions make you a tablet...
			return (
				
				//Physical width of > 6"
				(stageWidth / Capabilities.screenDPI > 5) ||
				
				//Explicitly identified as a tablet
		  		deviceName == PLAYBOOK || deviceName == IPAD
			); 
		}
		
		public static function get tabletScale():Number {
			if(!isTablet){ return 1; }
			return (stageWidth / Capabilities.screenDPI) / 4;
		}
		
		
	
	/**************************************
	 * UTILITIES
	 ***********************************/
		
		public static function get cameraRoll():File {
			switch(deviceName){
				case ANDROID:
					return File.userDirectory.resolvePath("DCIM" + File.separator + "Camera");
					
				case PLAYBOOK:
					return File.desktopDirectory.resolvePath("../camera");
			}
			//iPhone does not provide access.
			return null;
		}
		
		public static function get paddingLarge():int { return DeviceUtils.screenScale * 40; };
		public static function get paddingSmall():int { return DeviceUtils.screenScale * 10; };
		public static function get padding():int { return DeviceUtils.screenScale * 20; };
		
		public static function get screenScale():Number {
			if(!_stage){
				trace("[MobileUtils.screenScale] Warning: Stage has not been set"); 
				_screenScale = 1;
			} else {
				_screenScale = (Capabilities.screenDPI / 160 + stageWidth/1024) / 2;
			}
			return _screenScale;
		}
		
		public static function get hitSize():int {
			
			var size:int = Capabilities.screenDPI / 2.6;
			size *= tabletScale;
			if(stageWidth <= 500){
				size *= 1.15;
			}
			return size;
		}
		
	/********************************
	 * MARKETPLACE LINKS
	 ********************************/
		
		/**
		 * Android market uses the application id to search your app, ie: com.domain.MyApp
		 **/
		public static function getAndroidMarketURL(packageId:String):String {
			return "market://details?id=air." + packageId;
		}
		
		/**
		 * Playbook market uses the appId assigned to your app from the Blackberry Vendor Portal.
		 **/
		public static function getPlayBookMarketURL(appId:String):String {
			return "appworld://content/" + appId;
		}
		
		/**
		 * iOS uses the appId assigned in iTunes Connect
		 **/
		public static function getITunesMarketURL(appId:String):String {
			return "http://itunes.apple.com/us/app/id" + appId;
		}
		
		public static function getAmazonMarketURL(packageId:String):String {
			return "http://www.amazon.com/gp/mas/dl/android?p=air." + packageId;
		}
		
	}
}
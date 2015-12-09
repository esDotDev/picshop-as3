package ca.esdot.picshop.views
{
	
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.events.UnlockEvent;
	
	import flash.display.Bitmap;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import org.osflash.signals.Signal;
	
	import swc.CloseButton;

	public class AdView extends SizableView
	{
		//[Embed("/assets/banners/ColorUp1.png")]
		public static var ColorUp1Banner:Class;
		
		//[Embed("/assets/banners/ColorUp1-sm.png")]
		public static var ColorUp1Banner_sm:Class;
		
		//[Embed("/assets/banners/SnowBomber1.png")]
		public static var SnowBomber1:Class;
		
		//[Embed("/assets/banners/SnowBomber1-sm.png")]
		public static var SnowBomber1_sm:Class;
		
		
		//[Embed("/assets/banners/SnowBomber2.png")]
		public static var SnowBomber2:Class;
		
		//[Embed("/assets/banners/SnowBomber2-sm.png")]
		public static var SnowBomber2_sm:Class;
		
		
		//[Embed("/assets/banners/SnowBomber3.png")]
		public static var SnowBomber3:Class;
		
		//[Embed("/assets/banners/SnowBomber3-sm.png")]
		public static var SnowBomber3_sm:Class;
		
		
		protected const SNOWBOMBER_URL_PLAYBOOK:String = "appworld://content/64104/";
		protected const SNOWBOMBER_URL_IOS:String = "http://itunes.apple.com/us/app/snowbomber-lite/id478654005?ls=1&mt=8";
		protected const SNOWBOMBER_URL_ANDROID:String = "market://details?id=air.ca.esdot.SnowBomberLite&hl=en";
		protected const SNOWBOMBER_URL_AMAZON:String = "http://www.amazon.com/gp/mas/dl/android?p=air.ca.esdot.SnowBomberLite";
		
		protected const COLORUP_URL_PLAYBOOK:String = "appworld://content/49004/";
		protected const COLORUP_URL_IOS:String = "http://itunes.apple.com/us/app/colorup-pro-color-splash-editor/id445787283?mt=8";
		protected const COLORUP_URL_ANDROID:String = "market://details?id=air.ca.esdot.ColorUpPro";
		protected const COLORUP_URL_AMAZON:String = "http://www.amazon.com/gp/mas/dl/android?p=air.ca.esdot.ColorUpLite";
		
		//protected var adUrl:String = "http://esdot.ca/touchup/ads.html";
		protected var adSize:Rectangle = new Rectangle(0, 0, 480, 80);
		
		protected var padding:int = 10;
		protected var closeButton:Sprite;
		protected var bg:Sprite;
		
		protected var adCount:int = 1;
		protected var adList:Array;
		protected var adListSmall:Array;
		
		protected var bitmap:Bitmap;
		
		protected var adIndex:int;
		protected var upgradeDialog:Object;
		protected var currentAdList:Array;
		
		public var closeClicked:Signal;
		
		public function AdView() {
			adList = [];
			adListSmall = [];
			currentAdList = adList;
			
			closeClicked = new Signal();
			
			bg = new Sprite();
			bg.graphics.beginFill(0x0);
			bg.graphics.drawRect(0,0,1,1);
			bg.graphics.endFill();
			addChild(bg);
			
			closeButton = new swc.CloseButton();
			closeButton.x = closeButton.y = padding;
			addChild(closeButton);
			
			adIndex = 0;
			adList = [new SnowBomber1(),new SnowBomber2(),new SnowBomber3(), new ColorUp1Banner()];
			adListSmall = [new SnowBomber1_sm(),new SnowBomber2_sm(),new SnowBomber3_sm(), new ColorUp1Banner_sm()];
			
			bitmap = new Bitmap(adList[adIndex].bitmapData);
			bitmap.smoothing = true;
			addChild(bitmap);
			
			addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
			
			currentAdList = adList;
		}
		
		public function set useSmall(value:Boolean):void {
			currentAdList = (value)? adListSmall : adList;
			bitmap.bitmapData = currentAdList[adIndex].bitmapData;
			bitmap.smoothing = true;
			updateLayout();
		}
		
		protected function onClick(event:MouseEvent):void {
			if(event.target is SimpleButton){
				dispatchEvent(new UnlockEvent(UnlockEvent.UNLOCK));
			} else {
				var url:String;
				if(adIndex == adList.length - 1){
					url = (DeviceUtils.onIOS)? COLORUP_URL_IOS : COLORUP_URL_ANDROID;
					if(DeviceUtils.onAmazon){
						url = COLORUP_URL_AMAZON;
					}
				} else {
					url = (DeviceUtils.onIOS)? SNOWBOMBER_URL_IOS : SNOWBOMBER_URL_ANDROID;
					if(DeviceUtils.onAmazon){
						url = SNOWBOMBER_URL_AMAZON;
					}
				}
				navigateToURL(new URLRequest(url));
			}
		}
		
		public function random():void {
			adIndex = Math.floor(Math.random()* currentAdList.length);
			if(adIndex > 0 && adIndex == currentAdList.length){ adIndex--; }
			
			bitmap.bitmapData = currentAdList[adIndex].bitmapData;
			bitmap.smoothing = true;
		}
		
		public function next():void {
			if(++adIndex > adList.length-1){
				adIndex = 0;
			}
			bitmap.bitmapData = currentAdList[adIndex].bitmapData;
			bitmap.smoothing = true;
		}
		
		
		override public function updateLayout():void {
			bg.height = bitmap.height;
			bg.width = closeButton.width + padding +  bitmap.width;
			closeButton.y = bg.height - closeButton.height >> 1;
			bitmap.x = closeButton.x + closeButton.width + padding;
		}
	}
}
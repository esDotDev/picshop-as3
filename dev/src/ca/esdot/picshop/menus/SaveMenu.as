package ca.esdot.picshop.menus
{
	import com.milkmangames.nativeextensions.GoViral;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import assets.Bitmaps;
	
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.components.TileMenu;
	import ca.esdot.picshop.components.buttons.TileButton;
	import ca.esdot.picshop.data.colors.ColorTheme;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	import ca.esdot.picshop.services.InstagramService;
	
	import swc.LockIcon;
	
	public class SaveMenu extends TileMenu
	{
		public var backButton:TileButton;
		
		public var facebookButton:TileButton;
		public var facebookLock:Sprite;
		
		public var twitterButton:TileButton;
		public var twitterLock:Sprite;
		
		override protected function createTiles():void {
			tileList = [];
			
			tileList.push(SaveMenuTypes.SAVE);
			if(DeviceUtils.onAndroid){
				tileList.push(SaveMenuTypes.SHARE);
			} 
			
			if(GoViral.isSupported() && GoViral.goViral.isEmailAvailable()){
				tileList.push(SaveMenuTypes.EMAIL);
			}
			
			if(DeviceUtils.onIOS || (DeviceUtils.onAndroid && !DeviceUtils.onAmazon) || InstagramService.isSupported){
				tileList.push(SaveMenuTypes.INSTAGRAM);	
			}
			
			if(GoViral.isSupported() && GoViral.goViral.isTweetSheetAvailable()){
				tileList.push(SaveMenuTypes.TWITTER);	
			}
			tileList.push(SaveMenuTypes.FACEBOOK);
			
			
			facebookLock = new swc.LockIcon();
			twitterLock = new swc.LockIcon();
			
			var button:TileButton;
			var icon:Bitmap;
			
			for(var i:int = 0; i < tileList.length; i++){
				button = new TileButton("", null, .4);
				
				switch(tileList[i]){
					
					case SaveMenuTypes.SAVE:
						button.icon = new Bitmaps.saveToDeviceIcon();
						button.label  = SaveMenuTypes.SAVE;
						button.fontSize = DeviceUtils.fontSize * .75;
						button.bg.visible = false;
						ColorTheme.colorSprite(button.icon);
						break;
					
					case SaveMenuTypes.SHARE:
						button.icon = new Bitmaps.shareIcon();
						button.label  = SaveMenuTypes.SHARE;
						button.fontSize = DeviceUtils.fontSize * .75;
						button.bg.visible = false;
						ColorTheme.colorSprite(button.icon);
						break;
					
					case SaveMenuTypes.EMAIL:
						button.icon = new Bitmaps.gmailIcon();
						button.bg.visible = false;
						break;
					
					case SaveMenuTypes.FACEBOOK:		
						button.bg.bitmapData = SharedBitmaps.facebookBlue;
						button.icon = new Bitmaps.facebookLogo();
						facebookButton = button;
						break;
					
					case SaveMenuTypes.TWITTER:
						button.bg.bitmapData = SharedBitmaps.twitterBlue;
						button.icon = new Bitmaps.twitterLogo();
						twitterButton = button;
						break;
					
					case SaveMenuTypes.INSTAGRAM:
						button.bg.bitmapData = SharedBitmaps.instagramBlue;
						button.icon = new Bitmaps.instagramLogo();
						break;
				}
				button.showDivider = true;
				button.addEventListener(MouseEvent.CLICK, onButtonClicked, false, 0, true);
				button.addEventListener(MouseEvent.MOUSE_DOWN, onButtonDown, false, 0, true);
				
				buttonList[i] = button;
				typesByButton[button] = tileList[i];
				
				container.addChild(button);
			}
			
			backButton = new TileButton("", new Bitmaps.backArrow());
			ColorTheme.colorSprite(backButton.icon);
			
			backButton.showDivider = true;
			backButton.bg.visible = false;
			addChild(backButton);
		}
		
		override public function updateLayout():void {
			backButton.y = 1;
			backButton.setSize(viewHeight * .5, viewHeight - 2);
			scroller.x = backButton.width;
			super.updateLayout();
		}
		
		override protected function positionTiles():void {
			var xOffset:int = 0;
			for(var i:int = 0; i < tileList.length; i++){ 
				var button:TileButton = buttonList[i] as TileButton;
				button.setSize(viewHeight * 1.15, viewHeight - 2);
				button.x = xOffset;
				xOffset += button.width;
			}
			facebookLock.x = button.width - facebookLock.width >> 1;
			facebookLock.y = button.height - facebookLock.height - button.height * .1;
			
			twitterLock.x = button.width - twitterLock.width >> 1;
			twitterLock.y = button.height - twitterLock.height - button.height * .1;
			
		}
	}
}
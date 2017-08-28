package ca.esdot.picshop.menus
{
	import com.gskinner.motion.GTween;
	
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	
	import assets.Bitmaps;
	
	import ca.esdot.lib.data.TweenConstants;
	import ca.esdot.lib.image.ImageProcessing;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.components.buttons.TileButton;
	import ca.esdot.picshop.data.colors.AccentColors;
	import ca.esdot.picshop.data.colors.ColorTheme;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	import ca.esdot.picshop.events.UnlockEvent;
	import ca.esdot.picshop.views.SettingsPanel;
	
	import org.osflash.signals.Signal;
	
	import swc.Logo;
	import swc.UnlockButton;

	public class TopMenu extends SizableView {
		
		public var picText:TextField;
		public var shopText:TextField;
		public var liteText:TextField;
		
		public var versionText:TextField;	
		
		public var lockButton:Sprite;
		
		public var logo:Sprite;
		
		public var closeClicked:Signal;
		public var compareDown:Signal;
		public var compareUp:Signal;
		
		protected var settingsPanel:SettingsPanel;
		protected var underlay:Sprite;
		protected var underlayTop:Bitmap;
		protected var tween:GTween;
		
		public var closeButton:Sprite;
		public var compareButton:Sprite;
		
		protected var versionContainer:Sprite;
		protected var divider:Bitmap;
		protected var bg:Sprite;
		
		public var undoButton:TileButton;
		public var redoButton:TileButton;
		private var trialMode:Boolean;
		private var versionHit:Sprite;
		
		public function TopMenu() {
			var viewAssets:swc.Logo = new swc.Logo();
			
			bg = new Sprite();
			bg.addChild(new Bitmap(SharedBitmaps.bgColor));
			bg.addEventListener(MouseEvent.CLICK, onCloseSettingsClicked, false, 0, true);
			addChild(bg);
			
			versionText = viewAssets.versionText;
			
			updateVersionColor();
			ColorTheme.whiteModeChanged.add(onWhiteModeChanged);
			
			shopText = viewAssets.shopText;
			picText = viewAssets.picText;
			liteText = viewAssets.liteText;
			
			var descriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = descriptor.namespaceDeclarations()[0];
			var version:String = descriptor.ns::versionNumber;
			var split:Array = version.split(".");
			versionText.text = split[0] + "." + split[1] + "." + split[2];
			versionText.y = 0;
			
			logo = new Sprite();
			logo.addChild(viewAssets.picText);
			logo.addChild(viewAssets.shopText);
			logo.addChild(viewAssets.liteText);
			addChild(logo);
			
			versionContainer = new Sprite();
			versionContainer.addChild(viewAssets.versionText);
			addChild(versionContainer);
			
			divider = new Bitmap(SharedBitmaps.accentColor);
			addChild(divider);
			
			versionHit = new Sprite();
			versionHit.alpha = 0;
			versionHit.addChild(new Bitmap(SharedBitmaps.facebookBlue));
			versionHit.addEventListener(MouseEvent.MOUSE_DOWN, onShowSettingsClicked, false, 0, true);
			addChild(versionHit);
			
			closeButton = new Sprite();
			var bmp:Bitmap = new Bitmaps.closeAppButton();
			bmp.smoothing = true;
			closeButton.addChild(bmp);
			addChild(closeButton);
			closeButton.addEventListener(MouseEvent.CLICK, onCloseClicked, false, 0, true);
			closeClicked = new Signal();
			showCloseButton(false);
			
			compareButton = new Sprite();
			bmp = (ColorTheme.whiteMode)? new Bitmaps.compareButtonWhite() : new Bitmaps.compareButton();
			bmp.smoothing = true;
			compareButton.addChild(bmp);
			addChildAt(compareButton, 0);
			compareButton.addEventListener(MouseEvent.MOUSE_DOWN, onCompareDown, false, 0, true);
			showCompareButton(false);
			
			
			compareDown = new Signal();
			compareUp = new Signal();
			
			undoButton = new TileButton("", new Bitmaps.undoIcon());
			undoButton.bg.visible = false;
			addChild(undoButton);
			isUndoEnabled = false;
			
			var redoBitmap:Bitmap = new Bitmaps.undoIcon();
			ImageProcessing.flipBitmap(redoBitmap.bitmapData, false, true);
			redoButton = new TileButton("", redoBitmap);
			redoButton.bg.visible = false;
			addChild(redoButton);
			isRedoEnabled = false;
			
			underlayTop = new Bitmap(SharedBitmaps.bgColor);
			underlayTop.addEventListener(MouseEvent.CLICK, onCloseSettingsClicked, false, 0, true);
			underlayTop.alpha = .5;
			addChild(underlayTop);
			//Set accent color
			accentColor = AccentColors.DEFAULT;
			
			
			
		}
		
		protected function updateVersionColor():void {
			ColorTheme.colorTextfield(versionText, ColorTheme.whiteMode? ColorTheme.LIGHTER_GREY : 0xFFFFFF);
		}
		
		protected function onWhiteModeChanged(value:Boolean):void {
			updateVersionColor();
			
			var bmp:Bitmap = (ColorTheme.whiteMode)? new Bitmaps.compareButtonWhite() : new Bitmaps.compareButton();
			bmp.smoothing = true;
			compareButton.removeChildren();
			compareButton.addChild(bmp);
		}
		
		protected function onCloseClicked(event:MouseEvent):void {
			closeClicked.dispatch();
		}
		
		protected function onCompareDown(event:MouseEvent):void {
			compareDown.dispatch();
			PicShop.stage.addEventListener(MouseEvent.MOUSE_UP, onCompareUp);
		}
		
		protected function onCompareUp(event:MouseEvent):void {
			compareUp.dispatch();
			PicShop.stage.removeEventListener(MouseEvent.MOUSE_UP, onCompareUp);
		}
		
		public function set isLocked(value:Boolean):void {
			if(value){
				trialMode = true;
				if(!lockButton){
					lockButton = new swc.UnlockButton();
					lockButton.addEventListener(MouseEvent.CLICK, onUnlockClicked, false, 0, true);
				}
				addChild(lockButton);
				liteText.visible = true;
				versionText.x = liteText.x + liteText.width;
			} else {
				liteText.visible = false;
				versionText.x = liteText.x;
				trialMode = false;
				if(lockButton && contains(lockButton)){
					removeChild(lockButton);
				}
			}
			updateLayout();
		}
		
		protected function onUnlockClicked(event:MouseEvent):void {
			dispatchEvent(new UnlockEvent(UnlockEvent.UNLOCK));
		}
		
		public function set isUndoEnabled(value:Boolean):void {
			undoButton.alpha = (value)? 1 : .4;
			undoButton.mouseEnabled = value;
		}
		
		public function set isRedoEnabled(value:Boolean):void {
			redoButton.alpha = (value)? 1 : .4;
			redoButton.mouseEnabled = value;
		}
		
		protected function onShowSettingsClicked(event:MouseEvent):void {
			if(settingsPanel && settingsPanel.parent){ 
				onCloseSettingsClicked();
				return; 
			}
			
			MainView.click();
			
			if(!underlay){
				underlay = new Sprite();
				underlay.addChild(new Bitmap(SharedBitmaps.bgColor));
				underlay.alpha = .35;
			}
			underlay.y = viewHeight;
			underlay.width = viewWidth;
			underlay.height = stage.stageHeight;
			underlay.addEventListener(MouseEvent.CLICK, onCloseSettingsClicked, false, 0, true);
			addChildAt(underlay, getChildIndex(bg));
			
			underlayTop.visible = true;
			
			if(!settingsPanel){
				settingsPanel = new SettingsPanel(trialMode);
				tween = new GTween(settingsPanel, TweenConstants.NORMAL, {}, {ease: TweenConstants.EASE_OUT});
			}
			
			var panelWidth:int = 440;
			var panelHeight:int = trialMode? 510 : 445;
			settingsPanel.setSize(panelWidth, panelHeight);
			
			var scaleX:Number, scaleY:Number;
			if(stage.stageHeight > stage.stageWidth){
				scaleX = (stage.stageWidth * .95)/panelWidth; 
				settingsPanel.scaleX = settingsPanel.scaleY = scaleX;
			} 
			else {
				scaleY = (stage.stageHeight * 1.05 - viewHeight)/panelHeight; 
				if(DeviceUtils.isTablet){ scaleY = (stage.stageHeight * .8)/panelHeight; }
				settingsPanel.scaleX = settingsPanel.scaleY = scaleY;
			}
			
			settingsPanel.showIndicators((logo.width + versionContainer.width) / settingsPanel.scaleX);
			settingsPanel.x = viewWidth - (settingsPanel.width * .965) >> 1;
			
			settingsPanel.y = -settingsPanel.height;
			tween.proxy.y = viewHeight - 1;
			tween.onComplete = onSettingsOpened;
			
			settingsPanel.mouseEnabled = settingsPanel.mouseChildren = false;
			addChildAt(settingsPanel, getChildIndex(bg));
		}
		
		protected function onSettingsOpened(tween:GTween):void {
			settingsPanel.mouseEnabled = settingsPanel.mouseChildren = true;
		}
		
		protected function onCloseSettingsClicked(event:MouseEvent = null):void {
			if(!underlay || !underlay.parent){ return; }
			removeChild(underlay);
			underlayTop.visible = false;
			tween.proxy.y = -settingsPanel.height;
			tween.onComplete = removeSettings;
		}
		
		protected function removeSettings(tween:GTween = null):void {
			if(underlay && contains(underlay)){
				removeChild(underlay);
			}
			underlayTop.visible = false;
			if(settingsPanel && contains(settingsPanel)){
				removeChild(settingsPanel);
			}
		}
		
		override public function get height():Number {
			return bg.height;
		}
		
		public function set accentColor(value:Number):void {
			var cf:ColorTransform = new ColorTransform();
			cf.color = value;
			logo.transform.colorTransform = cf;
		}
		
		override public function updateLayout():void {
			
			undoButton.icon.width = DeviceUtils.hitSize/2.65;
			undoButton.icon.scaleY = undoButton.icon.scaleX;
			undoButton.setSize(viewHeight, viewHeight - 2);
			
			redoButton.icon.width = DeviceUtils.hitSize/2.65;
			redoButton.icon.scaleY = redoButton.icon.scaleX;
			redoButton.setSize(viewHeight, viewHeight - 2);
			redoButton.x = undoButton.x + undoButton.width;
			
			bg.width = viewWidth;
			bg.height = viewHeight;
			
			divider.width = viewWidth;
			divider.height = 2;
			divider.y = viewHeight - divider.height;
			
			underlayTop.width = viewWidth;
			underlayTop.height = divider.y;
			
			logo.height = viewHeight - viewHeight * .25;
			logo.scaleX = logo.scaleY;
			
			var w:int = (liteText.visible)? logo.width : logo.width - liteText.width;
			logo.x = viewWidth - w - versionContainer.width >> 1;
			logo.y = viewHeight - logo.height + 10 >> 1;
			
			versionContainer.scaleX = versionContainer.scaleY = logo.scaleX;
			versionContainer.x = logo.x + 2;// + logoContainer.width;
			versionContainer.y = logo.y + logo.height * .34;
			
			versionHit.width = logo.width * 1.5;
			versionHit.height = viewHeight * 1.25;
			versionHit.x = logo.x - (versionHit.width - logo.width >> 1);
			
			closeButton.height = viewHeight * .75|0;
			closeButton.scaleX = closeButton.scaleY;
			closeButton.x = viewWidth - closeButton.width * 1.25;
			closeButton.y = viewHeight - closeButton.height >> 1;
			
			compareButton.height = compareButton.width = closeButton.height * 1.35;
			compareButton.x = compareButton.width * .1;
			compareButton.y = viewHeight + compareButton.height * .1;
			
			if(lockButton){
				lockButton.height = bg.height * .65;
				lockButton.scaleX = lockButton.scaleY;
				lockButton.y = bg.height - lockButton.height >> 1;
				lockButton.x = viewWidth - lockButton.width;
				//Shift close button down
				closeButton.y = viewHeight + closeButton.height * .2;
				
			}
			
			removeSettings();
		}
		
		public function showCompareButton(value:Boolean):void {
			compareButton.alpha = value? 1 : .2;
			compareButton.mouseEnabled = value;
		}
		
		public function showCloseButton(value:Boolean):void {
			closeButton.alpha = value? 1 : .2;
			closeButton.mouseEnabled = value;
		}
	}
}
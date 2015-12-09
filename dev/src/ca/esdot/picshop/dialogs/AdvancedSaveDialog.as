package ca.esdot.picshop.dialogs
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.text.TextField;
	
	import assets.Bitmaps;
	
	import ca.esdot.lib.components.Image;
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.utils.GUID;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.components.ColorPanel;
	import ca.esdot.picshop.components.Slider;
	import ca.esdot.picshop.components.buttons.ComboBoxButton;
	import ca.esdot.picshop.data.SaveImageOptions;
	import ca.esdot.picshop.data.Strings;
	import ca.esdot.picshop.data.colors.ColorTheme;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	import swc.SaveDialogContent;
	import swc.UpgradeDialogContent;

	public class AdvancedSaveDialog extends TitleDialog
	{
		protected var MAX_SIZE:int = 4000;
		protected var MIN_SIZE:int = 10;
		
		public var content:SaveDialogContent;
		public var lockButton:MovieClip;
		public var widthText:TextField;
		public var heightText:TextField;
		
		public var options:SaveImageOptions;
		
		private var currentRatio:Number;
		private var qualitySlider:Slider;
		private var locationButton:ComboBoxButton;
		private var locationDialog:OptionsDialog;
		private var file:File;

		private var uniqueName:String;
		private var browseFile:File;
		
		
		public function AdvancedSaveDialog(width:int, height:int) {
			var unique:String = (GUID.create().split("-").join("")).substr(0, 6);
			uniqueName = "PicShop-" + unique + ".jpg";
			
			if(DeviceUtils.cameraRoll){
				file = new File(DeviceUtils.cameraRoll.nativePath + "/" + uniqueName);
			}
			
			var ratio:Number = (width > height)? width / 2400 : height / 2400;
			width /= ratio;
			height /= ratio;
			options = new SaveImageOptions(width, height, 1, file);
			
			super(100, 100, "Save");
			setButtons([Strings.CANCEL, Strings.OK]);
		}
		
		override protected function createChildren():void {
			content = new swc.SaveDialogContent();
			content.scaleX = content.scaleY = DeviceUtils.screenScale;
			addChild(content);
			
			ColorTheme.colorTextfield(content);
			
			lockButton = content.lockIcon;
			lockButton.addEventListener(MouseEvent.CLICK, onLockClicked, false, 0, true);
			
			widthText = content.widthText;
			widthText.text = options.width.toString();
			widthText.restrict = "01234567889";
			widthText.addEventListener(FocusEvent.FOCUS_IN, onTextIn, false, 0, true);
			widthText.addEventListener(FocusEvent.FOCUS_OUT, onTextOut, false, 0, true);
			
			heightText = content.heightText;
			heightText.text = options.height.toString();
			heightText.restrict = "01234567889";
			heightText.addEventListener(FocusEvent.FOCUS_IN, onTextIn, false, 0, true);
			heightText.addEventListener(FocusEvent.FOCUS_OUT, onTextOut, false, 0, true);
			
			if(!DeviceUtils.onIOS){
				qualitySlider = new Slider(1, Strings.SAVE_QUALITY);
				qualitySlider.addEventListener(ChangeEvent.CHANGED, onQualityChanged, false, 0, true);
				addChild(qualitySlider);
			
				locationButton = new ComboBoxButton("Location: Camera Roll");
				locationButton.addEventListener(MouseEvent.CLICK, onLocationClicked, false, 0, true);
				addChild(locationButton);
			}
			
			super.createChildren();
			
			_viewWidth = DeviceUtils.dialogWidth;	
			_viewHeight = Math.min(DeviceUtils.hitSize * 6, MainView.instance.viewHeight);
			
			updateLayout();
		}
		
		protected function onQualityChanged(event:ChangeEvent):void {
			options.quality = .25 + .75 * Number(event.newValue);
		}
		
		protected function onLocationClicked(event:MouseEvent):void {
			locationDialog = new OptionsDialog(DeviceUtils.dialogWidth, DeviceUtils.hitSize * 5, Strings.SAVE_LOCATION, [Strings.CAMERA_ROLL, Strings.PICSHOP_FOLDER, Strings.BROWSE_FOR_FOLDER]);
			locationDialog.addEventListener(ButtonEvent.CLICKED, onLocationDialogClosed, false, 0, true);
			locationDialog.setButtons([Strings.CANCEL]);
			locationDialog.addEventListener(ButtonEvent.CLICKED, onLocationDialogClosed, false, 0, true);
			
			DialogManager.addDialog(locationDialog, false, true, false);
			
		}
		
		protected function onLocationDialogClosed(event:ButtonEvent):void {
			
			DialogManager.removeDialog(locationDialog);
			
			if(event.label == Strings.CAMERA_ROLL){
				file = new File(DeviceUtils.cameraRoll.nativePath + "/" + uniqueName);
				locationButton.label = "Location: " + "Camera Roll";
				
			} else if(event.label == Strings.PICSHOP_FOLDER){
				file = new File(File.desktopDirectory.nativePath + "/PicShop/" + uniqueName);
				locationButton.label = "Location: " + "/PicShop/" + uniqueName;
				
			} else {
				browseFile = new File(File.desktopDirectory.nativePath + "/" + uniqueName);
				browseFile.addEventListener(Event.SELECT, onBrowseFileClosed, false, 0, true);
				browseFile.browseForSave("Save Image");
			}
			options.location = file;
		}
		
		protected function onBrowseFileClosed(event:Event):void {
			file = new File(browseFile.nativePath);
			locationButton.label = "Location: " + file.parent.name + "/" + file.name;
		}
		
		protected function onTextIn(event:FocusEvent):void {
			currentRatio = Number(widthText.text)/Number(heightText.text);
		}
		
		protected function onTextOut(event:FocusEvent):void {
			if(Number(widthText.text) > MAX_SIZE){
				widthText.text = MAX_SIZE.toString();
			}
			if(Number(widthText.text) < MIN_SIZE){
				widthText.text = MIN_SIZE.toString();
			}
			if(Number(heightText.text) > MAX_SIZE){
				heightText.text = MAX_SIZE.toString();
			}
			if(Number(heightText.text) < MIN_SIZE){
				heightText.text = MIN_SIZE.toString();
			}
			
			if(isLocked){
				if(event.target == widthText){
					heightText.text = Math.round(Number(widthText.text) / currentRatio).toString();
				} else {
					widthText.text = Math.round(Number(heightText.text) * currentRatio).toString();
				}
			}
			options.width = int(widthText.text);
			options.height = int(heightText.text);
		}
		
		protected function onLockClicked(event:MouseEvent):void {
			if(isLocked){
				lockButton.gotoAndStop(2);
			} else {
				lockButton.gotoAndStop(1);
			}
			lockButton.addEventListener(MouseEvent.CLICK, onLockClicked, false, 0, true);
		}
		
		public function get isLocked():Boolean {
			return lockButton.currentFrame == 1;
		}
		
		override public function updateLayout():void {
			super.updateLayout();
			
			
			if(DeviceUtils.onIOS){
				content.width = viewWidth * .8;
				content.scaleY = content.scaleX;
				content.y = topDivider.y + (viewHeight - buttonHeight - topDivider.y - content.height >> 1);
			} else {
				content.scaleY = content.scaleX = DeviceUtils.screenScale;
				content.y = topDivider.y + titleText.y;
				
				qualitySlider.y = content.y + content.height;
				qualitySlider.x = titleText.x;
				qualitySlider.width = viewWidth - qualitySlider.x * 3;
				
				locationButton.x = 0;
				locationButton.y = qualitySlider.y + qualitySlider.height;
				locationButton.setSize(viewWidth - locationButton.x * 2, buttonHeight);
			}
			
			content.x = viewWidth - content.width >> 1;
			
		}
	}
}
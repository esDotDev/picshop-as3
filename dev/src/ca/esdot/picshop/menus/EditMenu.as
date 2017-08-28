package ca.esdot.picshop.menus
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	
	import assets.Bitmaps;
	
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.components.buttons.LabelButton;
	import ca.esdot.picshop.data.UnlockableFeatures;
	import ca.esdot.picshop.data.colors.ColorTheme;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	import org.osflash.signals.Signal;
	
	import swc.LockIcon;

	public class EditMenu extends SizableView
	{
		public var topDivider:Bitmap;
		public var bg:Bitmap;
		
		public var buttonContainer:Sprite;
		protected var typesByButton:Dictionary;
		protected var buttonsByType:Object;
		protected var buttonList:Array;
		protected var _currentType:String;
		
		protected var _selectedIndex:int;
		
		public var saveButton:LabelButton;
		public var imageButton:LabelButton;
		
		public var requireSelection:Boolean;
		public var openImageClicked:Signal;
		public var unlockFeatureClicked:Signal;
		
		public function EditMenu() {
			
			bg = new Bitmap(SharedBitmaps.bgColor);
			addChild(bg);
			
			buttonContainer = new Sprite();
			addChild(buttonContainer);
			
			topDivider = new Bitmap(SharedBitmaps.accentColor);
			addChild(topDivider);
			
			saveButton = new LabelButton(null, ColorTheme.colorSprite(new Bitmaps.saveButtonIcon()));
			addChild(saveButton);
			
			imageButton = new LabelButton(null, ColorTheme.colorSprite(new Bitmaps.loadPhotoIcon()));
			imageButton.showDivider = true;
			imageButton.addEventListener(MouseEvent.CLICK, onImageButtonClicked, false, 0, true);
			addChild(imageButton);
			
			openImageClicked = new Signal();
			unlockFeatureClicked = new Signal(String);
			
			typesByButton = new Dictionary();
			buttonsByType = {};
			buttonList = [];
			
			var buttonNames:Array = [EditMenuTypes.EDITS, EditMenuTypes.FILTERS, EditMenuTypes.BORDERS, EditMenuTypes.EXTRAS];
			for(var i:int = 0; i < buttonNames.length; i++){
				var button:LabelButton = new LabelButton(buttonNames[i]);
				button.showDivider = true;
				button.addEventListener(MouseEvent.CLICK, onMenuButtonClicked, false, 0, true);
				buttonContainer.addChild(button);
				typesByButton[button] = buttonNames[i];
				buttonsByType[buttonNames[i]] = button;
				buttonList[i] = button;
			}
			
			toolsEnabled = false;
		}
		
		protected function onImageButtonClicked(event:MouseEvent):void {
			openImageClicked.dispatch();
		}
		
		public function unlockAll():void {
			var b:LabelButton;
			b = buttonsByType[EditMenuTypes.FILTERS];
			b.icon = null;
			
			b = buttonsByType[EditMenuTypes.BORDERS];
			b.icon = null;
			
			b = buttonsByType[EditMenuTypes.EXTRAS];
			b.icon = null;

			updateLayout();
		}
		
		public function unlockFeature(feature:String):void {
			
			var buttonType:String = EditMenuTypes.BORDERS;
			if(feature == UnlockableFeatures.EXTRAS){
				buttonType = EditMenuTypes.EXTRAS;	
			}
			else if(feature == UnlockableFeatures.FILTERS){
				buttonType = EditMenuTypes.FILTERS;	
			}
			
			var b:LabelButton = buttonsByType[buttonType];
			b.icon = null;
			
			updateLayout();
		}
		
		public function lockFeature(feature:String):void {
			var buttonType:String = EditMenuTypes.BORDERS;
			if(feature == UnlockableFeatures.EXTRAS){
				buttonType = EditMenuTypes.EXTRAS;	
			}
			else if(feature == UnlockableFeatures.FILTERS){
				buttonType = EditMenuTypes.FILTERS;	
			}
			
			var b:LabelButton = buttonsByType[buttonType];
			b.icon = new swc.LockIcon();
			
			updateLayout();
		}
		
		
		public function set toolsEnabled(value:Boolean):void {
			buttonContainer.mouseChildren = value;
			buttonContainer.alpha = (value)? 1 : .2;
			
			saveButton.mouseChildren = value;
			saveButton.mouseEnabled = value;
			saveButton.alpha = (value)? 1 : .2;
			
			if(!value){
				selectedIndex = -1;
			}
		}
		
		public function get selectedIndex():int {
			return _selectedIndex;
		}

		public function set selectedIndex(value:int):void {
			if(value < 0){ _currentType = null; }
			_selectedIndex = value;
			for(var i:int = 0; i < buttonList.length; i++){
				if(i == _selectedIndex){
					buttonList[i].isSelected = true;
				} else {
					buttonList[i].isSelected = false;
				}
			}
		}

		override public function get height():Number { 
			return viewHeight;
		}
		
		public function get currentType():String { return _currentType; }
		public function set currentType(value:String):void {
			_currentType = value;
			var button:LabelButton = buttonsByType[value];
			for(var i:int = 0; i < buttonList.length; i++){
				if(buttonList[i] == button){
					selectedIndex = i;
					break;
				}
			}
		}
		
		public function deselectButton():void {
			if(currentType){
				(buttonsByType[currentType] as LabelButton).isSelected = false;
				currentType = null;
			}
		}
		
		protected function onMenuButtonClicked(event:MouseEvent):void {
			//locked?
			/*
			if((event.target as LabelButton).icon){
				if(typesByButton[event.target] == EditMenuTypes.BORDERS){
					unlockFeatureClicked.dispatch(UnlockableFeatures.FRAMES);
				}
				else if(typesByButton[event.target] == EditMenuTypes.EXTRAS){
					unlockFeatureClicked.dispatch(UnlockableFeatures.EXTRAS);
				}
				else if(typesByButton[event.target] == EditMenuTypes.FILTERS){
					unlockFeatureClicked.dispatch(UnlockableFeatures.FILTERS);
				}
			}
			else {*/
				if(typesByButton[event.target] == currentType && !requireSelection){
					(event.target as LabelButton).isSelected = false;
					setMenuType(null);
				} else {
					setMenuType(typesByButton[event.target]);
				}	
			//}
		}
		
		public function setMenuType(value:String):void {
			currentType = value;
			dispatchEvent(new ChangeEvent(ChangeEvent.CHANGED, currentType));
		}
		
		override public function updateLayout():void {
			topDivider.width = viewWidth;
			topDivider.height = 2;
			
			bg.y = topDivider.height;
			bg.width = viewWidth;
			bg.height = viewHeight - bg.y;
			
			var buttonWidth:int = viewWidth / 6;
			var fontSize:int = DeviceUtils.fontSize * .65;
			var padding:int = DeviceUtils.padding;
			
			var xOffset:int = 0;
			for(var i:int = 0; i < buttonContainer.numChildren; i++){
				var button:LabelButton = buttonContainer.getChildAt(i) as LabelButton;
				button.fontSize = fontSize;
				button.setSize(buttonWidth, viewHeight);
				button.bold = true;
				button.labelText.y += 5;
				button.bg.y = 8;
				button.bg.height -= 8;
				button.x = xOffset;
				if(button.icon){
					
					button.labelText.x = 0;
					button.labelText.width = button.width;
					
					var iconPadding:int = button.viewHeight * .03;
					button.icon.height = viewHeight * .3;
					button.icon.scaleX = button.icon.scaleY;
					
					button.icon.x = button.viewWidth - button.icon.width >> 1;//- iconPadding;
					button.labelText.y = button.viewHeight * .5 - (button.icon.height + button.labelText.textHeight)/2;
					button.icon.y = button.labelText.y + button.labelText.textHeight;
					
				} else {
					button.align = TextFormatAlign.CENTER;
				}
				xOffset += button.width;
			}
			buttonContainer.x = viewWidth - buttonContainer.width >> 1;
			
			saveButton.fontSize = fontSize * .85;
			//If the view is too small to show labels, just show icon
			if(viewWidth - buttonContainer.width < buttonWidth * 3){
				saveButton.label = null;
				saveButton.setSize(buttonWidth, viewHeight - topDivider.height);
			} 
			//Show full labels and icon
			else {
				saveButton.label = "Save";
				saveButton.setSize(buttonWidth * 1.6, viewHeight - topDivider.height);
				//Right Align Icon
				saveButton.align = "right";
				saveButton.icon.x = saveButton.width - saveButton.icon.width - padding;
				saveButton.labelText.x = saveButton.icon.x - saveButton.labelText.width - padding;
			}
			saveButton.bg.visible = false;
			saveButton.x = viewWidth - saveButton.width;
			saveButton.y = topDivider.height;
			saveButton.bold = true;
			
			//If the view is too small to show labels, just show icon
			imageButton.fontSize = fontSize * .85;
			if(viewWidth - buttonContainer.width < buttonWidth * 3){
				imageButton.label = null;
				imageButton.setSize(buttonWidth, viewHeight - topDivider.height);
			} 
			//Show full labels and icon
			else {
				imageButton.label = "Load";
				imageButton.align = "left";
				imageButton.setSize(buttonWidth * 1.6, viewHeight - topDivider.height);
			}
			imageButton.bold = true;
			imageButton.bg.visible = false;
			imageButton.y = topDivider.height;
		}
		
	}
}
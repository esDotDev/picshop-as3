package ca.esdot.picshop.dialogs
{
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.utils.TextFields;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.components.OptionsMenu;
	import ca.esdot.picshop.data.colors.AccentColors;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public class OptionsDialog extends BaseDialog
	{
		protected var titleText:TextField;
		protected var topDivider:Bitmap;
		
		protected var _title:String;
		protected var _dataProvider:Array;
		
		protected var paddingTop:int = 20;
		protected var optionsMenu:OptionsMenu;
		
		public function OptionsDialog(width:int = 400, height:int = 250, title:String = "", dataProvider:Array = null, selectedIndex:int = -1){
			
			_dataProvider = dataProvider || [];
			
			super(width, height); //Super will call createChildren()
			
			optionsMenu.selectedIndex = selectedIndex;
			this.title = title;
		}
		
		override public function get height():Number {
			return bg.height;	
		}
		
		override public function destroy():void {
			super.destroy();
			optionsMenu.removeEventListener(ChangeEvent.CHANGED, onMenuChanged);
			optionsMenu.destroy();
		}
		
		override protected function createChildren():void {
			topDivider = new Bitmap(SharedBitmaps.backgroundAccent);
			
			titleText = TextFields.getRegular(DeviceUtils.fontSize, AccentColors.currentColor, "left");
			addChild(titleText);
			
			optionsMenu = new OptionsMenu(_dataProvider);
			optionsMenu.addEventListener(ChangeEvent.CHANGED, onMenuChanged, false, 0, true);
			addChild(optionsMenu);
			
			topDivider = new Bitmap(SharedBitmaps.accentColor);
			addChild(topDivider);
			
			super.createChildren();
		}
		
		protected function onMenuChanged(event:ChangeEvent):void {
			dispatchEvent(new ButtonEvent(ButtonEvent.CLICKED, event.newValue as String));
		}		
		
		override public function updateLayout():void {
			super.updateLayout();
			
			titleText.x = titleText.y = paddingTop;
			titleText.width = viewWidth - titleText.x * 2;
			
			topDivider.width = viewWidth - 2;
			topDivider.x = 1;
			topDivider.y = titleText.y + titleText.height + paddingTop;
			
			if(optionsMenu){
				optionsMenu.x = 1;
				optionsMenu.y = topDivider.y;
				optionsMenu.setSize(viewWidth - 2, viewHeight - topDivider.y - buttonHeight);
			}
		}
		
		
		public function set title(value:String):void {
			_title = titleText.text = value;
		}
		
		
		public function set dataProvider(value:Array):void {
			_dataProvider = value;
		}
	}
}
package ca.esdot.picshop.dialogs
{
	import flash.display.Bitmap;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.utils.TextFields;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.data.colors.AccentColors;
	import ca.esdot.picshop.data.colors.ColorTheme;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	public class TitleDialog extends BaseDialog
	{
		protected var titleText:TextField;
		protected var messageText:TextField;
		protected var topDivider:Bitmap;
		
		protected var _title:String;
		protected var _message:String;
		
		protected var paddingTop:int = 20;
		
		public function TitleDialog(width:int = 400, height:int = 250, title:String = "", message:String = "", fontSize:int = -1){
			super(width, height, fontSize); //Super will call createChildren()
			
			this.title = title;
			this.message = message;
			
		}
		
		override protected function createChildren():void {
			titleText = TextFields.getRegular(fontSize * 1.25, AccentColors.currentColor, "left");
			addChild(titleText);
			
			messageText = TextFields.getRegular(fontSize * .8, 0xFFFFFF, "left");
			messageText.multiline = true;
			messageText.autoSize = TextFieldAutoSize.LEFT;
			
			ColorTheme.colorTextfield(messageText);
			addChild(messageText);
			
			topDivider = new Bitmap(SharedBitmaps.accentColor);
			addChild(topDivider);
			
			super.createChildren();
		}
		
		override public function destroy():void {
			super.destroy();
			ColorTheme.removeSprite(messageText);
		}
		
		override public function updateLayout():void {
			super.updateLayout();
			
			titleText.x = titleText.y = paddingTop;
			titleText.width = viewWidth - titleText.x * 2;
			
			topDivider.width = viewWidth - 2;
			topDivider.x = 1;
			topDivider.y = titleText.y + titleText.height + paddingTop;
			
			messageText.x = titleText.x;
			messageText.y = topDivider.y + paddingTop;
			messageText.width = titleText.width;
		}
		
		public function shrinkToText():void {
			if(messageText.y + messageText.textHeight + 20 < buttonContainer.y){
				messageText.height = messageText.textHeight;
				var oldY:int = buttonContainer.y;
				buttonContainer.y = messageText.y + messageText.textHeight + 20;
				buttonDivider.y = buttonContainer.y;
				bg.height -= oldY - buttonContainer.y;
				_viewHeight = bg.height;
			}
		}
		
		public function set title(value:String):void {
			_title = titleText.text = value;
		}
		
		public function set message(value:String):void {
			_message = messageText.text = value;
		}
	}
}
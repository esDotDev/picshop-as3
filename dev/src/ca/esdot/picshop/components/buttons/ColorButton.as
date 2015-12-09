package ca.esdot.picshop.components.buttons
{
	import assets.Bitmaps;
	
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	import ca.esdot.picshop.dialogs.ColorDialog;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class ColorButton extends LabelButton
	{
		public var colorIcon:Bitmap;
		public var bottomBorder:Bitmap;
		private var colorDialog:ColorDialog;
		
		public function ColorButton() {
			super("Color:");
			align = "left";
		}
		
		override public function set fontSize(value:Number):void {
			trace();
		}
		
		override protected function createChildren():void {
			colorIcon = new Bitmap(new BitmapData(30, 30, true, 0xFF000000));
			bottomBorder = new Bitmap(SharedBitmaps.accentColor);
			
			super.createChildren();
			
			addChild(bottomBorder);
			addChild(colorIcon);
			
			addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
		}
		
		protected function onClick(event:MouseEvent):void {
			colorDialog = new ColorDialog();
			colorDialog.setButtons(["Cancel", "Ok"]);
			colorDialog.addEventListener(ButtonEvent.CLICKED, onColorDialogClicked, false, 0, true);
			if(stage.stageWidth < 500 || stage.stageHeight < 500){
				colorDialog.scaleX = colorDialog.scaleY = .6;
			}
			DialogManager.addDialog(colorDialog);
		}
		
		protected function onColorDialogClicked(event:ButtonEvent):void {
			if(event.label == "Ok"){
				dispatchEvent(new ChangeEvent(ChangeEvent.CHANGED, colorDialog.color));
				color = colorDialog.color;
			}
			colorDialog = null;
			DialogManager.removeDialogs();
		}
		
		public function set color(value:uint):void {
			colorIcon.bitmapData.fillRect(colorIcon.bitmapData.rect, value);
		}
		
		override public function updateLayout():void {
			super.updateLayout();
			
			colorIcon.height = viewHeight * .5 | 0;
			colorIcon.scaleX = colorIcon.scaleY;
			colorIcon.x = viewWidth - colorIcon.width - 10;
			colorIcon.y = viewHeight - colorIcon.height >> 1;
			
			bottomBorder.width = colorIcon.width + 2;
			bottomBorder.height = colorIcon.width + 2;
			
			bottomBorder.x = colorIcon.x - 1;
			bottomBorder.y = colorIcon.y - 1;
		}
	}
}
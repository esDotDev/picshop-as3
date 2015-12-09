package ca.esdot.picshop.components
{
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import ca.esdot.picshop.components.buttons.LabelButton;
	
	public class ButtonBar extends SizableView
	{
		public var buttonList:Array;

		protected var dividerBottom:Bitmap;
		
		public function ButtonBar() {
			dividerBottom = new Bitmap(SharedBitmaps.backgroundAccent);
			addChild(dividerBottom);
		}
		
		override public function get height():Number {
			return viewHeight || super.height;
		}
		
		public function setButtons(labelList:Array):void {
			removeChildren(1);
			buttonList = [];
			for(var i:int = 0, l:int = labelList.length; i < l; i++){
				buttonList[i] = new LabelButton(labelList[i]);
				if(i < l-1){
					(buttonList[i] as LabelButton).showDivider = true;
				}
				(buttonList[i] as LabelButton).addEventListener(MouseEvent.CLICK, onButtonClick, false, 0, true);
				addChildAt(buttonList[i] as LabelButton, 0);
			}
		}
		
		override public function destroy():void {
			for(var i:int = 0, l:int = buttonList.length; i < l; i++){
				buttonList[i].destroy();
				buttonList[i].removeEventListener(MouseEvent.CLICK, onButtonClick);
			}
			buttonList.length = 0;
			removeChildren();
		}
		
		protected function onButtonClick(event:MouseEvent):void {
			dispatchEvent(new ButtonEvent(ButtonEvent.CLICKED, (event.currentTarget as LabelButton).label));
		}
		
		override public function updateLayout():void {
			dividerBottom.width = viewWidth;
			
			var width:int = viewWidth / buttonList.length;
			var xOffset:int = 0;
			for(var i:int = 0, l:int = buttonList.length; i < l; i++){
				(buttonList[i] as LabelButton).fontSize = DeviceUtils.fontSize * .75;
				(buttonList[i] as LabelButton).setSize(width, viewHeight);
				(buttonList[i] as LabelButton).x = i * width;
			}
		}
	}
}
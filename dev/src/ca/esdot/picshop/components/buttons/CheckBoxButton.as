package ca.esdot.picshop.components.buttons
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.text.TextFormatAlign;
	
	import assets.Bitmaps;
	
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.data.colors.AccentColors;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	public class CheckBoxButton extends LabelButton
	{
		protected var checkMark:Bitmap;
		protected var checkMarkBg:Sprite;
		
		public function CheckBoxButton(label:String="") {
			super(label);
			bg.visible = false;
			
			checkMarkBg = new Sprite();
			addChild(checkMarkBg);
			
			checkMark = new Bitmaps.checkMark();
			checkMark.smoothing = true;
			checkMark.visible = false;
			addChild(checkMark);
			
			var ct:ColorTransform = checkMark.transform.colorTransform;
			ct.color = AccentColors.currentColor;
			checkMark.transform.colorTransform = ct;
			
			addEventListener(MouseEvent.CLICK, onMouseClick, false, 0, true);
		}
		
		protected function onMouseClick(event:MouseEvent):void {
			isSelected = !isSelected;
		}
		
		override public function set isSelected(value:Boolean):void {
			_isSelected = value;
			checkMark.visible = value;
		}
		
		override public function updateLayout():void {
			super.updateLayout();
			labelText.y = viewHeight * .5 - labelText.textHeight * .85;
			labelText.x = 20;
			align = TextFormatAlign.LEFT;
			fontSize = DeviceUtils.fontSize
				
			var checkHeight:int = viewHeight * .4;
			checkMarkBg.graphics.beginBitmapFill(SharedBitmaps.backgroundAccent);
			checkMarkBg.graphics.drawRect(0, 0, checkHeight, checkHeight);
			checkMarkBg.graphics.beginBitmapFill(SharedBitmaps.bgColor);
			checkMarkBg.graphics.drawRect(1, 1, checkHeight-2, checkHeight-2);
			checkMarkBg.graphics.endFill();
			
			checkMarkBg.x = viewWidth - checkMarkBg.width - 40;
			checkMarkBg.y = viewHeight - checkMarkBg.height >> 1;
			
			checkMark.width = checkMarkBg.width * 1;
			checkMark.scaleY = checkMark.scaleX;
			
			checkMark.x = checkMarkBg.x + 5;
			checkMark.y = checkMarkBg.y - 6;
		}
		
		override public function destroy():void {
			super.destroy();
			removeEventListener(MouseEvent.CLICK, onMouseClick);
		}
		
		override protected function onMouseUp(event:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			tween.proxy.alpha = 0;
		}
		
		override protected function onMouseDown(event:MouseEvent):void {
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
			tween.proxy.alpha = 1;
		}
	}
}
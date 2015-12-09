package ca.esdot.picshop.components.buttons
{
	import com.gskinner.motion.GTween;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getTimer;
	
	import assets.Bitmaps;
	
	import ca.esdot.lib.data.TweenConstants;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.utils.TextFields;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.components.BorderBox;
	import ca.esdot.picshop.data.colors.ColorTheme;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	public class UndoButton extends BaseButton
	{
		public var labelText:TextField;
		public var duration:Number = 3500;
		
		protected var undoTween:GTween;
		protected var icon:Bitmap;
		protected var lastTouch:Number = 0;
		public var paused:Boolean;
		protected var border:BorderBox;
		
		public function UndoButton() {
			super();
			
			labelText = TextFields.getBold(DeviceUtils.fontSize, 0xFFFFFF, "left");
			labelText.autoSize = TextFieldAutoSize.LEFT;
			labelText.multiline = labelText.wordWrap = false;
			labelText.text = "Undo";
			ColorTheme.colorTextfield(labelText);
			addChild(labelText);
			
			icon = new Bitmaps.undoIcon();
			icon.smoothing = true;
			
			addChild(icon);
			
			bg.alpha = .9;
			
			border = new BorderBox(1, SharedBitmaps.accentColor);
			addChild(border);
			
			alpha = 0;
			undoTween = new GTween(this, TweenConstants.SHORT, {}, {ease: TweenConstants.EASE_OUT});
			
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
		}
		
		override public function destroy():void {
			super.destroy();
			ColorTheme.removeSprite(labelText);
		}

		protected function onMouseMove(event:MouseEvent):void {
			lastTouch = getTimer();
		}
		
		protected function onEnterFrame(event:Event):void {
			if(paused){ lastTouch = getTimer(); return; }
			if(getTimer() - lastTouch > duration){
				hide();
			}
		}
		
		public function show():void {
			lastTouch = getTimer();
			undoTween.proxy.alpha = 1;
			mouseEnabled = true;
			addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
			undoTween.onComplete = null;
		}
		
		public function hide():void {
			undoTween.proxy.alpha = 0;
			undoTween.onComplete = onHideComplete;
			mouseEnabled = false;
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		protected function onHideComplete(tween:GTween):void {
			if(parent){ parent.removeChild(this); }
		}
		
		override public function updateLayout():void {
			super.updateLayout();
			
			border.setSize(viewWidth, viewHeight);
			
			var widthTotal:int = icon.width + labelText.width + 10;
			icon.height = viewHeight * .8;
			icon.scaleX = icon.scaleY;
			
			icon.x = icon.width * .1;
			icon.y = viewHeight - icon.height >> 1;
			
			labelText.x = icon.x + icon.width * .9;
			labelText.y = viewHeight - labelText.height >> 1;
			
			if(bg.width < labelText.x + labelText.width){
				bg.width = labelText.x + labelText.width;
				bgDown.width = bg.width;
			}
		}
		
		
	}
}
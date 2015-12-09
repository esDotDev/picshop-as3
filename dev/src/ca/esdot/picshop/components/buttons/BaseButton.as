package ca.esdot.picshop.components.buttons
{
	import ca.esdot.picshop.components.BorderBox;
	import ca.esdot.lib.data.TweenConstants;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	import com.gskinner.motion.GTween;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.display.Stage;

	public class BaseButton extends SizableView
	{
		protected var _isSelected:Boolean = false;
		protected var tween:GTween;
		
		public var bgColor:Number = 0x090909;
		
		public var container:Sprite;
		public var bg:Bitmap;
		public var bgDown:Bitmap;
		public var borderBox:BorderBox;
		private var _borderSize:int;
		private var _stage:Stage;
		
		public function BaseButton(borderSize:int = 0) {
			this.borderSize = borderSize;
			mouseChildren = false;
			createChildren();
		}
		
		public function get borderSize():int{ return _borderSize; }
		public function set borderSize(value:int):void {
			_borderSize = value;
			if(borderBox){
				borderBox.borderSize = _borderSize;
				borderBox.visible = (_borderSize > 0);
			}
		}

		override public function get width():Number {
			if(bg){
				return bg.width;
			} else {
				return super.width;
			}
		}
		
		override public function get height():Number {
			if(bg){
				return bg.height;
			} else {
				return super.height;
			}
		}
		
		protected function createChildren():void {
			container = new Sprite();
			addChild(container);
			
			bg = new Bitmap(SharedBitmaps.bgColor2);
			container.addChild(bg);
			
			bgDown = new Bitmap(SharedBitmaps.accentColor);
			bgDown.alpha = 0;
			container.addChild(bgDown);
			
			borderBox = new BorderBox();
			borderSize = borderSize;
			addChild(borderBox);
			
			tween = new GTween(bgDown, TweenConstants.SHORT, {}, {ease: TweenConstants.EASE_OUT });
			
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			mouseChildren = false;
		}
		
		override public function destroy():void {
			super.destroy();
			if(tween){
				tween.end();
				tween = null;
			}
			removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		public function get isSelected():Boolean {
			return _isSelected;
		}
		
		public function set isSelected(value:Boolean):void {
			_isSelected = value;
			tween.paused = true;
			tween.proxy.alpha = (value)? 1 : 0;
		}
		
		protected function onMouseUp(event:MouseEvent):void {
			if(isSelected){ return; }
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			tween.proxy.alpha = 0;
		}
		
		protected function onMouseDown(event:MouseEvent):void {
			if(isSelected){ return; }
			_stage = stage;
			_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
			tween.proxy.alpha = 1;
		}
		
		override public function updateLayout():void {
			bg.width = bgDown.width = viewWidth;
			bg.height = bgDown.height = viewHeight;
			
			borderBox.setSize(viewWidth, viewHeight);
		}
	}
}
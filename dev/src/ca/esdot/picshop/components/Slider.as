package ca.esdot.picshop.components
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.PressAndTapGestureEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.data.colors.AccentColors;
	import ca.esdot.picshop.data.colors.ColorTheme;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	import swc.Slider;
	
	public class Slider extends Sprite
	{
		protected static var bgCache:BitmapData;
		protected static var trackCache:BitmapData;
		protected static var fillCache:BitmapData;
		protected static var headUpCache:BitmapData;
		protected static var headDownCache:BitmapData;
		
		public static var radius:Number = 20;
		
		protected var viewAssets:swc.Slider;
		protected var bg:Bitmap;
		protected var track:Bitmap;
		protected var fill:Bitmap;
		protected var headDown:Bitmap;
		protected var headUp:Bitmap;
		protected var labelText:TextField;
		protected var labelText2:TextField;
		
		public var max:Number = 1;
		public var min:Number = 0;
		
		public function Slider(position:Number = .5, label:String = "", label2:String = ""){
			viewAssets = new swc.Slider();
			
			fillCache = SharedBitmaps.accentColor;
			trackCache = SharedBitmaps.backgroundAccent;
			//Shared cache among all assets
			if(!bgCache){
				
				//Draw Track Head
				if(!headUpCache){
					drawTrackHead(AccentColors.DEFAULT);
				}
				
				//Draw Track Over Image from .FLA
				var sprite:Sprite = viewAssets.headDown;
				sprite.width = sprite.height = radius * 2;
				var m:Matrix = new Matrix();
				m.scale(sprite.scaleX, sprite.scaleY);
				headDownCache = new BitmapData(radius * 2, radius * 2, true, 0x0);
				
				if(RENDER::GPU) {
					headDownCache.drawWithQuality(sprite, m, null, null, null, true, StageQuality.HIGH);
				} else {
					headDownCache.draw(sprite, m, null, null, null, true);
				}
			}
			
			bg = new Bitmap(SharedBitmaps.clear, PixelSnapping.AUTO, true);
			bg.alpha = .7;
			addChild(bg);
			
			track = new Bitmap(trackCache, PixelSnapping.AUTO, true);
			addChild(track);
			
			fill = new Bitmap(fillCache, PixelSnapping.AUTO, true);
			addChild(fill);
			
			headUp = new Bitmap(headUpCache, PixelSnapping.AUTO, true);
			addChild(headUp);
			
			headDown = new Bitmap(headDownCache, PixelSnapping.AUTO, true);
			headDown.visible = false;
			addChild(headDown);
			
			bg.height = radius * 2;
			
			labelText = viewAssets.labelText;
			labelText.text = label;
			labelText.mouseEnabled = false;
			ColorTheme.colorTextfield(labelText);
			addChild(labelText);
			
			
			labelText2 = viewAssets.labelText2;
			labelText2.text = label2;
			labelText2.mouseEnabled = false;
			ColorTheme.colorTextfield(labelText2);
			if(label2 != ""){
				addChild(labelText2);
			}
			
			fontSize = DeviceUtils.fontSize * .75;
			
			viewAssets = null;
			
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			this.position = position;
		}
		
		public function destroy():void {
			super.destroy();
			ColorTheme.removeSprite(labelText);
		}
		
		protected static function drawTrackHead(color:Number):void {
			var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(color, 0);
			sprite.graphics.drawCircle(radius, radius, radius);
			sprite.graphics.endFill();
			sprite.graphics.beginFill(color, 1);
			sprite.graphics.drawCircle(radius, radius, DeviceUtils.hitSize * .075);
			sprite.graphics.endFill();
			if(!headUpCache){
				headUpCache = new BitmapData(sprite.width + 2, sprite.height + 2, true, 0x0);
			}
			headUpCache.fillRect(headUpCache.rect, 0x0);
			headUpCache.drawWithQuality(sprite, null, null, null, null, false, StageQuality.HIGH);
		}
		
		public static function set colorMain(value:Number):void {
			trackCache.fillRect(trackCache.rect, value);
		}
		
		public static function set colorAccent(value:Number):void {
			drawTrackHead(value);
			
			if(!fillCache){ return; }
			fillCache.fillRect(fillCache.rect, value);
		}
		
		/**
		 * Position, 0 - 1
		 **/
		protected var _position:Number;
		protected var prevPosition:Number;
		public function get position():Number {
			return _position;
		}
		public function set position(value:Number):void	{
			_position = Math.max(0, Math.min(value, 1));
			fill.width = track.width * position;
			headDown.x = headUp.x = fill.width - headDown.width/2;
			dispatchEvent(new ChangeEvent(ChangeEvent.CHANGED, _position));
		}
		
		/** 
		 * Override width setter 
		 **/
		override public function set width(value:Number):void {
			bg.width = value;
			
			labelText.width = value - labelText .x * 2;
			labelText.height = DeviceUtils.hitSize * .65;
			
			fill.width = value * position;
			fill.height = 4;
			fill.y = labelText.textHeight + DeviceUtils.paddingSmall;
			
			track.width = bg.width = value;
			track.y = (fill.y + fill.height/2) - track.height/2 |0;
			
			headDown.x = headUp.x = fill.width - headDown.width/2;
			headDown.y = headUp.y = track.y - headDown.height/2;
			
			labelText2.width = labelText.width;
			labelText2.height = labelText.height;
			labelText2.x = value - labelText2.width;
		}
		
		public function set fontSize(value:Number):void {
			var tf:TextFormat = labelText.defaultTextFormat;
			tf.size = value;
			labelText.setTextFormat(tf);
			labelText.defaultTextFormat = tf;
			
			tf.align = TextFormatAlign.RIGHT;
			labelText2.setTextFormat(tf);
			labelText2.defaultTextFormat = tf;
		}
		
		public function set label(value:String):void {
			fontSize = DeviceUtils.fontSize;
			labelText.text = value;
		}
		
		public function set label3(value:String):void {
			fontSize = DeviceUtils.fontSize;
			labelText2.text = value;
			if(!labelText2.parent){ addChild(labelText2); }
		}
		
		protected function onMouseDown(value:MouseEvent):void {
			headDown.visible = true;
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
		}
		
		protected function onMouseUp(value:MouseEvent):void {
			headDown.visible = false;
			stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		protected function onEnterFrame(value:Event):void {
			updateBar();
		}
		
		protected function updateBar():void {
			fill.width = Math.max(0, Math.min(bg.width, this.mouseX));
			headDown.x = headUp.x = fill.width - headDown.width/2;
			_position = fill.width / track.width;
			if(_position != prevPosition){
				dispatchEvent(new ChangeEvent(ChangeEvent.CHANGED, _position, prevPosition));
				prevPosition = _position;
			}
		}
		
		override public function get width():Number {
			return bg.width;
		}
		
		override public function get height():Number {
			return bg.height;
		}
	}
}
import ca.esdot.picshop.components;


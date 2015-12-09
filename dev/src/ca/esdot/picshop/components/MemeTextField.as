package ca.esdot.picshop.components
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;
	
	import ca.esdot.lib.display.BitmapSprite;
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.utils.BB10Fixes;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.utils.TextFields;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	public class MemeTextField extends Sprite
	{
		public var maxSize:int = 70;
		public var minSize:int = 50;
		
		protected var cache:BitmapSprite;
		protected var cacheData:BitmapData;
		protected var tf:TextFormat;
		protected var textField:TextField;
		protected var border:BorderBox;
		protected var stroke:Number = 10;
		
		public function MemeTextField(){
			createTextField();
			BB10Fixes.add(textField);
			
			border = new BorderBox(3);
			addChild(border);
			
			cache = new BitmapSprite();
			cache.mouseEnabled = false;
			addChild(cache);
			cache.visible = false;
			
			updateText();
			updateCache();
		}
		
		protected function createTextField():void {
			textField = TextFields.getBold(maxSize, 0xFFFFFF, "center");
			tf = textField.defaultTextFormat;
			textField.width = 500;
			textField.text = " ";
			textField.multiline = true;
			textField.autoSize = "left";
			textField.mouseEnabled = textField.selectable = true;	
			textField.needsSoftKeyboard = true;
			//textField.alpha = .01;
			textField.type = TextFieldType.INPUT;
			textField.addEventListener(Event.CHANGE, onTextChanged, false, 0, true);
			textField.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut, false, 0, true);
			
			addChild(textField);
		}
		
		protected function onFocusOut(event:FocusEvent):void {
			onTextChanged(null);
		}
		
		public function destroy():void {
			BB10Fixes.add(textField);
		}
	
		
		public function set cacheEnabled(value:Boolean):void {
			textField.alpha = (value)? .01 : 1;
			cache.visible = value;
		}
		
		public function get text():String {
			return textField.text;
		}
		
		public function set bordersVisible(value:Boolean):void {
			border.visible = value;
		}
		
		override public function get height():Number {
			return border.height;
		}
		
		override public function set width(value:Number):void {
			//maxSize = value / 40;
			//minSize = value / 60;
			
			textField.width = value;
			border.setSize(value, textField.height);
			updateText();
			updateCache();
		}
		
		protected function onTextChanged(event:Event = null):void {
			setTimeout(function(){
				updateText();
				updateCache();
			}, 100);
			dispatchEvent(new ChangeEvent(ChangeEvent.CHANGED, textField.text));
		}
		
		public function updateCache():void {
			cacheData = new BitmapData(textField.width, textField.height, true, 0x0);
			if(textField.text != ""){
				textField.selectable = false;
				cacheData.draw(textField);
				cacheData.applyFilter(cacheData, cacheData.rect, new Point(), new GlowFilter(0x0, 3, 3, 2, stroke, 3));
				textField.selectable = true;
			}
			cache.bitmapData = cacheData;
		}
		
		public function updateText():void {
			//textField.text = textField.text.toLocaleUpperCase();
			if(textField.numLines == 1){
				while(textField.numLines == 1 && tf.size < maxSize){
					tf.size += 1;
					textField.setTextFormat(tf);
				}
				if(textField.numLines > 1 && tf.size > minSize ){
					tf.size = Number(tf.size) - 1;
				}
			} 
			else if(textField.numLines > 1){
				while(textField.numLines > 1 && tf.size > minSize){
					tf.size = Number(tf.size) - 1;
					textField.setTextFormat(tf);
				}
				
				while(textField.numLines > 2 && tf.size > minSize/2){
					tf.size = Number(tf.size) - 1;
					textField.setTextFormat(tf);
				}
			}
			textField.setTextFormat(tf);
		}
	}
}
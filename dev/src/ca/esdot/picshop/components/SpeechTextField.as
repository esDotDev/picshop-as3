package ca.esdot.picshop.components
{
	import ca.esdot.lib.display.BitmapSprite;
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.utils.TextFields;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	import com.adobe.utils.StringUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.TextEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;
	
	public class SpeechTextField extends SizableView
	{
		public var maxSize:int = 30;
		public var minSize:int = 20;
		
		protected var tf:TextFormat;
		protected var textField:TextField;
		
		public function SpeechTextField(){
			
			textField = TextFields.getBold(maxSize, 0x0, "center");
			tf = textField.defaultTextFormat;
			textField.width = 500;
			textField.maxChars = 140;
			textField.cacheAsBitmap = false;
			textField.text = "";
			textField.multiline = true;
			textField.autoSize = "left";
			textField.mouseEnabled = textField.selectable = true;
			textField.addEventListener(Event.CHANGE, onTextChanged, false, 0, true);
			textField.type = TextFieldType.INPUT;
			addChild(textField);
			
			updateText();
		}
		
		protected function onTextChanged(event:Event):void {
			dispatchEvent(new Event(Event.CHANGE));
			updateLayout();
		}
		
		public function set text(value:String):void { 
			textField.text = value;
			textField.scrollV = 0;
		}
		public function get text():String {
			return textField.text;
		}
		
		override public function updateLayout():void {
			textField.width = viewWidth;
			tf.size = 100;
			textField.setTextFormat(tf);
			text = textField.text;
			while(textField.textHeight > viewHeight && tf.size > 0){
				tf.size = Number(tf.size) - 1;
				textField.setTextFormat(tf);
			}
		}
		
		public function updateText():void {
			//textField.text = textField.text.toLocaleUpperCase();
			if(textField.numLines == 1){
				
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
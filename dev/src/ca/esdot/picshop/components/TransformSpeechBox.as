package ca.esdot.picshop.components
{
	import ca.esdot.lib.utils.TextFields;
	
	import com.adobe.utils.StringUtil;
	import com.gskinner.ui.touchscroller.TouchScrollEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;

	public class TransformSpeechBox extends TransformBox
	{
		protected var textContainer:Sprite;
		protected var textField:SpeechTextField;
		protected var bounds:DisplayObject;
		
		public function TransformSpeechBox(image:Sprite) {
			super(image);
			
			bounds = image.getChildByName("shim");
			
			textContainer = new Sprite();
			addChild(textContainer);
			textField = new SpeechTextField();
			textField.addEventListener(Event.CHANGE, onTextChanged, false, 0, true);
			textField.text = "...";
			textContainer.addChild(textField);
			
			flipButton.visible = buttonsBgTop.visible = false;
		}
		
		protected function onTextChanged(event:Event):void {
			timer.delay = DELAY;
			alphaTween.proxy.alpha = 1;
		}
		
		override public function updateLayout():void {
			super.updateLayout();
			
			var r:Number = imageContainer.rotation;
			textContainer.rotation = imageContainer.rotation = 0;
			
			var w:int = bounds.width * imageContainer.scaleX * image.scaleX;
			var h:int = textContainer.height = bounds.height * imageContainer.scaleY * image.scaleY;
			
			textField.setSize(w, h);
			textField.x = -w/2;
			textField.y = -h/2;
			
			textContainer.x = bounds.x * Math.abs(imageContainer.scaleX) * image.scaleX + w * .5;
			textContainer.y = bounds.y * imageContainer.scaleY * image.scaleY + h * .5;
			textContainer.scaleX = textContainer.scaleY = 1;
			textContainer.rotation = imageContainer.rotation = r;
		}
		
		override protected function onScroll(event:TouchScrollEvent):void {
			super.onScroll(event);
			textContainer.rotation = imageContainer.rotation;
			textField.visible = false;
		}
		
		override protected function onMouseUp(event:TouchScrollEvent):void {
			textField.text = StringUtil.trim(textField.text);
			super.onMouseUp(event);
			textField.visible = true;
		}
	}
}
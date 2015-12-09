package ca.esdot.picshop.components
{
	import com.gskinner.ui.touchscroller.TouchScrollEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import ca.esdot.lib.utils.BB10Fixes;
	import ca.esdot.lib.utils.TextFields;
	import ca.esdot.picshop.data.colors.AccentColors;

	public class TransformTextBox extends TransformBox
	{
		protected var textContainer:Sprite;
		public var textField:TextField;
		private var _textAlpha:Number = 1;
		
		public function TransformTextBox() {
			
			image = new Bitmap(new BitmapData(300, 100, true, 0x0));
			super(image);
			
			textContainer = new Sprite();
			addChildAt(textContainer, 2);
			
			textField = TextFields.getBold();
			textField.needsSoftKeyboard = true;
			textField.selectable = textField.mouseEnabled = true;
			textField.type = TextFieldType.INPUT;
			textField.border = true;
			textField.borderColor = AccentColors.currentColor;
			textField.text = " ";
			textContainer.addChild(textField);
			textField.addEventListener(Event.CHANGE, onTextChanged, false, 0, true);
			
			BB10Fixes.add(textField);
			
			flipButton.visible = buttonsBgTop.visible = false;
			removeChild(borderDown);
		}
		
		override public function destroy():void {
			super.destroy();
			BB10Fixes.remove(textField);
		}
		
		
		public function get textAlpha():Number { return _textAlpha; }
		public function set textAlpha(value:Number):void {
			_textAlpha = value;
			textField.alpha = value;
		}

		protected function onTextChanged(event:Event):void {
			timer.delay = DELAY;
			alphaTween.proxy.alpha = 1;
		}
		
		override public function updateLayout():void {
			super.updateLayout();
			
			var r:Number = imageContainer.rotation;
			textContainer.rotation = imageContainer.rotation = 0;
			trace("Update text size", viewWidth, viewHeight);
			textField.width = viewWidth;
			textField.height = viewHeight;
			textField.x = -viewWidth/2;
			textField.y = -viewHeight/2;
			
			textContainer.x = imageContainer.x;
			textContainer.y = imageContainer.y;
			textContainer.scaleX = textContainer.scaleY = 1;
			textContainer.rotation = imageContainer.rotation = r;
			
			borderDown.x = textField.x;
			borderDown.y = textField.y;
			borderDown.width = viewWidth;
			borderDown.height = viewHeight;

		}
		
		public function set fontSize(value:Number):void {
			var tf:TextFormat = textField.defaultTextFormat;
			tf.size = value;
			textField.setTextFormat(tf);
			textField.defaultTextFormat = tf;
		}
		
		public function set fontFamily(value:String):void {
			var tf:TextFormat = textField.defaultTextFormat;
			tf.font = TextFields.getRegular().defaultTextFormat.font;
			var newTf:TextFormat;
			switch(value){
				case "Regular":
					tf.bold = false;
					break;
				
				case "Bold":
					tf.bold = true;
					break;
				
				case "Cursive":
					tf.font = TextFields.getCursive().defaultTextFormat.font;
					break;
				
				case "College":
					tf.font = TextFields.getCollege().defaultTextFormat.font;
					break;
				
				case "Love":
					tf.font = TextFields.getLove().defaultTextFormat.font;
					break;
				
				case "Hacker":
					tf.font = TextFields.getHacker().defaultTextFormat.font;
					break;
				
				case "Fancy":
					tf.font = TextFields.getScript().defaultTextFormat.font;
					break;
				
				case "Scorched Earth":
					tf.font = TextFields.getScorched().defaultTextFormat.font;
					break;
				
				case "1942 Report":
					tf.font = TextFields.get1942().defaultTextFormat.font;
					break;
				
				case "Oriel":
					tf.font = TextFields.getOriel().defaultTextFormat.font;
					break;
				
				case "Old London":
					tf.font = TextFields.getLondon().defaultTextFormat.font;
					break;
				
				case "Ballpark":
					tf.font = TextFields.getBallpark().defaultTextFormat.font;
					break;
			}
			textField.setTextFormat(tf);
			textField.defaultTextFormat = tf;
		}
		
		public function set fontColor(value:Number):void {
			var tf:TextFormat = textField.defaultTextFormat;
			tf.color = value;
			textField.setTextFormat(tf);
			textField.defaultTextFormat = tf;
		}
		
		override protected function onScroll(event:TouchScrollEvent):void {
			//if(event.clickTarget == textField){ return; }
			
			super.onScroll(event);
			textContainer.rotation = imageContainer.rotation;
		}
	}
}
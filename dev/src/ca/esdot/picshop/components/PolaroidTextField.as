package ca.esdot.picshop.components
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.text.TextFieldType;
	
	import ca.esdot.lib.utils.BB10Fixes;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.utils.TextFields;

	public class PolaroidTextField extends MemeTextField
	{
		
		override protected function createTextField():void {
			maxSize = 50 * DeviceUtils.screenScale;
			minSize = 30 * DeviceUtils.screenScale;
			stroke = 0;
			
			textField = TextFields.getCursive(maxSize, 0x0, "center");
			tf = textField.defaultTextFormat;
			tf.leading = -4;
			textField.width = 500;
			textField.text = "";
			textField.multiline = true;
			textField.autoSize = "left";
			textField.mouseEnabled = textField.selectable = true;	
			textField.needsSoftKeyboard = true;
			//textField.alpha = .01;
			textField.type = TextFieldType.INPUT;
			textField.addEventListener(Event.CHANGE, onTextChanged, false, 0, true);
			textField.addEventListener(FocusEvent.FOCUS_OUT, onTextChanged, false, 0, true);
			addChild(textField);
			
		}
	}
}
package ca.esdot.lib.components
{
	import ca.esdot.lib.events.ChangeEvent;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public class Checkbox extends Sprite
	{
		protected var viewAssets:MovieClip;
		protected var toggle:MovieClip;
		public var labelText:TextField;
		
		public function get isChecked():Boolean {
			return (toggle.currentFrame == 2);
		}
		public function set isChecked(value:Boolean):void {
			toggle.gotoAndStop((value)? 2 : 1);
		}
		
		public function get label():String {
			return labelText.text;	
		}
		public function set label(value:String):void {
			if(!value) return;
			
			labelText.text = value;
		}
		
		[Embed(source="assets/Assets.swf", symbol="CheckboxAssets")]
		protected var CheckboxAssets:Class;
		
		public function Checkbox(){
			viewAssets = new CheckboxAssets();
			
			toggle = viewAssets.toggle;
			toggle.stop();
			
			this.addEventListener(MouseEvent.CLICK, onClick, false, 0, true); 
			addChild(toggle);
			
			labelText = viewAssets.labelText;
			labelText.autoSize = TextFieldAutoSize.LEFT;
			labelText.multiline = false;
			addChild(labelText);
			
			viewAssets = null;
		}
		
		protected function onClick(event:MouseEvent):void {
			isChecked = !isChecked;
			dispatchEvent(new ChangeEvent(ChangeEvent.CHANGED, isChecked));
		}
	}
}
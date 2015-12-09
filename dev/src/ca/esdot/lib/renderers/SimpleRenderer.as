package ca.esdot.phototouchup.renderers
{
	import assets.Bitmaps;
	
	import ca.esdot.lib.components.Checkbox;
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.events.ListEvent;
	import ca.esdot.lib.view.SizableView;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class SimpleRenderer extends SizableView
	{
		
		protected var labelText:TextField;
		
		public function get label():String {
			return labelText.text;
		}

		public function set label(value:String):void {
			labelText.text = value;
		}
		
		protected var _showDivider:Boolean = true;
		public function get showDivider():Boolean{ return _showDivider; }
		public function set showDivider(value:Boolean):void {
			_showDivider = value;
			setSize(viewWidth, viewHeight);
		}


		public function SimpleRenderer() {
			
			var viewAssets:MovieClip = new Bitmaps.CheckboxAssets();
			labelText = viewAssets.labelText;
			labelText.x = 10;
			labelText.y = 12;
			addChild(labelText);
			
			mouseChildren = false;
			
			setSize(400);
			
			addEventListener(MouseEvent.CLICK, onMouseClick, false, 0, true);
			
		}
		
		protected function onMouseClick(event:MouseEvent):void {
			dispatchEvent(new ListEvent(ListEvent.ITEM_CLICKED, label, true));
		}
		
		override  public function setSize(width:int=0, height:int=0):void {
			graphics.clear();
			graphics.beginFill(0xFFFFFF, .05);
			graphics.drawRect(0, 0, width, labelText.height + 30);
			graphics.endFill();
			if(showDivider){
				graphics.beginFill(0xFFFFFF, .2);
				graphics.drawRect(0, labelText.height + 26, width, 2);
				graphics.endFill();
			}
		}
	}
}
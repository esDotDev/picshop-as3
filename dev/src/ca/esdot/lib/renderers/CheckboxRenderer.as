package ca.esdot.lib.renderers
{
	import ca.esdot.lib.components.Checkbox;
	import ca.esdot.lib.components.Image;
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.view.SizableView;
	
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	public class CheckboxRenderer extends SizableView
	{
		
		protected var checkbox:Checkbox;
		
		protected var _label:String;

		public function get label():String {
			return checkbox.label;
		}

		public function set label(value:String):void {
			checkbox.label = value;
		}
		
		protected var _image:Image;
		public function set bitmapData(value:BitmapData):void {
			if(!_image){
				_image = new Image();
				_image.setSize(70, 48);
				_image.bitmapData = value;
				_image.x = 7;
				_image.y = 5;
				addChild(_image);
				checkbox.labelText.x += 25;
				
			}
			_image.bitmapData = value;
			
		}

		public function CheckboxRenderer() {
			
			checkbox = new Checkbox();
			checkbox.x = checkbox.y = 10;
			addChild(checkbox);
			
			mouseChildren = false;
			cacheAsBitmap = true;
			setSize(340);
			
			addEventListener(MouseEvent.CLICK, onMouseClick, false, 0, true);
			
		}
		
		protected function onMouseClick(event:MouseEvent):void {
			checkbox.isChecked = !checkbox.isChecked;
			setSize(viewWidth, viewHeight);
			setTimeout(function(){
				dispatchEvent(new ChangeEvent(ChangeEvent.CHANGED, checkbox.isChecked, null, true));
			}, 1);
		}
		
		override  public function setSize(width:int=0, height:int=0):void {
			super.setSize(width, height);
			graphics.clear();
			graphics.beginFill(0x0, checkbox.isChecked? .95 : .25);
			trace(checkbox.isChecked? .75 : .5);
			graphics.drawRect(0, 0, width, checkbox.height + 30);
			graphics.endFill();
			graphics.beginFill(0xFFFFFF, .2);
			graphics.drawRect(0, checkbox.height + 28, width, 2);
			graphics.endFill();
		}
	}
}
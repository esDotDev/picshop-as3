package ca.esdot.picshop.components
{
	import assets.Bitmaps;
	
	import ca.esdot.lib.events.ChangeEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class ColorPanel extends Sprite
	{
		protected var panel:Bitmap;
		protected var tileSize:int = 28;
		protected var highlight:Sprite;
		protected var _currentColor:Number = 0;
		
		public function ColorPanel() {
			panel = new Bitmaps.colorPanel();
			addChild(panel);
			
			highlight = new Sprite();
			var bmp:Bitmap = new Bitmap(new BitmapData(tileSize, tileSize, true, 0x0));
			bmp.bitmapData.fillRect(new Rectangle(0, 0, tileSize, tileSize), 0xFF000000);
			bmp.bitmapData.fillRect(new Rectangle(2, 2, tileSize-4, tileSize-4), 0x0);
			highlight.addChild(bmp);
			highlight.mouseEnabled = false;
			addChild(highlight);
			
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
		}
		
		public function get currentColor():Number { return _currentColor; }
		public function set currentColor(value:Number):void {
			if(value == _currentColor){ return; }
			_currentColor = value;
			dispatchEvent(new ChangeEvent(ChangeEvent.CHANGED, _currentColor));
		}

		protected function onMouseMove(event:MouseEvent):void {
			var x:int = Math.round((mouseX - 30) / tileSize) * 30;
			var y:int = Math.round((mouseY - 30)/ tileSize) * 30;
			
			highlight.x = Math.max(0, Math.min(panel.width - tileSize, x));
			highlight.y = Math.max(0, Math.min(panel.height - tileSize, y));
			
			var color:Number = panel.bitmapData.getPixel32(highlight.x + 4, highlight.y + 4);
			currentColor = color;
		}
	}
}
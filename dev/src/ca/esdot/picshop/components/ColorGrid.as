package ca.esdot.picshop.components
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import ca.esdot.lib.display.BitmapSprite;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	import org.osflash.signals.Signal;

	public class ColorGrid extends SizableView
	{
		protected static var bitmapCache:Object = {};
		protected var _colors:Array;
		protected var bitmapList:Vector.<BitmapSprite>;
		
		public var useVerticalLayout:Boolean;
		public var colorChanged:Signal;
		protected var _selectedColor:Number;
		protected var colorBorder:BorderBox;
		protected var bitmapsByColor:Object;
		protected var colorsByBitmap:Dictionary;
		
		public function ColorGrid(colors:Array){
			bitmapList = new <BitmapSprite>[];
			this.colors = colors;
			colorChanged = new Signal(Number);
			
			colorBorder = new BorderBox(DeviceUtils.divSize * 5, SharedBitmaps.accentColor);
			addChild(colorBorder);
			
			selectedColor = 0x0;

		}
		
		
		protected function onMouseMove(event:MouseEvent):void {
			if(colorsByBitmap[event.target] != null){
				selectedColor = colorsByBitmap[event.target];
			}
			
		}
		
		public function get colors():Array { return _colors; }
		public function set colors(value:Array):void {
			removeChildren();
			_colors = value;
			bitmapList.length = 0;
			bitmapsByColor = {};
			colorsByBitmap = new Dictionary(true);
			for(var i:int = 0; i < value.length; i++){
				
				//Share static cache
				if(bitmapCache[_colors[i]] == null){
					bitmapCache[_colors[i]] = new BitmapData(2, 2, false, _colors[i])
				}
				bitmapList[i] = new BitmapSprite(bitmapCache[_colors[i]]);
				bitmapList[i].addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
				bitmapList[i].addEventListener(MouseEvent.MOUSE_DOWN, onMouseMove, false, 0, true);
				colorsByBitmap[bitmapList[i]] = _colors[i];
				bitmapsByColor[_colors[i]] = bitmapList[i];
				addChildAt(bitmapList[i], 0);
			}
			updateLayout();
		}
		
		override public function updateLayout():void {
			if(!isSizeSet) { return; }
			
			var i:int, i2:int, row:int = 0, rows:int; 
			var col:int = 0, cols:int;
			var padding:int = DeviceUtils.divSize * 2;
			var bmp:BitmapSprite;
			var bw:int, bh:int;
			//If portrait, layout Hz Color Strips
			if(!useVerticalLayout){
				cols = 10;
				rows = 4;
				bw = (viewWidth - padding * (cols - 1)) / cols;
				bh = (viewHeight - padding * (rows - 1)) / rows;
				for(i = 0; i < rows; i++){
					for(i2  = 0; i2 < cols; i2++){
						if(i * cols + i2 > bitmapList.length - 1){ 
							break; 
						}
						bmp = bitmapList[i * cols + i2];
						bmp.width = bw;
						bmp.height = bh;
						bmp.x = i2 * (bw + padding);
						bmp.y = i * (bh + padding);
					}
				}
			} else {
				rows = 5;
				cols = 7;
				bw = (viewWidth - padding * (cols - 1)) / cols;
				bh = (viewHeight - padding * (rows - 1)) / rows;
				for(i = 0; i < cols; i++){
					for(i2 = 0; i2 < rows; i2++){
						if(i * rows + i2 > bitmapList.length - 1){ 
							break;
						}
						bmp = bitmapList[i * rows + i2];
						bmp.width = bw;
						bmp.height = bh;
						bmp.x = i * (bw + padding);
						bmp.y = i2 * (bh + padding);
					}
				}
			}
			
			colorBorder.setSize(bw + padding * 2, bh + padding * 2);
			updateColorBorder();
		}

		public function get selectedColor():Number { return _selectedColor; }
		public function set selectedColor(value:Number):void {
			if(_selectedColor == value){ return; }
			_selectedColor = value;
			colorChanged.dispatch(_selectedColor);
			updateColorBorder();
			
		}
		
		protected function updateColorBorder():void {
			var target:BitmapSprite = bitmapsByColor[_selectedColor];
			if(target){
				addChild(colorBorder);
				colorBorder.x = target.x + (target.width - colorBorder.width >> 1);
				colorBorder.y = target.y + (target.height - colorBorder.height >> 1);
				colorBorder.visible = true;
			}
			else {
				colorBorder.visible = false;
			}
		}

	}
}
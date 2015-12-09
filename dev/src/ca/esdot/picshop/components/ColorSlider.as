package ca.esdot.picshop.components
{
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.utils.SpriteUtils;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	import com.google.analytics.debug.Margin;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	public class ColorSlider extends SizableView
	{
		protected var colors:Array = [
			0xFFFFFF,
			0x000000,
			0xe32006,
			0xe35506,
			0xe38b06,
			0xe3bf06,
			0x99e104,
			0x61dd01,
			0x38e70b,
			0x0de37a,
			0x06e1ab,
			0x03e0e0,
			0x03a9df,
			0x0877e3,
			0x0c46e6,
			0x0a10e6,
			0x2d01de,
			0x0e13e9,
			0x2d00de,
			0x6201df,
			0x9903e0,
			0xcc02de,
			0xe003bc,
			0xe00386,
			0xe00452
		]
		protected var stroke:Bitmap;
		protected var tileList:Vector.<Sprite>;
		protected var marker:Bitmap;
		protected var _currentIndex:int;
		
		protected var indexBySprite:Dictionary;
		
		public function ColorSlider(){
			indexBySprite = new Dictionary();
			tileList = new <Sprite>[];
			stroke = new Bitmap(SharedBitmaps.backgroundAccent);
			addChild(stroke);
			
			_currentIndex = 0;
			
			var circle:Sprite = new Sprite();
			circle.graphics.beginFill(0x000000);
			circle.graphics.drawCircle(20, 20, 35);
			circle.graphics.beginFill(0xFFFFFF);
			circle.graphics.drawCircle(20, 20, 30);
			circle.graphics.endFill();
				
			for(var i:int = 0, l:int = colors.length; i < l; i++){
				var bitmap:Bitmap = new Bitmap(new BitmapData(1, 1, false, colors[i]));
				var sprite:Sprite = new Sprite();
				sprite.addChild(bitmap);
				tileList[i] = sprite;
				sprite.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
				indexBySprite[tileList[i]] = i;
				addChild(tileList[i]);
			}
			
			marker = new Bitmap(SpriteUtils.draw(circle), "never", true);
			addChild(marker);
		}
		
		public function get currentColor():int {
			return colors[currentIndex];
		}
		
		public function get currentIndex():int {
			return _currentIndex;
		}

		public function set currentIndex(value:int):void {
			_currentIndex = value;
			updateMarker();
		}

		protected function onMouseMove(event:MouseEvent):void {
			var index:int = indexBySprite[event.target];
			if(index != currentIndex){
				currentIndex = index;
				dispatchEvent(new ChangeEvent(ChangeEvent.CHANGED, currentColor));
			}
		}
		
		override  public function updateLayout():void {
			
			var width:Number = (viewWidth - 2) / tileList.length | 0;
			for(var i:int = 0, l:int = colors.length; i < l; i++){
				tileList[i].y = 1;
				tileList[i].x = 1 + i * width;
				tileList[i].width = width;
				tileList[i].height = viewHeight - 2;
			}
			stroke.width = tileList[i-1].x + width + 1;
			stroke.height = viewHeight;
			
			marker.width = marker.height = viewHeight * .5;
			updateMarker();
			
		}
		
		protected function updateMarker():void {
			marker.x = tileList[currentIndex].x + tileList[currentIndex].width/2 - marker.width/2;
			marker.y = viewHeight/2 - marker.height/2;
		}
	}
}
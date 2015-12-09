package ca.esdot.picshop.views
{
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.utils.SpriteUtils;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	import com.gskinner.ui.touchscroller.TouchScrollEvent;
	import com.gskinner.ui.touchscroller.TouchScrollListener;
	import com.gskinner.ui.touchscroller.TouchScroller;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;

	public class TiltLinesView extends SizableView
	{
		public var defaultPosition:Number = .2;
		
		protected var topLine:Bitmap;
		protected var topDiamond:Sprite;
		protected var topHit:Sprite;
		
		protected var middleHit:Sprite;
		
		protected var bottomLine:Bitmap;
		protected var bottomDiamond:Sprite;
		protected var bottomHit:Sprite;
		
		protected var manualSizing:Boolean;
		protected var scroller:TouchScrollListener;
		protected var _verticalMode:Boolean;
		
		public function TiltLinesView() {
			topLine = new Bitmap(SharedBitmaps.accentColor);
			topDiamond = createDiamond()
			topHit = SpriteUtils.getUnderlay(0x0, 0, 1, DeviceUtils.hitSize); 
			addChild(topDiamond);
			addChild(topLine);
			addChild(topHit);
			
			middleHit = SpriteUtils.getUnderlay(0x0, 0, 1, DeviceUtils.hitSize); 
			addChild(middleHit);
			
			bottomLine = new Bitmap(SharedBitmaps.accentColor);
			bottomDiamond = createDiamond()
			bottomHit = SpriteUtils.getUnderlay(0x0, 0, 1, DeviceUtils.hitSize); 
			addChild(bottomDiamond);
			addChild(bottomLine);
			addChild(bottomHit);
			
			scroller = new TouchScrollListener(this, true, true);
			scroller.addEventListener(TouchScrollEvent.SCROLL, onScroll, false, 0, true);
		}
		
		public function get verticalMode():Boolean { return _verticalMode; }
		public function set verticalMode(value:Boolean):void {
			_verticalMode = value;
			updateLayout();
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get topRatio():Number {
			return (verticalMode)? topLine.x / viewWidth : topLine.y / viewHeight;
		}
		
		public function get bottomRatio():Number {
			return (verticalMode)? bottomLine.x / viewWidth : bottomLine.y / viewHeight;
		}
		
		
		protected function onScroll(event:TouchScrollEvent):void {
			if(verticalMode){
				if(event.clickTarget == middleHit){
					topHit.x -= event.mouseDeltaX;
					bottomHit.x -= event.mouseDeltaX;
				} else if(event.clickTarget == topHit){
					topHit.x -= event.mouseDeltaX;
				} else if(event.clickTarget == bottomHit){
					bottomHit.x -= event.mouseDeltaX;
				}
				
				topHit.x = Math.min(bottomHit.x - topHit.width, topHit.x);
				topHit.x = Math.max(0, topHit.x);
				
				bottomHit.x = Math.max(topHit.x + topHit.width , bottomHit.x);
				bottomHit.x = Math.min(viewWidth - bottomHit.width, bottomHit.x);
			} else {
				if(event.clickTarget == middleHit){
					topHit.y -= event.mouseDeltaY;
					bottomHit.y -= event.mouseDeltaY;
				} else if(event.clickTarget == topHit){
					topHit.y -= event.mouseDeltaY;
				} else if(event.clickTarget == bottomHit){
					bottomHit.y -= event.mouseDeltaY;
				}
				
				topHit.y = Math.min(bottomHit.y - bottomHit.height, topHit.y);
				topHit.y = Math.max(0, topHit.y);
				
				bottomHit.y = Math.max(topHit.y + topHit.height, bottomHit.y);
				bottomHit.y = Math.min(viewHeight - bottomHit.height, bottomHit.y);
			}
			
			dispatchEvent(new Event(Event.CHANGE));
			positionToHit();
		}
		
		protected function createDiamond():Sprite {
			var sprite:Sprite = new Sprite();
			var bitmap:Bitmap = new Bitmap(SharedBitmaps.accentColor);
			bitmap.width = bitmap.height = 20;
			bitmap.rotation = 45;
			bitmap.x += bitmap.width/2;
			bitmap.y -= bitmap.height/2;
			sprite.mouseEnabled = sprite.mouseChildren = false;
			sprite.addChild(bitmap);
			return sprite;
		}
		
		override public function updateLayout():void {
			sizeHitAreas();
			positionToHit();
		}
		
		protected function sizeHitAreas():void {
			if(verticalMode){
				topHit.width = bottomHit.width = DeviceUtils.hitSize;
				topHit.height = bottomHit.height = viewHeight;
				topHit.y = bottomHit.y = 0;
				topHit.x = viewWidth * defaultPosition;
				bottomHit.x = viewWidth - topHit.x - bottomHit.width;
			} else {
				topHit.width = bottomHit.width = viewWidth;
				topHit.height = bottomHit.height = DeviceUtils.hitSize;
				topHit.y = viewHeight * defaultPosition;
				bottomHit.y = viewHeight - topHit.y - bottomHit.height;
				topHit.x = bottomHit.x = 0;
			}
		}
		
		protected function positionToHit():void {
			if(verticalMode){
				topLine.width = bottomLine.width = 1;
				topLine.height = bottomLine.height = middleHit.height = viewHeight;
				
				topLine.y = 0;
				topLine.x = topHit.x + topHit.width/2;
				
				topDiamond.y = topLine.height/2;
				topDiamond.x = topLine.x - topDiamond.width/2;
				
				bottomLine.x = bottomHit.x + bottomHit.width/2;
				bottomLine.y = 0;
				
				bottomDiamond.y = topLine.height/2;
				bottomDiamond.x = bottomLine.x - bottomDiamond.width/2;
				
				middleHit.x = topHit.x + topHit.width;
				middleHit.y = 0;
				middleHit.height = viewHeight;
				middleHit.width = bottomHit.x - middleHit.x;
				
			} else {
				topLine.width = bottomLine.width = middleHit.width = topHit.width;
				topLine.height = bottomLine.height = 1;
				
				topLine.x = 0;
				topLine.y = topHit.y + topHit.height/2;
				
				topDiamond.x = topLine.width/2;	
				topDiamond.y = topLine.y;
				
				bottomLine.x = 0;
				bottomLine.y = bottomHit.y + bottomHit.height/2;
				
				bottomDiamond.x = bottomLine.width/2;
				bottomDiamond.y = bottomLine.y;
				
				middleHit.x = 0;
				middleHit.y = topHit.y + topHit.height;
				middleHit.width = viewWidth;
				middleHit.height = bottomHit.y - middleHit.y;
			}
			
		}
	}
}
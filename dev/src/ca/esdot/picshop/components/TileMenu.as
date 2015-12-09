package ca.esdot.picshop.components
{
	import com.gskinner.motion.GTween;
	import com.gskinner.ui.touchscroller.TouchScrollEvent;
	import com.gskinner.ui.touchscroller.TouchScrollListener;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import assets.Bitmaps;
	
	import ca.esdot.lib.components.MaskedTouchScroller;
	import ca.esdot.lib.data.TweenConstants;
	import ca.esdot.lib.display.BitmapSprite;
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.components.buttons.LabelButton;
	import ca.esdot.picshop.menus.Signal;
	
	import org.osflash.signals.Signal;
	
	public class TileMenu extends SizableView
	{
		public var bg:TileMenuBackground;
		public var container:Sprite;
		public var currentButtonDown:SizableView;
		
		protected var tileList:Array = [];
		protected var typesByButton:Dictionary;
		protected var scrollListener:TouchScrollListener;
		protected var maxScrollX:Number;
		protected var scroller:MaskedTouchScroller;
		protected var buttonList:Array;
		public var closeClicked:Signal;
		protected var closeButton:BitmapSprite;
		
		public function TileMenu() {
			typesByButton = new Dictionary();
			buttonList = [];
			
			bg = new TileMenuBackground();
			addChild(bg);
			
			container = new Sprite();
			addChild(container);
			
			createTiles();
			
			scroller = new MaskedTouchScroller(container, false);
			scroller.addEventListener(TouchScrollEvent.SCROLL, onMenuScrolled, false, 0, true);
			addChild(scroller);
			
			closeButton = new BitmapSprite((new Bitmaps.closeMenuButton() as Bitmap).bitmapData);
			closeButton.addEventListener(MouseEvent.CLICK, onCloseClicked, false, 0, true);
			
			scroller.x = container.x;
			container.x = 0;
			closeClicked = new Signal();
			
		}
		
		protected function onCloseClicked(event:MouseEvent):void {
			closeClicked.dispatch();
		}
		
		
		override public function destroy():void {
			scroller.removeEventListener(TouchScrollEvent.SCROLL, onMenuScrolled)
			scroller.destroy();
			
			closeButton.removeEventListener(MouseEvent.CLICK, onCloseClicked);
			closeClicked.removeAll();
			
			if(buttonList){
				for(var i:int = 0, l:int = buttonList.length; i < l; i++){
					buttonList[i].removeEventListener(MouseEvent.CLICK, onButtonClicked);
					buttonList[i].removeEventListener(MouseEvent.MOUSE_DOWN, onButtonDown);
				}
			}
		}
		
		override public function get height():Number {
			return bg.height;
		}
		
		public function setButtons(buttonTypes:Array):void {
			tileList = buttonTypes.concat();
			createTiles();
		}
		
		protected function createTiles():void {
			if(!tileList){ return; }
			
			var button:LabelButton;
			buttonList = [];
			container.removeChildren();
			for(var i:int = 0, l:int = tileList.length; i < l; i++){
				button = new LabelButton(tileList[i]);
				button.addEventListener(MouseEvent.CLICK, onButtonClicked, false, 0, true);
				button.addEventListener(MouseEvent.MOUSE_DOWN, onButtonDown, false, 0, true);
				
				if(i < l-1){ 
					button.showDivider = true;
				}
				container.addChild(button);
				buttonList[i] = button;
			}
		}
		
		protected function onMenuScrolled(event:Event):void {
			if(currentButtonDown){
				if(currentButtonDown is LabelButton || "isSelected" in currentButtonDown){
					(currentButtonDown as LabelButton).isSelected = false;
				}
				currentButtonDown = null;
			}
		}
		
		protected function onButtonClicked(event:MouseEvent):void {
			//Scrolling must have disabled the button's selected state
			if(!currentButtonDown){
				return;
			}
			var type:String = typesByButton[event.currentTarget];
			dispatchEvent(new ChangeEvent(ChangeEvent.CHANGED, type));
		}
		
		protected function onButtonDown(event:MouseEvent):void {
			currentButtonDown = event.currentTarget as SizableView;
		}
		
		override public function updateLayout():void {
			
			container.y = 1;
			bg.setSize(viewWidth, viewHeight);
			
			positionTiles();
			maxScrollX = -container.width + viewWidth;
			
			scroller.setSize(viewWidth - scroller.x, viewHeight - 2);
		}
		
		protected function positionTiles():void {
			var xOffset:int = 0;
			for(var i:int = 0; i < buttonList.length; i++){ 
				var button:SizableView = buttonList[i] as SizableView;
				button.setSize(viewHeight, viewHeight - 2);
				button.x = xOffset;
				xOffset += button.width;
			}
		}
	}
}
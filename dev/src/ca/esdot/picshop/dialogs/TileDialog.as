package ca.esdot.picshop.dialogs
{
	import com.google.analytics.debug.Label;
	import com.gskinner.ui.touchscroller.TouchScrollEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import assets.Bitmaps;
	
	import ca.esdot.lib.components.MaskedTouchScroller;
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.components.buttons.BaseButton;
	import ca.esdot.picshop.components.buttons.LabelButton;
	import ca.esdot.picshop.data.colors.ColorTheme;
	import ca.esdot.picshop.data.colors.SharedBitmaps;

	public class TileDialog extends BaseDialog
	{
		public var _dataProvider:Array;
		public var imageContainer:Sprite;
		public var tileList:Vector.<LabelButton>
		
		protected var cols:int;
		protected var scroller:MaskedTouchScroller;
		protected var tileSize:int;

		protected var imageBg:Sprite;
		protected var currentButtonDown:LabelButton;
		
		public function TileDialog(dataProvider:Array, cols:int = 3) {
			super(width, height);
			
			//Can't have a black background with black stickers. White works fine though :)
			if(!ColorTheme.whiteMode){
				(bg as DialogBackground).inner.bitmapData = SharedBitmaps.backgroundAccent;
			}
			
			this.cols = cols;
			padding = 10;
			
			imageContainer = new Sprite();
			
			imageBg = new Sprite();
			imageBg.addChild(new Bitmap(SharedBitmaps.clear));
			
			tileList = new <LabelButton>[];
			
			scroller = new MaskedTouchScroller(imageContainer, true, false);
			scroller.addEventListener(TouchScrollEvent.SCROLL, onScroll, false, 0, true);
			addChild(scroller);
			
			this.dataProvider = dataProvider.concat();
		}
		
		override public function destroy():void {
			scroller.removeEventListener(TouchScrollEvent.SCROLL, onScroll);
			scroller.destroy();
			if(scroller.parent){
				removeChild(scroller);
			}
			
			if(tileList){				
				for(var i:int = tileList.length; i--;){
					tileList[i].removeEventListener(MouseEvent.CLICK, onTileClicked);
					tileList[i].removeEventListener(MouseEvent.MOUSE_DOWN, onButtonDown);
					tileList[i].destroy();
					
				}
				tileList.length = 0;
			}
			
			dataProvider.length = 0;
		}
		
		public function get currentSticker():DisplayObject {
			if(!currentButtonDown){ return null; }
			return currentButtonDown.icon;
		}

		public function get dataProvider():Array { return _dataProvider; }
		public function set dataProvider(value:Array):void {
			_dataProvider = value;
			createTiles();
			updateTileLayout();
			updateLayout();
		}
		
		protected function createTiles():void {
			if(imageContainer){ imageContainer.removeChildren(); }
			
			imageContainer.addChild(imageBg);
			var icon:DisplayObject;
			for (var i:int = 0, l:int = dataProvider.length; i < l; i++){
				
				//Instantiate
				if(dataProvider[i] is DisplayObject){
					icon = dataProvider[i];
				} else if(dataProvider[i] is Class){
					icon = new dataProvider[i]()
				}
				if(icon is Bitmap){
					(icon as Bitmap).smoothing = true;
				} 
				if(icon is Sprite){
					(icon as Sprite).cacheAsBitmap = true;
				} 
				
				var button:LabelButton = new LabelButton("", icon);
				button.addEventListener(MouseEvent.CLICK, onTileClicked, false, 0, true);
				button.addEventListener(MouseEvent.MOUSE_DOWN, onButtonDown, false, 0, true);
				tileList[i] = button;
				imageContainer.addChild(button);
			}
		}
		
		protected function onTileClicked(event:MouseEvent):void {
			//Scrolling must have disabled the button's selected state
			if(!currentButtonDown){
				return;
			}
			dispatchEvent(new ButtonEvent(ButtonEvent.CLICKED, null));
		}
		
		protected function onScroll(event:Event):void {
			if(currentButtonDown){
				if(currentButtonDown is LabelButton || "isSelected" in currentButtonDown){
					(currentButtonDown as LabelButton).isSelected = false;
				}
				currentButtonDown = null;
			}
		}
		
		protected function onButtonDown(event:MouseEvent):void {
			currentButtonDown = event.currentTarget as LabelButton;
		}
		
		protected function updateTileLayout():void {
			if(isNaN(tileSize) || tileSize <= 0){ return; }
			
			var button:LabelButton;
			var row:int = 0, col:int = 0;
			var padding:int = (viewWidth - (tileSize * cols)) / (cols);
			for (var i:int = 0, l:int = dataProvider.length; i < l; i++){
				button = tileList[i];
				if(button.icon.width > button.icon.height){
					button.icon.width = tileSize * .6;
					button.icon.scaleY = button.icon.scaleX;
				} else {
					button.icon.height = tileSize * .6;
					button.icon.scaleX = button.icon.scaleY;
				}
				button.bg.visible = false;
				button.setSize(tileSize, tileSize);
				button.x = col * (tileSize + padding);
				button.y = row * tileSize;
				if(++col > cols - 1){
					col = 0; row++;
				}
			}
		}
		
		override public function updateLayout():void {
			super.updateLayout();
			
			if(!dataProvider){ return; }
			tileSize = (viewWidth * .9)/cols;
			updateTileLayout();
			
			imageBg.width = imageContainer.width;
			imageBg.height = 1;
			imageBg.height = imageContainer.height;
			
			scroller.x = scroller.y = padding;
			scroller.setSize(viewWidth - padding * 2, viewHeight - padding * 2 - buttonHeight);
			
			
		}
	}
}
package ca.esdot.picshop.editors.borders
{
	import com.gskinner.ui.touchscroller.TouchScrollEvent;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import ca.esdot.lib.components.MaskedTouchScroller;
	import ca.esdot.lib.image.ImageProcessing;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.components.BorderBox;
	import ca.esdot.picshop.components.buttons.LabelButton;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	import org.osflash.signals.Signal;

	public class ScrollingBitmapGrid extends SizableView
	{
		protected var bitmapsByButton:Dictionary;
		protected var buttonsByBitmap:Dictionary;
		
		protected var _bitmapList:Vector.<BitmapData>;
		protected var buttonList:Vector.<LabelButton>;
		protected var _selectedBitmap:BitmapData;
		protected var colorBorder:BorderBox;
		protected var buttonLayer:Sprite;
		
		public var useVerticalLayout:Boolean;
		public var bitmapChanged:Signal;
		protected var downButton:Object;
		protected var scroller:MaskedTouchScroller;
		protected var smallBitmapList:Vector.<BitmapData>;
		
		public function ScrollingBitmapGrid(bitmapList:Vector.<BitmapData> = null){
			bitmapChanged = new Signal(BitmapData);
			
			buttonLayer = new Sprite();
			
			colorBorder = new BorderBox(DeviceUtils.divSize * 5, SharedBitmaps.accentColor);
			
			buttonList = new <LabelButton>[];
			
			this.bitmapList = bitmapList;
			
			scroller = new MaskedTouchScroller(buttonLayer, false, true, false);
			scroller.addEventListener(TouchScrollEvent.SCROLL, onScroll, false, 0, true);
			addChild(scroller);
		}
		
		protected function onScroll(event:Event):void {
			if(downButton){
				(downButton as LabelButton).isSelected = false;
			}
			downButton = null;
		}
		
		public function get bitmapList():Vector.<BitmapData> { return _bitmapList; }
		public function set bitmapList(value:Vector.<BitmapData>):void {
			buttonLayer.removeChildren();
			
			_bitmapList = value;
			buttonList.length = 0;
			smallBitmapList = new <BitmapData>[];
			bitmapsByButton = new Dictionary(true);
			buttonsByBitmap = new Dictionary(true);
			if(bitmapList){
				for(var i:int = 0; i < bitmapList.length; i++){
					var icon:Sprite = new Sprite();
					buttonList[i] = new LabelButton("", icon);
					buttonList[i].addEventListener(MouseEvent.MOUSE_DOWN, onButtonDown, false, 0, true);
					buttonList[i].addEventListener(MouseEvent.CLICK, onButtonClicked, false, 0, true);
					buttonList[i].iconScale = .98;
					buttonList[i].bg.bitmapData = SharedBitmaps.clear;
					buttonLayer.addChild(buttonList[i]);
					
					bitmapsByButton[buttonList[i]] = bitmapList[i];
					buttonsByBitmap[bitmapList[i]] = buttonList[i];

					var smallSize:int = DeviceUtils.hitSize * (DeviceUtils.onBB10? .5 : 1);
					smallBitmapList[i] = ImageProcessing.capSize(bitmapList[i], smallSize); 
				}
				
				selectedBitmap = _bitmapList[0];
			}
			buttonLayer.addChild(colorBorder);
			updateLayout();
			
		}
		
		protected function onButtonDown(event:MouseEvent):void {
			downButton = event.target as LabelButton;
		}
		
		protected function onButtonClicked(event:MouseEvent):void {
			if(downButton){
				selectedBitmap = bitmapsByButton[downButton];
			}
			downButton = null;
		}
		
		
		override public function updateLayout():void {
			if(!isSizeSet) { return; }
			
			var i:int, i2:int, row:int = 0, rows:int; 
			var col:int = 0, cols:int;
			var padding:int = 0;//DeviceUtils.divSize * 2;
			var button:LabelButton;
			var bw:int, bh:int;
			
			if(viewHeight > viewWidth * .2){
				rows = 3;						
			} else {
				rows = 2;
			}
			cols = Math.ceil(buttonList.length / rows);
			bw = bh = viewHeight / rows;
			
			for(i = 0; i < cols; i++){
				for(i2  = 0; i2 < rows; i2++){
					var index:int = i * rows + i2;
					button = buttonList[index];
					var s:Sprite = button.icon as Sprite;
					s.graphics.clear();
					s.graphics.beginBitmapFill(smallBitmapList[index], null, true, true);
					s.graphics.drawRect(0, 0, bw, bh);
					s.graphics.endFill();
					button.setSize(bw, bh);
					button.x = i * (bw + padding);
					button.y = i2 * (bh + padding);
					if(index == buttonList.length - 1){
						break;
					}
				}
			}
			
			scroller.setSize(viewWidth, viewHeight)
			scroller.tweenInBounds(.001);
			
			colorBorder.setSize(bw, bh);
			updateColorBorder();
		}

		public function get selectedBitmap():BitmapData { return _selectedBitmap; }
		public function set selectedBitmap(value:BitmapData):void {
			if(_selectedBitmap == value){ return; }
			_selectedBitmap = value;
			bitmapChanged.dispatch(_selectedBitmap);
			updateColorBorder();
		}
		
		protected function updateColorBorder():void {
			var target:LabelButton = buttonsByBitmap[_selectedBitmap];
			
			if(target){
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
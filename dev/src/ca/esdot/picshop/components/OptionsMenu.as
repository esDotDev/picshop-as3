package ca.esdot.picshop.components
{
	import com.gskinner.ui.touchscroller.TouchScrollEvent;
	import com.gskinner.ui.touchscroller.TouchScrollListener;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import ca.esdot.lib.components.MaskedTouchScroller;
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.components.buttons.RadioButton;
	
	public class OptionsMenu extends SizableView
	{
		public var container:Sprite;
		public var currentButtonDown:SizableView;
		public var buttonList:Array;
		
		protected var _dataProvider:Array = [];
		protected var typesByButton:Dictionary;
		
		protected var scroller:MaskedTouchScroller;
		private var _currentIndex:int;
		private var _currentButton:RadioButton;
		
		public function OptionsMenu(dataProvider:Array) {
			typesByButton = new Dictionary();
			buttonList = [];
			
			container = new Sprite();
			
			scroller = new MaskedTouchScroller(container, true, false);
			scroller.addEventListener(TouchScrollEvent.SCROLL, onMenuScrolled, false, 0, true);
			addChild(scroller);
			
			this.dataProvider = dataProvider;
		}
		
		override public function destroy():void {
			
			if(dataProvider){
				var button:RadioButton;
				for(var i:int = dataProvider.length; i--;){
					button = buttonList[i] as RadioButton;
					button.removeEventListener(MouseEvent.CLICK, onButtonClicked);
					button.removeEventListener(MouseEvent.MOUSE_DOWN, onButtonDown);
					button.destroy();
				}
			}
			scroller.removeEventListener(TouchScrollEvent.SCROLL, onMenuScrolled);
			scroller.destroy();
		}
		
		public function get dataProvider():Array { return _dataProvider; }
		public function set dataProvider(value:Array):void {
			if(!value){ return; }
			_dataProvider = value;
			
			var button:RadioButton;
			buttonList = [];
			container.removeChildren();
			for(var i:int = 0, l:int = dataProvider.length; i < l; i++){
				button = new RadioButton(dataProvider[i]);
				button.addEventListener(MouseEvent.CLICK, onButtonClicked, false, 0, true);
				button.addEventListener(MouseEvent.MOUSE_DOWN, onButtonDown, false, 0, true);
				//if(i < l-1){ 
					button.showDivider = true;
				//}
				container.addChild(button);
				buttonList[i] = button;
			}
		}
		
		protected function onMenuScrolled(event:Event):void {
			if(currentButtonDown){
				if(currentButtonDown is RadioButton || "isSelected" in currentButtonDown){
					(currentButtonDown as RadioButton).isSelected = false;
				}
				currentButtonDown = null;
			}
		}
		
		protected function onButtonClicked(event:MouseEvent):void {
			//Scrolling must have disabled the button's selected state
			if(!currentButtonDown){
				return;
			}
			dispatchEvent(new ChangeEvent(ChangeEvent.CHANGED, (event.currentTarget as RadioButton).label));
			
		}
		
		public function set selectedIndex(value:int):void {
			_currentIndex = i;
			var selectedY:int = 0;
			for(var i:int = 0; i < buttonList.length; i++){ 
				var button:RadioButton = buttonList[i] as RadioButton;
				button.isSelected = (i == value);
				if(button.isSelected){
					selectedY = button.y - button.height;
				}
			}	
			container.y = Math.min(0, Math.max(scroller.maxScrollY, -selectedY));
		}
		
		public function set selectedButton(value:RadioButton):void {
			_currentButton = value;
			for(var i:int = 0; i < buttonList.length; i++){ 
				var button:RadioButton = buttonList[i] as RadioButton;
				button.isSelected = (button == value);
				if(button == value){ _currentIndex = i; }
			}	
		}
		
		protected function onButtonDown(event:MouseEvent):void {
			currentButtonDown = event.currentTarget as SizableView;
		}
		
		override public function updateLayout():void {
			container.y = 1;
			updateChildrenLayout();
			scroller.setSize(viewWidth, viewHeight - 2);
		}
		
		protected function updateChildrenLayout():void {
			var yOffset:int = 0;
			var height:int = DeviceUtils.hitSize;
			if(buttonList.length > 5){
				height = DeviceUtils.hitSize * .65;
			} 
			for(var i:int = 0; i < buttonList.length; i++){ 
				var button:SizableView = buttonList[i] as SizableView;
				button.setSize(viewWidth, DeviceUtils.hitSize);
				button.y = yOffset;
				yOffset += button.height;
			}
		}
	}
}
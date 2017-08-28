package ca.esdot.picshop.views
{
	import com.gskinner.motion.GTween;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	
	import ca.esdot.lib.data.TweenConstants;
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.components.Slider;
	import ca.esdot.picshop.components.TileMenu;
	import ca.esdot.picshop.data.UnlockableFeatures;
	import ca.esdot.picshop.menus.BasicToolsMenu;
	import ca.esdot.picshop.menus.BordersMenu;
	import ca.esdot.picshop.menus.EditMenu;
	import ca.esdot.picshop.menus.EditMenuTypes;
	import ca.esdot.picshop.menus.ExtrasMenu;
	import ca.esdot.picshop.menus.ExtrasMenuTypes;
	import ca.esdot.picshop.menus.FiltersMenu;
	import ca.esdot.picshop.menus.StickersMenu;
	
	import org.osflash.signals.Signal;
	
	public class EditView extends SizableView
	{
		public var editMenu:EditMenu;
		
		public var imageView:ImageView;
		
		public var slider:Slider;
		
		protected var sourceImage:BitmapData;
		protected var currentMenuType:String;
		protected var _currentMenu:TileMenu;
		
		protected var basicToolsMenu:BasicToolsMenu;
		protected var filtersMenu:FiltersMenu;
		protected var bordersMenu:BordersMenu;
		protected var extrasMenu:ExtrasMenu;
		
		protected var secondaryMenu:SizableView;
		protected var currentSecondaryMenu:SizableView;
		protected var prevSecondaryMenu:SizableView;
		private var _marginTop:int;
		
		
		public function EditView() {
			
			imageView = new ImageView();
			addChild(imageView);
			
			editMenu = new EditMenu();
			editMenu.addEventListener(ChangeEvent.CHANGED, onMenuChanged, false, 0, true);
			addChild(editMenu);
			
			
		}
		
		public function get currentMenu():TileMenu{
			return _currentMenu;
		}

		public function set currentMenu(value:TileMenu):void
		{
			_currentMenu = value;
		}

		public function get marginTop():int { return _marginTop; }
		public function set marginTop(value:int):void {
			_marginTop = value;
			new GTween(imageView, TweenConstants.NORMAL, {y: value}, {ease: TweenConstants.EASE_OUT});
		}
		
		public function set fullscreen(value:Boolean):void {
			
			if(value){
				if(editMenu){
					new GTween(editMenu, TweenConstants.NORMAL, {y: viewHeight}, {ease:TweenConstants.EASE_OUT, delay: .2});
				}
				if(secondaryMenu){
					new GTween(secondaryMenu, TweenConstants.SHORT, {y: viewHeight}, {ease: TweenConstants.EASE_IN});
				} else {
					hideCurrentMenu();
				}
			} else {
				if(editMenu){
					new GTween(editMenu, TweenConstants.NORMAL, {y: viewHeight - editMenu.height}, {ease:TweenConstants.EASE_OUT});
				}
				if(secondaryMenu){
					new GTween(secondaryMenu, TweenConstants.NORMAL, {y: viewHeight - secondaryMenu.height - editMenu.height + 1}, {ease: TweenConstants.EASE_OUT});
				} else {
					showCurrentMenu();
				}
				
				var menuHeight:int = (editMenu)? editMenu.height : 0;
				if(currentMenu){ menuHeight += currentMenu.height; }
				
				imageView.scaleView(viewWidth, viewHeight - menuHeight);
			}
		}
		
		protected function showCurrentMenu():void {
			if(currentMenu){
				addChildAt(currentMenu, getChildIndex(editMenu));
				var menuHeight:int = (editMenu)? editMenu.height : 0;
				currentMenu.y = viewHeight;
				new GTween(currentMenu, TweenConstants.NORMAL, {y: viewHeight - currentMenu.viewHeight - menuHeight + 1}, {ease:TweenConstants.EASE_OUT});
			}
		}
		
		public function hideCurrentMenu():void {
			if(currentMenu){
				new GTween(currentMenu, TweenConstants.SHORT, {y: viewHeight}, {ease: TweenConstants.EASE_IN, onComplete:onMenuOutComplete});
				mouseEnabled = mouseChildren = false;
			}
		}
		
		
		public function showSecondaryMenu(type:String):void {
			if(!type){ return; }
			
			hideSecondaryMenu();
			hideCurrentMenu();
			
			switch(type) {
				
				case ExtrasMenuTypes.STICKERS:
					secondaryMenu = new StickersMenu();
					break;
			}
			if(secondaryMenu){
				addChildAt(secondaryMenu, 0);
				secondaryMenu.setSize(viewWidth, calculateMenuHeight());
				secondaryMenu.y = viewHeight;
				new GTween(secondaryMenu, TweenConstants.NORMAL, {y: viewHeight - secondaryMenu.height - editMenu.height}, {ease: TweenConstants.EASE_OUT});
				//editMenu.requireSelection = true;
			}
			
		}
		

		public function hideSecondaryMenu():void {
			if(!secondaryMenu){ return; }
			new GTween(secondaryMenu, TweenConstants.SHORT, {y: viewHeight}, {ease: TweenConstants.EASE_IN, onComplete: onMenuOutComplete});
			//editMenu.requireSelection = false;
			secondaryMenu = null;
		}
		
		protected function onMenuChanged(event:ChangeEvent):void {
			if(currentMenuType == event.newValue as String){ 
				if(secondaryMenu){
					hideSecondaryMenu();
				}
				return; 
			}
			
			MainView.click();
			dispatchEvent(event);
			
			setCurrentMenu(event.newValue as String);
		}
		
		public function setCurrentMenu(type:String = null):void {
			//Hide Menu
			hideCurrentMenu();
			hideSecondaryMenu();
			
			currentMenu = null;
			currentMenuType = null;
			
			currentMenuType = type;
			
			if(type){
				//Show New Menu
				var newMenu:TileMenu;
				
				switch(currentMenuType){
					
					case EditMenuTypes.EDITS:
						newMenu = basicToolsMenu || new BasicToolsMenu();
						basicToolsMenu = newMenu as BasicToolsMenu;
						break;
					
					case EditMenuTypes.FILTERS:
						//filtersMenu = null;
						newMenu = filtersMenu || new FiltersMenu();
						filtersMenu = newMenu as FiltersMenu;
						filtersMenu.createThumbs(imageView.currentBitmap);
						break;
					
					case EditMenuTypes.BORDERS:
						bordersMenu = null;
						newMenu = bordersMenu || new BordersMenu();
						bordersMenu = newMenu as BordersMenu;
						bordersMenu.createThumbs(imageView.currentBitmap);
						break;
					
					case EditMenuTypes.EXTRAS:
						newMenu = extrasMenu || new ExtrasMenu();
						extrasMenu = newMenu as ExtrasMenu;
						break;
					
				}
				currentMenu = newMenu;
			}
			
			MainView.instance.hideTopButtons(false);
			if(currentMenu){
				currentMenu.y = viewHeight - editMenu.height;
				addChildAt(currentMenu, getChildIndex(editMenu));
				
				currentMenu.closeClicked.addOnce(onCurrentMenuCloseClicked);
				
				var menuHeight:int = calculateMenuHeight();
				currentMenu.setSize(viewWidth, menuHeight);
				
				//If not full screen, tween in menu slowly, and scale the imageView to match
				if(!isCurrentMenuFullscreen){
					imageView.scaleView(viewWidth, viewHeight - imageView.y - currentMenu.height - editMenu.height);
					new GTween(currentMenu, TweenConstants.LONG, {y: viewHeight - currentMenu.height - editMenu.height + 1}, {ease: TweenConstants.EASE_OUT, onComplete: onMenuInComplete});
				} 
				//Fullscreen. Tween in a little faster, and no scale on imageView.
				else {
					new GTween(currentMenu, TweenConstants.NORMAL, {y: 0}, {ease: TweenConstants.EASE_OUT, onComplete: onMenuInComplete});
					MainView.instance.hideTopButtons(true);
				}
				mouseEnabled = mouseChildren = false;
			} else {
				imageView.scaleView(viewWidth, viewHeight - imageView.y - editMenu.height);
			}
		}
		
		protected function onCurrentMenuCloseClicked():void {
			closeEditMenu();
		}
		
		public function get isCurrentMenuFullscreen():Boolean {
			if(currentMenu && currentMenu.viewHeight == (viewHeight - editMenu.height)){
				return true;
			}
			return false;
		}
		
		protected function calculateMenuHeight():int {
			
			var maxHeight:int = viewHeight - editMenu.height;		
			var height:int;
			if(isPortrait){
				height = maxHeight / (DeviceUtils.isTablet? 5.5 : 4.5);
			} else {
				height = maxHeight / (DeviceUtils.isTablet? 3.5 : 2.6);
			}
			if(currentMenu == filtersMenu || currentMenu == bordersMenu){
				height = maxHeight;
			}
			return height;
		}
		
		protected function onMenuInComplete(tween:GTween):void {
			mouseEnabled = mouseChildren = true;
		}
		
		protected function onMenuOutComplete(tween:GTween):void {
			var target:Sprite = (tween.target as Sprite);
			mouseEnabled = mouseChildren = true;
			if(contains(target)){
				removeChild(target);
			}
		}
		
		override public function updateLayout():void {
			
			var height:int = DeviceUtils.hitSize;
			var maxHeight:Number = (DeviceUtils.isTablet)? .15 : .18;
			
			if(height > viewHeight * maxHeight){ height = viewHeight * maxHeight; }
			
			editMenu.setSize(viewWidth, height);
			editMenu.y = viewHeight-editMenu.height;
			
			var bottom:int = viewHeight - editMenu.height;
			if(currentMenu){
				if(!isCurrentMenuFullscreen){
					bottom -= currentMenu.height; 
				}
				currentMenu.setSize(viewWidth, calculateMenuHeight());
				currentMenu.y = viewHeight - currentMenu.height - editMenu.height;	
			}
			if(secondaryMenu){
				secondaryMenu.setSize(viewWidth, calculateMenuHeight());
				secondaryMenu.y = viewHeight - secondaryMenu.height - editMenu.height;
			}
			
			imageView.setSize(viewWidth, viewHeight);
			imageView.resetZoom();
			
		}
		
		public function back():Boolean {
			if(secondaryMenu){
				hideSecondaryMenu();
				if(currentMenu){
					showCurrentMenu();
				}
				return true;
			}
			return false;
		}
		
		
		public function closeEditMenu():void {
			setCurrentMenu(null);
			editMenu.selectedIndex = -1;
		}
	}
}
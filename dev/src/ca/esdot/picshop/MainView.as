package ca.esdot.picshop
{
	import com.gskinner.motion.GTween;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageOrientation;
	import flash.events.Event;
	import flash.events.StageOrientationEvent;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import ca.esdot.lib.components.ViewStack;
	import ca.esdot.lib.data.TweenConstants;
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.display.BitmapSprite;
	import ca.esdot.lib.events.ViewEvent;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.components.ClickAnimation;
	import ca.esdot.picshop.data.ViewTypes;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	import ca.esdot.picshop.menus.TopMenu;
	import ca.esdot.picshop.views.BackgroundView;
	import ca.esdot.picshop.views.CoreImageTestView;
	import ca.esdot.picshop.views.EditView;
	import ca.esdot.picshop.views.FacebookBrowser;
	import ca.esdot.picshop.views.FrameShopPrompt;
	import ca.esdot.picshop.views.SaveView;
	import ca.esdot.picshop.views.UnlockFeaturesView;
	
	import org.osflash.signals.Signal;
	
	import swc.FramesPreviewStrip;
	import swc.SegmentedSpinner;
	
	public class MainView extends SizableView
	{
		protected static var _stage:Stage;
		protected static var touchAnimationList:Vector.<ClickAnimation>;
		public static var instance:MainView;

		protected var MAX_LOAD_TIME:int = 30000;
		
		protected var _currentView:SizableView;
		protected var _isLoading:Boolean;
		
		protected var spinner:swc.SegmentedSpinner;
		protected var spinnerUnderlay:BitmapSprite;
		protected var viewStack:ViewStack;
		protected var touchAnimations:Sprite;
		protected var _fullscreen:Boolean;
		protected var loadStartTime:int;		
		
		public var facebookBrowser:FacebookBrowser;
		public var backgroundView:BackgroundView;
		public var topMenu:TopMenu;
		public var editView:EditView;
		public var saveView:SaveView;
		
		public var currentUnlockOffer:UnlockFeaturesView;
		
		protected var frameShopPrompt:FrameShopPrompt;
		public var downloadFrameShopClicked:Signal;

		private var coreImageTestView:CoreImageTestView;
		
		public function MainView(stage:Stage) {
			DialogManager.init(this);
			DeviceUtils.init(stage);
			
			instance = this;
			_stage = stage;
			
			spinnerUnderlay = new BitmapSprite(SharedBitmaps.underlayColor);
			spinnerUnderlay.alpha = .5;
			
			backgroundView = new BackgroundView();
			addChild(backgroundView);
			
			viewStack = new ViewStack();
			addChild(viewStack);
			
			topMenu = new TopMenu();
			addChild(topMenu);
			
			touchAnimations = new Sprite();
			addChild(touchAnimations);
			touchAnimationList = new Vector.<ClickAnimation>();
			
			setSize(stage.stageWidth, stage.stageHeight);
			
			downloadFrameShopClicked = new Signal();
			
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
			//stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGING, onOrientationChanging, false, 0, true);
			
			coreImageTestView = new CoreImageTestView();
			//addChild(coreImageTestView);
			//coreImageTestView.setSize(stage.stageWidth, stage.stageHeight);
			
			
		}
		
		protected function onEnterFrame(event:Event):void {
			//kill switch for loader...
			if(isLoading && getTimer() - loadStartTime > MAX_LOAD_TIME){
				isLoading = false;
			}
			if(touchAnimationList.length > 0){
				for(var i:int = touchAnimationList.length-1; i >= 0; i--){
					touchAnimationList[i].spriteSheet.step();
					if(touchAnimationList[i].spriteSheet.isPlaying == false){
						touchAnimations.removeChild(touchAnimationList[i]);
						touchAnimationList.splice(i, 1);
					}
				}
			}
		}
		
		protected function onFrameShopDownloadClicked():void {
			downloadFrameShopClicked.dispatch();
		}
		
		
		public static function click():void {
			if(!_stage){ return; }
			instance.click();
		}
		
		public function click():void {
			var anim:ClickAnimation = new ClickAnimation(true);
			anim.x = mouseX;
			anim.y = mouseY;
			touchAnimations.addChild(anim);
			touchAnimationList.push(anim);
		}
		
		public function get fullScreen():Boolean { return _fullscreen; }
		public function set fullScreen(value:Boolean):void {
			_fullscreen = value;
			if(value){
				new GTween(topMenu, TweenConstants.NORMAL, {y: -topMenu.height * 3}, {ease: TweenConstants.EASE_OUT});
				if(currentView is SaveView){ return; }
				(currentView as EditView).marginTop = -topMenu.height;
			} else {
				new GTween(topMenu, TweenConstants.NORMAL, {y: 0}, {ease: TweenConstants.EASE_OUT});
				if(currentView is EditView){
					(currentView as EditView).marginTop = 0;
				}
			}
		}
		
		public function get isLoading():Boolean{
			return _isLoading;
		}

		public function set isLoading(value:Boolean):void{
			_isLoading = value;
			if(_isLoading && !spinner){
				spinner = new swc.SegmentedSpinner();
				addChild(spinnerUnderlay);
				addChild(spinner);
				updateSpinner();
			} else if(spinner && contains(spinner)){
				removeChild(spinnerUnderlay);
				removeChild(spinner);
				spinner = null;
			}
			loadStartTime = getTimer();
		}

		public function get currentView():SizableView
		{
			return _currentView;
		}
		
		public function set currentView(value:SizableView):void
		{
			_currentView = value;
		}
		
		protected function onOrientationChanging(event:StageOrientationEvent):void {
			//Determine whether DEFAULT and UPSIDE_DOWN == landscape, this varies from device to device.
			var isDefaultLandscape:Boolean = true;
			var isLandscapeNow:Boolean = (stage.stageWidth > stage.stageHeight);
			if(isLandscapeNow && (stage.orientation == StageOrientation.ROTATED_LEFT || stage.orientation == StageOrientation.ROTATED_RIGHT)){
				isDefaultLandscape = false;
			}
			//Are we switching to a landscape mode? If we are, use preventDefault to stop it.
			var goingToDefault:Boolean = (event.afterOrientation == StageOrientation.DEFAULT || event.afterOrientation == StageOrientation.UPSIDE_DOWN);
			if((goingToDefault && !isDefaultLandscape) || (!goingToDefault && isDefaultLandscape)){
				event.preventDefault();
			}
			setTimeout(checkOrientation, 1);
		}
		
		protected function checkOrientation(event:Event = null):void {
			if(stage.stageWidth < stage.stageHeight){
				if(stage.orientation == stage.orientation == StageOrientation.ROTATED_RIGHT || stage.orientation == StageOrientation.ROTATED_LEFT){
					stage.setOrientation(StageOrientation.DEFAULT);
				} else {
					stage.setOrientation(StageOrientation.ROTATED_LEFT);
				}
			}
		}
		
		public function show(viewType:String):void {
			
			//Create new view
			var newView:SizableView;
			var doTransition:Boolean = false;
			switch(viewType) {
				/*
				case ViewTypes.INTRO:
				newView = new IntroView();
					introView = newView;
					break; 
				*/
			case ViewTypes.SAVE:
					newView = new SaveView();
					saveView = newView as SaveView;
					doTransition = true;
					break;
				
				case ViewTypes.EDIT:
					newView = new EditView();
					editView = newView as EditView;
					break;
				/*
				case ViewTypes.SHARE:
					newView = highScoreView || new HighScoreView();
					highScoreView = newView;
					break;
				*/
			}
			if(!newView){ return; }

			//Add new view
			var oldView:SizableView = currentView;
			currentView = newView;
			
			//Size and position
			newView.y = topMenu.height;
			newView.setSize(viewWidth, viewHeight - newView.y);
			
			viewStack.push(newView, doTransition);
			
		}
		
		public function showFrameshopPrompt():void {
			if(!frameShopPrompt){
				frameShopPrompt = new FrameShopPrompt();
				frameShopPrompt.downloadClicked.add(onFrameShopDownloadClicked);
			}
			frameShopPrompt.setSize(viewWidth, viewHeight);
			addChild(frameShopPrompt);
			frameShopPrompt.transitionIn();
		}
		
		public function showFacebookBrowser():FacebookBrowser {
			if(facebookBrowser && facebookBrowser.stage){
				return facebookBrowser;
			}
			facebookBrowser = new FacebookBrowser();
			addChild(facebookBrowser);
			facebookBrowser.setSize(viewWidth, viewHeight);
			return facebookBrowser;
		}
		
		public function showUpgradeOffer(type:String):void {
			
			currentUnlockOffer = new UnlockFeaturesView(type);
			addChild(currentUnlockOffer);
			
			currentUnlockOffer.setSize(viewWidth, viewHeight);
			currentUnlockOffer.transitionIn();
			
		}
		
		public function removeUpgradeOffer():void {
			if(currentUnlockOffer){
				currentUnlockOffer.destroy();
			}
			currentUnlockOffer = null;
		}
		
		protected function onViewTransitionOutComplete(event:Event):void {
			var oldView:SizableView = (event.target as SizableView);
			oldView.removeEventListener(ViewEvent.TRANSITION_OUT_COMPLETE, onViewTransitionOutComplete);
			oldView.x = 0;
			oldView.y = viewHeight - topMenu.height;
			removeChild(oldView);	
		}
		
		public function hide(value:String):void {
			
		}
		
		override public function updateLayout():void {
			backgroundView.setSize(viewWidth, viewHeight);
			
			var height:int = DeviceUtils.hitSize;
			if(DeviceUtils.isTablet){
				if(height > viewHeight * .09){ height = viewHeight * .09; }
			} else {
				if(height > viewHeight * .11){ height = viewHeight * .11; }
				if(DeviceUtils.screenScale < 1){
					height *= 1.15;
				}
			}
			if(isPortrait){ height *= .65; }
			
			topMenu.setSize(viewWidth, height);
			
			viewStack.y = height;
			viewStack.setSize(viewWidth, viewHeight - viewStack.y);
			
			if(facebookBrowser){
				facebookBrowser.setSize(viewWidth, viewHeight);
			}
			
			if(frameShopPrompt){
				frameShopPrompt.setSize(viewWidth, viewHeight);
			}
			
			if(coreImageTestView){
				coreImageTestView.setSize(viewWidth, viewHeight);
			}
			
			if(currentUnlockOffer && currentUnlockOffer.stage){
				currentUnlockOffer.setSize(viewWidth, viewHeight);
			}
			
			updateSpinner();
			DialogManager.setSize(viewWidth, viewHeight);
		}
		
		protected function updateSpinner():void {
			if(!spinner){ return; }
			spinner.x = viewWidth/2;
			spinner.y = viewHeight/2;
			spinner.width = DeviceUtils.hitSize;
			spinner.height = DeviceUtils.hitSize;
			spinnerUnderlay.width = viewWidth;
			spinnerUnderlay.height = viewHeight;
		}
		
		public function back():void {
			isLoading = false;
			if(editView && editView.back()){
				return;
			}
			viewStack.pop(true);
			currentView = viewStack.currentView;
		}
		
		public function closeMenus():void {
			editView.setCurrentMenu(null);
			editView.editMenu.deselectButton();
		}
		
		public function hideTopButtons(value:Boolean = true):void {
			topMenu.compareButton.visible = !value;
			topMenu.closeButton.visible = !value;
		}
	}
}
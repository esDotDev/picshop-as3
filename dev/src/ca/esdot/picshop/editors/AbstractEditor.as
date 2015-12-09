package ca.esdot.picshop.editors
{
	import com.gskinner.motion.GTween;
	import com.gskinner.ui.touchscroller.TouchScrollEvent;
	import com.gskinner.ui.touchscroller.TouchScrollListener;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.data.TweenConstants;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.utils.TextFields;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.components.ButtonBar;
	import ca.esdot.picshop.components.buttons.HideButton;
	import ca.esdot.picshop.components.buttons.LabelButton;
	import ca.esdot.picshop.components.buttons.UndoButton;
	import ca.esdot.picshop.data.ButtonLabels;
	import ca.esdot.picshop.data.colors.ColorTheme;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	import ca.esdot.picshop.events.EditorEvent;
	import ca.esdot.picshop.events.UnlockEvent;
	import ca.esdot.picshop.views.AdView;
	import ca.esdot.picshop.views.EditView;
	import ca.esdot.picshop.views.ImageView;
	
	import swc.LockIcon;
	
	public class AbstractEditor extends SizableView
	{
		protected static var undoDragPt:Point;
		
		protected var editingDownscale:Number;
		protected var instructions:TextField;
		
		protected var contentTween:GTween;
		protected var hideButtonTween:GTween;
		
		public var sourceData:BitmapData;
		protected var sourceDataSmall:BitmapData;

		protected var hideButton:HideButton;
		protected var scrollListener:TouchScrollListener;
		
		public var editView:EditView;
		public var imageView:ImageView;
		public var buttonBar:ButtonBar;
		public var undoButton:UndoButton;
		public var adView:AdView;
		
		public var bg:Bitmap;
		
		protected var settingsDirty:Boolean;
		
		protected var contentLayer:Sprite;
		protected var controlsLayer:Sprite;
		
		protected var processTimer:Timer;
		protected var processInterval:int = 250;
		protected var historyStates:Array;
		protected var padding:int = 10;
		protected var undoIsDragging:Boolean;
		protected var isHidden:Boolean;
		private var _isLocked:Boolean;
		
		protected var divider:Bitmap;
		protected var controlsPadding:int;
		
		public function AbstractEditor(editView:EditView) {
			
			controlsPadding = DeviceUtils.paddingSmall;
			
			this.editView = editView;
			imageView = editView.imageView;
			
			sourceData = currentBitmapData.clone();
			sourceDataSmall = sourceData;
			
			editingDownscale = .65;
			
			contentLayer = new Sprite();
			addChild(contentLayer);
			
			//Create Children
			bg = new Bitmap(SharedBitmaps.bgColor);
			bg.alpha = 1;//.9;
			contentLayer.addChild(bg);
			
			controlsLayer = new Sprite();
			contentLayer.addChild(controlsLayer);
			
			divider = new Bitmap(SharedBitmaps.accentColor);
			contentLayer.addChild(divider);
			
			buttonBar = new ButtonBar();
			buttonBar.setButtons([ButtonLabels.DISCARD, ButtonLabels.APPLY]);
			buttonBar.addEventListener(ButtonEvent.CLICKED, onButtonClicked, false, 0, true);
			addChild(buttonBar);
			
			//Undo support
			historyStates = [];
			undoButton = new UndoButton();
			undoButton.addEventListener(MouseEvent.CLICK, onUndoClicked, false, 0, true);
			//Undo button is draggable so it can be moved.
			scrollListener = new TouchScrollListener(undoButton, true, true);
			
			
			//Sub-Classes override this and should add children to the 'childrenContainer' sprite
			createChildren();
			
			hideButton = new HideButton();
			hideButton.addEventListener(MouseEvent.CLICK, onHideClicked, false, 0, true);
			//addChild(hideButton);
			//Sub-Classes can call start on timer to begin. Adjust timing interval as needed.
			processTimer = new Timer(processInterval, 0);
			processTimer.addEventListener(TimerEvent.TIMER, onTimerTick, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
			
			//Sub-Classes can call setInstructions() to show a tip along the top of the screen.
			instructions = TextFields.getBold(DeviceUtils.fontSize * .75, 0xCCCCCC, "center");
			ColorTheme.colorTextfield(instructions);
			instructions.opaqueBackground = ColorTheme.bgColor2;
		}
		
		override public function destroy():void {
			
			if(processTimer.running){
				processTimer.stop();
			}
			processTimer.removeEventListener(TimerEvent.TIMER, onTimerTick);
			
			sourceData = null;
			sourceDataSmall = null;
			
			if(contentTween){
				contentTween.end();
				contentTween = null;
			}
			
			ColorTheme.removeSprite(instructions);
			
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			if(hideButton){
				hideButton.removeEventListener(MouseEvent.CLICK, onHideClicked);
				hideButton.destroy();
				hideButton = null;
			}
				
			if(scrollListener){
				scrollListener.destroy();
				scrollListener = null;
			}	
			
			if(editView){
				editView.destroy();
				editView = null;
			}
			
			if(imageView){
				imageView.destroy();
				imageView = null;
			}

			if(buttonBar){
				buttonBar.removeEventListener(ButtonEvent.CLICKED, onButtonClicked);
				buttonBar.destroy();
				buttonBar = null;
			}
			
			if(undoButton){
				undoButton.removeEventListener(MouseEvent.CLICK, onUndoClicked);
				undoButton.destroy();
			}
		
		}
		
		protected function onHideClicked(event:MouseEvent):void {
			if(isHidden){
				isHidden = false;
				contentTween.proxy.y = viewHeight - bg.height;
				hideButtonTween.proxy.y = viewHeight - buttonBar.height - bg.height;
			} else {
				isHidden = true;
				contentTween.proxy.y = buttonBar.y - hideButton.height;
				hideButtonTween.proxy.y = buttonBar.y - hideButton.height;
			}
		}
		
		public function get isLocked():Boolean { return _isLocked; }
		public function set isLocked(value:Boolean):void {
			_isLocked = value;
			var b:LabelButton = buttonBar.buttonList[1];
			b.icon = value? new swc.LockIcon() : null;
		}
		
		public function showAd(value:Boolean):void {
			if(value){
				if(!adView){ adView = new AdView(); }
				adView.random();
				adView.useSmall = viewWidth < 500;
				adView.x = viewWidth - adView.width >> 1;
				adView.y = editView.marginTop;
				adView.addEventListener(UnlockEvent.UNLOCK, onAdUnlock, false, 0, true);
				addChild(adView);
				
				new GTween(adView, TweenConstants.NORMAL, {y: adView.y}, {ease: TweenConstants.EASE_OUT});
				adView.y -= 100;
				
			} else {
				if(adView){
					removeChild(adView);
					adView = null;
				}
			}
		}
		
		protected function onAdUnlock(event:UnlockEvent):void {
			showAd(false);
			dispatchEvent(event);
		}
		
		protected function onUndoButtonDrag(event:TouchScrollEvent):void {
			undoButton.x -= event.mouseDeltaX;
			undoButton.y -= event.mouseDeltaY;
			
			if(undoButton.x < 0){ undoButton.x = 0; }
			if(undoButton.x > viewWidth - undoButton.width){
				undoButton.x = viewWidth - undoButton.width;
			}
			
			if(undoButton.y < editView.marginTop){ undoButton.y = editView.marginTop; }
			if(undoButton.y > controlsLayer.y - undoButton.height){
				undoButton.y = controlsLayer.y - undoButton.height;
			}
			undoIsDragging = true;
			if(!undoDragPt){ undoDragPt = new Point(); }
			undoDragPt.x = undoButton.x;
			undoDragPt.y = undoButton.y;
		}
		
		
		public function init():void {
			
			var scale:Number = Math.min(1, Math.max(editView.viewWidth/sourceData.width, editView.viewHeight/sourceData.height));
			scale *= editingDownscale;
			
			var matrix:Matrix = new Matrix();
			matrix.scale(scale, scale);
			
			sourceDataSmall = new BitmapData(sourceData.width * scale, sourceData.height * scale, true, 0);
			sourceDataSmall.draw(sourceData, matrix, null, null, null, true);
			
			setCurrentBitmapData(sourceDataSmall.clone());
		}
		
		protected function setCurrentBitmapData(value:BitmapData, size:Boolean = true):void {
			if(!editView){ return; }
			editView.imageView.setCurrentBitmap(value, size);
		}
		
		override public function updateLayout():void {
			
			divider.width = viewWidth;
			divider.height = 2;
			
			buttonBar.setSize(viewWidth, DeviceUtils.hitSize);
			buttonBar.y = viewHeight - buttonBar.height;
			var b:LabelButton = buttonBar.buttonList[1];
			if(b.icon){ // Center align button icons (SB: Is this still needed?) 
				b.icon.x = b.width/2 - b.labelText.textWidth/2 - b.icon.width; 
			}
			
			//Layout the child controls
			updateControlsLayout();
			controlsLayer.y = controlsPadding;
			
			bg.width = viewWidth;
			bg.height = controlsLayer.height + controlsPadding * 2 + buttonBar.viewHeight;
			
			hideButton.setSize(DeviceUtils.hitSize, DeviceUtils.hitSize * .25);
			hideButton.x = viewWidth - hideButton.width >> 1;
			
			hideButton.visible = (bg.height > 0);
			
			contentLayer.y = viewHeight - bg.height;
			hideButton.y = contentLayer.y;
			
			if(instructions){
				instructions.width = viewWidth - 20;
				instructions.x = 10;
				instructions.y = -instructions.height;
			}
			padding = viewWidth * .025;
		}
		
		override public function transitionIn():void {
			contentTween = new GTween(contentLayer, TweenConstants.NORMAL, {y: viewHeight - bg.height}, {ease: TweenConstants.EASE_OUT});
			contentLayer.y = viewHeight;
			
			hideButtonTween = new GTween(hideButton, TweenConstants.NORMAL, {y: viewHeight - bg.height}, {ease: TweenConstants.EASE_OUT});
			hideButton.y = viewHeight;
			
			if(instructions){
				new GTween(instructions, TweenConstants.LONG, {y: 0}, {ease: TweenConstants.EASE_OUT, delay: TweenConstants.NORMAL});
				instructions.y = -50;
				new GTween(instructions, TweenConstants.SHORT, {y: -instructions.height}, {ease: TweenConstants.EASE_OUT, delay: 6.5});
			}
			
			buttonBar.y = viewHeight;
			new GTween(buttonBar, TweenConstants.NORMAL, {y: viewHeight - buttonBar.height}, {ease: TweenConstants.EASE_OUT});
			
		}
		
		
		override public function transitionOut():void {
			if(processTimer.running){ 
				processTimer.stop(); 
			}
			
			if(instructions){
				if(instructions && MainView.instance.contains(instructions)){
					MainView.instance.removeChild(instructions);
				}
			}
			if(contentLayer){
				contentLayer.removeChildren();
			}
			if(hideButton && contains(hideButton)){
				removeChild(hideButton);
			}
			if(undoButton && undoButton.parent){
				undoButton.parent.removeChild(undoButton);
			}
			showAd(false);
			new GTween(buttonBar, TweenConstants.NORMAL, {y: viewHeight}, {ease: TweenConstants.EASE_OUT, onComplete:onTransitionOutComplete});
		}
		
		public function onTransitionOutComplete(tween:GTween):void {
			if(parent){
				parent.removeChild(this);
			}
		}
		
		public function setInstructions(value:String):void {
			instructions.text = value;
			MainView.instance.addChild(instructions);
		}
		
		public function get currentBitmapData():BitmapData {
			return editView.imageView.bitmap.bitmapData;
		}
		
		public function get currentBitmap():Bitmap {
			return editView.imageView.bitmap;
		}
		
		public function scaleImageView(skipTween:Boolean = false):void {
			var height:int =  editView.stage.stageHeight - controlsLayer.height - buttonBar.viewHeight - controlsPadding * 2;
			editView.imageView.scaleView(editView.viewWidth, height, skipTween);
		}
		
		protected function onButtonClicked(event:ButtonEvent):void {
			if(event.label == ButtonLabels.APPLY){
				dispatchEvent(new EditorEvent(EditorEvent.APPLY));
			} else {
				discardEdits();
			}
		}
		
		public function discardEdits():void {
			dispatchEvent(new EditorEvent(EditorEvent.DISCARD));
		}
		
		
		
		protected function onUndoClicked(event:MouseEvent):void {
			if(undoIsDragging){ undoIsDragging = false; return; }
			if(!historyStates || historyStates.length == 0){ return; }
			setCurrentBitmapData(historyStates.pop(), false);
			
			if(historyStates.length == 0){
				undoButton.hide();
			}
		}
		
		protected function showUndo():void {
			if(!stage){ return ; }
			
			undoButton.show();
			addChild(undoButton);
			undoButton.setSize(DeviceUtils.hitSize * 1.5, DeviceUtils.hitSize * .5);
			
			if(!undoDragPt){
				undoButton.x = DeviceUtils.padding;
				undoButton.y = contentLayer.y - undoButton.height - DeviceUtils.padding;
			} else {
				undoButton.x = undoDragPt.x;
				undoButton.y = Math.min(undoDragPt.y, undoButton.y);
			}
			
			dispatchEvent(new EditorEvent(EditorEvent.UNDO));
			
		}	
		
		public function applyToSource():BitmapData { 
			return null;
		}
		
		public function createChildren():void {}
		protected function updateControlsLayout():void {}
		protected function applyChanges():void {};
			
		protected function onRemovedFromStage(event:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		protected function onTimerTick(event:TimerEvent):void {
			var t:int = getTimer();	
			var applied:Boolean = settingsDirty;
			applyChanges();	
			if(applied){
				trace("Filter applied: ", getTimer() - t, "ms");
			}
		}
		
		
		
	}
}
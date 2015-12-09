package ca.esdot.picshop.commands
{
	import com.greensock.easing.Back;
	import com.greensock.easing.Bounce;
	import com.gskinner.motion.GTween;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	
	import ca.esdot.lib.data.TweenConstants;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.utils.SpriteUtils;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.commands.events.ShowTipEvent;
	import ca.esdot.picshop.components.buttons.UndoButton;
	import ca.esdot.picshop.data.colors.ColorTheme;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	import ca.esdot.picshop.views.ImageView;
	
	import fl.motion.easing.Quadratic;
	
	import org.robotlegs.mvcs.Command;
	
	import swc.tipMeme;
	import swc.tipsCompare;
	import swc.tipsEditMenu;
	import swc.tipsFullScreen;
	import swc.tipsOpenImage;
	import swc.tipsSave;
	import swc.tipsSettings;
	import swc.tipsUndo;
	
	public class ShowTipCommand extends Command
	{
		[Inject]
		public var event:ShowTipEvent;
		
		[Inject]
		public var model:MainModel;
		
		protected var underlay:Sprite;
		protected var tip:Sprite;

		protected var mainView:MainView;

		protected var underlayTween:GTween;
		protected var tipTween:GTween;
		
		override public function execute():void {
			
			if(model.settings.numSaves > 5){ return; }
			
			commandMap.detain(this);
			
			mainView = (contextView as MainView);
			mainView.stage.addEventListener(Event.RESIZE, onStageResized, false, 0, true);
			mainView.editView.imageView.isFullScreenEnabled = false;
			
			var pt:Point;
			if(event.tipTarget){
				pt = event.tipTarget.localToGlobal(new Point());
			}
			
			underlay = new Sprite();
			var bmp:Bitmap = new Bitmap(SharedBitmaps.bgColor);
			var tipScale:Number = Math.max(1, DeviceUtils.screenScale);
			
			bmp.alpha = .8;
			underlay.addChild(bmp);
			
			switch(event.type) {
				
				case ShowTipEvent.COMPARE:
					tip = new swc.tipsCompare();
					tip.scaleX = tip.scaleY = tipScale;
					tip.y = mainView.topMenu.compareButton.y + mainView.topMenu.compareButton.height;
					underlay.width = mainView.stage.stageWidth;
					underlay.height = mainView.stage.stageHeight;
					showTip(tip);
					
					mainView.topMenu.addChildAt(underlay, mainView.topMenu.getChildIndex(event.tipTarget));
					break;
				
				case ShowTipEvent.SAVE:
					tip = new swc.tipsSave();
					tip.scaleX = tip.scaleY = tipScale;
					tip.y = mainView.stage.stageHeight - tip.height - event.tipTarget.height * .7;
					tip.x = mainView.stage.stageWidth - tip.width * 1.35;
					underlay.width = mainView.stage.stageWidth;
					underlay.height = mainView.stage.stageHeight - event.tipTarget.height;
					showTip(tip);
					break;
				
				case ShowTipEvent.MEME:
					tip = new swc.tipMeme();
					tip.scaleX = tip.scaleY = tipScale;
					tip.y = mainView.stage.stageHeight - tip.height - event.tipTarget.height >> 1;
					tip.x = mainView.stage.stageWidth - tip.width >> 1;
					underlay.width = mainView.stage.stageWidth;
					underlay.height = tip.height * 1.25;
					showTip(tip);
					underlay.y = tip.y - (underlay.height - tip.height >> 1);
					break;
				
				case ShowTipEvent.OPEN_IMAGE:
					tip = new swc.tipsOpenImage();
					tip.scaleX = tip.scaleY = tipScale;
					tip.y = pt.y - tip.height;
					tip.x = pt.x + event.tipTarget.width/2;
					underlay.width = mainView.stage.stageWidth;
					underlay.height = mainView.stage.stageHeight - event.tipTarget.height * .8;
					showTip(tip);
					break;
				
				case ShowTipEvent.SETTINGS:
					tip = new swc.tipsSettings();
					tip.scaleX = tip.scaleY = tipScale;
					tip.y = pt.y + event.tipTarget.height + 10;
					tip.x = pt.x  - (tip.width - event.tipTarget.width >> 1);;
					underlay.width = mainView.stage.stageWidth;
					underlay.height = mainView.stage.stageHeight;
					underlay.y = pt.y + event.tipTarget.height;
					showTip(tip);
					break;
				
				case ShowTipEvent.UNDO_BUTTON_DRAG:
					tip = new swc.tipsUndo();
					tip.scaleX = tip.scaleY = tipScale;
					tip.y = pt.y - tip.height * 1.1;
					tip.x = pt.x - (tip.width - event.tipTarget.width >> 1);
					(event.tipTarget as UndoButton).paused = true;
					underlay.width = mainView.stage.stageWidth;
					underlay.height = mainView.stage.stageHeight;
					showTip(tip);
					break;
				
				case ShowTipEvent.PINCH_TO_ZOOM:
					tip = new swc.tipsFullScreen();
					tip.scaleX = tip.scaleY = tipScale;
					tip.x = pt.x + (event.tipTarget.width - tip.width >> 1);
					tip.y = event.tipTarget.localToGlobal(new Point(0, event.tipTarget.height)).y;
					
					underlay.width = mainView.stage.stageWidth;
					underlay.height = mainView.stage.stageHeight;
					showTip(tip);
					
					var imageView:ImageView = mainView.editView.imageView;
					mainView.editView.setChildIndex(imageView, Math.min(2, mainView.editView.numChildren - 1));
					imageView.addChild(tip);
					imageView.addChildAt(underlay, 0);
					break;
				
				case ShowTipEvent.EDIT_MENU:
					tip = new swc.tipsEditMenu();
					tip.scaleX = tip.scaleY = tipScale;
					tip.x = pt.x + mainView.stage.stageWidth * .1;
					tip.y = pt.y - event.tipTarget.height;
					
					underlay.width = mainView.stage.stageWidth;
					underlay.height = mainView.stage.stageHeight - event.tipTarget.height + 10;
					showTip(tip);
				
			}
			
		}
		
		protected function onStageResized(event:Event):void {
			releaseCommand();
		}
		
		protected function showTip(tip:Sprite, alpha:Number = .85):void {
			mainView.addChild(underlay);
			mainView.addChild(tip);
			
			if(ColorTheme.whiteMode){
				var cf:ColorTransform = tip.transform.colorTransform;
				cf.color = 0x0;
				tip.transform.colorTransform = cf;
			}
			
			underlayTween = new GTween(underlay, TweenConstants.NORMAL, {alpha: alpha}, {ease:Quadratic.easeOut});
			underlay.alpha = 0;
			
			tipTween =  new GTween(tip, TweenConstants.LONG, {x: tip.x}, {ease:Back.easeOut, delay: TweenConstants.SHORT, onComplete:onTweenComplete});
			tip.x = -tip.width - 50;
			
			tip.mouseEnabled = false;
			mainView.mouseEnabled = mainView.mouseChildren = false;
			
		}
		
		protected function onTweenComplete(tween:GTween):void {
			mainView.mouseEnabled = mainView.mouseChildren = true;
			mainView.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
		}
		
		protected function onMouseDown(event:MouseEvent):void {
			releaseCommand();
		}
		
		protected function releaseCommand():void {
			commandMap.release(this);
			mainView.editView.setChildIndex(mainView.editView.imageView, 0);
			
			mainView.editView.imageView.isFullScreenEnabled = true;
			
			if(event.tipTarget is UndoButton){
				(event.tipTarget as UndoButton).paused = false;
			}
			
			if(underlay){
				underlay.parent.removeChild(underlay);
				underlay = null;
			}
			if(tip){
				tip.parent.removeChild(tip);
				tip = null;
			}
			
		}
	}
}
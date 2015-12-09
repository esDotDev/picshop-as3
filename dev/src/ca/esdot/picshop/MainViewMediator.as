package ca.esdot.picshop
{
	import flash.desktop.NativeApplication;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	
	import assets.Bitmaps;
	
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.events.ViewEvent;
	import ca.esdot.picshop.commands.events.ChangeViewEvent;
	import ca.esdot.picshop.commands.events.CommandEvent;
	import ca.esdot.picshop.commands.events.SettingsEvent;
	import ca.esdot.picshop.data.ViewTypes;
	import ca.esdot.picshop.events.ImageViewEvent;
	import ca.esdot.picshop.events.ModelEvent;
	import ca.esdot.picshop.views.FacebookBrowser;
	import ca.esdot.picshop.views.FullScreenImageView;
	import ca.esdot.picshop.views.SettingsPanel;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class MainViewMediator extends Mediator
	{
		[Inject]
		public var view:MainView;
		
		[Inject]
		public var mainModel:MainModel;
		protected var fullScreenImage:FullScreenImageView;
		protected var facebookBrowser:FacebookBrowser;
		
		override public function onRegister():void {
			addContextListener(ModelEvent.VIEW_CHANGED, onViewChanged, ModelEvent);
			
			addViewListener(ImageViewEvent.IMAGE_CLICKED, onImageClicked, ImageViewEvent);
			
			view.downloadFrameShopClicked.add(onFrameShopDownloaded);
			view.stage.addEventListener(Event.RESIZE, onStageResize, false, 0, true);
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
		}
		
		protected function onFrameShopDownloaded():void {
			
			dispatch(new CommandEvent(CommandEvent.OPEN_FRAMESHOP_LINK));
			mainModel.settings.numFrameshopPrompts = int.MAX_VALUE;
			dispatch(new SettingsEvent(SettingsEvent.SAVE));
		}
		
		protected function onOpenFacebookImage(event:ViewEvent):void {
			view.showFacebookBrowser();
		}
		
		protected function onStageResize(event:Event):void {
			dispatch(new CommandEvent(CommandEvent.RESIZE_APP));
			if(fullScreenImage){
				fullScreenImage.setSize(view.stage.stageWidth, view.stage.stageHeight);
			}
		}
		
		protected function onKeyDown(event:KeyboardEvent):void {
			if(event.keyCode == Keyboard.BACK || event.keyCode == Keyboard.F1){
				view.isLoading = false;
				if(fullScreenImage && fullScreenImage.stage){
					fullScreenImage.remove();
					event.preventDefault();
				}
				else if(DialogManager.currentDialog){
					DialogManager.removeDialogs();
					event.preventDefault();
				}
				else if(view.currentUnlockOffer != null){
					view.removeUpgradeOffer();
					event.preventDefault();
				}
				else if(mainModel.currentView == ViewTypes.SAVE){
					dispatch(new ChangeViewEvent(ChangeViewEvent.BACK, null));
					event.preventDefault();
				} else {
					if(mainModel.currentEditor){
						mainModel.currentEditor.discardEdits();
						event.preventDefault();
					} 
					else if(view.editView.back()){
						event.preventDefault();
						return;
					}
					else if(view.editView.currentMenu){
						view.editView.closeEditMenu();
						event.preventDefault();
					}
				}
			} else if(Capabilities.isDebugger){
				if(event.keyCode == Keyboard.SPACE){
					var images:Array = [Bitmaps.testImage, Bitmaps.sunset, Bitmaps.sadCat];
					if(!images[0]){ return; }
					var bitmapData:BitmapData = new images[Math.round((images.length - 1) * Math.random())]().bitmapData;
					//Set source image
					//mainModel.sourceData = bitmapData;
					
				}
			}
		}
		
		protected function onImageClicked(event:ImageViewEvent):void {
			if(mainModel.isPreviewEnabled == false){ return; }
			if(view.fullScreen){
				fullScreenImage = new FullScreenImageView(view.editView.imageView.currentBitmap);
			} else {
				fullScreenImage = new FullScreenImageView(mainModel.sourceData);
			}
			view.addChild(fullScreenImage);
			
		}
		
		protected function onViewChanged(event:ModelEvent):void {
			view.show(mainModel.currentView);
		}
	}
}
package ca.esdot.picshop.commands
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MediaEvent;
	import flash.filesystem.File;
	import flash.media.CameraRoll;
	import flash.media.MediaPromise;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	
	import assets.Bitmaps;
	
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.dialogs.TitleDialog;
	import ca.esdot.picshop.utils.AnalyticsManager;
	import ca.esdot.picshop.views.FullscreenCropView;
	
	import org.robotlegs.mvcs.Command;
	
	public class AddImageLayerCommand extends Command
	{
		private var currentPromise:MediaPromise;
		private var loader:Loader;
		
		override public function execute():void {
			commandMap.detain(this);
			if(CameraRoll.supportsBrowseForImage) {
				var camera:CameraRoll = new CameraRoll();
				camera.browseForImage();
				camera.addEventListener(MediaEvent.SELECT, onPhotoSelected);
				camera.addEventListener(Event.CANCEL, onCancel);
			} 
			else if(Capabilities.isDebugger && Bitmaps.transparent){
				openCropView(new Bitmaps.transparent().bitmapData);
			}
			else {
				DialogManager.alert("Error", "This device doesn't seem to support browsing for files. Possible permission issue?");
			}
		}
		
		protected function onCancel(event:Event):void {
			releaseCommand();
		}
		
		protected function onPhotoSelected(event:MediaEvent):void {
			(contextView as MainView).stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			currentPromise = event.data;
			loadPhotoBitmap();
		}
		
		protected function loadPhotoBitmap(file:File = null):void {
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.INIT, onPhotoBitmapLoadComplete, false, 0, true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, photoFailed, false, 0, true);
			loader.loadFilePromise(currentPromise);
		}
		
		protected function onPhotoBitmapLoadComplete(event:Event):void {
			var bitmapData:BitmapData = (event.target.content as Bitmap).bitmapData;
			openCropView(bitmapData);
		}
		
		protected function openCropView(bitmapData:BitmapData):void {
			var cropView:FullscreenCropView = new FullscreenCropView(bitmapData);
			contextView.addChild(cropView);
			cropView.setSize(contextView.stage.stageWidth, contextView.stage.stageHeight);
			releaseCommand();
		}
		
		protected function photoFailed(event:IOErrorEvent = null):void {
			DialogManager.alert("Woops", "Something went wrong...");
			
			releaseCommand();
		}
		
		protected function releaseCommand():void {
			commandMap.release(this);
		}
	}
}
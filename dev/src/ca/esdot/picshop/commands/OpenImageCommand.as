package ca.esdot.picshop.commands
{
	import com.freshplanet.ane.AirImagePicker.AirImagePicker;
	import com.vitapoly.nativeextensions.coreimage.CoreImage;
	import com.vitapoly.nativeextensions.coreimage.ImageFilter;
	import com.vitapoly.nativeextensions.coreimage.MediaPromiseReader;
	import com.vitapoly.nativeextensions.coreimage.events.MediaPromiseImageLoadedEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MediaEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.media.CameraRoll;
	import flash.media.CameraRollBrowseOptions;
	import flash.media.CameraUI;
	import flash.media.MediaPromise;
	import flash.media.MediaType;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import assets.Bitmaps;
	
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.image.ImageProcessing;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.commands.events.OpenImageEvent;
	import ca.esdot.picshop.commands.events.SettingsEvent;
	import ca.esdot.picshop.commands.events.ShowTipEvent;
	import ca.esdot.picshop.utils.AnalyticsManager;
	
	import jp.shichiseki.exif.ExifInfo;
	import jp.shichiseki.exif.ExifLoader;
	
	import org.robotlegs.mvcs.Command;
	
	public class OpenImageCommand extends Command
	{
		[Inject]
		public var event:OpenImageEvent;
		
		[Inject]
		public var mainModel:MainModel;
		
		protected var loader:Loader;
		protected var currentPromise:MediaPromise;
		
		protected var exifLoader:ExifLoader;
		protected var exifRotation:int = 0;
		
		protected var imagePicker:AirImagePicker;
		protected var coreImage:CoreImage;
		
		override public function execute():void {
			trace("Open Image!", CameraUI.isSupported);
			
			imagePicker = AirImagePicker.getInstance();
			
			//Load specific BitmapData
			if(event.type == OpenImageEvent.BITMAP_DATA){
				setSource(event.data);
			}
			//Load a specific file
			else if(event.type == OpenImageEvent.URL){
				var file:File = new File(event.url);
				if(file.exists){
					loadPhotoBitmap(file);
				}
			}
			
			//Load a default image if the device doesn't have a Camera ( desktop )
			else if(!CameraRoll.supportsBrowseForImage && Bitmaps.testImage){
				var defaultImage:BitmapData = new Bitmaps.testImage().bitmapData;
				setSource(defaultImage);
			}
			
			//Load from Device...
			else {
				//Camera
				if(event.type == OpenImageEvent.CAMERA && CameraUI.isSupported){
					if(imagePicker && imagePicker.isCameraAvailable()){
						imagePicker.displayCamera(function(status:String, ...mediaArgs):void {
							//Load was successful
							if(status == AirImagePicker.STATUS_OK && mediaArgs[0] is BitmapData){
								setSource(mediaArgs[0]);
							}
							//Error!
							else {
								photoFailed();
							}
							
						});
					} else {
						var cameraUi:CameraUI = new CameraUI();
						cameraUi.launch(MediaType.IMAGE);
						cameraUi.addEventListener(MediaEvent.COMPLETE, onPhotoSelected);
						cameraUi.addEventListener(Event.CANCEL, onPhotoCancel);
					}
					AnalyticsManager.imageOpened();
					
				}
				//Camera Roll
				else if(CameraRoll.supportsBrowseForImage) { // || imagePicker.isImagePickerAvailable()
					
					//** SB: Disabled use of ImagePicker because of many bug reports on Android - July 8, 2014
					// 
					/*
					if(imagePicker.isImagePickerAvailable()){
						imagePicker.displayImagePicker(function(status:String, ...mediaArgs):void {
							//Load was successful
							if(status == AirImagePicker.STATUS_OK && mediaArgs[0] is BitmapData){
								setSource(mediaArgs[0]);
							}
							//Error!
							else {
								photoFailed();
							}
							
						});
					} else {
					}
					*/
						var camera:CameraRoll = new CameraRoll();
						//if(DeviceUtils.onIOS){
							//var opts:CameraRollBrowseOptions = new CameraRollBrowseOptions();
							//opts.width = contextView.stage.stageWidth * .8;
							//opts.height = contextView.stage.stageHeight * .75;
							//camera.browseForImage(opts);
						//} else {
						camera.browseForImage();
						//}
						camera.addEventListener(MediaEvent.SELECT, onPhotoSelected);
						camera.addEventListener(Event.CANCEL, onCancel);
					//}
					AnalyticsManager.imageOpened();
				} 
			}
			
			
		}
		
		protected function onCancel(event:Event):void {
			releaseCommand();
			(contextView as MainView).stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
		}
		
		protected function onPhotoSelected(event:MediaEvent):void {
			(contextView as MainView).stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			(contextView as MainView).isLoading = true;
			
			//If the coreImage Extenstion is available, use it to handle the loading of the promise.
			if(DeviceUtils.onIOS && CoreImage.isSupported){
				trace("Loading image with CoreImage: " + CoreImage.instance + " @" + getTimer());
				MediaPromiseReader.instance.addEventListener(MediaPromiseReader.IMAGE_LOADED_EVENT, onMediaPromiseEvent, false, 0, true);
				MediaPromiseReader.instance.addEventListener(MediaPromiseReader.IMAGE_NOT_LOADED_EVENT, onMediaPromiseEvent, false, 0, true);
				MediaPromiseReader.instance.read(event.data as MediaPromise);
				
			} else {
				
				currentPromise = event.data;
				
				//Check extension
				var ext:String = "jpg";
				if(currentPromise.file){
					ext = currentPromise.file.extension;
					if(ext){ ext = ext.toLowerCase(); }
				}
				
				//Say no to videos! 
				if(ext == "mp4" || ext == "3gp" || ext == "webm" || ext == "mkv" || ext == "ts"){ 
					photoFailed(null, true);
				}
				else {
						
					if(event.data.file && event.data.file.url){
						loadExifData(currentPromise.file.url);
					} else {
						loadPhotoBitmap();
					}
				}
			}
		}
		
		protected function loadExifData(url:String):void {
			exifLoader = new ExifLoader();
			exifLoader.addEventListener(Event.COMPLETE, function(event:Event):void {
				var exif:ExifInfo = exifLoader.exif;
				exifRotation = 0;
				if( exif.ifds && exif.ifds.primary && exif.ifds.primary[ "Orientation" ] ) {
					
					var PORTRAIT:int = 6;
					var PORTRAIT_REVERSE:int = 8;
					var LANDSCAPE:int = 1;
					var LANDSCAPE_REVERSE:int = 3;
					
					switch( exif.ifds.primary[ "Orientation" ] ) {
						case LANDSCAPE: exifRotation = 0; break;
						case LANDSCAPE_REVERSE: exifRotation = 180; break;
						case PORTRAIT: exifRotation = 90; break;
						case PORTRAIT_REVERSE: exifRotation = 270; break;
					}
				}
				loadPhotoBitmap();
			});
			exifLoader.addEventListener(IOErrorEvent.IO_ERROR, function(){
				loadPhotoBitmap();
			}, false, 0, true);
			exifLoader.load(new URLRequest(url));
		}
		
		protected function onMediaPromiseEvent(event:MediaPromiseImageLoadedEvent):void {
			trace("[OpenImage] Image loaded with CoreImage @" + getTimer());
			if(event.type == MediaPromiseReader.IMAGE_LOADED_EVENT){
				setSource(event.bitmapData);
				event.bitmapData = null;
			} else {
				photoFailed();
			}
			
			MediaPromiseReader.instance.removeEventListener(MediaPromiseReader.IMAGE_LOADED_EVENT, onMediaPromiseEvent);
			MediaPromiseReader.instance.removeEventListener(MediaPromiseReader.IMAGE_NOT_LOADED_EVENT, onMediaPromiseEvent);
			
		}
		
		protected function onPhotoCancel(event:Event):void {
			releaseCommand();
			(contextView as MainView).stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
		}
		
		protected function loadPhotoBitmap(file:File = null):void {
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.INIT, onPhotoBitmapLoadComplete, false, 0, true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, photoFailed, false, 0, true);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, function(event:ProgressEvent){ 
				trace(1); 
			}, false, 0, true);
			loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, function(event:HTTPStatusEvent){ 
				trace(1); 
			}, false, 0, true);
			
			if(file){
				trace("Restoring Session: ", file.url);
				loader.load(new URLRequest(file.url));
			} else if(currentPromise){
				trace("Opening Promise: ", currentPromise);
				loader.loadFilePromise(currentPromise);
			} 
		}
		
		protected function onPhotoBitmapLoadComplete(event:Event):void {
			var bitmapData:BitmapData = (event.target.content as Bitmap).bitmapData;
			setSource(bitmapData);
		}
		
		protected function setSource(bitmapData:BitmapData):void {
			if(exifRotation != 0){
				bitmapData = ImageProcessing.rotateBy90(exifRotation/90, bitmapData);
			}
			
			var mainView:MainView = (contextView as MainView);
			mainView.closeMenus();
			
			//Empty history
			mainModel.clearHistory();
			
			//Set source image
			trace("[OpenImage] Inject Source Data @" + getTimer());
			mainModel.sourceData = bitmapData;
			
			//Add history
			mainModel.addHistory(mainModel.sourceData);
			
			//Show Settings Tip?
			if(++mainModel.settings.numOpenImage == 1){
				dispatch(new ShowTipEvent(ShowTipEvent.EDIT_MENU, (contextView as MainView).editView.editMenu.buttonContainer));
			}
			else if(mainModel.settings.numSettingsOpened < 1){
				dispatch(new ShowTipEvent(ShowTipEvent.SETTINGS, (contextView as MainView).topMenu.logo));
			} 
			
			dispatch(new SettingsEvent(SettingsEvent.SAVE));
		
			trace("[OpenImage] Completed @" + getTimer());
			
			//Clear old scratch file
			mainModel.updateScratchFile();
			
			releaseCommand();
		}
		
		protected function photoFailed(event:IOErrorEvent = null, isVideo:Boolean = false):void {
			trace("[LoadImage] Unable to load image", event? event.toString() : "");
			var message:String = "Something went wrong when opening the image. Please try again.";
			if(DeviceUtils.onAmazon || DeviceUtils.onAndroid){
				message = "This image failed to load... try again? Note that remote Albums (ie Picasa and Google+) are not currently supported.";
			}
			if(DeviceUtils.onBB10 || DeviceUtils.onPlayBook){
				message = "This image failed to load. Check your BB10 Security Settings to make sure PicShop has access to your Photos.";
			}
			
			if(isVideo){
				message = "This looks like a video file. I can't edit videos :'( "	
			}
			
			DialogManager.alert("Woops...", message); 
			releaseCommand();
		}
		
		protected function releaseCommand():void {
			
			(contextView as MainView).isLoading = false;
			commandMap.release(this);
		}
		
		
		
	}
}
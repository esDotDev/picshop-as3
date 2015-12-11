
package ca.esdot.lib.utils
{
	import com.mika.ane.refreshgallery.RefreshGallery;
	import com.vitapoly.nativeextensions.coreimage.CameraRollExport;
	import com.vitapoly.nativeextensions.coreimage.CoreImage;
	
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.media.CameraRoll;
	import flash.utils.ByteArray;
	
	import by.blooddy.crypto.image.PNG24Encoder;
	
	import ca.esdot.picshop.MainModel;
	
	public class ImageWriter extends EventDispatcher
	{	

		public var saveLocationName:String;

		protected var roll:CameraRoll;
		
		public function write(bmpData:BitmapData, target:File=null, quality:int = 100):void {
			//If we can push to CameraRoll, do it.
		
			var fileName:String = "PicShop-" + GUID.create().split("-").join("") + ".png";
			
			if(target){
				saveLocationName = target.url;
				if(saveLocationName.length > 30){
					saveLocationName = saveLocationName.substr(saveLocationName.length-31, 31);
				}
				try {
					writeJPG(bmpData, target, quality);
					dispatchEvent(new Event(Event.COMPLETE));
				} catch(e:Error){
					dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
				}
				
			}
			else if(DeviceUtils.onAndroid || DeviceUtils.onAmazon){
				var rootDir:File = MainModel.saveDir;
				if(!rootDir.exists){
					rootDir.createDirectory();
				}
				rootDir = rootDir.resolvePath(fileName);  
				saveLocationName = rootDir.parent.nativePath;
				
				try {
					writeJPG(bmpData, rootDir, 100);
					
					//Refresh Android 'MediaScanner' API
					if(RefreshGallery.instance){
						RefreshGallery.instance.refresh(rootDir.nativePath);
					}
					
					dispatchEvent(new Event(Event.COMPLETE));
				} catch(e:Error){
					dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
				}
				
			}
			else if(CameraRoll.supportsAddBitmapData){
				//TODO: Use new cameraRoll from Distriqt
				if(!roll){ roll = new CameraRoll(); }
				roll.addEventListener(ErrorEvent.ERROR, dispatchEvent, false, 0, true);
				roll.addEventListener(Event.COMPLETE, dispatchEvent, false, 0, true);
				roll.addBitmapData(bmpData); 
				
				saveLocationName = " your Camera Roll.";
				
			} else {
				//Write to desktop
				var file:File = File.desktopDirectory.resolvePath("Images");
				file = file.resolvePath(fileName);
				
				saveLocationName = file.url;
				if(saveLocationName.length > 100){
					saveLocationName = saveLocationName.substr(saveLocationName.length-100, 100);
				}
				saveLocationName = " your Camera Roll.";
				if(target){	file = target; }
				try {
					writePNG(bmpData, file);
					dispatchEvent(new Event(Event.COMPLETE));
				} catch(e:Error){
					dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
				}
			}
		}
		
		protected function onAndroidFailed(event:Event):void {
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
		}
		
		protected function onAndroidSaved(event:Event):void {
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function writeJPG(bitmapData:BitmapData, file:File, quality:int):void {
			var byteArray:ByteArray = new ByteArray(); 
			
			bitmapData.encode(bitmapData.rect, new JPEGEncoderOptions(quality), byteArray);
			
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeBytes(byteArray);
			stream.close();
	
			
		}
		
		public function writePNG(bmpData:BitmapData, file:File):void {
			var bytes:ByteArray = PNG24Encoder.encode(bmpData);
			
			var stream:FileStream = new FileStream()
			stream.open(file, FileMode.WRITE);
			stream.writeBytes(bytes);
			stream.close();
		}
	}
}
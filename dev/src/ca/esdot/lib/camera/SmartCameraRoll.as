package ca.esdot.lib.camera
{
	import ca.esdot.lib.filesystem.FileFinder;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.media.CameraRoll;
	import flash.net.FileReference;
	import flash.system.Capabilities;

	public class SmartCameraRoll extends CameraRoll
	{
		protected const PLAYBOOK:String = "playbook";
		protected const ANDROID:String = "android";
		protected const IOS:String = "iOs";
		
		protected const ANDROID_IMAGE_DIR:String = File.userDirectory.resolvePath("DCIM").nativePath;
		protected const PLAYBOOK_IMAGE_DIR:String = File.desktopDirectory.parent.resolvePath("camera").nativePath;
		//NEED TO TEST:
		protected const IOS_IMAGE_DIR:String = File.userDirectory.resolvePath("DCIM").nativePath;
		
		protected var deviceType:String;
		protected var fileName:String = "";
		protected var imageDir:String = "";
		
		public var file:File;
		
		override public function addBitmapData(bitmapData:BitmapData):void {
			super.addBitmapData(bitmapData);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function addBitmapAs(bitmapData:BitmapData, fileName:String, imageDir:String = null):void {
			if(!CameraRoll.supportsAddBitmapData){
				dispatchEvent(new Event(Event.COMPLETE));
				return;
			}
			
			super.addBitmapData(bitmapData);
			this.file = null;
			this.fileName = fileName;
			this.imageDir = imageDir;
			
			//Determin device
			checkDevice();
			
			//Search image dir
			var fileFinder:FileFinder = new FileFinder();
			fileFinder.addEventListener(Event.COMPLETE, onFilesComplete);
			
			switch(deviceType){
				case PLAYBOOK:
					fileFinder.run([PLAYBOOK_IMAGE_DIR]); break;
				
				case IOS:
					//fileFinder.run([IOS_IMAGE_DIR]); break;
				
				case ANDROID:
					fileFinder.run([ANDROID_IMAGE_DIR]); break;
				
			}
		}
		
		protected function onFilesComplete(event:Event):void {
			event.target.removeEventListener(Event.COMPLETE, onFilesComplete);
			
			var results:Array = (event.target as FileFinder).fileList;
			var file:File;
			var latestFile:File;
			for(var i:int = 0, l:int = results.length; i < l; i++){
				file = new File(results[i]);
				if(!latestFile || file.modificationDate > latestFile.modificationDate){
					latestFile = file;
				}
			}
			if(latestFile){
				this.file = latestFile;
				if(this.fileName && this.fileName != ""){
					trace("[SmartCameraRoll] Image Location:", this.file.nativePath);	
					trace("[SmartCameraRoll] Renaming image:", this.file.name, " to ", this.fileName);	
					if(imageDir == null){
						imageDir = this.file.parent.nativePath;
					}
					var newFile:File = new File(imageDir + File.separator + this.fileName);
					try {
						this.file.copyTo(newFile, true);
						this.file.deleteFileAsync();
					}
					catch (error:Error) {
						trace("Error:", error.getStackTrace());
					}
					trace("[SmartCameraRoll] Image moved:", newFile.nativePath, ", Exists:", newFile.exists);	
				}
			}
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function checkDevice():void {
			if(Capabilities.os.toLowerCase().indexOf("playbook") > -1){
				deviceType = PLAYBOOK;
				return;
			}
			deviceType = ANDROID;
		}
	}
}
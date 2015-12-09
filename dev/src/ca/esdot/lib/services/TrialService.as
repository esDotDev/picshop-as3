package ca.esdot.lib.services
{
	import ca.esdot.lib.utils.DeviceUtils;
	
	import com.adobe.crypto.MD5;
	
	import flash.desktop.NativeApplication;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	
	public class TrialService extends EventDispatcher
	{	
		protected var PLAYBOOK_COUNT:int = 26;
		protected var ANDROID_COUNT:int = 41;
		protected var IOS_COUNT:int = 16;
		
		protected var maxCount:int;
		protected var count:int = 0;
		protected var isLoaded:Boolean;
		
		public var file1:File;
		public var file2:File;
		public var file3:File;
		
		public var disabled:Boolean = false;
		
		public function get remaining():int {
			return Math.max(maxCount - count, 0);
		}
		
		public function TrialService() {
			super();
			
			var descriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = descriptor.namespaceDeclarations()[0];
			var id:String = descriptor.ns::id;
			
			if(DeviceUtils.onPlayBook){
				maxCount = PLAYBOOK_COUNT;
				file1 = File.desktopDirectory.resolvePath(MD5.hash(id));
				file2 = File.desktopDirectory.parent.resolvePath("misc" + File.separator + MD5.hash(id + id));
			} 
			else if (DeviceUtils.onAndroid){
				maxCount = ANDROID_COUNT;
				file1 = File.userDirectory.resolvePath(MD5.hash(id));
				file2 = File.userDirectory.resolvePath("misc" + File.separator + MD5.hash(id + id))
			} 
			else {
				maxCount = IOS_COUNT;
				//IOS gives us no directories to write too.... :(
				file1 = File.applicationStorageDirectory.resolvePath(MD5.hash(id + id));
				file2 = File.applicationStorageDirectory.resolvePath(MD5.hash(id + id));
			}
			file3 = File.applicationStorageDirectory.resolvePath(MD5.hash(id + id));
		}
		
		public function get isValid():Boolean {
			if(disabled){ return true; }
			
			updateCount();
			return (count < maxCount);
		}
		
		protected function updateCount():void {
			//Check file 1 (create)
			var count:int = 0;
			if(file1.exists){
				count = load(file1);
			}
			if(file2.exists){
				count = Math.max(count, load(file2));
			}
			if(file3.exists){
				count = Math.max(count, load(file3));
			} 
			this.count = count;
			saveFiles();
		}
		
		private function saveFiles():void{
			save(file1);
			save(file2);
			save(file3);
		}
		
		public function increment():int {
			if(disabled){
				return 0;
			}
			
			updateCount();
			count++;
			saveFiles();
			
			trace("[TrialService] Trial Status: " + count + " images.");
			return remaining;
		}
		
		protected function load(file:File):int {
			var inputBytes:ByteArray = new ByteArray();
			var fileStream:FileStream = new FileStream();
			
			fileStream.open(file, FileMode.READ);
			fileStream.readBytes(inputBytes, 0, inputBytes.bytesAvailable);
			fileStream.close();
			
			inputBytes.uncompress(CompressionAlgorithm.ZLIB);
			return inputBytes.readObject();
		}
		
		protected function save(file:File):void {
			var outputBytes:ByteArray = new ByteArray();
			outputBytes.writeObject(count);
			outputBytes.compress(CompressionAlgorithm.ZLIB);
			
			//trace("saving count:", count, file.nativePath);
			
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeBytes(outputBytes, 0, outputBytes.bytesAvailable);
			fileStream.close();
		}
		
	}
}
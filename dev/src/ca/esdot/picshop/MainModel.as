package ca.esdot.picshop
{
	import flash.desktop.NativeApplication;
	import flash.display.BitmapData;
	import flash.display.StageQuality;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.media.CameraUI;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.commands.events.SettingsEvent;
	import ca.esdot.picshop.data.FacebookAlbumData;
	import ca.esdot.picshop.data.FacebookPhotoData;
	import ca.esdot.picshop.data.ScratchData;
	import ca.esdot.picshop.data.SettingsData;
	import ca.esdot.picshop.data.UnlockableFeatures;
	import ca.esdot.picshop.editors.AbstractEditor;
	import ca.esdot.picshop.events.ModelEvent;
	
	import org.robotlegs.mvcs.Actor;

	public class MainModel extends Actor
	{
		private static var _trialMode:Boolean = false;
		
		public static var instance:MainModel;
		
		public var settings:SettingsData;
		public function get maxSourceSize():int {
			var width:int = Math.max(MainView.instance.viewHeight, MainView.instance.viewWidth);
			/*if(DeviceUtils.onIOS) {
				if(width > 2000){
					return 2800;
				} else if(width == 1024){
					return CameraUI.isSupported? 2400 : 1000;
				}
			} 
			else {
				if(width > 1500){
					return 2400;
				}
			}*/
			if(DeviceUtils.onIOS && DeviceUtils.isTablet && !CameraUI.isSupported){
				return 1024;
			} else if (width < 900) {
				return 1024;
			}
			return 2048;
		}
		
		protected var maxHistoryCount:uint = 5;
		
		public var isPreviewEnabled:Boolean = true;
		
		protected var _sourceImage:BitmapData;
		protected var _currentView:String;
		
		protected var viewHistory:Array;
		protected var _historyList:Array;
		protected var _historyIndex:int = -1;
		public var currentEditor:AbstractEditor;
		
		public var applyCount:int = 0;
		public var isFirstInstall:Boolean;
		
		public var facebookAlbums:Vector.<FacebookAlbumData>;
		public var facebookPhotos:Vector.<FacebookPhotoData>;
		public var enableAppGratis:Boolean = false;
		
		public static var saveDir:File = File.documentsDirectory.resolvePath("PicShop");
		public var scratchFile:File;
		
		public function MainModel() {
			viewHistory = [];
			historyList = [];
			_historyIndex = -1;
			
			scratchFile = saveDir.resolvePath("scratch.dat");
			
			//Ipad 1
			if(DeviceUtils.onIOS && !CameraUI.isSupported){
				maxHistoryCount = 3;
			}
			instance = this;
		}
		
		public function isFeatureLocked(feature:String):Boolean {
			if(!isAppLocked){ return false; }//All features unlocked from old versions?
			return settings.unlockedFeatures[feature] != true;
		}
		
		public function unlockFeature(feature:String):void {
			
			settings.unlockedFeatures[feature] = true;
			dispatch(new SettingsEvent(SettingsEvent.SAVE));
			if(feature == UnlockableFeatures.FILTERS){
				dispatch(new ModelEvent(ModelEvent.FILTERS_UNLOCKED));
			}
			else if(feature == UnlockableFeatures.FRAMES){
				dispatch(new ModelEvent(ModelEvent.FRAMES_UNLOCKED));
			}
			else if(feature == UnlockableFeatures.EXTRAS){
				dispatch(new ModelEvent(ModelEvent.EXTRAS_UNLOCKED));
			}
			checkAllFeaturesUnlocked();
		}
		
		public function checkAllFeaturesUnlocked():void {
			if(
				//settings.unlockedFeatures[UnlockableFeatures.FILTERS] && 
				settings.unlockedFeatures[UnlockableFeatures.EXTRAS] && 
				settings.unlockedFeatures[UnlockableFeatures.FRAMES]){
				isAppLocked = false;
			}
		}
		
		public function unlockAllFeatures():void {
			unlockFeature(UnlockableFeatures.EXTRAS);
			unlockFeature(UnlockableFeatures.FRAMES);
			//unlockFeature(UnlockableFeatures.FILTERS);
			isAppLocked = false;
		}
		
		public function get isAppLocked():Boolean { 
			return (PicShop.FULL_VERSION)? false : settings.isAppLocked; 
		}
		public function set isAppLocked(value:Boolean):void {
			settings.isAppLocked = value;
			if(!value){
				dispatch(new ModelEvent(ModelEvent.APP_UNLOCKED));
			}
			dispatch(new SettingsEvent(SettingsEvent.SAVE));
		}
		
		public function get versionNumber():String {
			var descriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = descriptor.namespaceDeclarations()[0];
			return descriptor.ns::versionNumber;
		}

		public function get historyList():Array { return _historyList; }
		public function set historyList(value:Array):void {
			_historyList = value;
		}

		public function get historyIndex():int { return _historyIndex; }
		public function set historyIndex(value:int):void {
			_historyIndex = value;
			trace("[MainModel] historyIndex: ", value);
			dispatch(new ModelEvent(ModelEvent.HISTORY_INDEX_CHANGED));	
		}

		public function get sourceData():BitmapData {
			return _sourceImage;
		}

		public function set sourceData(value:BitmapData):void {
			if(!value){
				_sourceImage  = null;
			} else {
				var scale:Number = Math.min(1, Math.min(maxSourceSize/value.width, maxSourceSize/value.height));
				var matrix:Matrix = new Matrix();
				matrix.scale(scale, scale);
				
				var sizedBitmapData:BitmapData = new BitmapData(value.width * scale, value.height * scale, true, 0x0);
				if(RENDER::GPU) {
					sizedBitmapData.drawWithQuality(value, matrix, null, null, null, true, StageQuality.HIGH);
				} else {
					sizedBitmapData.draw(value, matrix, null, null, null, true);		
				}
				trace("[MainModel] Source Changed. Size: ", sizedBitmapData.width, sizedBitmapData.height);
				
				_sourceImage  = sizedBitmapData;
			}
			dispatch(new ModelEvent(ModelEvent.SOURCE_CHANGED));
		}

		public function get currentView():String {
			return _currentView;
		}
		
		public function set currentView(value:String):void {
			if(_currentView){
				viewHistory.push(_currentView);
			}
			_currentView = value;
			dispatch(new ModelEvent(ModelEvent.VIEW_CHANGED));
		}
		
		public function addHistory(data:BitmapData):void {
			if(historyList.length - 1 > _historyIndex){
				historyList.splice(_historyIndex + 1, historyList.length - 1 - _historyIndex);
				historyIndex = _historyIndex;
			}
			historyList.push(data);
			historyIndex++;
			if(historyList.length > maxHistoryCount){
				historyList.splice(1, 1);
			}
		}
		
		public function historyNext():void {
			if(historyIndex < 0){ historyIndex = 0; }
			sourceData = historyList[historyIndex + 1];
			historyIndex++;
			updateScratchFile();
		}
		
		public function historyBack():void {
			if(historyIndex > historyList.length - 1){
				historyIndex = historyList.length - 1;
			}
			sourceData = historyList[historyIndex - 1];
			historyIndex--;
			updateScratchFile();
		}
		
		public function clearHistory():void {
			historyIndex = -1;
			historyList = [];
		}
		
		
		public function back():void {
			if(viewHistory.length > 0){
				_currentView = viewHistory.pop();
				dispatch(new ModelEvent(ModelEvent.BACK));
			}
		}
		
		public function incrementImageSaved():void {
			settings.numOpenImage++;
		}
		
		public function incrementImageOpened():void {
			
		}
		
		public function loadScratchFile():BitmapData {
			if(!scratchFile.exists){ return null; }
			
			registerClassAlias("scratch", ScratchData);
			
			var fs:FileStream = new FileStream();
			fs.open(scratchFile, FileMode.READ);
			var scratchData:ScratchData = fs.readObject();
			fs.close();
			
			if(!scratchData){ return null; }
			
			var newBitmapData:BitmapData = new BitmapData(scratchData.width, scratchData.height);
			newBitmapData.setPixels(newBitmapData.rect, scratchData.bytes);		
			return newBitmapData;
		}
		
		public function updateScratchFile():void {
			
			registerClassAlias("scratch", ScratchData);
			
			var t:Number = getTimer();
			var scratchData:ScratchData = new ScratchData(sourceData.width, sourceData.height, sourceData.getPixels(sourceData.rect));
			
			var fs:FileStream = new FileStream();
			fs.open(scratchFile, FileMode.WRITE);
			fs.writeObject(scratchData);
			fs.close();
			
			trace("Write Complete: " + (getTimer() - t));
		}
		
		public function deleteScratchFile():void {
			if(scratchFile && scratchFile.exists){
				scratchFile.deleteFileAsync();
			}
		}
		
		public function get numCoins():int { return settings.numCoins; }
		public function set numCoins(value:int):void {
			
			var prevValue:int = settings.numCoins;
			settings.numCoins = value;
			
			if(value > prevValue){
				dispatch(new ModelEvent(ModelEvent.COINS_ADDED));
			} else if(value < prevValue){
				dispatch(new ModelEvent(ModelEvent.COINS_REMOVED));
			}
			dispatch(new SettingsEvent(SettingsEvent.SAVE));
		}
		
		
	}
}
package ca.esdot.picshop.services
{
	import com.facebook.graph.FacebookMobile;
	
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	
	import by.blooddy.crypto.image.JPEGEncoder;
	
	import ca.esdot.lib.net.URLImageLoader;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.data.FacebookAlbumData;
	import ca.esdot.picshop.data.FacebookPhotoData;
	import ca.esdot.picshop.events.FacebookServiceEvent;
	
	import org.robotlegs.mvcs.Actor;
	
	public class FacebookAS3Service extends Actor implements IFacebookService
	{
		
		[Inject]
		public var mainModel:MainModel;
		
		public var viewPort:Rectangle;
		protected var hiResPhotoLoader:URLImageLoader;
		
		protected var authError:Boolean;
		protected var token:String;

		private var webView:StageWebView;
		private var tmpFile:File;
		
		public function init(appId:String):void{
			FacebookMobile.init(appId, onInitComplete);
		}
		
		protected function onInitComplete(result:Object, error:Object):void {
			if(error){
				authError = true;
			} else {
				token = FacebookMobile.getSession().accessToken;
			}
		}

		public function authenticate(permissions:String = "public_profile"):void{
			var stage:Stage = PicShop.stage;
			webView = new StageWebView();
			webView.viewPort = (viewPort)? viewPort : new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			webView.stage = stage;
			FacebookMobile.login(onLoginComplete, stage, permissions.split(","), webView);
		}
		
		protected function onLoginComplete(result:Object, error:Object):void {
			if(result && !error){
				authError = false;
				token = FacebookMobile.getSession().accessToken;
				dispatch(new FacebookServiceEvent(FacebookServiceEvent.LOGIN_COMPLETE));
			} else {
				dispatch(new FacebookServiceEvent(FacebookServiceEvent.LOGIN_CANCELED));
				//dispatch(new FacebookServiceEvent(FacebookServiceEvent.LOGIN_FAILED));
			}
		}
		
		public function cleanup():void {
			try {
				webView.viewPort = null;
				webView.stage = null;
				webView.dispose();
			} catch(e:Error){
				trace(e.getStackTrace());
			}
		}
		
		protected function onAlbumsLoaded(result:*, error:*):void {
			if(!result || error){ 
				dispatch(new FacebookServiceEvent(FacebookServiceEvent.ALBUMS_FAILED));
			} else {
				
				var albums:Vector.<FacebookAlbumData> = new <FacebookAlbumData>[];
				var request:Object = FacebookMobile.getRawResult(result);
				var data:Array = request.data;
				var token:String = FacebookMobile.getSession().accessToken;
				
				for(var i:int = 0, l:int = data.length; i < l; i++){
					if(!data[i].cover_photo){ continue; }
					var url:String = "https://graph.facebook.com/"+data[i].cover_photo+"/picture?type=normal&access_token="+token;
					var a:FacebookAlbumData = new FacebookAlbumData(url, data[i].name, data[i].id);
					albums.push(a);
				}
				mainModel.facebookAlbums = albums;
				dispatch(new FacebookServiceEvent(FacebookServiceEvent.ALBUMS_LOADED, albums));
				
			}
		}
		
		protected function onPhotosLoaded(result:*, error:*):void {
			if(!result || error){ 
				dispatch(new FacebookServiceEvent(FacebookServiceEvent.PHOTOS_FAILED));
			} else {
				
				var photos:Vector.<FacebookPhotoData> = new <FacebookPhotoData>[];
				var request:Object = FacebookMobile.getRawResult(result);
				var data:Array = request.data;
				
				for(var i:int = 0, l:int = data.length; i < l; i++){
					if(!data[i].id){ continue; }
					var url:String = "https://graph.facebook.com/"+data[i].id+"/picture?type=normal&access_token="+token;
					var a:FacebookPhotoData = new FacebookPhotoData(url, data[i].id);
					photos.push(a);
				}
				mainModel.facebookPhotos = photos;
				dispatch(new FacebookServiceEvent(FacebookServiceEvent.PHOTOS_LOADED, photos));
				
			}
		}
		
		public function callGraph(graphPath:String, httpMethod:String, params:Object):void{
			//FacebookMobile.api(graphPath, onAlbumsLoaded, params, httpMethod);
		}
		
		public function loadHiResPhoto(photoId:String):void {
			FacebookMobile.api(photoId, onHiResFieldsLoaded, {fields: "images"});
		}
		
		protected function onHiResFieldsLoaded(result:*, error: *):void {
			if(!result || error){
				dispatch(new FacebookServiceEvent(FacebookServiceEvent.HI_RES_PHOTO_FAILED));
			} else {
				var url:String;
				var maxIndex:int = 0, max:int = 0;
				for(var i:int = 0, l:int = result.images.length; i < l; i++){
					if(result.images[i].height > max){ 
						max = result.images[i].height;
						maxIndex = i; 
					}
				}
				if(max > 0){
					url = result.images[maxIndex].source;
					hiResPhotoLoader = new URLImageLoader();
					hiResPhotoLoader.addEventListener(IOErrorEvent.IO_ERROR, onHiResPhotoFailed);
					hiResPhotoLoader.addEventListener(Event.COMPLETE, onHiResPhotoLoaded);
					hiResPhotoLoader.loadImage(url);
				} else {
					dispatch(new FacebookServiceEvent(FacebookServiceEvent.HI_RES_PHOTO_FAILED));
				}
			}
		}
		
		protected function onHiResPhotoLoaded(event:Event):void {
			dispatch(new FacebookServiceEvent(FacebookServiceEvent.HI_RES_PHOTO_LOADED, hiResPhotoLoader.bmpImage.bitmapData));
		}
		
		protected function onHiResPhotoFailed(event:IOErrorEvent):void {
			dispatch(new FacebookServiceEvent(FacebookServiceEvent.HI_RES_PHOTO_FAILED));
		}
		
		public function isAuthenticated():Boolean{
			return !authError && FacebookMobile.getSession() != null;
		}
		
		public function loadAlbums():void{
			FacebookMobile.api("me/albums", onAlbumsLoaded, {limit: 64, fields: "id, name, cover_photo"});
		}
		
		public function loadPhotos(albumId:String):void{
			FacebookMobile.api(albumId + "/photos", onPhotosLoaded);
		}
		
		public function postPhoto(comment:String, bitmapData:BitmapData):void{
			
			
			FacebookMobile.requestExtendedPermissions(function(success:*, error:*){
				var bytes:ByteArray = JPEGEncoder.encode(bitmapData, 90);
				tmpFile = File.applicationStorageDirectory.resolvePath("tmp.jpg");
				if(tmpFile.exists){ tmpFile.deleteFile(); }
				
				var stream:FileStream = new FileStream();
				stream.open(tmpFile, FileMode.WRITE);
				stream.writeBytes(bytes, 0, bytes.bytesAvailable);
				stream.close();
				
				
				var _params:Object = new Object();
				_params.access_token = FacebookMobile.getSession().accessToken;
				_params.message = comment;
				_params.image = bitmapData;
				_params.fileName = tmpFile.url;
				_params.source = tmpFile.url;
				
				
				FacebookMobile.api("me/photos", onPostPhotoComplete, _params, URLRequestMethod.POST);
			}, webView, ["publish_stream"]);
			//goViral.facebookPostPhoto(comment, imageData);
		}
		
		protected function onPostPhotoComplete(result:*, error:*):void {
			if(tmpFile && tmpFile.exists){ 
				tmpFile.deleteFile(); 
			}
			if(result && !error){
				dispatch(new FacebookServiceEvent(FacebookServiceEvent.POST_PHOTO_COMPLETE));
			} else {
				dispatch(new FacebookServiceEvent(FacebookServiceEvent.POST_PHOTO_FAILED));
			}
		}
	}
}
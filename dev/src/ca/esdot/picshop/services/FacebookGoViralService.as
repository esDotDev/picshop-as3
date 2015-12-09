package ca.esdot.picshop.services
{
	import ca.esdot.lib.net.URLImageLoader;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.data.FacebookAlbumData;
	import ca.esdot.picshop.data.FacebookPhotoData;
	import ca.esdot.picshop.events.FacebookServiceEvent;
	
	import com.facebook.graph.Facebook;
	import com.milkmangames.nativeextensions.GoViral;
	import com.milkmangames.nativeextensions.events.GVFacebookEvent;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import org.robotlegs.mvcs.Actor;
	
	public class FacebookGoViralService extends Actor implements IFacebookService
	{
		protected var goViral:GoViral;
		
		[Inject]
		public var mainModel:MainModel;
		private var hiResPhotoLoader:URLImageLoader;
		private var hiResPhotoPath:String;
		
		public function init(appId:String):void{
			//GoViral.create();
			goViral = GoViral.goViral;	
			
			goViral.addEventListener(GVFacebookEvent.FB_LOGGED_IN, onLoginEvent, false, 0, true);
			goViral.addEventListener(GVFacebookEvent.FB_LOGIN_CANCELED, onLoginEvent, false, 0, true);
			goViral.addEventListener(GVFacebookEvent.FB_LOGIN_FAILED, onLoginEvent, false, 0, true);
			goViral.addEventListener(GVFacebookEvent.FB_REQUEST_FAILED,onRequestComplete, false, 0, true);
			goViral.addEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE,onRequestComplete, false, 0, true);
			
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_CANCELED,onFacebookEvent);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_FAILED,onFacebookEvent);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_FINISHED,onFacebookEvent);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGGED_IN,onFacebookEvent);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGGED_OUT,onFacebookEvent);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGIN_CANCELED,onFacebookEvent);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGIN_FAILED,onFacebookEvent);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_REQUEST_FAILED,onFacebookEvent);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE,onFacebookEvent);
			
			goViral.initFacebook(appId, "");
		}
		
		protected function onFacebookEvent(event:GVFacebookEvent):void {
			 trace(event);
		}
		
		public function authenticate(permissions:String = "public_profile"):void{
			
			goViral.authenticateWithFacebook(permissions);
			
		}
		
		protected function onRequestComplete(event:GVFacebookEvent):void {
			if(event.graphPath == hiResPhotoPath){
				if(!event.data|| event.errorCode){
					dispatch(new FacebookServiceEvent(FacebookServiceEvent.HI_RES_PHOTO_FAILED));
				} else {
					var url:String;
					var maxIndex:int = 0, max:int = 0;
					for(var i:int = 0, l:int = event.data.images.length; i < l; i++){
						if(event.data.images[i].height > max){ 
							max = event.data.images[i].height;
							maxIndex = i; 
						}
					}
					if(max > 0){
						url = event.data.images[maxIndex].source;
						hiResPhotoLoader = new URLImageLoader();
						hiResPhotoLoader.addEventListener(IOErrorEvent.IO_ERROR, onHiResPhotoFailed);
						hiResPhotoLoader.addEventListener(Event.COMPLETE, onHiResPhotoLoaded);
						hiResPhotoLoader.loadImage(url);
					} else {
						dispatch(new FacebookServiceEvent(FacebookServiceEvent.HI_RES_PHOTO_FAILED));
					}
				}
			}
			else if(event.graphPath == "me/photos"){
				if(event.data.error || event.errorMessage){ 
					dispatch(new FacebookServiceEvent(FacebookServiceEvent.POST_PHOTO_FAILED));
				} else {
					dispatch(new FacebookServiceEvent(FacebookServiceEvent.POST_PHOTO_COMPLETE));
				}
			}
			else if(event.graphPath == "me/albums"){
				if(event.data.error || !event.data.data || event.errorMessage){ 
					dispatch(new FacebookServiceEvent(FacebookServiceEvent.ALBUMS_FAILED));
				} else {
					
					var albums:Vector.<FacebookAlbumData> = new <FacebookAlbumData>[];
					var data:Array = event.data.data;
					var token:String = goViral.getFbAccessToken();
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
			
			else if(event.graphPath.indexOf("/photos") != -1){
				
				if(event.data.error || !event.data.data || event.errorMessage){ 
					dispatch(new FacebookServiceEvent(FacebookServiceEvent.ALBUMS_FAILED));
				} else {
					
					var photos:Vector.<FacebookPhotoData> = new <FacebookPhotoData>[];
					var data:Array = event.data.data;
					var token:String = goViral.getFbAccessToken();
					
					for(var i:int = 0, l:int = data.length; i < l; i++){
						if(!data[i].id){ continue; }
						var url:String = "https://graph.facebook.com/"+data[i].id+"/picture?type=normal&access_token="+token;
						var p:FacebookPhotoData = new FacebookPhotoData(url, data[i].id);
						photos.push(p);
					}
					mainModel.facebookPhotos = photos;
					dispatch(new FacebookServiceEvent(FacebookServiceEvent.PHOTOS_LOADED, photos));
					
				}
				
			}
		}
		
		public function cleanup():void {
		}
		
		protected function onLoginEvent(event:GVFacebookEvent):void {
			switch(event.type){
				
				case GVFacebookEvent.FB_LOGGED_IN:
					dispatch(new FacebookServiceEvent(FacebookServiceEvent.LOGIN_COMPLETE));
					break;
				
				case GVFacebookEvent.FB_LOGIN_CANCELED:
					dispatch(new FacebookServiceEvent(FacebookServiceEvent.LOGIN_CANCELED));
					break;
				
				case GVFacebookEvent.FB_LOGIN_FAILED:
					dispatch(new FacebookServiceEvent(FacebookServiceEvent.LOGIN_FAILED));
					break;
			}
		}
		
		public function callGraph(graphPath:String, httpMethod:String, params:Object):void{
			goViral.facebookGraphRequest(graphPath, httpMethod, params);
		}
		
		public function loadHiResPhoto(photoId:String):void {
			hiResPhotoPath = photoId;
			goViral.facebookGraphRequest(photoId, "GET", {fields: "images"});
		}
		
		protected function onHiResPhotoLoaded(event:Event):void {
			dispatch(new FacebookServiceEvent(FacebookServiceEvent.HI_RES_PHOTO_LOADED, hiResPhotoLoader.bmpImage.bitmapData));
		}
		
		protected function onHiResPhotoFailed(event:IOErrorEvent):void {
			dispatch(new FacebookServiceEvent(FacebookServiceEvent.HI_RES_PHOTO_FAILED));
		}
		
		public function isAuthenticated():Boolean{
			return goViral.isFacebookAuthenticated();
		}
		
		public function loadAlbums():void{
			goViral.facebookGraphRequest("me/albums", "GET", {limit: 64, fields: "id, name, cover_photo"});
		}
		
		public function loadPhotos(albumId:String):void{
			goViral.facebookGraphRequest(albumId + "/photos");
		}
		
		public function postPhoto(comment:String, imageData:BitmapData):void{
			goViral.facebookPostPhoto(comment, imageData);
		}
		
	}
}
package ca.esdot.picshop.views
{
	import com.facebook.graph.Facebook;
	import com.milkmangames.nativeextensions.GoViral;
	import com.milkmangames.nativeextensions.events.GVFacebookEvent;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.commands.events.OpenImageEvent;
	import ca.esdot.picshop.data.FacebookAlbumData;
	import ca.esdot.picshop.data.FacebookPhotoData;
	import ca.esdot.picshop.events.FacebookServiceEvent;
	import ca.esdot.picshop.services.FacebookAS3Service;
	import ca.esdot.picshop.services.FacebookGoViralService;
	import ca.esdot.picshop.services.IFacebookService;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class FacebookBrowserMediator extends Mediator
	{
		[Inject]
		public var view:FacebookBrowser;
		
		[Inject] 
		public var service:IFacebookService;
		
		[Inject] 
		public var mainModel:MainModel;
		
		override public function onRegister():void {
			
			addContextListener(FacebookServiceEvent.ALBUMS_LOADED, onAlbumsLoaded, FacebookServiceEvent);
			addContextListener(FacebookServiceEvent.ALBUMS_FAILED, onFail, FacebookServiceEvent);
			addContextListener(FacebookServiceEvent.PHOTOS_LOADED, onPhotosLoaded, FacebookServiceEvent);
			addContextListener(FacebookServiceEvent.PHOTOS_FAILED, onFail, FacebookServiceEvent);
			addContextListener(FacebookServiceEvent.HI_RES_PHOTO_LOADED, onHiResPhotoLoaded, FacebookServiceEvent);
			//addContextListener(FacebookServiceEvent.LOGIN_COMPLETE, onLoginComplete, FacebookServiceEvent);
			
			view.isLoading = true;
			view.albumClicked.add(onAlbumClicked);
			view.photoClicked.add(onPhotoClicked);

			
			
		}
		
		override public function onRemove():void {
			service.cleanup();
		}
		
		protected function onHiResPhotoLoaded(event:FacebookServiceEvent):void {
			var bmpData:BitmapData = event.data as BitmapData;
			dispatch(new OpenImageEvent(OpenImageEvent.BITMAP_DATA, bmpData));
			view.remove();
		}
		
		protected function onAlbumClicked(id:String):void {
			service.loadPhotos(id);
		}
		
		protected function onPhotoClicked(id:String):void {
			service.loadHiResPhoto(id);
		}
		
		protected function onAlbumsLoaded(event:FacebookServiceEvent):void {
			view.setAlbumData(event.data as Vector.<FacebookAlbumData>);
			view.isLoading = false;
		}
		
		protected function onPhotosLoaded(event:FacebookServiceEvent):void {
			view.setPhotoData(event.data as Vector.<FacebookPhotoData>);
			view.isLoading = false;
		}
		
		protected function onLoginComplete(event:Event):void {
			service.loadAlbums();
		}
		
		
		protected function onLoginCancelled(event:Event):void {
			view.remove();
		}
		
		
		protected function onLoginFailed(event:Event):void {
			view.remove();
			DialogManager.alert("Error: " + event.type, "The Facebook login failed. Make sure your internet connection is good, or try again later.");
		}
		
		protected function onFail(event:Event):void {
			view.remove();
			DialogManager.alert("Woops...", "PicShop encountered en error while trying to access your Facebook Images. ");
		}
		
	}
}
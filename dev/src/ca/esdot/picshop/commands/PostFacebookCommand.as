package ca.esdot.picshop.commands
{
	import com.facebook.graph.Facebook;
	
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.events.ShareEvent;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.events.FacebookServiceEvent;
	import ca.esdot.picshop.services.IFacebookService;
	import ca.esdot.picshop.utils.AnalyticsManager;
	
	import org.robotlegs.mvcs.Command;
	
	public class PostFacebookCommand extends Command
	{
		[Inject]
		public var event:ShareEvent;
		
		[Inject]
		public var facebook:IFacebookService;
		
		override public function execute():void {
			
			(contextView as MainView).isLoading = true;
			
			commandMap.detain(this);
			if(facebook.isAuthenticated() == false){
				eventDispatcher.addEventListener(FacebookServiceEvent.LOGIN_CANCELED, onLoginFailed, false, 0, true);
				eventDispatcher.addEventListener(FacebookServiceEvent.LOGIN_COMPLETE, onLoginComplete, false, 0, true);
				eventDispatcher.addEventListener(FacebookServiceEvent.LOGIN_FAILED, onLoginFailed, false, 0, true);
				facebook.authenticate();
			} else {
				setTimeout(post, 500);
			}
			
		}
		
		protected function post():void {
			eventDispatcher.addEventListener(FacebookServiceEvent.POST_PHOTO_COMPLETE, onPostComplete, false, 0, true);
			eventDispatcher.addEventListener(FacebookServiceEvent.POST_PHOTO_FAILED, onPostFailed, false, 0, true);
			facebook.postPhoto(event.message, event.bitmapData);
			
		}
		
		protected function onLoginComplete(event:FacebookServiceEvent):void {
			post();
		}
		
		protected function onPostFailed(event:FacebookServiceEvent):void {
			destroyCommand();
			DialogManager.alert("Error", "Something went wrong when trying to upload the Photo.");
		}
		
		protected function onLoginFailed(event:FacebookServiceEvent):void {
			destroyCommand();
		}
		
		protected function onPostComplete(event:Event):void{
			
			AnalyticsManager.pageView("/share-facebook");
			AnalyticsManager.imageShared();
			
			destroyCommand();
			
			DialogManager.alert("Share Complete!", "Your picture has been uploaded to Facebook. Thanks for using PicShop!");
			
		}
		
		
		protected function destroyCommand(event:Event = null):void {
			eventDispatcher.removeEventListener(FacebookServiceEvent.POST_PHOTO_COMPLETE, onPostComplete);
			eventDispatcher.removeEventListener(FacebookServiceEvent.POST_PHOTO_FAILED, onPostFailed);
			
			eventDispatcher.removeEventListener(FacebookServiceEvent.LOGIN_CANCELED, onLoginFailed);
			eventDispatcher.removeEventListener(FacebookServiceEvent.LOGIN_COMPLETE, onLoginComplete);
			eventDispatcher.removeEventListener(FacebookServiceEvent.LOGIN_FAILED, onLoginFailed);
			
			(contextView as MainView).isLoading = false;
			commandMap.release(this);
		}
	}
}
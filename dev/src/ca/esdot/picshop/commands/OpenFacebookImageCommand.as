package ca.esdot.picshop.commands
{
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.commands.events.CommandEvent;
	import ca.esdot.picshop.commands.events.OpenImageEvent;
	import ca.esdot.picshop.events.FacebookServiceEvent;
	import ca.esdot.picshop.services.FacebookAS3Service;
	import ca.esdot.picshop.services.FacebookGoViralService;
	import ca.esdot.picshop.services.IFacebookService;
	import ca.esdot.picshop.views.FacebookBrowser;
	
	import com.milkmangames.nativeextensions.GoViral;
	import com.milkmangames.nativeextensions.events.GVFacebookEvent;
	
	import flash.geom.Rectangle;
	
	import org.robotlegs.mvcs.Command;
	
	public class OpenFacebookImageCommand extends Command
	{
		[Inject]
		public var event:OpenImageEvent;
		
		[Inject] 
		public var service:IFacebookService;
		
		protected var mainView:MainView;
		
		override public function execute():void {
			
			//Show View 
			mainView = contextView as MainView;
			var browser:FacebookBrowser = mainView.showFacebookBrowser();
			if(service is FacebookAS3Service){
				(service as FacebookAS3Service).viewPort = browser.viewPort
			}
			
			//Check authentication
			if(!service.isAuthenticated()){
				commandMap.detain(this);
				eventDispatcher.addEventListener(FacebookServiceEvent.LOGIN_COMPLETE, onFacebookEvent, false, 0, true);
				eventDispatcher.addEventListener(FacebookServiceEvent.LOGIN_CANCELED, onFacebookEvent, false, 0, true);
				eventDispatcher.addEventListener(FacebookServiceEvent.LOGIN_FAILED, onFacebookEvent, false, 0, true);
				
				service.authenticate("user_photos");
			} else {
				//Load Albums
				service.loadAlbums();
			}
		}
		
		protected function onFacebookEvent(event:FacebookServiceEvent):void {
			
			if(event.type == FacebookServiceEvent.LOGIN_COMPLETE){
				service.loadAlbums();
			}
			commandMap.release(this);
		}
	}
}
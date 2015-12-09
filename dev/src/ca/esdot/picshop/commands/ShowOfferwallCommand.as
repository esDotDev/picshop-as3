package ca.esdot.picshop.commands
{
	import flash.utils.setTimeout;
	
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.services.SupersonicService;
	
	import org.robotlegs.mvcs.Command;
	
	public class ShowOfferwallCommand extends Command
	{
		[Inject]
		public var supersonic:SupersonicService;
		[Inject]
		public var mainModel:MainModel;
		
		override public function execute():void {
			commandMap.detain(this);
			if(SupersonicService.isSupported){
				supersonic.offerwallFailed.add(OnError);
				supersonic.offerwallClosed.add(OnOfferwallClosed);
				supersonic.showOfferwall();
			} else {
				OnError();
			}
			trace("[ShowOfferwallCommand] Show Offerwall");
		}
		
		private function OnOfferwallClosed():void {
			releaseCommand();
		}
		
		private function OnError():void {
			DialogManager.alert("Woops...", "Looks like you're unable to earn coins at the moment. Please make sure you're connected to the internet and try again in a few minutes.");
			releaseCommand();
		}
		
		private function releaseCommand():void {
			commandMap.release(this);
		}
		
	}
}
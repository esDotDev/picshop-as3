package ca.esdot.picshop.commands
{
	import ca.esdot.lib.events.ViewEvent;
	import ca.esdot.lib.utils.TextFields;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.commands.events.ChangeViewEvent;
	
	import flash.system.System;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	
	import org.robotlegs.mvcs.Command;
	
	public class ChangeViewCommand extends Command
	{
		[Inject]
		public var event:ChangeViewEvent;
		
		[Inject]
		public var mainModel:MainModel;
		
		public var mainView:MainView;
		
		override public function execute():void {
			mainView = contextView as MainView;
			if(event.type == ChangeViewEvent.BACK){
				mainView.back();
				mainModel.back();
			} else {
				mainModel.currentView = event.viewType;
			}
		}
	}
}
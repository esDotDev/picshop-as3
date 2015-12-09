package ca.esdot.picshop.commands
{
	import flash.display.Stage;
	
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.commands.events.CommandEvent;
	import ca.esdot.picshop.dialogs.VersionDialog;
	import ca.esdot.picshop.editors.BlemishEditor;
	import ca.esdot.picshop.editors.TeethWhiteningEditor;
	
	import org.robotlegs.mvcs.Command;

	public class ResizeAppCommand extends Command
	{
		[Inject]
		public var mainModel:MainModel;
		
		override public function execute():void {
			var mainView:MainView = contextView as MainView;
			var stage:Stage = mainView.stage;
			
			//Size main view
			mainView.setSize(stage.stageWidth, stage.stageHeight);
			
			//Version Dialog?
			if(DialogManager.currentDialog is VersionDialog){
				dispatch(new CommandEvent(CommandEvent.SHOW_VERSION_DIALOG));
			} else {
				DialogManager.removeDialogs();
			}
			
		}
	}
}
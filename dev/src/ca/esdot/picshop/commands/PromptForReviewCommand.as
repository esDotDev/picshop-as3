package ca.esdot.picshop.commands
{
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.commands.events.CommandEvent;
	import ca.esdot.picshop.commands.events.SettingsEvent;
	import ca.esdot.picshop.data.Strings;
	import ca.esdot.picshop.dialogs.TitleDialog;
	
	import org.robotlegs.mvcs.Command;

	public class PromptForReviewCommand extends Command
	{
		[Inject]
		public var mainModel:MainModel;
		
		override public function execute():void {
			if(mainModel.settings.numSaves % 3 == 0 
				&& mainModel.settings.numSaves < 10 
				&& !mainModel.settings.reviewAccepted){
				
				commandMap.detain(this);
				var dialog:TitleDialog = new TitleDialog(DeviceUtils.dialogWidth * .75, DeviceUtils.dialogHeight * .75, "Enjoying the app?", "Would you like to rate us 5 stars?");
				dialog.setButtons([Strings.CANCEL, Strings.OK]);
				dialog.addEventListener(ButtonEvent.CLICKED, onReviewDialogClicked, false, 0, true);
				DialogManager.addDialog(dialog, true);
			}
		}
		
		protected function onReviewDialogClicked(event:ButtonEvent):void {
			if(event.label == Strings.OK){
				dispatch(new CommandEvent(CommandEvent.OPEN_REVIEW_LINK));
				mainModel.settings.reviewAccepted = true;
				dispatch(new SettingsEvent(SettingsEvent.SAVE));
			}
			DialogManager.removeDialogs();
			
			commandMap.release(this);
		}
	}
}
package ca.esdot.picshop.commands
{
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.commands.events.CommandEvent;
	import ca.esdot.picshop.data.Strings;
	import ca.esdot.picshop.dialogs.UpgradeDialog;
	
	import org.robotlegs.mvcs.Command;
	
	public class UpgradeDialogCommand extends Command
	{
		override public function execute():void {
			commandMap.detain(this);
			
			var dialog:UpgradeDialog = new UpgradeDialog();
			dialog.addEventListener(ButtonEvent.CLICKED, onDialogClicked, false, 0, true);
			DialogManager.addDialog(dialog, true);
		}
		
		protected function onDialogClicked(event:ButtonEvent):void {
			DialogManager.removeDialogs();
			commandMap.release(this);
			
			if(event.label == Strings.UPGRADE){
				if(DeviceUtils.onAndroid || DeviceUtils.onIOS || DeviceUtils.onBB10){
					dispatch(new CommandEvent(CommandEvent.IN_APP_PURCHASE));
				} else {
					dispatch(new CommandEvent(CommandEvent.OPEN_PURCHASE_LINK));
				}
			} else if(event.label == Strings.RESTORE){
				dispatch(new CommandEvent(CommandEvent.IN_APP_RESTORE));
			}
		}
	}
}
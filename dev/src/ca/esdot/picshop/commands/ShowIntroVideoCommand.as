package ca.esdot.picshop.commands
{
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.commands.events.ShowTipEvent;
	import ca.esdot.picshop.dialogs.VideoDialog;
	
	import flash.media.Video;
	
	import org.robotlegs.mvcs.Command;
	
	public class ShowIntroVideoCommand extends Command
	{
		[Inject]
		public var mainModel:MainModel;
		
		override public function execute():void {
			commandMap.detain(this);
			
			var videoDialog:VideoDialog = new VideoDialog();
			videoDialog.setSize(contextView.stage.stageWidth * .8, contextView.stage.stageHeight * .8);
			DialogManager.closeCallback = onVideoClosed;
			DialogManager.addDialog(videoDialog);
			
		}
		
		protected function onVideoClosed():void {
			commandMap.release(this);
			if(!mainModel.sourceData){
				dispatch(new ShowTipEvent(ShowTipEvent.OPEN_IMAGE, (contextView as MainView).editView.editMenu.imageButton));
			}
		}
	}
}
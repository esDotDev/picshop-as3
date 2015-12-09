package ca.esdot.picshop.menus
{
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.events.BackEvent;
	import ca.esdot.lib.events.ViewEvent;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.commands.events.CommandEvent;
	import ca.esdot.picshop.data.Strings;
	import ca.esdot.picshop.data.ViewTypes;
	import ca.esdot.picshop.dialogs.TitleDialog;
	import ca.esdot.picshop.events.ModelEvent;
	import ca.esdot.picshop.events.UnlockEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class TopMenuMediator extends Mediator
	{
		[Inject]
		public var view:TopMenu;
		
		[Inject]
		public var mainModel:MainModel;
		
		override public function onRegister():void {
			addContextListener(ModelEvent.HISTORY_INDEX_CHANGED, onHistoryIndexChanged, ModelEvent);
			addContextListener(ModelEvent.VIEW_CHANGED, onViewChanged, ModelEvent);
			addContextListener(ModelEvent.BACK, onViewChanged, ModelEvent);
			addContextListener(ModelEvent.APP_UNLOCKED, onAppUnlocked, ModelEvent);
			
			eventMap.mapListener(view.undoButton, MouseEvent.CLICK, onUndoClicked);
			eventMap.mapListener(view.redoButton, MouseEvent.CLICK, onRedoClicked);
			addContextListener(ModelEvent.SOURCE_CHANGED, onSourceChanged, ModelEvent);
			
			view.closeClicked.add(onCloseClicked);
			
			view.compareDown.add(onCompareDown);
			view.compareUp.add(onCompareUp);
			
			addViewListener(UnlockEvent.UNLOCK, onUnlockClicked, UnlockEvent);
			
			view.isLocked = mainModel.isAppLocked;
			
			//Check whether to show closeButton initially (restore from previous work)
			view.showCloseButton(mainModel.sourceData != null);
		}
		
		protected function onCompareDown():void {
			MainView.click();
			mainModel.sourceData = mainModel.historyList[0];
		}
		
		protected function onCompareUp():void {
			mainModel.sourceData = mainModel.historyList[mainModel.historyIndex];
		}
		
		protected function onCloseClicked():void {
			if(mainModel.currentEditor){ return; }
			var dialog:TitleDialog = new TitleDialog(DeviceUtils.dialogWidth, DeviceUtils.dialogHeight, 
				"Close this image?", "Are you sure you want to close? All changes will be lost.");
			dialog.setButtons([Strings.CANCEL, Strings.OK]);
			dialog.addEventListener(ButtonEvent.CLICKED, onDialogClicked);
			DialogManager.addDialog(dialog);
			
			MainView.click();
		}
		
		protected function onDialogClicked(event:ButtonEvent):void {
			DialogManager.removeDialogs();
			if(event.label == Strings.CANCEL){
				return;
			}
			mainModel.clearHistory();
			mainModel.sourceData = null;
			mainModel.deleteScratchFile();
			
			MainView.instance.editView.editMenu.openImageClicked.dispatch();
		}
		
		private function onSourceChanged(event:ModelEvent):void {
			updateButtons();
			
			view.showCompareButton(mainModel.historyIndex != -1);
			
			if(mainModel.sourceData == null){
				view.isRedoEnabled = false;
				view.isUndoEnabled = false;
			}
		}
		
		protected function updateButtons():void {
			view.showCloseButton(mainModel.sourceData != null);
			view.showCompareButton(mainModel.historyIndex != -1);
		}
		
		protected function onAppUnlocked(event:ModelEvent):void {
			view.isLocked = false;
		}
		
		protected function onUnlockClicked(event:UnlockEvent):void {
			MainView.click();
			dispatch(new UnlockEvent(UnlockEvent.UNLOCK));
		}
		
		protected function onUndoClicked(event:MouseEvent):void {
			MainView.click();
			mainModel.historyBack();
		}
		
		protected function onRedoClicked(event:MouseEvent):void {
			MainView.click();
			mainModel.historyNext();
		}
		
		protected function onViewChanged(event:ModelEvent):void {
			if(mainModel.currentView == ViewTypes.EDIT){
				view.undoButton.visible = view.redoButton.visible = true;
				view.closeButton.visible = view.compareButton.visible = true;
				updateButtons();
			} else {
				view.showCloseButton(false);
				view.closeButton.visible = view.compareButton.visible = false;
				view.undoButton.visible = view.redoButton.visible = false;
			}
			
		}
		
		protected function onHistoryIndexChanged(event:ModelEvent):void {
			view.isRedoEnabled = false;
			view.isUndoEnabled = false;
			view.showCompareButton(false);
			
			if(mainModel.historyIndex < mainModel.historyList.length - 1){
				view.isRedoEnabled = true;
			} 
			if(mainModel.historyIndex > 0){
				view.isUndoEnabled = true;
				view.showCompareButton(true);
			}
			
		}
	}
}
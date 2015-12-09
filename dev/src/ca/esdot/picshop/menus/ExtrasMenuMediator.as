package ca.esdot.picshop.menus
{
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.commands.events.CommandEvent;
	import ca.esdot.picshop.commands.events.ShowStickersEvent;
	import ca.esdot.picshop.commands.events.StartEditEvent;
	import ca.esdot.picshop.data.StickerTypes;
	import ca.esdot.picshop.dialogs.TileDialog;
	import ca.esdot.picshop.editors.AbstractEditor;
	import ca.esdot.picshop.events.ShowMenuEvent;
	import ca.esdot.picshop.utils.AnalyticsManager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	import org.robotlegs.mvcs.Mediator;
	
	import swc.speech.AllSpeech;
	
	public class ExtrasMenuMediator extends Mediator
	{
		[Inject]
		public var view:ExtrasMenu;
		
		[Inject]
		public var mainModel:MainModel;
		
		private var stickerList:Array;
		private var smallStickerList:Array;
		private var stickerDialog:TileDialog;
		
		override public function onRegister():void {
			addViewListener(ChangeEvent.CHANGED, onToolChanged, ChangeEvent);
			AnalyticsManager.pageView("extras");
		}
		
		protected function onToolChanged(event:ChangeEvent):void {
			AnalyticsManager.pageView("extras-" + event.newValue as String);
			if(event.newValue == ExtrasMenuTypes.STICKERS){
				dispatch(new ShowMenuEvent(ShowMenuEvent.SHOW_SECONDARY, event.newValue as String));
			} 
			else if(event.newValue == ExtrasMenuTypes.POINTERS){
				dispatch(new ShowStickersEvent(ShowStickersEvent.SHOW_DIALOG, StickerTypes.POINTERS));
			} 
			else if(event.newValue == ExtrasMenuTypes.ATTENTION){
				dispatch(new ShowStickersEvent(ShowStickersEvent.SHOW_DIALOG, StickerTypes.ATTENTION));
			} 
			else if(event.newValue == ExtrasMenuTypes.SPEECH_BUBBLES){
				showSpeechDialog();
			} else if(event.newValue == ExtrasMenuTypes.ADD_IMAGE){
				dispatch(new CommandEvent(CommandEvent.ADD_IMAGE_LAYER));
			}
			else {
				dispatch(new StartEditEvent(StartEditEvent.EXTRAS, event.newValue as String));
			}
		}
		
		protected function showSpeechDialog():void {
			stickerList = [];
			
			var stickerContainer:Sprite = new swc.speech.AllSpeech();
			
			while(stickerContainer.numChildren){
				stickerList.push(stickerContainer.removeChildAt(0));
			}
			
			stickerDialog = new TileDialog(stickerList, 2);
			var width:int = Math.min(800, view.stage.stageWidth * .9)
			var height:int = Math.min(600, view.stage.stageHeight * .9);
			stickerDialog.setSize(width, height);
			stickerDialog.setButtons(["Cancel"]);
			stickerDialog.addEventListener(ButtonEvent.CLICKED, onStickerClicked, false, 0, true);
			
			DialogManager.addDialog(stickerDialog);
		}
		
		protected function onStickerClicked(event:ButtonEvent):void {
			DialogManager.removeDialogs();
			
			if(event.label == "Cancel"){ return; }
			
			if(stickerDialog.currentSticker){
				dispatch(new StartEditEvent(StartEditEvent.EXTRAS, ExtrasMenuTypes.SPEECH_BUBBLES, stickerDialog.currentSticker));
			}
		}
	}
}
package ca.esdot.picshop.menus
{
	import ca.esdot.lib.events.BackEvent;
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.commands.events.ChangeViewEvent;
	import ca.esdot.picshop.commands.events.ShowStickersEvent;
	import ca.esdot.picshop.dialogs.TileDialog;
	import ca.esdot.picshop.utils.AnalyticsManager;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class StickersMenuMediator extends Mediator
	{
		[Inject]
		public var view:StickersMenu;
		
		[Inject]
		public var mainModel:MainModel;

		protected var stickerDialog:TileDialog;

		private var stickerList:Array;

		private var smallStickerList:Array;
		
		override public function onRegister():void {
			addViewListener(ChangeEvent.CHANGED, onToolChanged, ChangeEvent);
			addViewListener(BackEvent.BACK, onBackClicked, BackEvent);
		}
		
		protected function onBackClicked(event:BackEvent):void {
			dispatch(new ChangeViewEvent(ChangeViewEvent.BACK, null));
		}
		
		protected function onToolChanged(event:ChangeEvent):void {
			AnalyticsManager.pageView("extras-stickers-" + event.newValue as String);
			dispatch(new ShowStickersEvent(ShowStickersEvent.SHOW_DIALOG, event.newValue as String));
		}
		
		
	}
}
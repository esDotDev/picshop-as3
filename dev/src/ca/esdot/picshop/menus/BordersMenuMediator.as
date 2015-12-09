package ca.esdot.picshop.menus
{
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.commands.events.StartEditEvent;
	import ca.esdot.picshop.editors.AbstractEditor;
	import ca.esdot.picshop.utils.AnalyticsManager;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class BordersMenuMediator extends Mediator
	{
		[Inject]
		public var view:BordersMenu;
		
		[Inject]
		public var mainModel:MainModel;
		
		override public function onRegister():void {
			addViewListener(ChangeEvent.CHANGED, onToolChanged, ChangeEvent);
			AnalyticsManager.pageView("borders");
		}
		
		protected function onToolChanged(event:ChangeEvent):void {
			AnalyticsManager.pageView("borders-" + event.newValue as String);
			dispatch(new StartEditEvent(StartEditEvent.BORDER, event.newValue as String));
		}
	}
}
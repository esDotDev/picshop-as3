package ca.esdot.picshop.menus
{
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.commands.events.StartEditEvent;
	import ca.esdot.picshop.editors.AbstractEditor;
	import ca.esdot.picshop.utils.AnalyticsManager;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class BasicToolsMenuMediator extends Mediator
	{
		[Inject]
		public var view:BasicToolsMenu;
		
		[Inject]
		public var mainModel:MainModel;
		
		override public function onRegister():void {
			addViewListener(ChangeEvent.CHANGED, onToolChanged, ChangeEvent);
			AnalyticsManager.pageView("edits");
		}
		
		protected function onToolChanged(event:ChangeEvent):void {
			dispatch(new StartEditEvent(StartEditEvent.BASIC, event.newValue as String));
			AnalyticsManager.pageView("edits-" +  event.newValue as String);
		}
	}
}
package ca.esdot.picshop.views
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.commands.ChangeColorCommand;
	import ca.esdot.picshop.commands.events.ChangeColorEvent;
	import ca.esdot.picshop.commands.events.CommandEvent;
	import ca.esdot.picshop.commands.events.SettingsEvent;
	import ca.esdot.picshop.data.colors.AccentColors;
	import ca.esdot.picshop.data.colors.ColorTheme;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	import ca.esdot.picshop.utils.AnalyticsManager;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class SettingsPanelMediator extends Mediator
	{
		[Inject]
		public var view:SettingsPanel;
		
		[Inject]
		public var mainModel:MainModel;
		
		protected var cf:ColorTransform;
		
		override public function onRegister():void {
			
			AnalyticsManager.pageView("settings");
			
			//Will use to do Accented mouse over on renderers
			cf = new ColorTransform();
			
			mainModel.settings.numSettingsOpened++;
			dispatch(new SettingsEvent(SettingsEvent.SAVE));
			
			view.colorRenderer.currentColor = mainModel.settings.accentColor;
			view.bgRenderer.currentType = mainModel.settings.bgType;
			
			eventMap.mapListener(view.colorRenderer, ChangeEvent.CHANGED, onColorChanged);
			eventMap.mapListener(view.bgRenderer, ChangeEvent.CHANGED, onBgChanged);
			
			eventMap.mapListener(view.reviewAppRenderer, MouseEvent.CLICK, onMouseClick);
			eventMap.mapListener(view.reviewAppRenderer, MouseEvent.MOUSE_DOWN, onMouseDown);
			eventMap.mapListener(view.reviewAppRenderer, MouseEvent.MOUSE_OUT, onMouseUp);
			eventMap.mapListener(view.reviewAppRenderer, MouseEvent.MOUSE_UP, onMouseUp);
			
			eventMap.mapListener(view.contactRenderer, MouseEvent.CLICK, onMouseClick);
			eventMap.mapListener(view.contactRenderer, MouseEvent.MOUSE_DOWN, onMouseDown);
			eventMap.mapListener(view.contactRenderer, MouseEvent.MOUSE_OUT, onMouseUp);
			eventMap.mapListener(view.contactRenderer, MouseEvent.MOUSE_UP, onMouseUp);
			
			if(view.restoreRenderer){
				eventMap.mapListener(view.restoreRenderer, MouseEvent.MOUSE_UP, onMouseClick);
			}
		}
		
		protected function onMouseClick(event:MouseEvent):void {
			MainView.click();
			if(event.target == view.reviewAppRenderer){
				AnalyticsManager.pageView("settings-review");
				dispatch(new CommandEvent(CommandEvent.OPEN_REVIEW_LINK));
				
			} else if(event.target == view.contactRenderer){
				AnalyticsManager.pageView("settings-support");
				navigateToURL(new URLRequest("mailto: support@esdot.ca"));
			} else if(event.target == view.restoreRenderer){
				dispatch(new CommandEvent(CommandEvent.IN_APP_RESTORE));
			}
		}
		
		protected function onMouseDown(event:MouseEvent):void {
			ColorTheme.colorTextfield(event.currentTarget as Sprite, AccentColors.currentColor);
		}
		
		protected function onMouseUp(event:MouseEvent):void {
			ColorTheme.colorTextfield(event.currentTarget as Sprite);
		}
		
		protected function onColorChanged(event:ChangeEvent):void {
			dispatch(new ChangeColorEvent(ChangeColorEvent.CHANGE_ACCENT, Number(event.newValue)));
		}
		
		protected function onBgChanged(event:ChangeEvent):void {
			mainModel.settings.bgType = event.newValue as String;
			ColorTheme.bgType = mainModel.settings.bgType;
			dispatch(new SettingsEvent(SettingsEvent.SAVE));
		}
	}
}
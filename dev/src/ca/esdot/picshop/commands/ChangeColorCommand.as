package ca.esdot.picshop.commands
{
	import flash.display.Bitmap;
	
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.commands.events.ChangeColorEvent;
	import ca.esdot.picshop.commands.events.SettingsEvent;
	import ca.esdot.picshop.components.Slider;
	import ca.esdot.picshop.components.buttons.LabelButton;
	import ca.esdot.picshop.data.colors.AccentColors;
	import ca.esdot.picshop.data.colors.ColorTheme;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	import ca.esdot.picshop.menus.TopMenu;
	
	import org.robotlegs.mvcs.Command;
	
	public class ChangeColorCommand extends Command
	{
		[Inject]
		public var event:ChangeColorEvent;
		
		[Inject]
		public var mainModel:MainModel;
		
		override public function execute():void {
			
			mainModel.settings.accentColor = event.color;
			ColorTheme.bgType = mainModel.settings.bgType;
			
			AccentColors.currentColor = event.color;
			(contextView as MainView).topMenu.accentColor = event.color;
			SharedBitmaps.accentColor.fillRect(SharedBitmaps.accentColor.rect, event.color);
			Slider.colorAccent = event.color;
			
			
			dispatch(new SettingsEvent(SettingsEvent.SAVE));
			
		}
	}
}
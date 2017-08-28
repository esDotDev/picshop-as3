package ca.esdot.picshop.commands
{
	import com.gskinner.filters.SharpenFilter;
	import com.pusleb.nativeExtensions.RefreshGallery.RefreshGallery;
	
	import flash.display.BitmapData;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.utils.ImageWriter;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.commands.events.CommandEvent;
	import ca.esdot.picshop.commands.events.SaveImageEvent;
	import ca.esdot.picshop.commands.events.SettingsEvent;
	import ca.esdot.picshop.commands.events.ShowTipEvent;
	import ca.esdot.picshop.data.Strings;
	import ca.esdot.picshop.dialogs.TitleDialog;
	import ca.esdot.picshop.utils.AnalyticsManager;
	
	import org.robotlegs.mvcs.Command;
	
	public class SaveImageCommand extends Command
	{
		[Inject]
		public var event:SaveImageEvent;
		
		[Inject] 
		public var mainModel:MainModel;
		
		public var imageWriter:ImageWriter;
		public var failedOnce:Boolean;

		protected var sizedData:BitmapData;
		
		override public function execute():void {
			
			commandMap.detain(this);
			
			(contextView as MainView).isLoading = true;
			
			setTimeout(writeImage, 500);
			
		}
		
		protected function writeImage(quality:String = null):void {
			sizedData = formatForSave(mainModel.sourceData);
			
			imageWriter = new ImageWriter();
			imageWriter.addEventListener(ErrorEvent.ERROR,onImageError, false, 0, true);
			imageWriter.addEventListener(Event.COMPLETE, onImageComplete, false, 0, true);
			
			imageWriter.write(sizedData, event.options.location, event.options.quality * 100);
			
		}
		
		protected function onImageError(event:ErrorEvent):void {
			
			onImageComplete(null);
			return;
			
			//if(failedOnce){
				var dialog:TitleDialog = new TitleDialog(DeviceUtils.dialogWidth, DeviceUtils.dialogHeight, "Woops", "An error occured when saving the file. It's probably too big, try saving at a smaller size.");
				dialog.addEventListener(ButtonEvent.CLICKED, function(){
					DialogManager.removeDialogs();
					releaseCommand();
				});
				dialog.setButtons([Strings.OK]);
				DialogManager.addDialog(dialog);
				
			/*} else {
				failedOnce = true;
				writeImage(SaveQuality.HIGH);
				trace("Error Saving Image: " + event.errorID + event.text);
			}*/
			
		}
		
		protected function formatForSave(sourceData:BitmapData):BitmapData {
			
			sourceData = sourceData.clone();
			
			//Sharpen the image a on save, to make it look a little extra crisp;
			var sharpenFilter:SharpenFilter = new SharpenFilter((Math.max(sourceData.width, sourceData.height) * .01));
			if(!failedOnce){
				sourceData.applyFilter(sourceData, sourceData.rect, new Point(), sharpenFilter);
			}
			
			var scaleX:Number = event.options.width / sourceData.width;
			var scaleY:Number = event.options.height / sourceData.height;
			
			var m:Matrix = new Matrix();
			m.scale(scaleX, scaleY);
			
			var data:BitmapData = new BitmapData(sourceData.width * scaleX, sourceData.height * scaleY, false, 0x0);
			data.draw(sourceData, m, null, null, null, true);
			
			return data;
		}
		
		protected function onImageComplete(event:Event):void {
			var dialog:TitleDialog = new TitleDialog(DeviceUtils.dialogWidth, DeviceUtils.dialogHeight, 
				"Save Complete", "Your image has been saved. Thanks for choosing PicShop!" + 
				"\n\nNOTE: You can find your image in " + imageWriter.saveLocationName);
			dialog.setButtons(["Ok"]);
			dialog.addEventListener(ButtonEvent.CLICKED, function():void{ 
				releaseCommand();
			});
			DialogManager.addDialog(dialog, false);
			
			AnalyticsManager.imageSaved();
		}
		
		protected function releaseCommand():void {
			DialogManager.removeDialogs();
			(contextView as MainView).isLoading = false;
			
			mainModel.settings.numSaves++;
			dispatch(new SettingsEvent(SettingsEvent.SAVE));
			
			checkPrompts();
			
			commandMap.release(this);
		}
		
		protected function checkPrompts():void {
			
			
				dispatch(new CommandEvent(CommandEvent.PROMPT_FOR_REVIEW));
			
			
			
		}		

	}
}
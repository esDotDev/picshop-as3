package ca.esdot.picshop.views
{
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.commands.events.StartEditEvent;
	import ca.esdot.picshop.data.Strings;
	import ca.esdot.picshop.menus.ExtrasMenuTypes;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.StageQuality;
	import flash.geom.Matrix;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class FullScreenCropViewMediator extends Mediator
	{
		[Inject]
		public var view:FullscreenCropView;
		
		override public function onRegister():void {
			
			eventMap.mapListener(view.buttonBar, ButtonEvent.CLICKED, onButtonClicked);
			
		}
		
		protected function onButtonClicked(event:ButtonEvent):void {
			if(event.label == Strings.APPLY){
				var sourceData:BitmapData = view.bitmapData;
				var cropView:CropView = view.cropView;
				
				var newSource:BitmapData = new BitmapData(sourceData.width * cropView.cropWidth, sourceData.height * cropView.cropHeight, true, 0x0);
				var m:Matrix = new Matrix(1, 0, 0, 1, -cropView.cropX * sourceData.width, -cropView.cropY * sourceData.height);
				if(RENDER::GPU) {
					newSource.drawWithQuality(sourceData, m, null, null, null, true, StageQuality.HIGH);
				} else {
					newSource.draw(sourceData, m, null, null, null, true);
				}
				dispatch(new StartEditEvent(StartEditEvent.EXTRAS, ExtrasMenuTypes.ADD_IMAGE, new Bitmap(newSource)));
			} 
			view.parent.removeChild(view);
		}
	}
}
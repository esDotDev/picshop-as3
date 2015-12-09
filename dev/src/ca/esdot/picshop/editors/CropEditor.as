package ca.esdot.picshop.editors
{
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.components.buttons.ComboBoxButton;
	import ca.esdot.picshop.components.buttons.TileButton;
	import ca.esdot.picshop.data.CropModes;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	import ca.esdot.picshop.dialogs.OptionsDialog;
	import ca.esdot.picshop.views.CropView;
	import ca.esdot.picshop.views.EditView;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	
	public class CropEditor extends AbstractEditor
	{
		public var cropView:CropView;
		
		protected var currentButton:TileButton;
		protected var cropModeButton:ComboBoxButton;
		
		protected var _currentRatio:String;
		protected var ratioList:Array;
		private var lines:Sprite;
		
		public function CropEditor(editView:EditView){
			super(editView);
			
			setInstructions("For best results, put important focal points on the grid intersections.");
		}
		
		public function get currentRatio():String { return _currentRatio; }
		public function set currentRatio(value:String):void {
			_currentRatio = value;
			cropModeButton.label = "Aspect Ratio: " +  ratioList[ratioList.indexOf(_currentRatio)]
			if(cropView){
				cropView.cropMode = _currentRatio;
			}
		}

		override public function createChildren():void {
			
			ratioList = [
				CropModes.FREEFORM,
				CropModes.SQUARE,
				CropModes.FOUR_BY_THREE,
				CropModes.GOLDEN,
				CropModes.FOUR_BY_SIX,
				CropModes.FIVE_BY_SEVEN,
				CropModes.EIGHT_BY_TEN
			];
			
			cropModeButton = new ComboBoxButton();
			cropModeButton.addEventListener(MouseEvent.CLICK, onCropModeClicked, false, 0, true);
			controlsLayer.addChild(cropModeButton);
			
			currentRatio = CropModes.FREEFORM;
			
			lines = new Sprite();
			var bitmapData:BitmapData = SharedBitmaps.black;
			for(var i:int = 4; i-->0;){
				var bmp:Bitmap = new Bitmap(bitmapData);
				bmp.width = bmp.height = 1;
				lines.addChild(bmp);
			}
			addChild(lines);
		}
		
		protected function onCropModeClicked(event:Event):void {
			var index:int = ratioList.indexOf(currentRatio);
			
			var dialog:OptionsDialog = new OptionsDialog(DeviceUtils.dialogWidth, 
				Math.max(DeviceUtils.dialogHeight, viewHeight * .9), 
				"Blend Modes", ratioList, index);
			
			dialog.setButtons(["Cancel"]);
			dialog.addEventListener(ButtonEvent.CLICKED, onBlendDialogClicked, false, 0, true);
			
			DialogManager.addDialog(dialog);
		}
		
		protected function onBlendDialogClicked(event:ButtonEvent):void {
			DialogManager.removeDialogs();
			if(event.label == "Cancel"){ return; }
			
			currentRatio = event.label;
			drawLines();
		}	
		
		override public function init():void {
			super.init();
			createCropView();
		}
		
		private function createCropView():void {
			removeCropView();
			
			cropView = new CropView(editView.imageView.bitmap);
			cropView.x = editView.imageView.bitmap.localToGlobal(new Point()).x;
			cropView.y = editView.marginTop;
			cropView.onChangeCallback = drawLines;
			cropView.setSize(viewWidth, viewHeight);
			cropView.x = imageView.container.x;
			cropView.y = imageView.container.y;
			imageView.addChild(cropView);
			
			drawLines();
		}
		
		override public function transitionOut():void {
			super.transitionOut();
			if(cropView && cropView.parent){ 
				cropView.parent.removeChild(cropView);	
			}
			if(lines && lines.parent){
				removeChild(lines);
			}
		}
		
		protected function removeCropView():void {
			if(cropView && cropView.parent){ 
				cropView.parent.removeChild(cropView);	
			}
			cropView = null;
		}	
		
		override protected function updateControlsLayout():void {
			if(viewWidth > viewHeight){
				cropModeButton.setSize(viewWidth/2, DeviceUtils.hitSize);
			} else {
				cropModeButton.setSize(viewWidth, DeviceUtils.hitSize);
			}
			if(cropView){
				removeCropView();
				setTimeout(createCropView, 1);
			}
		}
		
		
		override public function applyToSource():BitmapData {
			var newSource:BitmapData = new BitmapData(sourceData.width * cropView.cropWidth, sourceData.height * cropView.cropHeight);
			var m:Matrix = new Matrix(1, 0, 0, 1, -cropView.cropX * sourceData.width, -cropView.cropY * sourceData.height);
			if(RENDER::GPU) {
				newSource.drawWithQuality(sourceData, m, null, null, null, false, StageQuality.HIGH);
			} else {
				newSource.draw(sourceData, m, null, null, null, false);
			}
			return newSource;
		}
		
		protected function drawLines():void {
			var circleWidth:int = cropView.cropTL.width/2;
			var TL:Point = cropView.cropTL.localToGlobal(new Point(0, 0));
			TL.y += editView.marginTop;
			
			var BL:Point = cropView.cropBL.localToGlobal(new Point(0, 0));
			BL.y += editView.marginTop;
			
			var TR:Point = cropView.cropTR.localToGlobal(new Point(0, 0));
			TR.y += editView.marginTop;
			
			var BR:Point = cropView.cropBR.localToGlobal(new Point(0, 0));
			BR.y += editView.marginTop;
			
			var y:int = (TR.y > TL.y)? TR.y : TL.y;
			var x:int = (BL.x > TL.x)? BL.x : TL.x;
			var w:int = Math.min(TR.x, BR.x) - Math.max(TL.x, BL.x);
			var h:int = Math.abs(BL.y - TL.y);
			
			var rect:Rectangle = new Rectangle(x, y, w, h);
			
			//Mid-Left
			lines.getChildAt(0).x = rect.x + rect.width * .33;
			lines.getChildAt(0).y = rect.y;
			lines.getChildAt(0).height = rect.height;
			
			//Mid-Right
			lines.getChildAt(1).x = rect.x + rect.width * .66;
			lines.getChildAt(1).y = rect.y;
			lines.getChildAt(1).height = rect.height;
			
			//Mid-Top
			lines.getChildAt(2).x = rect.x;
			lines.getChildAt(2).y = rect.y + rect.height * .33;
			lines.getChildAt(2).width = rect.width;
			
			//Mid-Bottom
			lines.getChildAt(3).x = rect.x;
			lines.getChildAt(3).y = rect.y + rect.height * .66;
			lines.getChildAt(3).width = rect.width;
			
		}
		
	}
}
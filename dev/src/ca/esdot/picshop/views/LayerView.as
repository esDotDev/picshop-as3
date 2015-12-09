package ca.esdot.picshop.views
{
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.components.SizableLayer;
	import ca.esdot.picshop.components.TransformBox;
	import ca.esdot.picshop.components.TransformBoxEvent;
	import ca.esdot.picshop.components.buttons.BaseButton;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	import ca.esdot.picshop.data.Strings;
	import ca.esdot.picshop.dialogs.TitleDialog;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	public class LayerView extends SizableView
	{
		//public var bg:BaseButton;
	//	public var bgMask:Bitmap;
		private var _layerScale:Number;
		private var boxList:Vector.<TransformBox>;
		private var boxToDelete:TransformBox;
		
		public function LayerView() {
			boxList = new <TransformBox>[];
			_viewWidth = 800; 
			_viewHeight = 600;
		}
		
		public function get layerScale():Number{ return _layerScale; }
		public function set layerScale(value:Number):void {
			_layerScale = value;
			for (var i:int = 0, l:int = boxList.length; i < l; i++){
				boxList[i].externalScale = _layerScale;
			}
			
		}

		public function addBox(box:TransformBox, width:int = -1, height:int = -1, x:int = 0, y:int = 0):void {
			if(!box){ return; }
			var scale:Number = Math.min(viewWidth / box.imageWidth, viewHeight / box.imageHeight);
			scale *= .5;
			
			if(width != -1 && height != -1){
				box.setSize(width, height);
			} else {
				box.setSize(box.imageWidth * scale, box.imageHeight * scale);
			}
			
			box.x = x;
			box.y = y;// + viewHeight * Math.random() * .15;
			box.addEventListener(TransformBoxEvent.DELETE, onDelete, false, 0, true);
			box.externalScale = _layerScale;
			
			boxList.push(box);
			addChild(box);
		}
		
		protected function onDelete(event:Event):void {
			boxToDelete = event.target as TransformBox;
			var dialog:TitleDialog = new TitleDialog(DeviceUtils.dialogWidth, DeviceUtils.dialogHeight, "Remove Layer?", "Are you sure you want to delete this layer? It's not undo-able.");
			dialog.setButtons([Strings.CANCEL, Strings.OK]); 
			dialog.addEventListener(ButtonEvent.CLICKED, onDeleteDialogClicked, false, 0, true);
			DialogManager.addDialog(dialog);
		}
		
		protected function onDeleteDialogClicked(event:ButtonEvent):void {
			if(event.label == Strings.OK){
				removeBox(boxToDelete);
			}
			boxToDelete = null;
			DialogManager.removeDialogs();
		}
		
		public function removeBox(box:TransformBox):void {
			if(!box){ return; }
			
			var scale:Number = Math.min(viewWidth / box.imageWidth, viewHeight / box.imageHeight);
			box.destroy();
			if(contains(box)){
				removeChild(box);
			}
			
			if(boxList.indexOf(box) != -1){
				boxList.splice(boxList.indexOf(box), 1);
			}
		}
		
		override public function setSize(width:int, height:int):void {
			var scaleDeltaX:Number = width / viewWidth;
			var scaleDeltaY:Number = height / viewHeight;
			
			super.setSize(width, height);
		}
		
		override public function updateLayout():void {
			//bg.width = viewWidth;
			//bg.height = viewHeight;
			
		}
		
		
		public function scaleLayers(previousScale:Number):void {
			for (var i:int = 0, l:int = boxList.length; i < l; i++){
				trace("before: ", boxList[i].x, boxList[i].y, previousScale);
				boxList[i].x = boxList[i].x * previousScale;
				boxList[i].y = boxList[i].y * previousScale;
				boxList[i].setSize(boxList[i].width * previousScale, boxList[i].height * previousScale);
				trace("after: ", boxList[i].x, boxList[i].y);
			}
		}
	}
}
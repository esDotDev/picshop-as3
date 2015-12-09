package ca.esdot.picshop.editors
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	import ca.esdot.lib.image.ImageBorders;
	import ca.esdot.picshop.editors.borders.FrameBgEditor;
	import ca.esdot.picshop.events.EditorEvent;
	import ca.esdot.picshop.views.EditView;
	
	public class AdvancedBorderEditor extends AbstractEditor
	{
		protected var bgEditor:FrameBgEditor;
		protected var frameLayer:Sprite;
		protected var borderBitmapData:BitmapData;
		
		public function AdvancedBorderEditor(editView:EditView, filterType:String) {
			
			super(editView);
		}
		
		
		override public function destroy():void {
			
			super.destroy();
			bgEditor.destroy();
			
		}
		override public function createChildren():void {
			
			bgEditor = new FrameBgEditor();
			
		}
		
		override protected function updateControlsLayout():void {
			
			bgEditor.setSize(viewWidth, viewHeight * .5);
			controlsLayer.addChild(bgEditor);
				
		}
		
		protected function onColorChanged(bitmapData:BitmapData):void {
			borderBitmapData = bitmapData;
			settingsDirty = true;
			applyChanges();
		}
		
		
		override public function init():void {
			super.init();
			
			bgEditor.init();
			bgEditor.bgChanged.add(onColorChanged);
			bgEditor.fadeLevelChanged.add(onFadeLevelChanged);
			bgEditor.paddingChanged.add(onPaddingChanged);
			bgEditor.cornerRadiusChanged.add(onCornerRadiusChanged);
			
			borderBitmapData = new BitmapData(2, 2, false, 0x0);
			
			var data:BitmapData = sourceDataSmall.clone();
			applyBorder(data);
			setCurrentBitmapData(data);
			processTimer.start();
			
		}
		
		protected function onFadeLevelChanged(value:Number):void {
			settingsDirty = true;
		}
		
		protected function onPaddingChanged(value:Number):void {
			settingsDirty = true;
		}
		
		protected function onCornerRadiusChanged(value:Number):void {
			settingsDirty = true;
		}
		
		override protected function applyChanges():void {
			if(!settingsDirty){ return; }
			var data:BitmapData = sourceDataSmall.clone();
			
			applyBorder(data);
			setCurrentBitmapData(data);
			settingsDirty = false;
		}
		
		protected function applyBorder(data:BitmapData, source:Boolean = false):void {
			
			var padding:Number = bgEditor.padding;
			
			var scale:Number = (source)? 1/editingDownscale : 1;
			
			var fadedBitmap:BitmapData = borderBitmapData.clone();
			if(bgEditor.fadeLevel != 0){
				var overlay:Sprite = new Sprite();
				//White
				if(bgEditor.fadeLevel > 0){
					overlay.graphics.beginFill(0xFFFFFF, bgEditor.fadeLevel);
				} 
				//Black
				else {
					overlay.graphics.beginFill(0x0, Math.abs(bgEditor.fadeLevel));
				}
				overlay.graphics.drawRect(0, 0, fadedBitmap.width, fadedBitmap.height);
				overlay.graphics.endFill();
				
				fadedBitmap.draw(overlay);
			}
			
			ImageBorders.borderUnderlay(data, fadedBitmap, padding, scale, bgEditor.cornerRadius);
			
			
		}
		
		override public function applyToSource():BitmapData {
			var data:BitmapData = sourceData.clone();
			
			applyBorder(data, true);

			return data;
		}
		
		override public function discardEdits():void {
			dispatchEvent(new EditorEvent(EditorEvent.DISCARD));
		}
		
	}
}
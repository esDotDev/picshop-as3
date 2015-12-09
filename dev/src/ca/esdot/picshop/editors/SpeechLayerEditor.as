package ca.esdot.picshop.editors
{
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.picshop.components.SizableLayer;
	import ca.esdot.picshop.components.TileMenu;
	import ca.esdot.picshop.components.TransformBox;
	import ca.esdot.picshop.components.TransformSpeechBox;
	import ca.esdot.picshop.views.EditView;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	public class SpeechLayerEditor extends AbstractEditor
	{
		public var layer:TransformSpeechBox;
		protected var tileMenu:TileMenu;
		
		public function SpeechLayerEditor(editView:EditView, image:DisplayObject) {
			super(editView);
			
			image.cacheAsBitmap = false;
			
			var w:int, h:int;
			w = editView.width * .1;
			h = image.height * (w / image.width);
		
			layer = new TransformSpeechBox(image as Sprite);
			layer.setSize(w, h);
			editView.imageView.layerView.addBox(layer, -1, -1, editView.viewWidth * .2, editView.viewHeight * .1);
			
			editView.imageView.isPanEnabled = false;
		}
		
		override public function createChildren():void {
			super.createChildren();
		}
		
		//Don't need to do anything on init with this editor.
		override public function init():void {}
		
		override public function discardEdits():void {
			editView.imageView.layerView.removeBox(layer);
			super.discardEdits();
		}
		
		override public function applyToSource():BitmapData {
			layer.uiContainer.visible = false;
			
			var newData:BitmapData = sourceData.clone();
			var scale:Number = sourceData.width / currentBitmap.width;
			
			var m:Matrix = new Matrix();
			m.scale(scale, scale);
			m.translate(layer.x * scale, layer.y * scale);
			if(RENDER::GPU) {
				newData.drawWithQuality(layer, m, null, null, null, true, StageQuality.HIGH);
			} else {
				newData.draw(layer, m, null, null, null, true);
			}
			editView.imageView.layerView.removeBox(layer);
			return newData;
		}
		
		override public function transitionOut():void {
			editView.imageView.isPanEnabled = true;
			super.transitionOut();
		}
	}
}
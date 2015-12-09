package ca.esdot.picshop.components
{
	import ca.esdot.lib.view.SizableView;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	
	public class SizableLayer extends SizableView
	{
		protected var layerBox:TransformBox;
		
		public function SizableLayer(image:DisplayObject) {
			
			layerBox = new TransformBox(image);
			layerBox.deleteEnabled = false;
			
			addChild(layerBox);
			
		}
		
		public function get bitmapWidth():Number {
			return layerBox.image.width;
		}
		
		public function get bitmapHeight():Number {
			return layerBox.image.height;
		}

		override public function updateLayout():void {
			layerBox.setSize(viewWidth, viewHeight);
		}
	}
}
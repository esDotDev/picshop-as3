package ca.esdot.picshop.components
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	public class BorderBox extends SizableView
	{
		protected var lB:Bitmap;
		protected var rB:Bitmap;
		protected var tB:Bitmap;
		protected var bB:Bitmap;
		
		public var borderSize:int = 1;
		
		public function BorderBox(borderSize:int = 1, borderData:BitmapData = null){
			this.borderSize = borderSize;
			
			lB = new Bitmap(borderData || SharedBitmaps.accentColor);
			addChild(lB);
			
			rB = new Bitmap(borderData || SharedBitmaps.accentColor);
			addChild(rB);
			
			tB = new Bitmap(borderData || SharedBitmaps.accentColor);
			addChild(tB);
			
			bB = new Bitmap(borderData || SharedBitmaps.accentColor);
			addChild(bB);
		}
		
		public function set bitmapData(value:BitmapData):void {
			lB.bitmapData = rB.bitmapData = tB.bitmapData = bB.bitmapData = value;
		}
		
		override public function updateLayout():void {
			lB.width = borderSize;
			lB.height = viewHeight;
			
			rB.x = viewWidth - borderSize;
			rB.width = borderSize;
			rB.height = viewHeight;
			
			tB.width = viewWidth;
			tB.height = borderSize;
			
			bB.y = viewHeight - borderSize;
			bB.width = viewWidth;
			bB.height = borderSize;
		}
	}
}
package ca.esdot.picshop.components
{
	import flash.display.Bitmap;
	
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.data.colors.ColorTheme;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	public class TileMenuBackground extends SizableView
	{
		public var dividerTop:Bitmap;
		public var dividerBottom:Bitmap;
		public var bg:Bitmap;
		
		public function TileMenuBackground(){
			
			bg = new Bitmap(SharedBitmaps.bgColor);
			addChild(bg);
			
			dividerTop = new Bitmap(SharedBitmaps.accentColor);
			addChild(dividerTop);
			
			dividerBottom = new Bitmap(SharedBitmaps.accentColor);
			addChild(dividerBottom);
			
		}
		
		override public function updateLayout():void {
			dividerTop.width = viewWidth;
			
			dividerBottom.width = viewWidth;
			dividerBottom.y = viewHeight - dividerBottom.height;
			
			bg.width = viewWidth;
			bg.height = viewHeight;
			
		}
	}
}
package ca.esdot.picshop.menus
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import assets.Bitmaps;
	
	import ca.esdot.lib.image.ImageBorders;
	import ca.esdot.picshop.components.buttons.FilterTileButton;
	import ca.esdot.picshop.components.buttons.LabelButton;
	
	public class BordersMenu extends FiltersMenu {
		
		public function BordersMenu() {}
		
		override public function createThumbs(sourceData:BitmapData):void {
			tileList = [
				ImageBorders.PATTERNS,
				ImageBorders.FEATHERED,
				ImageBorders.AURA,
				
				ImageBorders.TORN_4,
				ImageBorders.TORN_3,
				ImageBorders.TORN_2,
				ImageBorders.TORN,
				
				ImageBorders.GRUNGE,
				ImageBorders.GRUNGE_2,
				ImageBorders.GRUNGE_3,
				ImageBorders.GRUNGE_4,
				
				ImageBorders.POLAROID_CLEAN
				//ImageBorders.POLAROID_DIRTY,
				/*
				ImageBorders.OLD_PAPER1,
				ImageBorders.OLD_PAPER2,
				
				ImageBorders.LEAVES,
				ImageBorders.BALLOONS,
				ImageBorders.CARTOON,
				
				ImageBorders.CLASSIC_BLACK,
				ImageBorders.CLASSIC_RED,
				ImageBorders.CLASSIC_WHITE
				*/
				
				
			];
			
			super.createThumbs(sourceData);
			
			
			
		}
		
		override protected function createThumb():void {
			super.createThumb();
			
			if(buttonList.length == 1){
				
				
				(buttonList[0] as FilterTileButton).thumbData = (new Bitmaps.framesPreview() as Bitmap).bitmapData;
				
				buttonList[0].gridSize = 2;
				positionTiles();
			}
		}
		
		override protected function applyFilter(filter:String, data:BitmapData, sourceThumb:BitmapData):void {
			ImageBorders.apply(filter, data);
		}
	
		override protected function createTiles():void { }
		
	}
	
	
}
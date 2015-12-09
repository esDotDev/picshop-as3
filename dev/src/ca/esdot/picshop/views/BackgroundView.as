package ca.esdot.picshop.views
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	import assets.Bitmaps;
	
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.data.colors.BgType;
	import ca.esdot.picshop.data.colors.ColorTheme;
	import ca.esdot.picshop.data.colors.SharedBitmaps;

	public class BackgroundView extends SizableView
	{
		protected var bgSprite:Sprite;
		
		public function BackgroundView() {
			
			bgSprite = new Sprite();
			addChild(bgSprite);
			
			ColorTheme.bgChanged.add(onBgChanged);
		}
		
		protected function onBgChanged(type:String):void {
			bgType = type;
		}
		
		public function set bgType(value:String):void {
			if(isNaN(viewWidth) || isNaN(viewHeight)){ return; }
			var bmp:Bitmap;
			bgSprite.removeChildren();
			if(value == BgType.BLACK_FADE){
				bmp = new Bitmaps.bgBlackTileFade();
				bmp.height = viewHeight;
				bmp.width = viewWidth;
				bgSprite.addChild(bmp);
			} 
			else if(value == BgType.BLACK_GRID){
				gridFill(Bitmaps.bgBlackTileGrid);
			}	
			else if(value == BgType.BLACK_DOTS){
				gridFill(Bitmaps.bgBlackTileDots);
			}
			else if(value == BgType.WHITE_FADE){
				bmp = new Bitmaps.bgWhiteTileFade();
				bmp.width = viewWidth;
				bmp.height = viewHeight;
				bgSprite.addChild(bmp);
			}
			else if(value == BgType.WHITE_GRID){
				gridFill(Bitmaps.bgWhiteTileGrid);
			}	
			else if(value == BgType.WHITE_DOTS){
				gridFill(Bitmaps.bgWhiteTileDots);
			} 
			 
		}
		
		protected function gridFill(bitmapClass:Class):void {
			var bmp:Bitmap = new bitmapClass();
			var bmpWidth:int = bmp.width;
			var bmpHeight:int = bmp.height;
			if(viewWidth > 1800 || viewHeight > 1800){
				bmpWidth *= 2;
				bmpHeight *= 2;
			}
			var cols:int = Math.ceil(viewWidth / bmpWidth);
			var rows:int = Math.ceil(viewHeight / bmpHeight);
			var row:int = 0, col:int = 0;
			while(row < rows){
				bmp = new bitmapClass();
				bgSprite.addChild(bmp);
				bmp.x = bmpWidth * col;
				bmp.y = bmpHeight * row;
				bmp.width = bmpWidth;
				bmp.height = bmpHeight;
				col++;
				if(col > cols){ col = 0; row++; }
			}
		}
		
		override public function updateLayout():void {
			bgType = ColorTheme.bgType;
		}
	}
}
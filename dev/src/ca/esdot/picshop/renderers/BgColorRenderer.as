package ca.esdot.picshop.renderers
{
	import flash.display.Bitmap;
	import flash.display.CapsStyle;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	
	import assets.Bitmaps;
	
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.picshop.data.colors.BgType;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	import swc.BgColorRenderer;
	
	public class BgColorRenderer extends Sprite
	{
		protected var swatchWidth:int;
		protected var swatchHeight:int;
		
		protected var swatchContainer:Sprite;
		
		protected var colorsBySprite:Dictionary;
		protected var spritesByColors:Object;
		protected var colorList:Array;
		
		public var labelText:TextField;
		protected var indicator:Bitmap;
		protected var _currentType:String;
		
		public function BgColorRenderer(swatchWidth:int = 65, swatchHeight:int = 50){
			
			colorList = [BgType.BLACK_FADE, BgType.BLACK_GRID, BgType.BLACK_DOTS, BgType.WHITE_FADE, BgType.WHITE_GRID, BgType.WHITE_DOTS];
			colorsBySprite = new Dictionary();
			spritesByColors = {};
			
			var viewAssets:swc.BgColorRenderer = new swc.BgColorRenderer();
			labelText = viewAssets.labelText;
			labelText.mouseEnabled = false;
			addChild(labelText);
			
			this.swatchWidth = swatchWidth;
			this.swatchHeight = swatchHeight;
			
			swatchContainer = new Sprite();
			addChild(swatchContainer);
			
			createSwatches();
		}	
		
		public function get currentType():String {
			return _currentType;
		}

		public function set currentType(value:String):void{
			if(value == _currentType){ return; }
			_currentType = value;
			dispatchEvent(new ChangeEvent(ChangeEvent.CHANGED, currentType));
			if(spritesByColors[value]){
				indicator.x = spritesByColors[value].x - 2;
			}
		}

		override public function set width(value:Number):void {
			labelText.width = value - labelText.x * 2;
		}
		
		
		protected function createSwatches():void {
			var top:int = labelText.height + 5;
			var sprite:Sprite;
			swatchContainer.removeChildren();
			for(var i:int = 0; i < colorList.length; i++){
				sprite = new Sprite();
				var bmp:Bitmap;
				if(colorList[i] == BgType.BLACK_FADE){
					bmp = new Bitmaps.bgBlackTileFade();
				}
				else if(colorList[i] == BgType.BLACK_GRID){
					bmp = new Bitmaps.bgBlackTileGrid();
				}
				else if(colorList[i] == BgType.BLACK_DOTS){
					bmp = new Bitmaps.bgBlackTileDots();
				}
				else if(colorList[i] == BgType.WHITE_FADE){
					bmp = new Bitmaps.bgWhiteTileFade();
				}
				else if(colorList[i] == BgType.WHITE_GRID){
					bmp = new Bitmaps.bgWhiteTileGrid();
				}
				else if(colorList[i] == BgType.WHITE_DOTS){
					bmp = new Bitmaps.bgWhiteTileDots();
				}
				
				bmp.width = swatchWidth;
				bmp.height = swatchHeight;
				sprite.addChild(bmp);
				
				bmp = new Bitmap(SharedBitmaps.backgroundAccent);
				bmp.width = swatchWidth + 2;
				bmp.height = swatchHeight + 2;
				bmp.x = bmp.y = -1;
				sprite.addChildAt(bmp, 0);
				
				sprite.x = i * (swatchWidth + 5);
				sprite.y = top;
				sprite.addEventListener(MouseEvent.CLICK, onSwatchClicked, false, 0, true);
				sprite.addEventListener(MouseEvent.MOUSE_MOVE, onSwatchClicked, false, 0, true);
				swatchContainer.addChild(sprite);
				
				colorsBySprite[sprite] = colorList[i];
				spritesByColors[colorList[i]] = sprite;
			}
			
			indicator = new Bitmap(SharedBitmaps.disabledGrey);
			indicator.width = swatchWidth + 4;
			indicator.height = swatchHeight + 4;
			indicator.y = top - 2;
			swatchContainer.addChildAt(indicator, 0);
		}
		
		protected function onSwatchClicked(event:MouseEvent):void {
			currentType = colorsBySprite[event.target];
		}
		
	}
}
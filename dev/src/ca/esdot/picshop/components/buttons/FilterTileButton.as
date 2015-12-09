package ca.esdot.picshop.components.buttons
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.Matrix;
	import flash.utils.setTimeout;
	
	import ca.esdot.lib.components.Image;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.data.colors.ColorTheme;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	import swc.ToolTile;
	
	public class FilterTileButton extends LabelButton
	{	
		protected static var bgCache:BitmapData;
		protected var accentDot:Sprite;
		
		protected var tileBg:Bitmap;
		protected var textCache:Bitmap;
		protected var image:Image;
		private var _thumbData:BitmapData;
		protected var stroke:Bitmap;
		
		public var gridSize:int = 1;

		protected var tileAssets:swc.ToolTile;
		
		public function FilterTileButton(label:String = "", thumbData:BitmapData = null) {
			_thumbData = thumbData;
			super(label.toUpperCase());
			
			
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			removeChild(divider);
			removeChild(labelText);
			
			stroke = new Bitmap(SharedBitmaps.accentColor);
			addChild(stroke);
			
			tileAssets = new swc.ToolTile();
			if(!bgCache){
				if(ColorTheme.whiteMode){
					tileAssets.bg.gotoAndStop("white");
				}
				ColorTheme.whiteModeChanged.add(onWhiteModeChanged);
				updateCache();
			}
			ColorTheme.whiteModeChanged.add(onWhiteModeChangedInstance);
			
			tileBg = new Bitmap(bgCache);
			addChild(tileBg);
			
			textCache = new Bitmap();
			addChild(textCache);
			
			labelText = tileAssets.labelText;
			ColorTheme.colorTextfield(labelText);
			
			this.label = label.toUpperCase();
			
			image = new Image();
			image.clipEdges = true;
			image.bitmapData = thumbData;
			addChild(image);
		}
		
		override public function destroy():void {
			super.destroy();
			bgCache = null;
			thumbData = null;
			if(image){
				image.destroy();
				image = null;
			}
			ColorTheme.whiteModeChanged.remove(onWhiteModeChangedInstance);
			ColorTheme.removeSprite(labelText);
		}
		
		protected function onWhiteModeChangedInstance(value:Boolean):void {
			setTimeout(function(){
				label = labelText.text;
			}, 1);
		}
		
		protected function onWhiteModeChanged(value:Boolean):void {
			trace(value? "white" : "black");
			tileAssets.bg.gotoAndStop(value? "white" : "black");
			updateCache();
		}
		
		protected function updateCache():void {
			if(!bgCache){ 
				bgCache = new BitmapData(tileAssets.bg.width * 2, tileAssets.bg.height * 2, false);
			}
			var m:Matrix = new Matrix();
			m.scale(2, 2);
			bgCache.floodFill(0, 0, ColorTheme.whiteMode? 0xFFFFFF : 0x0);
			bgCache.drawWithQuality(tileAssets.bg, m, null, null, null, true, StageQuality.BEST);
		}
		
		override public function set label(value:String):void {
			super.label = value;
			if(!textCache || labelText.width == 0){ return; }
			removeChild(labelText);
			
			bold = true;
			fontSize = DeviceUtils.fontSize * .75;
			var data:BitmapData = new BitmapData(labelText.width, labelText.height, true, 0x0);
			data.draw(labelText);
			textCache.bitmapData = data;
			textCache.smoothing = true;
		}
		
		override public function updateLayout():void {
			bg.width = bgDown.width = viewWidth;
			bg.height = bgDown.height = viewHeight;
			
			tileBg.width = viewWidth - DeviceUtils.padding * 2;
			tileBg.height = viewHeight - DeviceUtils.padding * 2;
			tileBg.x = viewWidth - tileBg.width >> 1;
			tileBg.y = viewHeight - tileBg.height >> 1;
			
			stroke.width = tileBg.width + 2;
			stroke.height = tileBg.height + 2;
			stroke.x = tileBg.x - 1;
			stroke.y = tileBg.y - 1;
			
			var topHeight:int = tileBg.height * .18; //Hardcoded ratio from FLA
			if(image.bitmapData){
				image.y = tileBg.y + topHeight;
				image.x = tileBg.x + 1;
				image.setSize(tileBg.width - 2, tileBg.height - topHeight);
			}
			if(!accentDot){
				createAccent();
			}
			accentDot.x = tileBg.x + tileBg.width - accentDot.width - DeviceUtils.paddingSmall;
			accentDot.y = tileBg.y + (topHeight - accentDot.height >> 1);
			
			labelText.width = bg.width * .9;
			labelText.height = bg.height * .5;
			this.label = label;
			
			textCache.x = tileBg.x + DeviceUtils.paddingSmall;
			textCache.y = tileBg.y + (topHeight - labelText.textHeight) * .5;
			
		}
		
		protected function createAccent():void {
			var squareSize:int = DeviceUtils.paddingSmall * .5;
			var squarePadding:int = squareSize * .5;
			accentDot = new Sprite();
			accentDot.graphics.beginBitmapFill(SharedBitmaps.accentColor);
			accentDot.graphics.drawRect(0, 0, squareSize, squareSize);
			accentDot.graphics.drawRect(0, squareSize + squarePadding, squareSize, squareSize);
			accentDot.graphics.drawRect(squareSize + squarePadding, 0, squareSize, squareSize);
			accentDot.graphics.drawRect(squareSize + squarePadding, squareSize + squarePadding, squareSize, squareSize);
			accentDot.graphics.endFill();
			addChild(accentDot);
		}

		public function get thumbData():BitmapData { return _thumbData;	}
		public function set thumbData(value:BitmapData):void {
			_thumbData = value;
			if(image){
				image.bitmapData = thumbData;
			}
			updateLayout();
		}

	}
}
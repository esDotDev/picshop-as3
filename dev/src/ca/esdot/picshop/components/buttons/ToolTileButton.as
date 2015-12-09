package ca.esdot.picshop.components.buttons
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.Matrix;
	import flash.utils.setTimeout;
	
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.data.colors.ColorTheme;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	import swc.ToolTile;
	
	public class ToolTileButton extends LabelButton
	{	
		protected static var bgCache:BitmapData;
		
		protected var tileBg:Bitmap;
		protected var textCache:Bitmap;
		private var iconScale:Number;
		protected var stroke:Bitmap;

		protected var tileAssets:swc.ToolTile;
		
		public function ToolTileButton(label:String = "", icon:DisplayObject = null, iconScale:Number = .4) {
			super(label.toUpperCase());
			removeChild(divider);
			removeChild(labelText);
			
			this.iconScale = iconScale;
			
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
			
			if(icon){
				this.icon = icon;
				//ColorTheme.colorSprite(icon);
				addChild(icon);
			}
		}
		
		override public function destroy():void {
			super.destroy();
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
			if(!textCache){ return; }
			removeChild(labelText);
			
			bold = true;
			fontSize = labelText.width / 10;
			var data:BitmapData = new BitmapData(Math.min(500, labelText.width), Math.min(100, labelText.height), true, 0x0);
			data.draw(labelText);
			textCache.bitmapData = data;
			textCache.smoothing = true;
		}
		
		override public function updateLayout():void {
			
			bg.width = bgDown.width = viewWidth;
			bg.height = bgDown.height = viewHeight;
			
			tileBg.width = viewWidth - DeviceUtils.paddingSmall * 2;
			tileBg.height = viewHeight - DeviceUtils.paddingSmall * 2;
			tileBg.x = viewWidth - tileBg.width >> 1;
			tileBg.y = viewHeight - tileBg.height >> 1;
			
			stroke.width = tileBg.width + 2;
			stroke.height = tileBg.height + 2;
			stroke.x = tileBg.x - 1;
			stroke.y = tileBg.y - 1;
			
			divider.height = viewHeight;
			divider.width = 1;
			divider.x = viewWidth - divider.width;
			
			var topHeight:int = tileBg.height * .28; //Hardcoded ratio from FLA
			if(icon){
				var iconWidth:int = viewWidth * iconScale;
				if(icon.width > icon.height){
					icon.width = iconWidth;
					icon.scaleY = icon.scaleX;
				} else {
					icon.height = iconWidth;
					icon.scaleX = icon.scaleY;
				}
				
				icon.x = viewWidth - icon.width >> 1;
				icon.y = tileBg.y + topHeight + ((tileBg.height - topHeight)/2 - icon.height/2);
			}
			
			
			labelText.width = bg.width * .9;
			labelText.height = bg.height * .5;
			this.label = label;
			
			textCache.x = tileBg.x + DeviceUtils.paddingSmall;
			textCache.y = tileBg.y + DeviceUtils.paddingSmall;
			
		}
		
	}
}
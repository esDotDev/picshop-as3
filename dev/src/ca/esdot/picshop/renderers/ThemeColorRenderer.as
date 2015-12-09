package ca.esdot.picshop.renderers
{
	import flash.display.Bitmap;
	import flash.display.CapsStyle;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.picshop.data.colors.AccentColors;
	import ca.esdot.picshop.data.colors.ColorTheme;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	import swc.ThemeColorRenderer;
	
	public class ThemeColorRenderer extends Sprite
	{
		protected var swatchWidth:int;
		protected var swatchHeight:int;
		
		protected var swatchContainer:Sprite;
		
		protected var colorsBySprite:Dictionary;
		protected var spritesByColors:Object;
		protected var colorList:Array;
		
		public var labelText:TextField;
		protected var indicator:Bitmap;
		protected var _currentColor:int;
		
		public function ThemeColorRenderer(swatchWidth:int = 55, swatchHeight:int = 50){
			
			colorList = [AccentColors.BLUE, AccentColors.RED, AccentColors.AQUA, AccentColors.ORANGE, AccentColors.GREEN, AccentColors.PINK, AccentColors.PURPLE ];
			colorsBySprite = new Dictionary();
			spritesByColors = {};
			
			var viewAssets:swc.ThemeColorRenderer = new swc.ThemeColorRenderer;
			labelText = viewAssets.labelText;
			labelText.mouseEnabled = false;
			addChild(labelText);
			
			this.swatchWidth = swatchWidth;
			this.swatchHeight = swatchHeight;
			
			swatchContainer = new Sprite();
			addChild(swatchContainer);
			
			createSwatches();
		}	
		
		public function get currentColor():int {
			return _currentColor;
		}

		public function set currentColor(value:int):void{
			if(value == _currentColor){ return; }
			_currentColor = value;
			dispatchEvent(new ChangeEvent(ChangeEvent.CHANGED, currentColor));
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
				sprite.graphics.beginFill(colorList[i]);
				sprite.graphics.drawRect(0, 0, swatchWidth, swatchHeight);
				sprite.graphics.endFill();
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
			currentColor = colorsBySprite[event.target];
		}
		
	}
}
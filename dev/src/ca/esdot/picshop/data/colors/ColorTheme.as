package ca.esdot.picshop.data.colors
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.osflash.signals.Signal;

	public class ColorTheme
	{
		public static var MID_GREY:Number = 0x282828;
		public static var LIGHT_GREY:Number = 0x3d3d3d;
		public static var LIGHTER_GREY:Number = 0xb7b7b7;
		public static var TEXT_ALMOST_WHITE:Number = 0xE5E5E5;
		
		protected static var coloredSprites:Array = [];
		protected static var _bgType:String;
		
		public static var bgChanged:Signal = new Signal(String);
		public static var whiteModeChanged:Signal = new Signal(Boolean);
		
		protected static var _whiteMode:Boolean = true;
		
		public static function get textColor():uint {
			return whiteMode? 0x0 : TEXT_ALMOST_WHITE;
		}
		
		public static function get bgColor():uint {
			return whiteMode? 0xFFFFFF : 0x0;
		}
		
		public static function get bgColor2():uint {
			return whiteMode? 0xFFFFFF : MID_GREY;
		}
		
		public static function get strokeColor():uint {
			return whiteMode? LIGHTER_GREY : LIGHT_GREY
		}
		
		public static function get underlayColor():uint {
			return whiteMode? 0xFFFFFF : 0x0;
		}
		
		public static function colorTextfield(target:*, color:int = -1):void {
			if(target is TextField){
				var text:TextField = target as TextField;
				var tf:TextFormat = text.defaultTextFormat;
				if(color < 0){
					color = whiteMode? 0x0 : ColorTheme.TEXT_ALMOST_WHITE;
					if(coloredSprites.indexOf(text) == -1){
						coloredSprites.push(text);
					}
				}
				tf.color = color;
				text.defaultTextFormat = tf;
				text.setTextFormat(tf);
			}
			else if(target is DisplayObjectContainer){
				var container:DisplayObjectContainer = target as DisplayObjectContainer;
				for(var i:int = container.numChildren; i--;){
					colorTextfield(container.getChildAt(i), color);
				}
			}		
		}
		
		public static function removeSprite(sprite:*):void {
			for(var i:int = coloredSprites.length; i--;){
				if(coloredSprites[i] == sprite){
					coloredSprites.splice(i, 1);
					break;
				}
			}
		}
		
		public static function colorSprite(icon:DisplayObject):DisplayObject {
			var ct:ColorTransform = icon.transform.colorTransform;
			ct.color = whiteMode? 0x0 : 0xFFFFFF;
			icon.transform.colorTransform = ct;
			if(coloredSprites.indexOf(icon) == -1){
				coloredSprites.push(icon);
				if(icon is Bitmap){
					(icon as Bitmap).smoothing = true;
				}
			}
			return icon;
		}
		
		public static function get bgType():String { return _bgType; }
		public static function set bgType(value:String):void {
			if(value == _bgType){ return; }
			_bgType = value;
			bgChanged.dispatch(_bgType);
			if(bgType == BgType.BLACK_DOTS || bgType == BgType.BLACK_FADE|| bgType == BgType.BLACK_GRID){
				whiteMode = false;
			} else {
				whiteMode = true;
			}
		}
		
		

		public static function get whiteMode():Boolean { return _whiteMode; }
		public static function set whiteMode(value:Boolean):void {
			if(value == _whiteMode){ return; }
			_whiteMode = value;
			whiteModeChanged.dispatch(_whiteMode); 
			SharedBitmaps.updateBitmaps();
			
			for(var i:int = coloredSprites.length; i--;){
				if(coloredSprites[i] is TextField){
					colorTextfield(coloredSprites[i]);
				} else if(coloredSprites[i] is DisplayObject){
					colorSprite(coloredSprites[i]);
				}
			}
		}


		
	}
}
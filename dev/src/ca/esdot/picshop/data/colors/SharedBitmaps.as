package ca.esdot.picshop.data.colors
{
	
	import flash.display.BitmapData;

	public class SharedBitmaps
	{
		protected static var _accentColor:BitmapData;
		
		public static function updateBitmaps():void {
			
			update(_accentColor, AccentColors.currentColor);
			update(_strokeColor, ColorTheme.strokeColor);
			update(_underlayColor, ColorTheme.underlayColor);
			update(_backgroundLight, ColorTheme.strokeColor);
			update(_bgColor, ColorTheme.bgColor);
			update(_bgColor2, ColorTheme.bgColor2);
			
		}
		
		protected static function update(bmp:BitmapData, color:uint):void {
			if(!bmp){ return; }
			bmp.fillRect(bmp.rect, color);
		}
		
		public static function get accentColor():BitmapData {
			if(!_accentColor){
				_accentColor = new BitmapData(1, 1, false, AccentColors.DEFAULT);
			}
			return _accentColor;
		}
		
		protected static var _strokeColor:BitmapData;
		public static function get strokeColor():BitmapData {
			if(!_strokeColor){
				_strokeColor = new BitmapData(1, 1, false, ColorTheme.strokeColor);
			}
			return _strokeColor;
		}
		
		protected static var _underlayColor:BitmapData;
		public static function get underlayColor():BitmapData {
			if(!_underlayColor){
				_underlayColor = new BitmapData(1, 1, false, ColorTheme.underlayColor);
			}
			return _strokeColor;
		}
		
		protected static var _backgroundLight:BitmapData;
		public static function get backgroundAccent():BitmapData {
			if(!_backgroundLight){
				_backgroundLight = new BitmapData(1, 1, false, ColorTheme.strokeColor);
			}
			return _backgroundLight;
		}
		
		protected static var _bgColor:BitmapData;
		public static function get bgColor():BitmapData {
			if(!_bgColor){
				_bgColor = new BitmapData(1, 1, false, ColorTheme.bgColor);
			}
			return _bgColor;
		}
		
		protected static var _bgColor2:BitmapData;
		public static function get bgColor2():BitmapData {
			if(!_bgColor2){
				_bgColor2 = new BitmapData(1, 1, false, ColorTheme.bgColor2);
			}
			return _bgColor2;
		}

		protected static var _black:BitmapData;
		public static function get black():BitmapData {
			if(!_black){
				_black = new BitmapData(1, 1, false, 0x0);
			}
			return _black;
		}
		
		protected static var _white:BitmapData;
		public static function get white():BitmapData {
			if(!_white){
				_white = new BitmapData(1, 1, false, 0xFFFFFF);
			}
			return _white;
		}
		
		protected static var _clear:BitmapData;
		public static function get clear():BitmapData {
			if(!_clear){
				_clear = new BitmapData(1, 1, true, 0x0);
			}
			return _clear;
		}
		
		protected static var _gold:BitmapData;
		public static function get gold():BitmapData {
			if(!_gold){
				_gold = new BitmapData(1, 1, false, 0xe6a93f);
			}
			return _gold;
		}
		
		protected static var _facebookBlue:BitmapData;
		public static function get facebookBlue():BitmapData {
			if(!_facebookBlue){
				_facebookBlue = new BitmapData(1, 1, false, 0x0154a0);
			}
			return _facebookBlue;
		}
		
		protected static var _twitterBlue:BitmapData;
		public static function get twitterBlue():BitmapData {
			if(!_twitterBlue){
				_twitterBlue = new BitmapData(1, 1, false, 0x5dd7fc);
			}
			return _twitterBlue;
		}
		
		protected static var _instagramBlue:BitmapData;
		public static function get instagramBlue():BitmapData {
			if(!_instagramBlue){
				_instagramBlue = new BitmapData(1, 1, false, 0x34628A);
			}
			return _instagramBlue;
		}
		
		protected static var _disabledGrey:BitmapData;
		public static function get disabledGrey():BitmapData {
			if(!_disabledGrey){
				_disabledGrey = new BitmapData(1, 1, false, 0x7f7f7f);
			}
			return _disabledGrey;
		}
		
		
	}
}
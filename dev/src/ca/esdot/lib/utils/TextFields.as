package ca.esdot.lib.utils
{
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.data.Fonts;
	
	import swc.textField;
	import swc.textField1942;
	import swc.textFieldBallpark;
	import swc.textFieldBold;
	import swc.textFieldChopin;
	import swc.textFieldCollege;
	import swc.textFieldCursive;
	import swc.textFieldHacker;
	import swc.textFieldLondon;
	import swc.textFieldLove;
	import swc.textFieldOriel;
	import swc.textFieldScorched;

	public class TextFields
	{
		public static function getRegular(size:int = 18, color:int = 0x0, align:String = null):TextField {
			var instance:TextField = new swc.textField().instance;
			return formatText(instance, size, color, align);
		}
		
		public static function getBold(size:int = 18, color:int = 0x0, align:String = ""):TextField {
			var instance:TextField = new swc.textFieldBold().instance;
			return formatText(instance, size, color, align, true);
		}
		
		public static function formatText(instance:TextField, size:int = 18, color:int = 0x0, align:String = null, bold:Boolean = false):TextField {
			var tf:TextFormat = instance.defaultTextFormat;
			tf.align = align || TextFormatAlign.LEFT;
			tf.color = color;
			tf.size = size;
			tf.bold = bold;
			
			instance.selectable = false;
			instance.mouseEnabled = false;
			instance.cacheAsBitmap = true;
			instance.height = size * 1.25;
			instance.width = 1;
			instance.setTextFormat(tf);
			instance.defaultTextFormat = tf;
			instance.text = "";
			return instance;
		}
		
		public static function getCursive(size:int = 18, color:int = 0x0, align:String = ""):TextField {
			var instance:TextField = new swc.textFieldCursive().instance;
			return formatText(instance, size, color, align, true);
		}
		
		public static function getCollege(size:int = 18, color:int = 0x0, align:String = ""):TextField {
			var instance:TextField = new swc.textFieldCollege().instance;
			return formatText(instance, size, color, align, true);
			MainView.instance.addChild(new swc.textFieldCollege());
		}
		
		public static function getLove(size:int = 18, color:int = 0x0, align:String = ""):TextField {
			var instance:TextField = new swc.textFieldLove().instance;
			return formatText(instance, size, color, align, true);
		}
		
		public static function getHacker(size:int = 18, color:int = 0x0, align:String = ""):TextField {
			var instance:TextField = new swc.textFieldHacker().instance;
			return formatText(instance, size, color, align, true);
		}
		
		public static function getScript(size:int = 18, color:int = 0x0, align:String = ""):TextField {
			var instance:TextField = new swc.textFieldChopin().instance;
			return formatText(instance, size, color, align, true);
		}
		
		public static function getScorched(size:int = 18, color:int = 0x0, align:String = ""):TextField {
			var instance:TextField = new swc.textFieldScorched().instance;
			return formatText(instance, size, color, align, true);
		}
		
		public static function get1942(size:int = 18, color:int = 0x0, align:String = ""):TextField {
			var instance:TextField = new swc.textField1942().instance;
			return formatText(instance, size, color, align, true);
		}
		
		public static function getOriel(size:int = 18, color:int = 0x0, align:String = ""):TextField {
			var instance:TextField = new swc.textFieldOriel().instance;
			return formatText(instance, size, color, align, true);
		}
		
		public static function getLondon(size:int = 18, color:int = 0x0, align:String = ""):TextField {
			var instance:TextField = new swc.textFieldLondon().instance;
			return formatText(instance, size, color, align, true);
		}
		
		public static function getBallpark(size:int = 18, color:int = 0x0, align:String = ""):TextField {
			var instance:TextField = new swc.textFieldBallpark().instance;
			return formatText(instance, size, color, align, true);
		}
		
		public static function applyFontByName(textField:TextField, value:String):void {
			var tf:TextFormat = textField.defaultTextFormat;
			tf.font = TextFields.getRegular().defaultTextFormat.font;
			var newTf:TextFormat;
			switch(value){
				case Fonts.REGULAR:
					tf.bold = false;
					break;
				
				case Fonts.BOLD:
					tf.bold = true;
					break;
				
				case Fonts.CURSIVE:
					tf.font = TextFields.getCursive().defaultTextFormat.font;
					break;
				
				case Fonts.COLLEGE:
					tf.font = TextFields.getCollege().defaultTextFormat.font;
					break;
				/*
				case Fonts.COMICS:
					tf.font = TextFields.getComic().defaultTextFormat.font;
					break;
				
				case Fonts.NEWS:
					tf.font = TextFields.getNews().defaultTextFormat.font;
					break;
				*/
				case Fonts.LOVE:
					tf.font = TextFields.getLove().defaultTextFormat.font;
					break;
				
				case Fonts.HACKER:
					tf.font = TextFields.getHacker().defaultTextFormat.font;
					break;
				
				case Fonts.FANCY:
					tf.font = TextFields.getScript().defaultTextFormat.font;
					break;
				
				case Fonts.SCORCHED_EARTH:
					tf.font = TextFields.getScorched().defaultTextFormat.font;
					break;
				
				case Fonts.REPORT_1942:
					tf.font = TextFields.get1942().defaultTextFormat.font;
					break;
				
				case Fonts.ORIEL:
					tf.font = TextFields.getOriel().defaultTextFormat.font;
					break;
				
				case Fonts.OLD_LONDON:
					tf.font = TextFields.getLondon().defaultTextFormat.font;
					break;
				
				case Fonts.BALLPARK:
					tf.font = TextFields.getBallpark().defaultTextFormat.font;
					break;
			}
			textField.setTextFormat(tf);
			textField.defaultTextFormat = tf;
		}
		
	}
}
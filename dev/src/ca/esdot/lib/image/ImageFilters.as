package ca.esdot.lib.image
{
	import com.hurlant.crypto.symmetric.NullPad;
	import com.quasimondo.geom.ColorMatrix;
	//import com.vitapoly.nativeextensions.coreimage.ImageFilter;
	
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.geom.ColorTransform;

	public class ImageFilters
	{
		public static const LOMO:String = "Lomo";
		public static const LOMO2:String = "Lomo 2";
		public static const VINTAGE:String = "Vintage";
		
		public static var GO_PRO:String = "Pro-X2";
		public static var TEXTURE:String = "Textures";
		public static var NOISE:String = "Noise";
		
		public static const ROMA:String = "Roma";
		public static const FAIRA:String = "Faira";
		public static const MORA:String = "Mora";
		public static const WAKE:String = "Awake";
		public static const HUSK:String = "Husk";
		
		public static const BW:String = "B & W";
		public static const SEPIA:String = "Sepia";
		public static const SEPIA_GREEN:String = "Sepia (Green)";
		public static const SEPIA_RED:String = "Sepia (Red)";
		public static const HIGH_CONTRAST:String = "Intense";
		public static const LOW_SATURATION:String = "Low Color";
		public static const HIGH_SATURATION:String = "High Color";
		public static const STRONG_RED:String = "Red Pop";
		public static const DEEP_PURPLE:String = "Deep Purple";
		public static const STRONG_BLUE:String = "Blue Pop";
		public static const STRONG_YELLOW:String = "Super Rich";
		public static const DARK_POP:String = "Dark Pop";
		
		public static const INVERT:String = "Negative";
		public static const EMBOSS:String = "Emboss";
		public static const RIPPLE:String = "Ripple	";
	
		public static function apply(effect:String, target:BitmapData, source:BitmapData, strength:Number = .85, blendMode:String = null):void {
			
			switch(effect) {
				case BW:
					ImageProcessing.blackAndWhite(target, source, strength);
					break;
				
				case SEPIA:
					//if(CoreImage.instance){
						//var filter:ImageFilter = new ImageFilter(true);
						//filter.setInput(target);
						//filter.sepiaTone(strength);
						//filter.render(target.rect, target);
					//} else {
						ImageProcessing.sepia(target, 10 + strength * 30, .33, 20);
					//}
					break;
				
				case GO_PRO:
					
					var c:Number = .2;//.6 + strength * .1;
					var colorMatrix:ColorMatrix = new ColorMatrix();
					colorMatrix.adjustContrast(c, c, c);
					colorMatrix.adjustBrightness(-20, -20, -20);
					target.applyFilter(source, target.rect, target.rect.topLeft, colorMatrix.filter);
					
					TextureFilters.apply(TextureFilters.VIGNETTE_BLUE, target, .15 + .25 * strength, BlendMode.OVERLAY);
					TextureFilters.apply(TextureFilters.VIGNETTE, target, .1 + strength * .1);
					
					break;
				
				
				case WAKE:
					var colorMatrix:ColorMatrix = new ColorMatrix();
					
					var b:Number = -.1 * strength;
					var c:Number = .5 + .3 * strength;
					var s:Number = .8 - .3 * strength;
					colorMatrix.adjustBrightness(b, b, b);
					colorMatrix.adjustContrast(c, c, c);
					colorMatrix.adjustSaturation(s);
					target.applyFilter(source, target.rect, target.rect.topLeft, colorMatrix.filter);
					
					var ct:ColorTransform = new ColorTransform(1, 1, 1, .15 + .1 * strength);
					var yellow:BitmapData = new BitmapData(target.width, target.height, false, 0xffa311);
					target.draw(yellow, null, ct);
					TextureFilters.apply(TextureFilters.VIGNETTE, target, .15 + strength * .35);
					TextureFilters.apply(TextureFilters.SHINE, target, .2 * strength, BlendMode.NORMAL);
					break;
				
				
				case HUSK:
					var colorMatrix:ColorMatrix = new ColorMatrix();
					//colorMatrix.adjustBrightness(-.5, -.5, 1);
					//colorMatrix.adjustContrast(0, -(strength), (strength));
					//colorMatrix.adjustHue(strength * 360);
					//target.applyFilter(source, target.rect, target.rect.topLeft, colorMatrix.filter);
					
					TextureFilters.apply(TextureFilters.VIGNETTE_BLUE, target, .25 + .35 * strength, BlendMode.OVERLAY);
					TextureFilters.apply(TextureFilters.NOISE, target, .25 + .35 * strength, BlendMode.OVERLAY);
					//ImageProcessing.adjustSaturation(.8, target);
					//ImageProcessing.adjustContrast(target, source, .9 + strength * .2);
					break;
				
				case MORA:
					
					/*
					* RISE
					* + Brightness 
					* + Contrast
					* + R/G sat, -B sat
					*/
					ImageProcessing.popYellow(target, source, strength);
					TextureFilters.apply(TextureFilters.SHINE, target, .35 + strength * .55, BlendMode.NORMAL);
					
					var colorMatrix:ColorMatrix = new ColorMatrix();
					colorMatrix.adjustContrast(.1 * strength, .1 * strength, .1 * strength);
					colorMatrix.adjustBrightness( 5 + 10 * strength, 5 + 10 * strength, 5 + 10 * strength);
					target.applyFilter(target, target.rect, target.rect.topLeft, colorMatrix.filter);
					
					break;
				
				case FAIRA:
					
					/* MAYFAIR
						
						+ Deep Purple
						+ Vignette
						+ Saturation
					*/
					ImageProcessing.popPurple(target, source, strength * .35);
					var colorMatrix:ColorMatrix = new ColorMatrix();
					colorMatrix.adjustSaturation(1 + .1 * strength);
					target.applyFilter(target, target.rect, target.rect.topLeft, colorMatrix.filter);
					TextureFilters.apply(TextureFilters.NOISE, target, .5, BlendMode.OVERLAY);
					break;
				
				case ROMA:
					/*
					+Brightness 75%
					+Contrast 90%
					-Sat 70%
					+Brightness Auto-Correct
					+Vignette
					*/
					var colorMatrix:ColorMatrix = new ColorMatrix();
					var c:Number = .2 + .2 * strength;
					colorMatrix.adjustContrast(c, c, c);
					var b:Number = -(5 + 10 * strength);
					colorMatrix.adjustBrightness(b, b, b);
					colorMatrix.adjustSaturation(1.02 + .03 * strength);
					target.applyFilter(target, target.rect, target.rect.topLeft, colorMatrix.filter);
					
					//ImageProcessing.autoContrast(target);
					//ImageProcessing.autoBrightness(target);
					
					//TextureFilters.apply(TextureFilters.VIGNETTE, target, .15 + strength * .35);
					TextureFilters.apply(TextureFilters.SHINE, target, .2 + .1 * strength, BlendMode.NORMAL);
					TextureFilters.apply(TextureFilters.NOISE, target, .35, BlendMode.OVERLAY);
					
					break;
				
				case LOMO:
					var colorMatrix:ColorMatrix = new ColorMatrix();
					colorMatrix.adjustContrast(0, .5, -.15);
					colorMatrix.adjustContrast(.05 + strength/3, .05 + strength/3, .05 + strength/3);
					colorMatrix.adjustSaturation(.5);
					colorMatrix.adjustBrightness(10 + strength * 10);
					target.applyFilter(target, target.rect, target.rect.topLeft, colorMatrix.filter);
					
					TextureFilters.apply(TextureFilters.NOISE, target, .25, BlendMode.OVERLAY);
					//TextureFilters.apply(TextureFilters.VIGNETTE, target, .15 + strength * .55);
					
					break;
				
				case LOMO2:
					ImageProcessing.popGreen(target, source, strength * .5);
					TextureFilters.apply(TextureFilters.SHINE, target, .25, BlendMode.NORMAL);
					TextureFilters.apply(TextureFilters.VIGNETTE, target, .05 + strength * .25);
					TextureFilters.apply(TextureFilters.NOISE, target, .65, BlendMode.OVERLAY);
					break;
				
				case VINTAGE:
					ImageProcessing.vintage(target, .85 * strength, .25 * strength, 1.5 * strength);
					break;
				
				case HIGH_CONTRAST:
					ImageProcessing.highContrast(target, source, strength);
					break;
				
				case HIGH_SATURATION:
					ImageProcessing.highSaturation(target, source, strength);
					break;
				
				case LOW_SATURATION:
					ImageProcessing.lowSaturation(target, source, strength);
					break;
				
				case STRONG_RED:
					ImageProcessing.popRed(target, source, strength);
					break;
				
				case DEEP_PURPLE:
					ImageProcessing.popGreen(target, source, strength);
					break;
				
				case STRONG_BLUE:
					ImageProcessing.popBlue(target, source, strength);
					break;
				
				case STRONG_YELLOW:
					ImageProcessing.popYellow(target, source, strength);
					break;
				
				case DARK_POP:
					ImageProcessing.popPurple(target, source, strength);
					break;
				
				case EMBOSS:
					ImageProcessing.emboss(target);
					break;
				
				case INVERT:
					ImageProcessing.invert(target);
					break;
				
				
			}
		}
		/*
		
		public static function coffeeStain(target:BitmapData, strength:Number = .5, blendMode:String = null):void {
			if(!blendMode){ blendMode = BlendMode.OVERLAY; }
			
			var bitmap:Bitmap = new Bitmaps.CoffeStain();
			
			ImageProcessing.adjustContrast(bitmap.bitmapData, bitmap.bitmapData, 1- strength);
			
			var matrix:Matrix = new Matrix();
			var scale:Number = target.width/bitmap.width;
			
			if(target.width < target.height){
				scale = target.height / bitmap.height;
			}
			matrix.scale(scale, scale);
			//center
			matrix.translate(target.width - (bitmap.width * scale), target.height - (bitmap.height * scale));
			target.draw(bitmap, matrix, new ColorTransform(1, 1, 1, strength), blendMode, null, true);
		}
		
		public static function spill(target:BitmapData, strength:Number = .5, blendMode:String = null):void {
			if(!blendMode){ blendMode = BlendMode.OVERLAY; }
			var bitmap:Bitmap = new Spill();
			
			ImageProcessing.adjustContrast(bitmap.bitmapData, bitmap.bitmapData, 1- strength);
			var matrix:Matrix = new Matrix();
			matrix.scale(target.width/bitmap.width, target.height / bitmap.height);
			target.draw(bitmap, matrix, new ColorTransform(1, 1, 1, strength), blendMode, null, true);
			
		}
		
		public static function vignette(target:BitmapData, strength:Number = .5, blendMode:String = null):void {
			if(!blendMode){ blendMode = BlendMode.OVERLAY; }
			var bitmap:Bitmap = new Vignette();
			
			ImageProcessing.adjustContrast(bitmap.bitmapData, bitmap.bitmapData, 1- strength);
			var matrix:Matrix = new Matrix();
			matrix.scale(target.width/bitmap.width, target.height / bitmap.height);
			target.draw(bitmap, matrix, new ColorTransform(1, 1, 1, strength), BlendMode.MULTIPLY, null, true);
		}
		
		public static function spyCam(target:BitmapData, strength:Number = .5):void {
			var bitmap:Bitmap = new SpyCam();
			
			var matrix:Matrix = new Matrix();
			var scaleX:Number = target.width/bitmap.width;
			var scaleY:Number = target.height/bitmap.height;
			
			matrix.scale(scaleX, scaleY);
			
			target.draw(bitmap, matrix, new ColorTransform(1, 1, 1, strength), BlendMode.OVERLAY, null, true);
		}
		*/
	}
}
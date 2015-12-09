package ca.esdot.lib.image
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.PixelSnapping;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;

	public class TextureFilters
	{
		[Embed(source="/assets/filters/vignette.jpg")]
		public static var Vignette:Class; 
		
		[Embed(source="/assets/filters/vignette-blue.jpg")]
		public static var VignetteBlue:Class; 
		
		[Embed(source="/assets/filters/shine.png")]
		public static var Shine:Class; 
		
		[Embed(source="/assets/filters/noise.gif")]
		public static var Noise:Class; 
		
		[Embed(source="/assets/filters/coffeeStain.png")]
		public static var CoffeStain:Class; 
		
		[Embed(source="/assets/filters/spyCam.png")]
		public static var SpyCam:Class; 
		
		[Embed(source="/assets/filters/spill.png")]
		public static var Spill:Class; 
		
		[Embed(source="/assets/filters/agedPaper.jpg")]
		public static var AgedPaper:Class; 
		
		[Embed(source="/assets/filters/creasedPaper.jpg")]
		public static var CreasedPaper:Class; 
		
		[Embed(source="/assets/filters/dirty.jpg")]
		public static var Dirty:Class; 
		
		[Embed(source="/assets/filters/dirty2.jpg")]
		public static var Dirty2:Class; 
		
		[Embed(source="/assets/filters/inkRoller.jpg")]
		public static var InkRoller:Class; 
		
		[Embed(source="/assets/filters/paintDrops.jpg")]
		public static var PaintDrops:Class; 
		
		protected static var textureCache:Object = {};
		
		public static const VIGNETTE:String = "Vignette";
		public static const VIGNETTE_BLUE:String = "Blue Vignette";
		public static const NOISE:String = "Noise";
		public static const SHINE:String = "Shine";
		public static const COFFEE_STAIN:String = "Coffee Stain";
		public static const AGED_PAPER:String = "Aged Paper";
		public static const CREASED_PAPER:String = "Creased Paper";
		public static const DIRT:String = "Dirt";
		public static const SLUDGE:String = "Sludge";
		public static const PAINT:String = "Paint";
		public static var SPY_CAM:String = "Spy Cam";
		public static var SPILL:String = "Spill";
		public static var INK_ROLLER:String = "Ink Roller";
		
		public static function apply(type:String, target:BitmapData, strength:Number = .5, blendMode:String = null, maintainAspectRatio:Boolean = false):void {
			if(!blendMode){ blendMode = BlendMode.MULTIPLY; }
			
			var bitmap:Bitmap;
			if(textureCache[type]){
				bitmap = new Bitmap(textureCache[type], PixelSnapping.AUTO, true);
			} else {
				switch(type){
					
					case VIGNETTE: bitmap = new Vignette(); break;
					case VIGNETTE_BLUE: bitmap = new VignetteBlue(); break;
					case SHINE: bitmap = new Shine(); break;
					case NOISE: bitmap = new Noise(); break;
					case AGED_PAPER: bitmap = new AgedPaper(); break;
					case COFFEE_STAIN: bitmap = new CoffeStain(); break;
					case CREASED_PAPER: bitmap = new CreasedPaper(); break;
					case DIRT: bitmap = new Dirty(); break;
					case SLUDGE: bitmap = new Dirty2(); break;
					case PAINT: bitmap = new PaintDrops(); break;
					case SPY_CAM: bitmap = new SpyCam(); break;
					case SPILL: bitmap = new Spill(); break;
					case INK_ROLLER: bitmap = new InkRoller(); break;
				}
				textureCache[type] = bitmap.bitmapData;
				trace("Create: ", bitmap);
			}
			
			
			//Apply Strength / Alpha
			//var data:BitmapData = bitmap.bitmapData.clone();
			//ImageProcessing.adjustContrast(bitmap.bitmapData, bitmap.bitmapData, 1 - strength);
			var color:ColorTransform = new ColorTransform(1, 1, 1, strength);
			
			//Scale and draw
			var matrix:Matrix = new Matrix();
			//Just stretch to match...
			if(!maintainAspectRatio){
				matrix.scale(target.width/bitmap.width, target.height / bitmap.height);
			} 
			//Scale and center, maintainAspectRatio
			else {
				var scale:Number = Math.max(target.width/bitmap.width, target.height / bitmap.height);
				matrix.scale(scale, scale);
				matrix.translate(target.width - (bitmap.width * scale), target.height - (bitmap.height * scale));
			}
			
			target.draw(bitmap, matrix, color, blendMode, null, true);
		}
	}
}
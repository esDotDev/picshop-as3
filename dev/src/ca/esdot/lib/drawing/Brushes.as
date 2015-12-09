package ca.esdot.lib.drawing
{
	import ca.esdot.lib.display.MobileSprite;
	import ca.esdot.lib.drawing.brushes.AbstractBrush;
	import ca.esdot.lib.drawing.brushes.ChromeBrush;
	import ca.esdot.lib.drawing.brushes.CirclesBrush;
	import ca.esdot.lib.drawing.brushes.FanBrush;
	import ca.esdot.lib.drawing.brushes.FurBrush;
	import ca.esdot.lib.drawing.brushes.GridBrush;
	import ca.esdot.lib.drawing.brushes.LongFurBrush;
	import ca.esdot.lib.drawing.brushes.RibbonBrush;
	import ca.esdot.lib.drawing.brushes.ShadedBrush;
	import ca.esdot.lib.drawing.brushes.SimpleBrush;
	import ca.esdot.lib.drawing.brushes.SketchyBrush;
	import ca.esdot.lib.drawing.brushes.SquaresBrush;
	import ca.esdot.lib.drawing.brushes.WebBrush;
	import ca.esdot.lib.utils.DeviceUtils;
	
	import flash.display.Sprite;
	import flash.display.Stage;

	public class Brushes
	{
		public static var SIMPLE:String = "Normal";
		
		public static var CHROME:String = "Chrome";
		public static var CIRCLES:String = "Circles";
		public static var FAN:String = "Fan";
		public static var FUR:String = "Fur";
		public static var GRID:String = "Grid";
		public static var LONG_FUR:String = "Long";
		public static var RIBBON:String = "Ribbon";
		public static var SHADED:String = "Shaded";
		public static var SKETCHY:String = "Sketchy";
		public static var SQUARES:String = "Squares";
		public static var WEB:String = "Web";
		
		
		public static function getBrush(value:String, canvas:Sprite, stage:Stage):AbstractBrush {
			var brush:AbstractBrush;
			var thickness:int = 5 * DeviceUtils.screenScale;
			
			switch(value){
				case SIMPLE:
					brush = new SimpleBrush(canvas);
					brush.style.thickness = thickness;
					break;
				
				case CHROME:
					brush = new ChromeBrush(canvas); 
					break;
				
				case CIRCLES:
					brush = new CirclesBrush(canvas); 
					break;
				
				case FAN:
					brush = new FanBrush(canvas, stage.width / 2, stage.height); 
					break;
				
				case GRID:
					brush = new GridBrush(canvas); 
					break;
				
				case FUR:
					brush = new FurBrush(canvas); 
					break;
				
				case LONG_FUR:
					brush = new LongFurBrush(canvas); 
					break;
				
				case RIBBON:
					brush = new RibbonBrush(canvas, stage.width / 2, stage.height); 
					break;
				
				case SHADED:
					brush = new ShadedBrush(canvas); 
					break;
				
				case SKETCHY:
					brush = new SketchyBrush(canvas); 
					break;
				
				case SQUARES:
					brush = new SquaresBrush(canvas, 0x0); 
					break;
				
				case WEB:
					brush = new WebBrush(canvas); 
					break;
			}
			return brush;
		}
	}
}
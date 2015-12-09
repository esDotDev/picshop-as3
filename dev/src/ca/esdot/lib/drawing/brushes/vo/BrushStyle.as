package ca.esdot.lib.drawing.brushes.vo
{
	/**
	 * based on Mr. Doob Harmony Application
	 * https://github.com/mrdoob/harmony (licens GPL Version 3)
	 * 
	 * @author Florian Weil [derhess.de, Deutschland]
	 * @see http://blog.derhess.de
	 * 
	 */
	public class BrushStyle
	{
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		public var red:uint;
		public var green:uint;
		public var blue:uint;
		
		public var thickness:Number;
		public var color:uint;
		public var alpha:Number;
		public var pixelHinting:Boolean; 
		public var scaleMode:String;
		public var caps:String; 
		public var joints:String; 
		public var miterLimit:Number;
		
		//--------------------------------------------------------------------------
		//
		//  Initialization
		//
		//--------------------------------------------------------------------------
		public function BrushStyle()
		{
			thickness = 1;
			color = 0x000000;
			red = 0;
			green = 0;
			blue = 0;
			alpha = 1.0;
			pixelHinting= false; 
			scaleMode = "normal";
			caps = null; 
			joints = null; 
			miterLimit = 3;
			
		}
		//--------------------------------------------------------------------------
		//
		//  Additional getters and setters
		//
		//--------------------------------------------------------------------------
		public function setRGBColor(redValue:uint, greenValue:uint, blueValue:uint):void
		{
			red = redValue;
			green = greenValue;
			blue = blueValue;
			color = red<<16 | green<<8 | blue;
		}
		
		public function setHexColor(value:uint):void
		{
			color = value;
			red = (color >> 16) & 0xFF;
			green = (color >> 8) & 0xFF;
			blue = (color >> 16) & 0xFF;
		}
		//--------------------------------------------------------------------------
		//
		//  API
		//
		//--------------------------------------------------------------------------
		public function copy():BrushStyle
		{
			var copyStyle:BrushStyle = new BrushStyle();
			copyStyle.thickness = this.thickness;
			copyStyle.color = this.color;
			copyStyle.red = this.red;
			copyStyle.green = this.green;
			copyStyle.blue = this.blue;
			copyStyle.alpha = this.alpha;
			copyStyle.pixelHinting= this.pixelHinting; 
			copyStyle.scaleMode = this.scaleMode;
			copyStyle.caps = this.caps; 
			copyStyle.joints = this.joints; 
			copyStyle.miterLimit = this.miterLimit;
			return copyStyle;
		}
	}
}
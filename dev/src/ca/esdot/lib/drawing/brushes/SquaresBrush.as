package ca.esdot.lib.drawing.brushes
{
	import ca.esdot.lib.drawing.brushes.vo.BrushPoint;
	import ca.esdot.lib.drawing.brushes.vo.BrushStyle;
	
	import flash.display.Sprite;
	import flash.geom.Point;
	
	/**
	 * based on Mr. Doob Harmony Application
	 * https://github.com/mrdoob/harmony (licens GPL Version 3)
	 * 
	 * @author Florian Weil [derhess.de, Deutschland]
	 * @see http://blog.derhess.de
	 * 
	 */
	public class SquaresBrush extends AbstractBrush implements IBrush
	{
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		private var prevMouseX:int;
		private var prevMouseY:int;
		//--------------------------------------------------------------------------
		//
		//  Initialization
		//
		//--------------------------------------------------------------------------
		public function SquaresBrush(canvas:Sprite,bgColorValue:uint = 0xFFFFFF)
		{
			super(canvas);
			bgColor = bgColorValue;
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		/** @private */
		private var _bgColor:uint;
		/**
		 * fill color for the squares
		 */
		public function get bgColor():uint
		{
			return _bgColor;	
		}
		public function set bgColor(value:uint):void
		{
			_bgColor = value;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Additional getters and setters
		//
		//--------------------------------------------------------------------------
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		//--------------------------------------------------------------------------
		//
		//  API
		//
		//--------------------------------------------------------------------------
		public function init():void
		{
			
		}
		
		
		public function destroy():void
		{
			
		}
		
		public function strokeStart(mouseX:int, mouseY:int):void 
		{
			this.prevMouseX = mouseX;
			this.prevMouseY = mouseY;
		}
		
		public function stroke(mouseX:int, mouseY:int):void
		{
			var dx:int, dy:int;
			var angle:Number, px:Number, py:Number;
			
			dx = mouseX - this.prevMouseX;
			dy = mouseY - this.prevMouseY;
			angle = 1.57079633;
			px = Math.cos(angle) * dx - Math.sin(angle) * dy;
			py = Math.sin(angle) * dx + Math.cos(angle) * dy;
			
			var tStyle:BrushStyle = super.style;
			tStyle.alpha = this.pressure;
			super.target.graphics.lineStyle(tStyle.thickness, tStyle.color, tStyle.alpha, tStyle.pixelHinting, tStyle.scaleMode,tStyle.caps,tStyle.joints ,tStyle.miterLimit);
			this.target.graphics.beginFill(bgColor);
			this.target.graphics.moveTo(this.prevMouseX - px, this.prevMouseY - py);
			this.target.graphics.lineTo(this.prevMouseX + px, this.prevMouseY + py);
			this.target.graphics.lineTo(mouseX + px, mouseY + py);
			this.target.graphics.lineTo(mouseX - px, mouseY - py);
			this.target.graphics.lineTo(this.prevMouseX - px, this.prevMouseY - py);
			this.target.graphics.endFill();
			
			
			this.prevMouseX = mouseX;
			this.prevMouseY = mouseY;
		}
		
		public function strokeEnd():void
		{
			
		}
		
		//--------------------------------------------------------------------------
		//
		//  Eventhandling
		//
		//--------------------------------------------------------------------------
		
		
		//--------------------------------------------------------------------------
		//
		//  Broadcasting
		//
		//--------------------------------------------------------------------------
		
		
	}
}
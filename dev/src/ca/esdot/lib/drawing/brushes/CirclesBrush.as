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
	public class CirclesBrush extends AbstractBrush implements IBrush
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
		public function CirclesBrush(canvas:Sprite)
		{
			super(canvas);
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		
		
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
			var i:int, dx:int, dy:int, d:int, cx:int, cy:int, steps:int, step_delta:int;

			var tStyle:BrushStyle = super.style;
			tStyle.alpha = 0.1 * this.pressure;
			super.target.graphics.lineStyle(tStyle.thickness, tStyle.color, tStyle.alpha, tStyle.pixelHinting, tStyle.scaleMode,tStyle.caps,tStyle.joints ,tStyle.miterLimit);
			
			dx = mouseX - this.prevMouseX;
			dy = mouseY - this.prevMouseY;
			d = Math.sqrt(dx * dx + dy * dy) * 2;
			
			cx = Math.floor(mouseX / 100) * 100 + 50;
			cy = Math.floor(mouseY / 100) * 100 + 50;
			
			steps = Math.floor( Math.random() * 10 );
			step_delta = d / steps;
			
			for (i = 0; i < steps; i++)
			{
				this.target.graphics.drawCircle(cx,cy,(steps - i) * step_delta);
			}
			
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
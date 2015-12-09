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
	public class ShadedBrush extends AbstractBrush implements IBrush
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
		private var points:Vector.<BrushPoint>;
		private var count:uint;
		private var secondStyle:BrushStyle;
		
		
		//--------------------------------------------------------------------------
		//
		//  Initialization
		//
		//--------------------------------------------------------------------------
		public function ShadedBrush(canvas:Sprite)
		{
			super(canvas);
			this.points = new Vector.<BrushPoint>();
			this.count = 0;
			secondStyle = super.style.copy();
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
			this.points = new Vector.<BrushPoint>();
			this.count = 0;
			secondStyle = super.style.copy();
		}
		
		public function destroy():void
		{
			this.points = null;
			this.count = 0;
			secondStyle = null;
		}
		
		public function strokeStart(mouseX:int, mouseY:int):void 
		{
			this.prevMouseX = mouseX;
			this.prevMouseY = mouseY;
		}
		
		public function stroke(mouseX:int, mouseY:int):void
		{
			var i:int, dx:int, dy:int, d:int;
			
			this.points.push(new BrushPoint(mouseX, mouseY));
			
			var tStyle:BrushStyle = super.style;
			
			for (i = 0; i < this.points.length; i++)
			{
				dx = this.points[i].x - this.points[this.count].x;
				dy = this.points[i].y - this.points[this.count].y;
				d = dx * dx + dy * dy;
				
				if (d < 1000)
				{
					secondStyle.alpha = ((1 - (d / 1000)) * 0.1 * this.pressure);
					secondStyle.color = tStyle.color;
					super.target.graphics.lineStyle(secondStyle.thickness,secondStyle.color, secondStyle.alpha, secondStyle.pixelHinting, secondStyle.scaleMode,secondStyle.caps,secondStyle.joints ,secondStyle.miterLimit);
					this.target.graphics.moveTo( this.points[this.count].x, this.points[this.count].y);
					this.target.graphics.lineTo( this.points[i].x, this.points[i].y);
				}
			}
			this.prevMouseX = mouseX;
			this.prevMouseY = mouseY;
			
			this.count++;
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
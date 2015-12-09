package ca.esdot.lib.drawing.brushes
{
	import ca.esdot.lib.drawing.brushes.vo.BrushPoint;
	import ca.esdot.lib.drawing.brushes.vo.BrushStyle;
	
	import flash.display.Sprite;
	import flash.geom.Point;

	public class ChromeBrush extends AbstractBrush implements IBrush
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
		public function ChromeBrush(canvas:Sprite)
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
			tStyle.alpha = 0.1 * this.pressure;
			super.target.graphics.lineStyle(tStyle.thickness, tStyle.color, tStyle.alpha, tStyle.pixelHinting, tStyle.scaleMode,tStyle.caps,tStyle.joints ,tStyle.miterLimit);
			
			this.target.graphics.moveTo(this.prevMouseX, this.prevMouseY);
			this.target.graphics.lineTo(mouseX, mouseY);
			
			for (i = 0; i < this.points.length; i++)
			{
				dx = this.points[i].x - this.points[this.count].x;
				dy = this.points[i].y - this.points[this.count].y;
				d = dx * dx + dy * dy;
				
				if (d < 1000)
				{
					secondStyle.alpha = 0.1 * this.pressure;
					secondStyle.setRGBColor(Math.floor(Math.random() * tStyle.red),Math.floor(Math.random() * tStyle.green), Math.floor(Math.random() * tStyle.blue));
					super.target.graphics.lineStyle(secondStyle.thickness,secondStyle.color, secondStyle.alpha, secondStyle.pixelHinting, secondStyle.scaleMode,secondStyle.caps,secondStyle.joints ,secondStyle.miterLimit);
					this.target.graphics.moveTo( this.points[this.count].x + (dx * 0.2), this.points[this.count].y + (dy * 0.2));
					this.target.graphics.lineTo( this.points[i].x - (dx * 0.2), this.points[i].y - (dy * 0.2));
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
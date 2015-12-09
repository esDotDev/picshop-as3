package ca.esdot.lib.drawing.brushes
{
	import ca.esdot.lib.drawing.brushes.vo.BrushPoint;
	import ca.esdot.lib.drawing.brushes.vo.BrushStyle;
	import ca.esdot.lib.utils.DeviceUtils;
	
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
	public class WebBrush extends AbstractBrush implements IBrush
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
		public function WebBrush(canvas:Sprite)
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
			tStyle.alpha = 0.5 * this.pressure;
			super.target.graphics.lineStyle(tStyle.thickness * DeviceUtils.screenScale, tStyle.color, tStyle.alpha, tStyle.pixelHinting, tStyle.scaleMode,tStyle.caps,tStyle.joints ,tStyle.miterLimit);
			
			this.target.graphics.moveTo(this.prevMouseX, this.prevMouseY);
			this.target.graphics.lineTo(mouseX, mouseY);
			secondStyle.alpha = 0.2 * this.pressure;
			secondStyle.color = tStyle.color;
			
			for (i = 0; i < this.points.length; i++)
			{
				dx = this.points[i].x - this.points[this.count].x;
				dy = this.points[i].y - this.points[this.count].y;
				d = dx * dx + dy * dy;
				
				if (d < 2500 * DeviceUtils.screenScale && Math.random() > 0.9)
				{
					super.target.graphics.lineStyle(secondStyle.thickness * DeviceUtils.screenScale,secondStyle.color, secondStyle.alpha, secondStyle.pixelHinting, secondStyle.scaleMode,secondStyle.caps,secondStyle.joints ,secondStyle.miterLimit);
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
package ca.esdot.lib.drawing.brushes
{
	import ca.esdot.lib.drawing.brushes.vo.BrushPoint;
	import ca.esdot.lib.drawing.brushes.vo.BrushStyle;
	import ca.esdot.lib.drawing.brushes.vo.RibbonPainter;
	
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	/**
	 * based on Mr. Doob Harmony Application
	 * https://github.com/mrdoob/harmony (licens GPL Version 3)
	 * 
	 * FanBrush was created during some mistakes of porting the Ribbon Brush.
	 * I like the style of this brush and for this reason I created this class
	 * 
	 * @author Florian Weil [derhess.de, Deutschland]
	 * @see http://blog.derhess.de
	 * 
	 */
	public class FanBrush extends AbstractBrush implements IBrush
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
		private var mouseXpos:int;
		private var mouseYpos:int;
		private var painters:Vector.<RibbonPainter>;
		private var timer:Timer;
		private var width:int;
		private var height:int;
		//--------------------------------------------------------------------------
		//
		//  Initialization
		//
		//--------------------------------------------------------------------------
		public function FanBrush(canvas:Sprite,widthVal:int,heightVal:int)
		{
			super(canvas);
			this.width = widthVal;
			this.height = heightVal;
			this.mouseXpos = this.width / 2;
			this.mouseYpos = this.height / 2;
			this.painters = new Vector.<RibbonPainter>();
			
			for (var i:int = 0; i < 50; i++)
			{
				this.painters.push(new RibbonPainter( this.width/2, this.height/2, 0, 0, 0.1, Math.random() * 0.2 + 0.6));
			}
			
			this.timer = new Timer(1000/60);
			this.timer.addEventListener(TimerEvent.TIMER,handleTimer,false,0,true);
			// setInterval
			this.timer.start();
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
			this.mouseXpos = this.width / 2;
			this.mouseYpos = this.height / 2;
			this.painters = new Vector.<RibbonPainter>();
			
			for (var i:int = 0; i < 50; i++)
			{
				this.painters.push(new RibbonPainter( this.width/2, this.height/2, 0, 0, 0.1, Math.random() * 0.2 + 0.6));
			}
			
			this.timer = new Timer(1000/60);
			this.timer.addEventListener(TimerEvent.TIMER,handleTimer,false,0,true);
		}
		
		
		public function destroy():void
		{
			this.timer.stop();
			this.timer.removeEventListener(TimerEvent.TIMER,handleTimer);
			this.timer = null;
			
			this.mouseXpos = 0;
			this.mouseYpos = 0;
			this.painters = null;
		}
		
		public function strokeStart(mouseX:int, mouseY:int):void 
		{
			this.mouseXpos = mouseX;
			this.mouseYpos = mouseY
			
			for (var i:int = 0; i < this.painters.length; i++)
			{
				this.painters[i].dx = mouseX;
				this.painters[i].dy = mouseY;
			}
			
			//this.shouldDraw = true; //-> it seems this variable is never used?!
			if(!this.timer.running)
				this.timer.start();
		}
		
		public function stroke(mouseX:int, mouseY:int):void
		{
			this.mouseXpos = mouseX;
			this.mouseYpos = mouseY;
			
		}
		
		public function strokeEnd():void
		{
			this.timer.stop();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Eventhandling
		//
		//--------------------------------------------------------------------------
		private function handleTimer(e:TimerEvent):void
		{
			var i:int;
			
			var tStyle:BrushStyle = super.style;
			tStyle.alpha = 0.05 * this.pressure;
			super.target.graphics.lineStyle(tStyle.thickness, tStyle.color, tStyle.alpha, tStyle.pixelHinting, tStyle.scaleMode,tStyle.caps,tStyle.joints ,tStyle.miterLimit);
			
			for (i = 0; i < this.painters.length; i++)
			{
				this.target.graphics.moveTo(this.painters[i].dx, this.painters[i].dy);
				
				this.painters[i].ax = (this.painters[i].ax + (this.painters[i].dx - this.mouseXpos) * this.painters[i].div) * this.painters[i].ease;
				this.painters[i].dx -= this.painters[i].ax;
				this.painters[i].ay = (this.painters[i].ay + (this.painters[i].dy - this.mouseYpos) * this.painters[i].div) * this.painters[i].ease;
				this.painters[i].dy -= this.painters[i].ay;
				
				this.target.graphics.lineTo(this.mouseXpos, this.mouseYpos);
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Broadcasting
		//
		//--------------------------------------------------------------------------
		
		
	}
}
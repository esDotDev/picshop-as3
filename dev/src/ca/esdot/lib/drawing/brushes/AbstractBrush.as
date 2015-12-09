package ca.esdot.lib.drawing.brushes
{
	import flash.display.Sprite;
	import ca.esdot.lib.drawing.brushes.vo.BrushStyle;
	
	/**
	 * based on Mr. Doob Harmony Application
	 * 
	 * @author Florian Weil [derhess.de, Deutschland]
	 * @see http://blog.derhess.de
	 */
	public class AbstractBrush
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
		
		//--------------------------------------------------------------------------
		//
		//  Initialization
		//
		//--------------------------------------------------------------------------
		public function AbstractBrush(canvas:Sprite = null)
		{
			_target = canvas;
			_style = new BrushStyle();
			_pressure = 1;
		}
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		/** @private */
		private var _target:Sprite;
		/**
		 * the canvas, where the brush draws
		 */
		
		public function get target():Sprite
		{
			return _target;	
		}
		public function set target(value:Sprite):void
		{
			_target = value;
		}
		
		
		/** @private */
		private var _style:BrushStyle;
		
		/**
		 * Brush Style  - define the look and feel of your brush
		 */
		
		public function get style():BrushStyle
		{
			return _style;	
		}
		public function set style(value:BrushStyle):void
		{
			_style = value;
		}
		
		/** @private */
		private var _pressure:Number;
		
		/**
		 * Brush Pressure  - interesting for tablet pen devices (e.g. wacom products) 
		 */
		
		public function get pressure():Number
		{
			return _pressure;	
		}
		public function set pressure(value:Number):void
		{
			_pressure = value;
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
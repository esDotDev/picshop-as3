package ca.esdot.lib.drawing.brushes.vo
{
	public class RibbonPainter
	{
		public var dx:int;
		public var dy:int;
		public var ax:int;
		public var ay:int;
		public var div:Number;
		public var ease:Number;
		
		public function RibbonPainter(dxVal:int, dyVal:int, axVal:int, ayVal:int, divVal:Number, easeVal:Number)
		{
			dx = dxVal;
			dy = dyVal;
			ax = axVal;
			ay = ayVal;
			div = divVal;
			ease = easeVal;;
		}
	}
}
package ca.esdot.lib.drawing.brushes
{
	import flash.display.Sprite;

	public interface IBrush
	{
		function init():void;
		function destroy():void;
		
		function strokeStart(mouseX:int, mouseY:int):void;
		function stroke(mouseX:int, mouseY:int):void;
		function strokeEnd():void;
	}
}
package ca.esdot.lib.display
{
	public interface IBlitClip
	{
		function play():void 
		
		function stop():void 
		
		function gotoAndPlay(frame:Object, loop:Boolean = false):void 
		
		function gotoAndStop(frame:Object):void 
		
		function step():void 
		
		function get currentFrame():int 
		function set currentFrame(value:int):void 
	}
}
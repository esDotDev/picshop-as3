package ca.esdot.lib.effects
{	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class BitmapParticle extends Bitmap 
	{
		public var previousPosition:Point;
		public var velX:Number;
		public var velY:Number;
		public var lifeSpan:Number;
		public var gravity:Number;
		public var decayRate:Number = .05;
		public var index:Number;
		public var prev:Particle = null;
		public var next:Particle = null;
		
		protected var _dying:Boolean;
		protected var pixel:Shape;
		protected var sprite:DisplayObject;
		
		public function BitmapParticle(bitmapData:BitmapData){
			this.bitmapData = bitmapData;
		}
		
		override public function set bitmapData(value:BitmapData):void {
			super.bitmapData = value;
			smoothing = true;
		}
	}
	
}
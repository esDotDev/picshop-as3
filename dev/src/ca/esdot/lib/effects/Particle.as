package ca.esdot.lib.effects
{	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	public class Particle extends Sprite 
	{
		public var previousPosition:Point;
		public var xVel:Number;
		public var yVel:Number;
		public var lifeSpan:Number;
		public var gravity:Number;
		public var decayRate:Number = .05;
		public var index:Number;
		public var prev:Particle = null;
		public var next:Particle = null;
		
		protected var _dying:Boolean;
		protected var pixel:Shape;
		protected var sprite:DisplayObject;

		protected var spriteAsset:Sprite;
		
		public function Particle(){
			pixel = new Shape();
			pixel.graphics.beginFill(0xFFFFFF);
			pixel.graphics.drawRect(0,0,1,1);
			pixel.graphics.endFill();
			
			init();
		}
		
		protected function init():void {
			alpha = 1;
			addChild(pixel);
		}
		
		public function setSprite(SpriteClass:Class):void {
			if(sprite && sprite.parent){ removeChild(sprite); }
			sprite = addChild(new SpriteClass());
			sprite.x = -(sprite.width>>1);
			sprite.y = -(sprite.height>>1);
			if(pixel.parent){ removeChild(pixel); }
		}
		
		public function decay():void {
			lifeSpan -= decayRate;
			if(lifeSpan < .5){
				alpha = (lifeSpan * 2);
			}
		}
		
		public function dispose():void {
			if(sprite && sprite.parent){ removeChild(sprite); }
			if(pixel.parent){ removeChild(pixel); }
			init();
		}
	}
	
}
package ca.esdot.lib.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageQuality;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class SpriteUtils
	{
		public static function reparent(source:Sprite, target:Sprite):void {
			for(var i:int = 0, l:int = source.numChildren; i < l; i++){
				target.addChild(source.getChildAt(0));
			}
		}
		
		public static function removeChild(parent:Sprite, child:Sprite):void {
			if(child && parent && parent.contains(child)){
				parent.removeChild(child);
			}
		}
		
		public static function getUnderlay(color:Number = 0x0, alpha:Number = .5, width:int = 10, height:int = 10):Sprite {
			var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(color, alpha);
			sprite.graphics.drawRect(0, 0, width, height);
			sprite.graphics.endFill();
			return sprite;
		}
		
		public static function rotateOnCenter(img:Sprite, regPoint:Point, angle:Number):Sprite {
			var imgMatrix:Matrix = img.transform.matrix; 
			var centerX:Number = regPoint.x;
			var centerY:Number = regPoint.y; 
			var centerPoint:Point = new Point(centerX, centerY); 
			var transformPoint:Point= imgMatrix.transformPoint(centerPoint); 
			
			//Lgoic is very simple and straight forwad, we know the Registration point of any Display Object are (0,0)i.e. 
			//the top left corner.Thats why it rotates normally around this point. 
			imgMatrix.translate(-transformPoint.x, -transformPoint.y);
			imgMatrix.rotate(angle * Math.PI / 180);
			imgMatrix.translate(transformPoint.x, transformPoint.y);
			img.transform.matrix = imgMatrix;
			return img; 
		}
		
		public static function match(target:Sprite, source:Sprite):void {
			target.x = source.x;
			target.y = source.y;
			target.width = source.width;
			target.height = source.height;
		}
		
		public static function draw(target:DisplayObject, scale:Number = 1):BitmapData {
			if(!target){ return null; }
			
			target.scaleX = target.scaleY = 1;
			var rect:Rectangle = target.getBounds(target);
			var bmpData:BitmapData = new BitmapData(rect.width * scale, rect.height * scale, true, 0x0);
			var m:Matrix = new Matrix(1,0,0,1, -rect.x, -rect.y);
			m.scale(scale, scale);
			
			if(RENDER::GPU) {
				bmpData.drawWithQuality(target, m, null, null, null, true, StageQuality.HIGH);
			} else {
				bmpData.draw(target, m, null, null, null, true);
			}
			return bmpData;
		}
		
		public static function drawEverything(target:DisplayObject, stage:Stage):BitmapData {
				
				var bounds:Rectangle = target.getBounds(stage);
				var bitmapData:BitmapData = new BitmapData(bounds.width, bounds.height, true, 0x00000000);
				
				var matrix:Matrix = target.transform.concatenatedMatrix;
				var origin:Point = target.localToGlobal(new Point());
				matrix.tx = origin.x - bounds.x;
				matrix.ty = origin.y - bounds.y;
				
				bitmapData.draw(target, matrix, target.transform.concatenatedColorTransform);
				
				return bitmapData;
		}
	}
}
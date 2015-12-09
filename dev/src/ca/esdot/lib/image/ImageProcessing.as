package ca.esdot.lib.image
{
	import com.quasimondo.geom.ColorMatrix;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import de.popforge.imageprocessing.core.Image;
	import de.popforge.imageprocessing.core.ImageFormat;
	import de.popforge.imageprocessing.filters.color.ContrastCorrection;
	import de.popforge.imageprocessing.filters.color.Invert;
	import de.popforge.imageprocessing.filters.color.LevelsCorrection;
	import de.popforge.imageprocessing.filters.color.QuickContrastCorrection;
	import de.popforge.imageprocessing.filters.convolution.Emboss;
	
	public class ImageProcessing
	{
		[Embed(source="/assets/filters/noise.gif")]
		protected static var NoiseImage:Class;
		protected static var noiseBitmap:Bitmap = new NoiseImage();
		
		public static function vignette(targetData:BitmapData, colors:Array=null, alphas:Array=null, ratios:Array = null):void {
			var s:Sprite = new Sprite();
			var m:Matrix = new Matrix();
			
			if(!colors){ colors = [0x0, 0x0]; }
			if(!alphas){ alphas = [0, .35]; }
			if(!ratios){ ratios = [160, 255]; }
			
			m.translate(targetData.width/2, targetData.height/2);
			s.graphics.beginGradientFill(GradientType.RADIAL, colors, alphas, ratios, m);
			s.graphics.drawRect(0, 0, targetData.width, targetData.height);
			s.graphics.endFill();
			
			m.identity();
			if(targetData.width > targetData.height){
				m.scale(1.5, 1.5);
				m.translate(-targetData.width * .25, -targetData.height * .25);
			} else {
				m.scale(1, 1.25);
				m.translate(0, -targetData.height * .25);
			}
			targetData.draw(s);
		}
		
		public static function sepia(targetData:BitmapData, tone:int, contrast:Number=.33, offset:Number=20):void {
			
			var colour:Array = [];
			colour = colour.concat( [contrast + .01, contrast, contrast, 0.00, tone] );
			colour = colour.concat( [contrast, contrast + .01, contrast, 0.00, offset] );
			colour = colour.concat( [contrast, contrast, contrast + .01, 0.00, 0.00] );
			colour = colour.concat( [0.00, 0.00, 0.00, 1.00, 0.00] );
			
			var colourFilter:ColorMatrixFilter = new ColorMatrixFilter( colour );
			targetData.applyFilter(targetData, targetData.rect, targetData.rect.topLeft, colourFilter);
		}
		
		public static function flipBitmap(targetData:BitmapData, vertical:Boolean = true, horizontal:Boolean = true):void {
			var scaleX:int = (horizontal)? -1 : 1;
			var scaleY:int = (vertical)? -1 : 1;
			
			var m:Matrix = new Matrix();
			m.scale(scaleX, scaleY);
			if(scaleX < 1){
				m.translate(targetData.width, 0);	
			}
			if(scaleY < 1){
				m.translate(0, targetData.height);
			}
			
			var tmpData:BitmapData = targetData.clone();
			targetData.fillRect(targetData.rect, 0x0);
			targetData.draw(tmpData, m);
		}
		
		public static function rotateBy90(rotateCount:int, sourceData:BitmapData):BitmapData {
			if(rotateCount <= -1){ rotateCount = 0; }
			rotateCount = rotateCount % 4;
			
			var m:Matrix = new Matrix();
			var tmpData:BitmapData = sourceData.clone();
			var returnData:BitmapData;
			if(rotateCount == 0){
				returnData = tmpData;
			} else {
				//for(var i:int = 0; i < rotateCount; i++){
				
				var point:Point = new Point(tmpData.width/2, tmpData.height/2);
				//Center
				m.tx -= point.x;
				m.ty -= point.y;
				
				//How much to rotate?
				m.rotate((90 * rotateCount) * (Math.PI/180));
				
				//How much to translate back?
				if(rotateCount == 1 || rotateCount == 3){
					m.tx += point.y;
					m.ty += point.x;	
					//How big is the new bitmap?
					returnData = new BitmapData(tmpData.height, tmpData.width, true, 0x0);
				} else {
					m.tx += point.x;
					m.ty += point.y;
					//How big is the new bitmap?
					returnData = new BitmapData(tmpData.width, tmpData.height, true, 0x0);
				}
				
				returnData.draw(tmpData, m, null, null, null, true);
				
				//tmpData = returnData.clone();
				//}
			}
			return returnData;
		}
		
		public static function highContrast(target:BitmapData, source:BitmapData, strength:Number = .5):void {
			var colorMatrix:ColorMatrix = new ColorMatrix();
			colorMatrix.adjustBrightness(-.1,-.1,-.1);
			colorMatrix.adjustContrast(strength * .6, strength * .6, strength * .6);
			target.applyFilter(source, target.rect, target.rect.topLeft, colorMatrix.filter);
		}
		
		public static function adjustContrast(target:BitmapData, source:BitmapData, contrast:Number):void {
			var colorMatrix:ColorMatrix = new ColorMatrix();
			colorMatrix.adjustContrast(contrast, contrast, contrast);
			target.applyFilter(source, target.rect, target.rect.topLeft, colorMatrix.filter);
		}
		
		public static function blackAndWhite(target:BitmapData, source:BitmapData, strength:Number = .5):void {
			var colorMatrix:ColorMatrix = new ColorMatrix();
			colorMatrix.adjustContrast(-.5 + strength, -.5 + strength, -.5 + strength);
			colorMatrix.adjustSaturation(0);
			target.applyFilter(source, target.rect, target.rect.topLeft, colorMatrix.filter);
		}
		
		public static function lowSaturation(target:BitmapData, source:BitmapData, strength:Number = .5):void {
			var colorMatrix:ColorMatrix = new ColorMatrix();
			colorMatrix.adjustSaturation(strength * .5);
			target.applyFilter(source, target.rect, target.rect.topLeft, colorMatrix.filter);
		}
		
		public static function adjustSaturation(value:Number, target:BitmapData):void {
			var colorMatrix:ColorMatrix = new ColorMatrix();
			colorMatrix.adjustSaturation(value);
			target.applyFilter(target, target.rect, target.rect.topLeft, colorMatrix.filter);
		}
		
		public static function highSaturation(target:BitmapData, source:BitmapData, strength:Number = .5):void {
			var colorMatrix:ColorMatrix = new ColorMatrix();
			colorMatrix.adjustSaturation(1 + strength * 2);
			target.applyFilter(source, target.rect, target.rect.topLeft, colorMatrix.filter);
		}
		
		public static function popRed(target:BitmapData, source:BitmapData, strength:Number = .5):void {
			var colorMatrix:ColorMatrix = new ColorMatrix();
			colorMatrix.adjustContrast(strength * 2, 0, 0);
			target.applyFilter(source, target.rect, target.rect.topLeft, colorMatrix.filter);
		}
		
		public static function popGreen(target:BitmapData, source:BitmapData, strength:Number = .5):void {
			var colorMatrix:ColorMatrix = new ColorMatrix();
			colorMatrix.adjustContrast(0, strength, 0);
			target.applyFilter(source, target.rect, target.rect.topLeft, colorMatrix.filter);
		}
		
		public static function popBlue(target:BitmapData, source:BitmapData, strength:Number = .5):void {
			var colorMatrix:ColorMatrix = new ColorMatrix();
			colorMatrix.adjustContrast(0, 0, strength * 2);
			target.applyFilter(source, target.rect, target.rect.topLeft, colorMatrix.filter);
		}
		
		public static function popYellow(target:BitmapData, source:BitmapData, strength:Number = .5):void {
			var colorMatrix:ColorMatrix = new ColorMatrix();
			colorMatrix.adjustContrast(strength, strength, 0);
			target.applyFilter(source, target.rect, target.rect.topLeft, colorMatrix.filter);
		}
		
		public static function popPurple(target:BitmapData, source:BitmapData, strength:Number = .5):void {
			var colorMatrix:ColorMatrix = new ColorMatrix();
			colorMatrix.adjustContrast(0, strength, strength);
			target.applyFilter(source, target.rect, target.rect.topLeft, colorMatrix.filter);
		}
		
		
		public static function emboss(target:BitmapData):void {
			var image:Image = new Image(target.width, target.height, ImageFormat.RGB);
			image.loadBitmapData(target);
			
			var sh:Emboss = new Emboss();
			sh.apply(image);
			target.draw(image.bitmapData)
		}
		
		public static function autoBrightness(target:BitmapData):void {
			var image:Image = new Image(target.width, target.height, ImageFormat.RGB);
			image.loadBitmapData(target);
			
			var bright:LevelsCorrection = new LevelsCorrection();
			bright.apply(image);
			target.draw(image.bitmapData)
		}
		
		public static function autoContrast(target:BitmapData):void {
			var image:Image = new Image(target.width, target.height, ImageFormat.RGB);
			image.loadBitmapData(target);
			
			var contrast:QuickContrastCorrection = new QuickContrastCorrection(1.2);
			contrast.apply(image);
			target.draw(image.bitmapData)
		}
		
		public static function invert(target:BitmapData):void {
			var image:Image = new Image(target.width, target.height, ImageFormat.RGB);
			image.loadBitmapData(target);
			
			var invert:Invert = new Invert();
			invert.apply(image);
			target.draw(image.bitmapData)
		}
		
		public static function vintage(target:BitmapData, age:Number = .15, vignette:Number = .25, noise:Number = .45):void {
			var colorMatrix:ColorMatrix = new ColorMatrix();
			colorMatrix.adjustContrast(0, age, age);
			colorMatrix.adjustSaturation(Math.max(1 - age, .3));
			
			target.applyFilter(target, target.rect, target.rect.topLeft, colorMatrix.filter);
			
			var scale:Number = Math.max(target.width/noiseBitmap.width, target.height/noiseBitmap.height);
			var m:Matrix = new Matrix();
			m.scale(scale, scale);
			var ct:ColorTransform = new ColorTransform(1, 1, 1, noise);
			target.draw(noiseBitmap, m, ct, BlendMode.OVERLAY);
			
			TextureFilters.apply(TextureFilters.VIGNETTE, target, vignette);
		}
		
		
		/**
		 * Ideal for fixing zits/pimples in a target circle area.
		 * Returns a blurred bitmapData Object.
		 **/
		public static function fixBlemish(sourceData:BitmapData, position:Point, radius:int, strength:Number = .5):BitmapData {
			
			var circle:Shape = new Shape();
			circle.graphics.beginFill(0xFFFFFF);
			circle.graphics.drawCircle(radius, radius, radius);
			circle.graphics.endFill();
			circle.x = position.x;
			circle.y = position.y;
			
			if(strength > 1){ strength = 1; }
			else if(strength < 0){ strength = 0; }
			
			/*
			var matrix:Matrix = new Matrix(1, 0, 0, 1, circle.x, circle.y);
			sourceData.draw(circle, matrix);
			return;
			*/
			//Get a copy of the circle sprite, so we can look at it's pixels
			var circleData:BitmapData = new BitmapData(circle.width, circle.height, true, 0x0);
			circleData.draw(circle, matrix);
			
			var px:uint;
			var center:Point = new Point(circle.width>>1, circle.height>>1);
			var red:uint = 0, green:uint = 0, blue:uint = 0;
			var circlePx:Vector.<Point> = new Vector.<Point>();
			
			//Loop through a bounding box around the circle
			var l:int = circle.x + circle.width;
			var m:int = circle.y + circle.height;
			
			//Firs we need to calcultae the average color to fill the circle with
			var avgColor:Number =  0;
			var avgCount:int = 0;
			var edgeThreshold:int = Math.ceil(circle.width * .05);
			
			var preview:BitmapData = new BitmapData(circle.width, circle.height, true, 0x0);
			
			for(var i:int = circle.x; i < l; i++){
				for(var j:int = circle.y; j < m; j++){
					//Get a point within the circle
					var pt:Point = new Point(i - circle.x, j - circle.y);
					px = circleData.getPixel32(pt.x, pt.y);
					//Is is non-transparent?
					if(px > 0){
						//If it is < 3px from the edge of the circle, use it towards our average
						var d:Number = Math.sqrt((center.x - pt.x)*(center.x - pt.x) + (center.y - pt.y)*(center.y - pt.y));
						if(Math.abs(d) >= 3){
							px = sourceData.getPixel32(i, j);
							red += px >> 16 & 0xFF;
							green += px >> 8 & 0xFF;
							blue += px & 0xFF;
							avgCount++
						}
						preview.setPixel32(i, j, px);
						//We'll need to fill these pixels later, so add them to a vector for now
						circlePx.push(pt);
					}
					
					
				}
			}
			//Now we can figure out the correct fill color.
			red /= avgCount;
			green /= avgCount;
			blue /= avgCount;
			
			//Alpha will always be 1, we'll blur later
			var color:uint = 255 << 24 | red << 16 | green << 8 | blue;
			
			//Create a bitmapData to hold the correction
			var blemishData:BitmapData = new BitmapData(circle.width, circle.height, true, 0x0);
			//Loop through circle pixels and color them
			for(i = 0, l = circlePx.length; i < l; i++){
				//color = 0xFFFFFFFF;
				blemishData.setPixel32(circlePx[i].x, circlePx[i].y, color);
			}
			
			//Blur
			var maxBlur:int = circle.width * .25|0;
			var blur:int = circle.width * .25;//(.35 - .1 * strength)|0;//maxBlur - maxBlur * strength;
			var blurFilter:BlurFilter = new BlurFilter(blur, blur, 3);
			
			//Scale down the whole thing just a little to reduce bluriness
			var scale:Number = .65;
			var matrix:Matrix = new Matrix();
			matrix.scale(scale, scale);
			matrix.translate(circle.width * ((1 - scale)/2), circle.height * ((1 - scale)/2));
			
			var alphaTransform:ColorTransform = new ColorTransform(1, 1, 1, strength);
			
			var finalData:BitmapData = new BitmapData(blemishData.width, blemishData.height, true, 0x0);
			
			finalData.draw(blemishData, matrix, alphaTransform, null, null, true);
			finalData.applyFilter(finalData, blemishData.rect, new Point(0, 0), blurFilter);
			
			scale = .2;
			blurFilter.blurX = blurFilter.blurY = blur/3;
			alphaTransform.alphaMultiplier = strength;
			matrix.identity();
			matrix.scale(scale, scale);
			matrix.translate(circle.width * ((1 - scale)/2), circle.height * ((1 - scale)/2));
			finalData.draw(blemishData, matrix, alphaTransform, null, null, true);
			finalData.applyFilter(finalData, blemishData.rect, new Point(0, 0), blurFilter);
			
			matrix = new Matrix();
			matrix.translate(circle.x, circle.y);
			sourceData.draw(finalData, matrix);
			
			return preview;
		}
		
		public static function capSize(bitmapData:BitmapData, maxSize:int):BitmapData {
			var returnData:BitmapData;
			var scale:Number = 1;
			if(bitmapData.width > bitmapData.height && bitmapData.width > maxSize){
				scale = maxSize / bitmapData.width;
			} else if(bitmapData.height > bitmapData.width && bitmapData.height > maxSize){
				scale = maxSize / bitmapData.height;
			}
			if(scale != 1){
				var m:Matrix = new Matrix();
				m.scale(scale, scale);
				returnData = new BitmapData(bitmapData.width * scale, bitmapData.height * scale);
				returnData.draw(bitmapData, m, null, null, null, true);
			} else {
				returnData = bitmapData;
			}
			return returnData;
		}
	}
}
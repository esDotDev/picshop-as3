package ca.esdot.lib.image
{
	import com.quasimondo.geom.ColorMatrix;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import ca.esdot.picshop.MainView;
	
	import swc.borders.Balloons;
	import swc.borders.Cartoon1;
	import swc.borders.ClassicWhite;
	import swc.borders.CleanPolaroid;
	import swc.borders.DirtyFrame1;
	import swc.borders.DirtyPolaroid1;
	import swc.borders.Grunge1;
	import swc.borders.Leaves;
	import swc.borders.Torn1;

	public class ImageBorders
	{
		public static var PATTERNS:String = "Colors & Patterns";
		
		public static var THIN:String = "Thin";
		public static var THICK:String = "Thick";
		public static var FEATHERED:String = "Feathered";
		public static var AURA:String = "Aura";
		
		public static var CARTOON:String = "Cartoon";
		
		public static var CLASSIC_WHITE:String = "Fancy White";
		public static var CLASSIC_RED:String = "Fancy Red";
		public static var CLASSIC_BLACK:String = "Fancy Black";
		
		public static var TORN:String = "Matte";
		public static var TORN_2:String = "Painted";
		public static var TORN_3:String = "Fuzzy Edges";
		public static var TORN_4:String = "Torn";
		
		public static var GRUNGE:String = "Grunge 1";
		public static var GRUNGE_2:String = "Grunge 2";
		public static var GRUNGE_3:String = "Grunge 3";
		public static var GRUNGE_4:String = "Grunge 4";
		
		public static var LEAVES:String = "Leaves";
		public static var BALLOONS:String = "Balloons";
		
		public static var OLD_PAPER1:String = "Old Paper";
		public static var OLD_PAPER2:String = "Old Paper 2";
		
		public static var POLAROID_CLEAN:String = "Polaroid";
		public static var POLAROID_DIRTY:String = "Polaroid 2";
		
		public static function apply(type:String, data:BitmapData, color:uint = 0xFFFFFF):void {
			switch (type){
				
				case PATTERNS:
					borderUnderlay(data, new kids4(), 1);
					
				case THIN:
					borderOverlay(data, .5, color, .05);
					break;
				
				case THICK:
					borderOverlay(data, .5, color, .1);
					break;
				
				case AURA:
					borderOverlay(data, .5, color, .05, .1);
					break;
				
				case FEATHERED:
					borderOverlay(data, .5, color, .065, 0.02);
					break;
				
				
				case POLAROID_CLEAN:
					polaroidClean(data);
					break;
				
				case POLAROID_DIRTY:
					polaroidDirty1(data);
					break;
	
				case OLD_PAPER1:
					oldPaper1(data);
					break;
				
				case OLD_PAPER2:
					oldPaper2(data);
					break;
				
				case CLASSIC_WHITE:
					classicWhite(data);
					break;
				
				case CLASSIC_BLACK:
					classicBlack(data);
					break;
				
				case CLASSIC_RED:
					classicRed(data);
					break;
				
				case TORN:
				case TORN_2:
				case TORN_3:
				case TORN_4:
					torn(data, type, color);
					break;
				
				case GRUNGE:
				case GRUNGE_2:
				case GRUNGE_3:
				case GRUNGE_4:
					grunge(data, type);
					break;
				
				case CARTOON:
					cartoon(data);
					break;
				
				case LEAVES:
					leaves(data);
					break;
				
				case BALLOONS:
					balloon(data);
					break;
				
			}
				
		}
		
		public static function borderUnderlay(data:BitmapData, borderData:BitmapData = null, padding:Number = 1, scale:Number = 1, cornerRadius:Number = 0):void {
			
			padding = Math.max(data.width, data.height) * padding * .1;
			
			var layer:Sprite = new Sprite();
			
			var border:Sprite = new Sprite();
			var matrix:Matrix = new Matrix();
			matrix.scale(1/scale, 1/scale);
			
			
			border.graphics.beginBitmapFill(borderData, matrix, true, true);
			border.graphics.drawRect(0, 0, data.width, data.height);
			border.graphics.endFill();
			layer.addChild(border);
			
			var image:Bitmap = new Bitmap();
			image.bitmapData = data;
			layer.addChild(image);
			
			var pixelRadius:Number = Math.min(data.width, data.height) * .5 * cornerRadius;
			
			var mask:Sprite = new Sprite();
			mask.graphics.beginFill(0xFF0000);
			mask.graphics.drawRoundRect(padding, padding, data.width - padding * 2, data.height - padding * 2, pixelRadius, pixelRadius);
			mask.graphics.endFill();
			layer.addChild(mask);
			
			//Mask image which will expose the border underneath
			image.mask = mask;
			
			//Draw the whole works into a new bitmap
			data.draw(layer);
			
			
		}
		
		public static function borderOverlay(target:BitmapData, cornerRadius:Number = .5, color:int = 0xFFFFFF, margin:Number = .05, blurAmount:Number = 0):void {
			margin = Math.min(target.width, target.height) * margin;
			var border:BitmapData = new BitmapData(target.width, target.height, true, 0x0);
			border.fillRect(border.rect, 0xFFFFFFFFF);
			
			var radius:int = (margin * 5) * cornerRadius;
			var inner:Sprite = new Sprite();
			inner.graphics.beginFill(0x0, 1);
			inner.graphics.drawRoundRect(margin, margin, target.width - margin*2, target.height - margin*2, radius, radius);
			inner.graphics.endFill();
			
			//
			if(RENDER::GPU) {
				border.drawWithQuality(inner, null, null, BlendMode.ERASE, null, false, StageQuality.HIGH);
			} else {
				border.draw(inner, null, null, BlendMode.ERASE, null, false);
			}
			
			//BLUR?
			if(blurAmount > 0){
				var amount:Number = Math.max(border.width, border.height) * blurAmount;
				var bf:BlurFilter = new BlurFilter(amount, amount, 3);
				border.applyFilter(border, border.rect, new Point(), bf);
			}
			
			var ct:ColorTransform = new ColorTransform();
			ct.color = color;
			if(RENDER::GPU) {
				target.drawWithQuality(border, null, ct, null, null, false, StageQuality.HIGH);
			} else {
				target.draw(border, null, ct, null, null, false);
			}
		}
		
		public static function polaroidClean(data:BitmapData):void {
			var border:Sprite = new swc.borders.CleanPolaroid();
			stretchAndDraw(border, data);
		}
		
		public static function polaroidDirty1(data:BitmapData):void {
			var border:Sprite = new swc.borders.DirtyPolaroid1();
			stretchAndDraw(border, data);
		}
		public static function oldPaper1(data:BitmapData):void {
			var border:Sprite = new swc.borders.DirtyFrame1();
			stretchAndDraw(border, data, .95);
		}
		
		public static function oldPaper2(data:BitmapData):void {
			var border:Sprite = new swc.borders.DirtyFrame2();
			stretchAndDraw(border, data, .95);
		}
		
		public static function classicWhite(data:BitmapData):void {
			var border:Sprite = new swc.borders.ClassicWhite();
			stretchAndDraw(border, data, .9);
		}
		
		public static function classicRed(data:BitmapData):void {
			var border:Sprite = new swc.borders.ClassicRed();
			stretchAndDraw(border, data, .8);
		}
		
		public static function classicBlack(data:BitmapData):void {
			var border:Sprite = new swc.borders.ClassicBlack();
			stretchAndDraw(border, data, .8);
		}
		
		public static function balloon(data:BitmapData):void {
			var border:Sprite = new swc.borders.Balloons();
			stretchAndDraw(border, data, .97, 0, 0xFF000000);
		}
		
		public static function grunge(data:BitmapData, type:String):void {
			var border:Sprite = new swc.borders.Grunge1();
			var margin:Number = .95;
			switch(type){
				case GRUNGE_2: 
					border = new swc.borders.Grunge2(); 
					margin = 1;
					break;
				case GRUNGE_3: 
					border = new swc.borders.Grunge3(); 
					margin = 1;
					break;
				case GRUNGE_4: 
					border = new swc.borders.Grunge4(); 
					margin = 1;
					break;
			}
			stretchAndDraw(border, data, margin, 0, 0xFF000000);
		}
		
		public static function torn(data:BitmapData, type:String, color:uint):void {
			var border:Sprite = new swc.borders.Torn1();
			var margin:Number = 1;
			switch(type){
				case TORN_2: 
					border = new swc.borders.Torn2(); 
					margin = 1;
					break;
				case TORN_3: 
					border = new swc.borders.Torn3(); 
					margin = 1;
					break;
				case TORN_4: 
					border = new swc.borders.Torn4(); 
					margin = 1;
					break;
			}
			var ct:ColorTransform = new ColorTransform();
			ct.color = color;
			stretchAndDraw(border, data, margin, 0, 0xFF000000, ct);
		}
		
		public static function cartoon(data:BitmapData):void {
			var border:Sprite = new swc.borders.Cartoon1();
			stretchAndDraw(border, data, .55, 0, 0xFF000000);
		}
		
		public static function leaves(data:BitmapData):void {
			var border:Sprite = new swc.borders.Leaves();
			stretchAndDraw(border, data, .65, 0, 0xFF000000);
		}
		
		protected static function stretchAndDraw(border:Sprite, data:BitmapData, margin:Number = .9, paddingY:Number = 0, 
												 bgColor:Number = 0xFFFFFFFF, color:ColorTransform=null):void {
			var dataCopy:BitmapData = data.clone(); 
			//Clear data
			data.fillRect(data.rect, bgColor);
			
			var m:Matrix = new Matrix();
			//Draw image smaller
			m.scale(margin, margin);
			m.translate(data.width * (1-margin)/2, data.height * (1-margin)/2);
			data.draw(dataCopy, m, null, null, null, true);
			//Draw Border
			m.identity();
			m.scale(data.width/border.width, data.height/border.height);
			m.translate(0, data.height * paddingY);
			data.draw(border, m, color, null, null, true);
		}
	}
}
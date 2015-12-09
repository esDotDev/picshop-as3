package ca.esdot.lib.utils
{
	public class ColorUtils
	{
		public static var YELLOW_MIN_H:int = 30;
		public static var YELLOW_MAX_H:int = 95;
		
		public static var YELLOW_MIN_S:int = 5;
		public static var YELLOW_MAX_S:int = 100;
		
		public static var YELLOW_MIN_V:int = 63;
		
		protected static var r:Number, g:Number, b:Number, color2:Number;
		
		public static function isYellow(color:uint, hsv:Object = null, sensitivity:Number = .5):Boolean {
			var hsvColor:Object = hsv || rgb2hsv(color);
			//Yellow: FFF7A3 >   R: 255 G: 247 B: 163 >   Y: 239 U: 84 V: 138   > H: 55  S: 36.1  V: 100
			//Yellow Detect: 
			/* 
			H: 20:40 - 100
			S: 15 - 100
			V: > 50:85
			*/
			
			var minH:int = YELLOW_MIN_H + (10 - (sensitivity * 20));
			var minV:int = YELLOW_MIN_V + (13 - (sensitivity * 26));
			
			if(hsvColor.h >= minH && hsvColor.h < YELLOW_MAX_H &&
				hsvColor.s > YELLOW_MIN_S && hsvColor.s < YELLOW_MAX_S &&
				hsvColor.v > minV){
				
				return true;
			}
			return false;
		}
		
		public static function whitenIfYellow(color:uint, sensitivity:Number = .5, strength:Number = .5):uint {
			/*
			var hsvColor:Object = rgb2hsv(color);
			var prevHsvColor:Object = rgb2hsv(color);
			
			if(isYellow(NaN, hsvColor, sensitivity)){
				//trace("hsvColor.s: " + hsvColor.s);
				if(hsvColor.s > 40){ 
					hsvColor.s -= 20 * strength;
				}
				else if(hsvColor.s > 5){
					hsvColor.s -= 10 * strength;
				}
				//trace("hsvColor.s (adjusted): " + hsvColor.s + "\n");
				//return 0xFF0000;
			}
			var color2:uint = hsv2rgb(hsvColor.h, hsvColor.s, hsvColor.v);
			if(color2 == 0){
				return color;
			}
			return color2;
			
			*/
			color2 = color;
			//var prevHsvColor:Object = rgb2hsv(color);
			
			if(isYellow(color, null, sensitivity)){
				trace("IS Yellow");
				//SHIFT RGB values towards white
				/*
				r = (color >> 16) & 0xFF;
				g = (color >> 8) & 0xFF;
				b = color & 0xFF;
				
				r += (255 - r) * .05 * strength;
				g += (255 - g) * .05 * strength;
				b += (255 - b) * .05 * strength;
				
				color = (r << 16) | (g << 8) | b;
				*/
				//USE HSV color space to shift towards brighter color
				var hsvColor:Object = rgb2hsv(color);
				trace("h: "+hsvColor.h+", s:"+hsvColor.s+" , v:" + hsvColor.v);
				if(hsvColor.s > 40){ 
					hsvColor.s -= 15 * strength;
				}
				else if(hsvColor.s > 30){
					hsvColor.s -= 5 * strength;
				}
				else if(hsvColor.s > YELLOW_MIN_S){
					hsvColor.s -= 2 * strength;
				}
				
				if(hsvColor.v < 90){
					hsvColor.v += 2 * strength;
				}
				
				color2 = hsv2rgb(hsvColor.h, hsvColor.s, hsvColor.v);
				if(color2 == 0 || color == 0xFF0000 || color == 0x00FF00 || color == 0x0000FF){
					color2 = color;
				}
				
			} else {
				color2 = color;
			}

			return color2;
			
			
		}
		
		public static function rgbToYuv(color:uint):Object {
			
			var R:uint = (color >> 16) & 0xFF;
			var G:uint = (color >> 8) & 0xFF;
			var B:uint = color & 0xFF;
			
			var obj:Object = {};
			
			obj.y = (0.257 * R) + (0.504 * G) + (0.098 * B) + 16;
			obj.u = -(0.148 * R) - (0.291 * G) + (0.439 * B) + 128;
			obj.v =  (0.439 * R) - (0.368 * G) - (0.071 * B) + 128;
				
			return obj;
		}
		
		public static function yuvToRgb(y:Number, u:Number, v:Number):Object {
			
			var R:uint, G:uint, B:uint;
			
			R = 1.164(y - 16) + 1.596(v - 128);
			G = 1.164(y - 16) - 0.813(v - 128) - 0.391(u - 128);
			B = 1.164(y - 16) + 2.018(u - 128);
			
			return ( ( R << 16 ) | ( G << 8 ) | B );
		}
		
		public static function hsv2rgb(hue:Number, sat:Number, val:Number):uint {
			var r:Number, g:Number, b:Number, i:Number, f:Number, p:Number, q:Number, t:Number;
			hue%=360;
			if(val==0) {return 0x0;}
			sat/=100;
			val/=100;
			hue/=60;
			i = Math.floor(hue);
			f = hue-i;
			p = val*(1-sat);
			q = val*(1-(sat*f));
			t = val*(1-(sat*(1-f)));
			if (i==0) {r=val; g=t; b=p;}
			else if (i==1) {r=q; g=val; b=p;}
			else if (i==2) {r=p; g=val; b=t;}
			else if (i==3) {r=p; g=q; b=val;}
			else if (i==4) {r=t; g=p; b=val;}
			else if (i==5) {r=val; g=p; b=q;}
			r = Math.floor(r*255);
			g = Math.floor(g*255);
			b = Math.floor(b*255);
			return ( ( r << 16 ) | ( g << 8 ) | b );
		}
		//
		public static function rgb2hsv(color:uint):Object {
			
			var r:Number = (color >> 16) & 0xFF;
			var g:Number = (color >> 8) & 0xFF;
			var b:Number = color & 0xFF;
			
			var x:Number, val:Number, f:Number, i:Number, hue:Number, sat:Number, val:Number;
			r/=255;
			g/=255;
			b/=255;
			x = Math.min(Math.min(r, g), b);
			val = Math.max(Math.max(r, g), b);
			if (x==val){
				return({h:undefined, s:0, v:val*100});
			}
			f = (r == x) ? g-b : ((g == x) ? b-r : r-g);
			i = (r == x) ? 3 : ((g == x) ? 5 : 1);
			hue = Math.floor((i-f/(val-x))*60)%360;
			sat = Math.floor(((val-x)/val)*100);
			val = Math.floor(val*100);
			return({h:hue, s:sat, v:val});
			
		}
	}
}
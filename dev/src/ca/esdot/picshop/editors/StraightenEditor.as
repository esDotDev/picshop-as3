package ca.esdot.picshop.editors
{
	import com.gskinner.ui.touchscroller.TouchScrollEvent;
	import com.gskinner.ui.touchscroller.TouchScrollListener;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import ca.esdot.lib.utils.SpriteUtils;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	import ca.esdot.picshop.views.EditView;
	
	public class StraightenEditor extends AbstractEditor
	{
		protected var rotateListener:TouchScrollListener;
		
		protected var lines:Sprite;
		protected var imageContainer:Sprite;

		protected var rotateTarget:Bitmap;

		protected var leftCorner:Point;
		protected var vtLines:Array;
		protected var hzLines:Array;
		private var underlay:Sprite;
		
		public function StraightenEditor(editView:EditView){
			super(editView);
		}
		
		override public function createChildren():void {
			
		}	
		
		override public function init():void {
			super.init();
			lines = new Sprite();
			var bitmapData:BitmapData = SharedBitmaps.accentColor;
			
			var numLines:int = 6;
			vtLines = [];
			for(var i:int = numLines; i-->0;){
				var bmp:Bitmap = new Bitmap(bitmapData);
				bmp.width = bmp.height = 1;
				lines.addChild(bmp);
				vtLines[i] = bmp;
			}
			
			hzLines = [];
			for(var i:int = numLines; i-->0;){
				var bmp:Bitmap = new Bitmap(bitmapData);
				bmp.width = bmp.height = 1;
				lines.addChild(bmp);
				hzLines[i] = bmp;
			}
			
			imageView.visible = false;
			
			rotateTarget = new Bitmap(sourceData);
			rotateTarget.width = currentBitmap.width;
			rotateTarget.height = currentBitmap.height;
			
			var s:Sprite = new Sprite();
			s.addChild(rotateTarget);
			s.x = -rotateTarget.width/2;
			s.y = -rotateTarget.height/2;
			
			leftCorner = editView.imageView.bitmap.localToGlobal(new Point());
			leftCorner.y += editView.marginTop;
			
			underlay = SpriteUtils.getUnderlay(0x0, 0, viewWidth, viewHeight);
			addChildAt(underlay, 0);
			
			imageContainer = new Sprite();
			imageContainer.addChild(s);
			imageContainer.x = leftCorner.x + rotateTarget.width/2;
			imageContainer.y = leftCorner.y + rotateTarget.height/2;
			addChildAt(imageContainer, 0);
				
			addChild(lines);
			drawLines();
			
			rotateListener = new TouchScrollListener(underlay);
			rotateListener.addEventListener(TouchScrollEvent.SCROLL, onScroll, false, 0, true);
			
		}
		
		public function resizeImageContainer():void {
			
			underlay.width = viewWidth;
			underlay.height = viewHeight;
			
			var oldRot:Number = imageContainer.rotation;
			imageContainer.rotation = 0;
			
			var maxHeight:int = viewHeight - contentLayer.height - editView.marginTop;
			rotateTarget.width = viewWidth;
			rotateTarget.scaleY = rotateTarget.scaleX;
			
			if(rotateTarget.height > maxHeight){
				rotateTarget.height = maxHeight;
				rotateTarget.scaleX = rotateTarget.scaleY;
			}
			
			imageContainer.getChildAt(0).x = -rotateTarget.width >> 1;
			imageContainer.getChildAt(0).y = -rotateTarget.height >> 1;
			
			imageContainer.x = viewWidth * .5;
			imageContainer.y = editView.marginTop * .5 + (viewHeight - contentLayer.height) * .5;
			
			drawLines();
			
			//imageContainer.rotation = oldRot;
		}
		
		protected function onScroll(event:TouchScrollEvent):void {
			var rotation:Number = (event.mouseDeltaX + event.mouseDeltaY)/2;
			
			imageContainer.rotation += event.mouseDeltaX * .25;
			
			var maxRotation:int = 20;
			if(imageContainer.rotation > maxRotation){
				imageContainer.rotation = maxRotation;
			}
			if(imageContainer.rotation < -maxRotation){
				imageContainer.rotation = -maxRotation;
			}
			
			var ratio:Number = Math.max(rotateTarget.width/rotateTarget.height, rotateTarget.height/rotateTarget.width);
			imageContainer.scaleX = imageContainer.scaleY = 1 + Math.abs(imageContainer.rotation) * .016 * ratio;
		}
		
		protected function drawLines():void {
			
			var rect:Rectangle = new Rectangle(imageContainer.x - imageContainer.width * .5, imageContainer.y - imageContainer.height * .5, rotateTarget.width, rotateTarget.height);
			
			var space:int = rect.width / (vtLines.length - 1);
			for(var i:int = 0, l:int = vtLines.length; i < l; i++){
				if(i < l - 1){
					vtLines[i].x = rect.x + space  * i;
				} else {
					vtLines[i].x = rect.x + rect.width;
				}
				vtLines[i].y = rect.y;
				vtLines[i].height = rect.height;
			}
			
			space = rect.height / (hzLines.length - 1);
			for(var i:int = 0, l:int = vtLines.length; i < l; i++){
				hzLines[i].x = rect.x;
				if(i < l - 1){
					hzLines[i].y = rect.y + space  * i;
				} else {
					hzLines[i].y = rect.y + rect.height;
				}
				hzLines[i].width = rect.width;
			}
			
			
		}
		
		override public function transitionOut():void {
			super.transitionOut();
			removeChild(imageContainer);
			removeChild(lines);
			imageView.visible = true;
			scrollListener.removeEventListener(TouchScrollEvent.SCROLL, onScroll);
			scrollListener.destroy();
		}
		
		
		override public function applyToSource():BitmapData {
			
			var newSource:BitmapData = new BitmapData(sourceData.width, sourceData.height, false, 0xFF);
			var m:Matrix = new Matrix();
			m.translate(-sourceData.width/2,-sourceData.height/2);
			m.rotate(imageContainer.rotation * Math.PI/180);
			m.scale(imageContainer.scaleX, imageContainer.scaleX);
			m.translate(sourceData.width/2,sourceData.height/2);
			newSource.draw(sourceData, m, null, null, null, true);
			
			return newSource;
		}
		
	}
}
package ca.esdot.picshop.editors
{
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.image.ImageProcessing;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.components.Slider;
	import ca.esdot.picshop.views.EditView;
	
	import com.gskinner.filters.SharpenFilter;
	import com.gskinner.motion.GTween;
	import com.quasimondo.geom.ColorMatrix;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.DisplacementMapFilterMode;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import swc.DisplaceMask;
	
	public class FishEyeEditor extends AbstractEditor
	{
		public var slider:Slider;
		
		protected var maskSprite:Sprite;
		protected var maskCache:BitmapData;
		protected var circleBitmap:Bitmap;
		protected var isMouseDown:Boolean;
		
		protected var displaceScale:Number;
		
		public var size:Number;
		public var displaceContainer:Sprite;
		public var displacer:Sprite;
		
		
		public function FishEyeEditor(editView:EditView){
			super(editView);
			processTimer.delay = 50;
			processTimer.start();
			
			MainView.instance.editView.imageView.zoomGesture.enabled = false;
			MainView.instance.editView.imageView.panGesture.enabled = false;
			
			setInstructions("Use your finger to adjust the position, and the slider to control the size...");
			
		}
		
		override public function createChildren():void {
			slider = new Slider(.5, "Size");
			slider.addEventListener(ChangeEvent.CHANGED, onSlider1Changed, false, 0, true);
			controlsLayer.addChild(slider);
			
			displaceContainer = new Sprite();
			displacer = new swc.DisplaceMask();
			displaceContainer.addChild(displacer);
			
			drawDisplaceContainer(sourceDataSmall);
			sizeDisplacer(sourceDataSmall);
			
			displacer.x = currentBitmap.width/2;
			displacer.y = currentBitmap.height/2;
			
			settingsDirty = true;
			
			imageView.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			PicShop.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			PicShop.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
			
		}
		
		protected function drawDisplaceContainer(bitmapData:BitmapData):void { 
			displaceContainer.graphics.clear();
			displaceContainer.graphics.beginFill(0x808080);
			displaceContainer.graphics.drawRect(0, 0, bitmapData.width, bitmapData.height);
			displaceContainer.graphics.endFill();
		}
		
		protected function sizeDisplacer(bitmapData:BitmapData):void {
			if(bitmapData.width > bitmapData.height){
				displacer.width = bitmapData.width * .85;
				displacer.scaleY = displacer.scaleX;
			} else {
				displacer.width = bitmapData.height * .85;
				displacer.scaleX = displacer.scaleY;
			}
			displaceScale = displacer.scaleX;
		}
		
		protected function onMouseMove(event:MouseEvent):void {
			if(!isMouseDown){ return; }
			
			displacer.x = (mouseX - imageView.container.x) / imageView.container.scaleX;
			displacer.y = (mouseY - imageView.container.y) / imageView.container.scaleY;
			
			settingsDirty = true;
		}
		
		protected function onMouseDown(event:MouseEvent):void {
			isMouseDown = true;
		}
		
		protected function onMouseUp(event:MouseEvent):void {
			isMouseDown = false;
		}
		
		override public function onTransitionOutComplete(tween:GTween):void {
			super.onTransitionOutComplete(tween);
			MainView.instance.editView.imageView.zoomGesture.enabled = true;
			MainView.instance.editView.imageView.panGesture.enabled = true;
			settingsDirty = true;
		}
		
		override protected function updateControlsLayout():void {
			slider.x = viewWidth * .025;
			slider.width = viewWidth - slider.x * 2;
		}
		
		protected function onSlider1Changed(event:ChangeEvent):void {
			size = Number(event.newValue);// *  100;
			if(size < .1){ size = .1; }
			
			displacer.scaleX = displaceScale * size;
			displacer.scaleY = displaceScale * size;
			
			settingsDirty = true;
		}
		
		override protected function applyChanges():void {
			if(!settingsDirty){ return; }
			
			if(!maskCache){
				maskCache = new BitmapData(sourceDataSmall.width, sourceDataSmall.height, false, 0x808080);
			}
			maskCache.draw(displaceContainer);
			
			var displaceFilter:DisplacementMapFilter = new DisplacementMapFilter(maskCache, 
				new Point(), 1, 2, 75, 75, DisplacementMapFilterMode.IGNORE);
			
			currentBitmapData.applyFilter(sourceDataSmall, sourceDataSmall.rect, new Point(), displaceFilter);
			settingsDirty = false;
		}
		
		override public function applyToSource():BitmapData {
			var newSource:BitmapData = sourceData.clone();
			
			drawDisplaceContainer(newSource);
			
			var scaleDelta:Number = sourceData.width/sourceDataSmall.width;
			displacer.x *= scaleDelta;
			displacer.y *= scaleDelta;
			displacer.width *= scaleDelta;
			displacer.height *= scaleDelta;
			
			maskCache = new BitmapData(newSource.width, newSource.height, false, 0x808080);
			maskCache.draw(displaceContainer);
			
			var displaceFilter:DisplacementMapFilter = new DisplacementMapFilter(maskCache, 
				new Point(), 1, 2, 75 * scaleDelta, 75 * scaleDelta, DisplacementMapFilterMode.IGNORE);
			
			newSource.applyFilter(sourceData, sourceData.rect, new Point(), displaceFilter);
			
			return newSource;
		}
		
		protected function createCircle(diameter:int):BitmapData {
			var circle:BitmapData=new BitmapData(diameter,diameter,false,0xFF808080);
			var center:Number=diameter/2;
			var radius:Number=center;
			for(var cy:int=0;cy < diameter;cy++) 
			{
				var newY:int=cy-center;
				for(var cx:int=0;cx < diameter;cx++) 
				{
					var newX:int=cx-center;
					var distance:Number=Math.sqrt(newX*newX+newY*newY);
					if(distance<radius)
					{
						var t:Number=Math.pow(Math.sin(Math.PI/2*distance/radius), size);
						var dx:Number=newX*(t-1)/diameter;
						var dy:Number=newY*(t-1)/diameter;
						var blue:uint=0x80+dx*0xFF;
						var green:uint=0x80+dy*0xFF;
						circle.setPixel(cx,cy,green << 8 |  blue);
					}
				}  
			}
			return circle;
		}
	}
}
package ca.esdot.picshop.editors
{
	import ca.esdot.lib.camera.SmartCameraRoll;
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.image.ImageProcessing;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.utils.TextFields;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.components.MemeTextField;
	import ca.esdot.picshop.components.Slider;
	import ca.esdot.picshop.components.buttons.CheckBoxButton;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	import ca.esdot.picshop.views.EditView;
	
	import com.quasimondo.geom.ColorMatrix;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.sampler.Sample;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	public class MemeEditor extends AbstractEditor
	{
		public var checkBox1:CheckBoxButton;
		public var checkBox2:CheckBoxButton;
		
		public var topText:MemeTextField;
		public var bottomText:MemeTextField;
		
		public var bgTop:Bitmap;
		public var bgBottom:Bitmap;
		
		public var memeOverlay:Sprite;
		
		public function MemeEditor(editView:EditView){
			super(editView);
		}
		
		override public function createChildren():void {
			checkBox1 = new CheckBoxButton("Top Border");
			checkBox1.addEventListener(MouseEvent.CLICK, onBorderChanged, false, 0, true);
			controlsLayer.addChild(checkBox1);
			
			checkBox2 = new CheckBoxButton("Bottom Border");
			checkBox2.addEventListener(MouseEvent.CLICK, onBorderChanged, false, 0, true);
			controlsLayer.addChild(checkBox2);
		}
		
		override public function init():void {
			super.init();
			
			memeOverlay = new Sprite();
			addChildAt(memeOverlay, 0);
			
			bgTop = new Bitmap(SharedBitmaps.black);
			bgTop.visible = false;
			memeOverlay.addChild(bgTop);
			
			bgBottom = new Bitmap(SharedBitmaps.black);
			bgBottom.visible = false;
			memeOverlay.addChild(bgBottom);
			
			//editView.imageView.mouseChildren
			topText = new MemeTextField();
			topText.maxSize = DeviceUtils.fontSize * 2;
			topText.minSize = DeviceUtils.fontSize * 1;
			topText.addEventListener(ChangeEvent.CHANGED, onTextChanged, false, 0, true);
			memeOverlay.addChild(topText);
			
			bottomText = new MemeTextField();
			bottomText.maxSize = DeviceUtils.fontSize * 2;
			bottomText.minSize = DeviceUtils.fontSize * 1;
			bottomText.addEventListener(ChangeEvent.CHANGED, onTextChanged, false, 0, true);
			memeOverlay.addChild(bottomText);
			
			positionText();
		}
		
		protected function onTextChanged(event:Event):void {
			//positionText();
		}
		
		protected function positionText():void {
			if(!topText){ return; }
			
			memeOverlay.x = imageView.container.x;
			memeOverlay.y = editView.marginTop + imageView.container.y;
			
			topText.y = padding * .5;
			topText.x = padding;
			topText.width = imageView.container.width - padding*2;
			
			bgTop.height = topText.height + padding;
			bgTop.width = imageView.container.width;
			
			bottomText.width = imageView.container.width - padding*2;
			bottomText.y = imageView.container.height - bottomText.height - padding * .5;
			bottomText.x = padding;
			
			bgBottom.height = bottomText.height + padding;
			bgBottom.width = imageView.container.width;
			bgBottom.y = bottomText.y - padding * .5;
		}
		
		override protected function updateControlsLayout():void {
			
			checkBox1.setSize(viewWidth/2, DeviceUtils.hitSize);
				
			checkBox2.x = checkBox1.width;
			checkBox2.setSize(viewWidth/2, DeviceUtils.hitSize);	
			
			positionText();
		}
		
		protected function onBorderChanged(event:MouseEvent):void {
			bgTop.visible = checkBox1.isSelected;
			bgBottom.visible = checkBox2.isSelected;
		}
		
		override public function discardEdits():void {
			if(memeOverlay && contains(memeOverlay)){
				removeChild(memeOverlay);
			}
			topText.bordersVisible = bottomText.bordersVisible = false;
			topText.cacheEnabled = bottomText.cacheEnabled = false;
			
			super.discardEdits();
		}
		
		override public function applyToSource():BitmapData {
			if(memeOverlay && contains(memeOverlay)){
				removeChild(memeOverlay);
			}
			
			topText.bordersVisible = bottomText.bordersVisible = false;
			topText.cacheEnabled = bottomText.cacheEnabled = false;
			
			var newSource:BitmapData = sourceData.clone();
			var memeLayer:BitmapData = new BitmapData(sourceData.width, sourceData.height, true, 0x0);
			
			var scale:Number = sourceData.width / imageView.container.width;
			var m:Matrix = new Matrix();
			m.scale(scale, scale);
			
			if(RENDER::GPU) {
				memeLayer.drawWithQuality(memeOverlay, m, null, null, null, true, StageQuality.HIGH);
			} else {
				memeLayer.draw(memeOverlay, m, null, null, null, true);
			}
			memeLayer.applyFilter(memeLayer, memeLayer.rect, new Point(), new GlowFilter(0x0, 1, 3 * scale, 3 * scale, 10 * scale, 3));
			
			if(RENDER::GPU) {
				newSource.drawWithQuality(memeLayer, null, null, null, null, false, StageQuality.HIGH);
			} else {
				newSource.draw(memeLayer, null, null, null, null, false);
			}
			return newSource;
		}
		
		override public function destroy():void {
			super.destroy();
			
			topText.destroy();
			bottomText.destroy();
		}
	}
}
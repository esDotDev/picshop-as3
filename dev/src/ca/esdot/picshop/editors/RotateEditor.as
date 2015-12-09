package ca.esdot.picshop.editors
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	
	import ca.esdot.lib.image.ImageProcessing;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.utils.SpriteUtils;
	import ca.esdot.picshop.components.buttons.TileButton;
	import ca.esdot.picshop.components.containers.HBox;
	import ca.esdot.picshop.views.EditView;
	
	import swc.RotateIcon;
	
	public class RotateEditor extends AbstractEditor
	{
		protected var hBox:HBox;
		
		protected var rotateRight:TileButton;
		protected var rotateLeft:TileButton;
		protected var flipHorizontal:TileButton;
		protected var flipVertical:TileButton;
		
		protected var currentButton:TileButton;
		private var rotateCount:int = 0;
		
		public function RotateEditor(editView:EditView){
			super(editView);
			editingDownscale = 1;
		}
		
		override public function createChildren():void {
			
			hBox = new HBox();
			controlsLayer.addChild(hBox);
			
			var m:Matrix = new Matrix();
			
			var rightIcon:Bitmap = new Bitmap(SpriteUtils.draw(new swc.RotateIconRight()), "auto", true);
			
			var leftIcon:Bitmap = new Bitmap(SpriteUtils.draw(new swc.RotateIconLeft()), "auto", true);
			
			var verticalIcon:Bitmap = new Bitmap(SpriteUtils.draw(new swc.FlipIconVt()), "auto", true);
			var horizontalIcon:Bitmap = new Bitmap(SpriteUtils.draw(new swc.FlipIconHz()), "auto", true);
			
			rotateRight = new TileButton(null, leftIcon);
			rotateRight.fontSize = DeviceUtils.fontSize;
			rotateRight.addEventListener(MouseEvent.CLICK, onButtonClick, false, 0, true);
			rotateRight.bg.visible = false;
			hBox.addChild(rotateRight);
			
			rotateLeft = new TileButton(null, rightIcon);
			rotateLeft.bg.visible = false;
			rotateLeft.addEventListener(MouseEvent.CLICK, onButtonClick, false, 0, true);
			hBox.addChild(rotateLeft);
			
			flipHorizontal = new TileButton(null, horizontalIcon);
			flipHorizontal.bg.visible = false;
			flipHorizontal.addEventListener(MouseEvent.CLICK, onButtonClick, false, 0, true);
			hBox.addChild(flipHorizontal);
			
			flipVertical = new TileButton(null, verticalIcon);
			flipVertical.bg.visible = false;
			flipVertical.addEventListener(MouseEvent.CLICK, onButtonClick, false, 0, true);
			hBox.addChild(flipVertical);
		}
		
		protected function onButtonClick(event:MouseEvent):void {
			
			switch(event.currentTarget){
				
				case rotateRight:
					if(++rotateCount > 3){ rotateCount = 0; }
					setCurrentBitmapData(ImageProcessing.rotateBy90(rotateCount, sourceDataSmall.clone()));
					editView.imageView.updateLayout();
					break;
				
				case rotateLeft:
					if(--rotateCount < 0){ rotateCount = 3; }
					setCurrentBitmapData(ImageProcessing.rotateBy90(rotateCount, sourceDataSmall.clone()));
					editView.imageView.updateLayout();
					break;
				
				case flipVertical:
					ImageProcessing.flipBitmap(currentBitmapData, true, false);
					break;
				
				case flipHorizontal:
					ImageProcessing.flipBitmap(currentBitmapData, false, true);
					break;
			}
			
		}		
	
		override protected function updateControlsLayout():void {
			
			var buttonWidth:int = DeviceUtils.hitSize * 2;
			if(buttonWidth * 4 > viewWidth){
				buttonWidth = viewWidth * .25;
			}
			var iconHeight:int = buttonWidth * .35;
			//rotateRight.icon.height = iconHeight;
			//rotateRight.icon.scaleX = rotateRight.icon.scaleY;
			rotateRight.setSize(buttonWidth, buttonWidth * .5);
			
			//rotateLeft.icon.height = iconHeight;
			//rotateLeft.icon.scaleX = rotateLeft.icon.scaleY;
			//rotateLeft.icon.scaleX = -Math.abs(rotateLeft.icon.scaleX);
			rotateLeft.setSize(buttonWidth, buttonWidth * .5);
			//rotateLeft.icon.x += rotateLeft.icon.width;
				
			//flipHorizontal.icon.height = iconHeight;
			//flipHorizontal.icon.scaleX = flipHorizontal.icon.scaleY;
			flipHorizontal.setSize(buttonWidth, buttonWidth * .5);
			
			//flipVertical.icon.height = iconHeight;
			//flipVertical.icon.scaleX = flipVertical.icon.scaleY;
			//flipVertical.icon.rotation = 90;
			flipVertical.setSize(buttonWidth, buttonWidth * .5);
			//flipVertical.icon.x += flipVertical.icon.width;
			
			hBox.updateLayout();
			hBox.x = viewWidth - hBox.width >> 1;
		}
		
		
		override public function applyToSource():BitmapData {
			return currentBitmapData;
		}
		
	}
}
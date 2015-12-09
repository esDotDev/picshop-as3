package ca.esdot.picshop.menus
{
	import com.greensock.easing.Back;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	
	import assets.Bitmaps;
	
	import ca.esdot.lib.display.CachedSprite;
	import ca.esdot.lib.events.BackEvent;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.components.TileMenu;
	import ca.esdot.picshop.components.buttons.TileButton;
	import ca.esdot.picshop.components.buttons.ToolTileButton;
	import ca.esdot.picshop.data.StickerTypes;
	import ca.esdot.picshop.data.colors.ColorTheme;
	
	import swc.IconEyes;
	import swc.IconHair;
	import swc.IconHoliday;
	import swc.IconLove;
	import swc.IconMeme;
	import swc.IconMoustache;
	import swc.IconMouth;
	import swc.IconPixel;
	
	public class StickersMenu extends TileMenu
	{
		private var backButton:TileButton;
		override protected function createTiles():void {
			tileList = [
				StickerTypes.PIXEL,
				StickerTypes.MEMES,
				StickerTypes.EYES,
				StickerTypes.MOUTHS,
				StickerTypes.HAIR,
				StickerTypes.MOUSTACHES,
				StickerTypes.HATS,
				StickerTypes.LOVE,
				StickerTypes.HOLIDAYS
			];
			
			var button:ToolTileButton;
			var icon:Sprite;
			for(var i:int = 0; i < tileList.length; i++){
				icon = null;
				switch(tileList[i]){
					case StickerTypes.EYES:
						icon = new swc.IconEyes();
						break;
					
					case StickerTypes.MOUTHS:
						icon = new swc.IconMouth();
						break;
					
					case StickerTypes.PIXEL:
						icon = new swc.IconPixel();
						break;
					
					case StickerTypes.MEMES:
						icon = new swc.IconMeme();
						break;
					
					case StickerTypes.HAIR:
						icon = new swc.IconHair();
						break;
					
					case StickerTypes.HATS:
						icon = new swc.IconHat();
						break;
					
					case StickerTypes.HOLIDAYS:
						icon = new swc.IconHoliday();
						break;
					
					case StickerTypes.LOVE:
						icon = new swc.IconLove();
						break;
					
					case StickerTypes.MOUSTACHES:
						icon = new swc.IconMoustache();
						break;
				}
				var cache:CachedSprite =  new CachedSprite(icon, DeviceUtils.screenScale * 2);
				button = new ToolTileButton(tileList[i], cache);
				
				button.addEventListener(MouseEvent.CLICK, onButtonClicked, false, 0, true);
				button.addEventListener(MouseEvent.MOUSE_DOWN, onButtonDown, false, 0, true);
				button.bg.visible = false;
				
				buttonList[i] = button;
				typesByButton[button] = tileList[i];
				
				container.addChild(button);	
			}
			
			var arrow:Bitmap = new Bitmaps.backArrow();
			ColorTheme.colorSprite(arrow);
			backButton = new TileButton("", arrow);
			backButton.showDivider = true;
			backButton.bg.visible = false;
			backButton.addEventListener(MouseEvent.CLICK, onBackClicked, false, 0, true);
			addChild(backButton);
		}
		
		protected function onBackClicked(event:MouseEvent):void {
			dispatchEvent(new BackEvent(BackEvent.BACK));
		}
		
		override public function updateLayout():void {
			
			backButton.y = 1;
			backButton.setSize(viewHeight * .5, viewHeight - 2);
			scroller.x = backButton.width;
			super.updateLayout();
		}
	}
}
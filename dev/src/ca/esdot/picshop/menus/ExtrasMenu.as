package ca.esdot.picshop.menus
{
	import assets.Bitmaps;
	
	import ca.esdot.lib.display.CachedSprite;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.components.TileMenu;
	import ca.esdot.picshop.components.buttons.ToolTileButton;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import swc.IconAddImage;
	import swc.IconAttention;
	import swc.IconBgFill;
	import swc.IconMemeMaker;
	import swc.IconPointer;
	import swc.IconRGB;
	import swc.IconSketch;
	import swc.IconSpeech;
	import swc.IconStickers;
	import swc.IconText;
	
	public class ExtrasMenu extends TileMenu {
		
		override protected function createTiles():void {
			tileList = [
				ExtrasMenuTypes.ADD_IMAGE,
				ExtrasMenuTypes.STICKERS,
				ExtrasMenuTypes.POINTERS,
				ExtrasMenuTypes.ATTENTION,
				ExtrasMenuTypes.DRAWING,
				ExtrasMenuTypes.TEXT,
				ExtrasMenuTypes.MEME,
				ExtrasMenuTypes.COLOR_CHANNELS,
				ExtrasMenuTypes.SPEECH_BUBBLES,
				ExtrasMenuTypes.BG_FILL
				
			];
			
			var button:ToolTileButton;
			var icon:Sprite;
			for(var i:int = 0; i < tileList.length; i++){
				icon = null;
				switch(tileList[i]){
					case ExtrasMenuTypes.BG_FILL:
						icon = new swc.IconBgFill();
						break;
					
					case ExtrasMenuTypes.ADD_IMAGE:
						icon = new swc.IconAddImage();
						break;
					
					case ExtrasMenuTypes.DRAWING:
						icon = new swc.IconSketch();
						break;
					
					case ExtrasMenuTypes.POINTERS:
						icon = new swc.IconPointer();
						break;
					
					case ExtrasMenuTypes.ATTENTION:
						icon = new swc.IconAttention();
						break;
					
					case ExtrasMenuTypes.MEME:
						icon = new swc.IconMemeMaker();
						break;
					
					case ExtrasMenuTypes.SPEECH_BUBBLES:
						icon = new swc.IconSpeech();
						break;
					
					case ExtrasMenuTypes.STICKERS:
						icon = new swc.IconStickers();
						break;
					
					case ExtrasMenuTypes.TEXT:
						icon = new swc.IconText();
						break;
					
					case ExtrasMenuTypes.COLOR_CHANNELS:
						icon = new swc.IconRGB();
						break;
				}
				var cache:CachedSprite = new CachedSprite(icon, DeviceUtils.screenScale);
				button = new ToolTileButton(tileList[i], cache);
				
				button.addEventListener(MouseEvent.CLICK, onButtonClicked, false, 0, true);
				button.addEventListener(MouseEvent.MOUSE_DOWN, onButtonDown, false, 0, true);
				button.bg.visible = false;
				
				buttonList[i] = button;
				typesByButton[button] = tileList[i];
				
				container.addChild(button);
			}
		}
	}
	
	
}
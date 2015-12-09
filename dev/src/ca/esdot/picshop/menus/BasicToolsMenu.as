package ca.esdot.picshop.menus
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import assets.Bitmaps;
	
	import ca.esdot.lib.display.CachedSprite;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.picshop.components.TileMenu;
	import ca.esdot.picshop.components.buttons.ToolTileButton;
	
	import swc.IconAutoFix;
	import swc.IconBlemishFix;
	import swc.IconBrightness;
	import swc.IconColor;
	import swc.IconCrop;
	import swc.IconFishEye;
	import swc.IconFocus;
	import swc.IconRedEye;
	import swc.IconRotate;
	import swc.IconSharpness;
	import swc.IconStraighten;
	import swc.IconText;
	import swc.IconTileShift;

	public class BasicToolsMenu extends TileMenu {
		
		override protected function createTiles():void {
			tileList = [
				BasicToolsMenuTypes.AUTOFIX,
				BasicToolsMenuTypes.CROP,
				BasicToolsMenuTypes.STRAIGHTEN,
				BasicToolsMenuTypes.BRIGHTNESS,
				BasicToolsMenuTypes.COLOR,
				BasicToolsMenuTypes.FIX_TEETH,
				BasicToolsMenuTypes.FIX_BLEMISH,
				BasicToolsMenuTypes.FIX_REDEYE,
				BasicToolsMenuTypes.FOCUS,
				BasicToolsMenuTypes.TILT_SHIFT,
				BasicToolsMenuTypes.FISH_EYE,
				BasicToolsMenuTypes.SHARPNESS,
				BasicToolsMenuTypes.ROTATE
			];
			
			var button:ToolTileButton;
			var icon:Sprite;
			for(var i:int = 0; i < tileList.length; i++){
				icon = null;
				switch(tileList[i]){
					case BasicToolsMenuTypes.BRIGHTNESS:
						icon = new swc.IconBrightness();
						break;
					
					case BasicToolsMenuTypes.COLOR:
						icon = new swc.IconColor();
						break;
					
					case BasicToolsMenuTypes.STRAIGHTEN:
						icon = new swc.IconStraighten();
						break;
					
					case BasicToolsMenuTypes.AUTOFIX:
						icon = new swc.IconAutoFix();
						break;
					
					case BasicToolsMenuTypes.FOCUS:
						icon = new swc.IconFocus();
						break;
					
					case BasicToolsMenuTypes.TILT_SHIFT:
						icon = new swc.IconTileShift();
						break;
					
					case BasicToolsMenuTypes.FISH_EYE:
						icon = new swc.IconFishEye();
						break;
					
					case BasicToolsMenuTypes.FIX_REDEYE:
						icon = new swc.IconRedEye();
						break;
					
					case BasicToolsMenuTypes.FIX_TEETH:
						icon = new swc.IconTeeth();
						break;
					
					case BasicToolsMenuTypes.FIX_BLEMISH:
						icon = new swc.IconBlemishFix();
						break;
					
					case BasicToolsMenuTypes.CROP:
						icon = new swc.IconCrop();
						break;
					
					case BasicToolsMenuTypes.ROTATE:
						icon = new swc.IconRotate();
						break;
					
					case BasicToolsMenuTypes.SHARPNESS:
						icon = new swc.IconSharpness();
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
		}
	}
	
	
}
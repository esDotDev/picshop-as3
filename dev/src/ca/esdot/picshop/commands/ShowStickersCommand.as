package ca.esdot.picshop.commands
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.dialogs.DialogManager;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.utils.SpriteUtils;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.commands.events.ShowStickersEvent;
	import ca.esdot.picshop.commands.events.StartEditEvent;
	import ca.esdot.picshop.data.StickerTypes;
	import ca.esdot.picshop.dialogs.TileDialog;
	import ca.esdot.picshop.menus.ExtrasMenuTypes;
	
	import org.robotlegs.mvcs.Command;
	
	import swc.AllAttention;
	import swc.AllEyes;
	import swc.AllMemes;
	import swc.AllMouths;
	import swc.AllPixel;
	import swc.AllPointers;
	import swc.facialHair.AllHair;
	import swc.hair.AllHair;
	import swc.hats.AllHats;
	import swc.holidays.AllHolidays;
	import swc.love.AllLove;
	
	public class ShowStickersCommand extends Command
	{
		[Inject]
		public var event:ShowStickersEvent;
		protected var stickerList:Array;
		protected var smallStickerList:Array;
		protected var stickerDialog:TileDialog;
		protected var view:MainView;
		
		override public function execute():void {
		
			commandMap.detain(this);
			view = (contextView as MainView);
			
			stickerList = [];
			
			var stickerContainer:Sprite;
			switch(event.stickerType){
				
				case StickerTypes.POINTERS:
					stickerContainer = new swc.AllPointers();
					break;
				
				case StickerTypes.ATTENTION:
					stickerContainer = new swc.AllAttention();
					break;
				
				case StickerTypes.EYES:
					stickerContainer = new swc.AllEyes();
					break;
				
				case StickerTypes.MOUTHS:
					stickerContainer = new swc.AllMouths();
					break;
				
				case StickerTypes.MEMES:
					stickerContainer = new swc.AllMemes();
					break;
				
				case StickerTypes.PIXEL:
					stickerContainer = new swc.AllPixel();
					break;
				
				
				case StickerTypes.HAIR:
					stickerContainer = new swc.hair.AllHair();
					break;
				
				case StickerTypes.MOUSTACHES:
					stickerContainer = new swc.facialHair.AllHair();
					break;
				
				case StickerTypes.LOVE:
					stickerContainer = new swc.love.AllLove();
					break;
				
				case StickerTypes.HOLIDAYS:
					stickerContainer = new swc.holidays.AllHolidays();
					break;
				
				default:
					stickerContainer = new swc.hats.AllHats();
			}
			
			//Apply colorTransform
			var ct:ColorTransform = new ColorTransform();
			ct.color = 0xFF0000;
			while(stickerContainer.numChildren){
				stickerList.push(stickerContainer.removeChildAt(0));
				if(event.stickerType == StickerTypes.MOUSTACHES){
					//(stickerList[stickerList.length-1] as Sprite).transform.colorTransform = ct;
				}
			}
			
			smallStickerList = [];
			for(var i:int = 0; i < stickerList.length; i++){
				var sprite:Sprite = stickerList[i];
				sprite.scaleX = sprite.scaleY = 1;
				
				//Size for both landscape and hz
				var scale:Number = (view.viewWidth * .4) / sprite.width;
				if(sprite.height > sprite.width){
					scale = (view.viewWidth * .4) / sprite.height;
				}
				
				var bitmapData:BitmapData = new BitmapData(sprite.width * scale, sprite.height * scale, true, 0x0);
				var m:Matrix = new Matrix();
				m.scale(scale, scale);
				
				if(event.stickerType == StickerTypes.MOUSTACHES){
					bitmapData.drawWithQuality(sprite, m, null, null, null, false, StageQuality.HIGH);
				} else {
					bitmapData.drawWithQuality(sprite, m, null, null, null, false, StageQuality.HIGH);
				}
				
				smallStickerList[i] = new Bitmap(bitmapData);
			}
			
			var cols:int = 3;
			if(event.stickerType == StickerTypes.HOLIDAYS || event.stickerType == StickerTypes.LOVE ||
			   event.stickerType == StickerTypes.HATS || event.stickerType == StickerTypes.HAIR || 
			   event.stickerType == StickerTypes.MOUSTACHES){
				cols = 4;
			}
			else if(event.stickerType == StickerTypes.POINTERS){
				cols = 5;
			}
			
			stickerDialog = new TileDialog(smallStickerList, cols);
			var width:int = DeviceUtils.isTablet?  MainView.instance.viewWidth * .8 :  MainView.instance.viewWidth * .95;
			var height:int = DeviceUtils.isTablet?  MainView.instance.viewHeight * .6 :  MainView.instance.viewHeight * .8;
			if(height <  MainView.instance.viewHeight * .8){
				height =  MainView.instance.viewHeight * .8;
			}
			stickerDialog.setSize(width, height);
			stickerDialog.setButtons(["Cancel"]);
			stickerDialog.addEventListener(ButtonEvent.CLICKED, onStickerClicked, false, 0, true);
			DialogManager.addDialog(stickerDialog);
			
		}
		
		protected function onStickerClicked(event:ButtonEvent):void {
			
			stickerDialog.removeEventListener(ButtonEvent.CLICKED, onStickerClicked);
			DialogManager.removeDialogs();
			
			if(event.label != "Cancel"){ 
				if(stickerDialog.currentSticker){
					var stickerSprite:Sprite = stickerList[smallStickerList.indexOf(stickerDialog.currentSticker)];
					var stickerBmp:Bitmap = new Bitmap(SpriteUtils.draw(stickerSprite, 2024/Math.max(stickerSprite.width, stickerSprite.height)));
					stickerBmp.smoothing = true;
					dispatch(new StartEditEvent(StartEditEvent.EXTRAS, ExtrasMenuTypes.STICKERS, stickerBmp));
				}
			}
			stickerDialog.destroy();
			stickerDialog = null;
			commandMap.release(this);
			
		}
	}
}
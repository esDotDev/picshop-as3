package ca.esdot.picshop.menus
{
	import com.gskinner.motion.GTween;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.StageQuality;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import ca.esdot.lib.data.TweenConstants;
	import ca.esdot.lib.image.ImageFilters;
	import ca.esdot.lib.image.TextureFilters;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.utils.TextFields;
	import ca.esdot.picshop.components.TileMenu;
	import ca.esdot.picshop.components.buttons.FilterTileButton;

	public class FiltersMenu extends TileMenu {
		
		protected var loadingText:TextField;
		protected var sourceThumb:BitmapData;
		protected var thumbQueue:Array;
		
		public function FiltersMenu() {
			super();
			container.visible = false;
			
			addChild(closeButton);
			scroller.setScroll(false, true);
			
		}
		
		public function createThumbs(sourceData:BitmapData):void {
						
			if(!tileList || tileList.length == 0){
				tileList = [
					ImageFilters.WAKE,
					ImageFilters.ROMA,
					ImageFilters.FAIRA,
					ImageFilters.MORA,
					ImageFilters.HUSK,
					ImageFilters.GO_PRO,
					ImageFilters.LOMO,
					ImageFilters.LOMO2,
					ImageFilters.VINTAGE,
					ImageFilters.TEXTURE,
					ImageFilters.SEPIA, 
					ImageFilters.NOISE,
					TextureFilters.VIGNETTE,
					ImageFilters.STRONG_YELLOW,
					ImageFilters.STRONG_RED,
					ImageFilters.DARK_POP,
					ImageFilters.DEEP_PURPLE,
					ImageFilters.STRONG_BLUE,
					ImageFilters.HIGH_CONTRAST, 
					ImageFilters.LOW_SATURATION, 
					ImageFilters.HIGH_SATURATION,
					ImageFilters.EMBOSS,
					TextureFilters.SPY_CAM,
					ImageFilters.BW, 
					ImageFilters.INVERT	
				];
			}
			
			clearThumbs(); 
			
			var imageSize:int = DeviceUtils.isRetina? 128 : 64;
			var scale:Number = Math.max(imageSize/sourceData.width, imageSize/sourceData.height);
			var m:Matrix = new Matrix();
			m.scale(scale, scale);
			
			var sourceBitmap:Bitmap = new Bitmap(sourceData, "auto", true);
			if(sourceData.width > sourceData.height){
				//Trim width
				sourceThumb = new BitmapData(sourceData.height * scale * 1.33, sourceData.height * scale, true, 0x0);
			} else {
				//Trim height
				sourceThumb = new BitmapData(sourceData.width* scale, sourceData.width * scale * .75, true, 0x0);
			}
			sourceThumb.draw(sourceBitmap, m, null, null, null, true);

			thumbQueue = [];
			for(var i:int = 0; i < tileList.length; i++){
				thumbQueue[i] = tileList[i];
			}
			if(!loadingText){
				loadingText = TextFields.getBold(DeviceUtils.fontSize * .75, 0xFFFFFF, "center");
				loadingText.height = 50;
				addChild(loadingText);
			}
			loadingText.visible = true;
			loadingText.text = "Creating Thumbnails";
			
			trace("ThumbQueue -- " + tileList.length);
			setTimeout(createThumbs_2, TweenConstants.NORMAL * 1000);
			updateLayout();
		}
		
		public function clearThumbs():void {
			container.removeChildren();
			if(buttonList){
				var button:FilterTileButton;
				for(var i:int = buttonList.length; i--;){
					button = buttonList[i];
					button.removeEventListener(MouseEvent.CLICK, onButtonClicked);
					button.removeEventListener(MouseEvent.MOUSE_DOWN, onButtonDown);
					button.destroy();
					typesByButton[button] = null;
					delete typesByButton[button];
				}
				buttonList.length = 0;
			}
			typesByButton = new Dictionary();
		}
		
		override public function updateLayout():void {
			super.updateLayout();
			
			closeButton.height = DeviceUtils.hitSize * .5;
			closeButton.scaleX = closeButton.scaleY;
			closeButton.x = viewWidth - closeButton.width >> 1;
			
			scroller.y = closeButton.height;
			scroller.setSize(viewWidth - scroller.x, viewHeight - scroller.y);
			
			loadingText.width = viewWidth;
			loadingText.y = viewHeight - loadingText.height >> 1;
			
			positionTiles();
		}
		
		protected function createThumbs_2():void {
			loadingText.text = "Creating Thumbnails...";
			for(var i:int = 0; i < tileList.length; i++){
				createThumb();
			}
			showThumbs();
			updateLayout();
		}
		
		protected function createThumb():void {
			var button:FilterTileButton;
			var filter:String = thumbQueue.shift();
			var data:BitmapData = sourceThumb.clone();
			
			//Add current filter effect to the thumnnail
			applyFilter(filter, data, sourceThumb);
			
			button = new FilterTileButton(filter, data);
			button.alpha = 0;
			button.addEventListener(MouseEvent.CLICK, onButtonClicked, false, 0, true);
			button.addEventListener(MouseEvent.MOUSE_DOWN, onButtonDown, false, 0, true);
			button.bg.visible = false;
			
			buttonList.push(button);
			typesByButton[button] = filter;
			
			container.addChild(button);
		}
		
		override protected function positionTiles():void {
			var cols:int = 0, col:int = 0, row:int = 0;
			
			if(DeviceUtils.isTablet){
				cols = isPortrait? 3 : 6;
			} else {
				cols = isPortrait? 2 : 4;
			}
			
			var padding:int = 0;//viewWidth * .05;
			var tileSize:int = (viewWidth - (padding * (cols + 1))) / cols;
			
			for(var i:int = 0; i < buttonList.length; i++){ 
				var button:FilterTileButton = buttonList[i] as FilterTileButton;
				
				button.setSize(tileSize, tileSize);
				button.x = col * (tileSize + padding);
				button.y = row * (tileSize + padding);
				col++;
			
				if(button.gridSize > 1){
					button.setSize(tileSize * button.gridSize + padding * (button.gridSize - 1), tileSize);
					col++;
				}
				
				if(i%cols == 1 && i >= cols-1){
					col = 0;
					row++;
				}
			}
		}
		
		protected function applyFilter(filter:String, data:BitmapData, sourceThumb:BitmapData):void {
			var t:int = getTimer();
			ImageFilters.apply(filter, data, sourceThumb);
			trace("Applied: " + filter + " in " + (getTimer() - t) + "ms");
		}
		
		protected function showThumbs():void {
			container.visible = true;
			loadingText.visible = false;
			
			for(var i:int = 0; i < buttonList.length; i++){
				new GTween(buttonList[i], TweenConstants.NORMAL, {alpha: 1}, {ease: TweenConstants.EASE_OUT, delay: i * .075});
			}
		}
		
		override protected function createTiles():void { }
		
	}
	
	
}
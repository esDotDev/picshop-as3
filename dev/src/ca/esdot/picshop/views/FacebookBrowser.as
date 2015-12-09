package ca.esdot.picshop.views
{
	import com.gskinner.motion.GTween;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import assets.Bitmaps;
	
	import ca.esdot.lib.components.MaskedTouchScroller;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.components.AlbumImage;
	import ca.esdot.picshop.components.FacebookImage;
	import ca.esdot.picshop.data.FacebookAlbumData;
	import ca.esdot.picshop.data.FacebookPhotoData;
	import ca.esdot.picshop.data.colors.ColorTheme;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	import ca.esdot.picshop.dialogs.DialogBackground;
	
	import org.osflash.signals.Signal;
	
	import swc.SegmentedSpinner;

	public class FacebookBrowser extends SizableView
	{

		protected var albumList:Vector.<FacebookAlbumData>;
		protected var photoList:Vector.<FacebookPhotoData>;
		protected var albumImageList:Vector.<AlbumImage>;
		protected var facebookImageList:Vector.<FacebookImage>;
		protected var imagesByAlbum:Dictionary;
		
		protected var underlay:Sprite;
		protected var content:Sprite;
		protected var albumContainer:Sprite;
		protected var photoContainer:Sprite;

		protected var numCols:int;
		protected var albumScroller:MaskedTouchScroller;
		protected var photoScroller:MaskedTouchScroller;
		protected var bg:DialogBackground;
		
		protected var buttons:Sprite;
		protected var closeButton:Bitmap;
		protected var backButton:Bitmap;
		
		protected var spinner:swc.SegmentedSpinner;
		
		public var viewPort:Rectangle;
		
		public var albumClicked:Signal;
		public var photoClicked:Signal;
		
		public function FacebookBrowser(){
			
			imagesByAlbum = new Dictionary();
			albumClicked = new Signal(String);
			photoClicked = new Signal(String);
			
			albumImageList = new <AlbumImage>[];
			facebookImageList = new <FacebookImage>[];
			
			viewPort = new Rectangle();
			
			
			underlay = new Sprite();
			var fill:Bitmap = new Bitmap(SharedBitmaps.accentColor);
			underlay.alpha = .15;
			underlay.addChild(fill);
			addChild(underlay);
			underlay.addEventListener(MouseEvent.CLICK, onCloseClicked, false, 0, true);
			
			bg = new DialogBackground();
			addChild(bg);
			
			content = new Sprite();
			addChild(content);
			
			albumContainer = new Sprite();
			albumScroller = new MaskedTouchScroller(albumContainer, true, false);
			content.addChild(albumScroller);
			
			photoContainer = new Sprite();
			photoScroller = new MaskedTouchScroller(photoContainer, true, false);
			content.addChild(photoScroller);
			
			buttons = new Sprite();
			buttons.addEventListener(MouseEvent.CLICK, onCloseClicked, false, 0, true);
			addChild(buttons);
			
			closeButton = (ColorTheme.whiteMode)? new Bitmaps.closeButtonWhite() : new Bitmaps.closeButton();
			closeButton.smoothing = true;
			buttons.addChild(closeButton);
			
			backButton = (ColorTheme.whiteMode)? new Bitmaps.backButtonWhite() : new Bitmaps.backButton();
			backButton.smoothing = true;
			backButton.visible = false;
			buttons.addChild(backButton);
		}
		
		public function set isLoading(value:Boolean):void {
			if(value){
				if(!spinner){
					spinner = new swc.SegmentedSpinner();
					spinner.width = spinner.height = DeviceUtils.hitSize;
				}
				addChild(spinner);
				updateSpinner();
			} else if(spinner && spinner.parent){
				removeChild(spinner);
			}
		}
		
		public function updateSpinner():void {
			if(!spinner){ return; }
			spinner.x = viewWidth >> 1;
			spinner.y = viewHeight >> 1;
			
		}
		
		protected function onCloseClicked(event:MouseEvent):void {
			if(backButton.visible){
				showAlbums();
				isLoading = false;
				backButton.visible = false;
			} else {
				remove();
			}
		}
		
		protected function get imageSize():int {
			var w:int = Math.min(PicShop.stage.stageWidth, PicShop.stage.stageHeight) * .93;
			return (DeviceUtils.isTablet)? w * .30|0 : w * .47|0;
		}
		
		override public function updateLayout():void {
			
			underlay.width = viewWidth;
			underlay.height = viewHeight;
			
			bg.width = viewWidth * .93;
			bg.height = viewHeight * .93;
			bg.x = viewWidth - bg.width >> 1;
			bg.y = viewHeight - bg.height >> 1;
			
			buttons.x = bg.x;
			buttons.y = bg.y;
			
			closeButton.width = closeButton.height = DeviceUtils.hitSize * .5;
			closeButton.x = bg.width - closeButton.width * .7;
			closeButton.y = -closeButton.width * .3;
			
			backButton.width = backButton.height = DeviceUtils.hitSize * .5;
			backButton.x = -backButton.width * .3;
			backButton.y = -backButton.width * .3;
			
			viewPort.x = bg.x;
			viewPort.y = bg.y + buttons.height * .5;
			viewPort.width = bg.width;
			viewPort.height = bg.height - buttons.height * .5;
			
			updateSpinner();
			
			numCols = bg.width / imageSize |0;
			var col:int, row:int;
			
			var album:AlbumImage;
			for(var i:int = 0, l:int = albumContainer.numChildren; i < l; i++){
				col = i % numCols;
				row = i / numCols|0;
				album = albumContainer.getChildAt(i) as AlbumImage;
				album.x = col * (album.width + 1);
				album.y = row * (album.height + 1);
			}
			albumScroller.y = bg.y + 20; 	
			albumScroller.x = bg.x + (bg.width  - (imageSize * numCols) >> 1);
			albumScroller.setSize(bg.width, bg.height);
			
			var photo:FacebookImage;
			for(i = 0, l = photoContainer.numChildren; i < l; i++){
				col = i % numCols;
				row = i / numCols|0;
				photo = photoContainer.getChildAt(i) as FacebookImage;
				photo.x = col * (photo.width + 1);
				trace("PhotoX: ", photo.x);
				photo.y = row * (photo.height + 1);
			}
			photoScroller.y = bg.y + 20;
			photoScroller.x = bg.x + (bg.width  - (imageSize * numCols) >> 1);
			photoScroller.setSize(bg.width, bg.height);
		}
		
		private function clearAlbums():void {
			if(albumList){
				albumList.length = 0;
			}
			if(albumImageList){
				for(var i:int = albumImageList.length; i--;){
					albumImageList[i].destroy();
					albumImageList[i].removeEventListener(MouseEvent.CLICK, onAlbumClicked);
				}
				albumImageList.length = 0;
			}
			if(albumContainer){
				albumContainer.removeChildren();
			}
			imagesByAlbum = new Dictionary();
		}
		
		private function clearPhotos():void {
			if(photoList){
				photoList.length = 0;
			}
			if(facebookImageList){
				for(var i:int = facebookImageList.length; i--;){
					facebookImageList[i].destroy();
					facebookImageList[i].removeEventListener(MouseEvent.CLICK, onPhotoClicked);
				}
				facebookImageList.length = 0;
			}
			if(photoContainer){
				photoContainer.removeChildren();
			}
		}
		
		public function remove():void {
			if(this.parent){
				this.parent.removeChild(this);
			}
			clearAlbums();
			clearPhotos();
			removeChildren();
			albumClicked.removeAll();
		}
		
		public function showAlbums():void {
			new GTween(photoContainer, .35, {x: -100, alpha: 0});
			albumContainer.x = 100;
			albumContainer.visible = true;
			new GTween(albumContainer, .35, {x: 0, alpha: 1}, {onComplete: onShowAlbumsComplete});
		}
		
		protected function onShowAlbumsComplete(tween:GTween):void {
			photoContainer.visible = false;
		}
		
		public function showPhotos():void {
			photoContainer.removeChildren();
			
			new GTween(albumContainer, .35, {x: -100, alpha: 0});
			photoContainer.x = 100;
			photoContainer.visible = true;
			new GTween(photoContainer, .35, {x: 0, alpha: 1}, {onComplete: onShowPhotosComplete});
			backButton.visible = true;
		}
		
		protected function onShowPhotosComplete(tween:GTween):void {
			albumContainer.visible = false;
		}
		
		public function setAlbumData(albums:Vector.<FacebookAlbumData>):void {
			
			clearAlbums();
			this.albumList = albums;
			
			var delay:int;
			for(var i:int = 0, l:int = albums.length; i < l; i++){
				delay = i * 200;
				if(i > 10){ delay = 2000; }
				var image:AlbumImage = new AlbumImage(albums[i], imageSize, delay);
				image.addEventListener(MouseEvent.CLICK, onAlbumClicked, false, 0, true);
				albumImageList[i] = image;
				albumContainer.addChild(image);
			}
			updateLayout();
		}
		
		
		public function setPhotoData(photos:Vector.<FacebookPhotoData>):void {
			
			clearPhotos();
			this.photoList = photos;
			
			var delay:int;
			for(var i:int = 0, l:int = photos.length; i < l; i++){
				delay = i * 200;
				if(i > 10){ delay = 2000; }
				var image:FacebookImage = new FacebookImage(photos[i], imageSize, delay);
				image.addEventListener(MouseEvent.CLICK, onPhotoClicked, false, 0, true);
				facebookImageList[i] = image;
				photoContainer.addChild(image);
			}
			updateLayout();
		}
		
		
		
		protected function onAlbumClicked(event:MouseEvent):void {
			if(albumScroller.isScrolling){ return; }
			var album:AlbumImage = event.target as AlbumImage;
			albumClicked.dispatch(album.album.id);
			showPhotos();
			isLoading = true;
		}
		
		protected function onPhotoClicked(event:MouseEvent):void {
			if(photoScroller.isScrolling){ return; }
			var photo:FacebookImage = event.target as FacebookImage;
			photoClicked.dispatch(photo.photo.id);
			new GTween(photoContainer, .35, {x: -100, alpha: 0});
			isLoading = true;
		}
	}

}
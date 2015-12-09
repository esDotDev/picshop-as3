package ca.esdot.picshop.views
{
	import com.gskinner.motion.GTween;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	
	import assets.Bitmaps;
	
	import ca.esdot.lib.data.TweenConstants;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.data.colors.ColorTheme;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	import ca.esdot.picshop.dialogs.DialogBackground;
	import ca.esdot.picshop.renderers.BgColorRenderer;
	import ca.esdot.picshop.renderers.ContactRenderer;
	import ca.esdot.picshop.renderers.RestoreRenderer;
	import ca.esdot.picshop.renderers.ReviewAppRenderer;
	import ca.esdot.picshop.renderers.ShareRenderer;
	import ca.esdot.picshop.renderers.ThemeColorRenderer;

	public class SettingsPanel extends SizableView
	{
		protected var bg:DialogBackground;
		protected var tipLeft:Bitmap;
		protected var tipRight:Bitmap;
		
		protected var padding:int = 20;
		
		protected var tweenLeft:GTween;
		protected var tweenRight:GTween;
		
		public var bgRenderer:BgColorRenderer;
		public var colorRenderer:ThemeColorRenderer;
		public var reviewAppRenderer:DisplayObject;
		public var contactRenderer:ContactRenderer;
		public var shareRenderer:ShareRenderer;
		public var restoreRenderer:RestoreRenderer;
		
		protected var divider0:Bitmap;
		protected var divider1:Bitmap;
		protected var divider2:Bitmap;
		protected var divider3:Bitmap;
		protected var divider4:Bitmap;
		protected var trialMode:Boolean;
		
		public function SettingsPanel(trialMode:Boolean) {
			this.trialMode = trialMode;
			createChildren();
			
		}
		
		protected function createChildren():void {
			bg = new DialogBackground();
			addChild(bg);
			
			tipLeft = new Bitmaps.dialogIndicator();
			tipLeft.smoothing = true;
			//addChild(tipLeft);
			
			tipRight = new Bitmap(tipLeft.bitmapData);
			tipRight.smoothing = true;
			tipRight.scaleX = -1;
			//addChild(tipRight);
			
			bgRenderer = new BgColorRenderer();
			ColorTheme.colorTextfield(bgRenderer);
			addChild(bgRenderer);
			
			divider0 = new Bitmap(SharedBitmaps.accentColor);
			addChild(divider0);
			
			colorRenderer = new ThemeColorRenderer();
			ColorTheme.colorTextfield(colorRenderer);
			addChild(colorRenderer);
			
			divider1 = new Bitmap(SharedBitmaps.accentColor);
			addChild(divider1);
			
			reviewAppRenderer = new ReviewAppRenderer();
			ColorTheme.colorTextfield(reviewAppRenderer);
			addChild(reviewAppRenderer);
			
			divider2 = new Bitmap(SharedBitmaps.accentColor);
			addChild(divider2);
			
			contactRenderer = new ContactRenderer();
			ColorTheme.colorTextfield(contactRenderer);
			addChild(contactRenderer);
			
			divider3 = new Bitmap(SharedBitmaps.accentColor);
			addChild(divider3);
			
			shareRenderer = new ShareRenderer();
			ColorTheme.colorTextfield(shareRenderer);
			addChild(shareRenderer);
			
			if(trialMode){
				restoreRenderer = new RestoreRenderer();
				ColorTheme.colorTextfield(restoreRenderer);
				addChild(restoreRenderer);
				
				divider4 = new Bitmap(SharedBitmaps.accentColor);
				addChild(divider4);
			}
		}
		
		override public function updateLayout():void {
			bg.width = viewWidth;
			bg.height = viewHeight;
			
			padding = viewHeight * .025;
			
			tipLeft.y = -16;
			tipLeft.visible = false;
			
			tipRight.y = -16;
			tipRight.visible = false;
			
			bgRenderer.x = padding;
			bgRenderer.y = padding;
			bgRenderer.width = viewWidth - padding * 2;
			
			divider0.y = bgRenderer.y + bgRenderer.height + padding;
			divider0.x = 15;
			divider0.width = viewWidth - divider0.x * 2;
			
			colorRenderer.x = padding;
			colorRenderer.y = divider0.y + padding - 2;
			colorRenderer.width = viewWidth - padding * 2;
			
			divider1.y = colorRenderer.y + colorRenderer.height + padding;
			divider1.x = 15;
			divider1.width = viewWidth - divider1.x * 2;
				
			reviewAppRenderer.x = padding;
			reviewAppRenderer.y = divider1.y + padding - 2;
			reviewAppRenderer.width = viewWidth - padding * 2;
			
			divider2.y = reviewAppRenderer.y + reviewAppRenderer.height;
			divider2.x = 15;
			divider2.width = viewWidth - divider2.x * 2;
			
			contactRenderer.x = padding;
			contactRenderer.y = reviewAppRenderer.y + reviewAppRenderer.height + padding - 2;
			contactRenderer.width = viewWidth - padding * 2;
			
			divider3.y = contactRenderer.y + contactRenderer.height;
			divider3.x = 15;
			divider3.width = viewWidth - divider3.x * 2;
			
			shareRenderer.x = padding;
			shareRenderer.y = contactRenderer.y + contactRenderer.height + padding - 2;
			shareRenderer.width = viewWidth - padding * 2;
			
			if(restoreRenderer){
				divider4.y = shareRenderer.y + shareRenderer.height;
				divider4.x = 15;
				divider4.width = viewWidth - divider4.x * 2;
				
				restoreRenderer.x = padding;
				restoreRenderer.y = shareRenderer.y + shareRenderer.height + padding - 2;
				restoreRenderer.width = viewWidth - padding * 2;
			}
		}
		
		public function showIndicators(centerMargin:Number):void {
			var leftX:int = viewWidth/2 - centerMargin/2 - tipLeft.width;
			tipLeft.x = leftX - 20;
			tipLeft.visible = true;
			new GTween(tipLeft, TweenConstants.NORMAL,  {x: leftX}, {ease:TweenConstants.EASE_OUT, delay: .3});
			
			var rightX:int = viewWidth/2 + centerMargin/2 + tipRight.width - 10;
			tipRight.x = rightX + 20;
			tipRight.visible = true;
			new GTween(tipRight, TweenConstants.NORMAL,  {x: rightX}, {ease:TweenConstants.EASE_OUT, delay: .3});
			
		}
	}
}
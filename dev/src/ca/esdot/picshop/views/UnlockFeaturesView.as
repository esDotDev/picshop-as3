package ca.esdot.picshop.views
{
	import com.gskinner.motion.GTween;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import ca.esdot.lib.components.events.ButtonEvent;
	import ca.esdot.lib.display.BitmapSprite;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.components.buttons.LabelButton;
	import ca.esdot.picshop.data.UnlockableFeatures;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	import fl.motion.easing.Back;
	import fl.motion.easing.Quadratic;
	
	import org.osflash.signals.Signal;
	
	import swc.CoinCounter;
	import swc.EarnCoinsTip;
	import swc.ExtrasPreviewStrip;
	import swc.FiltersPreviewStrip;
	import swc.FiltersPreviewText;
	import swc.FramesPreviewText;
	
	public class UnlockFeaturesView extends SizableView
	{
		protected var underlay:BitmapSprite;
		protected var bgStrip:BitmapSprite;
		protected var layer:Sprite;
		protected var textLayer:Sprite;
		protected var imageLayer:Sprite;
		protected var stripHeight:Number;
		protected var bgLayer:Sprite;
		protected var purchaseButton:LabelButton;
		protected var coinUnlockButton:LabelButton;
		protected var tapTip:EarnCoinsTip;
		protected var coinCounter:CoinCounter;
		protected var _numCoins:Number;
		protected var tipTween:GTween;
		protected var imageTween:GTween;
		
		protected var _coinCost:int;
		protected var _moneyCost:String;
		
		public var purchaseClicked:Signal;
		public var purchaseWithCoinsClicked:Signal;
		public var showOfferwallClicked:Signal;
		public var featureType:String;
		
		public function UnlockFeaturesView(featureType:String) {
			
			this.featureType = featureType;
			
			showOfferwallClicked = new Signal();
			purchaseClicked = new Signal();
			purchaseWithCoinsClicked = new Signal();
			
			createChildren();
			
		}
		
		protected function createChildren():void {
			
			underlay = new BitmapSprite(SharedBitmaps.white);
			underlay.addEventListener(MouseEvent.CLICK, onUnderlayClicked, false, 0, true);
			addChild(underlay);
			
			//BG STRIP, centered in it's own layer
			bgLayer = new Sprite();
			addChild(bgLayer);
			
			bgStrip = new BitmapSprite(SharedBitmaps.bgColor);
			bgLayer.addChild(bgStrip);
			
			//Contents
			layer = new Sprite();
			addChild(layer);
			
			if(featureType == UnlockableFeatures.FILTERS){
				textLayer = new swc.FiltersPreviewText();
			} else if(featureType == UnlockableFeatures.FRAMES){
				textLayer = new swc.FramesPreviewText();
			} else {
				textLayer = new swc.ExtrasPreviewText();
			}
			layer.addChild(textLayer);
			
			if(featureType == UnlockableFeatures.FILTERS){
				imageLayer = new swc.FiltersPreviewStrip();
			} else if(featureType == UnlockableFeatures.FRAMES){
				imageLayer = new swc.FramesPreviewStrip();
			} else {
				imageLayer = new swc.ExtrasPreviewStrip();
			}
			layer.addChild(imageLayer);
			
			purchaseButton = new LabelButton("0.01");
			purchaseButton.borderSize = 1;
			purchaseButton.bg.visible = false;
			purchaseButton.borderBox.bitmapData = SharedBitmaps.white;
			purchaseButton.addEventListener(MouseEvent.CLICK, onPurchaseClicked, false, 0, true);
			layer.addChild(purchaseButton);
			
			coinUnlockButton = new LabelButton("001");
			coinUnlockButton.borderSize = 2;
			coinUnlockButton.bg.visible = false;
			coinUnlockButton.borderBox.bitmapData = SharedBitmaps.gold;
			coinUnlockButton.labelColor = 0xe6a93f;
			coinUnlockButton.addEventListener(MouseEvent.CLICK, onPurchaseWithCoinsClicked, false, 0, true);
			layer.addChild(coinUnlockButton);
			
			tapTip = new swc.EarnCoinsTip();
			layer.addChild(tapTip);
			
			coinCounter = new swc.CoinCounter();
			coinCounter.addEventListener(MouseEvent.CLICK, onCoinCounterClicked, false, 0, true);
			layer.addChild(coinCounter);
		}
		
		override public function destroy():void {
			underlay.removeEventListener(MouseEvent.CLICK, onUnderlayClicked);
			purchaseButton.removeEventListener(MouseEvent.CLICK, onPurchaseClicked);
			coinUnlockButton.removeEventListener(MouseEvent.CLICK, onPurchaseWithCoinsClicked);
			coinCounter.removeEventListener(MouseEvent.CLICK, onCoinCounterClicked);
			
			purchaseWithCoinsClicked.removeAll();
			purchaseClicked.removeAll();
			showOfferwallClicked.removeAll();
			
			removeChildren();
			if(parent){
				parent.removeChild(this);
			}
		}
		
		protected function onPurchaseWithCoinsClicked(event:Event):void {
			purchaseWithCoinsClicked.dispatch();
		}
		
		protected function onPurchaseClicked(event:Event):void {
			purchaseClicked.dispatch();
		}
		
		protected function onCoinCounterClicked(event:MouseEvent):void {
			showOfferwallClicked.dispatch();
		}
		
		public function tweenCoins(value:Number):void {
			var dif:int = Math.abs(numCoins - value);
			var duration:Number = .35;
			if(dif > 50){
				duration = 1;
			} else if(dif > 10){
				duration = .5;
			}
			
			var tmp:Object = {value: numCoins};
			new GTween(tmp, duration, {value : value}, {onChange: function(){
				numCoins = tmp.value;
			}});
		}
		
		public function get numCoins():Number { return _numCoins; }
		public function set numCoins(value:Number):void {
			_numCoins = value;
			var prefix:String = "";
			if(value < 10){
				prefix = "00";
			} else if(value < 100){
				prefix = "0";
			}
			coinUnlockButton.alpha = (_numCoins < coinCost)? .75 : 1;
			if(coinUnlockButton.alpha == 1){
				tapTip.visible = false; 
			}
			coinCounter.label.text = prefix + value;
		}
		
		protected function onUnderlayClicked(event:MouseEvent):void {
			remove();
		}
		
		public function remove():void {
			MainView.instance.removeUpgradeOffer();
		}

		override public function transitionIn():void {
			
			updateLayout();
			
			underlay.alpha = 0;
			new GTween(underlay, .25, {alpha: .65});
			
			bgLayer.height = 0;
			new GTween(bgLayer, .5, {height: stripHeight}, {delay: .15, ease: Back.easeOut});
			
			layer.alpha = 0;
			new GTween(layer, .5, {alpha: 1}, {delay: .5, ease: Quadratic.easeOut});
			
			imageTween = new GTween(imageLayer, 1, {x: imageLayer.x}, {delay: .5, ease: Back.easeOut});
			imageLayer.x += DeviceUtils.hitSize;
			
			tapTip.alpha = 0;
			tipTween = new GTween(tapTip, 1, {alpha: 1, x: tapTip.x}, {delay: 1.5, ease: Back.easeOut, onComplete: function(){
				updateLayout();
			}});
			tapTip.x += tapTip.width * .1;
			
		}
		
		override public function updateLayout():void {
			
			underlay.width = viewWidth;
			underlay.height = viewHeight;
			
			var padding:int = DeviceUtils.padding;
			
			textLayer.width = isPortrait? viewWidth * .85 : viewWidth * .75;
			if(DeviceUtils.isTablet){
				textLayer.width *= .85;
			}
			textLayer.scaleY = textLayer.scaleX;
			if(textLayer.height > viewHeight * .3){
				textLayer.height = viewHeight * .3;
				textLayer.scaleX = textLayer.scaleY;
			}
			
			textLayer.x = textLayer.y = padding;
			
			coinCounter.height = DeviceUtils.hitSize * .5;
			coinCounter.scaleX = coinCounter.scaleY;
			coinCounter.x = viewWidth - coinCounter.width - padding;
			coinCounter.y = padding;
			
			bgStrip.width = viewWidth;
			bgStrip.height = textLayer.height * 3;
			bgStrip.y = -bgStrip.height * .5;
			bgLayer.y = viewHeight * .5;
			stripHeight = bgStrip.height;
			
			if(imageTween){
				imageTween.end();
			}
			imageLayer.height = bgStrip.height * .35;
			imageLayer.scaleX = imageLayer.scaleY;
			imageLayer.x = viewWidth - imageLayer.width >> 1;
			imageLayer.y = bgStrip.height - imageLayer.height;
			
			layer.y = viewHeight - bgStrip.height >> 1;
			
			var buttonWidth:int = textLayer.width * .25;
			var buttonHeight:int = DeviceUtils.hitSize * .5;//imageLayer.y - (textLayer.y + textLayer.height) - padding;
			var buttonY:int = textLayer.y + textLayer.height + (imageLayer.y - (textLayer.y + textLayer.height)) * .4 - buttonHeight * .5;
				
			purchaseButton.setSize(buttonWidth, buttonHeight);
			purchaseButton.x = padding;
			purchaseButton.y = buttonY;
			
			coinUnlockButton.setSize(buttonWidth, buttonHeight);
			coinUnlockButton.x = purchaseButton.x + buttonWidth + DeviceUtils.paddingSmall;
			coinUnlockButton.y = buttonY;
			
			if(tipTween){
				tipTween.end();
			}
			tapTip.height = buttonHeight * 1.3;
			tapTip.scaleX = tapTip.scaleY;
			tapTip.x = coinUnlockButton.x + buttonWidth * 1.1;
			tapTip.y = buttonY + buttonHeight * .5;// - (tapTip.height * .5);
			
		}

		public function get coinCost():int { return _coinCost; }
		public function set coinCost(value:int):void {
			_coinCost = value;
			coinUnlockButton.labelText.text = value + "";
		}

		public function get moneyCost():String { return _moneyCost;	}
		public function set moneyCost(value:String):void {
			_moneyCost = value;
			purchaseButton.labelText.text = value;
		}
		
		
	}
}
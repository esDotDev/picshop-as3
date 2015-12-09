package ca.esdot.picshop.editors.borders
{
	import com.gskinner.motion.GTween;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	
	import ca.esdot.lib.events.ChangeEvent;
	import ca.esdot.lib.utils.DeviceUtils;
	import ca.esdot.lib.utils.TextFields;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.components.AnimatedDiv;
	import ca.esdot.picshop.components.ButtonBar;
	import ca.esdot.picshop.components.ColorGrid;
	import ca.esdot.picshop.components.Slider;
	import ca.esdot.picshop.components.buttons.LabelButton;
	import ca.esdot.picshop.data.colors.ColorPickerColors;
	import ca.esdot.picshop.data.colors.ColorTheme;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	import org.osflash.signals.Signal;

	public class FrameBgEditor extends SizableView
	{
		protected var divider:Bitmap;
		protected var layer:Sprite;
		
		protected var bg:Bitmap;
		protected var buttonBar:ButtonBar;
		
		protected var colorPicker:ColorGrid;
		
		protected var colorButton:LabelButton;
		protected var colorDiv:AnimatedDiv;
		protected var patternButton:LabelButton;
		protected var patternDiv:AnimatedDiv;
		protected var selectedDivHeight:Number = DeviceUtils.divSize * 7;
		private var _currentTab:LabelButton;
		protected var bgPicker:ScrollingBitmapGrid;
		protected var loadingText:TextField;
		private var initComplete:Boolean;
		
		
		private var bgFadeSlider:Slider;
		private var paddingSlider:Slider;
		private var cornerRadiusSlider:Slider;
		
		public var bgChanged:Signal;
		
		public var fadeLevel:Number;
		public var fadeLevelChanged:Signal;
		
		public var cornerRadius:Number;
		public var cornerRadiusChanged:Signal;
		
		public var padding:Number;
		public var paddingChanged:Signal;
				
		public function FrameBgEditor(){
			
			bg = new Bitmap(SharedBitmaps.bgColor);
			bg.alpha = .85;
			addChild(bg);
			
			divider = new Bitmap(SharedBitmaps.backgroundAccent);
			addChild(divider);
			
			layer = new Sprite();
			addChild(layer);
			
			colorButton = new LabelButton("Colors");
			colorButton.addEventListener(MouseEvent.CLICK, onColorTabClicked, false, 0, true);
			colorButton.bg.bitmapData = SharedBitmaps.clear;
			addChild(colorButton);
			
			patternButton = new LabelButton("Patterns");
			patternButton.addEventListener(MouseEvent.CLICK, onPatternTabClicked, false, 0, true);
			patternButton.bg.bitmapData = SharedBitmaps.clear;
			addChild(patternButton);
			
			colorDiv = new AnimatedDiv(SharedBitmaps.accentColor, 1, true);
			addChild(colorDiv);
			
			patternDiv = new AnimatedDiv(SharedBitmaps.accentColor, 1, true);
			addChild(patternDiv);
			
			loadingText = TextFields.getRegular(DeviceUtils.fontSize * .7, 0xFFFFFF, "center");
			loadingText.text = "Loading Swatches, please wait...";
			addChild(loadingText);
			ColorTheme.colorTextfield(loadingText);
			
			bgChanged = new Signal(BitmapData);
			fadeLevelChanged = new Signal(Number);
			paddingChanged = new Signal(Number);
			cornerRadiusChanged = new Signal(Number);
			
			mouseChildren = false;
			
			
		}
		
		override public function destroy():void {
			super.destroy();
			bgChanged.removeAll();
			fadeLevelChanged.removeAll();
			paddingChanged.removeAll();
			cornerRadiusChanged.removeAll();
			ColorTheme.removeSprite(loadingText);
			
			patternButton.removeEventListener(MouseEvent.CLICK, onPatternTabClicked);
			colorButton.removeEventListener(MouseEvent.CLICK, onColorTabClicked);
			
		}
		
		override public function transitionIn():void {
			
			if(!initComplete){
				initComplete = true;
				setTimeout(init, 1000);
			} else if(colorPicker){
				if(colorPicker.selectedColor >= 0){
					currentTab = colorButton;
				} else {
					currentTab = patternButton;
				}
			}
		}
		
		public function init():void {
			
			colorPicker = new ColorGrid(ColorPickerColors.colors.concat(ColorPickerColors.greys));
			colorPicker.colorChanged.add(onColorChanged);
			layer.addChild(colorPicker);
			
			bgPicker = new ScrollingBitmapGrid(new <BitmapData>[
				
				new fun0(),
				new fun2(),
				new fun3(),
				new fun4(),
				new fun5(),
				new fun6(),
				new fun7(),
				new fun8(),
				new fun9(),
				new fun10(),
				new fun13(),
				new fun14(),
				new fun15(),
				new fun16(),
				new fun17(),
				new fun18(),
				new fun19(),
				new fun20(),
				
				new bday0(),
				new bday1(),
				new bday2(),
				new bday3(),
				
				new kids1(),
				new kids2(),
				new kids3(),
				new kids4(),
				new kids5(),
				new kids6(),
				new kids7(),
				new kids8(),
				
				new girls1(),
				new girls2(),
				new girls3(),
				new girls4(),
				new girls5(),
				new girls6(),
				new girls7(),
				new girls8(),
				
				new love0(),
				new love1(),
				
				new xmas0(),
				new xmas1(),
				new xmas2(),
				new xmas3(),
				new xmas4(),
				new xmas5(),
				new xmas6(),
				new xmas7(),
				
				new halloween0(),
				new halloween1(),
				
				new grunge0(),
				new grunge1(),
				new grunge2(),
				new grunge3(),
				new grunge4(),
				
				new wood0(), 
				new wood1(), 
				new wood2(), 
				new wood4(), 
				
				
				//Faded
				new pat4(),
				new pat5(),
				new pat6(),
				new pat7(),
				new pat8(),
				new pat9(),
				new pat10(),
				new pat11(),
				new pat12(),
				new pat13(),
				new pat14(),
				
				//Retro
				new retro1(),
				new retro2(),
				new retro3(),
				new retro4(),
				new retro5(),
				new retro6(),
				new retro7(),
				new retro8(),
				new retro9(),
				new retro10(),
				new retro11(),
				new retro12(),
				new retro13(),
				new retro14(),
				new retro15(),
				new retro16(),
				new retro17(),
				new retro18(),
				new retro19(),
				new retro20(),
				new retro21(),
				new retro22(),
				new retro23(),
				new retro24(),
				new retro25(),
				
				//Dark
				new pat15(),
				new pat1(), 
				new pat2(), 
				new pat3(),
				
				//Stripes
				new pat17(),
				new pat16(),
				new pat19(),
				new pat20(),
				new pat22(),
				new pat25(),
				new pat28(),
				
				//Slants
				new pat18(),
				new pat23(),
				new pat26(),
				new pat29(),
				new pat30(),
				new pat31(),
				new pat32(),
				
				new pat34(),
				new pat35(),
				new pat36(),
				new pat37(),
				new pat39(),
				new pat40(),
				new pat41(),
				new pat42(),
				new pat43(),
				new pat44(),
				new pat45(),
				new pat48(),
				new pat49(),
				new pat50(),
				new pat51(),
				new pat52(),
				new pat53(),
				new pat54(),
				new pat55(),
				new pat56(),
				new pat57(),
				new pat58(),
				new pat59(),
				new pat60(),
				new pat61(),
				new pat62(),
				new pat63(),
				new pat64()
				
			]);
			
			currentTab = colorButton;
			colorPicker.selectedColor = 0x0;
			colorPicker.alpha = 0;
			new GTween(colorPicker, .35, {alpha: 1});
			
			bgPicker.bitmapChanged.add(onPatternChanged);
			layer.addChild(bgPicker);
			
			bgFadeSlider = new Slider(.5, "Fade to White", "Fade to Black");
			bgFadeSlider.addEventListener(ChangeEvent.CHANGED, onBgFadeChanged, false, 0, true);
			layer.addChild(bgFadeSlider);
			
			padding = .5;
			paddingSlider = new Slider(padding, "Size", "");
			paddingSlider.addEventListener(ChangeEvent.CHANGED, onPaddingChanged, false, 0, true);
			layer.addChild(paddingSlider);
			
			cornerRadius = .25;
			cornerRadiusSlider = new Slider(cornerRadius, "Corner Radius", "");
			cornerRadiusSlider.addEventListener(ChangeEvent.CHANGED, onCornerRadiusChanged, false, 0, true);
			layer.addChild(cornerRadiusSlider);
			
			mouseChildren = true;
			
			loadingText.visible = false;
			
			updateLayout();
			
			
		}		
		
		protected function onCornerRadiusChanged(event:Event):void {
			cornerRadius = cornerRadiusSlider.position;
			cornerRadiusChanged.dispatch(cornerRadius);
			trace(cornerRadius);
		}
		
		protected function onPaddingChanged(event:Event):void {
			padding = paddingSlider.position;
			paddingChanged.dispatch(padding);
			trace(padding);
		}
		
		protected function onBgFadeChanged(event:ChangeEvent):void {
			var value:Number = bgFadeSlider.position;
			var pad:Number = .15;
			var old:Number = fadeLevel;
			
			if(Math.abs(value) > (.5 - pad) && Math.abs(value) < (.5 + pad)){ 
				fadeLevel = 0;
			} else {
				//White
				if(value < .5){
					fadeLevel = 1 - value/(.5 - pad);
					if(fadeLevel < .95){
						fadeLevel = .95;
					}
				} 
				//Black
				else {
					fadeLevel = -(value - (.5 + pad)) / (1 - (.5 + pad));
					if(fadeLevel < -.95){
						fadeLevel = -.95;
					}
				}
			}
			if(old != fadeLevel){
				fadeLevelChanged.dispatch(fadeLevel);
			}
		}	
		
		
		
		protected function onPatternTabClicked(event:Event):void {
			if(currentTab == patternButton){ return; }
			currentTab = patternButton;
		}
		
		protected function onColorTabClicked(event:Event):void {
			if(currentTab == colorButton){ return; }
			currentTab = colorButton;
		}
		
		public function get currentTab():LabelButton { return _currentTab; }
		public function set currentTab(button:LabelButton):void {
			_currentTab = button;
			if(button == colorButton){
				colorPicker.visible = true;
				bgPicker.visible = false;
				colorDiv.height = selectedDivHeight;
				patternDiv.height = DeviceUtils.divSize;
			}
			else if(button == patternButton){
				colorPicker.visible = false;
				bgPicker.visible = true;
				patternDiv.height = selectedDivHeight;
				colorDiv.height = DeviceUtils.divSize;
			}
			
		}
		
		protected function onPatternChanged(bitmapData:BitmapData):void {
			if(!bitmapData){ return; }
			colorPicker.selectedColor = -1;
			trace("SET PATTERN");
			bgChanged.dispatch(bitmapData);
		}
		
		protected function onColorChanged(color:Number):void {
			if(color >= 0){
				bgPicker.selectedBitmap = null;
				trace("SET COLOR");
				bgChanged.dispatch(new BitmapData(2, 2, false, color));
			}
		}		
		
		override public function updateLayout():void {
			if(!isSizeSet){ return; }
			
			padding = DeviceUtils.divSize * 2;
			bg.width = viewWidth;
			bg.height = viewHeight;
			
			divider.width = viewWidth;
			
			loadingText.width = viewWidth * .5;
			loadingText.x = viewWidth - loadingText.width >> 1;
			loadingText.y = viewHeight * .5;
			
			colorButton.setSize(viewWidth * .5 - padding, DeviceUtils.hitSize * .5);
			patternButton.setSize(viewWidth * .5 - padding, DeviceUtils.hitSize * .5);
			patternButton.x = colorButton.viewWidth + padding * 2;
			
			colorDiv.width = colorButton.width;
			colorDiv.y = colorButton.viewHeight;
			
			patternDiv.width = patternButton.width;
			patternDiv.x = patternButton.x;
			patternDiv.y = colorButton.viewHeight;
			
			var padding:int = DeviceUtils.hitSize * .15;
			layer.x = padding;
			layer.y = colorButton.viewHeight + padding;
			
			if(colorPicker){
				if(MainView.instance.isPortrait){
					colorPicker.useVerticalLayout = false;
					colorPicker.colors = ColorPickerColors.colors.concat(ColorPickerColors.greys);
				} else {
					colorPicker.useVerticalLayout = true;
					colorPicker.colors = ColorPickerColors.greys.concat(ColorPickerColors.colors);
				}
				
				paddingSlider.width = (viewWidth - padding * 3) / 2;
				
				cornerRadiusSlider.width = paddingSlider.width;
				cornerRadiusSlider.x = paddingSlider.x + paddingSlider.width + padding;
				
				bgFadeSlider.width = viewWidth - padding * 2;
				
				colorPicker.setSize(viewWidth - padding * 2, viewHeight - layer.y - (bgFadeSlider.height + paddingSlider.height));
				bgPicker.setSize(colorPicker.viewWidth, colorPicker.viewHeight);
				
				
				paddingSlider.y = colorPicker.height + padding * .5;
				cornerRadiusSlider.y = paddingSlider.y;
				bgFadeSlider.y = paddingSlider.y + paddingSlider.height;
			}	
			
			
		}
	}
}
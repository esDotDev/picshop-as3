package ca.esdot.lib.shaders
{
	import ca.esdot.lib.components.Image;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Shader;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.filters.BlurFilter;
	import flash.filters.ShaderFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * The HDRContainer class applies High Dynamic Range post-processing to a target DisplayObject. This creates a "bloom" effect with more brilliant highlights spilling over darker edges.
	 * 
	 * @author David Lenaerts (www.derschmale.com)
	 */
	public class HDRImage extends Sprite
	{
		//import flash.display.BitmapData;
		private var _brightnessFilter : ShaderFilter;
		private var _brightnessShader : Shader;
		private var _brightnessMap : BitmapData;
		private var _blurFilter : BlurFilter;
		
		private var _rect : Rectangle;
		private var _bounds : Rectangle;
		private var _target : Image;
		private var _matrix : Matrix = new Matrix();
		private var _origin : Point = new Point();
		
		[Embed(source="shaders/BloomBrightness.pbj", mimeType="application/octet-stream")]
		private var _brightnessAsset : Class;
		
		private var _exposure : Number;
		
		private var _bitmap : Bitmap;
		
		private var _mapScale : Number;
		
		/**
		 * Creates a HDRContainer class.
		 * 
		 * @param target The target DisplayObject to be post-processed.
		 * @param brightnessThreshold The minimum luminance of a pixel in the source to create a bloom effect.
		 * @param exposure The factor by which brighter pixels are multiplied, ie: the strength of the highlights.
		 * @param blur The amount of spill created by the highlights.
		 * @param blurQuality The quality of the blur effect.
		 * @param mapScale The scale of the brightness map compared to the target DisplayObject. A value from 0 to 1. Lower values are faster, higher values might look better.
		 */
		
		protected var sourceData:BitmapData;
		
		public function HDRImage(target : Image, brightnessThreshold : Number = 0.8, exposure : Number = 1.0, blur : Number = 5, blurQuality : int = 1, mapScale : Number = 0.5)
		{
			_target = target;
			sourceData = target.bitmapData.clone();
			
			_mapScale = mapScale;
			_matrix.a = mapScale;
			_matrix.d = mapScale;
			_rect = new Rectangle();
			_blurFilter = new BlurFilter(blur, blur, blurQuality);
			_brightnessShader = new Shader(new _brightnessAsset());
			_brightnessFilter = new ShaderFilter(_brightnessShader);
			
			this.exposure = exposure;
			this.brightnessThreshold = brightnessThreshold;
			
			addChild(target);
		}
		
		/**
		 * Updates the HDR effect. This function should be called whenever the source target has changed.
		 */
		public function render() : void
		{
			checkBitmap();
			if (_brightnessMap) {
				_matrix.tx = -_bounds.x*_mapScale;
				_matrix.ty = -_bounds.y*_mapScale;
				_brightnessMap.draw(_target, _matrix);
			}
		}
		
		/**
		 * Disposes the BitmapData memory occupied by the HDR effect.
		 */
		public function destroy() : void
		{
			_brightnessMap.dispose();
		}
		
		/**
		 * The minimum luminance of a pixel in the source to create a bloom effect.
		 */
		public function get brightnessThreshold() : Number
		{
			return _brightnessShader.data.threshold.value[0]/Math.sqrt(3); 
		}
		
		public function set brightnessThreshold(value : Number) : void
		{
			_brightnessShader.data.threshold.value = [ value*Math.sqrt(3) ];
			applyFilters()
		}
		
		/**
		 * The factor by which brighter pixels are multiplied, ie: the strength of the highlights.
		 */
		public function get exposure() : Number
		{
			return _brightnessShader.data.exposure.value[ 0 ]; 
		}
		
		public function set exposure(value : Number) : void
		{
			_brightnessShader.data.exposure.value = [ value ];
			applyFilters();
		}
		
		/**
		 * The amount of spill created by the highlights.
		 */
		public function get blur() : Number
		{
			return _blurFilter.blurX; 
		}
		
		public function set blur(value : Number) : void
		{
			_blurFilter.blurX = _blurFilter.blurY = value;
			applyFilters()
		}
		
		/**
		 * The quality of the blur effect.
		 */
		public function get blurQuality() : int
		{
			return _blurFilter.quality; 
		}
		
		public function set blurQuality(value : int) : void
		{
			_blurFilter.quality = value;
			applyFilters();
		}
		
		protected function applyFilters():void {
			if(!_bitmap){ return; }
			
			_bitmap.filters = [ _brightnessFilter, _blurFilter ];
				
		}
		
		private function checkBitmap() : void
		{
			var bounds : Rectangle = _target.getBounds(_target);
			
			if (!(_bounds && _bounds.equals(bounds))) {
				_bounds = bounds;
				_rect.width = _bounds.width;
				_rect.height = _bounds.height;
				if (_bitmap) {
					_bitmap.x = _target.x+_bounds.x;
					_bitmap.y = _target.y+_bounds.y;
				}
				if (_brightnessMap) {
					_brightnessMap.dispose();
					_brightnessMap = null;
				}
			}
			
			if (!_brightnessMap && bounds.width && bounds.height) {
				_brightnessMap = new BitmapData(bounds.width*_mapScale, bounds.height*_mapScale);
				if (!_bitmap) {
					_bitmap = new Bitmap(_brightnessMap);
					_bitmap.scaleX = _bitmap.scaleY = 1/_mapScale;
					_bitmap.blendMode = BlendMode.ADD;
					
					applyFilters();
					addChild(_bitmap);
				}
				else {
					_bitmap.bitmapData = _brightnessMap;
				}
			}
		}
	}
}
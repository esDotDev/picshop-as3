package ca.esdot.picshop.views
{
	import ca.esdot.lib.components.Image;
	import ca.esdot.lib.data.TweenConstants;
	import ca.esdot.lib.view.SizableView;
	import ca.esdot.picshop.data.colors.SharedBitmaps;
	
	import com.gskinner.motion.GTween;
	import com.gskinner.ui.touchscroller.TouchScrollEvent;
	import com.gskinner.ui.touchscroller.TouchScrollListener;
	
	import fl.motion.MatrixTransformer;
	
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.GesturePhase;
	import flash.events.MouseEvent;
	import flash.events.TransformGestureEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.PanGesture;
	import org.gestouch.gestures.TapGesture;
	import org.gestouch.gestures.TransformGesture;
	import org.gestouch.gestures.ZoomGesture;
	
	public class FullScreenImageView extends SizableView
	{
		protected var sourceData:BitmapData;
		protected var image:Image;
		protected var container:Sprite;
		protected var underlay:Bitmap;
		protected var ignoreClick:Boolean;
		protected var scroller:TouchScrollListener;
		
		protected var zoomGesture:ZoomGesture;
		protected var tapGesture:TapGesture;
		protected var panGesture:PanGesture;
		
		public function FullScreenImageView(sourceData:BitmapData) {
			super();
			this.sourceData = sourceData;
			
			underlay = new Bitmap(SharedBitmaps.bgColor);
			underlay.alpha = 0;
			new GTween(underlay, TweenConstants.NORMAL, {alpha: 1}, {ease: TweenConstants.EASE_OUT});
			addChild(underlay);
			
			container = new Sprite();
			addChild(container);
			
			image = new Image();
			image.clipEdges = false;
			container.addChild(image);
			
			zoomGesture = new ZoomGesture(container);
			zoomGesture.addEventListener(GestureEvent.GESTURE_BEGAN, onZoom);
			zoomGesture.addEventListener(GestureEvent.GESTURE_CHANGED, onZoom);
			
			tapGesture = new TapGesture(container);
			tapGesture.addEventListener(GestureEvent.GESTURE_RECOGNIZED, onTapGesture);
			
			panGesture = new PanGesture(container);
			panGesture.addEventListener(GestureEvent.GESTURE_BEGAN, onPan);
			panGesture.addEventListener(GestureEvent.GESTURE_CHANGED, onPan);
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
		}
		
		protected function onTapGesture(event:GestureEvent):void {
			remove();
		}
		
		protected function onPan(event:GestureEvent):void {
			container.x += panGesture.offsetX;
			container.y += panGesture.offsetY;	
		}
		
		protected function onZoom(event:GestureEvent):void {
			var matrix:Matrix = container.transform.matrix;
			var transformPoint:Point = matrix.transformPoint(container.globalToLocal(zoomGesture.location));
			matrix.translate(-transformPoint.x, -transformPoint.y);
			matrix.scale(zoomGesture.scaleX, zoomGesture.scaleY);
			matrix.translate(transformPoint.x, transformPoint.y);
			container.transform.matrix = matrix;
		}
		
		protected function onScrollStart(event:Event):void {
			ignoreClick = false;
		}
		
		protected function onScroll(event:TouchScrollEvent):void {
			ignoreClick = true;
			
			container.x -= event.mouseDeltaX;
			container.y -= event.mouseDeltaY;
		}
		
		protected function onMouseClick(event:MouseEvent):void {
			if(ignoreClick){ ignoreClick = false; return; }
			remove();
		}
		
		public function remove():void {
			if(stage){
				parent.removeChild(this);
			}
		}
		
		protected function onAddedToStage(event:Event):void {
			setSize(stage.stageWidth, stage.stageHeight);
		}
		
		protected function onRemovedFromStage(event:Event):void {
			zoomGesture.dispose();
			panGesture.dispose();
			tapGesture.dispose();
		}
		
		override public function updateLayout():void {
			underlay.width = viewWidth;
			underlay.height = viewHeight;
			
			image.bitmapData = sourceData;
			image.setSize(viewWidth, viewHeight);
			
			container.x = 0;
			container.y  = 0;
		}
	}
}
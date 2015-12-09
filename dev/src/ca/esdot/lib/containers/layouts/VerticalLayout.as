package ca.esdot.lib.containers.layouts
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	public class VerticalLayout implements ILayout
	{
		protected var yOffset:int;
		protected var child:DisplayObject;
		protected var i:int = 0, l:int = 0;
		
		public function update(root:Sprite):void {
			yOffset = 0;
			for(i = 0, l = root.numChildren; i < l; i++){
				child = root.getChildAt(i);
				child.y = yOffset;
				yOffset += child.height;
			}
		}
				
	}
}
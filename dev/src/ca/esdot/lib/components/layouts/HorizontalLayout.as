package ca.esdot.lib.components.layouts
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	public class HorizontalLayout implements ILayout
	{
		public function update(root:Sprite):void {
			var xOffset:int = 0;
			var child:DisplayObject;
			for(var i:int = 0, l:int = root.numChildren; i < l; i++){
				child = root.getChildAt(i);
				child.x = xOffset;
				xOffset += child.width;
			}
		}
				
	}
}
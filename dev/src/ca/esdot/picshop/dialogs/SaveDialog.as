package ca.esdot.picshop.dialogs
{
	import ca.esdot.picshop.components.buttons.RadioButton;
	
	public class SaveDialog extends OptionsDialog
	{
		public function SaveDialog(width:int = 400, height:int = 250, title:String = "", dataProvider:Array = null, selectedIndex:int = -1){
			super(width, height, title, dataProvider, selectedIndex);
		}
		
		override public function get height():Number {
			return bg.height;	
		}
		
		public function set isLocked(value:Boolean):void {
			for(var i:int = 0, l:int = optionsMenu.buttonList.length; i < l; i++){
				if(i <= 1){ continue; }
				var b:RadioButton = optionsMenu.buttonList[i];
				b.isLocked = value;
			}
		}
	}
}
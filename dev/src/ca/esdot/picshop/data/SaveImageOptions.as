package ca.esdot.picshop.data
{
	import flash.filesystem.File;

	public class SaveImageOptions
	{
	 	public var quality:Number;
		public var location:File;
		public var width:int;
		public var height:int;
		
		public function SaveImageOptions(width:int, height:int, quality:Number = 1, location:File = null){
			this.width = width;
			this.height = height;
			this.quality = quality;
			this.location = location;
		}
		
	}
}
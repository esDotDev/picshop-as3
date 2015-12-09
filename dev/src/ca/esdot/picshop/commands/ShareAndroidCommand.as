package ca.esdot.picshop.commands
{
	import by.blooddy.crypto.image.JPEGEncoder;
	
	import ca.esdot.lib.events.ShareEvent;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.MainView;
	
	import com.adobe.images.JPGEncoder;
	import com.adobe.images.PNGEncoder;
	import com.jam3media.shareExt.ShareExt;
	import com.milkmangames.nativeextensions.GoViral;
	
	import flash.display.BitmapData;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import org.robotlegs.mvcs.Command;
	
	public class ShareAndroidCommand extends Command
	{
		[Inject]
		public var event:ShareEvent;
		
		[Inject]
		public var mainModel:MainModel;
		
		
		protected var mainView:MainView;
		
		override public function execute():void {
			
			if(!GoViral.goViral.isGenericShareAvailable()){ return; }
			
			mainView = contextView as MainView;
			mainView.isLoading = true;
			commandMap.detain(this);
			
			setTimeout(function():void{
				GoViral.goViral.shareGenericMessageWithImage("", "", false, mainModel.sourceData);
				mainView.isLoading = false;
				commandMap.release(this);
			}, 1000);
			
		}
		/*
		protected function save():void {
			var source:BitmapData = mainModel.sourceData;
			var scale:Number = 1000 / Math.max(source.width, source.height);
			
			var m:Matrix = new Matrix();
			m.scale(scale, scale);
			
			var data:BitmapData = new BitmapData(source.width * scale, source.height * scale, false, 0x0);
			data.draw(source, m, null, null, null, true);
			
			var t:int = getTimer();
			var encoder:JPGEncoder = new JPGEncoder(65);
			var bloodyEncoder:JPEGEncoder = new JPEGEncoder();
			var ba:ByteArray = JPEGEncoder.encode(data, 90);//encoder.encode(data);
			
			trace("Encode completed in: ", getTimer() - t);
			var f:File = File.desktopDirectory.resolvePath("share.jpg");
			var fs:FileStream = new FileStream();
			fs.open(f, FileMode.WRITE);
			fs.writeBytes(ba);
			trace("Save completed in: ", getTimer() - t);
			trace("File Saved @ " + f.nativePath);
			
			mainView.isLoading = false;
			
			var share:ShareExt = new ShareExt();
			share.shareMedia("", f.nativePath, "image/*");
			
		}
		*/
	}
}
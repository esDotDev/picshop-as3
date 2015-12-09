package ca.esdot.picshop.dialogs
{
	import ca.esdot.lib.view.SizableView;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	
	import swc.PanelBg;
	
	public class VideoDialog extends SizableView
	{
		public var bg:PanelBg;
		
		protected var video:Video;

		private var ns:NetStream;

		private var nc:NetConnection;
		
		public function VideoDialog(){
			bg = new PanelBg();
			addChild(bg);
			
			video = new Video();
			addChild(video);
			nc = new NetConnection();
			nc.connect(null);
			ns = new NetStream(nc);
			ns.client = {onCuePoint: onCuePoint, onMetaData: onMetaData};
			video.attachNetStream(ns);
			ns.play("http://www.helpexamples.com/flash/video/cuepoints.flv");
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
		}
		
		protected function onRemovedFromStage(event:Event):void{
			try {
				ns.close();
			} catch(e:Error){}
		}
		
		override public function updateLayout():void {
			bg.width = viewWidth;
			bg.height = viewHeight;
			
			video.x = video.y = 10;
			video.width = viewWidth - 20;
			video.height = viewHeight - 20;
			
		}
		
		function onCuePoint(infoObject:Object):void {
			trace("cuePoint");
		}
		
		function onMetaData(infoObject:Object):void {
			trace("metaData");
		}
		
		/*
		protected function onLoaderInit(event:Event):void {
			addChild(loader);
			loader.content.addEventListener("onReady", onPlayerReady);
			loader.content.addEventListener("onError", onPlayerError);
			loader.content.addEventListener("onStateChange", onPlayerStateChange);
			loader.content.addEventListener("onPlaybackQualityChange", onVideoPlaybackQualityChange);
		}
		
		protected function onPlayerReady(event:Event):void {
			// Event.data contains the event parameter, which is the Player API ID 
			trace("player ready:", Object(event).data);
			
			// Once this event has been dispatched by the player, we can use
			// cueVideoById, loadVideoById, cueVideoByUrl and loadVideoByUrl
			// to load a particular YouTube video.
			player = loader.content;
			// Set appropriate player dimensions for your application
			player.setSize(viewWidth, viewHeight);
		}
		
		protected function onPlayerError(event:Event):void {
			// Event.data contains the event parameter, which is the error code
			trace("player error:", Object(event).data);
		}
		
		protected function onPlayerStateChange(event:Event):void {
			// Event.data contains the event parameter, which is the new player state
			trace("player state:", Object(event).data);
		}
		
		protected function onVideoPlaybackQualityChange(event:Event):void {
			// Event.data contains the event parameter, which is the new video quality
			trace("video quality:", Object(event).data);
		}
		*/
	}
}
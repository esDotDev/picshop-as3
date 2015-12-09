package ca.esdot.picshop.commands
{
	import flash.display.BitmapData;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.registerClassAlias;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import ca.esdot.lib.data.TweenConstants;
	import ca.esdot.lib.image.ImageBorders;
	import ca.esdot.lib.image.ImageFilters;
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.MainView;
	import ca.esdot.picshop.commands.events.ShowTipEvent;
	import ca.esdot.picshop.commands.events.StartEditEvent;
	import ca.esdot.picshop.data.UnlockableFeatures;
	import ca.esdot.picshop.editors.AbstractEditor;
	import ca.esdot.picshop.editors.AdvancedBorderEditor;
	import ca.esdot.picshop.editors.AutoCorrectEditor;
	import ca.esdot.picshop.editors.BasicBorderEditor;
	import ca.esdot.picshop.editors.BasicFilterEditor;
	import ca.esdot.picshop.editors.BgFillEditor;
	import ca.esdot.picshop.editors.BlemishEditor;
	import ca.esdot.picshop.editors.BrightnessEditor;
	import ca.esdot.picshop.editors.ColorChannelsEditor;
	import ca.esdot.picshop.editors.ColorEditor;
	import ca.esdot.picshop.editors.CropEditor;
	import ca.esdot.picshop.editors.DrawingEditor;
	import ca.esdot.picshop.editors.FishEyeEditor;
	import ca.esdot.picshop.editors.FocusEditor;
	import ca.esdot.picshop.editors.ImageLayerEditor;
	import ca.esdot.picshop.editors.MemeEditor;
	import ca.esdot.picshop.editors.NoiseFilterEditor;
	import ca.esdot.picshop.editors.RedEyeEditor;
	import ca.esdot.picshop.editors.RotateEditor;
	import ca.esdot.picshop.editors.SharpnessEditor;
	import ca.esdot.picshop.editors.SpeechLayerEditor;
	import ca.esdot.picshop.editors.StraightenEditor;
	import ca.esdot.picshop.editors.TeethWhiteningEditor;
	import ca.esdot.picshop.editors.TextLayerEditor;
	import ca.esdot.picshop.editors.TextureFilterEditor;
	import ca.esdot.picshop.editors.TiltShiftEditor;
	import ca.esdot.picshop.events.EditorEvent;
	import ca.esdot.picshop.events.ModelEvent;
	import ca.esdot.picshop.events.UnlockEvent;
	import ca.esdot.picshop.menus.BasicToolsMenuTypes;
	import ca.esdot.picshop.menus.ExtrasMenuTypes;
	import ca.esdot.picshop.views.EditView;
	
	import org.robotlegs.mvcs.Command;
	
	public class EditImageCommand extends Command
	{
		[Inject]
		public var event:StartEditEvent;
		
		[Inject]
		public var mainModel:MainModel;
		
		protected static var editCount:int = 0;

		protected var editView:EditView;
		protected var originalBitmap:BitmapData;
		protected var mainView:MainView;
		protected var editor:AbstractEditor;
		protected var newEditorPending:Boolean;
		
		override public function execute():void {
			commandMap.detain(this);
			
			mainView = (contextView as MainView);
			mainView.fullScreen = true;
			mainView.click();
			mainView.stage.addEventListener(Event.RESIZE, onStageResized, false, 0, true);
			
			editView = (contextView as MainView).editView;
			editView.fullscreen = true;
			
			initEditor();
			
			eventDispatcher.addEventListener(ModelEvent.APP_UNLOCKED, onAppUnlocked, false, 0, true);
			
			originalBitmap = editView.imageView.currentBitmap;
			//Give edit view some time to transition out
			setTimeout(enableEditor, (TweenConstants.NORMAL * 1000) + 100);
		}
	
		
		protected function initEditor():void {
			editor = createEditor();
			
			editor.mouseEnabled = editor.mouseChildren = false;
			editor.setSize(editView.viewWidth, editView.viewHeight);
			editor.transitionIn();
			editor.scaleImageView();
			editor.addEventListener(EditorEvent.APPLY, onEditorApply, false, 0, true);
			editor.addEventListener(EditorEvent.DISCARD, onEditorDiscard, false, 0, true);
			editor.addEventListener(EditorEvent.UNDO, onEditorUndo, false, 0, true);
			editor.addEventListener(UnlockEvent.UNLOCK, dispatch, false, 0, true);
			editView.addChild(editor);
			
			mainModel.currentEditor = editor;
		}
		
		protected function onStageResized(event:Event):void {
			if(!editor){ return; }
			
			//Disard
			//if(editor is StraightenEditor){
				onEditorDiscard();
			//} else { 
			//Resize Editor
				//editor.setSize(editView.viewWidth, editView.viewHeight);
				//editor.scaleImageView(true);
			//}
			
		}
		
		protected function replaceEditor():void {
			if(newEditorPending){ return; }
			newEditorPending = true;
			if(editor){
				editor.destroy();
				editView.removeChild(editor);
			
				editor.removeEventListener(EditorEvent.APPLY, onEditorApply);
				editor.removeEventListener(EditorEvent.DISCARD, onEditorDiscard);
				editor.removeEventListener(EditorEvent.UNDO, onEditorUndo);
				editor.removeEventListener(UnlockEvent.UNLOCK, dispatch);
			}
			
			initEditor();
			
		}
		
		protected function onAppUnlocked(event:ModelEvent):void {
			editor.isLocked = false;
			editor.showAd(false);
		}
		
		protected function createEditor():AbstractEditor {
			//Assign an Extras Editor
			mainModel.isPreviewEnabled = false;
			
			if(event.type == StartEditEvent.EXTRAS){
				
				switch(event.editType){
					case ExtrasMenuTypes.BG_FILL:
						editor = new BgFillEditor(editView);
						break;
					
					case ExtrasMenuTypes.ADD_IMAGE:
						editor = new ImageLayerEditor(editView, event.image, ImageLayerEditor.CONTROLS_BLEND);
						(editor as ImageLayerEditor).lockRatio = true;
						break;
					
					case ExtrasMenuTypes.TEXT:
						editor = new TextLayerEditor(editView);
						break;
					
					case ExtrasMenuTypes.SPEECH_BUBBLES:
						editor = new SpeechLayerEditor(editView, event.image);
						break;
					
					case ExtrasMenuTypes.STICKERS:
						editor = new ImageLayerEditor(editView, event.image);
						break;
					
					case ExtrasMenuTypes.DRAWING:
						editor = new DrawingEditor(editView);
						break;
					
					case ExtrasMenuTypes.MEME:
						editor = new MemeEditor(editView);
						break;
					
					case ExtrasMenuTypes.COLOR_CHANNELS:
						editor = new ColorChannelsEditor(editView);
						break;
				}
				editor.isLocked = mainModel.isFeatureLocked(UnlockableFeatures.EXTRAS);
				
			}
			//Assign a Border Editor
			else if(event.type == StartEditEvent.BORDER){
				if(event.editType == ImageBorders.PATTERNS){
					editor = new AdvancedBorderEditor(editView, event.editType);
				} else {
					editor = new BasicBorderEditor(editView, event.editType);
				}
				editor.isLocked = mainModel.isFeatureLocked(UnlockableFeatures.FRAMES);
			}
			//Assign a Filter Editor
			else if(event.type == StartEditEvent.FILTER){
				switch(event.editType){
					case ImageFilters.TEXTURE:
						editor = new TextureFilterEditor(editView);
						break;
					
					case ImageFilters.NOISE:
						editor = new NoiseFilterEditor(editView);
						break;
					
					default:
						editor = new BasicFilterEditor(editView, event.editType);
						break;
				}
				//editor.isLocked = mainModel.isAppLocked;
			}
			//Assign a basic editor
			else if(event.type == StartEditEvent.BASIC){
				
				switch(event.editType){
					
					case BasicToolsMenuTypes.FOCUS:
						editor = new FocusEditor(editView);
						break;
					
					case BasicToolsMenuTypes.STRAIGHTEN:
						editor = new StraightenEditor(editView);
						break;
					
					case BasicToolsMenuTypes.TILT_SHIFT:
						editor = new TiltShiftEditor(editView);
						break;
					
					case BasicToolsMenuTypes.FISH_EYE:
						editor = new FishEyeEditor(editView);
						break;
					
					case BasicToolsMenuTypes.BRIGHTNESS:
						editor = new BrightnessEditor(editView);
						break;
					
					case BasicToolsMenuTypes.AUTOFIX:
						editor = new AutoCorrectEditor(editView);
						break;
					
					case BasicToolsMenuTypes.COLOR:
						editor = new ColorEditor(editView);
						break;
					
					case BasicToolsMenuTypes.SHARPNESS:
						editor = new SharpnessEditor(editView);
						break;
					
					case BasicToolsMenuTypes.CROP:
						editor = new CropEditor(editView);
						break;
					
					case BasicToolsMenuTypes.ROTATE:
						editor = new RotateEditor(editView);
						break;
					
					case BasicToolsMenuTypes.FIX_BLEMISH:
						editor = new BlemishEditor(editView);
						break;
					
					case BasicToolsMenuTypes.FIX_TEETH:
						editor = new TeethWhiteningEditor(editView);
						break;
					
					case BasicToolsMenuTypes.FIX_REDEYE:
						editor = new RedEyeEditor(editView);
						break;
					
				}
			} 
			return editor;
		}
		
		protected function onEditorUndo(event:Event):void {
			if(++mainModel.settings.numUndo == 3 && mainModel.settings.numOpenImage <= 3){
				//dispatch(new ShowTipEvent(ShowTipEvent.UNDO_BUTTON_DRAG, editor.undoButton));
			}
		}
		
		protected function onEditorApply(event:EditorEvent):void {
			mainView.click();
			if(editor.isLocked){
				dispatch(new UnlockEvent(UnlockEvent.UNLOCK));
			} else {
				editor.transitionOut();
				mainView.isLoading = true;
				
				setTimeout(applyToSource, 100);
				
			}	
		}
		
		protected function applyToSource():void {
			mainModel.sourceData = editor.applyToSource();	
			editor.destroy();
			
			mainModel.addHistory(mainModel.sourceData);
			
			//Write scratch file to disk
			mainModel.updateScratchFile();
			
			System.pauseForGCIfCollectionImminent(0);
			
			//IF Filter or Border, close the menu
			if(event.type == StartEditEvent.BORDER || event.type == StartEditEvent.FILTER){
				editView.closeEditMenu();
			}
			
			setTimeout(endEdit, 500);
		}
		
		protected function onEditorDiscard(event:EditorEvent = null):void {
			
			mainView.click();
			editView.imageView.setCurrentBitmap(originalBitmap);
			try {
				editor.transitionOut();
				editor.destroy();
			} catch(e:Error){}
			setTimeout(endEdit, TweenConstants.SHORT);
		}
		
		protected function endEdit():void {
			
			mainView.isLoading = false;
			mainView.fullScreen = false;
			
			editView.fullscreen = false;
			
			mainModel.currentEditor = null;
			mainModel.isPreviewEnabled = true;
			mainModel.applyCount++;
			
			commandMap.release(this);
			
			mainView.stage.removeEventListener(Event.RESIZE, onStageResized);
			eventDispatcher.removeEventListener(ModelEvent.APP_UNLOCKED, onAppUnlocked);
			
			//Show Tips?
			if(mainModel.settings.numOpenImage == 1){
				
				if(mainModel.applyCount == 4 && mainModel.historyIndex > 1){
					setTimeout(function(){
						dispatch(new ShowTipEvent(ShowTipEvent.COMPARE, mainView.topMenu.compareButton));
					}, TweenConstants.NORMAL * 1000); 
				}
				else if(mainModel.applyCount == 2){
					setTimeout(function(){
							dispatch(new ShowTipEvent(ShowTipEvent.SAVE, editView.editMenu.saveButton));
					}, TweenConstants.NORMAL * 1000); 
				} 
			}
		
		}
		
		protected function enableEditor():void {
			editor.init();
			editor.mouseEnabled = editor.mouseChildren = true;
			
			if(editor is MemeEditor){
				dispatch(new ShowTipEvent(ShowTipEvent.MEME, (editor as MemeEditor).bgTop));
			}
			/*
			if(mainModel.isAppLocked){
				var frequency:int = 3;
				if(mainModel.settings.numSaves > 6){ frequency = 1; }
				else if(mainModel.settings.numSaves > 3){ frequency = 2; }
				
				if(++editCount%frequency == 0){
					editor.showAd(true);
				}
			}
			*/
			
			if(mainModel.applyCount == 2){
				setTimeout(function(){
					dispatch(new ShowTipEvent(ShowTipEvent.PINCH_TO_ZOOM, editView.imageView.container));
				}, TweenConstants.LONG * 1500);
			}
		}
	}
}
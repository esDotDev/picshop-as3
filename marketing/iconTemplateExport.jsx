// reference the current document open
var doc = app.activeDocument;
var layers = app.activeDocument.layers

var savedState = doc.activeHistoryState;

doc.suspendHistory("Start Export", "nada()"); //Need to insert and empty history state to properly allow us to revert
doc.suspendHistory("Complete Export", "exportImages()");

//doc.activeHistoryState = doc.historyStates[0];
doc.activeHistoryState = savedState;

function exportImages () {
	
	//layers.getByName("background").visible = false;
    //layers.getByName("previews").visible = false;
    
    //doc.trim(TrimType.TRANSPARENT);
	resizeAndSave(1024);
	resizeAndSave(512);
    resizeAndSave(480);
    resizeAndSave(152);
	resizeAndSave(144);
	resizeAndSave(120);
    resizeAndSave(114);
    resizeAndSave(100);
    resizeAndSave(96);
    resizeAndSave(80);
    resizeAndSave(76);
    resizeAndSave(72);
	resizeAndSave(58);
    resizeAndSave(57);
    resizeAndSave(50);
    resizeAndSave(48);
    resizeAndSave(40);
    resizeAndSave(36);
    resizeAndSave(29);

  //  layers.getByName("background").visible = true;
  //  layers.getByName("previews").visible = true;
};


function resizeAndSave(size, name){
    var options = new ExportOptionsSaveForWeb();
    options.format = SaveDocumentType.PNG; 
    options.PNG8 = false; // use PNG-24
    options.transparency = true;
    doc.info = null;  // delete metadata

    var prefix = "";//(size == 1024 || size == 512 || size == 480)? "store-icon" : "icon";
    
    doc.resizeImage(size,size, null, ResampleMethod.BICUBICSHARPER);
    if(!name){
        doc.exportDocument(new File(doc.path + "/"+prefix+""+size+".png"), ExportType.SAVEFORWEB, options);
    } else {
        doc.exportDocument(new File(doc.path + "/"+prefix+""+name+".png"), ExportType.SAVEFORWEB, options);
    }

    // Undo Resize so we are working with crisp resizing.
    app.activeDocument.activeHistoryState = app.activeDocument.historyStates[app.activeDocument.historyStates.length - 1];          

 }


function nada(){};
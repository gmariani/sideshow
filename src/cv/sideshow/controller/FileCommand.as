////////////////////////////////////////////////////////////////////////////////
//
//  COURSE VECTOR
//  Copyright 2008 Course Vector
//  All Rights Reserved.
//
//  NOTICE: Course Vector permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package cv.sideshow.controller {
	
	import flash.display.BitmapData;
	import gs.TweenLite;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	import cv.sideshow.ApplicationFacade;
	import cv.sideshow.model.FileProxy;
	import cv.sideshow.view.FrameMediator;
	import cv.sideshow.view.MenuMediator;
	import cv.sideshow.view.MetaDataMediator;
	import cv.sideshow.view.VideoMediator;
	import cv.sideshow.view.StageMediator;
	
	public class FileCommand extends SimpleCommand implements ICommand {
		
		override public function execute(note:INotification):void {
			var vM:VideoMediator = facade.retrieveMediator(VideoMediator.NAME) as VideoMediator;
			var fM:FrameMediator = facade.retrieveMediator(FrameMediator.NAME) as FrameMediator;
			var mM:MetaDataMediator = facade.retrieveMediator(MetaDataMediator.NAME) as MetaDataMediator;
			var meM:MenuMediator = facade.retrieveMediator(MenuMediator.NAME) as MenuMediator;
			var sM:StageMediator = facade.retrieveMediator(StageMediator.NAME) as StageMediator;
			var fP:FileProxy = facade.retrieveProxy(FileProxy.NAME) as FileProxy;
			var o:Object = note.getBody() as Object;
			
			switch(note.getName()) {
				case ApplicationFacade.FILE_UPDATE :
					ApplicationFacade.HAS_FILE = o.hasFile;
					meM.setHasFile(o.hasFile);
					
					if (o.hasFile) {
						fM.setTitle(o.name);
						mM.setTitle(o.name);
					} else {
						mM.setTitle();
					}
					sendNotification(ApplicationFacade.SHOW_FRAME);
					break;
				case ApplicationFacade.OPEN :
					fP.browseForOpen();
					break;
				case ApplicationFacade.SAVE :
					fP.browseForSave();
					break;
				case ApplicationFacade.SAVE_SS :
					var bmd:BitmapData = vM.getBitMapData();
					sendNotification(ApplicationFacade.CONTROL_PAUSE, true);
					fP.browseForSaveSS(bmd);
					sM.validateSetOnTop(false);
					break;
			}
		}
	}
}
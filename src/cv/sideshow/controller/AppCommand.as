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
	
	import gs.TweenLite;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	import cv.sideshow.ApplicationFacade;
	import cv.sideshow.model.TempoProxy;
	import cv.sideshow.view.MenuMediator;
	import cv.sideshow.view.StageMediator;
	import cv.sideshow.view.VideoMediator;
	
	public class AppCommand extends SimpleCommand implements ICommand {
		
		override public function execute(note:INotification):void {
			var mM:MenuMediator = facade.retrieveMediator(MenuMediator.NAME) as MenuMediator;
			var sM:StageMediator = facade.retrieveMediator(StageMediator.NAME) as StageMediator;
			var vM:VideoMediator = facade.retrieveMediator(VideoMediator.NAME) as VideoMediator;
			var tP:TempoProxy = facade.retrieveProxy(TempoProxy.NAME) as TempoProxy;
			var o:Object = note.getBody() as Object;
			
			switch(note.getName()) {
				case ApplicationFacade.UPDATE :
					if (o && o.hasOwnProperty("alpha")) {
						sM.appAlpha = o.alpha;
						mM.setSeeThru((o.alpha < 1) ? true : false);
					}
					if (ApplicationFacade.HAS_FILE) {
						if(ApplicationFacade.CURRENT_FILE) {
							if(ApplicationFacade.CURRENT_FILE.exists) {
								if (tP.validateFormat(ApplicationFacade.CURRENT_FILE)) {
									if (!tP.isAudio(ApplicationFacade.CURRENT_FILE)) {
										sM.videoMode();
										TweenLite.to(vM.screen, .5, { autoAlpha:sM.appAlpha } );
									} else {
										sM.audioMode();
										TweenLite.to(vM.screen, .5, { autoAlpha:0 } );
									}
								} else {
									sM.showError("format");
								}
							} else {
								sM.showError("exists");
							}
						} else if (!ApplicationFacade.CURRENT_FILE && ApplicationFacade.CURRENT_URL) {
							if (!tP.isAudioURL(ApplicationFacade.CURRENT_URL.extension)) {
								sM.videoMode();
								TweenLite.to(vM.screen, .5, { autoAlpha:sM.appAlpha } );
							} else {
								sM.audioMode();
								TweenLite.to(vM.screen, .5, { autoAlpha:0 } );
							}
						}
					} else {
						if(sM.isInitialized) sM.defaultMode();
						TweenLite.to(vM.screen, .5, { autoAlpha:0 } );
					}
					break;
			}
		}
	}
}
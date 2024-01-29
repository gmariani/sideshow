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
/**
* Initializes the Model and Views and their sub components
* Initializes the StageMediator and passes the stage reference
* Initializes the proxies
* 
* @author Gabriel Mariani
* @version 0.1
*/

package cv.sideshow.controller {
	
	import flash.filesystem.File;
	import flash.media.Video;
	import gs.TweenLite;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	import cv.sideshow.ApplicationFacade;
	import cv.sideshow.model.TempoProxy;
	import cv.sideshow.view.PlaylistMediator;
	import cv.sideshow.view.StageMediator;
	import cv.sideshow.view.VideoMediator;
	import cv.sideshow.view.MenuMediator;
	
	public class TempoCommand extends SimpleCommand implements ICommand {
		
		override public function execute(note:INotification):void {
			var sM:StageMediator = facade.retrieveMediator(StageMediator.NAME) as StageMediator;
			var vM:VideoMediator = facade.retrieveMediator(VideoMediator.NAME) as VideoMediator;
			var mM:MenuMediator = facade.retrieveMediator(MenuMediator.NAME) as MenuMediator;
			var tP:TempoProxy = facade.retrieveProxy(TempoProxy.NAME) as TempoProxy;
			var o:Object = note.getBody();
			var f:File;
			
			switch(note.getName()) {
				case ApplicationFacade.VALIDATE_VIDEO :
					vM.validateVideo(o);
					mM.validateVideo(o);
					break;
				case ApplicationFacade.OPEN_FILE :
					f = note.getBody() as File;
					ApplicationFacade.CURRENT_FILE = f;
					ApplicationFacade.CURRENT_URL = null;
					sM.hideError();
					
					if(f.exists) {
						if (tP.validateFormat(f)) {
							sendNotification(ApplicationFacade.FILE_UPDATE, {hasFile:true, name:f.name});
							sendNotification(ApplicationFacade.UPDATE);
							tP.loadMedia({url:f.url});
						} else {
							sM.showError("format");
							sendNotification(ApplicationFacade.CLOSE_FILE);
						}
					} else {
						sM.showError("exists");
						sendNotification(ApplicationFacade.CLOSE_FILE);
					}
					break;
				case ApplicationFacade.ADD_FILE :
					tP.addItem(note.getBody());
					break;
				case ApplicationFacade.OPEN_ITEM :
					if (o) {
						if (String(o.url).indexOf("http://") > -1) {
							ApplicationFacade.CURRENT_FILE = null;
							ApplicationFacade.CURRENT_URL = {name:o.url, extension:o.extOverride};
							sM.hideError();
							sendNotification(ApplicationFacade.FILE_UPDATE, { hasFile:true, name:o.url } );
							sendNotification(ApplicationFacade.UPDATE);
							tP.playItem(o.index);
						} else {
							try {
								f = new File(o.url);
							} catch (e:Error) {
								sM.showError("exists");
								sendNotification(ApplicationFacade.CLOSE_FILE);
								break;
							}
							
							ApplicationFacade.CURRENT_FILE = f;
							ApplicationFacade.CURRENT_URL = null;
							sM.hideError();
							
							if(f.exists) {
								if (tP.validateFormat(f)) {
									sendNotification(ApplicationFacade.FILE_UPDATE, { hasFile:true, name:f.name } );
									sendNotification(ApplicationFacade.UPDATE);
									tP.playItem(o.index);
								} else {
									sM.showError("format");
									sendNotification(ApplicationFacade.CLOSE_FILE);
								}
							} else {
								sM.showError("exists");
								sendNotification(ApplicationFacade.CLOSE_FILE);
							}
						}
					}
					break;
				case ApplicationFacade.CHECK_FOR_PLAYLIST :
					tP.checkIfPlayList();
					break;
				case ApplicationFacade.CLOSE_FILE :
					sM.closeFile();
					tP.closeFile();
					tP.clearList();
					sendNotification(ApplicationFacade.FILE_UPDATE, {hasFile:false});
					sendNotification(ApplicationFacade.UPDATE);
					sendNotification(ApplicationFacade.VIDEO_RESET_SIZE);
					break;
				case ApplicationFacade.REMOVE_FILE :
					tP.removeItem(note.getBody() as int);
					break;
				case ApplicationFacade.OPEN_PLAYLIST :
					tP.loadPlayList(note.getBody() as String);
					break;
				case ApplicationFacade.CONTROL_VOLUME :
					tP.volume = note.getBody() as Number;
					break;
				case ApplicationFacade.CONTROL_VOLUME_INCREMENT :
					tP.volume += .1 * int(note.getBody());
					break;
				case ApplicationFacade.SET_SCREEN :
					tP.setVideoScreen(note.getBody() as Video);
					break;
				case ApplicationFacade.EXITING :
					TweenLite.to(tP, .5, { volume:0 } );
					break;
				case ApplicationFacade.CONTROL_PAUSE_TOGGLE :
					tP.pause(!tP.isPause);
					break;
				case ApplicationFacade.CONTROL_PAUSE :
					var b:Boolean = note.getBody() as Boolean;
					if (tP.isPause == true && b == false) {
						tP.pause(false);
					} else if (tP.isPause == false && b == true) {
						tP.pause(true);
					} else {
						tP.play();
					}
					break;
				case ApplicationFacade.CONTROL_PLAY :
					tP.play();
					break;
				case ApplicationFacade.CONTROL_STOP :
					tP.stop();
					sM.validateSetOnTop(false);
					break;
				case ApplicationFacade.CONTROL_NEXT :
					sendNotification(ApplicationFacade.OPEN_ITEM, tP.getNext());
					break;
				case ApplicationFacade.CONTROL_PREVIOUS :
					sendNotification(ApplicationFacade.OPEN_ITEM, tP.getPrevious());
					break;
				case ApplicationFacade.CONTROL_SEEK :
					tP.seekPercent(note.getBody() as Number);
					break;
				case ApplicationFacade.CONTROL_SEEK_RELATIVE :
					tP.seekRelative(note.getBody() as Number);
					break;
				case ApplicationFacade.CONTROL_REPEAT :
					tP.repeat = note.getBody() as String;
					break;
				case ApplicationFacade.CONTROL_MUTE :
					tP.setMute(note.getBody() as Boolean);
					break;
				case ApplicationFacade.CONTROL_SHUFFLE :
					tP.shuffle = note.getBody() as Boolean;
					break;
				case ApplicationFacade.CONTROL_SWAP_CHANNELS :
					tP.swapChannels(note.getBody() as Boolean);
					break;
			}
		}
	}
}
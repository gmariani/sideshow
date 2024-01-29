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
	
	import cv.sideshow.view.URLMediator;
	import flash.display.DisplayObjectContainer;
	import flash.media.Video;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	import cv.sideshow.ApplicationFacade;
	import cv.sideshow.model.UpdateProxy;
	import cv.sideshow.model.FileProxy;
	import cv.sideshow.model.AppProxy;
	import cv.sideshow.model.TempoProxy;
	import cv.sideshow.view.StageMediator;
	import cv.sideshow.view.UpdateMediator;
	import cv.sideshow.view.MetaDataMediator;
	import cv.sideshow.view.AboutMediator;
	import cv.sideshow.view.PlaylistMediator;
	import cv.sideshow.view.CustomAspectMediator;
	import cv.sideshow.view.MenuMediator;
	import cv.sideshow.view.VideoMediator;
	
	import flash.display.NativeWindow;
	
	public class StartupCommand extends SimpleCommand implements ICommand {
		
		override public function execute(note:INotification):void {
			
			//--------------------------------------
			//  Model
			//--------------------------------------
			
			facade.registerProxy(new UpdateProxy());
			
			facade.registerProxy(new AppProxy());
			
			facade.registerProxy(new FileProxy());
			
			facade.registerProxy(new TempoProxy());
			
			//--------------------------------------
			//  View
			//--------------------------------------
			
			var stage:DisplayObjectContainer = note.getBody() as DisplayObjectContainer;
			
			facade.registerMediator(new PlaylistMediator(new PlaylistScreen()));
			
			facade.registerMediator(new MetaDataMediator(new MetaDataScreen()));
			
			facade.registerMediator(new UpdateMediator(new UpdateScreen()));
			
			facade.registerMediator(new AboutMediator(new AboutScreen()));
			
			facade.registerMediator(new URLMediator(new URLScreen()));
			
			facade.registerMediator(new CustomAspectMediator(new CustomAspectScreen()));
			
			facade.registerMediator(new MenuMediator(stage));
			
			facade.registerMediator(new VideoMediator(stage.getChildByName("vidScreen") as Video));
			
			var sM:StageMediator = new StageMediator(stage);
			facade.registerMediator(sM);
			
			sendNotification(ApplicationFacade.UPDATE);
			sendNotification(ApplicationFacade.FILE_UPDATE, {hasFile:false});
			sendNotification(ApplicationFacade.VIDEO_RESET_SIZE);
			sendNotification(ApplicationFacade.CHECK_FOR_PLAYLIST);
			sendNotification(ApplicationFacade.INITIALIZED);
		}
	}
}
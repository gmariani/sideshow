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
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	import cv.sideshow.ApplicationFacade;
	import cv.sideshow.model.UpdateProxy;
	
	public class UpdateCommand extends SimpleCommand implements ICommand {
		
		override public function execute(note:INotification):void {
			var u:UpdateProxy = facade.retrieveProxy(UpdateProxy.NAME) as UpdateProxy;
			
			switch(note.getName()) {
				case ApplicationFacade.INITIALIZED :
				case ApplicationFacade.UPDATE_CHECK :
					u.check();
					break;
				case ApplicationFacade.UPDATE_INSTALL :
					u.update();
					break;
			}
		}
	}
}
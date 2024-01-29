package cv.managers {
	
	import flash.desktop.NativeApplication;
	import flash.desktop.Updater;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.events.IOErrorEvent;
	import flash.errors.IOError;
	
	public class UpdateManager extends EventDispatcher {
		
		public static const CHECK_FOR_UPDATE:String = "CHECK_FOR_UPDATE";
		public static const AVAILABLE:String = "AVAILABLE";
		public static const NONE_AVAILABLE:String = "NONE_AVAILABLE";
		public static const DOWNLOAD_START:String = "DOWNLOAD_START";
		public static const DOWNLOAD_ERROR:String = "DOWNLOAD_ERROR";
		public static const DOWNLOAD_COMPLETE:String = "DOWNLOAD_COMPLETE";
		public static const BEFORE_INSTALL:String = "BEFORE_INSTALL";
		public static const UPDATE_ERROR:String = "UPDATE_ERROR";
		
		private var appId:String;
		private var appVersion:String;
		private var appName:String;
		private var _updateURL:String;
		private var _fileURL:String;
		private var _description:String;
		private var _remoteVersion:String;
		private var _compare:Function;
		private var newFile:File;
		private var loader:URLLoader;
		private static const _instance:UpdateManager = new UpdateManager();
		
		public function UpdateManager() {
			if( _instance ) throw new Error( "Invalid Singleton access.  Use Model.instance." ); 
			
			var appXML:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var air:Namespace = appXML.namespaceDeclarations()[0]; // Define the Namespace
			appId = appXML.air::id;
			appVersion = appXML.air::version;
			appName = appXML.air::name;
			
			_compare = function(local:String, remote:String):Boolean {
				var arrLocal:Array = local.split(".");
				var arrRemote:Array = remote.split(".");
				
				if (parseInt(arrLocal[0]) < parseInt(arrRemote[0])) {
					return true;
				} else if(parseInt(arrLocal[0]) > parseInt(arrRemote[0])) {
					return false;
				} else {
					if (parseInt(arrLocal[1]) < parseInt(arrRemote[1])) {
						return true;
					} else if (parseInt(arrLocal[1]) > parseInt(arrRemote[1])) {
						return false;
					} else {
						if (parseInt(arrLocal[2]) < parseInt(arrRemote[2])) {
							return true;
						}
					}
				}
				return false;
			};
		}
		
		public static function get instance():UpdateManager {
			return _instance;
		}
		
		public function get currentVersion():String {
			return appVersion;
		}
		
		public function get currentName():String {
			return appName;
		}
		
		public function get remoteVersion():String {
			return _remoteVersion;
		}
		
		public function get description():String {
			return _description;
		}
		
		/**
		 * Needs to accept two parameters, currentVersion:String, and remoteVersion:String
		 * and return a boolean.
		 * True for a valid new version, false if not
		 */
		public function get isNewerVersionFunction():Function {
			return _compare;
		}
		public function set isNewerVersionFunction(f:Function):void {
			_compare = f;
		}
		
		public function get updateURL():String {
			return _updateURL;
		}
		public function set updateURL(str:String):void {
			_updateURL = str;
		}
		
		public function checkNow():void {
			var ldr:URLLoader = new URLLoader();
			ldr.addEventListener(Event.COMPLETE, checkHandler);
			ldr.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			
			try {
				dispatchEvent(new Event(CHECK_FOR_UPDATE));
				ldr.load(new URLRequest(_updateURL));
			} catch (error:Error) {
				trace("UpdateManager::checkNow - Error : Unable to load " + _updateURL + " for version checking.");
			} catch (error:IOError) {
				trace("UpdateManager::checkNow - IOError : Unable to load " + _updateURL + " for version checking.");
			}
		}
		
		public function downloadUpdate():void {
			if(_remoteVersion) {
				try {
					dispatchEvent(new Event(DOWNLOAD_START));
					loader = new URLLoader();
					loader.dataFormat = URLLoaderDataFormat.BINARY;
					loader.addEventListener(Event.COMPLETE, loadHandler);
					loader.addEventListener(ProgressEvent.PROGRESS, loadHandler);
					loader.addEventListener(IOErrorEvent.IO_ERROR, loadHandler);
					loader.load(new URLRequest(_fileURL));
				} catch (error:Error) {
					trace("UpdateManager::downloadUpdate - Error : Unable to load " + _fileURL + " for updating.");
				}
			} else {
				trace("UpdateManager::downloadUpdate - Error : Please call checkForUpdate() before calling getUpdate().");
			}
		}
		
		private function errorHandler(event:IOErrorEvent):void {
			trace("UpdateManager::checkNow - IOError : Unable to load " + _updateURL + " for version checking.");
		}
		
		public function installUpdate():void {
			dispatchEvent(new Event(BEFORE_INSTALL));
			
			try {
				var updater:Updater = new Updater();
				updater.update(newFile, _remoteVersion);
			} catch (error:Error) {
				dispatchEvent(new Event(UPDATE_ERROR));
				trace("UpdateManager::installUpdate - Error : Unable to update.");
			}
		}
		
		public function cancelUpdate():void {
			loader.close();
			newFile = File.createTempFile();
		}
		
		private function checkHandler(event:Event):void {
			try {
				var loader:URLLoader = URLLoader(event.target);
				var xmlData:XML = XML(loader.data);
				var update:Namespace = xmlData.namespaceDeclarations()[0]; // Define the Namespace
				_remoteVersion = xmlData.update::version;
				_fileURL = xmlData.update::url;
				_description = xmlData.update::description;
				
				if (_compare(appVersion, _remoteVersion) == true) {
					dispatchEvent(new Event(AVAILABLE));
				} else {
					dispatchEvent(new Event(NONE_AVAILABLE));
				}
			} catch (error:Error) {
				trace("UpdateManager::checkForUpdate - Error : Unable to get file from server.");
			}
		}
		
		private function loadHandler(event:Event):void {
			if (event.type == ProgressEvent.PROGRESS) {
				dispatchEvent(event.clone());
			} else if (event.type == IOErrorEvent.IO_ERROR) {
				dispatchEvent(new Event(DOWNLOAD_ERROR));
				trace("UpdateManager::downloadUpdate - Error : Unable to get file from server.");
			} else {
				newFile = File.createTempFile();
				var loader:URLLoader = URLLoader(event.target);
				var fs:FileStream = new FileStream();
				fs.open(newFile, FileMode.WRITE);
				fs.writeBytes(loader.data, 0, loader.bytesTotal);
				fs.close();
				
				dispatchEvent(new Event(DOWNLOAD_COMPLETE));
				
				installUpdate();
			}
		}
	}
}
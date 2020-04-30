package tg {
	import air.update.ApplicationUpdaterUI;
	import fl.controls.Button;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import gs.easing.Circ;
	import gs.TweenLite;
	import tg.encry.*;
	import tg.plug.Alert;
	import tg.usb.IWindow;
	/**
	 * 个人工具集
	 * @author jempty 2013-9-10
	 * @author 2013-12-5 增加了png转换工具
	 * @author 2014-5-14 增加了背景抠图工具
	 * @author 2014-5-27 增加了swf转exe工具、文件压缩工具
	 * @author 2014-5-29 增加了swc合并工具
	 * @author 2014-7-28 增加了图标制作工具
	 */
	public class Jtools extends Sprite {
		public var swcBtn:Button, aneBtn:Button, adtBtn:Button;
		public var findBtn:Button, swiftBtn:Button, asdocBtn:Button;
		public var pngBtn:Button;
		private var loader:Loader = new Loader();
		private var window:NativeWindow;
		private var iw:Number, ih:Number;
		private var windowList:Object = { };
		private var curID:String, curTitle:String;
		private var reader:FileReader = new FileReader();
		private var separator:String;
		
		public function Jtools() {
			this.addEventListener(Event.ADDED_TO_STAGE, init);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete, false, 0, true);
			reader.readFun = fileReaded;
			separator = File.separator;
		}
		private function init(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(MouseEvent.CLICK, loadSwf);
			stage.scaleMode = "noScale";
			stage.align = "TL";
			var appUpdate:ApplicationUpdaterUI = new ApplicationUpdaterUI();  
			window = stage.nativeWindow;
			window.title = "Jtools V" + appUpdate.currentVersion;
			window.addEventListener(Event.CLOSING, closeAll, false, 0, true);
			window.x = stage.fullScreenWidth - window.width >> 1;
			window.y = stage.fullScreenHeight + window.height;
			var toy:Number = stage.fullScreenHeight - window.height >> 1;
			TweenLite.to(window, 0.8, {y:toy,ease:Circ.easeOut } );
		}
		private function closeAll(e:Event):void {
			var nwd:NativeWindow; 
			for (var id:String in windowList) {
				nwd = windowList[id];
				if (nwd) nwd.close();
			}
		}
		private function loadSwf(e:MouseEvent):void {
			e.stopPropagation();
			curID = e.target.name;
			switch(curID) {
				case "swcBtn":loadBytes("swcBuilder.swf"); curTitle = "swc编译工具"; break;
				case "aneBtn":loadBytes("aneBuilder.swf"); curTitle = "ane打包工具"; break; 
				case "adtBtn":loadBytes("adtPackager.swf"); curTitle = "adt打包工具"; break; 
				case "findBtn":loadBytes("Find.swf"); curTitle = "查找工具"; break;
				case "swiftBtn":loadBytes("Swifter.swf"); curTitle = "资源打包工具"; break; 
				case "asdocBtn":loadBytes("asdocBuilder.swf"); curTitle = "asdoc工具"; break; 
				case "pngBtn":loadBytes("PngToJpg.swf"); curTitle = "png转换工具"; break; 
				case "bgClear":loadBytes("bgClear.swf"); curTitle = "纯色背景抠图工具"; break; 
				case "swf2Btn":loadBytes("swf2exe.swf"); curTitle = "swf生成播放器文件"; break; 
				case "compBtn":loadBytes("文件压缩.swf"); curTitle = "文件压缩和解压缩工具"; break; 
				case "swcCombeBtn":loadBytes("swcCombine.swf"); curTitle = "swc合并工具"; break;
				case "gcatBtn":loadBytes("GhostCatTools.swf"); curTitle = "GhostCatTools工具"; break;
				case "unitBtn":loadBytes("单位换算.swf"); curTitle = "单位换算"; break;
				case "iconBtn":loadBytes("图标制作.swf");curTitle = "图标制作工具"; break;
			}
		}
		private function loadSwfFile(url:String):void {
			if (windowList[curID]) {
				(windowList[curID]as NativeWindow).restore();
				(windowList[curID]as NativeWindow).orderToFront();
				return;
			}
			var swfFile:File = File.applicationDirectory.resolvePath("asset" + separator + url);
			if (!swfFile.exists) {
				Alert.show(url + "文件丢失或损坏！", stage);
				return;
			}
			loader.load(new URLRequest(swfFile.nativePath));
		}
		private function loadBytes(url:String):void {
			if (windowList[curID]) {
				(windowList[curID]as NativeWindow).restore();
				(windowList[curID]as NativeWindow).orderToFront();
				return;
			}
			var swfFile:File = File.applicationDirectory.resolvePath("asset" + separator + url);
			if (!swfFile.exists) {
				Alert.show(url + "文件丢失或损坏！", stage);
				return;
			}
			reader.readFile(swfFile);
		}
		private function fileReaded(byte:ByteArray):void {
			var swfbyte:ByteArray = EncryptionUtils.unEncryption(byte);
			var context:LoaderContext = new LoaderContext();
			context.allowLoadBytesCodeExecution = true;
			loader.loadBytes(swfbyte, context);
		}
		private function loadComplete(e:Event):void {
			const info:LoaderInfo = e.currentTarget as LoaderInfo;
			iw = info.width;
			ih = info.height; 
			if(loader.contentLoaderInfo.swfVersion<10)creatWindow(loader); 
			else creatWindow(loader.content); 
			window.minimize(); 
		}
		private function creatWindow(swf:DisplayObject):void {
			var option:NativeWindowInitOptions = new NativeWindowInitOptions();
			option.maximizable = false;//禁止最大化
			option.resizable = false;//禁止调整大小
			option.systemChrome = NativeWindowSystemChrome.STANDARD;
			option.type = NativeWindowType.NORMAL;
			var nwd:NativeWindow = new NativeWindow(option);
			nwd.stage.scaleMode = "noScale";
			nwd.stage.align = "TL";
			nwd.width = 10;
			nwd.height = 10;
			nwd.x = stage.fullScreenWidth - iw >> 1;
			nwd.y = stage.fullScreenHeight - ih >> 1;
			nwd.addEventListener(Event.ACTIVATE, activateWindow);
			nwd.addEventListener(Event.CLOSING, closeingWindow);
			nwd.addEventListener(Event.CLOSE, closeWindow);
			windowList[curID] = nwd; 
			nwd.stage.addChild(swf); 
			nwd.activate();
		}
		//此事件主要针对GhostCatTools
		private function closeWindow(e:Event):void {
			//e.preventDefault();
			e.stopImmediatePropagation();
			(e.target as NativeWindow).removeEventListener(Event.CLOSE, closeWindow);
		}
		private function closeingWindow(e:Event):void {
			var nwd:NativeWindow = e.currentTarget as NativeWindow;
			//nwd.removeEventListener(Event.ACTIVATE, activateWindow);
			nwd.removeEventListener(Event.CLOSING, closeingWindow);
			var id:String = nwd.stage.getChildAt(0).name;
			try {
				var swf:DisplayObjectContainer = nwd.stage.getChildAt(1) as DisplayObjectContainer;
				(swf as IWindow).closeSave();
				JTools.killChilds(swf);
			}catch (e:Error) { 
				//if (!nwd.closed) nwd.close(); 
				nwd.stage.removeChildren();
			}
			loader.unloadAndStop();
			window.restore();
			windowList[id] = null;
		}
		private function activateWindow(e:Event):void { 
			const nwd:NativeWindow = e.currentTarget as NativeWindow;
			nwd.removeEventListener(Event.ACTIVATE, activateWindow);
			nwd.title = curTitle;
			TweenLite.to(nwd.stage, 0.5, {stageWidth:iw, stageHeight:ih, ease:Circ.easeOut } );
			var bg:Shape = new Shape();
			bg.graphics.beginFill(0xcccccc);
			bg.graphics.drawRect(0, 0, iw, ih + 50);
			bg.graphics.endFill();
			nwd.stage.addChildAt(bg, 0); 
			bg.name = curID;
		}
	}
}
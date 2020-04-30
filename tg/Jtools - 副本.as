package tg {
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
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import gs.easing.Circ;
	import gs.TweenLite;
	import tg.usb.IWindow;
	public class Jtools extends Sprite {
		public var swcBtn:Button, aneBtn:Button, batBtn:Button;
		public var findBtn:Button, swiftBtn:Button, asdocBtn:Button;
		private var loader:Loader = new Loader();
		private var window:NativeWindow;
		private var iw:Number, ih:Number;
		private var windowList:Object = { };
		private var curID:String, curTitle:String;
		
		public function Jtools() {
			this.addEventListener(Event.ADDED_TO_STAGE, init);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete,false,0,true);
		}
		private function init(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(MouseEvent.CLICK, loadSwf);
			stage.scaleMode = "noScale";
			stage.align = "TL";
			window = stage.nativeWindow;
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
				case "swcBtn":load("asset/swcBuilder.swf"); curTitle = "swc编译工具"; break;
				case "aneBtn":load("asset/aneBuilder.swf"); curTitle = "ane打包工具"; break; 
				case "batBtn":load("asset/AdtBatBuilder.swf"); curTitle = "bat生成工具"; break; 
				case "findBtn":load("asset/Find.swf"); curTitle = "查找工具"; break;
				case "swiftBtn":load("asset/Swifter.swf"); curTitle = "资源打包工具"; break; 
				case "asdocBtn":load("asset/asdocBuilder.swf"); curTitle = "asdoc工具"; break; 
			}
		}
		private function load(url:String):void {
			if (windowList[curID]) {
				(windowList[curID]as NativeWindow).restore();
				(windowList[curID]as NativeWindow).orderToFront();
				return;
			}
			loader.load(new URLRequest(url));
		}
		private function loadComplete(e:Event):void {
			const info:LoaderInfo = e.currentTarget as LoaderInfo;
			iw = info.width;
			ih = info.height;
			creatWindow(loader.content);
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
			nwd.addEventListener(Event.ACTIVATE, activateWindow,false,0,true);
			nwd.addEventListener(Event.CLOSING, closeWindow, false, 0, true);
			windowList[curID] = nwd;
			nwd.stage.addChild(swf);
			nwd.activate();
		}
		private function closeWindow(e:Event):void {
			var nwd:NativeWindow = e.currentTarget as NativeWindow;
			nwd.removeEventListener(Event.ACTIVATE, activateWindow);
			nwd.removeEventListener(Event.CLOSING, closeWindow);
			var id:String = nwd.stage.getChildAt(0).name;
			try {
				var swf:DisplayObjectContainer = nwd.stage.getChildAt(1) as DisplayObjectContainer;
				(swf as IWindow).closeSave();
				JTools.killChilds(swf);
			}catch(e:Error){}
			window.restore();
			windowList[id] = null;
		}
		private function activateWindow(e:Event):void {
			const nwd:NativeWindow = e.currentTarget as NativeWindow;
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
/*
 * Copyright 2005-2006 Anssi Piirainen
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import org.flowlib.EventDispatcher;
import org.flowplayer.ClipDescriptor;
import org.flowplayer.Config;
import org.flowplayer.FlowPlayer;
import org.flowplayer.Skin;

import LuminicBox.Log.ConsolePublisher;
import LuminicBox.Log.Logger;

/**
 * Abstract baseclass for movie clips.
 */
class org.flowplayer.NewAbstractMovieClip extends MovieClip {
	public static var logger:Logger;
	private var loader:MovieClipLoader;
	private var childClips:Array;
	var __width:Number;
	var __height:Number;
	private var dispatcher:EventDispatcher;
	private var txtFormat:TextFormat;
	private var loadingSymbols:Boolean = false;

	public function NewAbstractMovieClip() {
		this._visible = false;
		logger = new Logger();
		logger.addPublisher(new ConsolePublisher());
		logger.debug("NewAbstractMovieClip::constructor");
		
		loader = new MovieClipLoader();
		loader.addListener(this);
		
		dispatcher = new EventDispatcher();
		initClip();
		createChildren();
		loadOrAttachChildren();
	}
	
	private function initClip():Void {
		__width = _width;
		__height = _height;
		_xscale = 100;
		_yscale = 100;
		_x = 0;
		_y = 0;
	}
	
	private function loadOrAttachChildren():Void {
		childClips = new Array();
		var childDesc:Array = getChildDescriptors();
		for (var i : Number = 0; i < childDesc.length; i++) {
			var descriptor:ClipDescriptor = childDesc[i];
			childClips.push(loadOrCreateClip(descriptor));
		}
				
		// Arrange right away if only using embedded symbols for this clip
		if (! loadingSymbols) {
			if (hasSize(this)) {
				doArrange();
			}
			allChildrenCreated(childClips);
			this._visible = true;
		}
		
//		if (hasSize(this))
//			arrangeIfChildrenAvailable();
	}
	
	public function onLoadInit(target:MovieClip):Void {
		logger.error("onLoadInit(), target " + target);		
		if (target == this) return;
		if (allChildrenLoaded() && areChildrenCreated()) {
			logger.error("onLoadInit(); all children available --> arranging");
			allChildrenCreated(childClips);
			doArrange();
			this._visible = true;
			loadingSymbols = false;
		}
	}
	
	private function allChildrenLoaded():Boolean {
		return haveSize(childClips);
	}
	
	private function areChildrenCreated():Boolean {
		// possibly overridden in subclasses
		return true;
	}
	
	private function allChildrenCreated(clips:Array):Void {
		// possibly overridden in subclasses
	}

	private function loadOrCreateClip(descriptor:ClipDescriptor):MovieClip {
		if (loadableClip(descriptor)) {
			loadingSymbols = true;
			return loadImageAsClip(descriptor.getSymbolName(), descriptor.getURL());
		} else {
			var clip:MovieClip = attachMovie(descriptor.getSymbolName(), descriptor.getName(), getNextHighestDepth()); 
			logger.debug("===============> Attached " + clip + "  from symbol " + descriptor.getSymbolName());
			return clip;
		}
	}
	
	private function loadableClip(descriptor:ClipDescriptor):Boolean {
		if (descriptor.getURL() != null && ! useEmbeddedImages()) return true;
		if (descriptor.getSymbolName() == null) return true;
		return false;
	}
	
	private function createChildren():Void {
		// possibly overridden in subclasses
	}
	
	private function getChildDescriptors():Array {
//		throw new Error("getChildDescriptors(): This method must be overridden in a subclass");
		return new Array();		
	}

	public function set width(newWidth:Number):Void {
		setSize(newWidth, null);
	}
	
	public function get width():Number {
		return __width;
	}

	public function set height(newHeight:Number):Void {
		setSize(null, newHeight);
	}
	
	public function get height():Number {
		return __height;
	}
	
	public function setSize(nW:Number, nH:Number):Void {
		if (nW == __width && nH == __height) return;
		if (! (nW > 0 && nH > 0)) return;
		
		logger.info("setSize called on " + this._name + ", new size: " + nW + " x " + nH);

		_xscale = 100;
		_yscale = 100;
		if (nW != null) {
			__width = nW;
		}
		if (nH != null) {
			__height = nH;
		}
		
		onSetSize();
		doArrange();
	}
	
	private function onSetSize():Void {
		// possibly overridden in subclasses
	}
	
	private function doArrange():Void {
		if (__width == 0 || __height == 0) return;
		logger.info("calling arrange on " + this);
		arrange();
	}
	
	function arrange():Void {
		throw new Error("arrange(): This method must be overridden in a subclass");
	}
			
	function arrangeClip(clip:Object, x:Number, y:Number, width:Number, height:Number):Void {
		clip._x = x;
		clip._y = y;
		if (width != null)
			clip._width = width;
		if (height != null)
			clip._height = height;
	}

	function addEventListener(typeName:String, listener:Object):Void {
		dispatcher.addEventListener(typeName, listener);
	}
		
	function dispatchEvent(typeName:String, eventObject:Object):Void {
		dispatcher.dispatchEvent(typeName, eventObject);
	}
	
	static function drawRectangleWithBorder(clip:MovieClip, x:Number, y:Number, width:Number, height:Number, lineThickness:Number, lineRGB:Number):Void {
//		logger.debug("drawing rectangle " + width + " x " + height + " on " + clip._name);
		if (lineThickness != null)
			clip.lineStyle(lineThickness, lineRGB, 100);
		clip.moveTo(x,  y);
		clip.lineTo(width, y);
		clip.lineTo(width, height);
		clip.lineTo(x, height);
		clip.lineTo(x, y);
	}
		
	static function drawRectangle(clip:MovieClip, x:Number, y:Number, width:Number, height:Number, drawBorder:Boolean):Void {
		var lineThickness:Number = drawBorder ? 0.5 : null;
		var lineRGB:Number = drawBorder ? 0x000000: null;
		
		drawRectangleWithBorder(clip, x, y, width, height, lineThickness, lineRGB);
	}
		
	function isMouseOverClip(clip:MovieClip):Boolean {
		return clip.hitTest(_root._xmouse, _root._ymouse, true);
	}
		
	function haveSize(clips:Array):Boolean {
		if (clips == null) return true;
//		logger.error("checking clips in " + clips +  " for size");
		for (var i = 0; i < clips.length; i++) {
//			logger.error("clip " + clips[i] + " size is " + clips[i]._width);
			if (clips[i] == null || clips[i] == undefined) { 
//				logger.error("haveSize(): clip in position " + i + " is null or undefined");
				return false;
			}
			if (! (clips[i]._width > 0)) {
//				logger.error("Clip " + clips[i] + " does not have size");
				return false;
			}
		}
//		logger.error("all clips in " + clips +  " have size");
		return true;
	}
	
	function maxHeight(clips:Array):Number {
		var height:Number = 0;
		for (var i = 0; i < clips.length; i++) {
			if (clips[i]._height > height) {
				height = clips[i]._height;
				logger.debug("maxHeight:: " + clips[i]._name + " has current max " + height);
			}
		}
		return height;
	}
	
	function hasSize(clip:MovieClip):Boolean {
		return haveSize([clip]);
	}
	
	function getDefaultTextFormat():TextFormat {
		if (txtFormat == null) {
			txtFormat = new TextFormat();
			txtFormat.size = 12;
			txtFormat.italic = true;
			txtFormat.font = "vera";
		}
		return txtFormat;
	}
		
	function traceDims(clip:MovieClip, name:String) {
		logger.debug("DIMENSIONS FOR clip " + clip._name);
		logger.debug("    - width " + clip._width);
		logger.debug("    - height " + clip._height);
		logger.debug("    - X pos " + clip._x);
		logger.debug("    - Y pos " + clip._y);
	}
				
	private function loadImageAsClip(clipName:String, fileURL:String):MovieClip {
//		NewAbstractMovieClip.logger.error("Loading image " + fileURL);
		var clip:MovieClip = createEmptyMovieClip(clipName, getNextHighestDepth());
		loader.loadClip(fileURL, clip);
		return clip;
	}
	
	
	function getConfig():Config {
		return FlowPlayer.getConfig();
	}
	
	function getSkin():Skin {
		var skin:Skin = getConfig().getSkin();
		logger.debug("using skin " + skin);
		return skin;
	}
	
	function useEmbeddedImages():Boolean {
		return getConfig().useEmbeddedButtonImages();
	}
}
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

import org.flowplayer.NewAbstractMovieClip;
import org.flowplayer.ClipDescriptor;

/**
 * A scrubber that implements ProgressTracking.
 */
class org.flowplayer.ProgressTracker extends NewAbstractMovieClip {

	private static var BORDER_WIDTH:Number = 5;
	private static var PROGRESS_TO_DRAGGER_DISTANCE:Number = 5;
  
  	private var mcProgress:MovieClip;
  	private var mcProgressBorder:MovieClip;
  	private var mcDragger:MovieClip;
  	var mcMaxDrag:MovieClip;
  	
  	private var progressPercent:Number;
  	private var dragOffset:Number;
	private var prevDragValue:Number;
  	private var maxDragValue:Number;
  	private var seekPosition:Number;
	
    // The interval identifiers used with setInterval() and clearInterval()
  	private var intervalId:Number;
  	private var dragEventDispatchIntervalId:Number;

	private function createChildren():Void {
		createProgressBorder();
		createMaxDragIndicator();
		createProgressIndicator();
	}
	
	// Arrange all the elements. This method gets called when the instance is first created as well
	// as every time it is resized.
	 function arrange():Void {
	 	arrangeClip(mcProgressBorder, 0, 0, __width, __height);
	 	arrangeClip(mcProgress,       1, 1, __width, __height);
	 	arrangeClip(mcMaxDrag,        1, 1, __width, __height);
 		arrangeDragger();
 		this._width = __width;
 		this._height = __height;
	}
	
	private function arrangeDragger():Void {
		arrangeClip(mcDragger, 0, 0, null, null);
	}
	

	public function setX(newX:Number):Void {
		trace("tracker: setx to " + newX);
		_x = newX;
	}

	public function setY(newY:Number):Void {
		_y = newY;
	}

	/**
	 * @see ProgressTracking#updateProgress()
	 */
    public function updateProgress(percentage:Number):Void {
    	trace("updage progress " + percentage + ", mcProgress = " + mcProgress);
		var newWidth:Number = percentage == 0 ? 0 : 
			mcProgressBorder._width * (percentage / 100) - BORDER_WIDTH;
		mcProgress._width = newWidth < 0 ? 0 : newWidth;
		updateDraggerPos();
		progressPercent = percentage;
	}
  	
	/**
	 * @see ProgressTracking#getProgress()
	 */
	public function getProgress():Number {
		return progressPercent;
	}
  	
	/**
	 * @see ProgressTracking#getSeekPosition()
	 */
	public function getSeekPosition():Number {
		return seekPosition;
	}

	private function calculateSeekPosition():Number {
		var value:Number = (mcDragger._x / mcProgressBorder._width) * 100;
		logger.debug("calculated seek position " + value);
		return value;
	}
  	
	/**
	 * @see ProgressTracking#setMaxSeek()
	 */
  	public function setMaxSeek(percentage:Number):Void {
		updateMaxDrag(percentage);
  	}
	
	/**
	 * @see ProgressTracking#getMaxSeek()
	 */
  	public function getMaxSeek():Number {
  		return maxDragValue;
  	}
	
	/**
	 * @see ProgressTracking#addSeekListener(Object)
	 */
	public function addSeekListener(listener:Object):Void {
		trace("adding 'onSeek' listener " + listener);
		addEventListener("onSeek", listener);
	}
	
	private function createProgressIndicator() {
		createEmptyMovieClip("mcProgress", getNextHighestDepth());
		
		var color1 = getConfig().getProgressIndicatorColor1();
		var color2 = getConfig().getProgressIndicatorColor2();
		drawRectangleWithGradientFill(mcProgress, 100, 20, color1, color2, false);

		trace("created clip mcProgress " + this.mcProgress + ", width " + mcProgress._width);
	}
	
	private function drawRectangleWithGradientFill(clip:MovieClip, width:Number, height:Number, color1:Number, color2:Number, drawBorder:Boolean):Void {
		var colors = [color1, color2, color1];
		var matrix = { matrixType:"box", x:0, y:0, w:width, h:height, r:Math.PI/2 };
		
		clip.beginGradientFill("linear", 
			colors, 
			[100, 100, 100], [0, 128, 255], matrix);

		drawRectangle(clip, 0, 0, 100, 20, drawBorder);
		clip.endFill();
	}
	
	private function createProgressBorder() {
		createEmptyMovieClip("mcProgressBorder", getNextHighestDepth());
		drawRectangleWithGradientFill(mcProgressBorder, 100, 20, 0xDDDDDD, 0xEEEEEE, true);
		updateMaxDrag(0);
	}
	
	private function createMaxDragIndicator() {
		createEmptyMovieClip("mcMaxDrag", getNextHighestDepth());
		drawRectangleWithGradientFill(mcMaxDrag, 100, 20, 0xAAAAAA, 0xDDDDDD, false);
		mcMaxDrag._width = 0;
		
		mcMaxDrag.onMouseUp = function():Void {
			if (! this._parent.isMouseOverClip(this._parent.mcMaxDrag)) return;
			this._parent.drag();
			this._parent.dispatchDragEvent();
		};
	}

	private function getChildDescriptors():Array {
		return [
			new ClipDescriptor("Dragger", "mcDragger", getSkin().getDraggerImageURL())
		];
	}
	
	private function allChildrenCreated(clips:Array):Void {
		mcDragger = clips[0];
		
		mcDragger.onPress = function():Void {
			this._parent.interevalId = setInterval(this._parent, "drag", 10);
		};
		mcDragger.onRelease = function():Void {
			clearInterval(this._parent.interevalId);
			this._parent.dispatchDragEvent();
		};
		mcDragger.onReleaseOutside = mcDragger.onRelease;
	}

	private function drag():Void {
		var newValue:Number = _xmouse;

		if (newValue > maxDragValue) {
			newValue = maxDragValue;
		}
		if (newValue < 0) {
			newValue = 0;
		}
		mcDragger._x = newValue;
	
		updateAfterEvent();
	}
  	
	private function updateMaxDrag(percentage:Number):Void {
		if (percentage > 100)
			percentage = 100;
		mcMaxDrag._width = percentage == 0 ? 0 :
			mcProgressBorder._width * (percentage / 100) - 1;

		maxDragValue = mcMaxDrag._width - mcDragger._width;
	}
	
	private function updateDraggerPos() {
		var movement:Number = mcProgress._width; // + PROGRESS_TO_DRAGGER_DISTANCE;
		if (movement < 0) movement = 0;
		if (movement + mcDragger._width > mcProgressBorder._width)
			movement = mcProgressBorder._width - mcDragger._width;
		mcDragger._x = movement;
	}
	
	private function dispatchDragEvent():Void {
		if(mcDragger._x != prevDragValue) {
			seekPosition = calculateSeekPosition();
			logger.debug("dispatching onSeek, seekPosition = " + seekPosition);
			dispatchEvent("onSeek", this);
			prevDragValue = mcDragger._x;
		}
	}
	
}
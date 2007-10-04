import org.flowplayer.NewAbstractMovieClip;
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


/**
 * @author anssi
 */
 class org.flowplayer.playlist.PlayListStripe extends NewAbstractMovieClip {
 	
 	private var intervalId:Number = -1;
 	private var efectActive:Boolean = false;
 	public var alphaChange:Number = -20;
 	
 	private var mcHighlight:MovieClip;
 	public var mcSelectHighlight:MovieClip;

 	private static var selectedIntervalId:Number = -1;
 	private static var selectedStripe:PlayListStripe;
	
	function arrange():Void {
		logger.error("PlayListStripe.arrange(): width = " + __width);
		mcHighlight._width = __width;
		mcHighlight._height = __height;
		mcSelectHighlight._width = __width;
		mcSelectHighlight._height = __height;
		mcHighlight._x = 0;
		mcSelectHighlight._x = 0;
		
		// TODO: Find out why following cannot be set
//		this._width = __width;
//		this._height = __height;
	}
	
	public function fill(color:Number, width:Number, height:Number):Void {
		clear();
		beginFill(color, 100);
		drawRectangle(this, 0, 0, width, height, false);
		endFill();
	}
	
	private function createChildren():Void {
		createEmptyMovieClip("mcHighlight", getNextHighestDepth());
		drawRectangle(mcHighlight, 0, 0, 100, 20, true);
		mcHighlight._visible = false;
		
		createEmptyMovieClip("mcSelectHighlight", getNextHighestDepth());
		mcSelectHighlight.beginFill(0xAAFFAA, 50);
		drawRectangle(mcSelectHighlight, 0, 0, 100, 20, false);
		mcSelectHighlight.endFill();
		mcSelectHighlight._visible = false;
		mcSelectHighlight.alphaChange = -20;
	}
	
	private function allChildrenCreated(clips:Array):Void {
		this.onRollOver = function():Void {
			this.rollOverEfect();
		};
		this.onRollOut = function():Void {
			this.rollOutEfect();
		};
		this.onRelease = function():Void {
			this.selected();
		};
 	}
	
	
	private function rollOverEfect():Void {
		if (! efectActive) {
			logger.debug("rollOverEfect on " + this._name);
			clearInterval(this.intervalId);
			this.intervalId = setInterval(this, "rollOverAlphaEffect", 40, this);
			logger.debug("started interval " + intervalId + " on " + this._name);
			efectActive = true;
		}
		mcHighlight._visible = true;
	}
	
	public function rollOutEfect():Void {
		mcHighlight._visible = false;
	}
	
	public function rollOverAlphaEffect(stripe:PlayListStripe):Void {
		doUpdateAlpha(stripe);
		
		// terminate effect after one cycle
		var alphaCycled:Boolean = this._alpha >= 100 && alphaChange > 0;
		if (alphaCycled) {
			logger.debug("clearInterval " + intervalId + " on " + this._name);
			clearInterval(this.intervalId);
			efectActive = false;
			
			if (! isMouseOverClip(stripe)) {
				logger.debug("rollOutEfect!");
				stripe.rollOutEfect();
			}
		}
	}
	
	public function terminateSelectedEffect():Void {
		clearInterval(selectedIntervalId);
		mcSelectHighlight._visible = false;
	}
	
	public static function getSelectedStripe():PlayListStripe {
		return selectedStripe;
	}
	
	private function selected():Void {
		selectedStripe.terminateSelectedEffect();
		selectedStripe = this;
		mcSelectHighlight._visible = true;
		PlayListStripe.selectedIntervalId = setInterval(this, "selectedAlphaEffect", 200, this);
	}
	
	public function selectedAlphaEffect(stripe:PlayListStripe):Void {
		stripe.doUpdateAlpha(stripe.mcSelectHighlight);
	}
	
	private function doUpdateAlpha(clip:MovieClip):Void {
//		logger.debug("updating alpha on " + clip._name + ", alpha now " + clip._alpha);
		if (clip._alpha >= 100 && clip.alphaChange > 0) {
			clip.alphaChange = -20;
			return;
		} else if (clip._alpha <= 40) {
			clip.alphaChange = 20;
		}
		clip._alpha = clip._alpha + clip.alphaChange;
	}
	
}
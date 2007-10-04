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
import org.flowplayer.ClipDescriptor;
import org.flowplayer.NewAbstractMovieClip;
/**
 * @author anssi
 */
class org.flowplayer.playlist.ScrollBar extends NewAbstractMovieClip {

	private var btnScroll:MovieClip;
	private var mcBorder:MovieClip;
	private var scrollableRatio:Number = 0;
	private var eventFiringTreshold:Number = 0;
	private var interevalId:Number;
	
	private var prevScrollValue:Number;
	private var scrollPosition:Number;
	private var gripPos:Number;
	
	public function setScrollableRatio(ratio:Number):Void {
		logger.debug("setting scrollable ratio to " + ratio);
		scrollableRatio = ratio;
		arrange();
	}
	
	public function setEventFiringTreshold(value:Number):Void {
		this.eventFiringTreshold = value;
	}
	
	private function createChildren():Void {
		logger.debug("Creating additional children");
		mcBorder = createEmptyMovieClip("mcBorder", getNextHighestDepth());
	}
	
	private function getChildDescriptors():Array {
		return [ new ClipDescriptor("Scroller", "btnScroll", getSkin().getScrollBarButtonImageURL()) ];		
	}
	
	private function allChildrenCreated(clips:Array):Void {
		btnScroll = clips[0];

		btnScroll.onPress = function():Void {
			this._parent.gripPos = this._parent._ymouse - this._parent.btnScroll._y;
			this._parent.interevalId = setInterval(this._parent, "scroll", 10);
		};
		btnScroll.onRelease = function():Void {
			clearInterval(this._parent.interevalId);
			this._parent.dispatchScrollEvent();
		};
		btnScroll.onReleaseOutside = btnScroll.onRelease;
	}
	
	private function arrange():Void {
		mcBorder._x = 0;
		mcBorder._y = 0;
		mcBorder._width = __width;
		mcBorder._height = __height;
		btnScroll._x = 0;
		btnScroll._y = 0;
		btnScroll._width = __width;

		logger.debug("ScrollBar: filling border " + mcBorder);
		mcBorder.clear();
		mcBorder.beginFill(0xDDDDDD, 100);
		drawRectangle(mcBorder, 0, 0, btnScroll._width, btnScroll._height, false);
		mcBorder.endFill();
		
		if (scrollableRatio == 0)
			btnScroll._visible = false;
		else {
			btnScroll._visible = true;
			btnScroll._height = __height * scrollableRatio;
//			btnScroll._height = __height * (1-scrollableRatio);
		}
	}
	
	private function scroll():Void {
		var newValue:Number = _ymouse - gripPos;
		
		scrollTo(newValue);

		if (requiresEvent(newValue, prevScrollValue)) {
			dispatchScrollEvent();
		}	
		prevScrollValue = newValue;
	}
	
	private function scrollTo(newValue:Number):Void {
		var maxDragValue:Number = maxDragValue();
		if (newValue > maxDragValue) {
			newValue = maxDragValue;
		} else if (newValue < 0) {
			newValue = 0;
		}
		btnScroll._y = newValue;
	}
	
	private function maxDragValue():Number {
		return __height - btnScroll._height;
	}
	
	private function requiresEvent(newValue:Number, oldValue:Number):Boolean {
		return newValue > oldValue ? newValue - oldValue > eventFiringTreshold : oldValue - newValue > eventFiringTreshold;
	}
	
	// TODO: this & ProgressTracker's equivalent should be there only once!
	private function dispatchScrollEvent():Void {
		scrollPosition = calculateScrollPosition();
		logger.debug("dispatching onScroll, scrollPosition = " + scrollPosition);
		dispatchEvent("onScroll", this);
		prevScrollValue = btnScroll._y;
	}
	
	private function calculateScrollPosition():Number {
		var value:Number = btnScroll._y / (this.__height - btnScroll._height);
//		var value:Number = btnScroll._y / this._height;
		logger.debug("calculated scroll position " + value);
		return value;
	}
	
	public function getScrollPosition():Number {
		return this.scrollPosition;
	}
	
	public function setScrollPosition(scrollRatio:Number):Void {
		scrollTo(scrollRatio * maxDragValue());
	}
	
}
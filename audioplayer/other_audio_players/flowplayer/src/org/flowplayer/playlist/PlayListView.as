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
import org.flowplayer.playlist.Clip;
import org.flowplayer.playlist.PlayList;
import org.flowplayer.playlist.PlayListStripe;
import org.flowplayer.playlist.ScrollBar;
import org.flowplayer.ClipDescriptor;

/**
 * @author anssi
 */
class org.flowplayer.playlist.PlayListView extends NewAbstractMovieClip {
	private var mcList:MovieClip;
	private var list:TextField;
	private var stripes:Array;
	private var selectedClip:Number;
	
	private var btnUpScroll:MovieClip;
	private var btnDownScroll:MovieClip;
	private var scrollBar:ScrollBar;
	
	private var model:PlayList;
	
	private var textRowHeight:Number;
	private static var NUM_CLIPS_VISIBLE:Number = 10;
	private var listCreated:Boolean = false;
	
	private function createChildren():Void {
		this.model = getConfig().getPlayList();
		initTextRowHeight();
		createScrollBar();
	}
	
	
	public function createAndFillList():Boolean {
		if (listCreated) return true;
		if (! visibleClipCount() > 0) return false;
		
		createListHolderClip();
		createBorderStripes();
		createList();
		fillList();
		onClipChanged();
		updateStripes();
		listCreated = true;
		return true;
	}

	private function getChildDescriptors():Array {
		return [
			new ClipDescriptor("UpButton", "btnUpScroll", getSkin().getUpScrollButtonImageURL()),
			new ClipDescriptor("DownButton", "btnDownScroll", getSkin().getDownScrollButtonImageURL())
		];
	}
	
	private function allChildrenCreated(clips:Array):Void {
		btnUpScroll = clips[0];
		btnDownScroll = clips[1];
		traceDims(btnUpScroll, "upScroll");
		traceDims(btnDownScroll, "downScroll");
		
		btnUpScroll.onPress = function():Void {
			this._parent.scrollUp();
		};
		
		btnDownScroll.onPress = function():Void {
			this._parent.scrollDown();
		};
		
		scrollBar.addEventListener("onScroll", this);
		
		model.addListener("onClipChanged", this);
	}
	
	private function createScrollBar():Void {
		attachMovie("ScrollBar", "scrollBar", getNextHighestDepth());		
	}
	
	private function createListHolderClip():Void {
		mcList = createEmptyMovieClip("mcList", getNextHighestDepth());
	}
	
	private function createBorderStripes():Void {
		stripes = new Array();
//		logger.info("PlayListView:: Creating " + stripeCount() + " stripes");
		for (var i = 0; i < Math.max(model.size(), visibleClipCount()); i++) {

			var stripe:MovieClip = mcList.attachMovie("PlayListStripe", "stripe_" + i, mcList.getNextHighestDepth());
			stripes[i] = stripe;
			stripe._visible = false;
		}
	}
	
	private function stripeHeight(stripeNumber:Number):Number {
//		var lastStripe:Boolean = stripeNumber == stripeCount()-1;
//		return lastStripe ? textRowHeight + 4 : textRowHeight;
		return textRowHeight + 4;
	}
	
	private function stripeColor(stripeNumber:Number):Number {
		return stripeNumber % 2 == 0 ? 0xBBBBBB : 0xDDDDDD;
	}
	
	private function createList():Void {
		mcList.createTextField("list", mcList.getNextHighestDepth(), 0, 0, 320, NUM_CLIPS_VISIBLE * textRowHeight);
		
		mcList.onMouseUp = function():Void {
			this._parent.listClicked();
		};
		
		list = mcList.list;
		list.multiline = true;
		list.border = true;
		list.embedFonts = true;
		list.selectable = false;
//		list._alpha = 50;
		list._x = 0;
		list._y = 0;
	}
	
	public function arrange():Void {
		logger.error("PlayListView:: arrange, width " + __width + ", height " + __height);
		
		var ratio:Number = clipsVisibleRatio();
		if (ratio < 1) {
			setScrollingControlsVisible(true);
		} else
			setScrollingControlsVisible(false);

		arrangeScrollingControls(ratio);
		
		if (listCreated)
			arrangeList();
			
//		this._width = __width;
//		this._height = __height;
	}
	
	private function arrangeList():Void {
		
		
		// TODO: We need a MovieClip subclass for this collection of stripes
		// Now we cannot touch the mcList._widht or mcList._height properties
		// because it causes the layout to go wrong
		
		var stripeWidth:Number = __width - scrollingControlsWidth();
		for (var i = 0; i < stripes.length; i++) {
			var stripe:PlayListStripe = stripes[i];
			if (i < stripeCount()) {
				stripe._visible = true;
				stripe.setSize(stripeWidth, stripeHeight(i));
//				stripe._width = stripeWidth;
//				stripe._height = stripeHeight(i);
				stripe.fill(stripeColor(i), stripeWidth, stripeHeight(i));
				stripe._y = i * textRowHeight;
			} else {
				stripe._visible = false;
			}
		}

		mcList._y = 0;
		
		// TODO: Following cannot be touched
//		mcList._width = __width - scrollingControlsWidth();
//		mcList._height = __height;

		list._width = stripeWidth - 1;
		list._height = __height;
	}
	
	private function scrollingControlsWidth():Number {
		return btnUpScroll._visible ? btnUpScroll._width : 0;
	}
	
	private function clipsLoaded():Boolean {
		return haveSize([btnUpScroll, btnDownScroll]);
	}
	
	private function arrangeScrollingControls(scrollingRatio:Number):Void {
		btnUpScroll._y = 0;
		scrollBar.setSize(btnUpScroll._width, __height - btnUpScroll._height - btnDownScroll._height);
		scrollBar._y = btnUpScroll._height;
		scrollBar.setScrollableRatio(scrollingRatio);
		
		arrangeToRightEdge(btnUpScroll);
		arrangeToRightEdge(btnDownScroll);
		arrangeToRightEdge(scrollBar);

		btnDownScroll._y = __height - btnDownScroll._height;
	}
	
	private function setScrollingControlsVisible(makeVisible:Boolean):Void {
		scrollBar._visible = makeVisible;
		btnUpScroll._visible = makeVisible;
		btnDownScroll._visible = makeVisible;
	}
	
	private function clipsVisibleRatio():Number {
		var playListLength:Number = model.size();
		var clipsNotVisibleRatio:Number = visibleClipCount() / playListLength;
		if (clipsNotVisibleRatio < 0) clipsNotVisibleRatio = 0;
		logger.debug("visible clips / all clips ratio == " + clipsNotVisibleRatio);
		return clipsNotVisibleRatio;
	}
	
	private function arrangeToRightEdge(clip:MovieClip):Void {
		clip._x = __width - clip._width;
	}
	
	private function fillList():Void {
		var clips:Array = model.all();
		for (var i = 0; i < clips.length; i++) {
			var clip:Clip = clips[i];
			var clipText:String = (i+1) + ". " + clip.getName();
			
			logger.info("PlayListView:: adding clip " + clip.getName() + " to list " + list +
			 " extent = " + getDefaultTextFormat().getTextExtent(clipText).height);
			 
			list.text = list.text + clipText + "\n";
		}
		list.setTextFormat(getDefaultTextFormat());
		logger.info("PlayListView:: list text is now " + list.text);
	}

	private function initTextRowHeight():Void {
		textRowHeight = getDefaultTextFormat().getTextExtent("A\nA\nA\nA\nA\nA\nA\nA\nA\nA").height / 10;
		logger.debug("PlayListView:: will use " + textRowHeight + " as text row height");
	}
	
	private function listClicked():Void {
		if (! isMouseOverClip(mcList)) return;

		var clipNumber:Number = int(mcList._ymouse / textRowHeight) + list.scroll - 1;
		changeToClip(clipNumber);
	}
	
	private function changeToClip(clipNumber:Number):Void {
		if (model.currentIndex() == clipNumber) return;
		var clip:Clip = model.toClip(clipNumber);
	}
	
	public function onClipChanged():Void {
		selectedClip = model.currentIndex();

		scrollToSelectedClip();	
		updateStripes();
	}
	
	private function scrollToSelectedClip():Void {
		if (selectedClip < clipOnTop())
			list.scroll = selectedClip + 1;
		if (selectedClip > clipOnBottom())
			list.scroll = selectedClip - NUM_CLIPS_VISIBLE + 1;
		updateScrollBarPosition();
	}
	
	private function clipOnTop():Number {
		return list.scroll - 1;
	}
	
	private function clipOnBottom():Number {
		logger.debug("clip on bottom " + (list.scroll + NUM_CLIPS_VISIBLE - 1));
		return list.scroll + NUM_CLIPS_VISIBLE - 1;
	}
	
	private function scrollUp():Void {
		logger.debug("scrolling up");
		list.scroll--;
		updateScrollBarPosition();
		updateStripes();
	}
	
	private function scrollDown():Void {
		logger.debug("scrolling down");
		list.scroll++;
		updateScrollBarPosition();
		updateStripes();
	}
	
	private function updateScrollBarPosition():Void {
		scrollBar.setScrollPosition(list.scroll / (model.size() - NUM_CLIPS_VISIBLE));
	}
	
	public function onScroll():Void {
		var position:Number = scrollBar.getScrollPosition();
		var row:Number = int(model.size() * position);
		list.scroll = row;
		updateStripes();
	}
	
	private function updateStripes():Void {
		if (selectedClip < clipOnTop() || selectedClip >= clipOnBottom()) {
			PlayListStripe.getSelectedStripe().terminateSelectedEffect();
		} else
			stripes[selectedClip - clipOnTop()].selected();
	}
	
		
	private function visibleClipCount():Number {
		if (model == null)
			model = getConfig().getPlayList();
		return Math.min(model.size(), stripeCount());
	}
		
	private function stripeCount():Number {
		return Math.floor(this.__height / textRowHeight);
	}
	
	public function getDefaultHeight():Number {
		return NUM_CLIPS_VISIBLE * textRowHeight + 4;
	}
	
	public function getAdjustedHeight(height:Number):Number {
		var over:Number = (height - 4) % textRowHeight;
		return height - over;
	}
}
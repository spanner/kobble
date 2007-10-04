/**
******************************************

	@class: MP3Player
	@vertion: 0.1
	@date: 02/16/05
	@language: ActionScript 2.0
	@author: Mason Poe (mason{at--no--spam}skylab{peroid}ws)?at="@"?peroid=".")
	@usage: 
		depth = 0;
		//example1
		JukeBox = new MP3Player("song1.mp3");
		JukeBox.start();
		//example2
		JukeBox = new MP3Player(["song1.mp3","song2.mp3","song3.mp3"]);
		JukeBox.start();
		JukeBox.onLoad = function(){trace(JukeBox.getTotalTracks());};
		JukeBox.onSoundPlaying = function(){trace(JukeBox.getSecondsElapsed());};
		box1_mc.onPress = function(){JukeBox.pause();};
		box2_mc.onPress = function(){JukeBox.destroy()};
		
	PUBLIC METHODS
		start
		play
		stop
		pause
		soundToStream
		autoLoad
		autoPlayOnLoad
		trackNumToLoad
		soundVolume
		position
		totalTracks
		secondsElapsed
		loadNewSound
		soundVolume
		trackNumID3
		trackNumber
		artistID3
		albumID3
		genreID3
		songNameID3
		yearID3
		getID3
		destroy
		
	EVENTS
		onSoundComplete
		onSoundPlaying
		onLoadProgress
		onLoad
		//--onFail soon to come
		
	PRIVATE METHODS
		init
		onSoundEnd
		initAutoLoad
		IsPlaying
		autoLoad
		loadSound
		onSoundLoad
		position
	
	@History: released 07.10.04
			updated 12.15.04 -- converted from a AS1 class to AS2.
			added 'destroy' method to remove all listeners and kill the class.

******************************************
**/

//import com.kennybunch.utils.IntervalManager
//If you decide you would like to use Kenny Bunch's interval manager uncomment the code on lines 181,184,325  

class com.masonpoe.utils.MP3Player{
	//	PRIVATE : STATIC
	public static var MILLISECONDS:Number = 1000
	public static var SECONDS:Number = 60;
	//  EVENTS
	public var onLoad:Function;
	public var onSoundPlaying:Function;
	public var onSoundComplete:Function;
	//  EVENT LISTENER
	var addEventListener:Function;
	var removeEventListener:Function;
	var dispatchEvent:Function;
	//  PRIVATE VARS
	private var _isPlaying:Boolean
	private var _soundPlayID:Number
	private var _autoLoad:Boolean
	private var _trackNumber:Number
	private var _trackNumToLoad:Number
	private var _soundURL_list:Array
	private var _Sound:Sound
	private var _soundPosition:Number
	private var _soundStream:Boolean
	private var _autoPlay:Boolean
	//
	private var __loadProgressID:Number
	//  CLASS
	public function MP3Player(list){
		_Sound = new Sound();
		
		_soundURL_list = new Array()
		this.soundURL_list = list;
		//
		mx.events.EventDispatcher.initialize(this);
		this.addEventListener('onLoad', this);
		this.addEventListener('onLoadProgress',this);
		this.addEventListener('onSoundPlaying',this);
		this.addEventListener('onSoundComplete',this);
		//
		init()
	}
	
	//-----------------------------------------
	// private methods
	private function init():Void{
		this.autoLoad = true;
		this.autoPlayOnLoad = true;
	};
	// private event for when sound complete's
    private function onSoundEnd():Void{
		isPlaying = false
		dispatchEvent({type:'onSoundComplete'});
		loadNextTrack()
	}
    // conditional to see if next track should be loaded
    private function loadNextTrack():Void{
        if(this.trackNumber<_soundURL_list.length-1){
            destroy()
            _Sound = new Sound()
            loadNewSound(_soundURL_list[this.trackNumber+1])
            
        }
    }
    // conditional for auto load of first track
	private function initAutoLoad():Void{
		if(_autoLoad){
		  	loadNewSound();
		}
	}
    // the param track can be string (for URL) or number for ref to position in track list
	private function loadSound(track):Void{
	stopAudio();
	//
	if ((typeof (track)) != "string"){
		if (track == undefined){
			if(_trackNumToLoad!=undefined){
					track = _trackNumToLoad
					_trackNumToLoad = undefined
			}else{
				track = 0;
			}
		}
		if (_soundStream == undefined){
			_soundStream = false;
		}
		//
		var soundURL:String = getTrackURL(track);
		}else{
			var soundURL = track
		}
		this.trackNumber = track
		//
		soundURL = soundURL+"?id="+Math.round(Math.random()*1000)
		_Sound.loadSound(soundURL, this._soundStream);
		//
		if(this._soundStream){playAudio(this._soundStream)}
		//
		__loadProgressID = setInterval(this, "updateLoadProgress",100);
	};
    // called by interval : updates onLoadProgress    private function updateLoadProgress():Void{
        dispatchEvent({type:'onLoadProgress'})    }
    // called by interval : updates onSoundPlaying
    private function updateSoundProgress():Void{
        dispatchEvent({type:'onSoundPlaying'})    }
    // method called from Sound.onLoad
	private function onSoundLoad(){
        clearInterval(__loadProgressID)
        //
		dispatchEvent({type:'onLoad'});
	    //      
		if (_autoPlay){
		  trace("autoplay")
		  if(!_soundStream){
                trace("onLoad")
                playAudio();
            }
		}
	};
	//-------------------------------------
	//   Public Methods
	//-------------------------------------    // return number : percent loaded    public function get loaded():Number{	   var load:Number = Math.round(_Sound.getBytesLoaded()/_Sound.getBytesTotal()*100)
	   return load    }
    // return track url
	public function getTrackURL(id:Number):String{
		return _soundURL_list[id];
	}
    // set track position in seconds
	public function set position(num:Number):Void{
		if(num==undefined){
			num = (_Sound.position/MILLISECONDS);
		}
	 	_soundPosition = num
	}
	// return track position in seconds
	public function get position():Number{
		if (_soundPosition == undefined){
				_soundPosition = 0;
		}
		return _soundPosition;
	} // return percent of sound played
	public function get soundPercent():Number{	   var pos:Number = Math.round(_Sound.position/_Sound.duration*100);
	   return pos    } // toggle if sound is playing
	public function set isPlaying(state:Boolean):Void{
		_isPlaying = state;
		if (state){
				_soundPlayID = setInterval(this, "updateSoundProgress", 100);
			}else{
				clearInterval(_soundPlayID);
			}
	};
    // return boolean value if sound is playing
	public function get isPlaying():Boolean{
		return _isPlaying;
	};
	// set track number
	public function set trackNumber(trackNumber:Number):Void{
		_trackNumber = trackNumber;
	}
    // return track number
	public function get trackNumber():Number{
		return _trackNumber;
	};
	// set list of sounds to be loaded
	public function set soundURL_list(list):Void{
        if (list != undefined)
		{
			if ((typeof (list)) == "string")
			{
				_soundURL_list = new Array();
				_soundURL_list[0] = list;
			}
				else
			{
				_soundURL_list = list;
			}
		}
		
	}
	// start class
	public function start():Void{
		initAutoLoad();
	};
	// play audio
	public function playAudio(streaming:Boolean):Void{
		if(_trackNumToLoad!=undefined){
				var track:Number = _trackNumToLoad
				_trackNumToLoad = undefined
				loadNewSound(track)
			}else{
				var startSoundFrom = position;
                if(streaming==undefined){
				    _Sound.start(startSoundFrom);
				}
		}
		isPlaying = true;
	};
	// stop audio
	public function stopAudio():Void{
		_Sound.stop();
		position = 0
		isPlaying = false;
		dispatchEvent({type:'onSoundStop'});
	};
	// pause audio
	public function pauseAudio():Void{
		//$setPosition();
		position = undefined
		_Sound.stop();
		isPlaying = false;
		dispatchEvent({type:'onSoundPause'});
	};
    // set stream prop
	public function set soundToStream(state:Boolean):Void{
		_soundStream = state;
	}
    // does the file auto load on institution
	public function set autoLoad(state:Boolean):Void{
		_autoLoad = state;
	};
	// set the file to play on load.  if false file only plays on action from playAudio
	public function set autoPlayOnLoad(state:Boolean):Void{
		_autoPlay = state;
	}
	// set track number to load from list
	public function set trackNumToLoad(trackNumber:Number):Void{
		_trackNumToLoad = trackNumber-1;
	};
    // set sound volume
	public function set soundVolume(volumeNum:Number):Void{
		_Sound.setVolume(volumeNum)
	}
	// return sound volume
	public function get soundVolume():Number{
		return _Sound.getVolume()
	}
    // get total tracks in list
	public function get totalTracks():Number{
		var totalTracks:Number = _soundURL_list.length;
		return totalTracks;
	}
	// get seconds elapsed
	public function get secondsElapsed():Number{
		var totalSecs:Number = Math.ceil(_Sound.position/MILLISECONDS);
		return totalSecs;
	};
    // get track number ID3 tag. CAUTION! Problematic when used with streaming sounds.
	public function get trackNumID3():String{
		return getID3("track")
	}
	// get track artist ID3 tag. CAUTION! Problematic when used with streaming sounds.
	public function get artistID3():String{
		return getID3("artist")
	}
    // get track album ID3 tag. CAUTION! Problematic when used with streaming sounds.
	public function get albumID3():String{
		return getID3("album")
	}
	// get track genre ID3 tag. CAUTION! Problematic when used with streaming sounds.
	public function get genreID3():String{
		return getID3("genre")
	}
    // get track name ID3 tag. CAUTION! Problematic when used with streaming sounds.
	public function get songNameID3():String{
		return getID3("songname")
	}
	// get track year ID3 tag. CAUTION! Problematic when used with streaming sounds.
	public function get yearID3():String{
		return getID3("year")
	}
	// get track ID3 tag. Pass a string param for return. CAUTION! Problematic when used with streaming sounds.
	public function getID3(param:String):String{
		return _Sound.id3[param]
	}
	// load new sound
	public function loadNewSound(track):Void{
		var _controller = this;
		_Sound.onLoad = function(){
			_controller.onSoundLoad();
		}
		_Sound.onSoundComplete = function(){	
			_controller.onSoundEnd()
		}
		//
		loadSound(track);
	};
	// remove even listeners and stop audio and delete sound
	public function destroy(){
		//
		stopAudio()
		//
		//IntervalManager.clearAllIntervals();
		clearInterval(_soundPlayID);
		//
		this.removeEventListener('onLoad', this);
		this.removeEventListener('onSoundPlaying', this);
		this.removeEventListener('onLoadProgress',this);
		this.removeEventListener('onSoundComplete',this);
		//
		delete _Sound;
	}

}
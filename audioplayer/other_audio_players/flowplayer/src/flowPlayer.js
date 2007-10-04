/*
 * FlowPlayer external configuration file.
 * Copyright 2005-2006 Anssi Piirainen
 *
 * All settings defined in this file can be alternatively defined in the 
 * embedding HTML object tag (as flashvars variables). Values defined in the
 * object tag override values defined in this file. You could use this 
 * config file to provide defaults for multiple player instances that 
 * are used in a Web site. Individual instances can be then customized 
 * with their embedding HTML.
 *
 * Note that you should probably remove all the comments from this file
 * before using it. That way the file will be smaller and will load faster.
 */

{
	/*
	 * Name of the video file. Used if only one video is shown.
	 *
	 * Note for testing locally: Specify an empty baseURL '', if you want to load
	 * the video from your local disk from the directory that contains
	 * FlowPlayer.swf. In this case the videoFile parameter value should start
	 * with a slash, for example '/video.flv'.
	 *
	 * See also: 'baseURL' that affects this variable
	 */
//	 videoFile: '/ounasvaara.flv',

	/*
	 * Playlist is used to publish several videos using one player instance.
	 * Each entry contains a name that will be shown in the list widget and
	 * a URL that is used to load the video.
	 *
	 * See also: 'baseURL' is prefixed with each URL
	 */
	playList: [
		{ name: 'Skiing', url: '/ounasvaara.flv' },
		{ name: 'Amazon river', url: '/river.flv' },
		{ name: 'Skiing 2', url: '/ounasvaara.flv' },
		{ name: 'Amazon river 2', url: '/river.flv' },
		{ name: 'Skiing 3', url: '/ounasvaara.flv' },
		{ name: 'Amazon river 3', url: '/river.flv' },
		{ name: 'Skiing 4', url: '/ounasvaara.flv' },
		{ name: 'Skiing 5', url: '/ounasvaara.flv' },
		{ name: 'Amazon river 4', url: '/river.flv' },
		{ name: 'Amazon river 5', url: '/river.flv' },
		{ name: 'Skiing 6', url: '/ounasvaara.flv' },
		{ name: 'Amazon river', url: '/river.flv' },
		{ name: 'Amazon river 2', url: '/river.flv' },
		{ name: 'Skiing 2', url: '/ounasvaara.flv' },
		{ name: 'Skiing 3', url: '/ounasvaara.flv' },
		{ name: 'Amazon river 3', url: '/river.flv' },
		{ name: 'Skiing 4', url: '/ounasvaara.flv' },
		{ name: 'Amazon river 4', url: '/river.flv' },
		{ name: 'Skiing 5', url: '/ounasvaara.flv' },
		{ name: 'Amazon river 5', url: '/river.flv' },
		{ name: 'Skiing 6', url: '/ounasvaara.flv' },
		{ name: 'Amazon river 6', url: '/river.flv' }
	],

	/* 
	 * baseURL specifies the URL that is appended in front of different file names
	 * given in this file.
	 * If this variable is not present (undefined), the player will take a baseURL value from
	 * the URL that was used to load the FlowPlayer.swf file (which means that
	 * FlowPlayer.swf and the video file must be located in the same URL on the Web
	 * server).
	 */ 
	baseURL: '',

	/* 
	 * 'autoPlay' variable defines whether playback begins immediately or not.
	 * (optional, defaults to true)
	 */
	autoPlay: false,

	/*
	 * 'autoBuffering' specifies wheter to start loading the video stream into
	 *  buffer memory  immediately. Only meaningful if 'autoPlay' is set to
	 * false. (optional, defaults to true)
	 */
	autoBuffering: true,

	/*
	 * 'bufferLength' specifies the video buffer length in seconds
	 */
	bufferLength: 5,

	/*
	 * 'loop' defines whether the playback should loop to the first clip after
	 * all clips in the playlist have been shown. It is used as the
	 * default state of the toggle button that controls looping. (optional,
	 * defaults to true)
	 */
	loop: true,

	/*
	 * 'progressBarColor1' defines the color of the progress bar at the bottom
	 * and top edges. Specified in hexadecimal triplet form indicating the RGB
	 * color component values. (optional, defaults to light gray: 0xAAAAAA)
	 */
	progressBarColor1: 0xFFFF00,


	/*
	 * 'progressBarColor2' defines the color in the middle of the progress bar.
	 * The value of this and 'progressBarColor1' variables define the gradient
	 * color fill of the progress bar. (optional, defaults to dark gray: 0x555555)
	 */
	progressBarColor2: 0x00FF00,
	
	/*
	 * Specifies the height to be allocated for the video display. The height
	 * of the video is fixed exactly to match this value. If playlist is used
	 * the height of the playlist widget is scaled to fill the total height
	 * reserved for the player SWF component. The total height (and width) can
	 * be specified in the embedding HTML. 
	 *
	 * Note also that the height of the playlist widget is adjusted so that 
	 * it will show complete rows. The list widget will not have a weight that
	 * would make it to show only half of the height of a clip's name. This 
	 * adjustment may result in some empty space at the bottom of the coponent's
	 * allocated area. This empty space can be removed by adjusting the allocated
	 * size (changing the value of object tag's height attribute).
	 *
	 */
	videoHeight: 320,
	
	/*
	 * 'hideControls' if set to true, hides all buttons and the progress bar
	 * leaving only the video showing (optional, defaults to false)
	 */
	hideControls: false,
	
	/*
	 * 'hideBorder' if set to true, hides the rectangular box surrounding the
	 * video area (optional, defaults to false)
	 */
	hideBorder: true,

	/*
	 * URL that specifies a base URL that points to a folder containing
	 * images used to skin the player. You must specify this if you intend
	 * to load external button images (see 'loadButtonImages' below).
	 */
	skinImagesBaseURL: 'file:///home/anssi/projects/flowplayer/resources',

	/*
	 * Will button images be loaded from external files, or will images embedded
	 * in the player SWF component be used? Set this to false if you want to "skin"
	 * the buttons. Optional, defaults to true.
	 *
	 * See also: 'skinImagesBaseURL' that affects this variable
	 */
	useEmbeddedButtonImages: false,
	
	/**
	 * Optional logo image file. Specify this variable if you want to include
	 * a logo image on the right side of the progress bar. 'skinImagesBaseURL'
	 * will be prefixed to the URL used in loading.
	 *
	 * See also: 'skinImagesBaseURL' that affects this variable
	 */
//	logoFile: 'Logo.jpg',
	
	/*
	 * 'splashImageFile' specifies an image file to be used as a splash image.
	 * This is useful if 'autoPlay' is set to false and you want to show a
	 * welcome image before the video is played. Should be in JPG format. The
	 * value of 'baseURL' is used similarily as with the video file name and
	 * therefore the video and the image files should be placed in the Web
	 * server next to each other.
	 *
	 * See also: 'skinImagesBaseURL' that affects this variable
	 */
	splashImageFile: 'main_clickToPlay.jpg'
	
	/*
	 * Should the splash image be scaled to fit the entire video area? If false,
	 * the image will be centered. Optional, defaults to false.
	 */
	scaleSplash: false

}


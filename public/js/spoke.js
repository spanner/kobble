var accordion = null;
var scratchpad = null;
var display = null;
var droppers = [];
var clickthreshold = 20;
var tagspinners = [];
var waiticon = '/images/furniture/signals/wait_32.gif';

// element ids in spoke have a standard format: tag_type_id, where tag is an arbitrary identifier used to identify eg tab family, and type and id denote an object
// there must be a way to do this with a split

function idParts (el) {
  var parts = el.id.split('_');
  var splut = {
    'id' : parts[parts.length-1],
    'type' : parts[parts.length-2],
    'tag' : parts[parts.length-3]
  }
  return splut;
}

function announce (message) {
  $E('#notification').setText(message);
  var notifyfx = new Fx.Styles($E('#mastfoot'), {duration:1000, wait:false});
  notifyfx.start({
		'background-color': ['#00ff00','#559DC4'],
	}).chain(clearnotification);
}

function error (message) {
  $E('#notification').setText(message);
  var notifyfx = new Fx.Styles($E('#mastfoot'), {duration:2000, wait:false});
  notifyfx.start({
		'background-color': ['#ff0000','#559DC4'],
	}).chain(clearnotification);
}

function clearnotification (delay) {
  $E('#notification').setText('');
}

// now to set it all going

window.addEvent('domready', function(){

	$ES('a.displaycontrol').each(function (a) {
	  var slid = $E( '#' + a.id.replace('show','hide') );
    if (slid) {
      var slide = new Fx.Slide( slid, {
        transition: Fx.Transitions.Bounce.easeOut,
        onStart: function () { a.hide(); },
      });
      slide.hide();
  		a.addEvent('click', function (e) {
      	e = new Event(e);
      	slide.toggle();
      	e.stop();
  			e.preventDefault();
  		});
    }
	});

	scratchpad = droppers[0] = new Scratchpad( $E('#scratchpad') );
	$ES('div.dropzone').each(function (element) {
		droppers[droppers.length] = new Dropon(element);
	});

  $ES('.draggable').each(function(item) {
  	item.addEvent('mousedown', function(e) {
  		e = new Event(e).preventDefault();
			new Draggee(this, e);
  	});
  });

	$ES('input.tagbox').each(function (element, i) {
		new TagSuggestion(element, '/tags/matching', {
			postVar: 'stem',
			onRequest: function(el) { element.addClass('waiting'); },
			onComplete: function(el) { element.removeClass('waiting'); }
		});
	});
  
  $ES('a.snipper').each( function (element) {
    element.addEvent('click', function (e) {
      snip = new Snipper(element, e);
    })

  })
});




var slides = {};
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
    'context' : parts[parts.length-3]
  }
  return splut;
}

function announce (message) {
  $E('#notification').setText(message);
  var notifyfx = new Fx.Styles($E('#mastfoot'), {duration:1000, wait:false});
  notifyfx.start({
		'background-color': ['#CC6E1F','#559DC4']
	}).chain(clearnotification);
}

function error (message) {
  $E('#notification').setText(message);
  var notifyfx = new Fx.Styles($E('#mastfoot'), {duration:2000, wait:false});
  notifyfx.start({
		'background-color': ['#ff0000','#559DC4']
	}).chain(clearnotification());
}

function clearnotification (delay) {
  $E('#notification').setText('');
}

function flash (element) {
  var flashfx = new Fx.Styles(element, {duration:1000, wait:false});
  var bgbackto = element.getStyle('background-color');
  if (bgbackto == 'transparent') bgbackto = '#ffffff';
  var fgbackto = element.getStyle('color');
  flashfx.start({
		'background-color': ['#CC6E1F',bgbackto],
		'color': ['#CC6E1F',fgbackto]
  });
}




// now to set it all going

window.addEvent('domready', function(){

	$ES('a.displaycontrol').each(function (a) {
	  var tag = a.id.replace('show','hide');
	  var slid = $E( '#' + tag );
    if (slid) {
      slides[tag] = new Fx.Slide( slid, {
        transition: Fx.Transitions.Bounce.easeOut,
        onStart: function () { 
          if (a.hasClass('disappears')) a.hide(); 
          else a.setText(slides[tag].open ? a.getText().replace('-','+') : a.getText().replace('+','-'));
        }
      });
      if (!a.hasClass('defaultopen')) slides[tag].hide(); 
  		a.addEvent('click', function (e) {
  		  this.blur();
      	e = new Event(e);
      	slides[tag].toggle();
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
  		e = new Event(e);
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
  
  $ES('a.modalform').each( function (element) {
    element.addEvent('click', function (e) {
      e = new Event(e).stop();
      e.preventDefault();
      this.blur();
      new ModalForm(this, e);
    });
  });

  $ES('a.snipper').each( function (element) {
    element.addEvent('click', function (e) {
      e = new Event(e).stop();
      e.preventDefault();
      this.blur();
      snip = new Snipper(element, e);
    });
  });

  $ES('a.editinplace').each( function (a) {
    a.addEvent('click', function (e) {
      a.setText('+ ' + a.getText());
      e = new Event(e).stop();
      e.preventDefault();
      this.blur();
      ed = new Editor(a, e);
    });
  });
});




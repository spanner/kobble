var slides = {};
var scratchpad = null;
var display = null;
var droppers = [];
var clickthreshold = 20;
var tagspinners = [];
var waiticon = '/images/furniture/signals/wait_32.gif';
var fixedbottom = [];

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

function flash (element, bgbackto) {
  var flashfx = new Fx.Styles(element, {duration:1000, wait:false});
  if (!bgbackto) bgbackto = element.getStyle('background-color');
  if (bgbackto == 'transparent') bgbackto = '#ffffff';
  var fgbackto = element.getStyle('color');
  flashfx.start({
		'background-color': ['#CC6E1F',bgbackto],
		'color': ['#CC6E1F',fgbackto]
  });
}

function moveFixed (e) {
  fixedbottom.each(function (element) {
    element.stayBottom();
  })
}

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

	scratchpad = droppers[0] = new PadDropzone( $E('#scratchpad') );
	$ES('div.setdrop').each(function (element) {
		droppers.push(new SetDropzone(element));
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
      e = new Event(e).stop();
      e.preventDefault();
      this.blur();
      ed = new Editor(a, e);
    });
  });

  $ES('a.deleteinplace').each( function (a) {
    a.addEvent('click', function (e) {
      e = new Event(e).stop();
      e.preventDefault();
      this.blur();
      del = new Deleter(a, e);
    });
  });
  
  $ES('a.tab').each( function (a) {
    new Tab(a);
  });

  $ES('a.autolink').each( function (a) {
    new AutoLink(a);
  });

  $ES('a.toggle').each( function (a) {
    new Toggle(a);
  });
  
  $ES('a.rename_pad').each( function (a) {
    a.addEvent('click', function (e) {
      e = new Event(e).stop();
      e.preventDefault();
      var padid = a.id.replace('rename_', '');
      scratchpad.showRename(padid, a.getProperty('href'));
    });
  });

  $ES('a.setfrom_pad').each( function (a) {
    a.addEvent('click', function (e) {
      this.getParent().addClass('waiting');
    });
  });

  $ES('a.clear_pad').each( function (a) {
    a.addEvent('click', function (e) {
      e = new Event(e).stop();
      e.preventDefault();
      var padid = a.id.replace('clear_', '');
      scratchpad.clearPage(padid, a.getProperty('href'));
    });
  });

  $ES('a.delete_pad').each( function (a) {
    a.addEvent('click', function (e) {
      e = new Event(e).stop();
      e.preventDefault();
      var padid = a.id.replace('delete_', '');
      scratchpad.deletePage(padid, a.getProperty('href'));
    });
  });

  $ES('div.fixedbottom').each( function (element) {
    fixedbottom.push(element);
  });

  $ES('a.closepad').addEvent('click', function (e) {
    e = new Event(e).stop();
    e.preventDefault();
    scratchpad.close();
  })

	window.addEvent('scroll', moveFixed);
	window.addEvent('resize', moveFixed);
});

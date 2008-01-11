var slides = {};
var display = null;
var droppers = [];
var clickthreshold = 6;
var tagspinners = [];
var waiticon = '/images/furniture/signals/wait_32.gif';
var fixedbottom = [];
var commentator = null;
var dragging = false;

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
  console.log("message: " + message)
  if (message) $E('#notification').setText(message);
  flashfooter('#695D54');
}

function error (message) {
  console.log("message: " + message)
  if (message) $E('#notification').setText(message);
  flashfooter('#ff0000');
}

function flashfooter (colour) {
  var footer = $E('#mastfoot');
  var backto = footer.getStyle('background-color');
  var notifyfx = new Fx.Styles(footer, {duration:2000, wait:false});
  console.log('flashing footer from ' + colour + ' to ' + backto);
  notifyfx.start({
		'background-color': [colour,backto]
	});
}

function clearnotification (delay) {
  $E('#notification').setText('');
}

function flash (element) {
  var bgbackto = element.getStyle('background-color');
  var fgbackto = element.getStyle('color');
  var flashfx = new Fx.Styles(element, {duration:300, wait:false});
  flashfx.start({
		'background-color': ['#CC6E1F', '#ffffff'],
		'color': ['#ffffff',fgbackto]
  }).chain(function () {
    element.setStyle('background-color', bgbackto)
  });
}

function moveFixed (e) {
  fixedbottom.each(function (element) {
    element.stayBottom();
  })
}

window.addEvent('domready', function(){
	
  $ES('.dropzone').each(function (element) {
    droppers.push(new Dropzone(element));
  });

  $ES('.catcher').each(function (element) {
    droppers.push(new Dropzone(element));
  });

  $ES('.draggable').each(function(item) {
    item.addEvent('mousedown', function(e) {
       new Draggee(this, new Event(e));
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

  $ES('a.padtab').each( function (a) {
    new ScratchTab(a);
  });

  $ES('a.autolink').each( function (a) {
    new AutoLink(a);
  });

  $ES('a.toggle').each( function (a) {
    new Toggle(a);
  });
  
  $ES('div.fixedbottom').each( function (element) {
    fixedbottom.push(element);
  });
  
  commentator = new Commentator;
  
  $ES('.expandable').each( function (element) {
    element.addEvent('mouseenter', function (event) { if (!dragging) commentator.explain(element, event); })
    element.addEvent('mouseleave', function (e) { commentator.hide(); })
  });
  
	window.addEvent('scroll', moveFixed);
	window.addEvent('resize', moveFixed);
});

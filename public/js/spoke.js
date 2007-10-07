var scratch = null;

window.addEvent('domready', function(){
  scratch = new Scratchpad( $E('#scratchpad') );

  $ES('.draggable').each(function(item) {
  	item.addEvent('mousedown', function(e) {
  		e = new Event(e).stop();
			new Draggee(this, e);
  	});
  });

	$ES('a.displaycontrol').each(function (a) {
		a.addEvent('click', function (e) { 
			var toggled = $E('#' + this.id.replace('show','hide'))
			if (toggled.getStyle('display') == 'none') {
				this.setText(this.getText().replace('+', '-').replace('show', 'hide'));
				toggled.show();
			} else {
				this.setText(this.getText().replace('-', '+').replace('hide', 'show'));
				toggled.hide();
			}
			e.preventDefault();
		})
	})

});

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

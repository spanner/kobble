var slides = {};
var waiticon = '/images/furniture/signals/wait_32.gif';

// element ids in spoke have a standard format: tag_type_id, where tag is an arbitrary identifier used to identify eg tab family, and type and id denote an object
// there must be a way to do this with a split

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

  var commenter = $E('div#hide_reply');
  if (commenter) new Previewer(commenter);

});




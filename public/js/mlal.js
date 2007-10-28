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

  $ES('a.editinplace').each( function (element) {
    element.addEvent('click', function (e) {
      e = new Event(e).stop();
      e.preventDefault();
      this.blur();
      ed = new Editor(element, e);
    });
  });

});




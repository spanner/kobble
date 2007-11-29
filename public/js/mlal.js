window.addEvent('domready', function(){
  $ES('a.editinplace').each( function (element) {
    element.addEvent('click', function (e) {
      e = new Event(e).stop();
      e.preventDefault();
      this.blur();
      ed = new Editor(element, e);
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
  
  $ES('a.autolink').each( function (a) {
    new AutoLink(a);
  });
  
  $ES('a.toggle').each( function (a) {
    new Toggle(a);
  });

  var slides = {};

	$ES('a.showsignup').each(function (a) {
    signupform = $E('#signupform');
    otherforms = $E('#promoteform');
    slidein = new Fx.Slide( signupform, { duration: 1000, transition: Fx.Transitions.Bounce.easeOut });
    slideout = new Fx.Slide( otherforms, { duration: 1000, transition: Fx.Transitions.Bounce.easeOut });
    slidein.hide();
		a.addEvent('click', function (e) {
		  this.blur();
    	e = new Event(e).stop();
			e.preventDefault();
      slideout.slideOut();
			slidein.slideIn();
      
		});
	});
  
});




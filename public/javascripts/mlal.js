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
    slides['signup'] = new Fx.Slide( $E('#signupform'), { duration: 1000, transition: Fx.Transitions.Bounce.easeOut });
    slides['promote'] = new Fx.Slide( $E('#promoteform'), { duration: 1000, transition: Fx.Transitions.Bounce.easeOut });
    slides['signup'].hide();
		a.addEvent('click', function (e) {
		  this.blur();
    	e = new Event(e).stop();
      slides['promote'].slideOut();
			slides['signup'].slideIn();
			e.preventDefault();
		});
	});
  
});




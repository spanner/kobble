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
});




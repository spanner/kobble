var collapser = null;

var Collapser = new Class ({
  Extends: Accordion,
  options: {
    display: 0,
    show: false,
    height: true,
    width: false,
    opacity: true,
    fixedHeight: false,
    fixedWidth: false,
    wait: false,
    alwaysHide: true,
    onActive: function (toggler, element) {
      toggler.addClass('expanded');
      toggler.removeClass('squeezed');
    },
    onBackground: function (toggler, element) {
      toggler.blur();
      toggler.removeClass('expanded');
      toggler.addClass('squeezed');
    }
  },
  initialize: function (togglers, elements) {
    this.parent(togglers, elements);
    if (elements) elements.each(function (element) { element.collapsed = true; });
    collapser = this;
  },
  addSections: function (togglers, elements) {
    togglers.each(function (toggler) {
      element = elements[togglers.indexOf(toggler)];
      this.addSection(toggler, element);
      element.collapsed = true; 
    }, this);
  },
  redisplay: function() {
		var obj = {};
		this.elements.each( function(el, i){
		  if (i == this.previous) {
		    obj[i] = {};
		    for (var fx in this.effects) obj[i][fx] = el[this.effects[fx]];
		  }
    }, this);
		return this.start(obj);
  }
});

Element.implement({
  lookForCollapsedParent: function () {
    if (this.collapsed) return this;
    else if (this.getParent()) return this.getParent().lookForCollapsedParent();
    else return null;
  }
});

kobble_starters.push(function (scope) {
  var squeezable = scope.getElements('a.squeezebox');
  if (squeezable) new Collapser(squeezable, scope.getElements('div.squeezed'));
});





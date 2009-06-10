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
    if (elements) elements.each(function (element) { element.squeezed = true; });
  },
  addSections: function (togglers, elements) {
    togglers.each(function (toggler) {
      element = elements[togglers.indexOf(toggler)];
      this.addSection(toggler, element);
      element.collapsed = true; 
    }, this);
  }
});

Element.implement({
  lookForCollapsed: function () {
    if (this.collapsed) return this;
    else if (this.getParent()) return this.getParent().lookForCollapsed();
    else return null;
  }
});








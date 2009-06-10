Element.implement({
  isVisible: function() {
   return this.getStyle('display') != 'none';
  },
  toggle: function() {
   return this[this.isVisible() ? 'hide' : 'show']();
  },
  hide: function() {
   this.originalDisplay = this.getStyle('display'); 
   this.setStyle('display','none');
   return this;
  },
  show: function(display) {
   this.originalDisplay = (this.originalDisplay=="none")?'block':this.originalDisplay;
   this.setStyle('display', (display || this.originalDisplay || 'block'));
   return this;
  },
  moveto: function (here) {
      this.setStyle('top', here.y);
      this.setStyle('left', here.x);
  },
  toBottom: function () {
   this.setStyles({
     'top': window.getScrollTop() + window.getHeight() - parseInt(this.getStyle('height'), 10)
   });
  },
  getElementsIncludingSelf: function (selector) {
    elements = this.getElements(selector);
    if (this.match(selector)) elements.unshift(this);
    return elements;
  },
  idparts: function () {
      var parts = this.id.split('_');
      return {
        'id' : parts[parts.length-1],
        'type' : parts[parts.length-2],
        'context' : parts[parts.length-3]
      };
    },
  kobbleID: function () {
    return this.idparts().id;
  },
  kobbleKlass: function () {
    return this.idparts().type;
  },
  pluralKobbleKlass: function () {
		var type = this.idparts().type;
    switch (type ) {
      case 'person':
        return 'people';
      default:
        return type + 's';
    }
  },
  kobbleTag: function () {
    return this.kobbleKlass() + '_' + this.kobbleID();
  },
  isFixed: function () {
    return this.getStyle('position') == 'fixed' || this.getParent() && this.getParent().isFixed();
  },
  getCoordinates: function(element){
    if ($body(this)) return this.getWindow().getCoordinates();
    var position = this.getPosition(element), size = this.getSize();
    var obj = {'top': position.y, 'left': position.x, 'width': size.x, 'height': size.y};
    if (this.isFixed()) {
      var offset = window.getScroll();
      obj.left = obj.left + offset.x;
      obj.top = obj.top + offset.y;
    }
    obj.right = obj.left + obj.width;
    obj.bottom = obj.top + obj.height;
    return obj;
  }

});

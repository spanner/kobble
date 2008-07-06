Browser.extend({
	supportsPositionFixed: function(){
		if(!Browser.loaded) return null;
		var test = new Element('div').setStyles({
			position: 'fixed',
			top: '0px',
			right: '0px'
		}).injectInside(document.body);
		var supported = (test.offsetTop === 0);
		test.remove();
		return supported;
	}
});

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
	idparts: function () {
    var parts = this.id.split('_');
    return {
      'id' : parts[parts.length-1],
      'type' : parts[parts.length-2],
      'context' : parts[parts.length-3]
    };
  },
  spokeID: function () {
    return this.idparts().id;
  },
  spokeType: function () {
    return this.idparts().type;
  },
  pluralSpokeType: function () {
		var type = this.idparts().type;
    switch (type ) {
      case 'person':
        return 'people';
      default:
        return type + 's';
    }
  },
  spokeTag: function () {
    return this.spokeType() + '_' + this.spokeID();
  },
  dwindle: function () {
    var element = this;
    new Fx.Morph(element, {
  		duration: 600,
  		onComplete: function () { element.destroy(); }
  	}).start({ 
  	  'opacity': 0,
  	  'width': 0,
  	  'height': 0
  	});
  },
  explode: function () {
    this.dwindle();   //temporarily
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

function $body(el){
	return el.tagName.toLowerCase() == 'body';
};

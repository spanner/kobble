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
		  'top': window.getScrollTop() + window.getHeight() - parseInt(this.getStyle('height'))
		});
	},
	idparts: function () {
    var parts = this.id.split('_');
    return {
      'id' : parts[parts.length-1],
      'type' : parts[parts.length-2],
      'context' : parts[parts.length-3]
    }
  },
  spokeID: function () {
    return this.idparts().id;
  },
  spokeType: function () {
    return this.idparts().type;
  },
  dwindle: function () {
    var element = this;
    new Fx.Morph(element, {
  		duration: 600,
  		onComplete: function () { element.remove(); }
  	}).start({ 
  	  'opacity': 0,
  	  'width': 0,
  	  'height': 0
  	});
  },
  explode: function () {
    this.dwindle();   //temporarily
  }
});

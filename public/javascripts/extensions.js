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
	getValueAsList: function (separator) {
		if (!separator) separator = /, +/
		return this.getValue().split(separator);
	},
	getValueAfterLastComma: function () {
		return this.getValueAsList().pop();
	},
	setValueAsList: function (list) {
		return this.value = list.join(", ");
	},
	setValueAfterLastComma: function (listitem) {
		var list = this.getValueAsList();
		list.pop();
		list.push(listitem);
		return this.setValueAsList(list);
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
  },
	duplicate: function () {
    var clone = this.clone();
    clone.setStyle('position', 'absolute');
    clone.setStyles(this.getCoordinates());
    return clone;
	}
});


// 
// var spokeObject = new Class({
//  initialize: function(id){
//     this.id = id;
//  }
// });
// 
// var Node = spokeObject.extend({ });
// var Source = spokeObject.extend({ });
// var Bundle = spokeObject.extend({ });
// var Tag = spokeObject.extend({ });
// var Flag = spokeObject.extend({ });
// var User = spokeObject.extend({ });
// var Post = spokeObject.extend({ });

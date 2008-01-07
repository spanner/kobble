Element.extend({
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
		this.setStyle('display',(display || this.originalDisplay || 'block'));
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
	stayBottom: function () {
		this.setStyles({
		  'top': window.getScrollTop() + window.getHeight() - parseInt(this.getStyle('height'))
		});
	}
});

String.extend({
  capitalise: function () {
    return this.charAt(0).toUpperCase() + this.substr(1).toLowerCase();
  }
});

var Model = new Class({
	initialize: function(id){
    this.id = id;
	}
});

var Node = Model.extend({ });
var Source = Model.extend({ });
var Bundle = Model.extend({ });
var Tag = Model.extend({ });
var Flag = Model.extend({ });
var User = Model.extend({ });
var Post = Model.extend({ });

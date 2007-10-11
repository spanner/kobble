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
	}
});


/**
 *
 * this is slightly adapted by will from:
 *
 * Observer - Observe formelements for changes
 *
 * @version		1.0rc1
 *
 * @license		MIT-style license
 * @author		Harald Kirschner <mail [at] digitarald.de>
 * @copyright	Author
 */

var Observer = new Class({

	options: {
		periodical: false,
		delay: 1000
	},

	initialize: function(el, onFired, options){
		this.setOptions(options);
		this.addEvent('onFired', onFired);
		this.element = $(el);
		this.listener = this.fired.bind(this);
		this.value = this.element.getValue();
		if (this.options.periodical) this.timer = this.listener.periodical(this.options.periodical);
		else this.element.addEvent('keyup', this.listener);
	},

	fired: function() {
		var value = this.element.getValueAfterLastComma();
		if (this.value == value) return;
		this.clear();
		this.value = value;
		this.timeout = this.fireEvent.delay(this.options.delay, this, ['onFired', [value]]);
	},

	clear: function() {
		$clear(this.timeout);
		return this;
	}
});

Observer.implement(new Options);
Observer.implement(new Events);


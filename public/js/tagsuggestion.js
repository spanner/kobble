// here we jump on harald k's autocompleter to make it work only on the last entry in a commented list
// and to show nicely formatted lists

var TagSuggestion = Autocompleter.Ajax.Json.extend({
	build: function() {
		this.holder = new Element('div', {
		  'class': 'taglist-holder',
		  'styles': {zIndex: this.options.zIndex}
		});
		
		this.choices = new Element('ul', {'class': 'taglist'}).injectInside(document.body);
		
    var header = new Element('div', {'class': 'taglist-header'})
                  .adopt(new Element('div', {'class': 'taglist-corner'}))
                  .adopt(new Element('div', {'class': 'taglist-bar'}));
    var footer = new Element('div', {'class': 'taglist-footer'})
                  .adopt(new Element('div', {'class': 'taglist-corner'}))
                  .adopt(new Element('div', {'class': 'taglist-bar'}));

    header.injectInside(this.holder);
    this.choices.injectInside(this.holder);
    footer.injectInside(this.holder);
    this.holder.injectInside(document.body);
    
		this.fix = new OverlayFix(this.choices);
		this.fx = this.holder.effect('opacity', $merge({
			wait: false,
			duration: 200
		}, this.options.fxOptions))
			.addEvent('onStart', function() {
				if (this.fx.now) return;
				this.choices.setStyle('display', '');
				this.fix.show();
			}.bind(this))
			.addEvent('onComplete', function() {
				if (this.fx.now) return;
				this.choices.setStyle('display', 'none');
				this.fix.hide();
			}.bind(this)).set(0);
			
		this.element.setProperty('autocomplete', 'off')
			.addEvent(window.ie ? 'keydown' : 'keypress', this.onCommand.bindWithEvent(this))
			.addEvent('mousedown', this.onCommand.bindWithEvent(this, [true]))
			.addEvent('focus', this.toggleFocus.bind(this, [true]))
			.addEvent('blur', this.toggleFocus.bind(this, [false]))
			.addEvent('trash', this.destroy.bind(this));
	},
	showChoices: function() {
		if (this.visible || !this.choices.getFirst()) return;
		this.visible = true;
		var pos = this.element.getCoordinates(this.options.overflown);
		this.holder.setStyles({
			left: pos.left,
			top: pos.bottom
		});
		if (this.options.inheritWidth) this.holder.setStyle('width', pos.width);
		this.fx.start(1);
		this.choiceOver(this.choices.getFirst());
		this.fireEvent('onShow', [this.element, this.choices]);
	},
	destroy: function() {
		this.choices.remove();
		this.holder.remove();
	},
	choiceOver: function(el) {
		if (this.selected) this.selected.removeClass('taglist-highlight');
		this.selected = el.addClass('taglist-highlight');
	},
	choiceSelect: function(el) {
		this.observer.value = el.inputValue;
		this.element.setValueAfterLastComma(el.inputValue + ', ');
		this.hideChoices();
		this.fireEvent('onSelect', [this.element], 20);
	},
	prefetch: function() {
		var val = this.element.getValueAfterLastComma();
		if (val.length < this.options.minLength) this.hideChoices();
		else if (val == this.queryValue) this.showChoices();
		else this.query();
	},
	onCommand: function(e, mouse) {
		if (mouse && this.focussed) this.prefetch();
		if (e.key && !e.shift) switch (e.key) {
			case 'enter':
				if (this.selected && this.visible) {
					this.choiceSelect(this.selected);
					e.stop();
				} return;
			case 'up': case 'down':
				if (this.observer.value != (this.value || this.queryValue)) this.prefetch();
				else if (this.queryValue === null) break;
				else if (!this.visible) this.showChoices();
				else if (this.selected){
					this.choiceOver((e.key == 'up')
						? this.selected.getPrevious() || this.choices.getLast()
						: this.selected.getNext() || this.choices.getFirst() );
					this.setSelection();
				} else {
					this.choiceOver( (e.key == 'up') ? this.choices.getFirst() : this.choices.getLast() );
				}
				e.stop(); return;
			case 'esc': this.hideChoices(); return;
		}
		this.value = false;
	},
	query: function(){
		var data = $extend({}, this.options.postData);
		data[this.options.postVar] = this.element.getValueAfterLastComma();
		this.fireEvent('onRequest', [this.element, this.ajax]);
		this.ajax.request(data);
	},
	markQueryValue: function(txt) {
		return (this.options.markQuery && this.queryValue) ? txt.replace(new RegExp('(' + this.queryValue.escapeRegExp() + ')', 'i'), '<em>$1</em>') : txt;
	}
});


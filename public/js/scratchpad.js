var Dropon = new Class({
	initialize: function (element) {
		this.container = element;
		this.isreceptive = false;
		this.isopen = false;
		this.wasopen = false;
		this.receiptAction = 'add';				// default works for sets and scratchpads and tags
		this.removeAction = 'remove';			// default works for sets and scratchpads and tags
		this.container.dropzone = this;
  },
	waitsignal: function () { return $E('div.waitforit', this.container); },
	recipient: function () { return $E('div.dropcontents', this.container); },
	contents: function () { return $ES('.draggable', this.container).map(function(el){ return el.id; }); },
	contains: function (draggee) { return this.contents().contains(draggee.tag); },
	makeReceptive: function (draggee) {
		if (!this.isreceptive) {
			var dropon = this;
			this.container.addEvents({
				'drop': function() { sleepDroppers(); dropon.receiveDrop(draggee); },
				'over': function() { 
					if (!dropon.isopen) { 
						dropon.wasopen = false; 
						dropon.open(); 
					};
					draggee.appearance(draggee.origin == dropon ? 'normal' : 'droppable');
				},
				'leave': function() { 
					if (!dropon.wasopen) dropon.close(); 
					draggee.appearance(draggee.origin ? 'deletable' : 'normal');
				}
			});
			this.isreceptive = true;
			return this.container;
		}
	},
	makeUnreceptive: function () {
		if (this.isreceptive) {
    	this.container.removeEvents('over');
    	this.container.removeEvents('leave');
    	this.container.removeEvents('drop');
			this.isreceptive = false;
		}
	},
	receiveDrop: function (draggee) {
		drop = this;
		if (this == draggee.origin) {
			draggee.release();
			
		} else if (this.contains(draggee)) {
			error('we already have that one');
			draggee.release();
			
		} else {
			draggee.disappear();
			new Ajax(this.addURL(), {
				method : 'get',
				data : {
					'scrap': draggee.tag,
					'display': display
				},
				evalResponse : false,
				update: this.recipient(),
			  onRequest: function () { drop.waiting(); },
			  onComplete: function () { 
					drop.notWaiting();
				  $ES('.draggable', drop.recipient()).each(function(item) {
				  	item.addEvent('mousedown', function(e) {
				  		e = new Event(e).preventDefault();
							new Draggee(this, e);
				  	});
				  });
				},
			  onFailure: function () { drop.notWaiting(); error('ajax call failed'); },
			}).request();
		}
  },
	removeDrop: function (draggee) {
		drop = this;
		draggee.disappear();
		new Ajax(this.removeURL(), {
			method : 'get',
			data : 'scrap=' + draggee.tag,
		  onRequest: function () { draggee.waiting(); },
		  onSuccess: function () { announce(this.response.text); draggee.fadeAndRemove(); },
		  onFailure: function () { draggee.notWaiting(); },
		}).request();
	},
	addURL: function (argument) { 
		var parts = idParts(this.container);
		return '/' + parts['type'] + 's/' + this.receiptAction + '/' + parts['id']; 
	},
	removeURL: function (argument) { 
		var parts = idParts(this.container);
		return '/' + parts['type'] + 's/' + this.removeAction + '/' + parts['id']; 
	},
	waiting: function () { this.waitsignal().show(); },
	notWaiting: function () { this.waitsignal().hide(); },
	toggle: function (delay) { this.isopen ? this.close(delay) : this.open(delay); },
	open: function (delay) { this.container.addClass('drophere')},
	close: function (delay) { this.container.removeClass('drophere')},
});

var Scratchpad = Dropon.extend({
	initialize: function(element){
		this.parent(element);
		this.foreground = null;
		this.pages = {};
		this.addPages($ES('div.scratchpage'), this.container);
		var fx = this.container.effects({duration: 1000, transition: Fx.Transitions.Cubic.easeOut});
		this.container.addEvents({
      'expand' : function() { fx.start({'height': window.innerHeight-10, 'width': 400}); },
      'contract' : function() { fx.start({'height': 127, 'width': 200}); }
    });
	},
	waitsignal: function () { return this.foreground.waitsignal(); },
	recipient: function () { return this.foreground.list; },
	addURL: function (argument) { return '/scratchpads/add/' + this.foreground.spokeID; },
	removeURL: function (argument) { return '/scratchpads/remove/' + this.foreground.spokeID; },
	contents: function () { return this.foreground.contents(); },
  addPages: function(elements){
		var pad = this;
	  elements.each(function(element){
			pad.pages[element.id] = new Scratchpage($(element));
	    if (!pad.foreground) pad.foreground = pad.pages[element.id].makeForeground();
		});
  },
	tabClick: function (tag) {
		if (tag == this.foreground.tag) {
			this.toggle();
		} else {
			this.choosePage(tag);
		}
	},
  choosePage: function (pageid) {
    this.foreground.makeBackground();
  	this.foreground = this.pages[pageid].makeForeground();
	},
	open: function (delay) {
    this.container.fireEvent('expand', null, delay);
    this.isopen = true;
	},
	close: function (delay) {
    this.container.fireEvent('contract', null, delay); 
    this.isopen = false;
	},
});

var Scratchpage = new Class({
	initialize: function(element){
		this.spokeID = idParts(element)['id'];
		this.tag = element.id;
		this.list = $E('ul', element);
		this.tab = $E('a#tab_' + this.tag);
		this.tab.addEvent('click', function (e) { 
			e.preventDefault(); 
			scratchpad.tabClick(element.id); 
		});
		this.body = $(element);
		this.list.dropzone = this;
	},
  makeForeground: function(){
    this.body.show();
    this.tab.addClass('fg');
    return this;
  },
	makeBackground: function () {
    this.body.hide();
    this.tab.removeClass('fg');
	},
	waitsignal: function () { return $ES('div.waitforit', this.body); },
	contents: function () { return this.list.getChildren().map(function(el){ return el.id; }); },
	removeDrop: function (draggee) { scratchpad.removeDrop(draggee) },
});

var Draggee = new Class({
	initialize: function(element, event){
		this.original = $E('div.thumb', element);
		if (!this.original) this.original = element;
		this.container = element;
		this.tag = element.id;
		this.link = $E('a', element);
		this.backto = element.getCoordinates(); // returns an object with keys left/top/bottom/right
		this.origin = lookForDropper(element);
		this.imgsrc = $E('img', element).getProperty('src');
		var draggee = this;
		
		this.clone = this.original.clone()
		  .setStyles(this.backto)
			.setStyles({'opacity': 0.8, 'position': 'absolute', 'display': 'block'})
			.addEvent('emptydrop', function() { 
				sleepDroppers();
				draggee.removeIfDraggedOut();
			})
			.inject(document.body);
		
  	var label = $E('div.label', this.clone);
    if (label) label.show();

		this.clone.makeDraggable({ 
			droppables: wakeDroppers(this)			// returns list of activated droppers. activating them sets up drop triggers
		}).start(event);
	},
	removeIfDraggedOut: function () {
		if (this.origin) {
			this.origin.removeDrop(this);
		} else {
			this.release();
		}
	},
	disappear: function () {
		if (this.clone) this.clone.remove();
	},
	fadeAndRemove: function () {
		var container = this.container;
	  new Fx.Styles(container, {
			duration:600,
			wait:false
		}).start({ 
			'opacity': 0,
		});
	  new Fx.Styles(container, {
			duration:600,
			wait:true
		}).start({ 
			'width': 0,
			'height': 0,
		}).chain(function () { container.remove(); });
	},
	remove: function () {
	  this.original.remove();
	},
	release: function () {
		this.moved() ? this.flyback() : this.doClick();
	},
	moved: function () {
		var now = this.clone.getCoordinates();
		return Math.abs(this.backto['left'] - now['left']) + Math.abs(this.backto['top'] - now['top']) >= clickthreshold;
	},
	flyback: function () {
		draggee = this;
		if (this.clone) this.clone.effects({duration: 400, transition:Fx.Transitions.Back.easeOut}).start(draggee.backto).chain(function(){ draggee.disappear() });
	},
	doClick: function (e) {
		this.disappear();
		window.location = this.link.href;
	},
	appearance: function (signal) {
		switch (signal){
			case 'waiting': 
				$E('img', this.clone).setProperty('src', '/images/furniture/signals/wait_32.gif');
				break;
			case 'droppable': 
				$E('img', this.clone).setProperty('src', '/images/furniture/signals/droppable.png');
				break;
			case 'deletable': 
				$E('img', this.clone).setProperty('src', '/images/furniture/signals/deletable.png');
				break;
			default: 
				$E('img', this.clone).setProperty('src', this.imgsrc);
		}
	},
	waiting: function () { this.appearance('waiting'); },
	notWaiting: function () { this.appearance('normal'); },
});


// here we jump on harald kremer's autocompleter to make it work only on the last entry in a commented list
// and to show nicely formatted lists

var TagSuggestion = Autocompleter.Ajax.Json.extend({
	updateChoices: function(choices) {
		this.choices.empty();
		this.selected = null;
		if (!choices || !choices.length) return;
		if (this.options.maxChoices < choices.length) choices.length = this.options.maxChoices;
		choices.each(this.options.injectChoice || function(choice, i){
			var el = new Element('li').setHTML(this.markQueryValue(choice));
			el.inputValue = choice;
			this.addChoiceEvents(el).injectInside(this.choices);
		}, this);
		this.showChoices();
	},
	
});



function wakeDroppers (draggee) {
	return droppers.map(function(d){ return d.makeReceptive(draggee); });
}

function sleepDroppers () {
	droppers.each(function (d) { d.makeUnreceptive() })
}

function lookForDropper (element) {
	var p = element.getParent();
	if (element.dropzone) {
		return element.dropzone;
	} else if (p && p.getParent) {
		return lookForDropper( p );
	} else {
		return null;
	}
}

var scratchpad = null;
var display = null;
var droppers = [];
var clickthreshold = 20;

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
	}
});

var Dropon = new Class({
	initialize: function (element) {
		this.container = element;
		this.isreceptive = false;
		this.isopen = false;
		this.wasopen = false;
		this.receiptAction = 'add';		// default. works for sets and scratchpads
		this.dropcall = new Xcall(this);
		this.spinner = $E('div.waitforit', this.container);
		this.container.dropzone = this;
  },
	waitsignal: function () {
		return this.spinner;
	},
	recipient: function () {
		return this.container;
	},
	makeReceptive: function (draggee) {
		if (!this.isreceptive) {
			var dropon = this;
			this.container.addEvents({
				'drop': function() { sleepDroppers(); dropon.receiveDrop(draggee); },
				'over': function() { if (!dropon.isopen) { dropon.wasopen = false; dropon.open(); }; },
				'leave': function() { if (!dropon.wasopen) dropon.close(); }
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
	contents: function () { return $ES('.draggable', this.container).map(function(el){ return el.id; }); },
	contains: function (draggee) { return this.contents().contains(draggee.tag); },
	receiveDrop: function (draggee) {
		drop = this;
		if (this == draggee.fromdrop) {
			draggee.release();
			
		} else if (this.contains(draggee)) {
			error('we already have that one');
			draggee.release();
		} else {
			new Ajax(this.actionURL(), {
				method : 'get',
				data : 'scrap=' + draggee.tag,
				evalResponse : true,
			  onRequest: function () { drop.waiting(); },
			  onComplete: function () { drop.notWaiting(); },
			  onFailure: function () { drop.notWaiting(); error('ajax call failed'); },
			}).request();
			
//	    this.dropcall.send(draggee.tag);	// onSuccess trigger in xcall calls this.receiveResponse
			draggee.disappear();
		}
  },
	receiveResponse: function (response) {
		var recp = this.recipient();
		


		
		console.log("got this response text:");
		console.log(response.text);



		
	},
	actionURL: function (argument) { 
		var parts = idParts(this.container);
		return '/' + parts['type'] + 's/' + this.receiptAction + '/' + parts['id']; 

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
	waitsignal: function () { return this.foreground.spinner; },
	recipient: function () { return this.foreground.list; },
	actionURL: function (argument) { return '/scratchpads/add/' + this.foreground.spokeID; },
	contents: function () { return this.foreground.contents(); },
	contains: function (draggee) { return this.foreground.contents(draggee); },
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
		this.tab.addEvent('click', function (e) { scratchpad.tabClick(element.id); e.preventDefault; })
		this.body = $(element);
		this.spinner = $E('div.waitforit', this.body);
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
	contents: function () {
		return this.list.getChildren().map(function(el){ return el.id; });
	},
  contains: function (draggee) {
		this.scrapids.contains(draggee.tag);
  },
});

var Draggee = new Class({
	initialize: function(element, event){
		this.original = element;
		this.tag = element.id;
		this.link = $E('a', element);
		this.backto = this.original.getCoordinates(); // returns an object with keys left/top/bottom/right
		this.fromdrop = lookForDropper(element);
		var draggee = this;
		this.clone = this.original.clone()
		  .setStyles(this.backto)
			.setStyles({'opacity': 0.8, 'position': 'absolute'})
			.addEvent('emptydrop', function() { 
				sleepDroppers();
				draggee.release();
			})
			.inject(document.body);
		
  	var label = $E('div.label', this.clone);
    if (label) label.show();
		
		this.clone.makeDraggable({ 
			droppables: wakeDroppers(this)			// returns list of activated droppers. activating them sets up drop triggers
		}).start(event);
	},
	disappear: function () {
		if (this.clone) this.clone.remove();
	},
	release: function () {
		console.log('drag released');
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
	
});




var Xcall = new Class({
	initialize: function (sender) {
		this.sender = sender;
		this.xhr = new XHR({
		  method: 'get',
		  onRequest: function () { 
				sender.waiting();
			},
		  onSuccess: function () {
				sender.notWaiting();
				sender.receiveResponse(this.response);
		    announce('ajax call successful');
		  },
		  onFailure: function () { 
				sender.notWaiting();
		    error('ajax call failed');
		  },
		});
	},
	send: function (objectTag) {
		var qs = 'scrap=' + objectTag;
		console.log("calling " + this.sender.actionURL() + ' with qs ' + qs);
		this.xhr.send(this.sender.actionURL(), qs);
	}
});











// element ids in spoke have a standard format: tag_type_id, where tag is an arbitrary identifier used to identify eg tab family, and type and id denote an object
// there must be a way to do this with a split

function idParts (el) {
  var parts = el.id.split('_');
  var splut = {
    'id' : parts[parts.length-1],
    'type' : parts[parts.length-2],
    'tag' : parts[parts.length-3]
  }
  return splut;
}

function announce (message) {
  $E('#notification').setText(message);
  var notifyfx = new Fx.Styles($E('#mastfoot'), {duration:1000, wait:false});
  notifyfx.start({
		'background-color': ['#00ff00','#559DC4'],
	}).chain(clearnotification);
}

function error (message) {
  $E('#notification').setText(message);
  var notifyfx = new Fx.Styles($E('#mastfoot'), {duration:2000, wait:false});
  notifyfx.start({
		'background-color': ['#ff0000','#559DC4'],
	}).chain(clearnotification);
}

function clearnotification (delay) {
  $E('#notification').setText('');
}

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


// now to set it all going

window.addEvent('domready', function(){

	$ES('a.displaycontrol').each(function (a) {
		a.addEvent('click', function (e) { 
			var toggled = $E('#' + this.id.replace('show','hide'))
			if (toggled.getStyle('display') == 'none') {
				this.setText(this.getText().replace('+', '-').replace('show', 'hide'));
				toggled.show();
			} else {
				this.setText(this.getText().replace('-', '+').replace('hide', 'show'));
				toggled.hide();
			}
			e.preventDefault();
		})
	});
	
	scratchpad = droppers[0] = new Scratchpad( $E('#scratchpad') );
	$ES('div.dropzone').each(function (element) {
		droppers[droppers.length] = new Dropon(element);
	});

  $ES('.draggable').each(function(item) {
  	item.addEvent('mousedown', function(e) {
  		e = new Event(e);
			e.preventDefault();
			new Draggee(this, e);
  	});
  });

});

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

var Draggee = new Class({
	initialize: function(element, event){
		var parts = idParts(element);
		this.type = parts['type'];
		this.id = parts['id'];
		this.original = element;
		this.link = $E('a', element);
		this.backto = this.original.getCoordinates(); // returns an object with keys left/top/bottom/right
		var draggee = this;
		this.clone = this.original.clone()
		  .setStyles(this.backto)
			.setStyles({'opacity': 0.8, 'position': 'absolute'})
			.addEvent('emptydrop', function() { 
				scratch.makeUnreceptive();
				whereupon = this.getCoordinates();
				if (Math.abs(draggee.backto['left'] - whereupon['left']) < 10 && Math.abs(draggee.backto['top'] - whereupon['top'] < 10)) {
					draggee.doClick();
				} else {
					draggee.flyback();
				}
			})
			.inject(document.body);
		
		// bring up little icon label	
  	var label = $E('div.label', this.clone);
    if (label) label.show();

		// make drop zones react to dragging over
		
		var droppers = $ES('div.dragto');
		droppers.each(function () {
			


		});
		droppers.include( scratch.container );
		scratch.makeReceptive(this);
		
		this.clone.makeDraggable({ 
			droppables: droppers
		}).start(event);
	},
	disappear: function () {
		if (this.clone) this.clone.remove();
	},
	flyback: function () {
		draggee = this;
		if (this.clone) this.clone.effects({duration: 400, transition:Fx.Transitions.Back.easeOut}).start(draggee.backto).chain(function(){ draggee.disappear() });
	},
	doClick: function (e) {
		draggee = this;
		draggee.disappear();
		window.location = this.link.href;
	}
});

var Dropon = new Class({
	initialize: function (element) {
		this.setid = idParts(element)['id'];
		this.container = element;
	 	var dropon = this;
		this.receiveCall = new XHR({
      method: 'get',
      onRequest: function () { 
				dropon.waiting();
			},
      onSuccess: function () {
				dropon.notwaiting();
				dropon.makeUnreceptive();
        var newitem = new Element('div').setHTML(this.response.text).inject(dropon.container);
      	new Fx.Styles(newitem, {duration:1000, wait:false}).start({'background-color': ['#559DC4','#695D54']});
        announce('item added to set');
      },
      onFailure: function () { 
				dropon.notwaiting();
        error('dropzone receive failed');
      },
    });
  },
	receiveItem: function (draggee) {
		draggee.disappear();
    this.receiveCall.send('/bundles/addmembers/' + this.setid, 'members=' + draggee.type + '_' + draggee.id + '&display=' + display);
  },
	makeReceptive: function (draggee) {
		if (!this.isreceptive) {
			var dropon = this;
			this.container.addEvents({
				'drop': function() {
					dropon.makeUnreceptive();
	        dropon.receiveItem(draggee);
				},
				'over': function() {
					this.setStyle('background-color', '#ccc');
				},
				'leave': function() {
					this.setStyle('background-color', '#fff');
				}
			});
			this.isreceptive = true;
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
	waiting: function () {
	},
	notwaiting: function () {
	}
})



var Scratchpad = new Class({
	initialize: function(element){
		this.container = element;
		this.tag = element.id;
		this.pages = {};
		this.foreground = null;
		this.isreceptive = false;
		this.isopen = false;
		this.wasopen = false;
    
		this.addPages($ES('div.scratchpage'), this.container);

		var fx = this.container.effects({duration: 1000, transition: Fx.Transitions.Cubic.easeOut});
		this.container.addEvents({
      'expand' : function() { fx.start({'height': window.innerHeight-10, 'width': 400}); },
      'contract' : function() { fx.start({'height': 127, 'width': 200}); }
    });

	},
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
	toggle: function (delay) {
		this.isopen ? this.close(delay) : this.open(delay);
	},
	open: function (delay) {
    this.container.fireEvent('expand', null, delay);
    this.isopen = true;
	},
	close: function (delay) {
    this.container.fireEvent('contract', null, delay); 
    this.isopen = false;
	},
	makeReceptive: function (draggee) {
		if (!this.isreceptive) {
			this.container.addEvents({
				'drop': function() {
					scratch.makeUnreceptive();
	        scratch.foreground.receiveItem(draggee);
				},
				'over': function() {
					if (!scratch.isopen) { scratch.wasopen = false; scratch.open(); };
				},
				'leave': function() {
	        if (!scratch.wasopen) scratch.close();
				}
			});
			this.isreceptive = true;
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
});

var Scratchpage = new Class({
	initialize: function(element){
		var parts = idParts(element);
		this.spid = parts['id'];
		this.tag = element.id;
		this.list = $E('ul', element);
		this.tab = $E('a#tab_' + this.tag);
		this.tab.addEvent('click', function (e) { scratch.tabClick(element.id); return false; })
		this.body = $(element);
		this.waitsignal = $E('div.waitforit', this.body);
		
		var scratchpage = this;
		$ES('a.reorder').addEvent('click', function (e) { scratchpage.makeSortable(); return false; })
		this.receiveCall = new XHR({
      method: 'get',
      onRequest: function () { 
				scratchpage.waitsignal.show(); 
			},
      onSuccess: function () {
        scratchpage.waitsignal.hide();
        var newitem = new Element('li').addClass('draggable').setHTML(this.response.text).inject(scratchpage.list);
      	new Fx.Styles(newitem, {duration:1000, wait:false}).start({'background-color': ['#559DC4','#695D54']});
        announce('item added to scratchpad');
				scratch.makeUnreceptive();
      },
      onFailure: function () { 
        error('scratchpad receive failed');
        scratchpage.waitsignal.hide(); 
      },
    });
		this.sortCall = new XHR({
      method: 'get',
      onSuccess: function () { announce('scratchpad reordered');	},
      onFailure: function () { error('scratchpad reorder failed'); },
		});
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
  containsItem: function (element) {
		// body...
  },
	receiveItem: function (draggee) {
		draggee.disappear();
    this.receiveCall.send('/scratchpads/scratch/' + this.spid, 'scrap=' + draggee.type + '_' + draggee.id);
  },
});


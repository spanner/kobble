var intf = null;

window.addEvent('domready', function(){
  intf = new Interface();
  // console.profile()
  intf.activate();
  // console.profileEnd()
  // window.addEvent('scroll', function (e) { intf.moveFixed(e); });
  // window.addEvent('resize', function (e) { intf.moveFixed(e); });
});

var Interface = new Class({
	initialize: function(){
    this.tips = null;
    this.dragging = null;
    this.draggables = [];
    this.droppers = [];
    this.tagboxes = [];
    this.tabs = [];
    this.tabsets = {};
    this.fixedbottom = [];
    this.inlinelinks = [];
    this.clickthreshold = 6;
    this.announcer = $E('div#notification');
    this.admin = $E('div#admin');
    this.fader = new Fx.Tween(this.announcer, 'opacity', {duration: 'long', link: 'chain'});
	},
  announce: function (message, title) {
    this.announcer.removeClass('error');
    this.announcer.getElements('h4')[0].setText(title || 'Notice');
    this.announcer.getElements('p')[0].setText(message);
    this.fader.start(1);
    this.fader.start(0);
  },
  complain: function (message, title) {
    this.announcer.addClass('error');
    this.announcer.getElements('h4')[0].setText(title || 'Error');
    this.announcer.getElements('p')[0].setText(message);
    this.fader.start(1);
    this.fader.start(0);
  },
  flash: function (element, color) {
    element.highlight(color);
  },
  moveFixed: function (e) {
    this.fixedbottom.each(function (element) { element.toBottom(); });
  },
  prefer: function (setting, value) {
    this.preferences[setting] = value;
  },
  hideTips: function () {
    if (this.tips) this.tips.hide();
  },

  startDragging: function (helper) {
    $$('.hideondrag').each(function (element) { element.setStyle('visibility', 'hidden'); })
    $$('.showondrag').each(function (element) { element.setStyle('visibility', 'visible'); })
    this.dragging = helper;
    var catchers = [];
  	this.tabs.each(function (t) { t.makeReceptiveTo(helper); })
  	this.droppers.each(function(d){ if (d.makeReceptiveTo(helper)) catchers.push(d.container); });
  	return catchers;
  },
  stopDragging: function (helper) {
    this.dragging = null;
    this.tabs.each(function (t) { t.makeUnreceptive(helper); })
    this.droppers.each(function (d) { d.makeUnreceptive(helper); })
    $$('.hideondrag').each(function (element) { element.setStyle('visibility', 'visible'); })
    $$('.showondrag').each(function (element) { element.setStyle('visibility', 'hidden'); })
  },
  lookForDropper: function (element) {
    if (element) {
    	if (element.dropzone) {
    		return element.dropzone;
    	} else {
      	var p = element.getParent();
    	  if (p && p.getParent) {
    		  return this.lookForDropper( p );
    	  } else {
    		  return null;
    	  }
      }
    }
  },
  addTabs: function (elements) {  
    elements.each(function (element) { intf.tabs.push(new Tab(element)); });
  },
  addScratchTabs: function (elements) {
    elements.each(function (element) { intf.tabs.push(new ScratchTab(element)); });
  },
  addDropzones: function (elements) {
    elements.each(function (element) { intf.droppers.push(new Dropzone(element)); });
  },
  addTrashDropzones: function (elements) {
    elements.each(function (element) { intf.droppers.push(new TrashDropzone(element)); });
  },
  makeDraggables: function (elements) {
    elements.each(function (element) { 
      element.addEvent('mousedown', function(event) { new Draggee(element, event); }); 
    });
  },
  makeFixed: function (elements) {
    elements.each(function (element) { intf.fixedbottom.push(element); });
  },
  makeTippable: function (elements) {
    this.tips = new SpokeTips(elements);
  },
  makeToggle: function (elements) {
    elements.each(function (element) { intf.inlinelinks.push(new Toggle(element)); });
  },
  makeSuggester: function (elements) {
    elements.each(function (element) {
      var waiter = new Element('div', {'class': 'autocompleter-loading'}).setHTML('&nbsp;').inject(element, 'after');
      intf.tagboxes.push(new Autocompleter.Ajax.Json(element, '/tags/matching', { 'indicator': waiter, 'postVar': 'stem', 'multiple': true }));
    });
  },
  makeSnipper: function (elements) {
    elements.each(function (element) { 
      element.addEvent('click', function (e) { new Snipper(element, e); })
    });
  },
  
  makeInlineCreate: function (elements) {
    elements.each(function (element) { 
      element.addEvent('click', function (e) { new ModalForm(element, e); })
    });
  },
    
  // this is the main page initialisation: it gets called on domready
  
  activate: function (element) {
    var scope = element || document;
	  this.addDropzones( scope.getElements('.catcher') );
	  this.addTrashDropzones( scope.getElements('.trashdrop') );
	  this.makeDraggables( scope.getElements('.draggable') );
    this.makeTippable( scope.getElements('.tippable') );
	  this.addTabs(scope.getElements('a.tab'));
	  this.addScratchTabs(scope.getElements('a.padtab'));
	  this.makeFixed(scope.getElements('div.fixedbottom'));
    this.makeToggle(scope.getElements('a.toggle'));
    this.makeSuggester(scope.getElements('input.tagbox'));
    this.makeInlineCreate(scope.getElements('a.inlinecreate'));
    this.makeSnipper(scope.getElements('a.snipper'));
  },
  
  activateElement: function (element) {
    this.activate(element);
    
    //and the thing itself. there doesn't seem to be a cleaner way to work with thing-and-children
    
	  if (element.hasClass('catcher')) this.addDropzones( [element] );
	  if (element.hasClass('trashdrop')) this.addTrashDropzones( [element] );
	  if (element.hasClass('draggable')) this.makeDraggables( [element] );
    if (element.hasClass('tippable')) this.makeTippable( [element] );
	  if (element.hasClass('tab')) this.addTabs( [element] );
	  if (element.hasClass('padtab')) this.addScratchTabs( [element] );
	  if (element.hasClass('fixedbottom')) this.makeFixed( [element] );
    if (element.hasClass('toggle')) this.makeToggle( [element] )
    if (element.hasClass('snipper')) this.makeSnipper( [element] )
  },
  getSelectedText: function () {
  	var txt = '';
  	if (window.getSelection) {
  		txt = window.getSelection();
  	} else if (document.getSelection) {
  		txt = document.getSelection();
  	} else if (document.selection) {
  		txt = document.selection.createRange().text;
  	}
    return '' + txt;
  },
  getPlayerIn: function () {
    var player = document.spannerplayer;
    if (player && player.playerOk() ) return player.playerIn();
  },
  getPlayerOut: function () {
    var player = document.spannerplayer;
    if (player && player.playerOk() ) return player.playerOut();
  }
});

var SpokeTips = new Class({
  Extends: Tips,
  options: {
   onShow: function(tip) { if (!intf.dragging) tip.fade(0.8); },
   onHide: function(tip) { tip.fade('out'); }
  },
  build: function(el){
    el.$attributes.myTitle = el.title || el.getElement('div.tiptitle').getText();
    el.$attributes.myText = el.getElement('div.tiptext').getText();
		el.removeProperty('title');
		if (el.$attributes.myTitle && el.$attributes.myTitle.length > this.options.maxTitleChars)
			el.$attributes.myTitle = el.$attributes.myTitle.substr(0, this.options.maxTitleChars - 1) + "&hellip;";
		el.addEvent('mouseenter', function(event){
			this.start(el);
			if (!this.options.fixed) this.locate(event);
			else this.position(el);
		}.bind(this));
		if (!this.options.fixed) el.addEvent('mousemove', this.locate.bind(this));
		var end = this.end.bind(this);
		el.addEvent('mouseleave', end);
 }
});

var Dropzone = new Class({
	initialize: function (element) {
    // console.log('new dropzone: ' + element.id);
		this.container = element;
	  this.tag = element.id;
	  this.name = element.getProperty('title') || element.getText();
		this.container.dropzone = this;   // when a draggee is picked up we climb the tree to see if it is being dragged from somewhere
		this.isReceptive = false;
		this.isRegretful = false;
		this.receiptAction = 'catch';
		this.removeAction = 'drop';
		this.waitSignal = null;
		this.catches = this.container.getProperty('catches');
  },
  zoneType: function () {
    switch (this.container.tagName ) {
      case 'UL':
        return 'list';
      default:
        return 'single';
    }
  },
  spokeID: function () { return this.container.spokeID(); },
  spokeType: function () { return this.container.spokeType(); },
	recipient: function () { return this.container; },
	flasher: function () { return this.container; },
	contents: function () { return this.container.getElements('.draggable').map(function(el){ return el.id; }); },
	contains: function (draggee) { return this.contents().contains(draggee.tag); },
	can_catch: function (type) { if (this.catches) return this.catches == 'all' || this.catches.split(',').contains(type); },
  
  makeReceptiveTo: function (helper) {
    // this gets called when a drag from elsewhere enters this space
    var type = helper.draggee.spokeType();
    if (this.can_catch(type)) {
      var dropzone = this;
      dropzone.container.addEvents({
        'drop': function() { 
          console.log('drop!');
    		  dropzone.receiveDrop(helper); 
    		},
        'mouseenter': function() { dropzone.showInterest(helper); },
        'mouseleave': function() { dropzone.loseInterest(helper); },
      });
      return this.isReceptive = true;
    } else {
      return this.isReceptive = false;
    }
  },
  makeUnreceptive: function (helper) {
    // this gets called when a drag from elsewhere leaves this space
    if (this.isReceptive) {
      this.container.removeEvents('mouseenter');
      this.container.removeEvents('mouseleave');
      this.container.removeEvents('drop');
      this.isReceptive = false;
    }
  },
  makeRegretful: function (helper) {
    // this gets called when we drag something out of this space that began here
    console.log('makeRegretful');
    var dropzone = this;
    dropzone.container.addEvents({
      mouseenter: function() {
        console.log('back again');
        helper.clearState();
        dropzone.container.removeClass('bereft');
      },
      mouseleave: function() {
        console.log('leaving the area');
        // helper.droppable(dropzone);
        dropzone.container.addClass('bereft');
      }
    });
    this.isRegretful = true;
  },
  makeUnregretful: function () {
    if (this.isRegretful) {
      console.log('makeUnregretful');
      this.container.removeEvents('mouseenter');
      this.container.removeEvents('mouseleave');
      this.isRegretful = false;
    }
  },
  showInterest: function (helper) {
    if (this.container != helper.draggee.original && this != helper.draggee.draggedfrom && !this.contains(helper.draggee)) {
      this.container.addClass('drophere');
      if (this.tab) this.tab.tabhead.addClass('over');
      // helper.insertable(this);
    }
  },
  loseInterest: function (helper) { // nb. trigger set up during showInterest
    this.container.removeClass('drophere');
    if(this.tab) this.tab.tabhead.removeClass('over');
  },
	        
	receiveDrop: function (helper) {
	  intf.stopDragging();
		var dropzone = this;
	  var message = helper.getText() + '?';
		var draggee = helper.draggee;
		dropzone.loseInterest(helper);
		
		console.log(dropzone.name + ' catching ' + draggee.name);
		
		if (dropzone == draggee.draggedfrom) {
			helper.flyback();
			
		} else if (dropzone.contains(draggee)) {
		  console.log(draggee);
			intf.complain(draggee.name + ' is already there');
			helper.flyback();
			
		} else {
			helper.remove();

			var req = new Request.JSON( {
			  url: this.addURL(draggee),
				method: 'get',
			  onRequest: function () { 
			    dropzone.waiting(); 
			    draggee.waiting(); 
			  },
        onSuccess: function(response){
          console.log('outcome = ' + response.outcome + ', message = ' + response.message + ', consequence = ' + response.consequence);
          if (response.outcome == 'success') {
            dropzone.notWaiting();
            draggee.notWaiting();
            switch (response.consequence) {
            case "move": 
              dropzone.accept(draggee);
              draggee.disappear();
              break; 
            case "delete":
              draggee.disappear();
              break;
            default:
              dropzone.accept(draggee)
            }
            intf.announce(response.message);
          } else {
            intf.complain(response.message);
          }
        },
			  onFailure: function (response) { 
			    dropzone.notWaiting(); 
			    draggee.notWaiting(); 
			    intf.complain('remote call failed');
			  }
			}).send();
		}
  },
	removeDrop: function (helper) {
	  intf.stopDragging();
		var dropzone = this;
    var draggee = helper.draggee;
	  var message = helper.getText() + '?';
		helper.remove();
	  
		var req = new Request.JSON( {
		  url: this.removeURL(draggee),
			method: 'delete',
		  onRequest: function () { draggee.waiting(); },
		  onSuccess: function (response) { 
        if (response.outcome == 'success') {
		      intf.announce(response.message); 
          draggee.disappear();
		    } else {
          intf.complain(response.message);
		    }
		  },
		  onFailure: function (response) {
		    intf.complain('remote call failed');
		  }
		}).send();
	},
	addURL: function (draggee) { 
		return '/' + this.spokeType() + 's/' + this.receiptAction + '/' + this.spokeID() + '/' + draggee.spokeType() + '/' + draggee.spokeID();  
	},
	removeURL: function (draggee) { 
		return '/' + this.spokeType() + 's/' + this.removeAction + '/' + this.spokeID() + '/' + draggee.spokeType() + '/' + draggee.spokeID(); 
	},
	waiting: function () {
	  if (this.zoneType() == 'list') {
      this.waitSignal = new Element('li', { 'id': 'waiter', 'class': 'draggable waiting' });
      this.waitSignal.setText('working...');
      this.waitSignal.injectInside(this.container);
      return this.waitSignal;
	  } else {
	    this.container.addClass('waiting');
	  }
	},
	notWaiting: function () { 
	  if (this.zoneType() == 'list') {
      if (this.waitSignal) {
        this.waitSignal.remove();
        this.waitSignal = null;
      } 
	  } else {
	    this.container.removeClass('waiting');
	  }
	},
	accept: function (draggee) {
    if (this.zoneType() == 'list') {
      var element = draggee.clone().injectInside(this.container);
      element.set('id', this.tag + '_' + draggee.tag);
      console.log(element.id);
      intf.activateElement(element);
    }
	}
});

var TrashDropzone = new Class({
  Extends: Dropzone,
	initialize: function (element) { 
    this.parent(element);
    this.receiptAction = 'trash';
	},
	showInterest: function (helper) { 
		var dropzone = this;
    // var state = helper.getState();
	  var text = helper.getText();
	  dropzone.container.addClass('drophere');
	  dropzone.container.addEvents({
	    'leave': function() { 
			  dropzone.loseInterest();
        // helper.setState(state, text);
			}
	  });
	  helper.deleteable(dropzone);
	},
	addURL: function (draggee) { 
		return draggee.spokeType() +'s/trash/' + draggee.spokeID();  
	}
})

// now we always drag whole <li> elements. no more thumbnails.

var Draggee = new Class({
	initialize: function(element, e) {
	  event = new Event(e).stop();
	  event.preventDefault();
		this.original = element;
		this.tag = element.spokeType() + '_' + element.spokeID();   //omitting other id parts that only serve to avoid duplicate element ids
		this.link = element.getElements('a')[0];
		this.name = this.findTitle();
    this.draggedfrom = intf.lookForDropper(element.getParent());
    this.helper = new DragHelper(this);
    this.helper.start(event);
	},
  spokeID: function () { return this.original.spokeID(); },
  spokeType: function () { return this.original.spokeType(); },
	doClick: function (e) { 
	  console.log('click!');
	  this.link.fireEvent('click');
	},
	waiting: function () { this.original.addClass('waiting'); },
	notWaiting: function () { this.original.removeClass('waiting'); },
	remove: function () { this.original.remove(); },
	explode: function () { this.original.explode(); },
	disappear: function () { this.original.dwindle(); },
	clone: function () { return this.original.clone(); },
	findTitle: function () { 
	   return this.link.getText() || this.original.getElements('div.tiptitle').getText();
	}
});

// the dragged representation is a new DragHelper object with useful abilities
// and a tooltip-like label

var DragHelper = new Class({
	initialize: function(draggee){
	  this.draggee = draggee;
		this.original = this.draggee.original;
		this.container = new Element('div', { 'class': 'drag-tip' }).injectInside(document.body);
		this.textholder = new Element('div', { 'class': 'drag-title' }).injectInside(this.container);
		this.footer = new Element('div', { 'class': 'drag-text' }).injectInside(this.container);
		this.container.dragHelper = this;
		this.name = this.draggee.name;
		this.setText(this.name);
		this.clickedat = null;
		this.offsetY = this.container.getCoordinates().height + 12;
	  this.offsetX = Math.floor(this.container.getCoordinates().width / 2);
		var droppables = intf.startDragging(this);
		var dh = this;
    this.dragmove = this.container.makeDraggable({ droppables: droppables });
		this.flybackto = this.original.getCoordinates();
		this.flybackto['opacity'] = 0.4;
		this.flybackfx = new Fx.Morph(this.container, {
		  duration: 'long', 
		  transition: 'bounce:out',
		  onComplete: function () { dh.remove(); }
		});
	},
	start: function (event) {
	  event.stop();
	  event.preventDefault();
	  this.clickedat = event.client;
	  var dh = this;
	  this.container.addEvent('emptydrop', function() { dh.emptydrop(); }) 		
	  if (this.draggee.draggedfrom) this.draggee.draggedfrom.makeRegretful(this);
		this.moveto(event.page);
		this.dragmove.start(event);
		this.show();
	},
	emptydrop: function () {
		intf.stopDragging();
		if (!this.hasMoved()) {
		  this.draggee.doClick();
		  this.remove();
    } else if (this.draggee.draggedfrom) {
      this.draggedOut();
		} else {
		  this.flyback();
		}
	},
	draggedOut: function () {
	  this.remove();
    if (this.draggee.draggedfrom) this.draggee.draggedfrom.removeDrop(this);
	},
	flyback: function () {
    this.flybackfx.start( this.flybackto );

	},
	moveto: function (here) {
    this.container.setStyles({top: here.y - this.offsetY, left: here.x - this.offsetX});
	},
  hasMoved: function () {
    var now = this.container.getPosition();
    return Math.abs(this.clickedat.x - now.x) + Math.abs(this.clickedat.y - now.y) >= intf.clickthreshold;
  },
  show: function () { this.container.fade(0.8); },
  hide: function () { this.container.fade('out'); },
	remove: function () { this.container.fade('out'); },
	explode: function () { this.remove(); },  // something more explosive should happen here
	disappear: function () { this.original.dwindle(); },
	setText: function (text) { this.textholder.set('text', text); },
	getText: function () { return this.textholder.get('text'); }
});




var Tab = new Class({
	initialize: function(element){
		this.tabhead = element;
		this.name = this.tabhead.get('text');
    var parts = element.id.split('_');
		this.tag = parts.pop();
		this.settag = parts.pop();
		this.tabbody = $E('#' + this.settag + '_' + this.tag);
		this.tabset = null;
    this.addToSet();
 		this.tabhead.onclick = this.select.bind(this);
	},
	addToSet: function () {
    this.tabset = intf.tabsets[this.settag] || new TabSet(this.settag);
    this.tabset.addTab(this);
	},
	select: function (e) {
	  if (e) {
	    e = new Event(e).stop();
	    e.preventDefault();
	  }
	  this.tabhead.blur();
    this.tabset.select(this.tag);
	},
	reselect: function (e) {},
	deselect: function (e) {},
  showBody: function(){
    this.tabbody.show();
    this.tabhead.addClass('fg');
  },
  hideBody: function(){
    this.tabbody.hide();
    this.tabhead.removeClass('fg');
  },
	respond: function (helper) {
	  this.select();
	},
	receiveDrop: function (helper) {
    return false;
	},
	makeReceptiveTo: function (draggee) {
	  var stab = this;
	  this.tabset.holdopen = true;
 		this.tabhead.addEvent('mouseenter', function (e) { stab.select(e); });
	},
	makeUnreceptive: function () {
	  this.tabset.holdopen = false;
    this.tabhead.removeEvents('mouseenter');
	},
	erase: function (argument) {
    this.tabhead.remove(); 
    this.tabbody.dwindle(); 
    this.tabset.removeTab(this);
	},
});

var TabSet = new Class({
	initialize: function(tag){
	  this.tabs = [];
    this.tag = tag;
    this.headcontainer = $E('#headbox_' + this.tag);
	  this.container = $E('#box_' + this.tag);
    this.foreground = null;
	  intf.tabsets[this.tag] = this;
	},
	addTab: function (tab) {
    this.tabs.push(tab);
    if (this.tabs.length == 1) {
      tab.showBody();
      this.foreground = tab;
    } else {
      tab.hideBody();
    }
	},
	removeTab: function (tab) {
    this.tabs.remove(tab);
    if (this.foreground == tab) this.select();
	},
	select: function (tag) {
	  if (tag == this.foreground.tag) {
  	  this.reselect();
	  } else {
	    this.foreground.deselect();
  	  tabset = this;
  	  this.tabs.each(function (tab) { 
  	    if (!tag) tag = tab.tag;
  	    if (tag == tab.tag) {
  	      tab.showBody();
  	      tabset.foreground = tab;
  	    } else {
          tab.hideBody();
  	    }
  	  });
      this.postselect();
	  }
	},
	reselect: function (tag) {
	  this.foreground.reselect();
	},
	postselect: function (tag) { 
	  // used in subclasses to eg open scratchpad
	}
});

var ScratchTab = new Class({
  Extends: Tab,
	initialize: function(element){
		this.parent(element);
 		this.holdopen = false;
		this.dropzone = this.tabbody.getElement('.catcher');
  	this.padform = null;
    var stab = this;
    this.formholder = new Element('div', {'class': 'padform bigspinner'}).inject(this.tabbody, 'top').set('html', '&nbsp;').hide();
    this.showformfx = new Fx.Tween(this.formholder, 'width', {duration: 'long', transition: 'cubic:out'});
    this.hideformfx = new Fx.Tween(this.formholder, 'width', {duration: 'medium', transition: 'cubic:out', onComplete: function () { stab.hideForm(); }});
    this.tabbody.getElements('a.renamepad').each(function (a) { a.onclick = stab.getForm.bind(stab); });
    this.tabbody.getElements('a.setfrompad').each(function (a) { a.onclick = stab.toSet.bind(stab); });
    this.tabbody.getElements('a.createpad').each(function (a) { a.onclick = stab.createTab.bind(stab); });
  },
  open: function () { 
    this.tabset.open(); 
  },
	close: function () { 
    this.hideForm();
	  this.tabset.close(); 
	},
	addToSet: function () {
    this.tabset = intf.tabsets[this.settag] || new ScratchSet(this.settag);
    this.tabset.addTab(this);
	},
	reselect: function (tag) {
    this.tabset.toggle();
	},
	deselect: function () {
    this.hideForm();
	},
	toSet: function (e) {
	  this.tabbody.getElements('li').addClass('waiting');
	  // ...and let nature take its course
	},
	getForm: function (e) {
	  e = new Event(e).stop();
    e.preventDefault();
    this.showForm(e.target.getProperty('href'));
  },
  showForm: function (url) {
    if (!url) url = '/scratchpads/new';
    this.tabhead.addClass('editing');
    this.formholder.show();
    if (! this.padform) {
  	  this.showformfx.start(440);
  	  var stab = this;
  		new Request.HTML({
  		  url: url,
  			method: 'get',
  			update: stab.formholder,
  		  onSuccess: function () { stab.bindForm() },
  		  onFailure: function () { stab.hideFormNicely(); }
  		}).send();
    }
	},
	hideFormNicely: function (e) {
    if (e) e = new Event(e).stop();
    this.hideForm();
    //     var stab = this;
    // this.hideformfx.start(0);
	},
	hideForm: function (e) {
    if (e) e = new Event(e).stop();
    this.formholder.hide();
    this.tabhead.removeClass('editing');
	},
	bindForm: function () {
		var stab = this;
    this.formholder.removeClass('bigspinner');
    this.padform = this.formholder.getElement('form');
		this.padform.onsubmit = this.doForm.bind(this);
		this.padform.getElements('a.cancel_form').each(function (a) { a.onclick = stab.hideFormNicely.bind(stab); });
		this.padform.getElements('a.remove_tab').each(function (a) { a.onclick = stab.erase.bind(stab); });
		this.padform.getElement('input.titular').focus();
	},
	doForm: function (e) {
	  e = new Event(e).stop();
	  e.preventDefault();
	  var stab = this;
    this.padform.hide();
    this.formholder.addClass('bigspinner');
        
    var update = {
		  '_method': this.padform.getElement('input[name=_method]') ? this.padform.getElement('input[name=_method]').get('value') : '',
		  'scratchpad[name]': this.padform.getElement('#scratchpad_name').get('value'),
		  'scratchpad[body]': this.padform.getElement('#scratchpad_body').get('value'),
		};

		new Request.JSON({
		  url: this.padform.get('action'),
			method: 'post',
			data: update,
		  onSuccess: function (response) {
        stab.hideFormNicely();
        stab.tabhead.set('text', response.name);
        stab.tabhead.set('title', response.body);
        console.log(response);
        if (response.updated_by == null) {
          console.log('this is a new tab');
          
          var tabs = stab.tabset;
          tabs.removeTab(stab);
          stab.tabhead.set('id', 'tab_scratchpad_' + response.id);
          
      		new Request.HTML({
      		  url: '/scratchpads/' + response.id,
      			method: 'get',
      			update: stab.tabbody,
      		  onSuccess: function () { 
      		    intf.addScratchTabs([stab.tabhead]);
      		    intf.addDropzones(stab.tabbody.getElements('.catcher'));
      		    tabs.select('scratchpad_' + request.id);
      		  },
      		  onFailure: function () { intf.complain('no way'); }
      		}).send();
          
        }
      },
		  onFailure: function (response) { stab.hideForm(); intf.complain('remote call failed') }
		}).send();
	},
	createTab: function (e) {
    this.tabset.createTab(e);
	}
});

var ScratchSet = new Class({
  Extends: TabSet,
	initialize: function(tag){
		this.parent(tag);
	  this.container = $E('#box_scratchpad');
	  this.headcontainer = $E('#headbox_scratchpad');
		this.isopen = false;

		this.openpadFX = new Fx.Tween(this.container, 'width', {duration: 400, transition: Fx.Transitions.Cubic.easeOut});
		this.opentabsFX = new Fx.Tween(this.headcontainer, 'right', {duration: 400, transition: Fx.Transitions.Cubic.easeOut});
		this.closepadFX = new Fx.Tween(this.container, 'width', {duration: 1000, transition: Fx.Transitions.Bounce.easeOut});
		this.closetabsFX = new Fx.Tween(this.headcontainer, 'right', {duration: 1000, transition: Fx.Transitions.Bounce.easeOut});
	},
  postselect: function () {
    if (!this.isopen) this.open();
  },
  open: function () {
    this.openpadFX.start( 440 );
    this.opentabsFX.start( 438 );
    this.isopen = true;
	},
	close: function (delay) {
    this.closepadFX.start( 10 ); 
    this.closetabsFX.start( 8 ); 
    this.isopen = false;
	},
	toggle: function (delay) {
    this.isopen && !this.holdopen ? this.close(delay) : this.open(delay);
	},
	getForm: function (url) {
    this.foreground.getForm(url);
	},
	createTab: function (e) {
	  e = new Event(e).stop();
	  e.preventDefault();
    var tabs = this;
    var newhead = new Element('a', {
      'id': 'tab_scratchpad_new',
      'class': 'padtab', 
      'href': "#"
    }).setText('new scratchpad').injectInside(this.headcontainer);
    var newbody = new Element('div', {
      'id': 'scratchpad_new',
      'class': 'scratchpage'
    }).injectInside(this.container);
    this.newtab = new ScratchTab(newhead);
    console.log(this.newtab);
    this.newtab.select(e);
    this.newtab.showForm('/scratchpads/new');
    
	}
});

var AutoLink = new Class({
  initialize: function (a) {
    this.link = a;
    this.link.onclick = this.send.bind(this);
  },
  method: function () {
    return 'GET';
  },
  send: function (e) {
    e = new Event(e).stop();
    e.preventDefault();
    this.link.blur();
    al = this;
		new Request.JSON({
		  url: al.link.getProperty('href'),
			method: this.method(),
		  onRequest: function () {al.waiting();},
		  onComplete: function (response) {al.finished(response);},
		  onFailure: function (response) {al.failed(response);}
		}).send();
  },
  waiting: function () { this.link.addClass('waiting'); },
  notWaiting: function () { this.link.removeClass('waiting'); },
  finished: function (response) {
    this.notWaiting();
    //...
  },
  failed: function (response) {
    this.notWaiting();
    //...
  }
});

var Toggle = new Class({
  Extends: AutoLink,
  // method: function () {
  //   return this.ticked() ? 'DELETE' : 'POST';
  // },
  finished: function (response) {
    this.notWaiting();
    if (response.outcome == 'failure') {
      intf.complain(response.message);
      
    } else if (response.outcome == 'active') {
      this.link.addClass('ticked');
      this.link.removeClass('crossed');
      intf.announce(response.message);
      
    } else {
      this.link.removeClass('ticked');
      this.link.addClass('crossed');
      intf.announce(response.message);
    }
  },
  ticked: function () {
    return this.link.hasClass('ticked');
  }
});

var ModalForm = new Class ({
  initialize: function (element, e) {
    event = new Event(e);
    event.preventDefault();
    var mf = this;
    element.blur();
		this.link = element;
		this.form = null;
    this.waiter = null;
		this.eventPosition = this.position.bind(this);
		this.overlay = new Element('div', {'class': 'overlay'}).inject(document.body);
		this.floater = new Element('div', {'class': 'floater'}).inject(document.body);
		this.spinner = new Element('div', {'class': 'floatspinner'}).set('html', '&nbsp;').inject(this.floater).show();
		console.log('spinner');
		console.log(this.spinner);
		this.formholder = new Element('div', {'class': 'modalform'}).inject(this.floater).hide();
    this.responseholder = new Element(this.responseholdertype());
		this.overlay.onclick = this.hide.bind(this);
    this.formholder.set('load', {
      onRequest: function () { mf.waiting(); },
      onSuccess: function () { mf.prepForm(); },
      onFailure: function () { mf.failed(); }
    });
    this.show();
    console.log('destination:');
    console.log(this.destination());
  },
  url: function () { return this.link.getProperty('href'); },
  destination: function () { return $E('#' + this.link.id.replace('extend_', '')); },
  responseholdertype: function () { return 'select'; },
 
  show: function () {
    this.position();
    this.getForm();
		this.setup(true);
		this.top = window.getScrollTop() + (window.getHeight() / 15);
		this.floater.setStyles({top: this.top, display: ''});
		this.overlay.fade(0.6);
    this.floater.show();
  },

  hide: function () {
    this.floater.fade('out');
		this.overlay.fade('out');
		this.setup(false);
  },
  
  // overridable close-form link suitable for insertion into the dialog somewhere
  canceller: function () {
    var a = new Element('a', {'class': 'canceller', 'href': '#'}).setText('cancel [x]');
    a.onclick = this.hide.bind(this);
    return a;
  },
  
  // hide embeds and objects to prevent display glitches
	setup: function(opening){
		var fn = opening ? 'addEvent' : 'removeEvent';
		window[fn]('scroll', this.eventPosition)[fn]('resize', this.eventPosition);
  },
  
  //position whiteout overlay
	position: function(){
		dimensions = this.floater.getCoordinates();
		this.floater.setStyles({
		  'top': window.getScrollTop() + Math.floor(window.getHeight() - dimensions.height) / 2, 
		  'left': window.getScrollLeft() + Math.floor((window.getWidth() - dimensions.width) / 2), 
		});
		this.overlay.setStyles({
		  'top': window.getScrollTop(), 
		  'height': window.getHeight()
		});
	},
	
  getForm: function () {
    this.canceller().inject(this.floater, 'top');
    this.waiting();
    
    console.log('getting input form from ' + this.url());
    this.formholder.load(this.url());
  },
  
  // onSuccess trigger in formholder.load calls prepForm()

  prepForm: function () {
    console.log('prepform')
    this.notWaiting();
    this.form = this.formholder.getElement('form');
    intf.makeSuggester(this.form.getElements('input.tagbox'));
		this.form.onsubmit = this.sendForm.bind(this);
    var closer = this.hide.bind(this);
    this.form.getElements('a.cancelform').each(function (a) { a.onclick = closer })
    this.form.getElement('input').focus();
  },
  
  sendForm: function (e) {
    var event = new Event(e).stop();
    event.preventDefault();
    var mf = this;
    var req = new Request.JSON({
      url: this.form.get('action'),
      onRequest: function () { mf.page_waiting(); },
      onSuccess: function (response) { mf.page_update(response); },
      onFailure: function (response) { mf.hide(); intf.complain('remote call failed')}
    }).post(this.form);
  },
  page_waiting: function () { this.waiting(); },
  page_update: function (response) {
    // response should be the JSON representation of a spoke object
    console.log('page_update');
    console.log(response);
    this.hide();
    var sel = this.destination();
    var opt = new Element('option', {'value': response.id, 'selected': 'selected'}).set('text',response.name);
    opt.inject( sel, 'top' );
    intf.announce('new item created');
  },
  
  // really ought to do something constructive here
  failed: function () {
    this.hide();
    intf.complain("oh no.");
  },
  
  // just in case it's needed
  destroy: function () {
    this.floater.remove();
    this.overlay.remove();
  },
  
  waiting: function () {
    console.log('waiting');
    this.formholder.hide();
    this.spinner.show();
  },

  notWaiting: function () {
    console.log('notWaiting');
    this.spinner.hide();
    this.formholder.show();
  }
	
});

var Snipper = new Class ({
	Extends: ModalForm,
	
  destination: function () { return $E('ul#nodelist'); },
  responseholdertype: function () { return 'ul'; },

  prepForm: function () {
    console.log('filling in forms');
    this.notWaiting();
    this.form = this.formholder.getElement('form');
    var closer = this.hide.bind(this);
    this.form.getElements('a.cancelform').each(function (a) { a.onclick = closer })
    intf.makeSuggester(this.form.getElements('input.tagbox'));
    this.form.getElement('#node_body').set('value', intf.getSelectedText());
    this.form.getElements('#node_playfrom').each( function (input) { input.set('value', intf.getPlayerIn()); });
    this.form.getElements('#node_playto').each( function (input) { input.set('value', intf.getPlayerOut()); });
    this.form.getElement('.titular').focus();
		this.form.onsubmit = this.sendForm.bind(this);
  },
  
  sendForm: function (e) {
    var event = new Event(e).stop();
    event.preventDefault();
    
    var mf = this;
    var req = new Request.HTML({
      url: this.form.get('action'),
      update: this.responseholder,
      onRequest: function () { mf.page_waiting(); },
      onSuccess: function (response) { 
        mf.page_update(response); 
      }
    }).post(this.form);
  },
  
  // this is called when the form is submitted
  // we disappear the form and stick a waiter in the node list
  page_waiting: function (argument) {
    console.log('page_waiting. this is');
    console.log(this);
    this.waiting();
    var nodelist = this.destination();
    console.log(nodelist)
    this.waiter = new Element('li', {'class': 'waiting'}).setText('please wait').inject(nodelist, 'top');
    if (intf.tabsets['content']) intf.tabsets['content'].select('nodes');
    new Fx.Scroll(window).toTop();
    this.hide();
  },
  
  // this is called upon final response to the form
  // we remove the waiter, insert into the node list and make the new insertion draggable
  page_update: function () {
    var fragments = this.responseholder.getChildren();    
    var li = fragments[0];
    this.waiter.remove();
    li.inject(this.destination(), 'top');
    intf.activateElement( li );
    intf.announce('fragment created');
  }
});

var intf = null;

window.addEvent('domready', function(){
  intf = new Interface();
  // console.profile()
  intf.activate();
  intf.getPreferences();
  // console.profileEnd()
});

var Interface = new Class({
	initialize: function(){
    this.tips = null;
    this.draggables = [];
    this.droppers = [];
    this.tagboxes = [];
    this.tabs = [];
    this.tabsets = {};
    this.preferences = {};
    this.fixedbottom = [];
    this.inlinelinks = [];
    this.replyform = null;
    this.debug_level = 0;
    this.clickthreshold = 20;
    this.announcer = $E('div#notification');
    this.admin = $E('div#admin');
    this.squeezebox = null;
    this.draghelper = null;
    this.fader = new Fx.Tween(this.announcer, 'opacity', {duration: 'long', link: 'chain'});
	},
  announce: function (message, title) {
    this.announcer.removeClass('error');
    this.announcer.set('html', message);
    this.fader.start(1);
    this.fader.start(0);
  },
  complain: function (message, title) {
    this.announcer.addClass('error');
    this.announcer.set('html', message);
    this.fader.start(1);
    this.fader.start(0);
  },
  flash: function (element, color) {
    element.highlight(color);
  },
  moveFixed: function (e) {
    this.fixedbottom.each(function (element) { element.toBottom(); });
  },
  hideTips: function () {
    if (this.tips) this.tips.hide();
  },
  startDragging: function (helper) {
    var catchers = [];
  	if (this.preferences.tabs_responsive) this.tabs.each(function (t) { t.makeReceptiveTo(helper); });
  	this.droppers.each(function(d){ if (d.makeReceptiveTo(helper)) catchers.push(d.container); });
  	intf.debug('catchers will be: ', 3);
  	intf.debug(catchers, 3);
  	return catchers;
  },
  stopDragging: function (helper) {
  	intf.debug('stopdragging: ', 2);
    this.tabs.each(function (t) { t.makeUnreceptive(helper); });
    this.droppers.each(function (d) { d.makeUnreceptive(helper); });
    $$('.hideondrag').each(function (element) { element.setStyle('visibility', 'visible'); });
    $$('.showondrag').each(function (element) { element.setStyle('visibility', 'hidden'); });
  },
  removeHelper: function () {
    if (this.draghelper) {
      this.draghelper.remove();
      delete this.draghelper;
    }
    this.draghelper = null;
  },
  lookForDropper: function (element) {
    if (element) return element.dropzone || this.lookForDropper( element.getParent() );
    else return null;
  },
  lookForTab: function (element) {
    if (element) return element.tab || this.lookForTab( element.getParent() );
    else return null;
  },
  lookForSqueeze: function (element) {
    if (element) return element.squeezed ? element : this.lookForSqueeze( element.getParent() );
    else return null;
  },
  
  // these are convenient shortcuts called by activate()
  
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
  makePreference: function (elements) {
    elements.each(function (element) { intf.inlinelinks.push(new Preference(element)); });
  },
  makeSuggester: function (elements) {
    elements.each(function (element) {
      var waiter = new Element('div', {'class': 'autocompleter-loading'}).setHTML('&nbsp;').inject(element, 'after');
      intf.tagboxes.push(new Autocompleter.Ajax.Json(element, '/tags/matching', { 'indicator': waiter, 'postVar': 'stem', 'multiple': true }));
    });
  },

  grabForm: function (elements) { elements.each(function (element) { element.addEvent('click', function (e) { new htmlForm(element, e); }); }); },
  makeInlineCreate: function (elements) { elements.each(function (element) { element.addEvent('click', function (e) { new jsonForm(element, e); }); }); },
  makeSnipper: function (elements) { elements.each(function (element) { element.addEvent('click', function (e) { new Snipper(element, e); }); }); },
  makePopup: function (elements) { elements.each(function (element) { element.addEvent('click', function (e) { new Popup(element, e); }); }); },
  makeSquash: function (handles, blocks) { this.squeezebox = new Squeezebox(handles, blocks); },
  
  // there will only be one of these really

  makeReplyForm: function (elements) {
    elements.each(function (element) { 
      this.replyform = new ReplyForm(element); 
    }, this);
  },
  
  makeFixed: function (elements) { elements.each(function (element) { element.pin(); }); },

  makeCollectionsLinks: function (elements) {
    elements.each(function (a) {
      a.onclick = function (e) { 
        event = new Event(e).preventDefault();
        event.target.blur();
        intf.tabsets['scratchpad'].select('collections');
      }
    });
  },
  
  getPreferences: function () {
		var req = new Request.JSON({
		  url: "/user_preferences",
			method: 'get',
      onSuccess: function(response) { 
        intf.preferences = response;
        intf.debug("preferences object retrieved", 2);
        intf.enactPreferences();
      },
		  onFailure: function (response) { 
		    intf.complain("preferences call failed");
		  }
		}).send();
  },
  
  enactPreferences: function (argument) {
    this.debug('enacting preferences', 2);
    if (this.preferences.pads_condensed) {
      $$('div.scratchpage div.tiptext').hide();
    } else {
      $$('div.scratchpage div.tiptext').show();
    }
    if (this.preferences.lists_condensed) {
      $$('div.mainlist div.tiptext').hide();
    } else {
      $$('div.mainlist div.tiptext').show();
    }
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
    this.makePreference(scope.getElements('a.preference'));
    this.makeSuggester(scope.getElements('input.tagbox'));
    this.makeInlineCreate(scope.getElements('a.inlinecreate'));
    this.grabForm(scope.getElements('a.inlinediscuss'));
    this.makeSnipper(scope.getElements('a.snipper'));
    this.makeReplyForm(scope.getElements('form#new_post'));
    this.makeFixed(scope.getElements('.fixed'));
    this.makePopup(scope.getElements('.popup'));
    this.makeCollectionsLinks(scope.getElements('a.choosecollections'));
    this.makeSquash(scope.getElements('a.squeezebox'), scope.getElements('div.squeezed'));
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
    if (element.hasClass('toggle')) this.makeToggle( [element] );
    if (element.hasClass('snipper')) this.makeSnipper( [element] );
    if (element.hasClass('popup')) this.makePopup( [element] );
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
  }, 
  
  debug: function (message, level) {
    if (!level) level = 2;
    if (console && this.debug_level >= level) console.log(message);
  }
  	
});

var SpokeTips = new Class({
  Extends: Tips,
  options: {
    onShow: function(tip) { if (!intf.dragging) tip.fade(0.8); },
    onHide: function(tip) { tip.fade('out'); }
  },
  build: function(el){
    el.$attributes.myTitle = el.title || el.getElement('a').title;
    el.$attributes.myText = el.getElement('div.tiptext').getText();
		el.removeProperty('title');
		if (el.$attributes.myTitle && el.$attributes.myTitle.length > this.options.maxTitleChars)
			el.$attributes.myTitle = el.$attributes.myTitle.substr(0, this.options.maxTitleChars - 1) + "&hellip;";
		el.addEvent('mouseenter', function(event){
		  if (intf.preferences.tooltips) {
  			this.start(el);
  			if (!this.options.fixed) this.locate(event);
  			else this.position(el);
		  }
		}.bind(this));
		if (!this.options.fixed) el.addEvent('mousemove', this.locate.bind(this));
		var end = this.end.bind(this);
		el.addEvent('mouseleave', end);
 }
});

var Dropzone = new Class({
	initialize: function (element) {
    intf.debug('new dropzone: ' + element.id, 3);
		this.container = element;
	  this.tag = element.id;
	  this.name = element.getProperty('title') || element.getElement('a').get('text');
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
	contents: function () { return this.container.getElements('.draggable').map(function(el){ return el.spokeTag(); }); },
	contains: function (draggee) { 
	  intf.debug('looking for ' + draggee.tag + ' in ', 5);
	  intf.debug(this.contents(), 5);
	  return this.contents().contains(draggee.tag); 
	},
	can_catch: function (type) { if (this.catches) return this.catches == 'all' || this.catches.split(',').contains(type); },
  
  // makeReceptiveTo gets called on drag start to decide whether we're interested and if so prepare us to receive a drop
  // we do as many tests as possible here to make the mouseover events lighter

  makeReceptiveTo: function (helper) {
    if (this.can_catch(helper.draggee.spokeType()) && this.container != helper.draggee.original && this != helper.draggee.draggedfrom && !this.contains(helper.draggee)) {
      intf.debug('receptive: ' + this.name, 5);
      var dropzone = this;
      this.container.addEvents({
        'drop': function() { 
          intf.debug('hit drop event: ' + dropzone.name, 4);
          dropzone.receiveDrop(helper); 
        },
        'mouseover': function() { dropzone.showInterest(helper); },   // don't use mouseenter in case dragged item occludes dropzone
        'mouseout': function() { dropzone.loseInterest(helper); }
      });
      return this.isReceptive = true;
      
    } else {
      return this.isReceptive = false;
    }
  },
  
  makeUnreceptive: function (helper) {
    // this gets called when a drag from elsewhere leaves this space or a drag ends
    if (this.isReceptive) {
      intf.debug('unReceptive: ' + this.name, 5);
      this.container.removeEvents('mouseenter');
      this.container.removeEvents('mouseleave');
      this.container.removeEvents('mouseover');
      this.container.removeEvents('mouseout');
      this.container.removeEvents('drop');
      this.isReceptive = false;
    }
  },
  makeRegretful: function (helper) {
    // this gets called when we drag something out of this space that began here
    intf.debug('regretful: ' + this.name, 4);
    var dropzone = this;
    dropzone.container.addEvents({
      mouseenter: function() {
        intf.debug('returning to origin space', 3);
        helper.clearState();
        dropzone.container.removeClass('bereft');
      },
      mouseleave: function() {
        intf.debug('leaving origin space', 3);
        dropzone.container.addClass('bereft');
      }
    });
    this.isRegretful = true;
  },
  makeUnregretful: function () {
    if (this.isRegretful) {
      intf.debug('unRegretful: ' + this.name, 4);
      this.container.removeEvents('mouseover');
      this.container.removeEvents('mouseout');
      this.container.removeEvents('mouseenter');
      this.container.removeEvents('mouseleave');
      this.container.removeEvents('drop');
      this.isRegretful = false;
    }
  },
  showInterest: function (helper) {
    intf.debug('interested: ' + this.name, 5);
    this.container.addClass('drophere');
    if (this.tab) this.tab.tabhead.addClass('over');
  },
  loseInterest: function (helper) {
    intf.debug('uninterested: ' + this.name, 4);
    this.container.removeClass('drophere');
    if(this.tab) this.tab.tabhead.removeClass('over');
  },
	        
	receiveDrop: function (helper) {
    intf.debug('receiveDrop: ' + this.name, 3);
	  intf.stopDragging();
		var dropzone = this;
		var draggee = helper.draggee;
		dropzone.loseInterest(helper);
    intf.debug(dropzone.name + ' catching ' + draggee.name, 2);

		if (dropzone == draggee.draggedfrom) {
			helper.flyback();
			
		} else if (dropzone.contains(draggee)) {
			intf.complain(draggee.name + ' is already in' + dropzone.name);
			helper.flyback();
			
		} else {
      intf.removeHelper();
			if (intf.preferences.confirmation == false || confirm('are you sure you wanted to drop that there?')) {
        
  			var req = new Request.JSON( {
  			  url: this.addURL(draggee),
  				method: 'get',
  			  onRequest: function () { 
  			    dropzone.waiting();
  			    draggee.waiting();
  			  },
          onSuccess: function(response){
            intf.debug('drop successful: ', 3);
            intf.debug('outcome = ' + response.outcome + ', message = ' + response.message + ', consequence = ' + response.consequence, 4);
            dropzone.notWaiting();
            draggee.notWaiting();
            if (response.outcome == 'success') {
              switch (response.consequence) {
              case "move": 
                dropzone.accept(draggee);
                draggee.disappear();
                break; 
              case "delete":
                draggee.disappear();
                break;
              default:
                dropzone.accept(draggee);
              }
              intf.announce(response.message);
            } else {
              intf.complain(response.message);
            }
          },
  			  onFailure: function (response) { 
            intf.debug('drop failed!', 2);
            intf.debug('outcome = ' + response.outcome + ', message = ' + response.message + ', consequence = ' + response.consequence, 4);
  			    dropzone.notWaiting(); 
  			    draggee.notWaiting(); 
  			    intf.complain('remote call failed');
  			  }
  			}).send();
			}
		}
  },
	removeDrop: function (helper) {
    intf.debug('removeDrop: ' + this.name, 3);
	  intf.stopDragging();
		var dropzone = this;
    var draggee = helper.draggee;
    intf.removeHelper();
	  
		var req = new Request.JSON( {
		  url: this.removeURL(draggee),
			method: 'delete',
		  onRequest: function () { draggee.waiting(); },
		  onSuccess: function (response) { 
        if (response.outcome == 'success') {
          intf.debug('drop successful: ', 3);
          intf.debug('outcome = ' + response.outcome + ', message = ' + response.message + ', consequence = ' + response.consequence, 4);
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
      var element = draggee.clone().inject(this.container, 'inside');
      element.set('id', this.tag + '_' + draggee.tag);
      intf.activateElement(element);
    }
	}
});

var TrashDropzone = new Class({
  Extends: Dropzone,
	addURL: function (draggee) { return draggee.spokeType() +'s/trash/' + draggee.spokeID(); },
	can_catch: function (type) { return true; }
});

var Draggee = new Class({
	initialize: function(element, e) {
	  event = new Event(e).stop();
	  event.preventDefault();
		this.original = element;
		this.tag = element.spokeTag();
		this.link = element.getElements('a')[0];
		this.name = this.findTitle();
    this.draggedfrom = intf.lookForDropper(element.getParent());
    intf.draghelper = new DragHelper(this);
	},
  spokeID: function () { return this.original.spokeID(); },
  spokeType: function () { return this.original.spokeType(); },
	doClick: function (e) { 
	  var event = new Event(e).stop();
    intf.removeHelper();
	  this.link.fireEvent('click'); 
	},
	waiting: function () { this.original.addClass('waiting'); },
	notWaiting: function () { this.original.removeClass('waiting'); },
	remove: function () { this.original.remove(); },
	explode: function () { this.original.explode(); },
	disappear: function () { this.original.dwindle(); },
	clone: function () { return this.original.clone(); },
	findTitle: function () { return this.link.getText() || this.original.getElements('div.tiptitle').getText(); }
});

// the dragged representation is a new DragHelper object with useful abilities
// and a tooltip-like label

var DragHelper = new Class({
	initialize: function(draggee){
	  this.draggee = draggee;
		this.original = this.draggee.original;
		this.name = this.draggee.name;
    this.active = false;
    
    this.dragger = new Element('ul', {'class': 'dragging'});
    this.original.clone().inject(this.dragger);
    this.dragger.inject(document.body, 'inside');
    this.dragger.setStyles(this.original.getCoordinates());
    
	  var dh = this;
	  this.dragger.addEvent('emptydrop', function() { dh.emptydrop(); });	
    this.dragmove = this.dragger.makeDraggable({ 
      droppables: intf.startDragging(this),
      snap: intf.clickthreshold,
      onSnap: function (element) { dh.reveal(); }
    });
		this.dragmove.start(event);
	},
	reveal: function () {
    $$('.hideondrag').each(function (element) { element.setStyle('visibility', 'hidden'); });
    $$('.showondrag').each(function (element) { element.setStyle('visibility', 'visible'); });
		this.dragger.setStyle('visibility', 'visible');
    this.active = true;
	},
	emptydrop: function () {
		intf.stopDragging();
		if (!this.active) {
		  this.draggee.doClick();
    } else if (this.draggee.draggedfrom) {
      this.draggedOut();
		} else {
		  this.flyback();
		}
	},
	draggedOut: function () {
    if (this.draggee.draggedfrom) this.draggee.draggedfrom.removeDrop(this);
	},
	flyback: function () {
		new Fx.Morph(this.dragger, {
		  duration: 'long', 
		  transition: 'bounce:out',
		  onComplete: function () { intf.removeHelper(); }
		}).start( $merge(this.original.getCoordinates(), {'opacity': 0.2}) );
	},
  show: function (event) { this.dragger.show(); },
  hide: function () { this.dragger.fade('out'); },
	remove: function () { 
	  this.hide();
	  this.dragger.removeEvents('emptydrop');
	  this.dragger.destroy();
	},
	explode: function () { this.remove(); }
});




var Tab = new Class({
	initialize: function(element){
		this.tabhead = element;
		this.name = this.tabhead.get('text');
	  intf.debug("tab: " + this.name, 4);
    var parts = element.id.split('_');
		this.tag = parts.pop();
		this.settag = parts.pop();
		this.tabbody = $E('#' + this.settag + '_' + this.tag);
		this.tabbody.tab = this;
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
	}
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
  		  onSuccess: function () { stab.bindForm(); },
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
		  'scratchpad[body]': this.padform.getElement('#scratchpad_body').get('value')
		};

		new Request.JSON({
		  url: this.padform.get('action'),
			method: 'post',
			data: update,
		  onSuccess: function (response) {
        stab.hideFormNicely();
        stab.tabhead.set('text', response.name);
        stab.tabhead.set('title', response.body);
        intf.debug(response, 3);
        if (response.updated_by == null) {
          var tabs = stab.tabset;
          tabs.removeTab(stab);
          stab.tabhead.set('id', 'tab_scratchpad_' + response.id);
      		new Request.HTML({
      		  url: '/scratchpads/' + response.id,
      			method: 'get',
      			update: stab.tabbody,
      		  onSuccess: function (request) { 
      		    var st = intf.addScratchTabs([stab.tabhead]);
      		    intf.addDropzones(stab.tabbody.getElements('.catcher'));
      		  },
      		  onFailure: function () { intf.complain('no way'); }
      		}).send();
          
        }
      },
		  onFailure: function (response) { stab.hideForm(); intf.complain('remote call failed'); }
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
	  this.container = $E('#scratchpad');
	  this.tabscontainer = $E('#scratchpad_tabs');
	  this.pagescontainer = $E('#scratchpad_pages');
		this.isopen = false;
		this.openFX = new Fx.Tween(this.container, 'width', {duration: 400, transition: Fx.Transitions.Cubic.easeOut});
		this.closeFX = new Fx.Tween(this.container, 'width', {duration: 1000, transition: Fx.Transitions.Cubic.easeOut});
	},
  postselect: function () {
    if (!this.isopen) this.open();
  },
  open: function () {
    this.openFX.start( 560 );
    this.isopen = true;
	},
	close: function (delay) {
    this.closeFX.start( 130 ); 
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
    }).setText('new scratchpad').injectInside(this.tabscontainer);
    var newbody = new Element('div', {
      'id': 'scratchpad_new',
      'class': 'scratchpage'
    }).injectInside(this.pagescontainer);
    this.newtab = new ScratchTab(newhead);
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

var Preference = new Class({
  Extends: Toggle,
  finished: function (response) {
    arguments.callee.parent(response);
    var abbr = this.link.id.replace('prefs_', '');
    intf.preferences[abbr] = response.outcome == 'active';
    intf.debug('set preference ' + abbr + ' to ' + intf.preferences[abbr], 1);
    intf.enactPreferences();
  }
});

var jsonForm = new Class ({
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
		this.formholder = new Element('div', {'class': 'modalform'}).inject(this.floater).hide();
		this.destination = $E('#' + this.link.id.replace('extend_', ''));
		this.destination_type = this.destination.tagName;
		this.squeeze = intf.lookForSqueeze( this.destination );
		this.overlay.onclick = this.hide.bind(this);
    this.formholder.set('load', {
      onRequest: function () { mf.waiting(); },
      onSuccess: function () { mf.prepForm(); },
      onFailure: function () { mf.failed(); }
    });
    this.show();
  },
  
  url: function () { return this.link.getProperty('href'); },
 
  show: function () {
    this.position();
    this.getForm();
		this.setup(true);
    // this.top = window.getScrollTop() + (window.getHeight() / 15);
    // this.floater.setStyles({top: this.top, display: ''});
		this.overlay.fade(0.6);
    this.floater.show();
  },

  hide: function (e) {
    event = new Event(e);
    event.preventDefault();
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
		  'left': window.getScrollLeft() + Math.floor((window.getWidth() - dimensions.width) / 2) 
		});
		this.overlay.setStyles({
		  'top': window.getScrollTop(), 
		  'height': window.getHeight()
		});
	},
	
  getForm: function () {
    this.canceller().inject(this.floater, 'top');
    this.waiting();
    this.formholder.load(this.url());
  },
  
  // onSuccess trigger in formholder.load calls prepForm()

  prepForm: function () {
    this.notWaiting();
    this.position();
    this.form = this.formholder.getElement('form');
    intf.makeSuggester(this.form.getElements('input.tagbox'));
    var closer = this.hide.bind(this);
		this.form.onsubmit = this.sendForm.bind(this);
    this.form.getElements('a.cancelform').each(function (a) { a.onclick = closer; });
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
      onFailure: function (response) { mf.hide(); intf.complain('remote call failed'); }
    }).post(this.form);
  },
  
  page_waiting: function () { this.waiting(); },
  
  page_update: function (response) {
    // default is that we expect to add an option to a select box
    // response should be the JSON representation of a materialist object
    this.hide();
    var newitem = new Element('option', {'value': response.id}).set('text',response.name);
    newitem.inject( this.destination, 'top' );
    intf.announce('new item created');
    this.showOnPage();
  },
  
  // really ought to do something constructive here
  // like show the form again with error messages. genius.
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
    intf.debug('jsonForm.waiting', 5);
    this.formholder.hide();
    this.spinner.show();
  },

  notWaiting: function () {
    intf.debug('jsonForm.notWaiting', 5);
    this.spinner.hide();
    this.formholder.show();
  },

  showOnPage: function () {
    if (this.squeeze) intf.squeezebox.display(this.squeeze);
    if (this.destination_type == 'UL') this.destination.selectedIndex = 0;
    new Fx.Scroll(window).toElement(this.destination);
  }
	
});

// htmlForm inherits from modalform but expects to get html back at the end of the process: 
// usually a list item but could be anything.

var htmlForm = new Class ({
	Extends: jsonForm,
	  
  sendForm: function (e) {
    var event = new Event(e).stop();
    event.preventDefault();
    this.responseholder = new Element(this.destination.get('tag'));
    var mf = this;
    var req = new Request.HTML({
      url: this.form.get('action'),
      update: this.responseholder,
      onRequest: function () { mf.page_waiting(); },
      onSuccess: function (response) { mf.page_update(response); }
    }).post(this.form);
  },

  // this is called when the form is submitted
  // we disappear the form, stick a waiter in the destination list
  // make the list visible and scroll to it
  page_waiting: function (argument) {
    this.waiting();
    this.waiter = new Element('li', {'class': 'waiting'}).setText('please wait').inject(this.destination, 'top');
    this.hide();
    this.showOnPage();
  },
  
  // this is called upon final response to the form
  // we remove the waiter, insert into the node list and make the new insertion draggable
  page_update: function () {
    this.waiter.remove();
    var elements = this.responseholder.getChildren();    
    var newitem = elements[0];
    newitem.inject(this.destination, 'top');
    intf.activateElement( newitem );
  },
  
  showOnPage: function () {
    
    new Fx.Scroll(window).toElement(this.destination);
  }
});

// snipper is a special case of htmlForm that does more work to populate the form

var Snipper = new Class ({
	Extends: htmlForm,
	
  prepForm: function () {
    this.notWaiting();
    this.position();
    this.form = this.formholder.getElement('form');
    var closer = this.hide.bind(this);
    this.form.getElements('a.cancelform').each(function (a) { a.onclick = closer; } );
    intf.makeSuggester(this.form.getElements('input.tagbox'));
    this.form.getElement('#node_body').set('value', intf.getSelectedText());
    this.form.getElements('#node_playfrom').each( function (input) { input.set('value', intf.getPlayerIn()); });
    this.form.getElements('#node_playto').each( function (input) { input.set('value', intf.getPlayerOut()); });
    this.form.getElement('.titular').focus();
		this.form.onsubmit = this.sendForm.bind(this);
  }
  
});

// popup is a simple case of htmlForm that doesn't expect any form submission and appears just over the triggering link

var Popup = new Class ({
	Extends: htmlForm,
	
  initialize: function (element, e) {
    event = new Event(e);
    event.preventDefault();
    var popup = this;
    element.blur();
		this.link = element;
		this.at = event.client;
		this.overlay = new Element('div', {'class': 'overlay'}).inject(document.body);
		this.floater = new Element('div', {'class': 'floater popup'}).inject(document.body);
		this.spinner = new Element('div', {'class': 'floatspinner'}).set('html', '&nbsp;').inject(this.floater).show();
		this.formholder = new Element('div', {'class': 'popupform'}).inject(this.floater).hide();
		this.overlay.onclick = this.hide.bind(this);
    this.formholder.set('load', {
      onRequest: function () { popup.waiting(); },
      onSuccess: function () { popup.prepForm(); },
      onFailure: function () { popup.failed(); }
    });
    this.show();
  },

  show: function () {
    this.position();
    this.getForm();
		this.setup(true);
		this.overlay.fade(0.6);
    this.floater.show();
  },

	position: function(){
		this.floater.setStyles({
		  'top': this.at.y, 
		  'left': this.at.x
		});
	},
	
  prepForm: function () {
    this.notWaiting();
    this.position();
    intf.activate(this.formholder);
  }
});



// separate inline form mechanism for discussion replies
// and anything else that previews iteratively before 
// returning html
// unlike most interface elements this is initialized on load, not on click
// but there will only be one on the page

var ReplyForm = new Class ({
  initialize: function (element) {
    this.form = element;
    this.wrapper = element.getParent();
    this.previewform = null;
    this.messagebox = this.form.getElement('textarea');
		this.responseholder = new Element('div', {'class': 'previewform'}).inject(this.form, 'after').hide();
		this.form.onsubmit = this.sendForm.bind(this);
		$$('a.quoteme').each( function (a) {
		  a.onclick = this.quote.bind(this);
		}, this);  
  },
  
  quote: function (e) {
    event = new Event(e).stop();
    event.preventDefault();
		var source = $E('#' + event.target.id.replace('quote_', ''));
    if (source) {
  		var quote = "bq. " + source.getText().replace(/[\r\n]+\s*/g, "")  + "\n\n";
      this.messagebox.set('value', quote);
      new Fx.Scroll(window).toElement(this.messagebox);
      this.messagebox.focus();
    }
  },
  
  sendForm: function (e) {
    event = new Event(e).stop();
    event.preventDefault();
    var rf = this;
    var req = new Request.HTML({
      url: this.form.get('action'),
      update: this.responseholder,
      onRequest: function () { rf.waiting(); },
      onSuccess: function (response) { rf.processResponse(response); }
    }).get(this.form);    // get because this is really the new action. the preview form points to the create action.
  },

  // if the returned html contains a form, we'll assume that further confirmation is required
  // if not, we assume job is done, display it and call finish.
  
  processResponse: function () {
		this.notWaiting();
    if (this.responseholder.getElement('.preview')) {
      this.previewform = this.responseholder.getElement('form');
      this.wrapper.addClass('previewing');
      this.previewform.onsubmit = this.confirm.bind(this);
      this.responseholder.getElement('a.revise').onclick = this.revise.bind(this);
      this.form.hide();
      this.responseholder.show();
    } else {
      this.form.hide();
      this.responseholder.show();
      this.finished();
    }
  },
	
	confirm: function (e) {
    event = new Event(e).stop();
    event.preventDefault();
    this.wrapper.removeClass('previewing');
    var rf = this;
    var req = new Request.HTML({
      url: this.previewform.get('action'),
      update: this.responseholder,
      onRequest: function () { rf.waiting(); },
      onSuccess: function (response) { rf.processResponse(response); }
    }).post(this.previewform);
	},

	revise: function (e) {
    event = new Event(e).stop();
    event.preventDefault();
    this.wrapper.removeClass('previewing');
    this.responseholder.hide();
    this.form.show();
	},

  waiting: function () {
    this.wrapper.getElements('div.waitme').each(function (element) {
      element.addClass('waiting');
    });
  },
  
  notWaiting: function () {
    this.wrapper.getElements('div.waitme').each(function (element) {
      element.removeClass('waiting');
    });
  },

	finished: function () {
    intf.flash(this.responseholder);
    this.form.remove();
    intf.makeReplyForm(this.responseholder.getElements('form#new_post'));
	}
	
});

var Squeezebox = new Class ({
  Extends: Accordion,
	options: {
		display: 0,
		show: false,
		height: true,
		width: false,
		opacity: true,
		fixedHeight: false,
		fixedWidth: false,
		wait: false,
		alwaysHide: true,
    onActive: function (toggler, element) {
      toggler.addClass('expanded');
      toggler.removeClass('squeezed');
    },
    onBackground: function (toggler, element) {
      toggler.blur();
      toggler.removeClass('expanded');
      toggler.addClass('squeezed');
    }
	},
	initialize: function (togglers, elements) {
    arguments.callee.parent(togglers, elements);
    elements.each(function (element) { element.squeezed = true; });
	}
});






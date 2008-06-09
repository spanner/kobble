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
    this.floaters = [];
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

	rememberFloater: function (floater) {
		this.floaters.push(floater);
	},
	clearFloaters: function () {
		this.floaters.each(function (floater) { 
			floater.hide(); 
			delete floater;
		});
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

  makeInlineCreate: function (elements) { elements.each(function (element) { element.addEvent('click', function (e) { new jsonForm(element, e); }); }); },
  makeInlineDiscuss: function (elements) { elements.each(function (element) { element.addEvent('click', function (e) { new htmlForm(element, e); }); }); },
  makeInlineReply: function (elements) { elements.each(function (element) { element.addEvent('click', function (e) { new htmlForm(element, e); }); }); },
  makeNoter: function (elements) { elements.each(function (element) { element.addEvent('click', function (e) { new htmlForm(element, e); }); }); },
  makeSnipper: function (elements) { elements.each(function (element) { element.addEvent('click', function (e) { new Snipper(element, e); }); }); },
  makePopup: function (elements) { elements.each(function (element) { element.addEvent('click', function (e) { new Popup(element, e); }); }); },

  makeSquash: function (handles, blocks) { 
	 	if (this.squeezebox) this.squeezebox.addSections(handles,blocks);
		else this.squeezebox = new Squeezebox(handles, blocks);
	},
    
  makeFixed: function (elements) { elements.each(function (element) { element.pin(); }); },

  makeCollectionsLinks: function (elements) {
    elements.each(function (a) {
      a.onclick = function (e) { 
        event = intf.blocked_event(e);
        if (event) event.target.blur();
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
    this.makeInlineDiscuss(scope.getElements('a.inlinediscuss'));
    this.makeInlineReply(scope.getElements('a.inlinereply'));
    this.makeSnipper(scope.getElements('a.snipper'));
    this.makeNoter(scope.getElements('a.annotate'));
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
    if (element.hasClass('noter')) this.makeNoter( [element] );
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

  quoteSelectedText: function () {
  	var txt = this.getSelectedText();
		if (txt) {
			txt.replace(/[\n\r]+/g, " ");
			return "bq. " + txt + "\n\n";
		} else {
			return '';
		}
  },
  
  getPlayerIn: function () {
    var player = document.spannerplayer;
    if (player && player.playerOk() ) return player.playerIn();
  },
  
  getPlayerOut: function () {
    var player = document.spannerplayer;
    if (player && player.playerOk() ) return player.playerOut();
  },

	blocked_event: function (e) {
		if (e) {
			var event = new Event(e);
			event.preventDefault();
			return event;
		}
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
	  var event = intf.blocked_event(e);
		this.original = element;
		this.tag = element.spokeTag();
		this.link = element.getElements('a')[0];
		this.name = this.findTitle();
    this.draggedfrom = intf.lookForDropper(element.getParent());
    intf.draghelper = new DragHelper(this, event);
	},
  spokeID: function () { return this.original.spokeID(); },
  spokeType: function () { return this.original.spokeType(); },
	doClick: function (e) { 
	  var event = intf.blocked_event(e);
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
	initialize: function(draggee, event){
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
		intf.blocked_event(e);
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
    this.formHolder = new Element('div', {'class': 'padform bigspinner'}).inject(this.tabbody, 'top').set('html', '&nbsp;').hide();
    this.showformfx = new Fx.Tween(this.formHolder, 'width', {duration: 'long', transition: 'cubic:out'});
    this.hideformfx = new Fx.Tween(this.formHolder, 'width', {duration: 'medium', transition: 'cubic:out', onComplete: function () { stab.hideForm(); }});
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
	  var event = intf.blocked_event(e);
    this.showForm(event.target.getProperty('href'));
  },
  showForm: function (url) {
    if (!url) url = '/scratchpads/new';
    this.tabhead.addClass('editing');
    this.formHolder.show();
    if (! this.padform) {
  	  this.showformfx.start(440);
  	  var stab = this;
  		new Request.HTML({
  		  url: url,
  			method: 'get',
  			update: stab.formHolder,
  		  onSuccess: function () { stab.bindForm(); },
  		  onFailure: function () { stab.hideFormNicely(); }
  		}).send();
    }
	},
	hideFormNicely: function (e) {
    intf.blocked_event(e);
    this.hideForm();
    //     var stab = this;
    // this.hideformfx.start(0);
	},
	hideForm: function (e) {
    intf.blocked_event(e);
    this.formHolder.hide();
    this.tabhead.removeClass('editing');
	},
	bindForm: function () {
		var stab = this;
    this.formHolder.removeClass('bigspinner');
    this.padform = this.formHolder.getElement('form');
		this.padform.onsubmit = this.doForm.bind(this);
		this.padform.getElements('a.cancel_form').each(function (a) { a.onclick = stab.hideFormNicely.bind(stab); });
		this.padform.getElements('a.remove_tab').each(function (a) { a.onclick = stab.erase.bind(stab); });
		this.padform.getElement('input.titular').focus();
	},
	doForm: function (e) {
	  var event = intf.blocked_event(e);
	  var stab = this;
    this.padform.hide();
    this.formHolder.addClass('bigspinner');
        
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
	  var event = intf.blocked_event(e);
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
    this.newtab.select(event);
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
    var event = intf.blocked_event(e);
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
		var event = intf.blocked_event(e);
    event.target.blur();
		intf.clearFloaters();
		this.link = element;
		intf.debug('jsonForm.initialize', 5);
		this.form = null;
		this.is_open = false;
		this.at = event.page;
    this.waiter = null;
		this.form = null;
		this.floater = new Element('div', {'class': 'floater'}).inject(document.body);
		this.formHolder = new Element('div', {'class': 'modalform'}).inject(this.floater);
		this.formWaiter = new Element('div', {'class': 'floatspinner'}).inject(this.formHolder);
		this.destination = $E('#' + this.link.id.replace(/[\w_]*extend_/, ''));
		this.destination_type = this.destination.get('tag');
		this.created_item = null;
		this.destination_squeeze = intf.lookForSqueeze( this.destination );			// this is going to be a memory leak in IE when we get there
    var mf = this;
		this.openfx = new Fx.Morph(this.floater, {
			duration: 'long', 
			transition: Fx.Transitions.Back.easeOut,
			link: 'cancel'
		});
		this.closefx = new Fx.Morph(this.floater, {
			duration: 'normal', 
			transition: Fx.Transitions.Cubic.easeOut, 
			link: 'cancel',
			onComplete: function () { mf.floater.hide(); }
		});
    this.formHolder.set('load', {
      onRequest: function () { mf.linkWaiting(); },
      onSuccess: function () { mf.prepForm(); },
      onFailure: function () { mf.failed(); }
    });
		intf.rememberFloater(this);
		this.waiting();
		this.show();
    this.getForm();
  },

  // initialize calls getForm() directly
	// it's only separated to be overridable

  getForm: function () {
		intf.debug('jsonForm.getForm', 5);
    this.canceller().inject(this.floater, 'top');
    this.formHolder.load(this.url());
  },
  
  // onSuccess trigger in formHolder.load calls prepForm()
	// which locates and displays the form and activates any useful elements within it
	// may be called again by processResponse if response contains another form

  prepForm: function () {
		this.notWaiting();
		this.linkNotWaiting();
    this.form = this.formHolder.getElement('form');
		this.form.onsubmit = this.sendForm.bind(this);
    this.form.getElements('a.cancelform').each(function (a) { a.onclick = this.hide.bind(this); }, this);
    this.form.getElements('.fillWithSelection').each(function (input) { if (input.get('value') == '') input.set('value', intf.quoteSelectedText()); });
    intf.makeSuggester(this.form.getElements('input.tagbox'));

		// this.resize();

		var first = this.form.getElement('.pickme');
		if (first) first.focus();
		
		this.resize();
  },

  // captured form.onsubmit calls sendForm()
	// which initiates the JSON request and binds its outcomes
  
  sendForm: function (e) {
		intf.debug('jsonForm.sendForm', 5);
    var event = intf.blocked_event(e);
    var mf = this;
    var req = new Request.JSON({
      url: this.form.get('action'),
      onRequest: function () { mf.waiting(); },
      onSuccess: function (response) { mf.processResponse(response); },
      onFailure: function (response) { mf.hide(); intf.complain('remote call failed'); }
    }).post(this.form);
  },

	// sendform sets onSuccess to processResponse
	// processResponse looks for an error in the response
	// calls updatePage if none found
	// in subclasses this is usually a previewing or validation mechanism

	processResponse: function (response) {
		intf.debug('jsonForm.processResponse', 5);
		this.notWaiting();
		if (response.errors) {
			console.log(response.errors);
		} else {
			this.updatePage(response);
		}
	},
  
	// updatePage called by processResponse if no more user input is expected
	// and inserts response html into destination element
  // default is that we expect to add an option to a select box
  // created from the JSON representation of a materialist object
	// subclasses have other ideas mostly to do with extending lists

  updatePage: function (response) {
		intf.debug('jsonForm.updatePage', 5);
    this.created_item = new Element('option', {'value': response.id}).set('text',response.name);
    this.created_item.inject( this.destination, 'top' );
    this.hide(this.created_item);
    this.showOnPage();
  },

	// rest is just display control
  
  failed: function () {
    this.hide();
    intf.complain("oh no.");
  },
  
	show: function (origin) {
		intf.debug('jsonForm.show', 5);
		if (!origin) origin = this.link;
		this.expandFrom(origin);
		this.link.addClass('activated');
		this.is_open = true;
	},

	hide: function (e, destination) {
		intf.blocked_event(e);
		if (!destination) destination = this.link;
		this.shrinkTowards(destination);
		this.link.removeClass('activated');
		this.is_open = false;
	},
		
	resize: function (width, height) {
		var at = this.floater.getCoordinates();
		var towidth = width || 520;
		var toheight = height || this.formHolder.getHeight() + 10;
		var scroll = document.getScroll();
		var boundary = document.getSize();
		
		var toleft, totop;
		
		if (towidth < at.width) {
			toleft = at.left;
		} else {
			var cangoleft = at.left - towidth - scroll.x > 0;
			var cangoright = at.left + towidth + scroll.x < boundary.x;
			if (cangoleft == cangoright) toleft = Math.floor(at.left - towidth / 2);
			else if (cangoright) toleft = at.left;
			else toleft = at.left - at.width + towidth;
		}
		
		if (toheight < at.height) {
			totop = at.top;
		} else {
			var cangoup = at.top - toheight - scroll.y > 0;
			var cangodown = at.top + toheight + scroll.y < boundary.y;
			if (cangoup == cangodown) totop = Math.floor(at.top - toheight / 2);
			else if (cangodown) totop = at.top;
			else totop = at.top + at.height - toheight;
		}
		this.openfx.start({'opacity': 1, 'left': toleft, 'top': totop, 'width': towidth, 'height': toheight});
	},
	
	shrinkTowards: function (element) {
		var downto = element.getCoordinates();
		downto.opacity = 0;
		this.closefx.start(downto);
	},
	
	expandFrom: function (element) {
		if (!element) element = this.link;
		var upfrom = element.getCoordinates();
		upfrom.opacity = 1;
		upfrom.left = upfrom.left + 20;
		this.floater.setStyles(upfrom);
		this.resize();
	},

  destroy: function () {
    this.floater.remove();
  },
  
  waiting: function () {
    this.formWaiter.show();
  },

  notWaiting: function () {
    this.formWaiter.hide();
  },

	linkWaiting: function (argument) {
		this.link.addClass('waiting');
	},
	
	linkNotWaiting: function (argument) {
		this.link.removeClass('waiting');
	},

  showOnPage: function () {
    if (this.destination_squeeze) intf.squeezebox.display(this.destination_squeeze);
    if (this.destination_type == 'UL') {
			this.destination.selectedIndex = 0;
	    new Fx.Scroll(window).toElement(this.destination);
		} else {
	    new Fx.Scroll(window).toElement(this.created_item);
		}
  },

	announceSuccess: function () {
    intf.announce('done');
	},

  url: function () { 
		return this.link.getProperty('href'); 			// needs to be overridable
  },

  canceller: function () {
    var a = new Element('a', {'class': 'canceller', 'href': '#'}).setText('X');
    a.onclick = this.hide.bind(this);
    return a;
  }
	
});

// htmlForm inherits from jsonForm but expects to get html back at the end of the process instead: 
// usually a list item but could be anything.

var htmlForm = new Class ({
	Extends: jsonForm,
	
	prepForm: function () {
		arguments.callee.parent();
		this.form.getElements('#revise').each( function (input) { input.onclick = this.revise.bind(this); }, this);
		this.form.getElements('#confirm').each( function (input) { input.onclick = this.confirm.bind(this); }, this);
	},
	
  sendForm: function (e) {
    var event = intf.blocked_event(e);
    this.responseholder = new Element(this.destination_type);
    var mf = this;
    var req = new Request.HTML({
      url: this.form.get('action'),
      update: this.responseholder,
      onRequest: function () { mf.waiting(); },
      onSuccess: function (response) { mf.processResponse(response); },
      onFailure: function (response) { mf.hide(); intf.complain('remote call failed'); }
    }).post(this.form);
  },

	confirm: function (e) {
		console.log('confirming');
		this.form.getElements('input.routing').each(function (input) { input.set('value', 'confirm'); });
		return true;
	},

	revise: function (e) {
		console.log('revising');
		this.form.getElements('input.routing').each(function (input) { input.set('value', 'revise'); });
		return true;
	},

  processResponse: function (response) {
		this.notWaiting();
    if (this.responseholder.getElement('form')) {
			this.formHolder.empty();
			this.formHolder.adopt(this.responseholder.getChildren());
			this.prepForm();			// loop back and prepare form for submission again
    } else {
			this.hide();
			this.updatePage(response);
    }
  },

  updatePage: function () {
    var elements = this.responseholder.getChildren(); 
    this.created_item = elements[0];
		var addwhere = this.destination.hasClass('addToBottom') ? 'bottom' : 'top';
    this.created_item.inject(this.destination, addwhere);
    this.showOnPage();
    intf.activateElement( this.created_item );
		this.announceSuccess();
  },
  
  showOnPage: function () {
    if (this.destination_squeeze) intf.squeezebox.display(this.destination_squeeze);
    new Fx.Scroll(window).toElement(this.created_item).chain(function(){ this.created_item.highlight(); });
  }
});


// snipper is a special case of htmlForm that does more work to prepare the form

var Snipper = new Class ({
	Extends: htmlForm,
	
  prepForm: function () {
		arguments.callee.parent();
    this.form.getElements('#node_playfrom').each( function (input) { input.set('value', intf.getPlayerIn()); });
    this.form.getElements('#node_playto').each( function (input) { input.set('value', intf.getPlayerOut()); });
  },

	announceSuccess: function () {
    intf.announce('fragment created');
	}
});

// snipper is another htmlForm with a few extra preparations





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
    if (elements) elements.each(function (element) { element.squeezed = true; });
	},
	addSections: function (togglers, elements) {
		togglers.each(function (toggler) {
			element = elements[togglers.indexOf(toggler)];
			this.addSection(toggler, element);
			element.squeezed = true; 
		}, this);
	}
});






var interface = null;

window.addEvent('domready', function(){
  interface = new Interface();
  interface.activate();
	window.addEvent('scroll', function (e) { interface.moveFixed(e); });
	window.addEvent('resize', function (e) { interface.moveFixed(e); });
});

var Interface = new Class({
	initialize: function(){
    this.tips = null;
    this.dragging = false;
    this.draggables = [];
    this.droppers = [];
    this.tabs = [];
    this.tabsets = {};
    this.fixedbottom = [];
    this.clickthreshold = 6;
    this.cloud = null;
    this.notifyfx = null;
    // defaults
    this.storedPreferences = new Hash.Cookie('SpokePrefs');
    this.preferences = {
      confirmDrops: this.storedPreferences.get('set') ? this.storedPreferences.get('confirmDrops') : false,
      showDetails: this.storedPreferences.get('set') ? this.storedPreferences.get('showDetails') : true
    };
	},
	setPrefFromCheckbox: function (element, event) {
    this.setPref(element.id, element.getProperty('checked') ? true : false);
    // console.log(this.preferences);
	},
	setPref: function (key, value) {
    this.preferences[key] = value;
    this.savePrefs();
	},
	getPref: function (key) {
	  return this.preferences[key];
	},
	savePrefs: function () {
	  this.preferences['set'] = true;
    this.storedPreferences.extend(this.preferences);
	},
  announce: function (message) {
    if (message) $E('#notification').setText(message);
    this.flashfooter('#695D54');
  },
  complain: function (message) {
    if (message) $E('#notification').setText(message);
    this.flashfooter('#ff0000');
  },
  clearnotification: function () {
    $E('#notification').setText('');
  },
  flash: function (element, color) {
    return;
    var bgbackto = element.getStyle('background-color');
    var fgbackto = element.getStyle('color');
    new Fx.Styles(element, {duration:300, wait:false}).start({
  		'background-color': [color || '#cc6e1f', '#ffffff'],
  		'color': ['#ffffff',fgbackto]
    }).chain(function () {
      element.setStyle('background-color', bgbackto)
    });
  },
  flashfooter: function (colour) {
    var footer = $E('#mastfoot');
    var backto = footer.getStyle('background-color');
    if (!this.notifyfx) this.notifyfx = new Fx.Styles($E('#mastfoot'), {duration:2000, wait:false});
    this.notifyfx.start({ 'background-color': [colour,backto] });
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
  startDragging: function (element) {
    $ES('.hideondrag').each(function (element) { element.setStyle('visibility', 'hidden'); })
    $ES('.showondrag').each(function (element) { element.setStyle('visibility', 'visible'); })
    this.tabs.each(function (t) { t.makeReceptiveTo(element); })
    this.hideTips();
    var catchers = [];
  	this.droppers.each(function(d){ if (d.makeReceptiveTo(element)) catchers.push(d.container); });
  	return catchers;        // returns list of elements ready to receive drop, suitable for initializing draggable
  },
  stopDragging: function () {
    this.dragging = false;
    this.tabs.each(function (t) { t.makeUnreceptive(); })
  	this.droppers.each(function (d) { 
  	  d.makeUnreceptive();
  	  d.makeUnregretful();
  	})
    $ES('.hideondrag').each(function (element) { element.setStyle('visibility', 'visible'); })
    $ES('.showondrag').each(function (element) { element.setStyle('visibility', 'hidden'); })
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
  
  // useful abstractions used when initialising page and also when making newly created objects active
  
  addTabs: function (elements) {  
    var intf = this; elements.each(function (element) { intf.tabs.push(new Tab(element)); });
  },
  addScratchTabs: function (elements) {
    var intf = this; elements.each(function (element) { intf.tabs.push(new ScratchTab(element)); });
  },
  addDropzones: function (elements) {
    var intf = this; elements.each(function (element) { intf.droppers.push(new Dropzone(element)); });
  },
  addTrashDropzones: function (elements) {
    var intf = this; elements.each(function (element) { intf.droppers.push(new TrashDropzone(element)); });
  },
  makeDraggable: function (elements) {
    var intf = this; elements.each(function (element) { element.addEvent('mousedown', function(event) { intf.dragging = new Draggee(this, event); }); });
  },
  makeFixed: function (elements) {
    var intf = this; elements.each(function (element) { intf.fixedbottom.push(element); });
  },
  makeTippable: function (elements) {
    this.tips = new SpokeTips(elements);
  },
    
  // this is the main page initialisation routine: it gets called on domready
  
  activate: function (element) {
    var scope = element || null;
	  this.addDropzones($ES('.catcher', scope));
	  this.addTrashDropzones($ES('.trashdrop', scope));
	  this.makeDraggable($ES('.draggable', scope));
	  this.makeTippable($ES('.expandable', scope));
    // this.makeExpandable($ES('.expandable', scope));
	  if (scope) {
	    if (scope.hasClass('catcher')) this.addDropzones([scope]);
  	  if (scope.hasClass('trashdrop')) this.addTrashDropzones([scope]);
  	  if (scope.hasClass('draggable')) this.makeDraggable([scope]);
  	  if (scope.hasClass('expandable')) this.makeTippable([scope]);
      // if (scope.hasClass('expandable')) this.makeExpandable([scope]);
	  } 

	  this.addTabs($ES('a.tab', scope));
	  this.addScratchTabs($ES('a.padtab', scope));
	  this.makeFixed($ES('div.fixedbottom', scope));

    $ES('a.autolink', scope).each( function (a) { new AutoLink(a); });
    $ES('a.toggle', scope).each( function (a) { new Toggle(a); });
    $ES('input.cloudcontrol', scope).each( function (element) {
      element.addEvent('click', function (e) {
        var band = element.idparts().id;
        element.checked ? $ES('a.cloud' + band).setStyle('display', 'inline') : $ES('a.cloud' + band).hide();
      })
    });
    // $ES('input.tagbox', scope).each(function (element, i) {
    //  new TagSuggestion(element, '/tags/matching', {
    //    postVar: 'stem',
    //    onRequest: function(el) { element.addClass('waiting'); },
    //    onComplete: function(el) { element.removeClass('waiting'); }
    //  });
    // });
    $ES('a.snipper', scope).each( function (element) {
      element.addEvent('click', function (e) {
        new Snipper(element, e);
      });
    });
    
    $ES('input.spokepref').each( function (element) {
      element.addEvent('click', function (e) { interface.setPrefFromCheckbox(element, e) });
      if (interface.getPref(element.id)) element.setProperty('checked', true);
    })
  }
});

var SpokeTips = Tips.extend({
  options: {
  	initialize:function(){ this.fx = new Fx.Style(this.toolTip, 'opacity', {duration: 250, wait: false}).set(0); },
  	onShow: function(toolTip) { if (interface.getPref('showDetails') && !interface.dragging) this.fx.start(0.8); },
  	onHide: function(toolTip) { this.fx.start(0); }
  },
	build: function(el){
    el.$tmp.myTitle = el.title || $E('div.tiptitle', el).getText();
    el.$tmp.myText = $E('div.tiptext', el).getText();
		el.addEvent('mouseenter', function(event){
			this.start(el);
			if (!this.options.fixed) this.locate(event);
			else this.position(el);
		}.bind(this));
		if (!this.options.fixed) el.addEvent('mousemove', this.locate.bindWithEvent(this));
		var end = this.end.bind(this);
		el.addEvent('mouseleave', end);
		el.addEvent('trash', end);
	}
});

var Outcome = new Class({
	initialize: function(response){
    var parts = response.split('|');
    this.status = parts[0];
    this.message = parts[1];
    this.consequence = parts[2];
	}
})

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
	contents: function () { return $ES('.draggable', this.container).map(function(el){ return el.id; }); },
	contains: function (draggee) { return this.contents().contains(draggee.tag); },
	can_catch: function (type) { if (this.catches) return this.catches == 'all' || this.catches.split(',').contains(type); },
	makeReceptiveTo: function (helper) {
    // this gets called when a drag from elsewhere enters this space
	  type = helper.draggee.spokeType();
	  if (this.can_catch(type)) {
  		var dropzone = this;
  		dropzone.container.addEvents({
  			drop: function() { 
  			  interface.stopDragging(); 
  			  dropzone.receiveDrop(helper); 
  			},
  			over: function() { 
  			  dropzone.showInterest(helper); 
  			}
  		});
  		return this.isReceptive = true;
    } else {
  		return this.isReceptive = false;
    }
	},
	makeUnreceptive: function () { 
    // this gets called when a drag from elsewhere leaves this space
	  if (this.isReceptive) {
  	  this.container.removeEvents('over');
  	  this.container.removeEvents('leave');
  	  this.container.removeEvents('drop');
  		this.isReceptive = false;
	  }
	},
	makeRegretful: function (helper) {
    // this gets called when we drag something out of this space that began here
    console.log('makeRegretful');
		var dropzone = this;
		dropzone.container.addEvents({
	    'mouseenter': function() { 
			  console.log('back again');
        helper.clearState();
    	  dropzone.container.removeClass('bereft');
			},
			'mouseleave': function() { 
			  console.log('leaving the area');
        helper.droppable(dropzone);
    	  dropzone.container.addClass('bereft');
			}
    });
		this.isRegretful = true;
	},
	makeUnregretful: function () {
    console.log('makeUnregretful');
	  if (this.isRegretful) {
  	  this.container.removeEvents('mouseenter');
  	  this.container.removeEvents('mouseleave');
  		this.isRegretful = false;
    }
	},
	showInterest: function (helper) {
	  if (this.container != helper.draggee.original && this != helper.draggee.draggedfrom && !this.contains(helper.draggee)) {
  		var dropzone = this;
		  var state = helper.getState();
		  var text = helper.getText();
  	  dropzone.container.addClass('drophere');
  	  if(dropzone.tab) dropzone.tab.tabhead.addClass('over');
  	  dropzone.container.addEvents({
  	    'leave': function() { 
      	  if(dropzone.tab) dropzone.tab.tabhead.removeClass('over');
  			  dropzone.loseInterest();
  			  helper.setState(state, text);
  			}
  	  });
  	  helper.insertable(dropzone);
	  }
	},
	loseInterest: function (helper) { 
	  console.log('loseinterest');
    this.container.removeClass('drophere');
	},
	receiveDrop: function (helper) {
		var dropzone = this;
	  var message = helper.getText() + '?';
		dropzone.loseInterest(helper);
		draggee = helper.draggee;
		if (dropzone == draggee.draggedfrom) {
			helper.flyback();
			
		} else if (dropzone.contains(draggee)) {
			interface.complain('already there');
			helper.flyback();
			
		} else {
			helper.remove();
			if (!interface.getPref('confirmDrops') || confirm(message)) {
  			var req = new Ajax(this.addURL(draggee), {
  				method: 'get',
  			  onRequest: function () { 
  			    dropzone.waiting(); 
  			    draggee.waiting(); 
  			  },
          onSuccess: function(response){
            var outcome = new Outcome(response);
            console.log('status = ' + outcome.status + ', message = ' + outcome.message + ', consequence = ' + outcome.consequence);
            if (outcome.status == 'success') {
              dropzone.notWaiting();
    			    draggee.notWaiting(); 
              dropzone.showSuccess();
              if (outcome.consequence == 'move' || outcome.consequence == 'insert') dropzone.accept(draggee);
              if (outcome.consequence == 'move' || outcome.consequence == 'delete') draggee.disappear();
              interface.announce(outcome.message);
            } else {
      		    dropzone.showFailure();
              interface.complain(outcome.message);
            }
          },
  			  onFailure: function (response) { 
  			    dropzone.notWaiting(); 
  			    draggee.notWaiting(); 
  			    dropzone.showFailure();
  			    interface.complain('remote call failed');
  			  }
  			}).request();
  			console.log('drop received');
			}
		}
  },
	removeDrop: function (draggee) {
		var dropzone = this;
	  var message = helper.getText() + '?';
		if (!interface.getPref('confirmDrops') || confirm(message)) {
  		new Ajax(dropzone.removeURL(draggee), {
  			method : 'post',
  		  onRequest: function () { draggee.waiting(); },
  		  onSuccess: function (response) { 
          var outcome = new Outcome(response);
          if (outcome.status == 'success') {
  		      interface.announce(outcome.message); 
            draggee.disappear(); 
  		    } else {
  			    dropzone.showFailure();
            interface.complain(outcome.message);
  		    }
  		  },
  		  onFailure: function (response) {
  		    dropzone.showFailure();
  		    interface.complain('remote call failed');
  		  }
  		}).request();
    }
	},
	addURL: function (draggee) { 
		return '/' + this.spokeType() + 's/' + this.receiptAction + '/' + this.spokeID() + '/' + draggee.spokeType() + '/' + draggee.spokeID();  
	},
	removeURL: function (draggee) { 
		return '/' + this.spokeType() + 's/' + this.removeAction + '/' + this.spokeID() + '/' + draggee.spokeType() + '/' + draggee.spokeID(); 
	},
	waiter: function () {
    if (this.waitSignal) return this.waitSignal;
    if (this.zoneType() != 'list') return null;
    this.waitSignal = new Element('li', { 'class': 'waiting hide' }).injectInside(this.container);
    new Element('a', {'class': 'listed'}).setText('hold on').injectInside(this.waitSignal);
    return this.waitSignal;
	},
	waiting: function () {
	  if (this.zoneType() == 'list') {
  	  if (this.waiter()) this.waiter().show();
	  } else {
	    console.log('waiting ' + this.tag);
	    this.container.addClass('waiting');
	  }
	},
	notWaiting: function () { 
	  if (this.zoneType() == 'list') {
      if (this.waiter()) this.waiter().hide();
	  } else {
	    this.container.removeClass('waiting');
	  }
	},
	showSuccess: function () {
	  interface.flash(this.flasher());
	},
	showFailure: function () {

	},
	accept: function (draggee) {
    if (this.zoneType() == 'list') {
      var element = draggee.clone().injectInside(this.container);
      interface.activate(element);
    }
	}
});

var TrashDropzone = Dropzone.extend({
	initialize: function (element) { 
    this.parent(element);
    this.receiptAction = 'trash';
	},
	showInterest: function (helper) { 
		var dropzone = this;
	  var state = helper.getState();
	  var text = helper.getText();
	  dropzone.container.addClass('drophere');
	  dropzone.container.addEvents({
	    'leave': function() { 
			  dropzone.loseInterest();
			  helper.setState(state, text);
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
	initialize: function(element, e){
	  event = new Event(e).stop();
	  event.preventDefault();
		this.original = element;
		this.tag = element.spokeType() + '_' + element.spokeID();   //omitting other id parts that only serve to avoid duplicate element ids
		this.link = $E('a', element);
		this.name = this.original.title || this.link.getText();
		this.draggedfrom = interface.lookForDropper(element.getParent());
		this.helper = new DragHelper(this);
		this.helper.start(event);
	},
  spokeID: function () { return this.original.spokeID(); },
  spokeType: function () { return this.original.spokeType(); },
	doClick: function (e) { window.location = this.link.href; },  // this.link.fireEvent('click')?
	draggedOut: function () { if (this.draggedfrom) this.draggedfrom.removeDrop(this) },
	waiting: function () { this.original.addClass('waiting'); },
	notWaiting: function () { this.original.removeClass('waiting'); },
	remove: function () { this.original.remove(); },
	explode: function () { this.original.explode(); },
	disappear: function () { this.original.dwindle(); },
	clone: function () { return this.original.clone(); }
});

// the dragged representation is a new DragHelper object with useful abilities
// and a tooltip-like label

var DragHelper = new Class({
	initialize: function(draggee){
	  this.draggee = draggee;
		this.container = new Element('div', { 'class': 'drag-tip' }).injectInside(document.body);
		this.textholder = new Element('div', { 'class': 'drag-title' }).injectInside(this.container);
		this.footer = new Element('div', { 'class': 'drag-text' }).injectInside(this.container);
    this.fx = new Fx.Style(this.container, 'opacity', {duration: 250, wait: false}).set(0);
		this.name = this.draggee.name;
		this.startingfrom = draggee.original.getCoordinates();
		this.startingfrom.opacity = 0;
    this.currentState = null;
    this.currentText = null;
		this.setText(this.name);
	},
	start: function (event) {
	  event.stop();
	  event.preventDefault();
		this.moveto(event.page.y, event.page.x);
		var helper = this;
		this.container.addEvent('emptydrop', function() { helper.emptydrop(); })      // should just bind this
		if (this.draggee.draggedfrom) this.draggee.draggedfrom.makeRegretful(helper);
		this.show();
		this.container.makeDraggable({ 
			droppables: interface.startDragging(this)     // returns list of activated dropzones.
		}).start(event);
	},
	emptydrop: function () {
		interface.stopDragging();
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
	  this.draggee.draggedOut();
	  this.explode();
	},
	flyback: function () {
	  helper = this;
    this.container.effects({ duration: 600, transition: Fx.Transitions.Back.easeOut }).start( this.startingfrom ).chain(function(){ helper.remove() });
	},
	moveto: function (top, left) {
	  var offsetY = this.container.getCoordinates().height + 12;
	  var offsetX = Math.floor(this.container.getCoordinates().width / 2);
    this.container.setStyles({'top': top - offsetY, 'left': left - offsetX});
	},
	hasMoved: function () {
		var now = this.container.getCoordinates();
		var hm = Math.abs(this.startingfrom.left - now.left) + Math.abs(this.startingfrom.top - now.top) >= interface.clickthreshold;
		console.log('hasmoved? ' + hm);
		return hm;
	},
  show: function () { this.fx.start(0.8); },
  hide: function () { this.fx.start(0); },
	remove: function () { this.container.remove(); },
	explode: function () { this.remove(); },  // something more vivid should happen here
	disappear: function () { this.original.dwindle(); },
	deleteable: function () { 
    this.setState('deleteable', "Delete '" + this.name + "' from the collection");
	},
	droppable: function (dropzone) { 
    this.setState('droppable', "Remove '" + this.name + "' from " + dropzone.name);
	},
	insertable: function (dropzone) {
	  if (this.draggee.spokeType() == dropzone.spokeType()) {
      this.setState('mergeable', "Merge '" + this.name + "' into '" + dropzone.name + "'");
	  } else {
      this.setState('insertable', "Apply '" + this.name + "' to '" + dropzone.name + "'");
	  }
	},
	setState: function (state, text) {
    this.clearState();
 	  console.log('setState(' + state + ', ' + text + ')');
   this.container.addClass(state);
    this.currentState = state;
    this.setText(text || this.name);
	},
	getState: function () {
	  console.log('getState returning ' + this.currentState);
    return this.currentState;
	},
	clearState: function () {
	  console.log('clearState');
    this.container.removeClass('droppable');
    this.container.removeClass('insertable');
    this.container.removeClass('deleteable');
    this.container.removeClass('mergeable');
    this.currentState = null;
    this.setText(this.name);
	},
	setText: function (text) {
	  this.textholder.setText(text);
	},
	getText: function () {
	  return this.textholder.getText();
	}
});

var Tab = new Class({
	initialize: function(element){
		this.tabhead = element;
    var parts = element.id.split('_');
		this.tag = parts.pop();
		this.settag = parts.pop();
		this.tabbody = $E('#' + this.settag + '_' + this.tag);
		this.tabset = null;
    this.addToSet();
 		this.tabhead.onclick = this.select.bind(this);
	},
	addToSet: function () {
    this.tabset = interface.tabsets[this.settag] || new TabSet(this.settag);
    this.tabset.addTab(this);
	},
	select: function (e) {
	  e = new Event(e).stop();
	  e.preventDefault();
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
	makeReceptiveTo: function (draggee) {
	  var tab = this;
 		this.tabhead.addEvent('mouseenter', function (e) { tab.select(e); });
	},
	makeUnreceptive: function () {
    this.tabhead.removeEvents('mouseenter');
	}
});

var TabSet = new Class({
	initialize: function(tag){
	  this.tabs = [];
    this.tag = tag;
    this.headcontainer = $E('#headbox_' + this.tag);
	  this.container = $E('#box_' + this.tag);
    this.foreground = null;
	  interface.tabsets[this.tag] = this;
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

var ScratchTab = Tab.extend({
	initialize: function(element){
		this.parent(element);
 		this.holdopen = false;
		this.dropzone = $E('.catcher', this.container);
		this.dropzone.tab = this;
  	this.padform = null;
    this.formholder = new Element('div', {'class': 'padform bigspinner', 'style': 'height: 0'}).injectTop(this.tabbody).hide();
    this.formfx = new Fx.Style(this.formholder, 'height', {duration:1000});
    this.renamer = $E('a.renamepad', this.tabbody);
    this.clearer = $E('a.clearpad', this.tabbody);
    this.deleter = $E('a.deletepad', this.tabbody);
    this.setter = $E('a.setfrompad', this.tabbody);
    this.renamer.onclick = this.getForm.bind(this);
    this.clearer.onclick = this.clear.bind(this);
    this.deleter.onclick = this.remove.bind(this);
    this.setter.onclick = this.toSet.bind(this);
    $E('a.closepad', this.tabbody).onclick = this.close.bind(this);
    $E('a.createpad', this.tabbody).onclick = this.createTab.bind(this);
  },
  open: function () { 
    this.tabset.open(); 
  },
	close: function () { 
    this.hideForm();
	  this.tabset.close(); 
	},
	addToSet: function () {
    this.tabset = interface.tabsets[this.settag] || new ScratchSet(this.settag);
    this.tabset.addTab(this);
	},
	reselect: function (tag) {
    this.tabset.toggle();
	},
	deselect: function () {
    this.hideForm();
	},
	clear: function (e) {
	  e = new Event(e).stop();
    e.preventDefault();
	  var stab = this;
		new Ajax(e.target.getProperty('href'), {
			method: 'get',
			onRequest: function () {
    	  $ES('li', stab.tabbody).addClass('waiting');
			},
		  onSuccess: function (response) { 
    	  $ES('li', stab.tabbody).dwindle();
    	  interface.announce("scratchpad cleared");
		  },
		  onFailure: function (response) { 
        interface.complain("scratchpad clear failed!");
		  }
		}).request();
	},
	remove: function (e) {
	  e = new Event(e).stop();
    e.preventDefault();
    this.tabhead.addClass('red');
    if (confirm("are you sure you want to completely remove the scratchpad '" + this.tabhead.getText() + "'?")) {
      var stab = this;
  		new Ajax(e.target.getProperty('href'), {
  			method: 'get',
  		  onSuccess: function (response) { 
  		    stab.tabhead.dwindle(); 
  		    stab.tabbody.dwindle(); 
  		    stab.tabset.removeTab(stab);
  		  },
  		  onFailure: function () { 
  		    interface.complain('no way'); 
  		  }
  		}).request();
    } else {
      this.tabhead.removeClass('red');
    }
	},
	toSet: function (e) {
	  $ES('li', this.tabbody).addClass('waiting');
	  // and we let nature take its course
	},
	getForm: function (e) {
	  e = new Event(e).stop();
    e.preventDefault();
    this.showForm(e.target.getProperty('href'));
  },
  showForm: function (url) {
    this.tabhead.addClass('editing');
    this.formholder.show();
    if (! this.padform) {
  	  this.formfx.start(64);
  	  var stab = this;
  		new Ajax(url, {
  			method: 'get',
  			update: stab.formholder,
  		  onSuccess: function () { stab.bindForm() },
  		  onFailure: function () { 
  		    stab.hideFormNicely(); 
  		    interface.complain('no way'); 
  		  }
  		}).request();
    }
	},
	hideFormNicely: function (e) {
    if (e) e = new Event(e).stop();
    var stab = this;
	  this.formfx.start(0).chain(function () { stab.hideForm(e) });
	},
	hideForm: function (e) {
    if (e) e = new Event(e).stop();
    this.formholder.hide();
    this.tabhead.removeClass('editing');
	},
	bindForm: function () {
    this.formholder.removeClass('bigspinner');
    this.formholder.show();
    this.padform = $E('form', this.formholder);
		this.padform.onsubmit = this.doForm.bind(this);
		$E('a.cancel_form', this.padform).onclick = this.hideForm.bind(this);
		$E('input', this.padform).focus();
	},
	doForm: function (e) {
	  e = new Event(e).stop();
	  e.preventDefault();
	  var stab = this;
    this.padform.hide();
    this.formholder.addClass('bigspinner');
	  this.padform.send({
      method: 'post',
      update: stab.tabhead,
      onComplete: function () { stab.hideFormNicely(); }
	  });
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
	createTab: function (e) {
    this.tabset.createTab(e);
	}
});

var ScratchSet = TabSet.extend({
	initialize: function(tag){
		this.parent(tag);
	  this.container = $E('#scratchpad');
		this.isopen = false;
		this.openFX = this.container.effects({duration: 600, transition: Fx.Transitions.Cubic.easeOut});
		this.closeFX = this.container.effects({duration: 1000, transition: Fx.Transitions.Bounce.easeOut});
	},
  postselect: function () {
    if (!this.isopen) this.open();
  },
  open: function () {
    this.openFX.start({
      'top': window.getScrollTop() + 10,
      'height': window.getHeight() - 10
    });
    this.isopen = true;
	},
	close: function (delay) {
    this.closeFX.start({
      'top': window.getScrollTop() + window.getHeight() - 34, 
      'height': 34
    }); 
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
    var bodyholder = new Element('div', {'class': "temporary"}).injectInside($E('body'));
    var tabs = this;
    var workingtab = new Element('a', {'class': 'padtab red', 'href': "#"}).setText('working').injectInside(this.headcontainer);
		var req = new Ajax(e.target.getProperty('href'), {
			method: 'get',
			update: bodyholder,
		  onSuccess: function (response) { 
    		var newbody = $E('div.scratchpage', bodyholder);
    		var tabid = newbody.spokeID();
        var newhead = new Element('a', {'class': 'padtab', 'href': "#", 'id': "tab_scratchpad_" + tabid}).setText('new pad');
        workingtab.hide();
    		newhead.injectInside(tabs.headcontainer);
        newbody.injectInside(tabs.container);
        var newtab = new ScratchTab(newhead);
        interface.activate(newbody);
        tabs.select(newtab.tag);
        newtab.showForm('/scratchpads/edit/' + tabid);
        bodyholder.remove();
		  },
		  onFailure: function (response) { 
		    
        bodyholder.remove();
		  }
		}).request();
		
    
    
	}
});


var intf = null;

window.addEvent('domready', function(){
  intf = new Interface();
  intf.activate();
  // window.addEvent('scroll', function (e) { intf.moveFixed(e); });
  // window.addEvent('resize', function (e) { intf.moveFixed(e); });
});

var Interface = new Class({
	initialize: function(){
    // this.tips = null;
    this.dragging = false;
    this.draggables = [];
    this.droppers = [];
    this.tabs = [];
    this.tabsets = {};
    this.fixedbottom = [];
    this.inlinelinks = [];
    this.clickthreshold = 6;
    this.cloud = null;
    this.announcer = $E('div#notification');
    this.admin = $E('div#admin');
    this.fader = new Fx.Tween(this.announcer, 'opacity', {duration: 'long', link: 'chain'});
    // this.activate();
	},
	setPrefFromCheckbox: function (element, event) {
    // this.setPref(element.id, element.getProperty('checked') ? true : false);
    // console.log(this.preferences);
	},
	setPref: function (key, value) {
    // this.preferences[key] = value;
    // this.savePrefs();
	},
	getPref: function (key) {
    // return this.preferences[key];
	},
	savePrefs: function () {
    // this.preferences['set'] = true;
    //     this.storedPreferences.extend(this.preferences);
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
  // hideTips: function () {
  //   if (this.tips) this.tips.hide();
  // },
  startDragging: function (draggee) {
    $$('.hideondrag').each(function (element) { element.setStyle('visibility', 'hidden'); })
    $$('.showondrag').each(function (element) { element.setStyle('visibility', 'visible'); })
    this.dragging = draggee.original;
    var catchers = [];
  	this.droppers.each(function(d){ if (d.can_catch(draggee.spokeType())) catchers.push(d.container); });
  	return catchers;        // returns list of elements ready to receive drop, suitable for initializing draggable
  },
  stopDragging: function () {
    this.dragging = null;
    this.tabs.each(function (t) { t.makeUnreceptive(); })
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
  
  // useful abstractions used when initialising page and also when making newly created objects active
  
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
  // makeTippable: function (elements) {
  //   this.tips = new SpokeTips(elements);
  // },
  makeToggle: function (elements) {
    elements.each(function (element) { intf.inlinelinks.push(new Toggle(element)); });
  },
    
  // this is the main page initialisation routine: it gets called on domready
  
  activate: function (element) {
    var scope = element || null;
	  this.addDropzones($$('.catcher', scope));
	  this.addTrashDropzones($$('.trashdrop', scope));
	  this.makeDraggables($$('.draggable', scope));
    // this.makeTippable($$('.expandable', scope));
    // this.makeExpandable($$('.expandable', scope));
	  if (scope) {
	    if (scope.hasClass('catcher')) this.addDropzones([scope]);
  	  if (scope.hasClass('trashdrop')) this.addTrashDropzones([scope]);
  	  if (scope.hasClass('draggable')) this.makeDraggables([scope]);
      // if (scope.hasClass('expandable')) this.makeTippable([scope]);
      // if (scope.hasClass('expandable')) this.makeExpandable([scope]);
	  } 

	  this.addTabs($$('a.tab', scope));
	  this.addScratchTabs($$('a.padtab', scope));
	  this.makeFixed($$('div.fixedbottom', scope));
    this.makeToggle($$('a.toggle', scope))

    $$('input.cloudcontrol', scope).each( function (element) {
      element.addEvent('click', function (e) {
        var band = element.idparts().id;
        element.checked ? $$('a.cloud' + band).setStyle('display', 'inline') : $$('a.cloud' + band).hide();
      })
    });
    // $$('input.tagbox', scope).each(function (element, i) {
    //  new TagSuggestion(element, '/tags/matching', {
    //    postVar: 'stem',
    //    onRequest: function(el) { element.addClass('waiting'); },
    //    onComplete: function(el) { element.removeClass('waiting'); }
    //  });
    // });
    $$('a.snipper', scope).each( function (element) {
      element.addEvent('click', function (e) {
        new Snipper(element, e);
      });
    });
    
    $$('input.spokepref').each( function (element) {
      element.addEvent('click', function (e) { intf.setPrefFromCheckbox(element, e) });
      if (intf.getPref(element.id)) element.setProperty('checked', true);
    })
  }
});

// var SpokeTips = new Class({
//   Extends: Tips,
//   options: {
//    initialize:function(){ this.fx = new Fx.Style(this.toolTip, 'opacity', {duration: 250, wait: false}).set(0); },
//    onShow: function(toolTip) { if (!intf.dragging) this.fx.start(0.8); },
//    onHide: function(toolTip) { this.fx.start(0); }
//   },
//  build: function(el){
//     el.$tmp.myTitle = el.title || $E('div.tiptitle', el).getText();
//     el.$tmp.myText = $E('div.tiptext', el).getText();
//    el.addEvent('mouseenter', function(event){
//      this.start(el);
//      if (!this.options.fixed) this.locate(event);
//      else this.position(el);
//    }.bind(this));
//    if (!this.options.fixed) el.addEvent('mousemove', this.locate.bindWithEvent(this));
//    var end = this.end.bind(this);
//    el.addEvent('mouseleave', end);
//    el.addEvent('trash', end);
//  }
// });

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
	contents: function () { return this.container.getElements('.draggable').map(function(el){ return el.id; }); },
	contains: function (draggee) { return this.contents().contains(draggee.tag); },
	can_catch: function (type) { if (this.catches) return this.catches == 'all' || this.catches.split(',').contains(type); },
  respond: function (helper) {
    // this gets called when a drag from elsewhere enters this space
    // catchability checks were performed when the drag began and this method should not
    // be called if we weren't activated then
    this.container.addClass('drophere');
  	if (this.tab) this.tab.tabhead.addClass('over');
  },
  forget: function (helper) {
    // this gets called when a drag from elsewhere leaves this space
    this.container.removeClass('drophere');
	  if (this.tab) this.tab.tabhead.removeClass('over');
  },
  
	receiveDrop: function (helper) {
	  intf.stopDragging();
		var dropzone = this;
	  var message = helper.getText() + '?';
		var draggee = helper.draggee;
		dropzone.loseInterest(helper);
		
		if (dropzone == draggee.draggedfrom) {
			helper.flyback();
			
		} else if (dropzone.contains(draggee)) {
		  console.log(draggee);
			intf.complain(draggee.name + ' is already there');
			helper.flyback();
			
		} else {
			helper.remove();
			if (!intf.getPref('confirmDrops') || confirm(message)) {

  			var req = new Request.JSON( {
  			  url: this.addURL(draggee),
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
              intf.announce(outcome.message);
            } else {
      		    dropzone.showFailure();
              intf.complain(outcome.message);
            }
          },
  			  onFailure: function (response) { 
  			    dropzone.notWaiting(); 
  			    draggee.notWaiting(); 
  			    dropzone.showFailure();
  			    intf.complain('remote call failed');
  			  }
  			}).send();
			}
		}
  },
	removeDrop: function (helper) {
	  intf.stopDragging();
		var dropzone = this;
    var draggee = helper.draggee;
	  var message = helper.getText() + '?';
		helper.remove();
	  
		if (!intf.getPref('confirmDrops') || confirm(message)) {
  		new Request.JSON({
  		  url: dropzone.removeURL(draggee),
  			method: 'post',
  		  onRequest: function () { draggee.waiting(); },
  		  onSuccess: function (response) { 
          var outcome = new Outcome(response);
          if (outcome.status == 'success') {
  		      intf.announce(outcome.message); 
            draggee.disappear(); 
  		    } else {
  			    dropzone.showFailure();
            intf.complain(outcome.message);
  		    }
  		  },
  		  onFailure: function (response) {
  		    dropzone.showFailure();
  		    intf.complain('remote call failed');
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
	  intf.flash(this.flasher());
	},
	showFailure: function () {

	},
	accept: function (draggee) {
    if (this.zoneType() == 'list') {
      var element = draggee.clone().injectInside(this.container);
      intf.activate(element);
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
		this.link = element.getElements('a')[0];
		this.name = this.findTitle();
		this.draggedfrom = intf.lookForDropper(element.getParent());
    this.link.duplicate().makeDraggable({ 
			droppables: intf.startDragging(this),
      onEnter: function(element, dropzone) { dropzone.respond(); },
      onLeave: function(element, dropzone) { dropzone.forget(); },
      onDrop: function(element, dropzone) {
        if (!dropzone) {
          dh.emptydrop();
        } else {
          dropzone.receiveDrop();
          dh.remove();
        } 
      }
		}).start(e);
		
    // this.helper = new DragHelper(this);
    //     this.helper.start(event);
	},
  spokeID: function () { return this.original.spokeID(); },
  spokeType: function () { return this.original.spokeType(); },
	doClick: function (e) { window.location = this.link.href; },  // this.link.fireEvent('click')?
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
		this.container = new Element('div', { 'class': 'drag-tip' }).injectInside(document.body);
		this.textholder = new Element('div', { 'class': 'drag-title' }).injectInside(this.container);
		this.footer = new Element('div', { 'class': 'drag-text' }).injectInside(this.container);
		this.container.dragHelper = this;
		this.name = this.draggee.name;
		this.startingfrom = null;
		this.setText(this.name);
		this.original = this.draggee.original;
		var dh = this;
		intf.dh = this;

		this.dragmove = this.container.makeDraggable({ 
			droppables: intf.startDragging(this),
      onEnter: function(container, dropzone) { dropzone.respond(); },
      onLeave: function(container, dropzone) { dropzone.forget(); },
      onDrop: function(container, dropzone) {
        console.log('onDrop! container is ');
        console.log(container);
        console.log('and droppable ');
        console.log(dropzone);
        if (!dropzone) {
          dh.emptydrop();
        } else {
          dropzone.receiveDrop();
          dh.remove();
        } 
      }
		});
	},
	start: function (event) {
	  event.stop();
	  event.preventDefault();
	  this.startingfrom = this.container.getPosition();
		this.moveto(event.page);
		this.show();
		this.dragmove.start(event);
	},
	emptydrop: function () {
		intf.stopDragging();
		if (this.moved < intf.clickthreshold) {
		  this.draggee.doClick();
		  this.remove();
    } else if (this.draggee.draggedfrom) {
      this.draggedOut();
		} else {
		  this.flyback();
		}
	},
	draggedOut: function () {
    if (this.draggee.draggedfrom) {
      this.draggee.draggedfrom.removeDrop(this);
  	  this.explode();
    } else {
      this.remove();
    }
	},
	flyback: function () {
	  helper = this;
    new Fx.Morph(this.container, {duration: 'long', transition: Fx.Transitions.Back.easeOut}).start( this.startingfrom );
	},
	moveto: function (here) {
	  var offsetY = this.container.getCoordinates().height + 12;
	  var offsetX = Math.floor(this.container.getCoordinates().width / 2);
    this.container.setStyle('top', here.y - offsetY);
    this.container.setStyle('left', here.x - offsetX);
	},
  show: function () { this.container.fade(0.8); },
  hide: function () { this.container.fade('out'); },
	remove: function () { this.container.remove(); },
	explode: function () { this.remove(); },  // something more explosive should happen here
	disappear: function () { this.original.dwindle(); },
	setText: function (text) { this.textholder.set('text', text); },
	getText: function () { return this.textholder.get('text'); }
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
    this.tabset = intf.tabsets[this.settag] || new TabSet(this.settag);
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
	respondTo: function (helper) {
	  this.select();
	},
	receiveDrop: function (helper) {
    return false;
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
		this.dropzone = $E('.catcher', this.container);
		this.dropzone.tab = this;
  	this.padform = null;
    this.formholder = new Element('div', {'class': 'padform bigspinner', 'style': 'height: 0'}).injectTop(this.tabbody).hide();
    this.formfx = new Fx.Tween(this.formholder, 'height', {duration: 'long'});
    this.renamer = $E('a.renamepad', this.tabbody);
    this.deleter = $E('a.deletepad', this.tabbody);
    this.setter = $E('a.setfrompad', this.tabbody);
    this.renamer.onclick = this.getForm.bind(this);
    this.deleter.onclick = this.remove.bind(this);
    this.setter.onclick = this.toSet.bind(this);
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
    this.tabset = intf.tabsets[this.settag] || new ScratchSet(this.settag);
    this.tabset.addTab(this);
	},
	reselect: function (tag) {
    this.tabset.toggle();
	},
	deselect: function () {
    this.hideForm();
	},
	remove: function (e) {
	  e = new Event(e).stop();
    e.preventDefault();
    this.tabhead.addClass('red');
    if (confirm("are you sure you want to completely remove the scratchpad '" + this.tabhead.getText() + "'?")) {
      var stab = this;
  		new Request.JSON({
  		  url: e.target.getProperty('href'),
  			method: 'delete',
  		  onSuccess: function (response) { 
  		    stab.tabhead.dwindle(); 
  		    stab.tabbody.dwindle(); 
  		    stab.tabset.removeTab(stab);
  		  },
  		  onFailure: function () { 
  		    intf.complain('no way'); 
  		  }
  		}).request();
    } else {
      this.tabhead.removeClass('red');
    }
	},
	toSet: function (e) {
	  $$('li', this.tabbody).addClass('waiting');
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
  		new Request.HTML({
  		  url: url,
  			method: 'get',
  			update: stab.formholder,
  		  onSuccess: function () { stab.bindForm() },
  		  onFailure: function () { 
  		    stab.hideFormNicely(); 
  		    intf.complain('no way'); 
  		  }
  		}).request();
    }
	},
	hideFormNicely: function (e) {
    if (e) e = new Event(e).stop();
    var stab = this;
	  this.formfx.start('height', 0).chain(function () { stab.hideForm(e) });
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
    var bodyholder = new Element('div', {'class': "temporary"}).injectInside($E('body'));
    var tabs = this;
    var workingtab = new Element('a', {'class': 'padtab red', 'href': "#"}).setText('working').injectInside(this.headcontainer);
		var req = new Request.HTML({
		  url: e.target.getProperty('href'),
			method: 'post',
			update: bodyholder,
		  onSuccess: function (response) { 
    		var newbody = $E('div.scratchpage', bodyholder);
    		var tabid = newbody.spokeID();
        var newhead = new Element('a', {'class': 'padtab', 'href': "#", 'id': "tab_scratchpad_" + tabid}).setText('new pad');
        workingtab.hide();
    		newhead.injectInside(tabs.headcontainer);
        newbody.injectInside(tabs.container);
        var newtab = new ScratchTab(newhead);
        intf.activate(newbody);
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

var AutoLink = new Class({
  initialize: function (a) {
    this.link = a;
    this.link.onclick = this.send.bind(this);
    this.catcher = new Element('div', {'style': 'display: none;'}).injectAfter(a).hide();
  },
  method: function () {
    return 'GET';
  },
  send: function (e) {
    e = new Event(e).stop();
    e.preventDefault();
    this.link.blur();
    al = this;
		new Request.HTML({
		  url: al.link.getProperty('href'),
			method: al.method(),
			update: al.catcher,
		  onRequest: function () {al.waiting();},
		  onComplete: function () {al.finished();},
		  onFailure: function () {al.failed();}
		}).request();
  },
  waiting: function () { this.link.addClass('waiting'); },
  notWaiting: function () { this.link.removeClass('waiting'); },
  finished: function () {
    this.link.remove();
    this.catcher.show();
    $$('a.autolink', this.catcher).each( function (a) { new AutoLink(a); });
  },
  failed: function () {
    this.notWaiting();
    this.catcher.remove();
    this.link.show();
  }
});

var Toggle = new Class({
  Extends: AutoLink,
  method: function () {
    return this.ticked() ? 'DELETE' : 'POST';
  },
  finished: function () {
    this.notWaiting();
    if (this.link.hasClass('ticked')) {
      this.link.removeClass('ticked');
      this.link.addClass('crossed');
    } else {
      this.link.removeClass('crossed');
      this.link.addClass('ticked');
    }
  },
  ticked: function () {
    return this.link.hasClass('ticked');
  }
});

var interface = null;

window.addEvent('domready', function(){
  interface = new Interface();
  interface.activate();
	window.addEvent('scroll', function (e) { interface.moveFixed(e); });
	window.addEvent('resize', function (e) { interface.moveFixed(e); });
});

var Interface = new Class({
	initialize: function(){
    this.dragging = false;
    this.commenting = false;
    this.commentator = new Commentator;
    this.draggables = [];
    this.droppers = [];
    this.tabs = [];
    this.tabsets = {};
    this.fixedbottom = [];
    this.clickthreshold = 6;
    this.cloud = null;
    this.notifyfx = null;
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
  startDragging: function (element) {
    console.log('startDragging');
    this.commentator.hide();
    $ES('.hideondrag').each(function (element) { element.hide(); })
    $ES('.showondrag').each(function (element) { element.show(); })
    this.tabs.each(function (t) { t.makeReceptiveTo(element); })
    var catchers = [];
  	this.droppers.each(function(d){ if (d.makeReceptiveTo(element)) catchers.push(d.container); });
  	return catchers;        // returns list of elements ready to receive drop, suitable for initializing draggable
  },
  stopDragging: function () {
    console.log('stopDragging');
    this.dragging = false;
    this.tabs.each(function (t) { t.makeUnreceptive(); })
  	this.droppers.each(function (d) { d.makeUnreceptive() })
    $ES('.showondrag').each(function (element) { element.hide(); })
    $ES('.hideondrag').each(function (element) { element.show(); })
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
  makeExpandable: function (elements) {
    var intf = this; 
    elements.each(function (element) { 
      element.addEvent('mouseenter', function (event) { interface.commentator.explain(element, event); });
      element.addEvent('mouseleave', function (e) { intf.commentator.startDown(); });
    });
  },
  makeFixed: function (elements) {
    var intf = this; elements.each(function (element) { intf.fixedbottom.push(element); });
  },
    
  // this is the main page initialisation routine: it gets called on domready
  
  activate: function (element) {
    var scope = element || null;
	  this.addDropzones($ES('.catcher', scope));
	  this.addTrashDropzones($ES('.trashdrop', scope));
	  this.makeDraggable($ES('.draggable', scope));
	  this.makeExpandable($ES('.expandable', scope));
	  if (scope) {
	    if (scope.hasClass('catcher')) this.addDropzones([scope]);
  	  if (scope.hasClass('trashdrop')) this.addTrashDropzones([scope]);
  	  if (scope.hasClass('draggable')) this.makeDraggable([scope]);
  	  if (scope.hasClass('expandable')) this.makeExpandable([scope]);
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

var Commentator = new Class({
	initialize: function(){
		this.container = new Element('div', { 'class': 'commentator' }).injectInside(document.body);
		this.textholder = new Element('div', { 'class': 'commentatorbody' }).injectInside(this.container);
		this.footer = new Element('div', { 'class': 'commentatorfoot' }).injectInside(this.container);
		this.container.addEvent('mouseenter', function (e) { interface.commentator.cancelDown(e) });
		this.container.addEvent('mouseleave', function (e) { interface.commentator.startDown(e) });
		this.downTimer = null;
		this.explaining = null;
	},
	explain: function (element, event) {
    this.cancelDown();
    if (! interface.dragging) {
      var position = element.getCoordinates();
      var explanation = $E('div.expansion', element);
      if (explanation) {
        this.explaining = element;
        this.moveto(position.top + 8, position.left + parseInt(position.width * 2 / 3));
        this.display(explanation.clone());
        this.show();
      }
    }
	},
	display: function (elements) {
    this.textholder.empty();
    if (elements) elements.injectInside(this.textholder);
	},
	clear: function () {
    this.display();
	},
  moveto: function (top, left) {
    this.container.setStyles({'top': top-23, 'left': left});
  },
  
  // give the mouse time to move into another area that raised the same comment, or over to the commentary itself
  
  startDown: function (event) {
    this.downTimer = window.setTimeout(function () { interface.commentator.hide(); }, 300);
  },
  cancelDown: function (event) {
    if (this.downTimer) window.clearTimeout(this.downTimer);
  },
  show: function () {
    this.container.show();
  },
  hide: function () {
    this.container.hide();
  }
});

var Dropzone = new Class({
	initialize: function (element) {
    // console.log('new dropzone: ' + element.id);
		this.container = element;
	  this.tag = element.id;
		this.container.dropzone = this;   // when a draggee is picked up we climb the tree to see if it is being dragged from somewhere
		this.isReceptive = false;
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
  			},
  			leave: function() { 
  			  dropzone.loseInterest(helper);
  			}
  		});
  		return this.isReceptive = true;
    } else {
  		return this.isReceptive = false;
    }
	},
	makeUnreceptive: function () { 
	  if (this.isReceptive) {
  	  this.container.removeEvents('over');
  	  this.container.removeEvents('leave');
  	  this.container.removeEvents('drop');
  		this.isReceptive = false;
	  }
	},
	showInterest: function (helper) { 
	  if (this != helper.draggee.draggedfrom && !this.contains(helper.draggee)) {
  	  this.container.addClass('drophere');
  	  helper.droppable(); 
	  }
	},
	loseInterest: function (helper) { 
	   this.container.removeClass('drophere');
     helper.notDroppable(); 
	},
	receiveDrop: function (helper) {
		dropzone = this;
		dropzone.loseInterest(helper);
		draggee = helper.draggee;
		if (dropzone == draggee.draggedfrom) {
			helper.flyback();
			
		} else if (dropzone.contains(draggee)) {
			interface.complain('already there');
			helper.flyback();
			
		} else {
			helper.remove();
			
			var req = new Ajax(this.addURL(draggee), {
				method: 'get',
			  onRequest: function () { dropzone.waiting(); },
        onSuccess: function(response){
          var outcome = new Outcome(response);
          console.log('status = ' + outcome.status + ', message = ' + outcome.message + ', consequence = ' + outcome.consequence);
          if (outcome.status == 'success') {
            dropzone.notWaiting();
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
			    dropzone.showFailure();
			    interface.complain('remote call failed');
			  }
			}).request();
			console.log('drop received');
		}
  },
	removeDrop: function (draggee) {
		dropzone = this;
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
	  this.container.addClass('drophere');
	  helper.deleteable(); 
	},
	loseInterest: function (helper) { 
	  helper.notDeleteable(); 
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
		this.name = this.link.getText();
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

var DragHelper = new Class({
	initialize: function(draggee){
	  this.draggee = draggee;
		this.container = new Element('div', { 'class': 'dragging' }).injectInside(document.body);
		this.textholder = new Element('div', { 'class': 'draggingbody' }).injectInside(this.container);
		this.footer = new Element('div', { 'class': 'draggingfoot' }).injectInside(this.container);
		draggee.original.clone().injectInside(this.textholder);
		this.startingfrom = {};
	},
	start: function (event) {
	  event.stop();
	  event.preventDefault();
		var helper = this;
	  var offsetY = this.container.getCoordinates().height;
	  var offsetX = 124;
	  this.startingfrom.left = event.page.x - offsetX;
	  this.startingfrom.top = event.page.y - offsetY;
		this.moveto(this.startingfrom.top, this.startingfrom.left);
		this.container.addEvent('emptydrop', function() { helper.emptydrop(); })
		this.show();
		this.container.makeDraggable({ 
			droppables: interface.startDragging(this) // returns list of activated dropzones.
		}).start(event);
	},
	emptydrop: function () {
		interface.stopDragging();
		if (!this.hasMoved) {
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
    this.container.effects({ duration: 600, transition: Fx.Transitions.Back.easeOut }).start(this.startingfrom).chain(function(){ helper.remove() });
	},
	moveto: function (top, left) {
    this.container.setStyles({'top': top, 'left': left});
	},
	hasMoved: function () {
		var now = this.container.getCoordinates();
		return Math.abs(this.startingfrom.left - now.left) + Math.abs(this.startingfrom.top - now.top) >= interface.clickthreshold;
	},
  show: function () { this.container.show(); },
  hide: function () { this.container.hide(); },
	remove: function () { this.container.remove(); },
	explode: function () { this.remove(); },  // something more vivid should happen here
	disappear: function () { this.original.dwindle(); },
	deleteable: function () { this.container.addClass('deleteable');},
	droppable: function () { this.container.addClass('insertable');},
	notDroppable: function () { this.container.removeClass('insertable');},
	notDeleteable: function () { this.container.removeClass('deleteable');}
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
	},
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
    var bodyholder = new Element('div', {class: "temporary"}).injectInside($E('body'));
    var tabs = this;
    var workingtab = new Element('a', {class: 'padtab red', href: "#"}).setText('working').injectInside(this.headcontainer);
		var req = new Ajax(e.target.getProperty('href'), {
			method: 'get',
			update: bodyholder,
		  onSuccess: function (response) { 
    		var newbody = $E('div.scratchpage', bodyholder);
    		var tabid = newbody.spokeID();
        var newhead = new Element('a', {class: 'padtab', href: "#", id: "tab_scratchpad_" + tabid}).setText('new pad');
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


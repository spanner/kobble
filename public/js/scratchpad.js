var Dropzone = new Class({
	initialize: function (element) {
    // console.log('new dropzone: ' + element.id);
	  this.tag = element.id;
		this.container = element;
		this.waiter = $E('div.waiting', element);
		if (this.waiter) this.waiter.hide();
		this.container.dropzone = this;   // used to work out whether we've dragged into a new place
		this.isreceptive = false;
		this.receiptAction = 'add';
		this.removeAction = 'remove';
  },
	recipient: function () { return this.container; },
	flasher: function () { return this.container; },
	contents: function () { return $ES('.draggable', this.container).map(function(el){ return el.id; }); },
	contains: function (draggee) { 
	  return this.contents().contains(draggee.tag); 
	},
	makeReceptiveTo: function (draggee) {
		var dropzone = this;
		this.container.addEvents({
			'drop': function() { sleepDroppers(); dropzone.receiveDrop(draggee); },
			'over': function() { dropzone.showInterest(draggee); },
			'leave': function() { dropzone.loseInterest(draggee); }
		});
		return this.container;
	},
	makeUnreceptive: function () { 
	  this.container.removeEvents('over');
	  this.container.removeEvents('leave');
	  this.container.removeEvents('drop');
	},
	showInterest: function (draggee) { 
	  this.container.addClass('drophere');
	  draggee.appearance(draggee.origin == this ? 'normal' : 'droppable'); 
	},
	loseInterest: function (draggee) { 
	   this.container.removeClass('drophere');
     draggee.appearance(draggee.origin ? 'deletable' : 'normal'); 
	},
	receiveDrop: function (draggee) {
    // console.log('receiveDrop(' + draggee.tag + ')');
		dropzone = this;
		dropzone.loseInterest(draggee);
    // console.log('letting go(' + draggee.tag + ')');
		if (dropzone == draggee.origin) {
			draggee.release();
			
		} else if (dropzone.contains(draggee)) {
			error('already there');
			draggee.release();
			
		} else {
  	  // console.log('disappearing clone(' + draggee.tag + ')');
			draggee.disappear();
      // console.log('ajax call(' + draggee.tag + ')');
			new Ajax(this.addURL(), {
				method: 'get',
				data: { 'scrap': draggee.tag, 'display': display },
        update: this.recipient(),
			  onRequest: function () { 
			    dropzone.waiting(); 
			  },
			  onComplete: function () { 
			    dropzone.notWaiting();
				  $ES('.draggable', dropzone.recipient()).each(function(item) { item.addEvent('mousedown', function(e) { new Draggee(this, new Event(e)); }); });
          dropzone.showSuccess();
				},
			  onFailure: function () { 
			    dropzone.notWaiting(); 
			    error('ajax call failed');
			    dropzone.showFailure();
			  }
			}).request();
		}
  },
	removeDrop: function (draggee) {
    // console.log('removedrop');
		dropzone = this;
    draggee.disappear();
		new Ajax(dropzone.removeURL(), {
			method : 'post',
			data : { 'scrap': draggee.tag },
		  onRequest: function () { dropzone.draggeeWaiting(draggee); },
		  onSuccess: function () { announce(this.response.text); dropzone.draggeeRemove(draggee); dropzone.showSuccess(); },
		  onFailure: function () { dropzone.draggeeNotWaiting(); }
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
	waiting: function () { 
    // console.log('dropzone.waiting')
    this.waiter = $E('div.waiting', this.container);
	  if (this.waiter) this.waiter.show();
	},
	notWaiting: function () { 
    // console.log('dropzone.notWaiting(' + this.tag + ')')
	  this.waiter = $E('div.waiting', this.container);
	  if (this.waiter) this.waiter.hide();
	},
	// by default we use the signalwith image (first image in the draggee) to display a spinner
	// scratchpages override this to use list styles instead
	draggeeWaiting: function (draggee) {
	  draggee.presignal = draggee.signalwith.getProperty('src');
    draggee.signalwith.setProperty('src', '/images/furniture/signals/wait_32_grey.gif');
	},
	draggeeNotWaiting: function (draggee) {
    draggee.signalwith.setProperty('src', draggee.presignal);
	},
	draggeeRemove: function (draggee) {
    draggee.explode(draggee.container.getParent());
	},
	showSuccess: function () {
	  flash(this.flasher());
	},
	showFailure: function () {

	}
});

var SetDropzone = Dropzone.extend({
	recipient: function () { return $E('div.dropcontents', this.container); },
	tabset: function () {
	  return tabsets['content'];    // generalise this when you redo droppers
	},
	showSuccess: function () {
	  flash(this.flasher());
	  console.log(this.tabset);
	  if (this.tabset()) this.tabset().resize();
	}
});

var PadDropzone = Dropzone.extend({
	initialize: function(element){
		this.parent(element);
		this.foreground = null;
		this.isopen = false;
		this.wasopen = false;
		this.pages = {};
		this.allpages = [];
		this.addPages($ES('div.scratchpage'), this.container);
		var openFX = this.container.effects({duration: 600, transition: Fx.Transitions.Cubic.easeOut});
		var closeFX = this.container.effects({duration: 1000, transition: Fx.Transitions.Bounce.easeOut});
		this.container.addEvents({
      'expand' : function() { 
        openFX.start({
          'top': window.getScrollTop() + 10,
          'height': window.getHeight() - 10
        });
      },
      'contract' : function() { 
        closeFX.start({
          'top': window.getScrollTop() + window.getHeight() - 34, 
          'height': 34
        }); 
      }
    });
	},
	recipient: function () { return this.foreground.list; },
	flasher: function () { return this.foreground.flasher(); },
	addURL: function (argument) { return '/scratchpads/add/' + this.foreground.spokeID; },
	removeURL: function (argument) { return '/scratchpads/remove/' + this.foreground.spokeID; },
	contents: function () { return this.foreground.contents(); },
  addPages: function(elements){
		var pad = this;
	  elements.each(function(element){
			pad.pages[element.id] = new Scratchpage($(element));
			pad.allpages.push(pad.pages[element.id])
	    if (!pad.foreground) pad.foreground = pad.pages[element.id].makeForeground();
		});
  },
	tabClick: function (tag) {
    // console.log('tabclick: ' + tag);
    // console.log('foreground is: ' + this.foreground.tag);
		if (tag == this.foreground.tag) {
			this.toggle();
		} else {
		  if(!this.isopen) this.open();
			this.choosePage(tag);
		}
	},
  choosePage: function (tag) {
    // console.log('choosePage: ' + tag);
    this.allpages.each(function (p) { p.makeBackground(); })
  	this.foreground = this.pages[tag].makeForeground();
	},
	showInterest: function (draggee) { 
	  if (this != draggee.origin) {
  	  if (!this.isopen) this.open();
  	  this.foreground.showInterest();
  	  draggee.origin ? draggee.lookDroppable() : draggee.lookNormal();
	  }
	},
	loseInterest: function (draggee) { 
	  this.foreground.loseInterest();
	  draggee.origin == this ? draggee.lookNormal : draggee.lookDroppable();
	},
	open: function (delay) {
    this.container.fireEvent('expand', null, delay);
    this.isopen = true;
	},
	close: function (delay) {
    this.container.fireEvent('contract', null, delay); 
    this.isopen = false;
	},
	toggle: function (delay) {
    this.isopen ? this.close(delay) : this.open(delay);
	},
	showRename: function (pageid, url) {
    this.pages[pageid].showRename(url);
	},
	draggeeWaiting: function (draggee) {
	  draggee.container.addClass('waiting');
	},	
	draggeeNotWaiting: function (draggee) {
	  draggee.container.removeClass('waiting');
	},
	draggeeRemove: function (draggee) {
    draggee.explode(draggee.container);
	},
	waiting: function () { 
    // console.log('padDropzone.waiting')
	  this.foreground.waiting();
	},
	notWaiting: function () { 
	  this.foreground.notWaiting();
	},
	clearPage: function (e, url) {
	  this.foreground.clearPage(url);
  },
	deletePage: function (e, url) {
	  this.foreground.deletePage(url);
	},
	showSuccess: function () {
	  flash(this.flasher(), '695D54');
	}
});

var Scratchpage = new Class({
	initialize: function(element){
    // console.log('initialize: ' + element.id);
		this.container = element;
		this.spokeID = idParts(element)['id'];
		this.tag = element.id;
		this.list = $E('ul', element);
		this.waiter = null;
		this.tab = $E('a#tab_' + this.tag);
		this.tab.onclick = this.tabclick.bind(this);
		this.renameform = null;
    this.formholder = new Element('div', {'class': 'renameform bigspinner', 'style': 'height: 0'}).injectBefore(this.container).hide();
    this.renamefx = new Fx.Style(this.formholder, 'height', {duration:1000});
	},
	flasher: function(){ return this.container; },
  makeForeground: function(){
    // console.log('makeForeground: ' + this.tag);
    this.container.show();
    this.hideRename();
    this.tab.addClass('fg');
    return this;
  },
	makeBackground: function () {
    // console.log('makeBackground: ' + this.tag);
    this.hideRename();
    this.container.hide();
    this.tab.removeClass('fg');
    this.hideRename();
    return this;
	},
	tabclick: function (e) {
	  e = new Event(e).stop();
		e.preventDefault();
		scratchpad.tabClick(this.tag); 
	},
	contents: function () { 
	  return this.list.getChildren().map(function(el){ return el.id.replace('padded_',''); }); 
	},
	showRename: function (url) {
	  var scratchpage = this;
    this.tab.addClass('editing');
    this.formholder.show();
    if (! this.renameform) {
  	  this.renamefx.start(64);
  		new Ajax(url, {
  			method: 'get',
  			update: scratchpage.formholder,
  		  onSuccess: function () { scratchpage.bindRenameForm() },
  		  onFailure: function () { scratchpage.hideRenameNicely(); error('no way'); }
  		}).request();
    }
	},
	hideRenameNicely: function (e) {
    if (e) e = new Event(e).stop();
    var sp = this;
	  this.renamefx.start(0).chain(function () { sp.hideRename(e) });
	},
	hideRename: function (e) {
    if (e) e = new Event(e).stop();
    this.formholder.hide();
    this.tab.removeClass('editing');
	},
	bindRenameForm: function () {
    this.formholder.removeClass('bigspinner');
    this.formholder.show();
    this.renameform = $E('form', this.formholder);
		this.renameform.onsubmit = this.doRename.bind(this);
		$E('a.cancel_rename', this.renameform).onclick = this.hideRename.bind(this);
		$E('input', this.renameform).focus();
	},
	doRename: function (e) {
	  e = new Event(e).stop();
	  e.preventDefault();
	  var scratchpage = this;
    this.renameform.hide();
    this.formholder.addClass('bigspinner');
	  this.renameform.send({
      method: 'post',
      update: this.tab,
      onComplete: function () { scratchpage.hideRenameNicely(); }
	  });
	},
	clearPage: function (url) {
    if (confirm('are you sure you want to remove everything from this scratchpad?')) {
  	  var scratchpage = this;
  		new Ajax(url, {
  			method: 'get',
  			update: scratchpage.list,
  			onRequest: function () { $ES('li', scratchpage.list).each(function (el) { el.addClass('waiting')}) },
  			onSuccess: function () { flash(scratchpage.flasher(), '695D54') },
  			onFailure: function () { $ES('li', scratchpage.list).each(function (el) { el.removeClass('waiting')}) }
  		}).request();
    }
	},
	deletePage: function (e) {
    // body...
	},
	showInterest: function () {
    this.tab.addClass('receptive');
    this.container.addClass('receptive');
	},
	loseInterest: function () {
    this.tab.removeClass('receptive');
    this.container.removeClass('receptive');
	},
	waiting: function () {
		this.waiter = new Element('li', {'class': 'waiting'}).setText('please wait').injectTop(this.list);
	},
	notWaiting: function () {
    if (this.waiter && this.waiter.type) this.waiter.remove();
	}
});

var Draggee = new Class({
	initialize: function(element, event){
    event.stop();
	  event.preventDefault();
		this.original = $E('div.thumb', element);
		if (!this.original) this.original = element;
		this.container = element;
		var ip = idParts(element);
		this.tag = ip['type'] + '_' + ip['id'];   //omitting other id parts that only serve to avoid duplicate ids
		this.link = $E('a', element);
		this.backto = element.getCoordinates();
		this.origin = lookForDropper(element);
		this.imgsrc = $E('img.icon', element).getProperty('src');
		this.signalwith = $E('img', element);
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
			droppables: wakeDroppers(draggee) // returns list of activated droppers. activating them sets up drop triggers
		}).start(event);
	},
	removeIfDraggedOut: function () {
		this.origin ? this.origin.removeDrop(this) : this.release();
	},
	disappear: function () {
		if (this.clone) this.clone.remove();
	},
	explode: function (removed) {
    // console.log('explode')
	  new Fx.Styles(removed, {
			duration:600
		}).start({ 
			'opacity': 0,
			'width': 0,
			'height': 0
		}).chain(function () {
      removed.remove();
		});
	},
	remove: function () {
	  this.original.remove();
	},
	release: function () {
	  this.lookNormal();
		this.moved() ? this.flyback() : this.doClick();
	},
	moved: function () {
		var now = this.clone.getCoordinates();
		return Math.abs(this.backto['left'] - now['left']) + Math.abs(this.backto['top'] - now['top']) >= clickthreshold;
	},
	flyback: function () {
		draggee = this;
		if (this.clone) this.clone.effects({
		  duration: 400, 
		  transition:Fx.Transitions.Back.easeOut
		}).start(draggee.backto).chain(function(){ draggee.disappear() });
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
	waiting: function () { this.appearance('waiting') },
	notWaiting: function () { this.appearance('normal') },
	lookNormal: function () { this.appearance('normal') },
	lookDroppable: function () { this.appearance('droppable') },
	lookDeletable: function () { this.appearance('deletable') }
});










function wakeDroppers (draggee) {
  // console.log('wakeDroppers(' + draggee.tag + ')');
	return droppers.map(function(d){ return d.makeReceptiveTo(draggee); });
}

function sleepDroppers () {
  // console.log('sleepDroppers');
	droppers.each(function (d) { d.makeUnreceptive() })
}

function lookForDropper (element) {
	if (element.dropzone) {
		return element.dropzone;
	} else {
  	var p = element.getParent();
	  if (p && p.getParent) {
		  return lookForDropper( p );
	  } else {
		  return null;
	  }
  }
}

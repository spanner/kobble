var Dropzone = new Class({
	initialize: function (element) {
    // console.log('new dropzone: ' + element.id);
		this.container = element;
	  this.tag = element.id;
		this.waiter = $E('div.waiting', element);
		if (this.waiter) this.waiter.hide();
		this.container.dropzone = this;   // used to work out whether we've dragged into a new place
		this.isreceptive = false;
		this.receiptAction = 'catch';
		this.removeAction = 'drop';
  },
  spokeID: function () { return idParts(this.container)['id']; },
  spokeType: function () { return idParts(this.container)['type']; },
	recipient: function () { return this.container; },
	flasher: function () { return this.container; },
	contents: function () { return $ES('.draggable', this.container).map(function(el){ return el.id; }); },
	contains: function (draggee) { 
	  return this.contents().contains(draggee.tag); 
	},
	makeReceptiveTo: function (draggee) {
		var dropzone = this;
		this.container.addEvents({
			drop: function() { sleepDroppers(); dropzone.receiveDrop(draggee); },
			over: function() { dropzone.showInterest(draggee); },
			leave: function() { dropzone.loseInterest(draggee); }
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
	  draggee.appearance(draggee.draggedfrom == this ? 'normal' : 'droppable'); 
	},
	loseInterest: function (draggee) { 
	   this.container.removeClass('drophere');
     draggee.appearance(draggee.draggedfrom ? 'deletable' : 'normal'); 
	},
	receiveDrop: function (draggee) {
    // console.log('receiveDrop(' + draggee.tag + ')');
		dropzone = this;
		dropzone.loseInterest(draggee);
    // console.log('letting go(' + draggee.tag + ')');
		if (dropzone == draggee.draggedfrom) {
			draggee.release();
			
		} else if (dropzone.contains(draggee)) {
			error('already there');
			draggee.release();
			
		} else {
  	  // console.log('disappearing clone(' + draggee.tag + ')');
			draggee.disappear();
      // console.log('ajax call(' + draggee.tag + ')');
			var req = new Ajax(this.addURL(draggee), {
				method: 'get',
			  onRequest: function () { 
			    dropzone.waiting(); 
			  },
        onSuccess: function(response){
          dropzone.notWaiting();
          console.log(response);
          if (response.successful) {
            dropzone.showSuccess();
            confirm(response.message);
          } else {
    		    dropzone.showFailure();
            error(response.message);
          }
        },
			  onFailure: function (response) { 
			    dropzone.notWaiting(); 
          console.log(response)
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
		new Ajax(dropzone.removeURL(draggee), {
			method : 'post',
		  onRequest: function () { dropzone.draggeeWaiting(draggee); },
		  onSuccess: function () { announce(this.response.text); dropzone.draggeeRemove(draggee); dropzone.showSuccess(); },
		  onFailure: function () { dropzone.draggeeNotWaiting(); }
		}).request();
	},
	addURL: function (draggee) { 
		return '/' + this.spokeType() + 's/' + this.receiptAction + '/' + this.spokeID() + '/' + draggee.spokeType() + '/' + draggee.spokeID();  
	},
	removeURL: function (draggee) { 
		return '/' + this.spokeType() + 's/' + this.removeAction + '/' + this.spokeID() + '/' + draggee.spokeType() + '/' + draggee.spokeID(); 
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









// now we always drag whole <li> elements. no more thumbnail representation

var Draggee = new Class({
	initialize: function(element, event){
    event.stop();
	  event.preventDefault();
		this.original = element;
		var ip = idParts(element);
		this.tag = ip['type'] + '_' + ip['id'];   //omitting other id parts that only serve to avoid duplicate element ids
		this.link = $E('a', element);
		this.flybackto = element.getCoordinates();
		this.clickpoint = {'top': event.page.y-25, 'left': event.page.x-75}
		this.draggedfrom = lookForDropper(element.getParent());
		draggee = this;
		
		this.clone = this.original.clone()
		  .addClass('dragging')
		  .setStyles(this.clickpoint)
			.addEvent('emptydrop', function() { 
				sleepDroppers();
				draggee.removeIfDraggedOut();
			})
			.inject(document.body);
		
		this.clone.makeDraggable({ 
			droppables: wakeDroppers(draggee) // returns list of activated droppers. activating them sets up drop triggers
		}).start(event);
	},
  spokeID: function () { return idParts(this.original)['id']; },
  spokeType: function () { return idParts(this.original)['type']; },
	removeIfDraggedOut: function () {
		this.draggedfrom ? this.draggedfrom.removeDrop(this) : this.release();
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
		return Math.abs(this.clickpoint['left'] - now['left']) + Math.abs(this.clickpoint['top'] - now['top']) >= clickthreshold;
	},
	flyback: function () {
		draggee = this;
		if (this.clone) this.clone.effects({
		  duration: 600, 
		  transition:Fx.Transitions.Back.easeOut
		}).start(draggee.flybackto).chain(function(){ draggee.disappear() });
	},
	doClick: function (e) {
		this.disappear();
		window.location = this.link.href;
	},
	appearance: function (signal) {
		switch (signal){
			case 'waiting': 
				this.clone.addClass('waiting');
				break;
			case 'droppable': 
			  this.clone.addClass('droppable');
			  break
			case 'deletable': 
			  this.clone.addClass('deletable');
				break;
			default: 
	      this.clone.removeClass('waiting');
	      this.clone.removeClass('droppable');
		    this.clone.removeClass('deletable');
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
  if (element) {
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
}

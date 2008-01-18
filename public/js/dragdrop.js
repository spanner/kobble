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
    if (this.zoneType() == 'list') draggee.clone().injectInside(this.container);
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

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
  spokeID: function () { return idParts(this.container)['id']; },
  spokeType: function () { return idParts(this.container)['type']; },
	recipient: function () { return this.container; },
	flasher: function () { return this.container; },
	contents: function () { return $ES('.draggable', this.container).map(function(el){ return el.id; }); },
	contains: function (draggee) { return this.contents().contains(draggee.tag); },
	can_catch: function (type) { if (this.catches) { return this.catches.split(',').contains(type); }; },
	makeReceptiveTo: function (helper) {
	  type = helper.draggee.spokeType();
	  if (this.can_catch(type)) {
  		var dropzone = this;
  		dropzone.container.addEvents({
  			drop: function() { stopDragging(); dropzone.receiveDrop(helper); },
  			over: function() { dropzone.showInterest(helper); },
  			leave: function() { dropzone.loseInterest(helper); }
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
	  console.log('showinterest');
	  this.container.addClass('drophere');
	},
	loseInterest: function (helper) { 
	   this.container.removeClass('drophere');
	},
	receiveDrop: function (helper) {
		dropzone = this;
		console.log('dropped on ' + this.spokeType() + '/' + this.spokeID());
		dropzone.loseInterest(helper);
		draggee = helper.draggee;
		if (dropzone == draggee.draggedfrom) {
			helper.flyback();
			
		} else if (dropzone.contains(draggee)) {
			error('already there');
			helper.flyback();
			
		} else {
			helper.remove();
			
			var req = new Ajax(this.addURL(draggee), {
				method: 'get',
			  onRequest: function () { 
			    dropzone.waiting(); 
			  },
        onSuccess: function(response){
          
          // fix this
          
          var parts = response.split('|');
          var status = parts[0];
          var message = parts[1];
          var consequence = parts[2];
          console.log('status = ' + status + ', message = ' + message + ', consequence = ' + consequence);
          if (status == 'success') {
            dropzone.notWaiting();
            dropzone.showSuccess();
            if (consequence == 'move' || consequence == 'insert') dropzone.accept(draggee);
            if (consequence == 'move' || consequence == 'delete') draggee.disappear();
            announce(message);
          } else {
    		    dropzone.showFailure();
            error(message);
          }
        },
			  onFailure: function (response) { 
			    dropzone.notWaiting(); 
			    dropzone.showFailure();
			    error('remote call failed');
			  }
			}).request();
			console.log('drop received');
		}
  },
	removeDrop: function (draggee) {
    // console.log('removedrop');
		dropzone = this;
		new Ajax(dropzone.removeURL(draggee), {
			method : 'post',
		  onRequest: function () { 
		    draggee.waiting(); 
		  },
		  onSuccess: function (response) { 
        var parts = response.split('|');
        var status = parts[0];
        var message = parts[1];
        var consequence = parts[2];
        if (status == 'success') {
		      announce(message); 
          draggee.disappear(); 
		    } else {
			    dropzone.showFailure();
          error(message);
		    }
		  },
		  onFailure: function (response) {
		    dropzone.showFailure();
		    error('remote call failed');
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
    this.waitSignal = new Element('li', { 'class': 'waiting hide' }).setText('hold on...').injectInside(this.container);
    return this.waitSignal;
	},
	waiting: function () {
	  if (this.zoneType() == 'list') {
  	  if (this.waiter()) this.waiter().show();
	  } else {
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
	  flash(this.flasher());
	},
	showFailure: function () {

	},
	accept: function (draggee) {
    if (this.zoneType() == 'list') draggee.clone().injectInside(this.container);
	}
});


var TrashDropZone = Dropzone.extend({
	initialize: function () { 
    this.parent();
    this.receiptAction = 'trash';
	},
})




// now we always drag whole <li> elements. no more thumbnails.

var Draggee = new Class({
	initialize: function(element, event){
    event.stop();
	  event.preventDefault();
		this.original = element;
		var ip = idParts(element);
		this.tag = ip['type'] + '_' + ip['id'];   //omitting other id parts that only serve to avoid duplicate element ids
		this.link = $E('a', element);
		this.name = this.link.getText();
		this.draggedfrom = lookForDropper(element.getParent());
		this.helper = new DragHelper(this);
		this.helper.start(event);
	},
  spokeID: function () { return idParts(this.original)['id']; },
  spokeType: function () { return idParts(this.original)['type']; },
	doClick: function (e) { window.location = this.link.href; },    // this.link.fireEvent('click')?
	draggedOut: function () { if (this.draggedfrom) this.draggedfrom.removeDrop(this) },
	waiting: function () { this.original.addClass('waiting'); },
	notWaiting: function () { this.original.removeClass('waiting'); },
	remove: function () { this.original.remove(); },
	explode: function () { this.remove(); },
	disappear: function () { console.log('disappearing' + this.name); dwindle(this.original); },
	clone: function () { return this.original.clone();	}
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
			droppables: startDragging(this) // returns list of activated dropzones.
		}).start(event);
	},
	emptydrop: function () {
		stopDragging();
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
    this.container.effects({ duration: 600, transition: Fx.Transitions.Back.easeOut }).start(this.startingfrom)
    .chain(function(){ helper.remove() });
	},
	moveto: function (top, left) {
    this.container.setStyles({'top': top, 'left': left});
	},
	hasMoved: function () {
		var now = this.container.getCoordinates();
		return Math.abs(this.startingfrom.left - now.left) + Math.abs(this.startingfrom.top - now.top) >= clickthreshold;
	},
  show: function () { this.container.show(); },
  hide: function () { this.container.hide(); },
	remove: function () { this.container.remove(); },
	explode: function () { this.remove(); },  // something more vivid should happen here
	disappear: function () { dwindle(this.original); }
});












function startDragging (element) {
  dragging = true;
  var catchers = [];
  commentator.hide();
  scratchtabs.each(function (t) { t.makeReceptiveTo(element); })
	droppers.each(function(d){ if (d.makeReceptiveTo(element)) catchers.push(d.container); });
	return catchers;
}

function stopDragging () {
  dragging = false;
  scratchtabs.each(function (t) { t.makeUnreceptive(); })
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

function dwindle (element) {
  new Fx.Styles(element, {
		duration:600
	}).start({ 
	  'opacity': 0, 
	  'width': 0, 
	  'height': 0 
	}).chain(function () {
    element.remove();
	});
}




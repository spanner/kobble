var hopper = null;              // hopper is the dragged representation. It's created in an Element.mousedown handler
var catchers = [];              // catcher is the processing object that handles dropped hoppers
var dropzones = [];             // dropzone is the Element that is set up by a catcher to detect the drop
var click_zone_radius = 20;     // drag and drop that moves less than this distance is considered a click

var enableCatchers = function (hopper) {
  catchers.each(function(catcher){ if (catcher.makeReceptiveTo(hopper)) dropzones.push(catcher.container); });
  return dropzones;
};

var disableCatchers = function (hopper) {
  catchers.each(function (catcher) { catcher.makeUnreceptive(); });
  dropzones = [];
};

var Catcher = new Class({
  Implements: Log,
  initialize: function (element) {
    this.container = element;
    this.tag = element.id;
    this.receiptAction = 'catch';
    this.catches = this.container.getProperty('catches');
    this.container.dropzone = this;   // when a draggee is picked up we climb the tree to see if it is being dragged from somewhere
    this.is_list = this.container.tagName == 'UL';
    catchers.push(this);
  },

  can_catch: function (klass) { if (this.catches) return this.catches == 'all' || this.catches.split(',').contains(klass); },
  contents: function () { return this.container.getElements('.draggable').map(function(el){ return el.kobbleTag(); }); },
  contains: function (tag) { return this.contents().contains(tag); },

  makeReceptiveTo: function (hopper) {
    if (this.can_catch(hopper.klass) && this != hopper.origin && !this.contains(hopper.tag)) {
      this.container.addClass('receptive');
      this.container.addEvents({
        'drop': this.receiveHopper.bind(this, hopper),
        'enter': this.showInterest.bind(this),
        'leave': this.loseInterest.bind(this)
      });
      return true;
    } else {
      return false;
    }
  },
  
  makeUnreceptive: function () {
    if (this.container && this.container.hasClass('receptive')) {
      this.container.removeClass('receptive'); 
      ['enter', 'leave', 'drop'].each(function (trigger) { this.container.removeEvents(trigger); }, this);  
    }
  },
    
  showInterest: function () { 
    this.container.addClass('drophere');
  },
  
  loseInterest: function () { 
    this.container.removeClass('drophere');
  },
          
  receiveHopper: function (hopper) {
    this.log('receiveHopper:', hopper);
    disableCatchers();
    this.loseInterest();

    if (this == hopper.from) {
      hopper.flyback();
      
    } else if (this.contains(hopper.tag)) {
      k.complain(hopper.cargo.name + ' is already in' + this.name);
      hopper.flyback();
      
    } else {
      new Request.JSON({
        url: this.urlToReceive(hopper.cargo),
        method: this.httpMethod(),
        onRequest: this.waiting.bind(this, hopper),
        onSuccess: this.dropComplete.bind(this, hopper),
        onFailure: this.dropFailed.bind(this, hopper)
      }).send();
    }
  },

  dropComplete: function (response, hopper) {
    hopper.hide();
    this.notWaiting();
    this.log('drop successful. response = ', response);
    if (response.insertion) this.assimilate(hopper); //*
    if (response.delete_original) hopper.original.disappear();
    if (response.message) k.announce(response.message);
    if (response.error) k.complain(response.error);
    hopper.remove();
  },

  dropFailed: function (response, hopper) { 
    hopper.hide();
    this.notWaiting();
    this.log('drop failed!');
    this.log('response = ', response);
    k.complain('remote call failed');
    hopper.remove();
  },
  
  urlToReceive: function (draggee) { 
    return '/' + this.spokeType() + 's/' + this.receiptAction + '/' + this.spokeID() + '/' + draggee.spokeType() + '/' + draggee.spokeID();  
    return "/markers/new?selection=node_13"
  },
  
  urlToRemove: function (draggee) { 
    return '/' + this.spokeType() + 's/' + this.removeAction + '/' + this.spokeID() + '/' + draggee.spokeType() + '/' + draggee.spokeID(); 
  },
  
  httpMethod: function () {
    return 'get';
  },
  
  waiting: function () {
    if (this.is_list) {
      this.waitSignal = new Element('li', { 'id': 'waiter', 'class': 'waiting' });
      this.waitSignal.set('text','working...');
      this.waitSignal.inject(this.container);
      return this.waitSignal;
    } else {
      this.container.addClass('waiting');
    }
  },
  
  notWaiting: function () { 
    if (this.waitSignal) this.waitSignal.destroy();
    this.container.removeClass('waiting');
  },
  
  assimilate: function (hopper) {
    if (this.is_list) {
      var li = new Element('li', {'class' : 'adopted'});
      li.grab(hopper.cargo).inject(this.container);
      k.activate(li);
    }
  }
});

// the dragged representation is a Hopper object with useful abilities

var Hopper = new Class({
  initialize: function(element, e){
    k.block(e);
    this.original = element;
    this.cargo = element.clone();
    this.cargo.set('text', '1');
    this.klass = element.kobbleKlass();
    this.tag = element.kobbleTag();
    this.notaclick = false;
    
    this.container = new Element('div', {'class': 'dragging', 'style' : 'display: none;'});
    this.container.grab(this.cargo).inject(document.body);
    this.startingpoint = { left : e.page.x - 10, top : e.page.y - 20 };
    this.container.setStyles(this.startingpoint);

    this.mover = this.container.makeDraggable({ 
      droppables: enableCatchers(this),
      snap: click_zone_radius,
      onSnap: this.reveal.bind(this),
      onDrop: function(element, catcher, e){ catcher ? catcher.fireEvent('drop', this, e) : this.emptydrop(); }.bind(this),        // dropzone events are declared in a closure 
      onEnter: function(element, catcher, e){ if (catcher) catcher.fireEvent('enter', this, e); },                                 // with the hopper in context
      onLeave: function(element, catcher, e){ if (catcher) catcher.fireEvent('leave', this, e); }                                  // so here we only need to fire them
    });
    
    this.mover.start(e);
  },
  reveal: function () {
    this.container.show();
    this.notaclick = true;
  },
  emptydrop: function () {
    disableCatchers();
    if (this.notaclick) this.flyback();
    else this.original.fireEvent('click');
  },
  flyback: function () {
    this.container.set('morph', { duration: 'long', transition: 'back:out', onComplete: this.remove.bind(this) });
    this.container.morph( $merge(this.startingpoint, {'opacity': 0.1}) );
  },
  show: function (event) { this.container.show(); },
  hide: function () { this.container.hide(); },
  remove: function () { this.container.destroy(); }
});







Element.implement({

  // set up the hopper initialization

  prepDraggable: function () {
    this.addEvent('mousedown', function(e) { 
      if (e.event.button != 2) new Hopper(this, k.block(e));
    }.bind(this));
  },

  // find a catcher around this element (usually on pickup but also possibly useful on drop)

  lookForCatcher: function () {
    if (this.catcher) return this.catcher;
    else if (this.getParent()) return this.getParent().lookForCatcher();
    else return null;
  }
});


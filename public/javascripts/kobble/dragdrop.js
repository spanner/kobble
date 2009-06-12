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
    this.klass = element.kobbleKlass();
    this.title = this.container.getProperty('title') || this.klass;
    this.catches = this.container.getProperty('catches');
    this.is_list = this.container.tagName == 'UL';
    this.waiter = null;
    this.container.dropzone = this;   // when a draggee is picked up we climb the tree to see if it is being dragged from somewhere
    this.container.addEvents({
      'catch': function (hopper) { this.receiveHopper(hopper); }.bind(this),
      'enter': this.showInterest.bind(this),
      'leave': this.loseInterest.bind(this)
    });
    
    catchers.push(this);
  },

  can_catch: function (klass) { if (this.catches) return this.catches == 'all' || this.catches.split(',').contains(klass); },
  contents: function () { return this.container.getElements('.draggable').map(function(el){ return el.kobbleTag(); }); },
  contains: function (tag) { return this.contents().contains(tag); },
  makeReceptiveTo: function (hopper) {
    if (this.can_catch(hopper.klass) && this != hopper.origin && !this.contains(hopper.tag)) {
      this.container.addClass('receptive');
      return true;
    } else {
      return false;
    }
  },
  makeUnreceptive: function () {
    this.container.removeClass('receptive'); 
  },
    
  showInterest: function () { this.container.addClass('drophere'); },
  loseInterest: function () { this.container.removeClass('drophere'); },

  catch_url: function (hopper) { 
    var parts = [this.container.pluralKobbleKlass(), this.container.kobbleID()];

    if (this.container.kobbleCollection()) {
      parts.unshift(this.container.kobbleCollection());
      parts.unshift('collections');
    }
    if (this.container.kobbleAssociation()) {
      parts.push(this.container.kobbleAssociation());
      
    } else if (this.klass == 'tag' || hopper.klass == 'tag') {
      parts.push('taggings');
      
    } else if (this.klass == 'bundle' || hopper.klass == 'bundle') {
      parts.push('bundlings');
      
    } else if (this.klass == 'user' || hopper.klass == 'user') {
      parts.push('sendings');
      
    }
    parts.unshift('');
    return parts.join('/');
  },
  
  drop_url: function () { 
    return this.tag.replace('_','/') + '?object=' + tag; 
  },

  receiveHopper: function (hopper) {
    disableCatchers();
    this.loseInterest(); 

    if (this == hopper.from) {
      hopper.flyback();
      
    } else if (this.contains(hopper.tag)) {
      k.complain(hopper.cargo.name + ' is already in' + this.name);
      hopper.flyback();
      
    } else {
      hopper.hide();
      this.success_message = hopper.title + " added to " + this.title;
      this.failure_message = hopper.title + " was not added to " + this.title;
      var request_options = {
        url: this.catch_url(hopper),
        onRequest: this.waiting.bind(this),
        onSuccess: this.dropComplete.bind(this),
        onFailure: this.dropFailed.bind(this)
      };
      if (this.is_list) request_options['update'] = this.container;
      new Request.HTML(request_options).post({object : hopper.tag});
    }
    hopper.drop();
    delete hopper;
  },

  dropComplete: function (response) {
    this.notWaiting();
    if (this.is_list) {
      this.container.getChildren().each(function (el) { k.activate(el); });
      if (collapser && this.container.lookForCollapsedParent()) collapser.redisplay();
      // scroll to new item?
    } else {
      this.container.highlight('#d1005d');
    }
    k.announce(this.success_message);
  },

  dropFailed: function (xhr) { 
    this.notWaiting();
    k.complain(this.failure_message);
  },
  
  actionFor: function (hopper) { 
    return this.action + '/' + hopper.taghopper;
  },
  
  httpMethod: function () {
    return 'get';
  },
  
  waiting: function () {
    if (this.is_list) {
      if (!this.waiter) {
        this.waiter = new Element('li', {'class': 'waiter'}).grab(new Element('a', {'class' : 'waiting'} ).set('text','working...'));
        this.waiter.inject(this.container);
      }
      this.waiter.show();
    } else {
      this.container.addClass('waiting');
    }
  },
  
  notWaiting: function () { 
    if (this.waiter) this.waiter.hide();
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
    this.klass = element.kobbleKlass();
    this.tag = element.kobbleTag();
    this.title = element.getProperty('title') || this.klass;
    this.notaclick = false;

    this.cargo = element.clone();
    this.cargo.set('text', '1');
    this.cargo.addClass(this.klass);
    
    this.container = new Element('div', {'class': 'dragging', 'style' : 'display: none;'});
    this.container.grab(this.cargo).inject(document.body);
    this.startingpoint = { left : e.page.x - 10, top : e.page.y - 20 };
    this.container.setStyles(this.startingpoint);

    this.mover = this.container.makeDraggable({ 
      droppables: enableCatchers(this),
      snap: click_zone_radius,
      onSnap: this.reveal.bind(this),
      onDrop: function(element, catcher, e){ catcher ? catcher.fireEvent('catch', this, e) : this.emptydrop(); }.bind(this),        // dropzone events are declared in a closure 
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
    this.container.set('morph', { duration: 'long', transition: 'back:out', onComplete: this.drop.bind(this) });
    this.container.morph( $merge(this.startingpoint, {'opacity': 0.1}) );
  },
  show: function (event) { this.container.show(); },
  hide: function () { this.container.hide(); },
  drop: function () { this.container.destroy(); }
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


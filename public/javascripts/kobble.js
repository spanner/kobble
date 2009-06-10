var SelfSelection = {
  getElementsIncludingSelf: function (selector) {
    var elements = this.getElements(selector);
    if (this.match && this.match(selector)) elements.push(this);
    return elements;
  }
};

var KobbleParameters = {
  idparts: function () {
      var parts = this.id.split('_');
      return {
        'id' : parts[parts.length-1],
        'type' : parts[parts.length-2],
        'context' : parts[parts.length-3]
      };
    },
  kobbleID: function () {
    return this.idparts().id;
  },
  kobbleKlass: function () {
    return this.idparts().type;
  },
  pluralKobbleKlass: function () {
		var type = this.idparts().type;
    switch (type ) {
      case 'person':
        return 'people';
      default:
        return type + 's';
    }
  },
  kobbleTag: function () {
    return this.kobbleKlass() + '_' + this.kobbleID();
  },
  
  // mootools has never been able to handle fixed elements in a scrolled page. d'oh!

  isFixed: function () {
    return this.getStyle('position') == 'fixed' || this.retrieve('pinnedByJS') || this.getParent() && this.getParent().isFixed();
  },
  getCoordinates: function(element){
  	if (isBody(this)) return this.getWindow().getCoordinates();
  	var position = this.getPosition(element), size = this.getSize();
  	var obj = {left: position.x, top: position.y, width: size.x, height: size.y};
    if (this.isFixed()) {
      var offset = window.getScroll();
      obj.left = obj.left + offset.x;
      obj.top = obj.top + offset.y;
    }
  	obj.right = obj.left + obj.width;
  	obj.bottom = obj.top + obj.height;
  	return obj;
  }
};

function isBody(element){
	return (/^(?:body|html)$/i).test(element.tagName);
};

Document.implement(SelfSelection);
Element.implement(SelfSelection);
Element.implement(KobbleParameters);


var k = null;

window.addEvent('domready', function(){
  // console.profile();
  k = new Kobble();
  k.activate();         // sometimes it needs to refer to itself.
  // console.profileEnd();    //in materialist: 65.38ms, 7517 calls
});

var Kobble = new Class({
  Implements: Log,
  initialize: function(){

    // errors and notices
    this.message_holder = null;
        
    // zoomy forms
    this.zoomlinks = [];
    this.floater = null;
    this.floaters = [];
    
    // logging control
    this.debug_level = 5;
  },

  // getElementsIncludingSelf calls getElements 
  // then adds the scope element to the beginning 
  // of the array if it too matches the selector
  
  activate: function (element) {
    var scope = element || document;
    // scope.getElementsIncludingSelf('div.fixed').each(function (el) { el.pin(); });
    scope.getElementsIncludingSelf('.catcher').each (function (el) { new Catcher(el); });
    scope.getElementsIncludingSelf('.draggable').each(function (el) { el.prepDraggable(); });
    // scope.getElementsIncludingSelf('input.tagbox').each(function (el) { new Suggester(el); });
    // scope.getElementsIncludingSelf('a.inline').each(function (el) { new Zoomer(el); });
    // scope.getElementsIncludingSelf('a.snipper').each(function (el) { new Zoomer(el, Snipper); });
    // scope.getElementsIncludingSelf('div.uploader').each( function (el) { new Uploader(element); });
    // if(scope.getElements('a.squeezebox')) new Collapser(scope.getElements('a.squeezebox'), scope.getElements('div.squeezed'));
  },
  
  // instantiates and stops the supplied event
  
  block: function (e) {
    if (e) {
      var event = new Event(e);
      event.preventDefault();
      return event;
    }
  },
  
  // rails flashes and other notifications
  
  announcer: function () {
    if (!this.message_holder) this.message_holder = new Element('div', {'class' : 'notification'}).inject(document.body);
    return this.message_holder;
  },
  announce: function (message, title) {
    this.announcer().removeClass('error');
    this.announcer().set('html', message);
  },
  complain: function (message, title) {
    this.announcer().addClass('error');
    this.announcer().set('html', message);
  },

  // selective logger
  
  debug: function (message, level) {
    if (!level) level = 2;
    this.log(message);
  }
    
});





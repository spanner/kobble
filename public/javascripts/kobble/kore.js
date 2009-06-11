var SelfSelection = {
  getElementsIncludingSelf: function (selector) {
    var elements = this.getElements(selector);
    if (this.match && this.match(selector)) elements.push(this);
    return elements;
  }
};

// all kobble DOM ids take the form controller_id[_association]
// not model not controller: must be singular
// eg node_16, node_16_tags, bundle_23_members, user_1_bookmarks

var KobbleParameters = {
  idparts: function () {
      var parts = this.id.split('_');
      return {
        'type' : parts[0],
        'id' : parts[1],
        'association' : parts[2]
      };
    },
  kobbleID: function () {
    return this.idparts().id;
  },
  kobbleKlass: function () {
    return this.idparts().type;
  },
  kobbleAssociation: function () {
    return this.idparts().association;
  },
  pluralKobbleKlass: function () {
		var type = this.idparts().type;
    switch (type ) {
      case 'person': return 'people';
      default: return type + 's';
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
  k.activate();
  if($$('a.squeezebox')) new Collapser($$('a.squeezebox'), $$('div.squeezed'));
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
    this.debug_level = 0;
  },

  // getElementsIncludingSelf calls getElements 
  // then adds the scope element to the beginning 
  // of the array if it too matches the selector
  
  activate: function (element) {
    var scope = element || document;
    scope.getElementsIncludingSelf('.catcher').each (function (el) { new Catcher(el); });
    scope.getElementsIncludingSelf('.draggable').each(function (el) { el.prepDraggable(); });
    scope.getElementsIncludingSelf('input.tagbox').each(function (el) { new Suggester(el); });
    scope.getElementsIncludingSelf('a.inline').each(function (el) { new Zoomer(el, 'JsonForm'); });
    scope.getElementsIncludingSelf('a.snipper').each(function (el) { new Snipper(el, 'Snipper'); });
    scope.getElementsIncludingSelf('div.uploader').each( function (el) { new Uploader(element); });
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
    if (!this.message_holder) this.message_holder = new Element('div', {'id' : 'notification'}).inject(document.body);
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





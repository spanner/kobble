var kobble_starters = [];
var k = null;

window.addEvent('domready', function(){
  // console.profile();
  k = new Kobble();
  k.activate();
  // console.profileEnd();    //in materialist: 65.38ms, 7517 calls
});



var SelfSelection = {
  getElementsIncludingSelf: function (selector) {
    var elements = this.getElements(selector);
    if (this.match && this.match(selector)) elements.push(this);
    return elements;
  }
};

Document.implement(SelfSelection);
Element.implement(SelfSelection);



// all kobble DOM ids take the form controller_id[_association]
// not model not controller: must be singular
// eg node_16, node_16_tags, bundle_23_members, user_1_bookmarks

var KobbleParameters = {
  idparts: function () {
    var parts = this.id.split('_');
    var parameters = {};
    if (parts[parts.length-1] != parseInt(parts[parts.length-1], 10)) parameters['association'] = parts.pop();
    if (parts[parts.length-1] == parseInt(parts[parts.length-1], 10)) parameters['id'] = parts.pop();
    parameters['type'] = parts.pop();
    if (parts[parts.length-1] != parseInt(parts[parts.length-1], 10)) parameters['context'] = parts.pop();
    else parameters['collection'] = parts.pop();
    return parameters;
  },
  kobbleID: function () { return this.idparts().id; },
  kobbleKlass: function () { return this.idparts().type; },
  kobbleCollection: function () { return this.idparts().collection; },
  kobbleAssociation: function () { return this.idparts().association; },
  kobbleContext: function () { return this.idparts().context; },
  
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

Element.implement(KobbleParameters);



function isBody(element){
	return (/^(?:body|html)$/i).test(element.tagName);
};



var Kobble = new Class({
  Implements: Log,
  
  initialize: function(){

    // errors and notices
    this.message_holder = null;
    this.message_fader = null;
    this.message_timer = null;
        
    // zoomy forms
    this.zoomlinks = [];
    this.floater = null;
    this.floaters = [];
    
    // logging control
    this.debug_level = 0;
  },

  // this is just a holder-together:
  // each of kobble's functional components adds a few activation triggers
  
  activate: function (element) {
    var scope = element || document;
    kobble_starters.each(function (fun) { fun.attempt(scope); });
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
    if (!this.message_holder) {
      this.message_holder = new Element('div', {'id' : 'notification'}).inject(document.body);
      this.message_fader = function () { this.message_holder.fade('out'); }.bind(this);
    }
    if (this.message_timer) $clear(this.message_timer);
    this.message_holder.fade('hide');
    return this.message_holder;
  },
  announce: function (message, title) {
    this.announcer().removeClass('error');
    this.announcer().set('html', message);
    this.flashMessage();
  },
  complain: function (message, title) {
    this.announcer().addClass('error');
    this.announcer().set('html', message);
    this.flashMessage();
  },
  flashMessage: function () {
    this.announcer().fade('in');
    this.message_timer = this.message_fader.delay(4000);
  },

  // selective logger
  
  debug: function (message, level) {
    if (!level) level = 2;
    this.log(message);
  },
  
  // utilities
  
  uuid: function () {
    // http://www.ietf.org/rfc/rfc4122.txt
    var s = [];
    var hexDigits = "0123456789ABCDEF";
    for (var i = 0; i < 32; i++) { s[i] = hexDigits.substr(Math.floor(Math.random() * 0x10), 1); }
    s[12] = "4";                                       // bits 12-15 of the time_hi_and_version field to 0010
    s[16] = hexDigits.substr((s[16] & 0x3) | 0x8, 1);  // bits 6-7 of the clock_seq_hi_and_reserved to 01

    return s.join('');
  }
    
});


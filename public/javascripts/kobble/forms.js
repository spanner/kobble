var JsonForm = new Class ({
  initialize: function (element, e) {
    var event = k.block(e);
    event.target.blur();
    k.clearFloaters();
    this.link = element;
    k.debug('jsonForm.initialize', 5);
    this.form = null;
    this.is_open = false;
    this.at = event.page;
    this.anchored_at = null;
    this.waiter = null;
    this.form = null;
    this.floater = new Element('div', {'class': 'floater'}).inject(document.body);
    this.formHolder = new Element('div', {'class': 'modalform'}).inject(this.floater);
    this.formWaiter = new Element('div', {'class': 'floatspinner'}).inject(this.formHolder);
    this.destination = $(this.link.id.replace(/[\w_]*extend_/, ''));
    this.destination_type = this.destination.get('tag');
    this.created_item = null;
    this.destination_squeeze = k.lookForSqueeze( this.destination );     // this is going to be a memory leak in IE when we get there
    var mf = this;
    this.openfx = new Fx.Morph(this.floater, {
      duration: 'long', 
      transition: Fx.Transitions.Back.easeOut,
      link: 'cancel'
    });
    this.closefx = new Fx.Morph(this.floater, {
      duration: 'normal', 
      transition: Fx.Transitions.Cubic.easeOut, 
      link: 'cancel',
      onComplete: function () { mf.floater.hide(); }
    });
    this.formHolder.set('load', {
      onRequest: function () { mf.show(); },
      onSuccess: function () { mf.prepForm(); },
      onFailure: function () { mf.failed(); }
    });
    k.rememberFloater(this);
    this.waiting();
    this.getForm();
    k.floater = this;
  },

  // initialize calls getForm() directly
  // it's only separated to be overridable

  getForm: function () {
    k.debug('jsonForm.getForm', 5);
    this.canceller().inject(this.floater, 'top');
    this.formHolder.load(this.url());
  },
  
  // onSuccess trigger in formHolder.load calls prepForm()
  // which locates and displays the form and activates any useful elements within it
  // may be called again by processResponse if response contains another form

  prepForm: function () {
    this.notWaiting();
    // this.linkNotWaiting();
    this.resize();
    this.form = this.formHolder.getElement('form');
    this.form.onsubmit = this.sendForm.bind(this);
    this.form.getElements('a.cancelform').each(function (a) { a.onclick = this.hide.bind(this); }, this);
    this.form.getElements('.fillWithSelection').each(function (input) { if (input.get('value') == '') input.set('value', k.quoteSelectedText()); });
    k.makeSuggester(this.form.getElements('input.tagbox'));
    var first = this.form.getElement('.pickme');
    if (first) first.focus();
 },

  // captured form.onsubmit calls sendForm()
  // which initiates the JSON request and binds its outcome
  
  sendForm: function (e) {
    k.debug('jsonForm.sendForm', 5);
    var event = k.block(e);
    var mf = this;
    var req = new Request.JSON({
      url: this.form.get('action'),
      onRequest: function () { mf.waiting(); },
      onSuccess: function (response) { mf.processResponse(response); },
      onFailure: function (response) { mf.hide(); k.complain('remote call failed'); }
    }).post(this.form);
  },

  // sendform sets onSuccess to processResponse
  // processResponse looks for an error in the response
  // calls updatePage if none found
  // in subclasses this is usually a previewing or validation mechanism

  processResponse: function (response) {
    k.debug('jsonForm.processResponse', 5);
    this.notWaiting();
    if (response.errors) {
      
      // it's too dull and fiddly rebuilding or marking the form
      // so potentially-iterative or validated forms should use htmlForm
      
    } else {
      this.updatePage(response.created);
    }
  },
  
  // updatePage called by processResponse if no more user input is expected
  // and inserts response html into destination element
  // default is that we expect to add an option to a select box
  // created from the JSON representation of a kobble object
  // subclasses have other ideas mostly to do with extending lists

  updatePage: function (response) {
    k.debug('jsonForm.updatePage', 5);
    this.created_item = new Element('option', {'value': response.id}).set('text',response.name);
    this.created_item.inject( this.destination, 'top' );
    this.hide(this.created_item);
    this.showOnPage();
  },

  // rest is just display control
  
  failed: function () {
    this.hide();
    k.complain("oh no.");
  },
  
  show: function (origin) {
    k.debug('jsonForm.show', 5);
    if (!origin) origin = this.link;
    this.startAt(origin);
    this.link.addClass('activated');
    this.is_open = true;
  },

  hide: function (e, destination) {
    k.block(e);
    if (!destination) destination = this.link;
    this.shrinkTowards(destination);
    this.link.removeClass('activated');
    this.is_open = false;
  },
  
  choose_anchor: function (at, towidth, toheight) {
    if (this.anchored_at) return this.anchored_at;
    
    var scroll = document.getScroll();
    var boundary = document.getSize();
    var anchored = { x: null, y: null };

    var cangoleft = at.left - towidth - scroll.x > 0;
    var cangoright = at.left + towidth + scroll.x < boundary.x;
    if (cangoleft == cangoright) anchored.x = 'center';
    else if (cangoright) anchored.x = 'left';
    else anchored.x = 'right';
    
    var cangoup = at.top - toheight - scroll.y > 0;
    var cangodown = at.top + toheight + scroll.y < boundary.y;
    if (cangoup == cangodown) anchored.y = 'center';
    else if (cangodown) totop = anchored.y = 'top';
    else totop = anchored.y = 'bottom';

    this.anchored_at = anchored;
    return anchored;
  },
  
  resize: function (width, height) {
    var at = this.floater.getCoordinates();
    var towidth = width || 510;
    var toheight = height || this.formHolder.getHeight() + 10;
    var anchor = this.choose_anchor(at, towidth, toheight);
    var toleft, totop;
    k.debug('floater anchored at ' + anchor.y + ' ' + anchor.x, 2);
    
    switch (anchor.x) {
      case "right": toleft = (at.left - towidth) + at.width; break;
      case "center": toleft = Math.floor(at.left - towidth / 2); break;
      default: toleft = at.left;
    }
      
    switch (anchor.y) {
      case "bottom": totop = (at.top - toheight) + at.height; break;
      case "center": totop = Math.floor(at.top - toheight / 2); break;
      default: totop = at.top;
    }
    
    this.openfx.start({'opacity': 1, 'left': toleft, 'top': totop, 'width': towidth, 'height': toheight});
  },
  
  shrinkTowards: function (element) {
    this.floater.addClass('floater_waiting');   // no scroll bars
    var downto = element.getCoordinates();
    // downto.opacity = 0;
    this.closefx.start(downto);
  },
  
  startAt: function (element) {
    if (!element) element = this.link;
    var upfrom = element.getCoordinates();
    upfrom.opacity = 1;
    upfrom.left = upfrom.left + 20;
    upfrom.height = 62;
    upfrom.width = 62;
    this.floater.setStyles(upfrom);
  },
  
  expandFrom: function (element) {
    if (!element) element = this.link;
    var upfrom = element.getCoordinates();
    upfrom.opacity = 1;
    upfrom.left = upfrom.left + 20;
    this.floater.setStyles(upfrom);
    this.resize();
  },

  destroy: function () {
    this.floater.remove();
  },
  
  waiting: function () {
    this.formWaiter.show();
    this.floater.addClass('floater_waiting');
  },

  notWaiting: function () {
    this.formWaiter.hide();
    this.floater.removeClass('floater_waiting');
  },

  linkWaiting: function (argument) {
    this.link.addClass('waiting');
  },
  
  linkNotWaiting: function (argument) {
    this.link.removeClass('waiting');
  },

  showOnPage: function () {
    if (this.destination_squeeze) k.squeezebox.display(this.destination_squeeze);
    if (this.destination_type == 'UL') {
      this.destination.selectedIndex = 0;
      new Fx.Scroll(window).toElement(this.destination);
    } else {
      new Fx.Scroll(window).toElement(this.created_item);
    }
  },

  announceSuccess: function () {
    k.announce('done');
  },

  url: function () { 
    return this.link.getProperty('href');       // needs to be overridable
  },

  canceller: function () {
    var a = new Element('a', {'class': 'canceller', 'href': '#'}).set('text','X');
    a.onclick = this.hide.bind(this);
    return a;
  }
  
});

// htmlForm inherits from jsonForm but expects to get html back at the end of the process instead: 
// usually a list item but could be anything.

var HtmlForm = new Class ({
  Extends: JsonForm,
  
  prepForm: function () {
    this.parent();
    if (this.form.hasClass('confirming')) this.floater.addClass('confirming');
    else this.floater.removeClass('confirming');
    this.form.getElements('#revise').each( function (input) { input.onclick = this.revise.bind(this); }, this);
    this.form.getElements('#confirm').each( function (input) { input.onclick = this.confirm.bind(this); }, this);
  },
  
  sendForm: function (e) {
    var event = k.block(e);
    this.responseholder = new Element(this.destination_type);
    var mf = this;
    var req = new Request.HTML({
      url: this.form.get('action'),
      update: this.responseholder,
      onRequest: function () { mf.waiting(); },
      onSuccess: function (response) { mf.processResponse(response); },
      onFailure: function (response) { mf.hide(); k.complain('remote call failed'); }
    }).post(this.form);
  },

  // confirm and revise set the hidden 'dispatch' parameter to control wehether we save or re-edit after a preview

  confirm: function (e) {
    this.form.getElements('input.routing').each(function (input) { input.set('value', 'confirm'); });
    return true;  // and submit form
  },

  revise: function (e) {
    this.form.getElements('input.routing').each(function (input) { input.set('value', 'revise'); });
    return true;  // and submit form
  },

  processResponse: function (response) {
    this.notWaiting();
    if (this.responseholder.getElement('form')) {
      this.formHolder.empty();
      this.formHolder.adopt(this.responseholder.getChildren());
      this.prepForm();      // loop back and prepare form for submission again
    } else {
      this.hide();
      this.updatePage(response);
    }
  },

  updatePage: function () {
    var elements = this.responseholder.getChildren(); 
    this.created_item = elements[0];
    this.created_item.inject(this.destination, this.destination.hasClass('addToBottom') ? 'bottom' : 'top');
    this.showOnPage();
    k.activateElement( this.created_item );
  },
  
  showOnPage: function () {
    if (this.destination_squeeze && this.destination_squeeze.offsetHeight == 0) k.squeezebox.display(this.destination_squeeze);
    var mf = this;
    new Fx.Scroll(window).toElement(mf.created_item).chain(function(){ mf.created_item.highlight(); });
  }
});


// snipper is a special case of htmlForm that does more work to prepare the form

var Snipper = new Class ({
  Extends: HtmlForm,
  prepForm: function () {
    this.parent();
    this.form.getElements('#node_playfrom').each( function (input) { input.set('value', k.getPlayerIn()); });
    this.form.getElements('#node_playto').each( function (input) { input.set('value', k.getPlayerOut()); });
  },
  announceSuccess: function () {
    k.announce('fragment created');
  },
  
  getSelectedText: function () {
    var txt = '';
    if (window.getSelection) {
      txt = window.getSelection();
    } else if (document.getSelection) {
      txt = document.getSelection();
    } else if (document.selection) {
      txt = document.selection.createRange().text;
    }
    return '' + txt;
  },

  quoteSelectedText: function () {
    var txt = this.getSelectedText();
    if (txt) {
      txt.replace(/[\n\r]+/g, " ");
      return "bq. " + txt + "\n\n";
    } else {
      return '';
    }
  },
  
  getPlayerIn: function () {
    var player = document.spannerplayer;
    if (player && player.playerOk() ) return player.playerIn();
  },
  
  getPlayerOut: function () {
    var player = document.spannerplayer;
    if (player && player.playerOk() ) return player.playerOut();
  }
  
});

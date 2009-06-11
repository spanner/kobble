var zoomers = {};

var Zoomer = new Class({
  initialize: function (element, klass) {
    this.link = element;
    this.klass = klass;
    this.destination = $(this.link.id.replace(/[\w_]*extend_/, ''));
    this.zoombox = null;
    this.link.addEvent('click', this.launch.bindWithEvent(this));
  },
  launch: function (e) {
    if (!this.zoombox) this.zoombox = new ZoomBox(this);
    this.zoombox.launch(e);
  },
  reset: function () {
    this.zoombox = null;
  }
});

var ZoomBox = new Class({
  initialize: function (zoomer) {
    this.zoomer = zoomer;
    this.link = zoomer.link;
    this.destination = zoomer.destination;
    
    this.initial_form_url = this.link.get('href');
    this.click_at = null;
    this.form = null;

    this.floater = new Element('div', {'class': 'floater'}).inject(document.body);
    this.formHolder = new Element('div', {'class': 'modalform'}).inject(this.floater);
    this.formWaiter = new Element('div', {'class': 'floatspinner'}).inject(this.formHolder);
    this.canceller = new Element('a', {'class': 'canceller', 'href': '#'}).set('text','X').inject(this.floater, 'top');

    this.floater.set('morph', {
      duration: 'long', 
      transition: Fx.Transitions.Back.easeOut,
      link: 'cancel'
    });
    this.formHolder.set('load', {
      onRequest: this.waiting.bind(this),
      onComplete: this.bindForm.bind(this)
    });
    
    this.canceller.addEvent('click', this.collapse.bind(this));
  },
  
  launch: function (e) {
    event = k.block(e);
    this.click_at = event.page;
    this.relocate();
    if (!this.form) {
      this.getReady();
      this.getForm();
    } else {
      this.zoom();
    }
  },
  
  relocate: function (argument) {
    this.floater.setStyles({
      left: this.click_at.x - 10,
      top: this.click_at.y - 10
    });
  },
  
  getReady: function () {
    this.floater.setStyles({
      opacity : 1,
      height: 62,
      width: 62
    });
  },

  getForm: function () {
    this.formHolder.load(this.initial_form_url);      // triggers bind and zoom on successful load
  },
  
  bindForm: function (argument) {
    this.notWaiting();
    var form = this.formHolder.getElement('form');
    if (form) {
      switch(this.zoomer.klass){                        // it's stodgy but it's cheaper and safer than an eval
        case "JsonForm": this.form = new JsonForm(form, this); break;
        case "HtmlForm": this.form = new HtmlForm(form, this); break;
        case "Snipper": this.form = new Snipper(form, this); break;
      }
    } else {
      this.formHolder.set('text', "Sorry: big end's gone.");
    }
    this.zoom();
  },
  
  zoom: function (width, height) {
    this.floater.removeClass('floater_collapsing');
    
    var at = this.floater.getCoordinates();
    var towidth = width || 510;
    var toheight = height || this.formHolder.getHeight() + 10;
    var expansion = this.choose_expansion(at, towidth, toheight);
    var toleft, totop;
    console.log('floater expanding towards ' + expansion.y + ' ' + expansion.x);
    
    switch (expansion.x) {
      case "right": toleft = (at.left - towidth) + at.width; break;
      case "center": toleft = Math.floor(at.left - towidth / 2); break;
      default: toleft = at.left;
    }
      
    switch (expansion.y) {
      case "bottom": totop = (at.top - toheight) + at.height; break;
      case "center": totop = Math.floor(at.top - toheight / 2); break;
      default: totop = at.top;
    }
    
    this.floater.morph({
      'opacity': 1, 
      'left': toleft, 
      'top': totop, 
      'width': towidth, 
      'height': toheight
    });
  },

  collapse: function (x, y) {
    this.floater.addClass('floater_collapsing');   // no scroll bars
    if (!x) x = this.click_at.x;
    if (!y) y = this.click_at.y;
    this.floater.morph({
      left: x,
      top: y,
      width: 0,
      height: 0,
      opacity: 0
    });
  },
  
  // this is just a shortcut for triggers

  collapseBack: function (e) {
    k.block(e);
    this.collapse();
  },
  
  // sometimes the outcome is different than the starting point
  
  collapseTowards: function (element) {
    var at = element.getCoordinates();
    x = at.left + parseInt(at.width/2, 10);
    y = at.left + parseInt(at.height/2, 10);
    this.collapse(x, y);
  },

  choose_expansion: function (at, towidth, toheight) {
    
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

    return anchored;
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
  
  reset: function () {
    this.floater.destroy();
    this.zoomer.reset();
  }
  
});







var JsonForm = new Class ({
  initialize: function (form, container) {
    this.form = form;
    this.container = container;
    if (container.destination) {
      this.destination = container.destination;
      this.destination_type = this.destination.get('tag');
      this.destination_squeeze = this.destination.lookForCollapsedParent();
    }
    this.bindForm();
  },
  
  bindForm: function () {
    this.form.onsubmit = this.sendForm.bindWithEvent(this);
    this.form.getElements('a.cancelform').each(function (a) { a.addEvent('click', this.container.collapseBack.bindWithEvent(this.container)); }, this);
    this.form.getElements('.fillWithSelection').each(function (input) { if (input.get('value') == '') input.set('value', this.quoteSelectedText()); }, this);
    this.form.getElements('input.tagbox').each(function (el) { new Suggester(el); });
    var first = this.form.getElement('.pickme');
    if (first) first.focus();
 },

  // captured form.onsubmit calls sendForm()
  // which initiates the JSON request and binds its outcome
  
  sendForm: function (e) {
    var event = k.block(e);
    var req = new Request.JSON({
      url: this.form.get('action'),
      onRequest: this.waiting.bind(this),
      onSuccess: this.processResponse.bind(this, response),
      onFailure: this.fail.bind(this, response)
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
      k.complain(response.errors);      // really ought to try and present failed validations here
    } else {
      this.container.updatePage(response.created);
    }
  },
  
  // updatePage is called by processResponse if no more user input is expected
  // and inserts response html into destination element
  // by default we expect to add an option to a select box
  // created from the JSON representation of a kobble object
  // subclasses have other ideas mostly to do with extending lists

  updatePage: function (response) {
    this.created_item = new Element('option', {'value': response.id}).set('text',response.name);
    this.created_item.inject( this.destination, 'top' );
    this.container.collapseTowards(this.created_item);
    this.showOnPage();
    this.container.reset();
  },
  
  showOnPage: function () {
    if (this.destination_squeeze) k.squeezebox.display(this.destination_squeeze);
    if (this.destination_type == 'UL') this.destination.selectedIndex = 0;
    new Fx.Scroll(window).toElement(this.created_item);
  },
  
  waiting: function () {
    this.container.waiting();
  },
  
  notWaiting: function () {
    this.container.notWaiting();
  },
  
  fail: function (response) {
    k.complain(response.errors);
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
  }  
  
});

// htmlForm inherits from jsonForm but expects to get html back at the end of the process instead: 
// usually a list item but could be anything.

var HtmlForm = new Class ({
  Extends: JsonForm,
  
  bindForm: function () {
    this.parent();
    this.form.getElements('#revise').each( function (input) { input.addEvent('click', this.revise.bind(this)); }, this);
    this.form.getElements('#confirm').each( function (input) { input.addEvent('click', this.confirm.bind(this)); }, this);
  },
  
  sendForm: function (e) {
    var event = k.block(e);
    this.responseholder = new Element(this.destination_type);
    var req = new Request.HTML({
      url: this.form.get('action'),
      update: this.responseholder,
      onRequest: this.waiting.bind(this),
      onSuccess: this.processResponse.bind(this, response),
      onFailure: this.fail.bind(this, response)
    }).post(this.form);
  },

  // confirm and revise set the hidden 'dispatch' parameter to control whether we save or re-edit after a preview

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
      this.bindForm();      // loop back and prepare form for submission again
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
  bindForm: function () {
    this.parent();
    this.form.getElements('#node_playfrom').each( function (input) { input.set('value', this.getPlayerIn()); });
    this.form.getElements('#node_playto').each( function (input) { input.set('value', this.getPlayerOut()); });
  },
  announceSuccess: function () {
    k.announce('fragment created');
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

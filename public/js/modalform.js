var ModalForm = new Class ({
  initialize: function (element, e) {
    e.preventDefault();
		this.eventPosition = this.position.bind(this);
		this.source = element;
		this.overlay = new Element('div', {'id': 'overlay'}).injectInside(document.body);
		this.floater = new Element('div', {'id': 'floater'}).injectInside(document.body);
		this.spinner = new Element('div', {'class': 'bigspinner'}).injectInside(this.floater);
		this.formholder = new Element('div', {'id': 'modalform'}).injectInside(this.floater).hide();
    this.responseholder = new Element(this.responseholdertype());
    console.log(this.responseholder);
		this.form = null;
		this.overlay.onclick = this.hide.bind(this);
    this.waiter = null;
    this.fx = { overlay: this.overlay.effect('opacity', {duration: 500}).hide() };
    this.show();
  },
  
  // the url from which we should request the form
  // by default we read this from the source link href
  url: function () {
    return this.source.getProperty('href');
  },

  // the id of the element inside which we should inject the eventual results of submitting the form
  // by default we get this from the 'target' property of the source link
  target: function () {
    var targetid = this.source.getProperty('target');
    console.log('targetid is ' + targetid);
    return $E('#' + targetid);
  },
  
  // there must be a better way to generalise than this, but never mind.
  responseholdertype: function () {
    return 'select';
  },
  
  // overridable close-form link suitable for insertion into the dialog somewhere
  canceller: function () {
    var p = new Element('p');
    var a = new Element('a', {'class': 'canceller', 'href': '#'}).setText('close form');
    a.onclick = this.hide.bind(this);
    a.injectInside(p);
    return p;
  },
  
  // hide embeds and objects to prevent display glitches
	setup: function(opening){
    $ES('div.player').setStyle('visibility', opening ? 'hidden' : 'visible');
		var fn = opening ? 'addEvent' : 'removeEvent';
		window[fn]('scroll', this.eventPosition)[fn]('resize', this.eventPosition);
  },
  
  //position whiteout overlay
	position: function(){
		this.overlay.setStyles({
		  'top': window.getScrollTop(), 
		  'height': window.getHeight()
		});
	},
	
  // retrieve blank input form
  populate: function () {
    this.canceller().injectInside(this.floater);
    var form = this;
		new Ajax(this.url(), {
			method: 'get',
			update: this.formholder,
		  onRequest: function () {form.waiting();},
		  onComplete: function () {form.gotform();},
		  onFailure: function () {form.failed();}
		}).request();
  },
  
	// display form layer. calls position and setup to refresh interface positioning in case we've scrolled
  show: function () {
    this.position();
    this.populate();
		this.setup(true);
		this.top = window.getScrollTop() + (window.getHeight() / 15);
		this.floater.setStyles({top: this.top, display: ''});
		this.fx.overlay.start(0.4);
    this.floater.show();
  },

  // hide snipper and overlay
  hide: function () {
    this.floater.hide();
		this.fx.overlay.start(0);
		this.setup(false);
  },

  // display spinner, hide form
  waiting: function () {
    this.formholder.hide();
    this.spinner.show();
  },

  // display spinner, hide form
  notwaiting: function () {
    this.spinner.hide();
    this.formholder.show();
  },

  // display form, hide spinner, bind form submit
  gotform: function () {
    this.notwaiting();
    this.form = $E('form', this.formholder);
		this.form.onsubmit = this.submit.bind(this);
    this.prepform();
  },
  
  // this is where one would intervene on the form, eg to initialize tagging widget
  // nothing really needed here.
  prepform: function (argument) {
    $E('input', this.form).focus();
  },
  
  // submit form by ajax
  submit: function (e) {
    e.preventDefault();
    var f = this;
    this.form.send({
      method: 'post',
      update: f.responseholder,
      onRequest: function () { f.page_waiting(); },
      onComplete: function () { f.page_update(); }
    });
  },
  
  // some subclasses will want to display spinners in lists and things like that
  // by default we just wait the form, making this a bit of a misnomer
  page_waiting: function () {
    this.waiting();
  },
  
  page_update: function () {
    this.hide();
    
    var newitem = this.responseholder.getFirst();
    console.log('responseholder children are');
    console.log(this.responseholder.getChildren());
    
    var recipient = this.target();
    console.log('recipient is');
    console.log(recipient);

    newitem.injectInside(recipient);
    announce('new item created');
  },
  
  // really ought to do something sensible here
  failed: function () {
    error("something didn't work");
  },
  
  // just in case it's needed
  destroy: function () {
    this.floater.remove();
    this.overlay.remove();
  }
});

/*
  the snipper is a special case of the modal form used only on the source document page to cut out fragments
*/

var Snipper = ModalForm.extend ({
	
	// retreive form using values gathered from page
	// (overriding standard modalform, which is blank)
  populate: function () {
    var snipper = this;
    this.canceller().injectInside(this.floater);
		new Ajax('/nodes/snipper', {
			method: 'get',
			data: {
				'node[body]': snipper.getSelectedText(),
				'node[playfrom]': snipper.getPlayerIn(),
				'node[playto]': snipper.getPlayerOut(),
				'node[source_id]': snipper.getSourceID()
			},
			update: this.formholder,
		  onRequest: function () {snipper.waiting();},
		  onComplete: function () {snipper.gotform();},
		  onFailure: function () {snipper.failed();}
		}).request();
  },
  
  // no need to work this out
  url: function () {
    return '/nodes/snipper';
  },
  
  // or this
  target: function () {
    return $E('ul#nodelist');
  },

  // there must be a better way to generalise than this, but never mind.
  responseholdertype: function () {
    return 'div';
  },
  
  // this is called once the form has been retrieved
  // we need to initialize tagging widget and position cursor
  prepform: function (argument) {
    $ES('input.tagbox', this.form).each(function (element, i) {
  		new TagSuggestion(element, '/tags/matching', {
  			postVar: 'stem',
  			onRequest: function(el) { element.addClass('waiting'); },
  			onComplete: function(el) { element.removeClass('waiting'); }
  		});
  	});
    $E('input#node_name').focus();
  },
  
  // this is called when the form is submitted
  // we disappear the form and stick a waiter in the node list
  page_waiting: function (argument) {
    this.waiting(); 
    slides['hide_fragments'].slideIn();
    var nodelist = $E('ul#nodelist');
    this.waiter = new Element('li', {'class': 'waiter'}).injectTop(nodelist);
    this.hide();
  },
  
  // this is called upon final response to the form
  // we remove the waiter, insert into the node list and make the new insertion draggable
  page_update: function () {
    $E('a#show_fragments').removeClass('emptylist');
    var nodelist = this.target();
    var newnode = this.responseholder.getFirst();
    this.waiter.remove();
    newnode.injectTop(nodelist);
    $ES('li.removewhenfilled', nodelist).each(function (el) { el.remove(); });
    newnode.addEvent('mousedown', function(e) { new Draggee(this, new Event(e)); });
    announce('fragment created');
    flash(newnode);
  },
  
  // here we try various ways to get hold of the text selected on the page
  // works in firefox and safari, anwyay.
  getSelectedText: function () {
  	var txt = '';
  	if (window.getSelection) {
  		txt = window.getSelection();
  	} else if (document.getSelection) {
  		txt = document.getSelection();
  	} else if (document.selection) {
  		txt = document.selection.createRange().text;
  	}
    return txt;
  },
  
  // query the flash player, if present, for starting timecode
  getPlayerIn: function () {
    var player = document.spannerplayer;
    if (player && player.playerOk() ) return player.playerIn();
  },

  // query the flash player, if present, for starting timecode
  getPlayerOut: function () {
    var player = document.spannerplayer;
    if (player && player.playerOk() ) return player.playerOut();
  },

  // dig the currently appropriate source id out of the page
  // (this assumes we are looking at a source page)
  getSourceID: function () {
    var splut = idParts($E('div.header'));
    return splut['id'];
  }
});

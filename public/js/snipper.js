var Snipper = new Class ({
  initialize: function (element, e) {
		this.eventPosition = this.position.bind(this);
		this.overlay = new Element('div', {'id': 'overlay'}).injectInside(document.body);
		this.floater = new Element('div', {'id': 'snipper'}).injectInside(document.body);
		this.spinner = new Element('div', {'class': 'bigspinner'}).injectInside(this.floater);
		this.formholder = new Element('div', {'id': 'snipperform'}).injectInside(this.floater).hide();
		this.overlay.onclick = this.hide.bind(this);
    this.responseholder =  new Element('div');
    this.waiter = null;
    this.fx = { overlay: this.overlay.effect('opacity', {duration: 500}).hide() };
    this.position();
    this.show();
  },
  
  // hide embeds and objects to prevent display glitches
	setup: function(opening){
    $E('div.player').setStyle('visibility', opening ? 'hidden' : 'visible');
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
	
	// display snipper layer. calls position and setup to refresh interface positioning
  show: function () {
    console.log('snipper.show()');
    // retrieve node-creation form using values pulled from page
    var snipper = this;
		new Ajax('/nodes/snipper', {
			method: 'get',
			data: {
				'node[body]': getSelectedText(),
				'node[playfrom]': getPlayerIn(),
				'node[playto]': getPlayerOut(),
				'node[source_id]': getSourceID(),
			},
			update: this.formholder,
		  onRequest: function () {snipper.waiting();},
		  onComplete: function () {snipper.withform();},
		  onFailure: function () {snipper.failed();},
		}).request();
		this.position();
		this.setup(true);
		this.top = window.getScrollTop() + (window.getHeight() / 15);
		this.floater.setStyles({top: this.top, display: ''});
		this.fx.overlay.start(0.4);
    this.floater.show();
  },
  
  // hide snipper and overlay
  hide: function () {
    console.log('snipper.hide()');
    this.floater.hide();
		this.fx.overlay.start(0);
		this.setup(false);
  },

  // display spinner, hide form
  waiting: function () {
    this.formholder.hide();
    this.spinner.show();
  },

  // display form, hide spinner
  // because this is called after form retrieval, we initialize the tagger here
  withform: function () {
    this.spinner.hide();
    this.formholder.show();
    this.form = $E('form', this.formholder);
		this.form.onsubmit = this.submit.bind(this);
    console.log("this.form is");
    console.log(this.form);
    $ES('input.tagbox', this.form).each(function (element, i) {
  		new TagSuggestion(element, '/tags/matching', {
  			postVar: 'stem',
  			onRequest: function(el) { element.addClass('waiting'); },
  			onComplete: function(el) { element.removeClass('waiting'); }
  		});
  	});
    $E('input#node_name').focus();
  },
  submit: function (e) {
    e.preventDefault();
    snipper = this;
    snipper.form.send({
      method: 'post',
      update: snipper.responseholder,
      onRequest: function () { 
        snipper.waiting(); 
        slides['hide_fragments'].slideIn();
        var nodelist = $E('ul#nodelist');
        this.waiter = new Element('li', {'class': 'waiter'}).injectTop(nodelist);
        snipper.hide();
      },
      onComplete: function () {
        $E('a#show_fragments').removeClass('emptylist');
        var nodelist = $E('ul#nodelist');
        var newnode = snipper.responseholder.getFirst();
        this.waiter.remove();
        newnode.injectTop(nodelist);
        $E('li.removewhenfilled', nodelist).remove();
        newnode.addEvent('mousedown', function(e) { new Draggee(this, new Event(e)); });
        announce('fragment created');
        flash(newnode);
      }
    });
  },
  failed: function () {
    
  }, 
  destroy: function () {
    this.floater.remove();
    this.overlay.remove();
  }
});

var getSelectedText = function () {
	var txt = '';
	if (window.getSelection) {
		txt = window.getSelection();
	} else if (document.getSelection) {
		txt = document.getSelection();
	} else if (document.selection) {
		txt = document.selection.createRange().text;
	}
  return txt;
};

var getPlayerIn = function () {
  var player = document.spannerplayer;
  if (player && player.playerOk() ) return player.playerIn();
};

var getPlayerOut = function () {
  var player = document.spannerplayer;
  if (player && player.playerOk() ) return player.playerOut();
};

var getSourceID = function () {
  var splut = idParts($E('div.header'));
  return splut['id'];
}
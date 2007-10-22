var Snipper = ModalForm.extend ({
	
	// retreive form using values gathered from page
	// (overriding standard modalform, which is blank)
  populate: function () {
    var snipper = this;
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
    var nodelist = $E('ul#nodelist');
    var newnode = snipper.responseholder.getFirst();
    this.waiter.remove();
    newnode.injectTop(nodelist);
    $E('li.removewhenfilled', nodelist).remove();
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

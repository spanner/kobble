var sn = null;

var Snipper = new Class ({
  initialize: function (element, e) {
    console.log('snipper.initialize()');
    var snipper = sn = this;
    e.preventDefault();
		this.eventPosition = this.position.bind(this);
		this.overlay = new Element('div', {'id': 'overlay'}).injectInside(document.body);
		this.floater = new Element('div', {'id': 'snipper'}).injectInside(document.body);
		this.spinner = new Element('div', {'class': 'bigspinner'}).injectInside(this.floater);
		this.formholder = new Element('div', {'id': 'snipperform'}).injectInside(this.floater).hide();
		
		// bind formholder submit event to this.submit
		
		this.footer = new Element('div', {'id': 'snipperfot'}).injectInside(this.floater);
		new Element('a', {'id': 'closesnipper', 'href': '#'}).injectInside(this.footer).onclick = this.overlay.onclick = this.hide.bind(this);
    this.newnode =  new Element('div', {'class': 'draggable'});
    this.fx = {
			overlay: this.overlay.effect('opacity', {duration: 500}).hide(),
		};
		
    this.position();
    this.show();
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
		  onComplete: function () {snipper.notwaiting();},
		  onFailure: function () {snipper.failed();},
		}).request();
  },
	setup: function(opening){
		var elements = $A(document.getElementsByTagName('object'));
		elements.extend(document.getElementsByTagName(window.ie ? 'select' : 'embed'));
		elements.each(function(el){
			if (opening) el.snBackupStyle = el.style.visibility;
			el.style.visibility = opening ? 'hidden' : el.snBackupStyle;
		});
		var fn = opening ? 'addEvent' : 'removeEvent';
		window[fn]('scroll', this.eventPosition)[fn]('resize', this.eventPosition);
  },
	position: function(){
		this.overlay.setStyles({
		  'top': window.getScrollTop(), 
		  'height': window.getHeight()
		});
	},
  show: function () {
    console.log('snipper.show()');
		this.position();
		this.setup(true);
		this.top = window.getScrollTop() + (window.getHeight() / 15);
		this.floater.setStyles({top: this.top, display: ''});
		this.fx.overlay.start(0.4);
    this.floater.show();
  }, 
  hide: function () {
    console.log('snipper.hide()');
    this.floater.hide();
		this.fx.overlay.start(0);
		this.setup(false);
  },
  submit: function () {
		new Ajax('/nodes/create', {
			method : 'post',
			data : {

			},
			update: this.newnode,
		  onRequest: this.waiting,
		  onComplete: this.confirm,
		  onFailure: this.failed,
		}).request();
  },
  confirm: function () {
    console.log('that seems to work');
  },
  waiting: function () {
    console.log('waiting');
    this.formholder.hide();
    this.spinner.show();
  },
  notwaiting: function () {
    console.log('notwaiting');
    this.spinner.hide();
    this.formholder.show();
    $ES('input.tagbox', this.formholder).each(function (element, i) {
  		new TagSuggestion(element, '/tags/matching', {
  			postVar: 'stem',
  			'onRequest': function(el) { element.addClass('waiting'); },
  			'onComplete': function(el) { element.removeClass('waiting'); }
  		});
  	});
  	
  },
  failed: function () {

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
  return $E('div.header').id.replace('source_', '');
}
var autolinks = [];
var AutoLink = new Class ({
  initialize: function (a, e) {
    this.link = a;
    this.catcher = new Element('div', {'style': 'display: none;'}).injectAfter(a).hide();
    this.link.onclick = this.send.bind(this);
    autolinks.push(this);
  },
  
  request_url: function () {
    return this.link.getProperty('href');
  },
  
  send: function (e) {
    e = new Event(e).stop();
    e.preventDefault();
    this.link.blur();
    al = this;
		new Ajax(this.request_url(), {
			method: 'get',
			update: al.catcher,
		  onRequest: function () {al.waiting();},
		  onComplete: function () {al.finished();},
		  onFailure: function () {al.failed();}
		}).request();
  },
  
  waiting: function () {
    this.link.addClass('waiting');
  },
  
  notWaiting: function () {
    this.link.removeClass('waiting');
  },
  
  finished: function () {
    this.link.remove();
    this.catcher.show();
    $ES('a.autolink', this.catcher).each( function (a) { new AutoLink(a); });
  },
  
  failed: function () {
    this.notWaiting();
    this.catcher.remove();
    this.link.show();
  }
});

var Toggle = AutoLink.extend ({
  finished: function () {
    this.notWaiting();
    if (this.link.hasClass('ticked')) {
      this.link.removeClass('ticked');
      this.link.addClass('crossed');
    } else {
      this.link.removeClass('crossed');
      this.link.addClass('ticked');
    }
  }
})


var Previewer = new Class ({
  initialize: function (element, e) {
    this.container = element;
    this.recipient = new Element('div', {'style': 'display: none;'}).injectInside(element);
    this.waiter = new Element('div', {'class': 'waiting', 'style': 'display: none;'}).injectInside(element);
		this.form = $E('form', element);
    this.form.onsubmit = this.preview.bind(this);
  },
  
  preview: function (e) {
    e = new Event(e).stop();
    e.preventDefault();
    var p = this;
    this.form.hide();
    this.form.send({
      method: 'post',
			update: p.recipient,
		  onRequest: function () {p.waiting();},
		  onComplete: function () {p.show_preview();},
		  onFailure: function () {p.failed();}
    });
  },
  
  show_preview: function () {
    this.container.addClass('preview');
    this.previewform = $E('form', this.recipient);
    this.previewform.onsubmit = this.confirm.bind(this);
    console.log(this.previewform);
    $E('a.revise', this.recipient).onclick = this.revise.bind(this);
		this.notwaiting();
    this.recipient.show();
  },
  
  confirm: function (e) {
    e = new Event(e).stop();
    e.preventDefault();
    var p = this;
    this.recipient.hide();
    this.previewform.send({
      method: 'post',
			update: p.recipient,
		  onRequest: function () {p.waiting();},
		  onComplete: function () {p.finished();},
		  onFailure: function () {p.failed();}
    });
  },
  
  revise :function (e) {
    e = new Event(e).stop();
    e.preventDefault();
    this.container.removeClass('preview');
    this.recipient.hide();
    this.form.show();
  },
  
  waiting: function () {
    this.container.removeClass('preview');
    this.waiter.show();
  },
  
  notwaiting: function () {
    this.waiter.hide();
  },
  
  finished: function () {
    this.recipient.show();
    this.form.remove();
    this.waiter.remove();
    flash(this.container)
  },

  failed: function (argument) {
    console.log(this);
  }
});

var editor = null;

var Editor = new Class ({
  initialize: function (a, e) {
    editor = this;
    this.link = a
	  var tag = a.id.replace('edit_','');
    this.subject = $E('#' + tag);
    this.dimensions = this.subject.getCoordinates();
    this.fonts = this.subject.getStyles('font-family', 'font-size', 'line-height', 'letter-spacing');
		this.wrapper = new Element('div', {'styles': {'overflow': 'hidden'}, 'class': 'editwrapper'}).injectAfter(this.subject);
    this.formholder = new Element('div', {'style': 'display: none;'}).injectTop(this.wrapper);
    this.previewholder = new Element('div', {'style': 'display: none;'}).injectTop(this.wrapper);
    this.resizer = new Fx.Style(this.wrapper, 'height', {duration:500});
		this.getForm();
  },
  
  url: function () {
    return this.link.getProperty('href')
  },
  
  resizetocontain: function (element) {
    var height = element.getCoordinates()['height'];
    if (height) this.resizer.start(height)
  },
  
  closewrapper: function () {
    ed = this;
    this.formholder.hide();
    this.previewholder.hide();
    this.resizer.start(0).chain(function () { ed.wrapper.remove(); });
  },
  
  getForm: function () {
    this.link.hide();
    ed = this;
    this.wrapper.setStyles({'width': this.dimensions.width, 'height': this.dimensions.height});
		new Ajax(this.url(), {
			method: 'get',
			update: ed.formholder,
		  onRequest: function () {ed.waiting();},
		  onComplete: function () {ed.gotForm();},
		  onFailure: function () {ed.failed();}
		}).request();
  },
  
  gotForm: function () {
    this.form = $E('form', this.formholder);
    this.form.onsubmit = this.getPreview.bind(this);
    $E('a.cancel', this.formholder).onclick = this.cancel.bind(this);
    this.notWaiting();
    this.formholder.show();
    this.resizetocontain(this.formholder);
  },
  
  getPreview: function (e) {
    e = new Event(e).stop();
    e.preventDefault();
    var ed = this;
    this.form.send({
      method: 'post',
			update: ed.previewholder,
		  onRequest: function () {ed.waiting();},
		  onComplete: function () {ed.gotPreview();},
		  onFailure: function () {ed.failed();}
    });
  },
  
  // if the return from getPreview contains a form, we'll assume that further confirmation is required
  // if not, we move the returned html into the original element and call finish.
  
  gotPreview: function () {
    this.previewform = $E('form', this.previewholder);
    if (this.previewform) {
      this.previewform.onsubmit = this.confirm.bind(this);
      console.log(this.previewform);
      $E('a.revise', this.previewholder).onclick = this.revise.bind(this);
      $E('a.cancel', this.previewholder).onclick = this.cancel.bind(this);
  		this.notWaiting();
      this.previewholder.show();
      this.resizetocontain(this.previewholder);
    } else {
      this.previewholder.show();
      this.resizetocontain(this.previewholder);
      this.subject.replaceWith(this.previewholder.clone());
      this.finished();
    }
  },
  
  confirm: function (e) {
    e = new Event(e).stop();
    e.preventDefault();
    var p = this;
    this.waiting();
    this.previewform.send({
      method: 'post',
			update: p.subject,
		  onRequest: function () {p.waiting();},
		  onComplete: function () {p.finished();},
		  onFailure: function () {p.failed();}
    });
  },
  
  revise :function (e) {
    e = new Event(e).stop();
    e.preventDefault();
    this.previewholder.hide();
    this.formholder.show();
    this.resizetocontain(this.formholder);
  },
    
  waiting: function () {
    this.formholder.hide();
    this.previewholder.hide();
    this.subject.hide();
    this.wrapper.addClass('waiting');
  },
  
  notWaiting: function () {
    this.wrapper.removeClass('waiting');
  },
  
  finished: function () {
    console.log('finished!')
    if (this.link && !this.link.hasClass('onlyonce')) this.link.show();
    this.notWaiting();
    this.subject.show();
    this.closewrapper();
    flash(this.subject);
  },
  
  cancel: function (e) {
    console.log('cancelled!')
    if (this.link) this.link.show();
    e = new Event(e).stop();
    e.preventDefault();
    this.notWaiting();
    this.subject.show();
    this.closewrapper();
  },
  
  failed: function () {
    console.log('failed!')
    if (this.link) this.link.show();
    this.notWaiting();
    this.subject.show();
    this.closewrapper();
  }
});

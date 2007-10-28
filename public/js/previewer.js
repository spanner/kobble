var Editor = new Class ({
  initialize: function (a, e) {
    this.link = a
	  var tag = a.id.replace('edit_','');
    console.log('eip: tag is' + tag);
    this.subject = $E('#' + tag);
    console.log('eip: subject is');
    console.log(this.subject);
    this.original = this.subject.clone();
    this.dimensions = this.subject.getCoordinates();
    this.fonts = this.subject.getStyles('font-family', 'font-size', 'line-height', 'letter-spacing');
		this.wrapper = new Element('div', {'styles': $extend(this.subject.getStyles('margin'), {'overflow': 'hidden'})}).injectAfter(this.subject).adopt(this.subject);
    this.formholder = new Element('div', {'style': 'display: none;'}).injectTop(this.wrapper);
    this.previewholder = new Element('div', {'style': 'display: none;'}).injectTop(this.wrapper);
		this.getForm();
  },
  
  url: function () {
    return this.link.getProperty('href')
  },
  
  getForm: function () {
    ed = this;
		new Ajax(this.url(), {
			method: 'get',
			update: ed.formholder,
		  onRequest: function () {ed.waiting();},
		  onComplete: function () {ed.gotForm();},
		  onFailure: function () {ed.failed();}
		}).request();
  },
  
  gotForm: function () {
    this.wrapper.addClass('editinplace');
    this.form = $E('form', this.formholder);
    this.form.onsubmit = this.getPreview.bind(this);
    // this.input = this.form.getFirst();
    // this.input.setStyles(this.dimensions);
    // this.input.setStyles(this.fonts);
    // this.input.addClass('editinplace');
    this.notWaiting();
    this.formholder.show();
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
    this.wrapper.removeClass('editinplace');
    this.previewform = $E('form', this.previewholder);
    if (this.previewform) {
      this.wrapper.addClass('preview');
      this.previewform.onsubmit = this.confirm.bind(this);
      console.log(this.previewform);
      $E('a.revise', this.previewholder).onclick = this.revise.bind(this);
  		this.notWaiting();
      this.previewholder.show();
    } else {
      this.previewholder.show();
      flash(this.previewholder);
    }
  },
  
  confirm: function (e) {
    this.wrapper.removeClass('preview');
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
    this.wrapper.removeClass('preview');
    this.wrapper.addClass('editinplace');
    e = new Event(e).stop();
    e.preventDefault();
    this.previewholder.hide();
    this.formholder.show();
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
    this.notWaiting();
    this.formholder.remove();
    this.previewholder.remove();
    this.subject.show();
  },
  
  failed: function () {
    this.wrapper.removeClass('editinplace');
    this.wrapper.removeClass('preview');
    this.wrapper.addClass('editfailed');
    this.notWaiting();
    this.subject.show();
    flash(this.subject);
  }
});

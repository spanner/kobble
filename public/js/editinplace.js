var Editor = new Class ({
  initialize: function (a, e) {
    this.link = a;
	  var tag = a.id.replace('edit_','');
    this.subject = $E('#' + tag);
    this.subject.getParent().show();
    this.dimensions = this.subject.getCoordinates();
    this.fonts = this.subject.getStyles('font-family', 'font-size', 'line-height', 'letter-spacing');
		this.wrapper = new Element('div', {'styles': {'overflow': 'hidden'}, 'class': 'editwrapper'}).injectAfter(this.subject);
    this.formholder = new Element('div', {'style': 'display: none;'}).injectTop(this.wrapper);
    this.previewholder = new Element('div', {'style': 'display: none;'}).injectTop(this.wrapper);
    this.resizer = new Fx.Style(this.wrapper, 'height', {duration:500});
		this.getForm();
  },
  
  request_url: function () {
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
		new Ajax(this.request_url(), {
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
    if (this.link && !this.link.hasClass('onlyonce')) this.link.show();
    this.notWaiting();
    this.subject.show();
    this.closewrapper();
  },
  
  cancel: function (e) {
    if (this.link) this.link.show();
    e = new Event(e).stop();
    e.preventDefault();
    this.notWaiting();
    this.subject.show();
    this.closewrapper();
  },
  
  failed: function () {
    if (this.link) this.link.show();
    this.notWaiting();
    this.subject.show();
    this.closewrapper();
  }
});

var autoforms = [];
var AutoForm = new Class ({
  initialize: function (el, e) {
    this.form = el;
    this.form.onsubmit = this.checkandsubmit.bind(this);
    this.fields = [];
    this.values = {};
    this.changed = [];
    this.waiter = new Element('div', {'class': 'waiter', 'style': 'display: none;'}).injectAfter(this.form);
    this.waiter.setStyles(this.form.getCoordinates());
    autoforms.push(this);
    this.prepare();
  },
  
  prepare: function () {
    af = this;
    $ES("input", this.form).each(function (el, i) {
      af.fields.push(el);
      af.values[el.id] = af.getValue(el);
      switch (el.type) {
        case "checkbox" : 
          el.addEvent('click', function () { af.checkandsubmit(); })
          break;
        case "select" : 
          el.addEvent('change', function () { af.checkandsubmit(); })
          break;
        default : 
          el.addEvent('blur', function () { af.checkandsubmit(); })
      }
    })
  },
  
  diff: function () {
    af = this;
    this.fields.each(function (el, i) {
      if (af.getValue(el) != af.values[el.id]) af.changed.push(el)
    });
    return this.changed;
  },
  
  getValue: function (el) {
    switch (el.type) {
      case "checkbox" : 
        return el.checked;
      case "select" : 
        return el.selectedIndex;
      default : 
        return el.value;
    }
  },
  
  checkandsubmit: function () {
    console.log('checkandsubmit');
    this.diff();
    if (this.changed.length) this.submit();
  },
  
  submit: function (argument) {
    var af = this;
    this.form.send({
      method: 'post',
		  onRequest: function () {af.waiting();},
		  onComplete: function () {af.finished();},
		  onFailure: function () {af.failed();}
    });
  },
  
  waiting: function () {
    this.form.hide();
    this.waiter.show();
  },
  
  notWaiting: function () {
    this.waiter.hide();
    this.form.show();
  },
  
  finished: function () {
    this.notWaiting();
  },
    
  failed: function () {
    this.notWaiting();
    alert('form submission failed');
  }
})
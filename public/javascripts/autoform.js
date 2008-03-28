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
});
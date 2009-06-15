var Chooser = new Class({
  initialize: function(element){
    this.container = element;
    this.choices = [];
    element.getElements('.choice').each(function (el) { this.choices.push(new Choice(el, this)); }, this);
  },
  hideExcept: function (choice) {
    this.choices.each(function (ch) {
      if (ch == choice) ch.show();
      else ch.hide();
    });
  }
});

/* these stretch rightwards on mouseover */

var Choice = new Class({
  initialize: function (element, chooser) {
    this.head = element;
    this.tag = element.id.replace('show_', '');  
    this.body = $(this.tag);
    this.chooser = chooser;
    this.head.addEvent('click', this.pickMe.bindWithEvent(this));
    if (this.head.getProperty('checked')) this.show();
    else this.hide();
  },
  pickMe: function (e) {
    this.chooser.hideExcept(this);
  },
  show: function () {
    this.body.show();
  },
  hide: function () {
    this.body.hide();
  }
});

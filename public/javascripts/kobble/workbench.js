var bench = null;

var Bench = new Class({
  Extends: Catcher,
  initialize: function (element) {
    this.parent(element);
    this.listed = [];
    this.legend = element.getParent().getElement('.explanatory');
    this.controls = element.getParent().getElement('.controls');
    this.setter = this.controls.getElement('a.setter');
    if (this.setter) this.setter.addEvent('click', this.setThese.bindWithEvent(this));
    this.captureList();
    this.toggleControls();
    bench = this;
  },
  captureList: function () {
    this.listed = [];
    this.container.getElements('li').each(function (li) { this.listed.push(new Benched(li)); }, this);
  },
  selected: function () {
    return this.listed.filter(function (benched) { return benched.selected(); });
  },
  anythingSelected: function () {
    return (this.selected().length > 0);
  },
  firstSelection: function () {
    return this.selected()[0];
  },
  lastSelection: function () {
    var selected = this.selected();
    return selected[selected.length-1];
  },
  toggleControls: function () {
    if (this.anythingSelected()) this.showControls();
    else this.hideControls();
  },
  showControls: function () {
    this.legend.fade('out');
    // this.controls.setStyle('top', this.lastSelection().getBottom());
    var y = this.firstSelection().getTop() - window.getScroll().y;      // in kore.js getCoordinates on a fixed element includes scroll
    console.log("setting ", this.controls, " top to", y);
    this.controls.setStyles({'bottom' : 'auto', 'top' : y});
    this.controls.fade('in');
  },
  hideControls: function () {
    this.controls.fade('out');
  },
  refresh: function () {
    this.captureList();
    return true;
  },
  setThese: function (e) {
    k.block(e);
    console.log("making a set from ", this.selected());
    var url = this.setter.get('href');
    var qs = this.selected().map(function (benched) { return 'with[]=' + benched.kobbleID(); });
    url = url + '?' + qs.join('&amp;');
    console.log("making a set with url ", url);
    window.location = url;
  },
  removeThese: function (e) {
    k.block(e);
  }
});

var Benched = new Class({
  initialize: function (element) {
    this.container = element;
    this.checkbox = element.getElement('input');
    this.link = element.getElement('a');
    this.link.addEvent('click', this.toggleSelection.bindWithEvent(this));
    this.title = this.link.get('text');
    if (this.checkbox.get('checked')) this.select();
  },
  toggleSelection: function (e) {
    k.block(e);
    this.selected() ? this.deselect() : this.select();
    bench.toggleControls();
  },
  select: function () {
    this.checkbox.set('checked', true);
    this.container.addClass('selected');
  },
  deselect: function () {
    this.checkbox.set('checked', false);
    this.container.removeClass('selected');
  },
  selected: function () {
    return this.checkbox.get('checked');
  },
  getTop: function () {
    var pos = this.container.getCoordinates();
    return pos.top;
  },
  getBottom: function () {
    var pos = this.container.getCoordinates();
    return pos.top + pos.height;
  },
  kobbleTag: function () {
    return this.container.kobbleTag();
  },
  kobbleID: function () {
    return this.container.kobbleID();
  }
});

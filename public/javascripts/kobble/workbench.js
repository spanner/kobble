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
    this.remover = this.controls.getElement('a.remover');
    if (this.remover) this.remover.addEvent('click', this.removeThese.bindWithEvent(this));
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
  numberSelected: function () {
    return this.selected().length;
  },
  anythingSelected: function () {
    return (this.numberSelected() > 0);
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
    var y = this.firstSelection().getTop() - window.getScroll().y;      // in kore.js getCoordinates on a fixed element includes scroll
    this.controls.setStyles({'bottom' : 'auto', 'top' : y});
    this.controls.fade('in');
  },
  hideControls: function () {
    this.controls.fade('out');
  },
  refresh: function () {
    this.container.getChildren().each(function (el) { k.activate(el); });
    this.captureList();
    
    // would be nice to remember and restore selections here
    
    return true;
  },
  setThese: function (e) {
    k.block(e);
    var url = this.setter.get('href');
    var qs = this.selected().map(function (sel) { return 'with[]=' + sel.kobbleID(); });
    url = url + '?' + qs.join('&amp;');
    window.location = url;
  },
  removeThese: function (e) {
    k.block(e);
    this.hideControls();
    var url = this.remover.get('href');
    this.selected().each(function (sel) { sel.remove(url); });
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
  waiting: function () {
    this.link.addClass('waiting');
  },
  notWaiting: function () {
    this.link.removeClass('waiting');
  },
  remove: function (url) {
    url = url + '/' + this.kobbleID();
    new Request.HTML({
      emulation: true,
      method: 'delete',
      url: url,
      onRequest: this.waiting.bind(this),
      onSuccess: this.destroy.bind(this),
      onFailure: this.removeFailed.bind(this)
    }).send();
  },
  destroy: function (argument) {
    this.deselect();
    this.notWaiting();
    this.container.nix();
    k.announce('Removed ' + this.title + ' from bench');
  },
  removeFailed: function (response) {
    this.notWaiting();
    k.complain("could not unbench " + this.title);
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






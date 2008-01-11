var tabsets = {};
var scratchtabs = [];

var Tab = new Class({
	initialize: function(element){
		this.tabhead = element;
    var parts = element.id.split('_');
		this.tag = parts.pop();
		this.settag = parts.pop();
		this.tabbody = $E('#' + this.settag + '_' + this.tag);
		this.tabset = null;
    this.addToSet();
 		this.tabhead.onclick = this.select.bind(this);
 		this.holdopen = false;
	},
	addToSet: function () {
    this.tabset = tabsets[this.settag] || new TabSet(this.settag);
    this.tabset.addTab(this);
	},
	select: function (e) {
	  e = new Event(e).stop();
	  e.preventDefault();
	  this.tabhead.blur();
    this.tabset.select(this.tag);
	},
	reselect: function (e) {},
	deselect: function (e) {},
  showBody: function(){
    this.tabbody.show();
    this.tabhead.addClass('fg');
  },
  hideBody: function(){
    this.tabbody.hide();
    this.tabhead.removeClass('fg');
  }
});

var TabSet = new Class({
	initialize: function(tag){
	  this.tabs = [];
    this.tag = tag;
	  this.container = $E('#box_' + this.tag);
    this.foreground = null;
    this.resizer = null;
	  tabsets[this.tag] = this;
	},
	addTab: function (tab) {
    this.tabs.push(tab);
    if (this.tabs.length == 1) {
      tab.showBody();
      this.foreground = tab;
    } else {
      tab.hideBody();
    }
	},
	select: function (tag) {
	  if (tag == this.foreground.tag) {
  	  this.reselect();
	  } else {
	    this.foreground.deselect();
  	  tabset = this;
  	  this.tabs.each(function (tab) { 
  	    if (tag == tab.tag) {
  	      tab.showBody();
  	      tabset.foreground = tab;
  	    } else {
          tab.hideBody();
  	    }
  	  });
  	  this.resize();
	  }
	},
	reselect: function (tag) {
	  this.foreground.reselect();
	},
	resizer: function (argument) {
    if (!this.resizer) this.resizer = new Fx.Style(this.container, 'height', {duration:500});
    return this.resizer;
	},
  resize: function () {
    console.log('TabSet.resize');
    var element = this.foreground.tabbody;
    var height = element.getCoordinates()['height'];
    if (height) this.resizer.start(height + 28)
  }
});

var ScratchSet = TabSet.extend({
	initialize: function(tag){
		this.parent(tag);
	  this.container = $E('#scratchpad');
		this.isopen = false;
		var openFX = this.container.effects({duration: 600, transition: Fx.Transitions.Cubic.easeOut});
		var closeFX = this.container.effects({duration: 1000, transition: Fx.Transitions.Bounce.easeOut});
		this.container.addEvents({
      'expand' : function() { 
        openFX.start({
          'top': window.getScrollTop() + 10,
          'height': window.getHeight() - 10
        });
      },
      'contract' : function() { 
        closeFX.start({
          'top': window.getScrollTop() + window.getHeight() - 34, 
          'height': 34
        }); 
      }
    });
	},
  resize: function () {
    if (!this.isopen) this.open();
  },
  open: function (delay) {
    this.container.fireEvent('expand', null, delay);
    this.isopen = true;
	},
	close: function (delay) {
    this.container.fireEvent('contract', null, delay); 
    this.isopen = false;
	},
	toggle: function (delay) {
    this.isopen && !this.holdopen ? this.close(delay) : this.open(delay);
	},
	showRename: function (url) {
    this.foreground.showRename(url);
	}
});

var ScratchTab = Tab.extend({
	initialize: function(element){
		this.parent(element);
  	this.renameform = null;
    this.formholder = new Element('div', {'class': 'renameform bigspinner', 'style': 'height: 0'}).injectTop(this.tabbody).hide();
    this.renamefx = new Fx.Style(this.formholder, 'height', {duration:1000});
    $E('a.rename_pad', this.tabbody).onclick = this.rename.bind(this);
    $E('a.closepad', this.tabbody).onclick = this.close.bind(this);
    scratchtabs.push(this)
  },
  open: function () { this.tabset.open(0); },
	close: function () { 
    this.hideRename();
	  this.tabset.close(0); 
	},
	addToSet: function () {
    this.tabset = tabsets[this.settag] || new ScratchSet(this.settag);
    this.tabset.addTab(this);
	},
	reselect: function (tag) {
    this.tabset.toggle();
	},
	deselect: function () {
    this.hideRename();
	},
	rename: function (e) {
	  e = new Event(e).stop();
    e.preventDefault();
	  var scratchtab = this;
    var url = e.target.getProperty('href');
    this.tabhead.addClass('editing');
    this.formholder.show();
    if (! this.renameform) {
  	  this.renamefx.start(64);
  		new Ajax(url, {
  			method: 'get',
  			update: scratchtab.formholder,
  		  onSuccess: function () { scratchtab.bindRenameForm() },
  		  onFailure: function () { scratchtab.hideRenameNicely(); error('no way'); }
  		}).request();
    }
	},
	hideRenameNicely: function (e) {
    if (e) e = new Event(e).stop();
    var scratchtab = this;
	  this.renamefx.start(0).chain(function () { scratchtab.hideRename(e) });
	},
	hideRename: function (e) {
    if (e) e = new Event(e).stop();
    this.formholder.hide();
    this.tabhead.removeClass('editing');
	},
	bindRenameForm: function () {
    this.formholder.removeClass('bigspinner');
    this.formholder.show();
    this.renameform = $E('form', this.formholder);
		this.renameform.onsubmit = this.doRename.bind(this);
		$E('a.cancel_rename', this.renameform).onclick = this.hideRename.bind(this);
		$E('input', this.renameform).focus();
	},
	doRename: function (e) {
	  e = new Event(e).stop();
	  e.preventDefault();
	  var scratchtab = this;
    this.renameform.hide();
    this.formholder.addClass('bigspinner');
	  this.renameform.send({
      method: 'post',
      update: scratchtab.tabhead,
      onComplete: function () { scratchtab.hideRenameNicely(); }
	  });
	},
	makeReceptiveTo: function (draggee) {
	  var tab = this;
    // console.log('adding mouseenter event to ')
    // console.log(this.tabhead)
	  this.tabset.holdopen = true;
 		this.tabhead.addEvent('mouseenter', function (e) { tab.select(e); });
	},
	makeUnreceptive: function () {
	  this.tabset.holdopen = false;
    this.tabhead.removeEvents('mouseenter');
	},
});

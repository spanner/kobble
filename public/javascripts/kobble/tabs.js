var tabs = [];
var tabsets = {};

var Tab = new Class({
	initialize: function(element){
		this.tabhead = element;
		this.name = this.tabhead.get('text');
    var parts = element.id.split('_');
		this.tag = parts.pop();
		var settag = parts.pop();
		this.tabbody = $(settag + '_' + this.tag);
    this.tabset = tabsets[settag] || new TabSet(settag);
    this.tabset.addTab(this);
 		this.tabhead.onclick = this.select.bind(this);
 		tabs.push(this);
	},
	select: function (e) {
    k.block(e);
	  this.tabhead.blur();
    this.tabset.select(this);
	},
  show: function(){
    this.tabhead.addClass('fg');
    this.tabbody.show();
  },
  hide: function(){
    this.tabbody.hide();
    this.tabhead.removeClass('fg');
  }
});

var TabSet = new Class({
	initialize: function(tag){
	  this.tabs = [];
    this.tag = tag;
    this.foreground = null;
    this.rolling = false;
 		tabsets[this.tag] = this;
	},
	addTab: function (tab) {
    this.tabs.push(tab);
    if (this.tabs.length == 1) {
      tab.show();
      this.foreground = tab;
    } else {
      tab.hide();
    }
	},
	select: function (tab) {
	  this.tabs.each(function (t) { 
	    if (t.tag == tab.tag) {
	      t.show();
	      this.foreground = t;
	    } else {
        t.hide();
	    }
	  }, this);
	}
});

kobble_starters.push(function (scope) {
  if (!scope) scope = document;
  scope.getElementsIncludingSelf('a.tab').each (function (el) { new Tab(el); });
});


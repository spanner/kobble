var tabsets = {};

var Tab = new Class({
	initialize: function(element){
		this.tabhead = element;
    var parts = element.id.split('_');
		this.tag = parts.pop();
		this.settag = parts.pop();
		this.tabbody = $E('#' + this.settag + '_' + this.tag);
    this.tabset = find_tabset(this.settag);   // link id format is tab_[tabsetname]_[tabname]
    this.tabset.addTab(this);
 		this.tabhead.onclick = this.select.bind(this);
	},
	select: function (e) {
	  e = new Event(e).stop();
	  e.preventDefault();
	  this.tabhead.blur();
    this.tabset.select(this.tag);
	},
  showBody: function(){
    this.tabbody.show();
    this.tabhead.addClass('fg');
    this.tabset.resizetocontain(this.tabbody);
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
    this.resizer = new Fx.Style(this.container, 'height', {duration:500});
	  tabsets[this.tag] = this;
	},
	addTab: function (tab) {
    this.tabs.push(tab);
    this.tabs.length > 1 ? tab.hideBody() : tab.showBody();
	},
	select: function (tag) {
	  var shown = null;
	  this.tabs.each(function (t) {
	    tag == t.tag ? t.showBody() : t.hideBody();
	  });
	},
  resizetocontain: function (element) {
    var height = element.getCoordinates()['height'];
    if (height) this.resizer.start(height + 28)
  }
});

function find_tabset (tag) {
  return tabsets[tag] || new TabSet(tag);
}
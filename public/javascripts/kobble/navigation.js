var sitenav = null;
var topz = 0;

function toFront (element) {
  topz = parseInt(topz, 10) + 10;
  element.setStyle('z-index', this.topz);
}

var Navigation = new Class({
  initialize: function(element){
    this.container = element;
    this.menu = [];
    this.container.getElements('li.mi').each(function (li) { this.menu.push(new MenuItem(li, this)); }, this);
    sitenav = this;
  }
});

/* these stretch rightwards on mouseover */

var MenuItem = new Class({
  initialize: function (li, nav) {
    this.name = li.id;
    this.head = li.getElement('.head');
    this.body = li.getElement('.body');
    this.body.set('morph', {duration: 'short'});
    
    var headsize = this.head.getSize();
    var bodysize = this.body.getSize();
    
    console.log(this.name, ' bodysize: ', bodysize);
    
    this.opento = {
      width: bodysize.x + 12,
      height: bodysize.y + 12
    };
    this.closeto = {
      width: headsize.x + 12,
      height: headsize.y + 12
    };
    
    var y = 26 + (nav.menu.length * 16);
    var x = 120 - headsize.x;

    this.head.setStyles({
      position: 'fixed',
      left: x,
      top: y
    });

    this.body.addClass('out');
    this.body.setStyles({
      position: 'fixed',
      left: x-6,
      top: y-4,
      width: headsize.x,
      height: headsize.y
    });
    
    this.head.addEvent('mouseenter', this.enter.bindWithEvent(this));
    this.head.addEvent('mouseleave', this.leave.bindWithEvent(this));
    this.body.addEvent('mouseenter', this.enter.bindWithEvent(this));
    this.body.addEvent('mouseleave', this.leave.bindWithEvent(this));
  },
  
  enter: function (e) {
    toFront(this.body);
    this.body.removeClass('out');
    this.body.addClass('over');
    this.show(e);
  },
  leave: function (e) {
    this.hide(e);
  },
  show: function (e) {
    k.block(e);
    this.interrupt();
    this.body.get('morph').start(this.opento);
  },
  hide: function (e) {
    k.block(e);
    this.interrupt();
    this.body.get('morph').start(this.closeto).chain(this.finishHiding.bind(this));
  },
  interrupt: function () {
    $clear(this.timer);
    this.body.get('morph').cancel();
  },
  hideSoon: function (e) {
    k.block(e);
    this.timer = this.hide.bind(this).delay(1000);
  },
  finishHiding: function () {
    this.body.removeClass('over');
    this.body.addClass('out');
  }
});




var Tab = new Class({
  initialize: function(element){
    this.tabhead = element;
    this.name = this.tabhead.get('text');
    var parts = element.id.split('_');
    this.tag = parts.pop();
    this.settag = parts.pop();
    this.tabbody = $E('#' + this.settag + '_' + this.tag);
    this.tabset = i.tabsets[this.settag] || new TabSet(this.settag);
    this.tabset.addTab(this);
    this.tabhead.addEvent('click', this.select.bindWithEvent(this));
    i.tabs.push(this);
  },
  select: function (e) {
    k.block(e);
    this.tabhead.blur();
    this.tabset.select(this);
  },
  show: function(){
    this.tabhead.addClass('here');
    this.tabbody.show();
  },
  hide: function(){
    this.tabbody.hide();
    this.tabhead.removeClass('here');
  }
});

var TabSet = new Class({
  initialize: function(tag){
    this.tabs = [];
    this.tag = tag;
    this.foreground = null;
    this.rolling = false;
    i.tabsets[this.tag] = this;
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
  },
  next: function (tab) {
    if (!tab) tab = this.foreground;
    var i = this.tabs.indexOf(tab);
    return (i == this.tabs.length-1) ? this.tabs[0] : this.tabs[i+1];
  },
  previous: function (tab) {
    if (!tab) tab = this.foreground;
    var i = this.tabs.indexOf(tab);
    return (i == 0) ? this.tabs.getLast() : this.tabs[i-1];
  },
  showNext: function (e) { 
    k.block(e);
    this.select(this.next()); 
  },
  showPrev: function (e) { 
    k.block(e);
    this.select(this.previous()); 
  },
  play: function () {},
  stop: function () {}
});

var Page = new Class({
  Extends: Tab,
  initialize: function (element) {
    this.tabhead = element;
    this.name = this.tabhead.get('text');
    var parts = element.id.split('_');
    this.tag = parts.pop();
    this.settag = parts.pop();
    this.tabbody = $E('#' + this.settag + '_' + this.tag);
    this.tabset = i.tabsets[this.settag] || new PageSet(this.settag);
    this.tabset.addTab(this);
    this.tabhead.onclick = this.select.bind(this);
    i.tabs.push(this);
  },
  show: function(){
    this.tabhead.addClass('fg');
  },
  hide: function(){
    this.tabhead.removeClass('fg');
  }
});

var PageSet = new Class ({
  Extends: TabSet,
  initialize: function (tag) {
    this.parent(tag);
    this.slidecontainer = $E('#' + this.tag + '_container');
    this.slidecontainer.setStyles({
      width: 10000
    });
    this.slideholder = $E('#' + this.tag + '_scroller');
    this.slideholder.setStyles({
      overflow: 'hidden'
    });
    this.fx = new Fx.Scroll(this.slideholder, {transition: 'cubic:out'});
    var ts = this;
    $$('a.' + this.tag + '_next').each(function (a) { a.onclick = ts.showNext.bind(ts); });
    $$('a.' + this.tag + '_previous').each(function (a) { a.onclick = ts.showPrev.bind(ts); });
    this.timer = null;
    this.play();
  },
  addTab: function (tab) {
    this.tabs.push(tab);
    if (!this.foreground) {
      this.foreground = tab;
      this.selectWithoutStop(tab);
    }
  },
  select: function (tab) {
    this.stop();
    this.selectWithoutStop(tab);
  },
  selectWithoutStop: function (tab) {
    if (!tab || tab == this.foreground) return false;
    tab.show();
    this.fx.toElement(tab.tabbody);
    this.foreground.hide();
    this.foreground = tab;
  },
  play: function (e) {
    k.block(e);
    var pager = this;
    this.rolling = true;
    this.selectWithoutStop(this.next());
    this.timer = window.setInterval( function () { pager.selectWithoutStop(pager.next()); }, 8000 );
    $$('a.stopit').each(function (element) { 
      element.removeClass('paused'); 
      if (element.get('text') != '' ) element.set('text', 'stop bloody moving.');
    });
  },
  stop: function (e) {
    k.block(e);
    if (this.timer) window.clearInterval(this.timer);
    this.rolling = false;
    $$('a.stopit').each(function (element) { 
      element.addClass('paused'); 
      if (element.get('text') != '' ) element.set('text', 'bored now. do something.');
    });
  },
  toggle: function (e) {
    return this.rolling ? this.stop(e) : this.play(e);
  }
});

var BannerAd = new Class({
  initialize: function (element) {
    this.background = element;
    this.foreground = element.getElement('img');
    this.background.addEvent('mouseenter', this.up.bindWithEvent(this));
    this.background.addEvent('mouseleave', this.down.bindWithEvent(this));
    this.down();
  },
  up: function(){
    this.foreground.setStyle('opacity', 1);
  },
  down: function(){
    this.foreground.fade(0.25);
  }
});

var Place = new Class({
  initialize: function (element) {
    
  },
  up: function(){
    this.foreground.setStyle('opacity', 1);
  },
  down: function(){
    this.foreground.fade(0.25);
  }
});


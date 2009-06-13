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
    
    var headsize = this.head.getSize();
    var y = 22 + (nav.menu.length * 18);
    var x = 120 - headsize.x;

    this.head.setStyles({
      position: 'fixed',
      left: x,
      top: y
    });

    this.body.addClass('out');
    this.body.setStyles({
      position: 'fixed',
      left: x-9,
      top: y-7
    });
    
    this.head.addEvent('mouseenter', this.enter.bindWithEvent(this));
    this.head.addEvent('mouseleave', this.leave.bindWithEvent(this));
    this.body.addEvent('mouseenter', this.enter.bindWithEvent(this));
    this.body.addEvent('mouseleave', this.leave.bindWithEvent(this));
  },
  
  enter: function (e) {
    toFront(this.body);
    this.body.fade('in');
  },
  leave: function (e) {
    this.body.fade('out');
  }
});

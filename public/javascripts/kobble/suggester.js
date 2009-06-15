// TagSuggester is just an autocompleter with some options set

var Suggester = new Class ({
  Extends: Autocompleter.Request.JSON,
  initialize: function(element) {
    var collection = element.kobbleID();
    this.parent(element, '/collections/' + collection + '/tags/matching', { 
      indicator: element,     // autocompleter should be edited to add 'waiting' class rather than showing indicator
      postVar: 'stem', 
      multiple: true,
      zIndex: 30000,
      overflow: 'scroll',
      forceSelect: true,
      typeAhead: true,
      className: 'tagsuggestions'
  		
    });
  }
});


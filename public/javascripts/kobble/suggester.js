// TagSuggester is just an autocompleter with some options set

var Suggester = new Class ({
  Extends: Autocompleter.Ajax.Json,
  initialize: function(element) {
    this.parent(element, '/tags/matching', { 
      'indicator': element,     // autocompleter should be edited to add 'waiting' class rather than showing indicator
      'postVar': 'stem', 
      'multiple': true,
      'zIndex': 30000,
      'overflow': 'scroll',
      'forceSelect': true,
      'typeAhead': true
    });
  }
});


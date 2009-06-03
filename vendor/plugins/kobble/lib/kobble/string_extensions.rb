# most of these were originally lifted from has_many_polymorphs 

module Kobble
  module StringExtensions
    require 'redcloth'

    def as_class
      self.classify.constantize
    end

    def titlecase
      self.gsub(/((?:^|\s)[a-z])/) { $1.upcase }
    end
    
    def formatted
      RedCloth.new(self).to_html
    end
  
    def initials(between='')
      self.split(/\s+/).map{ |w| w.chars[0,1] }.join(between)
    end

    def initials_or_beginning(length=5)
      return self.split(/\s+/).size > 1 ? self.initials : self.chars[0,length]
    end
  
  end
end

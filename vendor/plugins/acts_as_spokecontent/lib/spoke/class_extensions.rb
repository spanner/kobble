# most of these were originally lifted from has_many_polymorphs 

module StringExtensions
  require 'redcloth'
  require 'text/format'

  def _as_class
    self.classify.constantize
  end

  def titlecase
    self.gsub(/((?:^|\s)[a-z])/) { $1.upcase }
  end
    
  def formatted
    RedCloth.new(self).to_html
  end
  
  def wrapped_to(width=80, indent=0, first_indent=0)
    formatter = Text::Format.new {
      @columns = 68
      @indent = indent
      @first_indent = first_indent
    }
    self.split( /[\r\n][\r\n\s]+/ ).collect{ |p| formatter.format(p) }.join("\r\n")
  end

  def initials(between='')
    self.split(/\s+/).map{ |w| w.chars[0,1] }.join(between)
  end

  def initials_or_beginning(length=5)
    return self.split(/\s+/).size > 1 ? self.initials : self.chars[0,length]
  end
  
end

String.send :include, StringExtensions
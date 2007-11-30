module StringExtensions
  require 'redcloth'
  require 'text/format'

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
    self.split( /[\r\n][\r\n\s]+/ ).collect{ |p| formatter.format(p) }.join("")
  end
end

String.send :include, StringExtensions
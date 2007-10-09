module StringExtensions
  require 'redcloth'

  def titlecase
    self.gsub(/((?:^|\s)[a-z])/) { $1.upcase }
  end
  
  def formatted
    RedCloth.new(self).to_html
  end
end

String.send :include, StringExtensions
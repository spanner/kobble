# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include Localization
    
  def pretty (textile = '')
    r = RedCloth.new textile
    return r.to_html;
  end
  
  def colour_code (object)
    if object.respond_to?('warnings') && object.warnings.length > 0
      'red'
    elsif object.respond_to?('playto') && ! object.playto && ! object.playfrom
      'yellow'
    else
      'white'
    end
  end
  
  def title_helper
    "#{@controller.controller_class_name} #{@controller.action_name}"
  end
  
end

class PopulatePreferences < ActiveRecord::Migration

  # an initial set of preference choices

  def self.up
    Preference.new({
      :name => 'hover object descriptions',
      :abbr => 'tooltips',
      :description => "With this selected, you can hover the mouse over any item in a list to throw up an explanatory note."
    }).save
    Preference.new({
      :name => 'confirm drag and drop operations',
      :abbr => 'confirmation',
      :description => "Select this if you would rather avoid mistaken drag and drops and don't mind clicking in dialog boxes."
    }).save
    Preference.new({
      :name => 'default to condensed view',
      :abbr => 'condensed',
      :description => "Select this to pack as much as possble into each screenful. Usually works best with the description hovers on."
    }).save
    Preference.new({
      :name => 'notify me of comments',
      :abbr => 'notify_comments',
      :description => "Select this to receive an email whenever someone comments on something you have created or uploaded."
    }).save
    Preference.new({
      :name => 'notify me of use',
      :abbr => 'notify_use',
      :description => "Select this to receive an email whenever someone makes use of something of yours in a set."
    }).save
    Preference.new({
      :name => 'play audio automatically',
      :abbr => 'play_audio',
      :description => "Select this and when audio appears on a page it will start playing as soon as the page loads."
    }).save
    Preference.new({
      :name => 'tabs respond to dragging over',
      :abbr => 'tabs_responsive',
      :description => "Select this and when you are dragging something and move the mouse over a tab it will react as though to a click."
    }).save
  end

  def self.down
    Preference.find(:all).each {|p| p.destroy }
  end
end

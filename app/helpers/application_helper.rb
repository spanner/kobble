# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
    
  def submit_tag(value = "Save Changes", options={} )
    or_option = options.delete(:or)
    return super + "<span class='button_or'>"+"or " + or_option + "</span>" if or_option
    super
  end

  def ajax_spinner_for(id, spinner="spinner.gif")
    "<img src='/images/#{spinner}' style='display:none; vertical-align:middle;' id='#{id.to_s}_spinner'> "
  end

  def avatar_for(user, size=32)
    # image_tag "http://www.gravatar.com/avatar.php?gravatar_id=#{MD5.md5(user.email)}&rating=PG&size=#{size}", :size => "#{size}x#{size}", :class => 'photo'
  end

  def feed_icon_tag(title, url)
    (@feed_icons ||= []) << { :url => url, :title => title }
    link_to image_tag('feed-icon.png', :size => '14x14', :alt => "Subscribe to #{title}"), url
  end

  def search_posts_title
    returning(params[:q].blank? ? 'Recent Posts'[] : "Searching for"[] + " '#{h params[:q]}'") do |title|
      title << " "+'by {user}'[:by_user,h(User.find(params[:user_id]).display_name)] if params[:user_id]
      title << " "+'in {forum}'[:in_forum,h(Forum.find(params[:forum_id]).name)] if params[:forum_id]
    end
  end

  def topic_title_link(topic, options)
    if topic.title =~ /^\[([^\]]{1,15})\]((\s+)\w+.*)/
      "<span class='flag'>#{$1}</span>" + 
      link_to(h($2.strip), topic_path(@forum, topic), options)
    else
      link_to(h(topic.title), topic_path(@forum, topic), options)
    end
  end

  def search_posts_path(rss = false)
    options = params[:q].blank? ? {} : {:q => params[:q]}
    prefix = rss ? 'formatted_' : ''
    options[:format] = 'rss' if rss
    [[:user, :user_id], [:forum, :forum_id]].each do |(route_key, param_key)|
      return send("#{prefix}#{route_key}_posts_path", options.update(param_key => params[param_key])) if params[param_key]
    end
    options[:q] ? all_search_posts_path(options) : send("#{prefix}all_posts_path", options)
  end

  def tag_cloud(size=100, classes=['cloud1','cloud2','cloud3','cloud4','cloud5', 'cloud6'])
    tags = Tag.tags_with_popularity
    max, min = 0, 0
    tags.each { |t|
      max = t.marks_count.to_i if t.marks_count.to_i > max
      min = t.marks_count.to_i if t.marks_count.to_i < min
    }
    divisor = ((max - min) / classes.size) + 1
    tags.each { |t| yield t, classes[(t.marks_count.to_i - min) / divisor] }
  end

  def tagtree
    tags = current_collection.tags
    tags.collect{ |tag| tag.parentage }.sort!
  end
  
end

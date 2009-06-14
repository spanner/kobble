module Kobble
  module UrlExtensions

    def default_url_options(options={})
      { :collection_id => Collection.current } if Collection.current
    end

  end
end
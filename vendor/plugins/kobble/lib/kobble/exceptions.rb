module Kobble
  # kobble error root
  class Error < RuntimeError; end

  # administrative issues
  class CollectionNotChosen < Kobble::Error; end
  class AccessDenied < Kobble::Error; end

  # interface failures
  class CatchError < Kobble::Error; end








end
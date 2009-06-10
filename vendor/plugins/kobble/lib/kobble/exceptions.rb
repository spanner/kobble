module Kobble
  # kobble error root
  class Error < RuntimeError; end

  # catch and drop
  class CatchError < Kobble::Error; end
  class CatchAlreadyPresent < Kobble::CatchError; end
  class DropNotPresent < Kobble::CatchError; end

  # administrative issues
  class CollectionNotChosen < Kobble::Error; end
  class AccessDenied < Kobble::Error; end

  # interface failures
  class CatchError < Kobble::Error; end








end
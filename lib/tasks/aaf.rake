# =============================================================================
# Ferret index-maintenance tasks (and related DRb stuff soon)
# =============================================================================

namespace :ferret do

  desc "Rebuild all ferret indexes. This is necessary to allow multi-model searches."
  task :rebuild => [:environment] do
    Spoke::Config.indexed_classes.each do |s| 
      puts "Rebuilding #{s.pluralize} index. This may take a while."
      s.constantize.rebuild_index 
    end
  end
end
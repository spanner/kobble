# =============================================================================
# Ferret index-maintenance tasks (and related DRb stuff soon)
# =============================================================================

namespace :ferret do

  desc "Rebuild all ferret indexes. This is necessary to allow multi-model searches."
  task :rebuild => [:environment] do
    Spoke::Config.indexed_models.each do |k| 
      puts "Rebuilding #{k.to_s.pluralize} index. This may take a while."
      k.rebuild_index 
    end
  end
end
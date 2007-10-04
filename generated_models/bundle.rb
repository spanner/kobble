
class Bundle

  belongs_to ,
     use
     # called from line 55

  belongs_to ,
     bundletyp
     # called from line 55

  belongs_to ,
     collectio
     # called from line 55

  has_many_polymorphs :members,
     :as => "superbundle",
     :from => [:nodes,
     :people,
     :sources,
     :tags,
     :bundles]
     # called from line 55

  has_many :marks_tags,
     :as => :mark,
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "MarksTag",
     :conditions => nil
     # called from line 55

  has_many :tags,
     :source => :tag,
     :foreign_key => "tag_id",
     :extend => [],
     :limit => nil,
     :order => nil,
     :through => :marks_tags,
     :group => nil,
     :class_name => "Tag",
     :offset => nil
     # called from line 55

  has_many :members_superbundles,
     :foreign_key => "superbundle_id",
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "MembersSuperbundle",
     :conditions => nil
     # called from line 55

  has_many :tags,
     :source => :member,
     :extend => [Bundle::BundleTagPolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :members_superbundles,
     :group => nil,
     :class_name => "Tag",
     :conditions => nil,
     :source_type => "Tag"
     # called from line 55

  has_many :sources,
     :source => :member,
     :extend => [Bundle::BundleSourcePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :members_superbundles,
     :group => nil,
     :class_name => "Source",
     :conditions => nil,
     :source_type => "Source"
     # called from line 55

  has_many :people,
     :source => :member,
     :extend => [Bundle::BundlePersonPolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :members_superbundles,
     :group => nil,
     :class_name => "Person",
     :conditions => nil,
     :source_type => "Person"
     # called from line 55

  has_many :bundles,
     :source => :member,
     :extend => [Bundle::BundleBundlePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :members_superbundles,
     :group => nil,
     :class_name => "Bundle",
     :conditions => nil,
     :source_type => "Bundle"
     # called from line 55

  has_many :nodes,
     :source => :member,
     :extend => [Bundle::BundleNodePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :members_superbundles,
     :group => nil,
     :class_name => "Node",
     :conditions => nil,
     :source_type => "Node"
     # called from line 55

  has_many :members_superbundles_as_child,
     :as => :member,
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "MembersSuperbundle",
     :conditions => nil
     # called from line 55

  has_many :superbundles,
     :source => "superbundle",
     :foreign_key => "superbundle_id",
     :extend => [],
     :limit => nil,
     :order => nil,
     :through => :members_superbundles_as_child,
     :group => nil,
     :class_name => "Bundle",
     :offset => nil
     # called from line 55

  has_many :scraps_scratchpads,
     :as => :scrap,
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "ScrapsScratchpad",
     :conditions => nil
     # called from line 55

  has_many :scratchpads,
     :source => :scratchpad,
     :foreign_key => "scratchpad_id",
     :extend => [],
     :limit => nil,
     :order => nil,
     :through => :scraps_scratchpads,
     :group => nil,
     :class_name => "Scratchpad",
     :offset => nil
     # called from line 55

  has_many :offenders_warnings,
     :as => :offender,
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "OffendersWarning",
     :conditions => nil
     # called from line 55

  has_many :warnings,
     :source => :warning,
     :foreign_key => "warning_id",
     :extend => [],
     :limit => nil,
     :order => nil,
     :through => :offenders_warnings,
     :group => nil,
     :class_name => "Warning",
     :offset => nil
     # called from line 55

  belongs_to ,
     use
     # called from line 55

  belongs_to ,
     bundletyp
     # called from line 55

  belongs_to ,
     collectio
     # called from line 55

  has_many_polymorphs :members,
     :as => "superbundle",
     :from => [:nodes,
     :people,
     :sources,
     :tags,
     :bundles]
     # called from line 55

  has_many :offenders_warnings,
     :as => :offender,
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "OffendersWarning",
     :conditions => nil
     # called from line 55

  has_many :warnings,
     :source => :warning,
     :foreign_key => "warning_id",
     :extend => [],
     :limit => nil,
     :order => nil,
     :through => :offenders_warnings,
     :group => nil,
     :class_name => "Warning",
     :offset => nil
     # called from line 55

  has_many :scraps_scratchpads,
     :as => :scrap,
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "ScrapsScratchpad",
     :conditions => nil
     # called from line 55

  has_many :scratchpads,
     :source => :scratchpad,
     :foreign_key => "scratchpad_id",
     :extend => [],
     :limit => nil,
     :order => nil,
     :through => :scraps_scratchpads,
     :group => nil,
     :class_name => "Scratchpad",
     :offset => nil
     # called from line 55

  has_many :members_superbundles,
     :foreign_key => "superbundle_id",
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "MembersSuperbundle",
     :conditions => nil
     # called from line 55

  has_many :tags,
     :source => :member,
     :extend => [Bundle::BundleTagPolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :members_superbundles,
     :group => nil,
     :class_name => "Tag",
     :conditions => nil,
     :source_type => "Tag"
     # called from line 55

  has_many :sources,
     :source => :member,
     :extend => [Bundle::BundleSourcePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :members_superbundles,
     :group => nil,
     :class_name => "Source",
     :conditions => nil,
     :source_type => "Source"
     # called from line 55

  has_many :people,
     :source => :member,
     :extend => [Bundle::BundlePersonPolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :members_superbundles,
     :group => nil,
     :class_name => "Person",
     :conditions => nil,
     :source_type => "Person"
     # called from line 55

  has_many :bundles,
     :source => :member,
     :extend => [Bundle::BundleBundlePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :members_superbundles,
     :group => nil,
     :class_name => "Bundle",
     :conditions => nil,
     :source_type => "Bundle"
     # called from line 55

  has_many :nodes,
     :source => :member,
     :extend => [Bundle::BundleNodePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :members_superbundles,
     :group => nil,
     :class_name => "Node",
     :conditions => nil,
     :source_type => "Node"
     # called from line 55

  has_many :members_superbundles_as_child,
     :as => :member,
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "MembersSuperbundle",
     :conditions => nil
     # called from line 55

  has_many :superbundles,
     :source => "superbundle",
     :foreign_key => "superbundle_id",
     :extend => [],
     :limit => nil,
     :order => nil,
     :through => :members_superbundles_as_child,
     :group => nil,
     :class_name => "Bundle",
     :offset => nil
     # called from line 55

  has_many :marks_tags,
     :as => :mark,
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "MarksTag",
     :conditions => nil
     # called from line 55

  has_many :tags,
     :source => :tag,
     :foreign_key => "tag_id",
     :extend => [],
     :limit => nil,
     :order => nil,
     :through => :marks_tags,
     :group => nil,
     :class_name => "Tag",
     :offset => nil
     # called from line 55

  belongs_to ,
     use
     # called from line 55

  belongs_to ,
     bundletyp
     # called from line 55

  belongs_to ,
     collectio
     # called from line 55

  has_many_polymorphs :members,
     :as => "superbundle",
     :from => [:nodes,
     :people,
     :sources,
     :tags,
     :bundles]
     # called from line 55

  has_many :offenders_warnings,
     :as => :offender,
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "OffendersWarning",
     :conditions => nil
     # called from line 55

  has_many :warnings,
     :source => :warning,
     :foreign_key => "warning_id",
     :extend => [],
     :limit => nil,
     :order => nil,
     :through => :offenders_warnings,
     :group => nil,
     :class_name => "Warning",
     :offset => nil
     # called from line 55

  has_many :scraps_scratchpads,
     :as => :scrap,
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "ScrapsScratchpad",
     :conditions => nil
     # called from line 55

  has_many :scratchpads,
     :source => :scratchpad,
     :foreign_key => "scratchpad_id",
     :extend => [],
     :limit => nil,
     :order => nil,
     :through => :scraps_scratchpads,
     :group => nil,
     :class_name => "Scratchpad",
     :offset => nil
     # called from line 55

  has_many :members_superbundles,
     :foreign_key => "superbundle_id",
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "MembersSuperbundle",
     :conditions => nil
     # called from line 55

  has_many :tags,
     :source => :member,
     :extend => [Bundle::BundleTagPolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :members_superbundles,
     :group => nil,
     :class_name => "Tag",
     :conditions => nil,
     :source_type => "Tag"
     # called from line 55

  has_many :sources,
     :source => :member,
     :extend => [Bundle::BundleSourcePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :members_superbundles,
     :group => nil,
     :class_name => "Source",
     :conditions => nil,
     :source_type => "Source"
     # called from line 55

  has_many :people,
     :source => :member,
     :extend => [Bundle::BundlePersonPolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :members_superbundles,
     :group => nil,
     :class_name => "Person",
     :conditions => nil,
     :source_type => "Person"
     # called from line 55

  has_many :bundles,
     :source => :member,
     :extend => [Bundle::BundleBundlePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :members_superbundles,
     :group => nil,
     :class_name => "Bundle",
     :conditions => nil,
     :source_type => "Bundle"
     # called from line 55

  has_many :nodes,
     :source => :member,
     :extend => [Bundle::BundleNodePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :members_superbundles,
     :group => nil,
     :class_name => "Node",
     :conditions => nil,
     :source_type => "Node"
     # called from line 55

  has_many :members_superbundles_as_child,
     :as => :member,
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "MembersSuperbundle",
     :conditions => nil
     # called from line 55

  has_many :superbundles,
     :source => "superbundle",
     :foreign_key => "superbundle_id",
     :extend => [],
     :limit => nil,
     :order => nil,
     :through => :members_superbundles_as_child,
     :group => nil,
     :class_name => "Bundle",
     :offset => nil
     # called from line 55

  has_many :marks_tags,
     :as => :mark,
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "MarksTag",
     :conditions => nil
     # called from line 55

  has_many :tags,
     :source => :tag,
     :foreign_key => "tag_id",
     :extend => [],
     :limit => nil,
     :order => nil,
     :through => :marks_tags,
     :group => nil,
     :class_name => "Tag",
     :offset => nil
     # called from line 55

  belongs_to ,
     use
     # called from line 55

  belongs_to ,
     bundletyp
     # called from line 55

  belongs_to ,
     collectio
     # called from line 55

  has_many_polymorphs :members,
     :as => "superbundle",
     :from => [:nodes,
     :people,
     :sources,
     :tags,
     :bundles]
     # called from line 55

  has_many :offenders_warnings,
     :as => :offender,
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "OffendersWarning",
     :conditions => nil
     # called from line 55

  has_many :warnings,
     :source => :warning,
     :foreign_key => "warning_id",
     :extend => [],
     :limit => nil,
     :order => nil,
     :through => :offenders_warnings,
     :group => nil,
     :class_name => "Warning",
     :offset => nil
     # called from line 55

  has_many :scraps_scratchpads,
     :as => :scrap,
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "ScrapsScratchpad",
     :conditions => nil
     # called from line 55

  has_many :scratchpads,
     :source => :scratchpad,
     :foreign_key => "scratchpad_id",
     :extend => [],
     :limit => nil,
     :order => nil,
     :through => :scraps_scratchpads,
     :group => nil,
     :class_name => "Scratchpad",
     :offset => nil
     # called from line 55

  has_many :members_superbundles,
     :foreign_key => "superbundle_id",
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "MembersSuperbundle",
     :conditions => nil
     # called from line 55

  has_many :tags,
     :source => :member,
     :extend => [Bundle::BundleTagPolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :members_superbundles,
     :group => nil,
     :class_name => "Tag",
     :conditions => nil,
     :source_type => "Tag"
     # called from line 55

  has_many :sources,
     :source => :member,
     :extend => [Bundle::BundleSourcePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :members_superbundles,
     :group => nil,
     :class_name => "Source",
     :conditions => nil,
     :source_type => "Source"
     # called from line 55

  has_many :people,
     :source => :member,
     :extend => [Bundle::BundlePersonPolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :members_superbundles,
     :group => nil,
     :class_name => "Person",
     :conditions => nil,
     :source_type => "Person"
     # called from line 55

  has_many :bundles,
     :source => :member,
     :extend => [Bundle::BundleBundlePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :members_superbundles,
     :group => nil,
     :class_name => "Bundle",
     :conditions => nil,
     :source_type => "Bundle"
     # called from line 55

  has_many :nodes,
     :source => :member,
     :extend => [Bundle::BundleNodePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :members_superbundles,
     :group => nil,
     :class_name => "Node",
     :conditions => nil,
     :source_type => "Node"
     # called from line 55

  has_many :members_superbundles_as_child,
     :as => :member,
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "MembersSuperbundle",
     :conditions => nil
     # called from line 55

  has_many :superbundles,
     :source => "superbundle",
     :foreign_key => "superbundle_id",
     :extend => [],
     :limit => nil,
     :order => nil,
     :through => :members_superbundles_as_child,
     :group => nil,
     :class_name => "Bundle",
     :offset => nil
     # called from line 55

  has_many :marks_tags,
     :as => :mark,
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "MarksTag",
     :conditions => nil
     # called from line 55

  has_many :tags,
     :source => :tag,
     :foreign_key => "tag_id",
     :extend => [],
     :limit => nil,
     :order => nil,
     :through => :marks_tags,
     :group => nil,
     :class_name => "Tag",
     :offset => nil
     # called from line 55

end

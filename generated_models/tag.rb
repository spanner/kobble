
class Tag

  belongs_to ,
     use
     # called from line 55

  has_many_polymorphs :marks,
     :from => [:nodes,
     :people,
     :sources,
     :bundles]
     # called from line 55

  has_many :marks_tags,
     :foreign_key => "tag_id",
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "MarksTag",
     :conditions => nil
     # called from line 55

  has_many :sources,
     :source => :mark,
     :extend => [Tag::TagSourcePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :marks_tags,
     :group => nil,
     :class_name => "Source",
     :conditions => nil,
     :source_type => "Source"
     # called from line 55

  has_many :people,
     :source => :mark,
     :extend => [Tag::TagPersonPolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :marks_tags,
     :group => nil,
     :class_name => "Person",
     :conditions => nil,
     :source_type => "Person"
     # called from line 55

  has_many :bundles,
     :source => :mark,
     :extend => [Tag::TagBundlePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :marks_tags,
     :group => nil,
     :class_name => "Bundle",
     :conditions => nil,
     :source_type => "Bundle"
     # called from line 55

  has_many :nodes,
     :source => :mark,
     :extend => [Tag::TagNodePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :marks_tags,
     :group => nil,
     :class_name => "Node",
     :conditions => nil,
     :source_type => "Node"
     # called from line 55

  belongs_to :parent,
     :foreign_key => "parent_id",
     :class_name => "Tag",
     :counter_cache => true
     # called from line 55

  has_many :children,
     :foreign_key => "parent_id",
     :order => "name",
     :dependent => :destroy,
     :class_name => "Tag"
     # called from line 55

  has_many :members_superbundles,
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
     :through => :members_superbundles,
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

  has_many_polymorphs :marks,
     :from => [:nodes,
     :people,
     :sources,
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
     :through => :members_superbundles,
     :group => nil,
     :class_name => "Bundle",
     :offset => nil
     # called from line 55

  has_many :marks_tags,
     :foreign_key => "tag_id",
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "MarksTag",
     :conditions => nil
     # called from line 55

  has_many :sources,
     :source => :mark,
     :extend => [Tag::TagSourcePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :marks_tags,
     :group => nil,
     :class_name => "Source",
     :conditions => nil,
     :source_type => "Source"
     # called from line 55

  has_many :people,
     :source => :mark,
     :extend => [Tag::TagPersonPolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :marks_tags,
     :group => nil,
     :class_name => "Person",
     :conditions => nil,
     :source_type => "Person"
     # called from line 55

  has_many :bundles,
     :source => :mark,
     :extend => [Tag::TagBundlePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :marks_tags,
     :group => nil,
     :class_name => "Bundle",
     :conditions => nil,
     :source_type => "Bundle"
     # called from line 55

  has_many :nodes,
     :source => :mark,
     :extend => [Tag::TagNodePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :marks_tags,
     :group => nil,
     :class_name => "Node",
     :conditions => nil,
     :source_type => "Node"
     # called from line 55

  belongs_to :parent,
     :foreign_key => "parent_id",
     :class_name => "Tag",
     :counter_cache => true
     # called from line 55

  has_many :children,
     :foreign_key => "parent_id",
     :order => "name",
     :dependent => :destroy,
     :class_name => "Tag"
     # called from line 55

  belongs_to ,
     use
     # called from line 55

  has_many_polymorphs :marks,
     :from => [:nodes,
     :people,
     :sources,
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
     :through => :members_superbundles,
     :group => nil,
     :class_name => "Bundle",
     :offset => nil
     # called from line 55

  has_many :marks_tags,
     :foreign_key => "tag_id",
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "MarksTag",
     :conditions => nil
     # called from line 55

  has_many :sources,
     :source => :mark,
     :extend => [Tag::TagSourcePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :marks_tags,
     :group => nil,
     :class_name => "Source",
     :conditions => nil,
     :source_type => "Source"
     # called from line 55

  has_many :people,
     :source => :mark,
     :extend => [Tag::TagPersonPolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :marks_tags,
     :group => nil,
     :class_name => "Person",
     :conditions => nil,
     :source_type => "Person"
     # called from line 55

  has_many :bundles,
     :source => :mark,
     :extend => [Tag::TagBundlePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :marks_tags,
     :group => nil,
     :class_name => "Bundle",
     :conditions => nil,
     :source_type => "Bundle"
     # called from line 55

  has_many :nodes,
     :source => :mark,
     :extend => [Tag::TagNodePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :marks_tags,
     :group => nil,
     :class_name => "Node",
     :conditions => nil,
     :source_type => "Node"
     # called from line 55

  belongs_to :parent,
     :foreign_key => "parent_id",
     :class_name => "Tag",
     :counter_cache => true
     # called from line 55

  has_many :children,
     :foreign_key => "parent_id",
     :order => "name",
     :dependent => :destroy,
     :class_name => "Tag"
     # called from line 55

  belongs_to ,
     use
     # called from line 55

  has_many_polymorphs :marks,
     :from => [:nodes,
     :people,
     :sources,
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
     :through => :members_superbundles,
     :group => nil,
     :class_name => "Bundle",
     :offset => nil
     # called from line 55

  has_many :marks_tags,
     :foreign_key => "tag_id",
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "MarksTag",
     :conditions => nil
     # called from line 55

  has_many :sources,
     :source => :mark,
     :extend => [Tag::TagSourcePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :marks_tags,
     :group => nil,
     :class_name => "Source",
     :conditions => nil,
     :source_type => "Source"
     # called from line 55

  has_many :people,
     :source => :mark,
     :extend => [Tag::TagPersonPolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :marks_tags,
     :group => nil,
     :class_name => "Person",
     :conditions => nil,
     :source_type => "Person"
     # called from line 55

  has_many :bundles,
     :source => :mark,
     :extend => [Tag::TagBundlePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :marks_tags,
     :group => nil,
     :class_name => "Bundle",
     :conditions => nil,
     :source_type => "Bundle"
     # called from line 55

  has_many :nodes,
     :source => :mark,
     :extend => [Tag::TagNodePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :marks_tags,
     :group => nil,
     :class_name => "Node",
     :conditions => nil,
     :source_type => "Node"
     # called from line 55

  belongs_to :parent,
     :foreign_key => "parent_id",
     :class_name => "Tag",
     :counter_cache => true
     # called from line 55

  has_many :children,
     :foreign_key => "parent_id",
     :order => "name",
     :dependent => :destroy,
     :class_name => "Tag"
     # called from line 55

end

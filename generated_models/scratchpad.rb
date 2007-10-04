
class Scratchpad

  belongs_to ,
     use
     # called from line 55

  has_many_polymorphs :scraps,
     :from => [:nodes,
     :people,
     :sources,
     :tags,
     :bundles]
     # called from line 55

  has_many :scraps_scratchpads,
     :foreign_key => "scratchpad_id",
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "ScrapsScratchpad",
     :conditions => nil
     # called from line 55

  has_many :tags,
     :source => :scrap,
     :extend => [Scratchpad::ScratchpadTagPolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :scraps_scratchpads,
     :group => nil,
     :class_name => "Tag",
     :conditions => nil,
     :source_type => "Tag"
     # called from line 55

  has_many :sources,
     :source => :scrap,
     :extend => [Scratchpad::ScratchpadSourcePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :scraps_scratchpads,
     :group => nil,
     :class_name => "Source",
     :conditions => nil,
     :source_type => "Source"
     # called from line 55

  has_many :people,
     :source => :scrap,
     :extend => [Scratchpad::ScratchpadPersonPolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :scraps_scratchpads,
     :group => nil,
     :class_name => "Person",
     :conditions => nil,
     :source_type => "Person"
     # called from line 55

  has_many :bundles,
     :source => :scrap,
     :extend => [Scratchpad::ScratchpadBundlePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :scraps_scratchpads,
     :group => nil,
     :class_name => "Bundle",
     :conditions => nil,
     :source_type => "Bundle"
     # called from line 55

  has_many :nodes,
     :source => :scrap,
     :extend => [Scratchpad::ScratchpadNodePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :scraps_scratchpads,
     :group => nil,
     :class_name => "Node",
     :conditions => nil,
     :source_type => "Node"
     # called from line 55

  belongs_to ,
     use
     # called from line 55

  has_many_polymorphs :scraps,
     :from => [:nodes,
     :people,
     :sources,
     :tags,
     :bundles]
     # called from line 55

  has_many :scraps_scratchpads,
     :foreign_key => "scratchpad_id",
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "ScrapsScratchpad",
     :conditions => nil
     # called from line 55

  has_many :tags,
     :source => :scrap,
     :extend => [Scratchpad::ScratchpadTagPolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :scraps_scratchpads,
     :group => nil,
     :class_name => "Tag",
     :conditions => nil,
     :source_type => "Tag"
     # called from line 55

  has_many :sources,
     :source => :scrap,
     :extend => [Scratchpad::ScratchpadSourcePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :scraps_scratchpads,
     :group => nil,
     :class_name => "Source",
     :conditions => nil,
     :source_type => "Source"
     # called from line 55

  has_many :people,
     :source => :scrap,
     :extend => [Scratchpad::ScratchpadPersonPolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :scraps_scratchpads,
     :group => nil,
     :class_name => "Person",
     :conditions => nil,
     :source_type => "Person"
     # called from line 55

  has_many :bundles,
     :source => :scrap,
     :extend => [Scratchpad::ScratchpadBundlePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :scraps_scratchpads,
     :group => nil,
     :class_name => "Bundle",
     :conditions => nil,
     :source_type => "Bundle"
     # called from line 55

  has_many :nodes,
     :source => :scrap,
     :extend => [Scratchpad::ScratchpadNodePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :scraps_scratchpads,
     :group => nil,
     :class_name => "Node",
     :conditions => nil,
     :source_type => "Node"
     # called from line 55

  belongs_to ,
     use
     # called from line 55

  has_many_polymorphs :scraps,
     :from => [:nodes,
     :people,
     :sources,
     :tags,
     :bundles]
     # called from line 55

  has_many :scraps_scratchpads,
     :foreign_key => "scratchpad_id",
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "ScrapsScratchpad",
     :conditions => nil
     # called from line 55

  has_many :tags,
     :source => :scrap,
     :extend => [Scratchpad::ScratchpadTagPolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :scraps_scratchpads,
     :group => nil,
     :class_name => "Tag",
     :conditions => nil,
     :source_type => "Tag"
     # called from line 55

  has_many :sources,
     :source => :scrap,
     :extend => [Scratchpad::ScratchpadSourcePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :scraps_scratchpads,
     :group => nil,
     :class_name => "Source",
     :conditions => nil,
     :source_type => "Source"
     # called from line 55

  has_many :people,
     :source => :scrap,
     :extend => [Scratchpad::ScratchpadPersonPolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :scraps_scratchpads,
     :group => nil,
     :class_name => "Person",
     :conditions => nil,
     :source_type => "Person"
     # called from line 55

  has_many :bundles,
     :source => :scrap,
     :extend => [Scratchpad::ScratchpadBundlePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :scraps_scratchpads,
     :group => nil,
     :class_name => "Bundle",
     :conditions => nil,
     :source_type => "Bundle"
     # called from line 55

  has_many :nodes,
     :source => :scrap,
     :extend => [Scratchpad::ScratchpadNodePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :scraps_scratchpads,
     :group => nil,
     :class_name => "Node",
     :conditions => nil,
     :source_type => "Node"
     # called from line 55

  belongs_to ,
     use
     # called from line 55

  has_many_polymorphs :scraps,
     :from => [:nodes,
     :people,
     :sources,
     :tags,
     :bundles]
     # called from line 55

  has_many :scraps_scratchpads,
     :foreign_key => "scratchpad_id",
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "ScrapsScratchpad",
     :conditions => nil
     # called from line 55

  has_many :tags,
     :source => :scrap,
     :extend => [Scratchpad::ScratchpadTagPolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :scraps_scratchpads,
     :group => nil,
     :class_name => "Tag",
     :conditions => nil,
     :source_type => "Tag"
     # called from line 55

  has_many :sources,
     :source => :scrap,
     :extend => [Scratchpad::ScratchpadSourcePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :scraps_scratchpads,
     :group => nil,
     :class_name => "Source",
     :conditions => nil,
     :source_type => "Source"
     # called from line 55

  has_many :people,
     :source => :scrap,
     :extend => [Scratchpad::ScratchpadPersonPolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :scraps_scratchpads,
     :group => nil,
     :class_name => "Person",
     :conditions => nil,
     :source_type => "Person"
     # called from line 55

  has_many :bundles,
     :source => :scrap,
     :extend => [Scratchpad::ScratchpadBundlePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :scraps_scratchpads,
     :group => nil,
     :class_name => "Bundle",
     :conditions => nil,
     :source_type => "Bundle"
     # called from line 55

  has_many :nodes,
     :source => :scrap,
     :extend => [Scratchpad::ScratchpadNodePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :scraps_scratchpads,
     :group => nil,
     :class_name => "Node",
     :conditions => nil,
     :source_type => "Node"
     # called from line 55

end

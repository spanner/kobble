
class Node

  belongs_to ,
     sourc
     # called from line 55

  belongs_to ,
     use
     # called from line 55

  belongs_to ,
     perso
     # called from line 55

  belongs_to ,
     collectio
     # called from line 55

  has_and_belongs_to_many ,
     peopl
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
     sourc
     # called from line 55

  belongs_to ,
     use
     # called from line 55

  belongs_to ,
     perso
     # called from line 55

  belongs_to ,
     collectio
     # called from line 55

  has_and_belongs_to_many ,
     peopl
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
     sourc
     # called from line 55

  belongs_to ,
     use
     # called from line 55

  belongs_to ,
     perso
     # called from line 55

  belongs_to ,
     collectio
     # called from line 55

  has_and_belongs_to_many ,
     peopl
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
     sourc
     # called from line 55

  belongs_to ,
     use
     # called from line 55

  belongs_to ,
     perso
     # called from line 55

  belongs_to ,
     collectio
     # called from line 55

  has_and_belongs_to_many ,
     peopl
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

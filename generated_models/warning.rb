
class Warning

  belongs_to ,
     use
     # called from line 55

  belongs_to ,
     warningtyp
     # called from line 55

  has_many_polymorphs :offenders,
     :from => [:nodes,
     :people,
     :sources,
     :tags,
     :bundles]
     # called from line 55

  has_many :offenders_warnings,
     :foreign_key => "warning_id",
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "OffendersWarning",
     :conditions => nil
     # called from line 55

  has_many :tags,
     :source => :offender,
     :extend => [Warning::WarningTagPolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :offenders_warnings,
     :group => nil,
     :class_name => "Tag",
     :conditions => nil,
     :source_type => "Tag"
     # called from line 55

  has_many :sources,
     :source => :offender,
     :extend => [Warning::WarningSourcePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :offenders_warnings,
     :group => nil,
     :class_name => "Source",
     :conditions => nil,
     :source_type => "Source"
     # called from line 55

  has_many :people,
     :source => :offender,
     :extend => [Warning::WarningPersonPolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :offenders_warnings,
     :group => nil,
     :class_name => "Person",
     :conditions => nil,
     :source_type => "Person"
     # called from line 55

  has_many :bundles,
     :source => :offender,
     :extend => [Warning::WarningBundlePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :offenders_warnings,
     :group => nil,
     :class_name => "Bundle",
     :conditions => nil,
     :source_type => "Bundle"
     # called from line 55

  has_many :nodes,
     :source => :offender,
     :extend => [Warning::WarningNodePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :offenders_warnings,
     :group => nil,
     :class_name => "Node",
     :conditions => nil,
     :source_type => "Node"
     # called from line 55

  belongs_to ,
     use
     # called from line 55

  belongs_to ,
     warningtyp
     # called from line 55

  has_many_polymorphs :offenders,
     :from => [:nodes,
     :people,
     :sources,
     :tags,
     :bundles]
     # called from line 55

  has_many :offenders_warnings,
     :foreign_key => "warning_id",
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "OffendersWarning",
     :conditions => nil
     # called from line 55

  has_many :tags,
     :source => :offender,
     :extend => [Warning::WarningTagPolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :offenders_warnings,
     :group => nil,
     :class_name => "Tag",
     :conditions => nil,
     :source_type => "Tag"
     # called from line 55

  has_many :sources,
     :source => :offender,
     :extend => [Warning::WarningSourcePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :offenders_warnings,
     :group => nil,
     :class_name => "Source",
     :conditions => nil,
     :source_type => "Source"
     # called from line 55

  has_many :people,
     :source => :offender,
     :extend => [Warning::WarningPersonPolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :offenders_warnings,
     :group => nil,
     :class_name => "Person",
     :conditions => nil,
     :source_type => "Person"
     # called from line 55

  has_many :bundles,
     :source => :offender,
     :extend => [Warning::WarningBundlePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :offenders_warnings,
     :group => nil,
     :class_name => "Bundle",
     :conditions => nil,
     :source_type => "Bundle"
     # called from line 55

  has_many :nodes,
     :source => :offender,
     :extend => [Warning::WarningNodePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :offenders_warnings,
     :group => nil,
     :class_name => "Node",
     :conditions => nil,
     :source_type => "Node"
     # called from line 55

  belongs_to ,
     use
     # called from line 55

  belongs_to ,
     warningtyp
     # called from line 55

  has_many_polymorphs :offenders,
     :from => [:nodes,
     :people,
     :sources,
     :tags,
     :bundles]
     # called from line 55

  has_many :offenders_warnings,
     :foreign_key => "warning_id",
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "OffendersWarning",
     :conditions => nil
     # called from line 55

  has_many :tags,
     :source => :offender,
     :extend => [Warning::WarningTagPolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :offenders_warnings,
     :group => nil,
     :class_name => "Tag",
     :conditions => nil,
     :source_type => "Tag"
     # called from line 55

  has_many :sources,
     :source => :offender,
     :extend => [Warning::WarningSourcePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :offenders_warnings,
     :group => nil,
     :class_name => "Source",
     :conditions => nil,
     :source_type => "Source"
     # called from line 55

  has_many :people,
     :source => :offender,
     :extend => [Warning::WarningPersonPolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :offenders_warnings,
     :group => nil,
     :class_name => "Person",
     :conditions => nil,
     :source_type => "Person"
     # called from line 55

  has_many :bundles,
     :source => :offender,
     :extend => [Warning::WarningBundlePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :offenders_warnings,
     :group => nil,
     :class_name => "Bundle",
     :conditions => nil,
     :source_type => "Bundle"
     # called from line 55

  has_many :nodes,
     :source => :offender,
     :extend => [Warning::WarningNodePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :offenders_warnings,
     :group => nil,
     :class_name => "Node",
     :conditions => nil,
     :source_type => "Node"
     # called from line 55

  belongs_to ,
     use
     # called from line 55

  belongs_to ,
     warningtyp
     # called from line 55

  has_many_polymorphs :offenders,
     :from => [:nodes,
     :people,
     :sources,
     :tags,
     :bundles]
     # called from line 55

  has_many :offenders_warnings,
     :foreign_key => "warning_id",
     :extend => [],
     :order => nil,
     :dependent => :destroy,
     :class_name => "OffendersWarning",
     :conditions => nil
     # called from line 55

  has_many :tags,
     :source => :offender,
     :extend => [Warning::WarningTagPolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :offenders_warnings,
     :group => nil,
     :class_name => "Tag",
     :conditions => nil,
     :source_type => "Tag"
     # called from line 55

  has_many :sources,
     :source => :offender,
     :extend => [Warning::WarningSourcePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :offenders_warnings,
     :group => nil,
     :class_name => "Source",
     :conditions => nil,
     :source_type => "Source"
     # called from line 55

  has_many :people,
     :source => :offender,
     :extend => [Warning::WarningPersonPolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :offenders_warnings,
     :group => nil,
     :class_name => "Person",
     :conditions => nil,
     :source_type => "Person"
     # called from line 55

  has_many :bundles,
     :source => :offender,
     :extend => [Warning::WarningBundlePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :offenders_warnings,
     :group => nil,
     :class_name => "Bundle",
     :conditions => nil,
     :source_type => "Bundle"
     # called from line 55

  has_many :nodes,
     :source => :offender,
     :extend => [Warning::WarningNodePolymorphicChildAssociationExtension],
     :order => nil,
     :limit => nil,
     :through => :offenders_warnings,
     :group => nil,
     :class_name => "Node",
     :conditions => nil,
     :source_type => "Node"
     # called from line 55

end

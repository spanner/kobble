module NodesHelper
	$people = Person.find(:all, :order => 'name').map {|u| [u.name, u.id]}
	$possibletypes =  %w{Image Clip Passage}
	
end

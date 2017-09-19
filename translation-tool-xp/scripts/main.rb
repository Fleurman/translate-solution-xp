#==============================================================================
# Main
#------------------------------------------------------------------------------
#==============================================================================

begin
	
	$DIR = Dir.getwd
	$ROOT = File.dirname($DIR)
	$fontname = "Consolas"
	$busy = false
	$help_text = ""
	
	require "#{$DIR}/scripts/windows.rb"
	
	require "#{$DIR}/scripts/module_cache.rb"
	require "#{$DIR}/scripts/module_import.rb"
	require "#{$DIR}/scripts/module_extract.rb"
	require "#{$DIR}/scripts/module_texts.rb"
	
	require "#{$DIR}/scripts/scene.rb"
	
	Extract::get_maps_array
	
	$scene = Scene.new
	
  while $scene != nil
    $scene.main
  end
  
  Graphics.transition(0)
  $FULLSCR = false
  
  # rescue Errno::ENOENT
  # filename = $!.message.sub("Ne trouve pas le fichier ou le repertoire - ", "")
  # print("Le ficher #{filename} n'a pas etet trouve")

end
#==============================================================================
# Main
#------------------------------------------------------------------------------
#==============================================================================

def load_data(filename)
  File.open(filename, 'rb') { |data| Marshal.load(data) }
end

#begin

	$DIR = Dir.getwd
	$ROOT = File.dirname($DIR)
	$fontname = "Consolas"
	$busy = false
	$help_text = ""
	
	require "#{$DIR}/data/scripts/windows.rb"
	
	require "#{$DIR}/data/scripts/module_cache.rb"
	require "#{$DIR}/data/scripts/module_import.rb"
	require "#{$DIR}/data/scripts/module_extract.rb"
	require "#{$DIR}/data/scripts/module_texts.rb"
	
	require "#{$DIR}/data/scripts/scene.rb"
	
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

#end
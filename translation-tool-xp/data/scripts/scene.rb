#==============================================================================

class Scene
 
#------------------------------------------------------------------------
# INITIALIZE
#------------------------------------------------------------------------
  def initialize
		@index = 0
		@window = Window_Base.new(0,0,640,480)
		@window.title("Translate Tool XP",35)
		@window.active = true
		@icons = [Sprite.new,Sprite.new]
		@help = Window_Help.new
		@select_menu = Window_SelectMenu.new
		@win_append = Window_Append.new
		draw_items
		#draw_icons
		$help_text = Texts::help[@index]
		$new = ""
		@help.refresh
  end
  
#------------------------------------------------------------------------
# UPDATE
#------------------------------------------------------------------------
	def draw_items
		@window.item(Rect.new(0,0,96,20),Texts::gui[0],1,20)
		@window.item(Rect.new(0,20,96,20),Texts::gui[1],1,20)
		a = Texts::items
		for i in 0..a.size-1
			ali = i%2 == 0 ? 0 : 2
			@window.item(get_rect(i),a[i],ali)
		end
	end
	
	def draw_icons
		@window.icon(132,310,RPG::Cache.img("Extract"))
		@window.icon(410,310,RPG::Cache.img("Import"))
	end
	
#------------------------------------------------------------------------
# UPDATE
#------------------------------------------------------------------------
	def get_rect(id)
		c = (id/2)-0.5
		c.truncate
		m = (id)%2
		r = Rect.new(0,0,216,48)
		r.x = 80 + 228*m
		r.y = 118 + 52*c
		r
	end
	
#------------------------------------------------------------------------
# MAIN
#------------------------------------------------------------------------
  def main
      Graphics.transition(10)
		
    loop do
      Graphics.update
      Input.update
      update
      if $scene != self
        break
      end
    end
    
    Graphics.freeze
  end
  
#------------------------------------------------------------------------
# UPDATE
#------------------------------------------------------------------------
	def update_cursor_rect
		rect = @index < 0 ? Rect.new(0,0+20*(@index+2),96,20) : get_rect(@index)
		@window.cursor_rect.set(rect.x-6,rect.y,rect.width+12,rect.height)
	end
	
#------------------------------------------------------------------------
# UPDATE
#------------------------------------------------------------------------
  def update
		@window.update
		@select_menu.update if @select_menu.visible
		@win_append.update if @win_append.visible
		
		return if $busy
		
		if Input.trigger?(Input::RIGHT) && @index >= 0
			@index = @index%2 == 0 ? @index+1 : @index-1
			$help_text = Texts::help[@index]
			@help.refresh
		elsif Input.trigger?(Input::LEFT) && @index >= 0
			@index = @index%2 == 0 ? @index+1 : @index-1
			$help_text = Texts::help[@index]
			@help.refresh
		elsif Input.trigger?(Input::UP)
			if @index < 0
				@index = @index == -2 ? -1 : -2
			else
				@index = @index < 2 ? @index+4 : @index-2
			end
			$help_text = Texts::help[@index]
			@help.refresh
		elsif Input.trigger?(Input::DOWN)
			if @index < 0
				@index = @index == -2 ? -1 : -2
			else
				@index = @index > 3 ? @index-4 : @index+2
			end
			$help_text = Texts::help[@index]
			@help.refresh
		end
		
		if Input.trigger?(Input::C)
			if @index == -2
				$scene = nil
			elsif @index == -1
				print("Work In Progress")
				Input.update
			elsif @index == 0
				$busy = true
				@select_menu.open("extract")
				@window.cursor_rect.empty
				$help_text = Texts::help[-6]
				@help.refresh
				Input.update
			elsif @index == 1
				@select_menu.open("import")
				@window.cursor_rect.empty
				$help_text = Texts::help[-6]
				@help.refresh
				$busy = true
				Input.update
			elsif @index == 2
				@win_append.open("all")
				loop do 
					Graphics.update
					Input.update
					@win_append.update
					break if !@win_append.visible
				end
			elsif @index == 3
				Import::import_all_maps
				Input.update
			elsif @index == 4
			
				@win_append.open("commons")
				loop do 
					Graphics.update
					Input.update
					@win_append.update
					break if !@win_append.visible
				end
				
				# Extract::extract_comm_events
				# Input.update
			elsif @index == 5
				#print("Work In Progress")
				Import::import_all_common_events
				Input.update
			end
		elsif Input.trigger?(Input::SHIFT)
			@index = @index < 0 ? 0 : -2
			$help_text = Texts::help[@index]
			@help.refresh
		end
		
		update_cursor_rect
  end
	
#------------------------------------------------------------------------
# UPDATE
#------------------------------------------------------------------------
	def refresh
		$help_text = Texts::help[@index]
		@help.refresh
	end
  
	def help
		@help
	end
	
	def select_menu
		@select_menu
	end
	
#==============================================================================
# END TAG
#==============================================================================
end
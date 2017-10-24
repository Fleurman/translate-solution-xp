#========================================================================
# = Window_Base
#========================================================================
#		Check in '%Parent Folder%/Data' for the 'MapXXX.rxdata' files
#		then makes an array of the Maps that contain some text.
#========================================================================

class Window_Base < Window
	
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------

	def initialize(x, y, width, height)
		super()
		self.contents = Bitmap.new(width,height)
		self.windowskin = RPG::Cache.img("Window")
		self.contents.font.name = $fontname
		self.x = x
		self.y = y
		self.width = width
		self.height = height
		self.z = 100
	end

	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def dispose
		if self.contents != nil
		  self.contents.dispose
		end
		super
	end

	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def color
		return Color.new(30, 30, 30)
	end

	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def title(text,size=22,color=color)
		self.contents.clear
		self.contents.font.size = size
		self.contents.font.color = color
		self.contents.draw_text(0,12,self.width-36,size,text,1)
		self.contents.draw_text(0,size,self.width-36,size,
		 "---------------------------------------------",1)
	end
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def text(text,align,size=22,color=color)
		self.contents.clear
		self.contents.font.size = size
		self.contents.font.color = color
		self.contents.draw_text(0,12,self.width-36,size,text,align)
	end

	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def item(rect,text,align=1,size=22,color=color)
		self.contents.font.size = size
		self.contents.font.color = color
		self.contents.draw_text(rect.x,rect.y,rect.width,rect.height,text,align)
	end
  
	def icon(x,y,bitmap)
		self.contents.blt(x,y,bitmap,bitmap.rect)
	end
#==============================================================================
# END OF Window_Base
#==============================================================================
end

#========================================================================
# = Window_Progress
#========================================================================
#		Check in '%Parent Folder%/Data' for the 'MapXXX.rxdata' files
#		then makes an array of the Maps that contain some text.
#========================================================================

class Window_Progress < Window_Base
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize
		super(160, 208, 320, 64)
		@spr = Sprite.new
		@spr.z = 200
		@spr.bitmap = Bitmap.new(640,480)
		@spr.bitmap.fill_rect(0,0,640,480,Color.new(0,0,0,30))
		self.windowskin = RPG::Cache.img("Progress")
		self.z = 201
  end
	
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def rate(v)
		v.to_i
		self.contents.clear
		for i in 0..100
			if i <= v
				self.contents.fill_rect(0+i*3,12,2,32,green)
			end
		end
	end
	
	def green
		Color.new(200,180,80)
	end
	
	def dispose
		@spr.dispose
		super
	end
	
#==============================================================================
# END OF Window_Progress
#==============================================================================
end

#========================================================================
# = Window_Help
#========================================================================
#		Check in '%Parent Folder%/Data' for the 'MapXXX.rxdata' files
#		then makes an array of the Maps that contain some text.
#========================================================================

class Window_Help < Window_Base
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize
		super(0, 346, 640, 148)
		#self.contents.font.name = $fontname
		self.contents.font.size = 30
		self.contents.font.color = Color.new(150,150,150)
		self.windowskin = nil
  end
	
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def refresh
		self.contents.clear
		self.contents.font.size = 20
		self.contents.draw_text(0,-6,616,20,
		"----------------------------------------------------------",1)
		self.contents.font.size = 30
		t = format_text
		i = 0
		t.each{|s|
		self.contents.draw_text(0,20+30*i,616,30,s,1)
		i += 1
		}
	end
	
	def format_text
		t = $help_text.split
		nt = ["","","","","",""]
		i = 0
		t.each {|w|
		if self.contents.text_size(nt[i]).width <= 500
			nt[i] += w + " "
		else
			i += 1
			nt[i] += w + " "
		end
		}
		return nt
	end
#==============================================================================
# END OF Window_Help
#==============================================================================
end

#========================================================================
# = Window_MapName
#========================================================================
#
#========================================================================

class Window_MapName < Window_Base
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize
		super(-16, 54, 656, 408)
		self.z = 202
		#self.contents.font.name = $fontname
		self.contents.font.size = 20
		self.contents.font.color = Color.new(150,150,150)
		self.windowskin = nil
		@current = ""
		@names = []
  end
	
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def refresh
		self.contents.clear
		self.contents.draw_text(0,0,640,32,@current,1)
#		self.contents.font.size = 11
#		self.contents.font.color = Color.new(220, 150, 80)
#		nb = @names.size-1 <= 60 ? @names.size-1 : 60
#		for i in 0..nb
#			if i <= 26
#				self.contents.draw_text(4,11*i,100,11,@names[i])
#			else
#				self.contents.draw_text(550,-312+11*i,100,11,@names[i])
#			end
#		end
	end
	
	def current(v)
		@current = v
		refresh
	end
	
	def add(v)
		@names.push(v)
		refresh
	end
	
	def sub(v)
		@names.delete(v)
		refresh
	end
#==============================================================================
# END OF Window_MapName
#==============================================================================
end

#========================================================================
# = Window_Select
#========================================================================
#		Check in '%Parent Folder%/Data' for the 'MapXXX.rxdata' files
#		then makes an array of the Maps that contain some text.
#========================================================================

class Window_Select < Window_Base
	
	attr_accessor				:mode
	
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize
		super(84, 86, 466, 480)
		self.height = 246
		self.visible = false
		self.z = 110
		#self.contents.font.name = $fontname
		self.contents.font.size = 22
		self.contents.font.color = color
		self.windowskin = RPG::Cache.img("Select")
		@index = 1
		@line_dex = 0
		@states = []
		@lines = []
		@mode = "select"
		@scroll = 0
		for i in 0..$maps-1
			@states[i] = false
			@lines[i*0.1] = false if (i)%10 == 0
		end
		#p($maps,@states.size)
		
		@arrows = Sprite.new
		@arrows.visible = self.visible
		@arrows.x = 522
		@arrows.y = 97
		@arrows.z = 110
		@arrows.bitmap = Bitmap.new(28,246)
		@arrows.bitmap.font.color = Color.new(220, 150, 80)
		
		@name = Window_MapName.new
		
		refresh
  end
	
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def refresh
		self.contents.clear
		check_lines
		for i in 1..$maps
			r = get_rect(i)
			if @states[i]
				self.contents.font.color = Color.new(220, 220, 20)
				self.contents.font.bold = true
			else
				self.contents.font.color = Color.new(60, 60, 60)
				self.contents.font.bold = false
			end
			self.contents.draw_text(r.x+18,r.y,40,20,$maps_id[i-1].to_s,1)
			self.contents.font.bold = false
		end
		self.contents.font.size = 28
		calc = ($maps*0.1).truncate
		for i in 0..@lines.size-1
			y = i*24
			if @lines[i]
				self.contents.font.color = Color.new(220, 150, 80)
				self.contents.draw_text(0,y-6,28,28,"x")
			else
				self.contents.font.color = Color.new(60, 60, 60)
				self.contents.draw_text(0,y-6,28,28,"o")
			end
		end
		self.contents.font.size = 22
		refresh_arrows	
	end
	
	def refresh_arrows
		if @lines.size > 8
			@arrows.visible = self.visible
			@arrows.bitmap.clear
			for i in 0..2
				if @scroll == 0
					@arrows.bitmap.draw_text(0,194,28,28,"\\//")
				elsif @scroll < @lines.size-9
					@arrows.bitmap.draw_text(0,194,28,28,"\\//")
					@arrows.bitmap.draw_text(0,0,28,28,"/\\")
				elsif @scroll == @lines.size-9
					@arrows.bitmap.draw_text(0,0,28,28,"/\\")
				end
			end
		end
	end
	
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def get_rect(i)
		rect = Rect.new(0,0,40,20)
		rect.y = (((i-1)*0.1).truncate)*24
		rect.x = ((i-1)%10)*40
		rect
	end
	
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def select_all(b = true)
		for i in 1..@states.size
			@states[i] = b
		end
		refresh
	end
	
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def trigger_line
		r = @line_dex * 10
		for i in r..r+9
			if @lines[@line_dex]
				@states[i+1] = false
			else
				@states[i+1] = true
			end
		end
	end
	
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def check_lines
		for i in 0..@lines.size-1
			b = true
			r = i*10
			for n in r..r+9
				break if @states[n+1] == nil
				b = false if !@states[n+1]
			end
			@lines[i] = b if @lines[i] != b
		end
	end
	
	def scroll_effect
		calc = ((@index-1)*0.1).truncate
		scroll_method(calc)
	end	
	
	def scroll_method(calc)
		if calc > 7 && @scroll != calc-8
			@scroll = calc-8
			self.oy = (calc-8)*24
		elsif calc < 8
			@scroll = 0
			self.oy = 0
		end
		refresh_arrows
	end
	
	def scroll_effect_line
		scroll_method(@line_dex)
	end
	
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def update
		case @mode
			when "select"
				update_select
			when "lines"
				update_lines
		end
	end
	
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def update_lines
		if Input.repeat?(Input::UP)
			@line_dex = @line_dex == 0 ? @lines.size-1 : @line_dex-1
			scroll_effect_line
		elsif Input.repeat?(Input::DOWN)
			@line_dex = @line_dex == @lines.size-1 ? 0 : @line_dex+1
			scroll_effect_line
		end
		
		update_cursor_rect_line
		
		if Input.trigger?(Input::C)
			trigger_line
			refresh
		elsif Input.trigger?(Input::ALT)
			@index = @line_dex*10+1
			@mode = "select"
		elsif Input.trigger?(Input::SHIFT)
			self.cursor_rect.empty
			@mode = "menu"
		end
	end
	
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def update_select
		if Input.repeat?(Input::RIGHT)
			if $maps >= @index+1
				@index = @index%10 == 0 ? @index-9 : @index+1
			else
				@index -= (@index%10)-1
			end
			if Input.press?(Input::CTRL)
				@states[@index] = !@states[@index]
				#@name.add
				refresh
			end
		elsif Input.repeat?(Input::LEFT)
			if @index%10 == 1
				if $maps >= @index+9
					@index += 9
				else
					calc = ($maps*0.1).truncate
					@index += $maps-(calc*10)-1
				end
			else
				@index -= 1
			end
			if Input.press?(Input::CTRL)
				@states[@index] = !@states[@index]
				refresh
			end
		elsif Input.repeat?(Input::UP)
			calc = ($maps*0.1).truncate
			if @index < 11
				if $maps >= @index+(calc*10)
					@index += (calc*10)
				else
					@index += (calc*10)-10
				end
			else
				@index -= 10
			end
			if Input.press?(Input::CTRL)
				@states[@index] = !@states[@index]
				refresh
			end
			scroll_effect
		elsif Input.repeat?(Input::DOWN)
			calc = ((@index-1)*0.1).truncate
			if $maps >= @index+10
				@index += 10
			else
				@index -= (calc*10)
			end
			if Input.press?(Input::CTRL)
				@states[@index] = !@states[@index]
				refresh
			end
			scroll_effect
		end
		
		update_cursor_rect
		
		if Input.trigger?(Input::C) || Input.trigger?(Input::CTRL)
			@states[@index] = !@states[@index]
			refresh
		elsif Input.trigger?(Input::ALT)
			@line_dex = ((@index-1)*0.1).truncate
			@mode = "lines"
		elsif Input.trigger?(Input::SHIFT)
			self.cursor_rect.empty
			@mode = "menu"
		end
	end
	
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def update_cursor_rect
		r = get_rect(@index-@scroll*10)
		self.cursor_rect.set(r.x+18,r.y,40,20)
		if @index > 0
			@name.current($maps_name[@index-1])
		end
	end
	
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def update_cursor_rect_line
		y = (@line_dex-@scroll) * 24
		self.cursor_rect.set(-1,y+3,16,16)
	end
	
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def maps_array
		a = []
		for i in 1..$maps
			a.push($maps_id[i-1]) if @states[i]
		end
		#p(a)
		a
	end
	
	def hide
		@arrows.visible = false
		@name.visible = false
		self.visible = false
	end
	
	def show
		@arrows.visible = true
		@name.visible = true
		self.visible = true
		refresh
	end
	
#==============================================================================
# END OF Window_Select
#==============================================================================
end

#========================================================================
# = Window_SelectMenu
#========================================================================
#		Check in '%Parent Folder%/Data' for the 'MapXXX.rxdata' files
#		then makes an array of the Maps that contain some text.
#========================================================================

class Window_SelectMenu < Window_Base
	
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize
		super(78, 312, 466, 128)
		self.visible = false
		@select = Window_Select.new
		@win_append = Window_Append.new(@select)
		self.z = 120
		#self.contents.font.name = $fontname
		self.contents.font.size = 30
		self.contents.font.color = color
		self.opacity = 0
		self.windowskin = RPG::Cache.img("Progress")
		@goal = ""
		@index = 1
		@all = 0
		refresh
  end
	
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def refresh
		self.contents.clear
		
		for i in 0..2
			self.contents.font.size = i == 1 ? 34 : 30
			text = i == 0 ? Texts::gui[i+2][@all] : Texts::gui[i+2]
			self.contents.draw_text(147*i,0,147,self.contents.font.size,text,1)
		end
	end
	
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def get_rect(i)
		rect = Rect.new(0,0,40,34)
		self.contents.font.size = i == 1 ? 34 : 30
		text = i == 0 ? Texts::gui[i+2][@all] : Texts::gui[i+2]
		t = self.contents.text_size(text)
		rect.width = t.width
		rect.height = t.height
		x = i*147
		rect.x = x+(147*0.5)-(t.width*0.5)
		rect
	end
	
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def update
		if @select.mode == "menu"
			if Input.repeat?(Input::RIGHT)
				@index = @index == 2 ? 0 : @index+1
			elsif Input.repeat?(Input::LEFT)
				@index = @index == 0 ? 2 : @index-1
			end
			
			update_cursor_rect
			
			if Input.trigger?(Input::C)
				case @index
					when 0
						@select.select_all(@all==0)
						@all = @all == 0 ? 1 : 0
						refresh
					when 1
						@select.mode = "process"
						if @goal == "extract"
							@win_append.open("select")
							@win_append.pass_array(@select.maps_array)
							loop do 
								Graphics.update
								Input.update
								@win_append.update
								break if !@win_append.visible
							end
						elsif @goal == "import"
							Import::import_selected_maps(@select.maps_array,self)
						end
						Input.update
						self.cursor_rect.empty
					when 2
						close
						self.cursor_rect.empty
						$scene.refresh
						$busy = false
						Input.update
				end
			elsif Input.trigger?(Input::SHIFT)
				self.cursor_rect.empty
				@select.mode = "select"
			end
		else
			@select.update
		end
	end
	
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def update_cursor_rect
		r = get_rect(@index)
		self.cursor_rect.set(r.x-6,r.y-2,r.width+12,r.height+3)
	end
	
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def open(goal)
		@goal = goal
		@select.show
		@select.mode = "select"
		self.visible = true
	end
	
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def close
		@select.hide
		self.visible = false
	end
	
#==============================================================================
# END OF Window_SelectMenu
#==============================================================================
end

#========================================================================
# = Window_New
#========================================================================
#		Check in '%Parent Folder%/Data' for the 'MapXXX.rxdata' files
#		then makes an array of the Maps that contain some text.
#========================================================================

class Window_New < Window_Base
	
	LETTERS = [
	'a','b','c','d','e','f','g','h','i',
	'j','k','l','m','n','o','p','q','r',
	's','t','u','v','w','x','y','z'
	]
	
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(parent)
		super(232, 255, 173, 56)
		self.visible = false
		self.z = 130
		#self.contents.font.name = $fontname
		self.contents.font.size = 20
		self.contents.font.bold = true
		self.opacity = 0
		self.back_opacity = 0
		self.active = false
		self.pause = false
		self.windowskin = RPG::Cache.img("Window")
		@parent = parent
		@index = 0
		@word = []
		refresh
  end
	
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def refresh
		self.contents.clear
		self.contents.fill_rect(0,0,640,480,Color.new(14,14,14))
		self.contents.fill_rect(59,0,22,32,Color.new(100,100,100))
		self.cursor_rect.set(55,-2,30,28)
		for i in 0..6
			off = Math.abs(i-3) * 55
			self.contents.font.color = Color.new(240-off,240-off,240-off)
			self.contents.draw_text(i*20,0,20,23,get_letter(i-3+@index),1)
		end
	end
	
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def get_letter(id)
		if id > LETTERS.size-1
			return LETTERS[id-LETTERS.size]
		elsif id < -(LETTERS.size-1)
			return LETTERS[id+LETTERS.size]
		else
			return LETTERS[id]
		end
	end
	
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def update
		if Input.repeat?(Input::LEFT)
			@index -= 1
			@index = 0 if @index <= -(LETTERS.size)
			refresh
		elsif Input.repeat?(Input::RIGHT)
			@index += 1
			@index = 0 if @index >= LETTERS.size
			refresh
		end
		
		if Input.trigger?(Input::C)
			if @parent.word.size == 0
				@parent.word.push(get_letter(@index))
				$new = @parent.word.to_s
				@parent.refresh
			elsif @parent.word.size == 1
				@parent.word.push(get_letter(@index))
				$new = @parent.word.to_s
				@parent.refresh
				close
			end
		elsif Input.trigger?(Input::B)
			$new = ""
			@parent.refresh
			close
		end
	end
	
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def open
		self.visible = true
		@index = 0
		refresh
	end
	
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def close
		self.visible = false
	end
	
#==============================================================================
# END OF Window_New
#==============================================================================
end

#========================================================================
# = Window Append
#========================================================================
#		Menu that appear before extracting text.
#		It allows to choose what to append at the end of messages.
#========================================================================

class Window_Append < Window_Base
	
	attr_accessor		:word
	
#========================================================================
# = Initialize
#========================================================================
#		-@window_new: 	Roll selection window of the alphabet
#		-@index:				Current index (0:none,1:'xx',2:new)
#		-@word:					Array of two letters
#		-@mode:					String of the type of action ('all','select',
#																									'comevent','module')
#========================================================================
  def initialize(parent = nil)
		super(247, 167, 146, 146)
		self.visible = false
		self.z = 120
		#self.contents.font.name = $fontname
		self.contents.font.size = 28
		self.windowskin = RPG::Cache.img("Append")
		@window_new = Window_New.new(self)
		@index = 0
		@word = []
		@maps_array = []
		@mode = ""
		@parent = parent if parent
		refresh
  end
	
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def refresh
		self.contents.clear
		self.contents.font.size = 30
		self.contents.font.color = Color.new(220, 150, 80)
		self.contents.draw_text(0,-2,112,28,"Append",1)
		self.contents.font.size = 23
		self.contents.font.color = Color.new(220, 220, 220)
		self.contents.draw_text(0,30,112,28,"none",1)
		self.contents.draw_text(0,58,112,28,"\"#{@word.to_s}\"",1) if $new != ""
		self.contents.draw_text(0,86,112,28,"new",1)
	end
	
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def update_cursor_rect
		self.cursor_rect.set(16,30+(@index*28),80,28)
	end
	
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def update
		@window_new.update if @window_new.visible
		if Input.repeat?(Input::UP)
			@index -= 1
			@index -= 1 if @index == 1 && $new == ""
			@index = 2 if @index < 0
		elsif Input.repeat?(Input::DOWN)
			@index += 1
			@index += 1 if @index == 1 && $new == ""
			@index = 0 if @index > 2
			refresh
		end
		
		update_cursor_rect
		
		if Input.trigger?(Input::C)
			case @index
				when 0
					if @mode == "all"
						Extract::extract_all_maps
					elsif @mode == "select"
						Extract::extract_selected_maps(@maps_array,$scene.select_menu)
					elsif @mode == "commons"
						Extract::extract_comm_events
					end
					close
				when 1
					if @mode == "all"
						Extract::extract_all_maps(true)
					elsif @mode == "select"
						Extract::extract_selected_maps(@maps_array,$scene.select_menu,true)
					elsif @mode == "commons"
						Extract::extract_comm_events(true)
					end
					close
				when 2
					self.cursor_rect.empty
					@word = []
					refresh
					@window_new.open
					loop do
					Graphics.update
					Input.update
					@window_new.update
					break if !@window_new.visible
				end
			end
		elsif Input.trigger?(Input::B)
			close
			@parent.mode = "menu" if @parent
		end
	end
	
	def pass_array(a)
		@maps_array = a
	end
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def open(mode)
		@mode = mode
		self.visible = true
		refresh
	end
	
	#--------------------------------------------------------------------------
	#--------------------------------------------------------------------------
	def close
		self.visible = false
	end
	
#==============================================================================
# END OF Window Append
#==============================================================================
end
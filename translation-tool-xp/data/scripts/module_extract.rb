#############################################################################
#																			#
#								Extract Module								#
#																			#
#############################################################################

module Extract
	
	@welcome = Sprite.new	
	
	#=======================================================================#
	# = Get Maps Array =													#
	#	This method is executed before all. It display a 'Welcome' message.	#
	#=======================================================================#
	#	-Check in '%Parent Folder%/Data' for the 'MapXXX.rxdata' files		#
	#	-then makes an array of the Maps that contain some text.			#
	#-----------------------------------------------------------------------#
	#		-$maps_id: 	array of the maps number that contain text			#
	#		-$maps: 		number of maps available for translation		#
	#=======================================================================#
	def self.get_maps_array
		
		self.show_welcome()
		
		d = Dir.entries("#{$ROOT}/Data").to_s
		dd = d.scan(/Map(\d+)/)
		dd.flatten!
		arr = []
		dd = dd.each{|i| arr.push(i.to_i)}
		na = []
		
		for i in arr
			id = sprintf("%03d",i)
			print [$ROOT,File.exist?("#{$ROOT}/Data/Map#{id}.rxdata")]
			map = load_data("#{$ROOT}/Data/Map#{id}.rxdata")
			na.push(i) if self.check_for_text(map)
			Graphics.update
		end
		
		$maps_id = na
		$maps = $maps_id.size
		
		names = []
		infos = load_data("#{$ROOT}/Data/MapInfos.rxdata")
		
		for i in $maps_id
			names.push(infos[i].name)
		end
		
		$maps_name = names
		
		@welcome.dispose
		
	end
	
	#========================================================================
	# = Show Welcome
	#========================================================================
	#		Create and display a 'Welcome' text
	#========================================================================
	def self.show_welcome
		@welcome.bitmap = Bitmap.new(640,480)
		@welcome.bitmap.font.name = $fontname
		@welcome.bitmap.font.color = Color.new(220,220,220)
		@welcome.bitmap.font.size = 60
		@welcome.bitmap.draw_text(0,0,640,480,Texts::gui[5],1)
	end
	
	#========================================================================
	# = Extract All Maps (new = Boolean)
	#========================================================================
	#		Extract all the maps into 'MapXXX.txt' files in the '/Texts' folder
	#------------------------------------------------------------------------
	#		-new: 	whether or not a blank canvas is added at the end
	#						of messages (in the form '\$new{}')
	#========================================================================
	def self.extract_all_maps(new = false)
		
		@new = new
		$busy = true
		rate = 0
		
		@progress = Window_Progress.new
		
		for i in $maps_id
			rate += 1
			r = (rate*100)/$maps
			@progress.rate(r)
			self.extract_map(i)
			Graphics.update
		end
		
		self.process_complete
		$new = ""
		
	end
	
	#========================================================================
	# = Extract Selected Maps (	arr = Array,
	#							win = Window_SelectMenu,
	#							new = Boolean)
	#========================================================================
	#	Extract the maps listed in 'arr' into 'MapXXX.txt'
	#	files in the '/Texts' folder
	#------------------------------------------------------------------------
	#	-arr: 	the list of selected maps (Window_Select)
	#	-win: 	the window that will be closed when the method ends
	#	-new: 	whether or not a blank canvas is added at the end
	#						of messages (in the form '\$new{}')
	#========================================================================
	def self.extract_selected_maps(arr,win,new = false)
		
		@new = new
		rate = 0
		$busy = true
		
		@progress = Window_Progress.new
		
		for i in arr
			rate += 1
			r = (rate*100)/arr.size-1
			@progress.rate(r)
			self.extract_map(i)
			Graphics.update
		end
		
		self.process_complete
		
		$new = ""
		win.close
		
		Input.update
		
	end
	
	#========================================================================
	# = Extract Map (i = Integer)
	#========================================================================
	#	Extract map 'id' into a 'MapXXX.txt' file in the '/Texts' folder
	#	Return if the map in '%Parent Folder%/Data' does not exist or
	#	does not contain any text.
	#------------------------------------------------------------------------
	#	-i: 	the id of the map to extract
	#------------------------------------------------------------------------
	#	FORMATTING:
	#
	#	Header	 	##################################################
	#	Map Name >	#------------------- MAP 001 --------------------#
	#	Number >	#------------------- map 001 --------------------#
	#				##################################################
	#
	#	* White Spaces have no effect *
	#
	#	Ev Header	#==============================================#
	#	Ev Name	>	#                   Event 1                    #
	#	Ev Number > #================== event 1 ===================#
	#
	#	Page >		#-----------------------------------Page 0-#
	#
	#	* The texts have unique id made with the ev_id, page, list_nb *				
	#
	#	A Text > 	\T101-		(\T: Text \S: Script) 
	#				First line
	#				Second line
	#				Third line	(There is no line limit)
	#				Fourth line
	#				...
	#				\aa{}		(empty language tag, if set)
	#	End tag		-\
	#
	#				##################################################
	#				#---------------- END OF MAP 001 ----------------#
	#				##################################################
	#
	#========================================================================
	def self.extract_map(i)
		
		id = sprintf("%03d",i)
		
		# return if no file is found
		return unless File.exist?("#{$ROOT}/Data/Map#{id}.rxdata")
		
		map = nil
		map = load_data("#{$ROOT}/Data/Map#{id}.rxdata")
		
		# return if the map contain no text
		return unless self.check_for_text(map)	# TODO - Is this necessary ?
		
		infos = load_data("#{$ROOT}/Data/MapInfos.rxdata")
		
		# Set the Map Header
		t = ("#"*50) + "\n"
		tmp = "#" + " #{infos[i].name} ".center(48,'-') + "#"
		t += tmp + "\n"
		tmp = "#" + " map #{id} ".center(48,'-') + "#"
		t += tmp + "\n"
		t += ("#"*50) + "\n\n"
		
		th = {}
		counter = 0
		script_take = false
		
		map.events.each_pair{|ke,e|
		for p in 0..e.pages.size-1
			add = true
			for kl in 0..e.pages[p].list.size-1
				l = e.pages[p].list[kl]
				if l.code == 355 || l.code == 655
					Graphics.update
					if l.code == 355
						c = l.parameters.to_s
						if c.include?("choices(")
							if !th.has_key?("#{ke}")
								t += "#" + ("="*46) + "#\n"
								t += "#" + " #{e.name.upcase} ".center(46,' ') + "#\n"
								t += "#" + " event #{ke} ".center(46,'=') + "#\n\n"
								th["#{ke}"] = true
							end
							if !th.has_key?("#{ke}#{p}")
								t += "#" + "Page #{p}".rjust(42,'-') + "-#\n\n"
								th["#{ke}#{p}"] = true
							end
							t += "\\S#{ke}#{p}#{counter}-\n" unless l.code ==  655
							t += l.parameters.to_s + "\n"
							t += "-\\\n\n" unless map.events[ke].pages[p].list[kl+1].code == 655
							counter += 1
							script_take = true
						else
							script_take = false
						end
					elsif l.code == 655 && script_take
						t += l.parameters.to_s + "\n"
						t += "-\\\n\n" unless map.events[ke].pages[p].list[kl+1].code == 655
						counter += 1
					end
				elsif l.code == 101 || l.code ==  401
					if !th.has_key?("#{ke}")
						t += "#" + ("="*46) + "#\n"
						t += "#" + " #{e.name.upcase} ".center(46,' ') + "#\n"
						t += "#" + " event #{ke} ".center(46,'=') + "#\n\n"
						th["#{ke}"] = true
					end
					if !th.has_key?("#{ke}#{p}")
						t += "#" + "Page #{p}".rjust(42,'-') + "-#\n\n"
						th["#{ke}#{p}"] = true
					end
					add = false if l.parameters.to_s.include?("\\#{$new}")
					t += "\\T#{ke}#{p}#{counter}-\n" unless l.code ==  401
					t += l.parameters.to_s + "\n"
					unless map.events[ke].pages[p].list[kl+1].code == 401
						t += "\\#{$new}{}\n" if add && @new
						t += "-\\\n\n"
						add = true
						encapsulate = true
					end
					counter += 1
				end
			end
		end
		}
		
		# Set the Map Footer
		t += "#" * 50 + "\n"
		t += "#" + " END OF MAP #{id} ".center(48,'-') + "#\n"
		t += "#" * 50
		
		Graphics.update
		
		# Write the .txt file
		f = File.new("Texts/Map#{id}.txt","w+")
		f.write("")
		f.write(t)
		f.close
		
		# Update until the file is created
		loop do
			break if File.exist?("Texts/Map#{id}.txt")
			Graphics.update
		end
		
	end
	
	#========================================================================
	# = Check For Text (map = MapData)
	#========================================================================
	#		Iterate through 'map' and return whether or not
	#   it contains some text.
	#------------------------------------------------------------------------
	#		-map: 	A loaded 'MapXXX.rxdata' file
	#========================================================================
	def self.check_for_text(map)
		
		return false if map.events.empty?
		
		# init the boolean
		b = false
		
		map.events.each_pair{|ke,e|
		
		for p in e.pages
			
			for l in p.list
				
				# code 355 = first line of script command
				if l.code == 355
					
					c = l.parameters.to_s
					
					# check if the script command contain 'choices('
					if c.include?("choices(")
						b = true
					end
					
					# code 101 = first line of message command
					# code 401 = from second line to nth line of message command
				elsif l.code == 101	|| l.code ==  401
					
					# check if the text command contain text
					c = l.parameters.to_s
					b = true unless c.empty?
					
				end
				
			end
			
		end
		}
		
		# return the boolean
		b
		
	end
	
	##========================================================================
	## = Extract Modules
	##========================================================================
	##		Extract the maps listed in 'arr' into 'MapXXX.txt'
	##========================================================================
	#	def self.extract_modules
	#		scripts = load_data("#{$ROOT}/Data/Scripts.rxdata")
	#		Graphics.update
	#		start = self.get_script_index(scripts,"---Languages---")
	#		@progress = Window_Progress.new
	#		rate = 0
	#
	#		size = 1
	#		loop do
	#			break if scripts[start+size][1].empty?
	#			size += 1
	#		end
	#		Graphics.update
	#		loop do
	#			rate += 1
	#			r = (rate*100)/size
	#			@progress.rate(r)
	#			start += 1
	#			break if scripts[start][1].empty?
	#			game_sytem = Zlib::Inflate.inflate(scripts[start][2])
	#			Graphics.update
	#			f = File.new("Texts/#{scripts[start][1]}.txt","w+")
	#			f.write("")
	#			f.write(game_sytem)
	#			f.close
	#			Graphics.update
	#		end
	#
	#		scripts = nil
	#		self.process_complete
	#	end
	#
	##========================================================================
	## = Get Script Index (scripts = ScriptsData,
	##											name = String)
	##========================================================================
	##		Return the index of the script 'name' in the 'scripts' list.
	##------------------------------------------------------------------------
	##		-scripts: 	a loaded and inflated(Zlib) 'Scripts.rxdata' file
	##		-name:			the name of the script to search
	##========================================================================
	#	def self.get_script_index(scripts,name)
	#		for i in 0..scripts.size-1
	#			if scripts[i][1] == name
	#				return i
	#			end
	#		end
	#	end
	
	#========================================================================
	# = Extract Comm Events
	#========================================================================
	#		Extract all 'Common Events' that contain some text in a single
	#		'CommonEvents.txt' file into the '/Texts' folder.
	#========================================================================
	def self.extract_comm_events(new = false)
		
		@new = new
		$busy = true
		@progress = Window_Progress.new
		
		com = nil
		com = load_data("#{$ROOT}/Data/CommonEvents.rxdata")
		t = ""
		
		# Set the Map Header
		t = ("#"*50) + "\n"
		tmp = "#" + " COMMON EVENTS ".center(48,'-') + "#\n"
		t += tmp
		t += ("#"*50) + "\n\n"
		
		for i in 1..com.size-1
			r = (i*100)/com.size-1
			@progress.rate(r)
			t += self.extract_common_event(com[i],i).to_s
		end
		
		# Set the Common Event Footer
		t += "#" * 50 + "\n"
		t += "#" + " END OF COMMON EVENTS ".center(48,'-') + "#\n"
		t += "#" * 50 + "\n"
		
		Graphics.update
		
		# write the .txt file containing all the common events
		f = File.new("Texts/CommonEvents.txt","w+")
		f.write("")
		f.write(t)
		f.close
		
		self.process_complete
		$new = ""
	end
	
	#========================================================================
	# = Extract Common Event (com = CommonEvent,
	#													i = Integer)
	#========================================================================
	#		Iterate throught 'com' and return all the texts in a string.
	#------------------------------------------------------------------------
	#		-com: 	the common event to check
	#		-i:			the id of the common event
	#------------------------------------------------------------------------
	#		FORMATTING:
	#
	#			Header for each event-------> ##########################
	#														 				#### COMMON EVENT XXX ####
	#			White Spaces----------------> #
	#			A Text----------------------> \Text%ev%pg%ct-
	#			%ev: event id									First line
	#			%pg: page number							Second line
	#			%ct: event list number				Third line
	#																		Fourth line
	#																		...
	#			Blank canvas (if activated)-> \aa{}
	#			End tag---------------------> -end\
	#																		#
	#========================================================================
	def self.extract_common_event(com,i)
		
		return unless self.check_for_text_com(com)
		
		t = "#" + ("="*46) + "#\n"
		t += "#" + " #{com.name} ".center(46," ") + "#\n"
		t += "#" + " common event #{i} ".center(46,"=") + "#\n"
		t += "start\n\n"
		
		th = {}
		counter = 0
		script_take = false
		
		add = true
		
		for kl in 0..com.list.size-1
			
			Graphics.update
			l = com.list[kl]
			
			if l.code == 355 || l.code == 655
				if l.code == 355
					c = l.parameters.to_s
					if c.include?("choices(")
						t += "\\S#{i}#{counter}-\n" unless l.code ==  655
						t += l.parameters.to_s + "\n"
						t += "-\\\n\n" unless com.list[kl+1].code == 655
						counter += 1
						script_take = true
					end
				elsif l.code == 655 && script_take
					#t += "\\T#{i}#{counter}-\n" unless l.code ==  655
					t += l.parameters.to_s + "\n"
					t += "-\\\n\n" unless com.list[kl+1].code == 655
					counter += 1
				else
					script_take = false
				end
			elsif l.code == 101 || l.code ==  401
				add = false if l.parameters.to_s.include?("\\#{$new}")
				
				t += "\\T#{i}#{counter}-\n" unless l.code ==  401
				t += l.parameters.to_s + "\n"
				
				unless com.list[kl+1].code == 401
					t += "\\#{$new}{}\n" if add && $new != ""
					t += "-\\\n\n"
					add = true
				end
				
				counter += 1
			end
		end
		t += "end\n"
		t
	end
	
	#========================================================================
	# = Check For Text Com (ev = CommonEvents)
	#========================================================================
	#		Iterate through 'ev' and return whether or not
	#   it contains some text.
	#------------------------------------------------------------------------
	#		-ev: 	'Common Event' data
	#========================================================================
	def self.check_for_text_com(ev)
		
		return false if ev.list.empty?
		
		# init the boolean
		b = false
		
		ev.list.each{|l|
		
		# code 355 = first line of script command
		if l.code == 355 #|| l.code == 655
			
			c = l.parameters.to_s
			
			if c.include?("choices(")
				b = true
			end
			
			# code 101 = first line of message command
			# code 401 = from second line to nth line of message command
		elsif l.code == 101 || l.code ==  401
			
			# check if the text command contain text
			c = l.parameters.to_s
			b = true unless c.empty?
			
		end
		
		}
		
		# return the boolean
		b
		
	end
	
	#========================================================================
	# = Process Complete
	#========================================================================
	#		Display a "Completed" text in the 
	#		progress window and wait for input.
	#========================================================================
	def self.process_complete
		
		@progress.text("COMPLETED",1)
		
		loop do
			
			Graphics.update
			Input.update
			
			break if Input.trigger?(Input::C)
			
		end
		
		@progress.dispose
		$busy = false
		
	end
	
#############################################################################
# 							END OF EXTRACT MODULE							#
#############################################################################
end
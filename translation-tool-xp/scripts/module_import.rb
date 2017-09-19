#############################################################################
#																			#
#								import Module								#
#																			#
#############################################################################
module Import
	
	# #========================================================================
	# def self.add_language(name)
		# scripts = load_data("#{$ROOT}/Data/Scripts.rxdata")
		# id = self.get_script_index(scripts,"Module Options")
		
		# text = File.read("Module_Base.txt")
		
		# tt = Zlib::Deflate.deflate(text)
		# s = [1,"Module_#{name.upcase!}",tt]
		# scripts.insert(id+1,s) 
		# save_data(scripts,"#{$ROOT}/Data/Scripts.rxdata") 
	# end
		
	# #========================================================================
	# def self.get_script_index(scripts,name)
		# for i in 0..scripts.size
			# if scripts[i][1] == name + "\n"
				# return i
			# end
		# end
	# end
	
#############################################################################
#							   	MAP METHODS		    						#
#############################################################################

	#========================================================================
	def self.import_all_maps
		$busy = true
		@progress = Window_Progress.new
		for i in $maps_id
			r = (i*100)/$maps
			@progress.rate(r)
			self.import_map(i)
			Graphics.update
		end
		self.process_complete
	end
	
	#========================================================================
	def self.import_selected_maps(arr,win)
		$busy = true
		@progress = Window_Progress.new
		for i in arr
			r = (i*100)/arr.size-1
			@progress.rate(r)  
			self.import_map(i)
			Graphics.update
		end
		self.process_complete
		win.close
		Input.update
	end
	
	#========================================================================
	def self.read_map_txt(id)
		text = File.read("Texts/Map#{id}.txt")
		t = text.scan(/\\[T|S](\d*)-\n(.*?)\n-\\/m)
		texts = []
		t.each{|a| ch = a[1].to_a
			ch.each{|l| l.chomp!}
			ch = [" "] if ch == [] or ch == nil
			texts.push(ch)
		}
		
		return texts
	end
	
	#========================================================================
	def self.import_map(i)
		id = sprintf("%03d",i)
		return unless File.exist?("#{$ROOT}/Data/Map#{id}.rxdata")
		return unless File.exist?("Texts/Map#{id}.txt")
		
		text_array = self.read_map_txt(id)

		map = nil
		map = load_data("#{$ROOT}/Data/Map#{id}.rxdata")
		map = self.erase_second_lists(map)
		
		counter = 0
		indent = 0
		
		map.events.each_pair{|ke,e|
			for p in 0..e.pages.size-1
				kl = 0
				loop do
					break unless e.pages[p].list[kl]
					l = e.pages[p].list[kl]
					if l.code == 355 && text_array[counter].to_s.include?("choices(")
						for i in 0..text_array[counter].size-1
							if i == 0
								indent = map.events[ke].pages[p].list[kl].indent
								map.events[ke].pages[p].list[kl].parameters = text_array[counter][0].to_a
							else
								obj = RPG::EventCommand.new(655,indent,text_array[counter][i].to_a)
								map.events[ke].pages[p].list.insert(kl+i,obj)
							end
						end
						counter += 1
					elsif l.code == 101
						for i in 0..text_array[counter].size-1
							if i == 0
								indent = map.events[ke].pages[p].list[kl].indent
								map.events[ke].pages[p].list[kl].parameters = text_array[counter][0].to_a
							else
								obj = RPG::EventCommand.new(401,indent,text_array[counter][i].to_a)
								map.events[ke].pages[p].list.insert(kl+i,obj)
							end
						end
						counter += 1
					end
					kl += 1
				end
			end
		}
		save_data(map,"#{$ROOT}/Data/Map#{id}.rxdata")
	end
	
	#========================================================================
	def self.erase_second_lists(map)
		map.events.each_pair{|ke,e|
			for p in 0..e.pages.size-1
				script_take = false
				map.events[ke].pages[p].list.delete_if{|l|
					b = false
					if l.code == 355
						if l.parameters.to_s.include?("choices(")
							script_take = true
						else
							script_take = false
						end
					elsif script_take && l.code == 655
						b = true
					elsif l.code == 401
						b = true
					end
					b
				}
			end
		}
		return map
	end
	
#############################################################################
#							COMMON EVENTS METHODS		   					#
#############################################################################

	#========================================================================
	def self.import_all_common_events
		$busy = true
		@progress = Window_Progress.new
		
		return unless File.exist?("Texts/CommonEvents.txt")
		
		texts = self.read_common_events_txt
		
		com = nil
		com = load_data("#{$ROOT}/Data/CommonEvents.rxdata")
		comsize = com.size-1
		
		count = 0
		for i in 1..comsize
			r = (i*100)/comsize
			@progress.rate(r)
			if Extract.check_for_text_com(com[i])
				com[i] = self.erase_second_lists_commons(com[i])
				com[i] = self.import_common_event(com[i],texts[count])
				count += 1
			end
			Graphics.update
		end
		
		#write com back into .rxdata
		save_data(com,"#{$ROOT}/Data/CommonEvents.rxdata")
		
		Graphics.update
		self.process_complete
	end
	
	#========================================================================
	def self.read_common_events_txt
		text = File.read("Texts/CommonEvents.txt")
		t = text.scan(/start\n(.*?)\nend/m)
		return t.flatten!
	end
	
	#========================================================================
	def self.import_common_event(com,t)
		
		text_array = self.read_common_events_array(t)

		counter = 0
		indent = 0
		
		for kl in 0..com.list.size-1
			
			Graphics.update
			l = com.list[kl]
	
			if l.code == 355 && text_array[counter].to_s.include?("choices(")
				for i in 0..text_array[counter].size-1
					if i == 0
						indent = com.list[kl].indent
						com.list[kl].parameters = text_array[counter][0].to_a
					else
						obj = RPG::EventCommand.new(655,indent,text_array[counter][i].to_a)
						com.list.insert(kl+i,obj)
					end
				end
				counter += 1
			elsif l.code == 101
				for i in 0..text_array[counter].size-1
					if i == 0
						indent = com.list[kl].indent
						com.list[kl].parameters = text_array[counter][0].to_a
					else
						obj = RPG::EventCommand.new(401,indent,text_array[counter][i].to_a)
						com.list.insert(kl+i,obj)
					end
				end
				counter += 1
			end
		end
		return com
	end
	
	#========================================================================
	def self.read_common_events_array(arr)
		
		t = arr.scan(/\\[T|S](\d*)-\n(.*?)\n-\\/m)
		
		texts = []
		t.each{|a| ch = a[1].to_a
			ch.each{|l| l.chomp!}
			ch = [" "] if ch == []
			texts.push(ch)
		}
		
		return texts
	end	
	
#========================================================================
	def self.erase_second_lists_commons(com)
		script_take = false
		com.list.delete_if{|l|
			b = false
			if l.code == 355
				if l.parameters.to_s.include?("choices(")
					script_take = true
				else
					script_take = false
				end
			elsif script_take && l.code == 655
				b = true
			elsif l.code == 401
				b = true
			end
			b
		}
		return com
	end
	
#############################################################################
#############################################################################

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
# 							END OF import MODULE								#
#############################################################################
end
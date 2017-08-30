module Write
	
	def self.write_all_maps
		$busy = true
		@progress = Window_Progress.new
		for i in $maps_id
			r = (i*100)/$maps
			@progress.rate(r)
			self.write_map(i)
			Graphics.update
		end
		self.process_complete
	end  
	
	def self.write_selected_maps(arr,win)
		$busy = true
		@progress = Window_Progress.new
		for i in arr
			r = (i*100)/arr.size-1
			@progress.rate(r)  
			self.write_map(i)
			Graphics.update
		end
		self.process_complete
		win.close
		Input.update
	end
	
	def self.add_language(name)
		scripts = load_data("#{$ROOT}/Data/Scripts.rxdata")
		id = self.get_script_index(scripts,"Module Options")
		
		text = File.read("Module_Base.txt")
		
		tt = Zlib::Deflate.deflate(text)
		s = [1,"Module_#{name.upcase!}",tt]
		scripts.insert(id+1,s) 
		save_data(scripts,"#{$ROOT}/Data/Scripts.rxdata") 
	end
		
	def self.get_script_index(scripts,name)
		for i in 0..scripts.size
			if scripts[i][1] == name + "\n"
				return i
			end
		end
	end
	
	def self.read_map_txt(id)
		text = File.read("Texts/Map#{id}.txt")
		t = text.scan(/\\Text(\d*)-\n(.*?)\n-end\\/m)
		texts = []
		t.each{|a| ch = a[1].to_a
			ch.each{|l| l.chomp!}
			ch = [" "] if ch == []
			texts.push(ch)
		}
		
#		aa = []  
#		texts.each{|t|
#			aaa = []
#			t.each{|v|
#			aaa.push("#{v} - ")
#			}
#			aa.push("#{aaa}\n")
#		}
#		print(aa)
		
		return texts
	end
	
	def self.write_map(i)
		id = sprintf("%03d",i)
		return unless File.exist?("#{$ROOT}/Data/Map#{id}.rxdata")
		return unless File.exist?("Texts/Map#{id}.txt")
		
		text_array = self.read_map_txt(id)

		map = nil
		map = load_data("#{$ROOT}/Data/Map#{id}.rxdata")
		map = self.erase_second_lists(map)

#		aa = []
#		map.events.each_pair{|ke,e|
#			aa.push("#{e.id}\n")
#		}
#		print(aa)
#		return
		
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
	
end
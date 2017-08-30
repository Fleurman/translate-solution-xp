module RPG
  module Cache
    def self.windowskin(filename)
      self.load_bitmap("Data/", filename)
    end
  end
end

module Math
	
	def self.abs(value)
		if value < 0
			return value*-1
		else
			return value
		end
	end
	
end
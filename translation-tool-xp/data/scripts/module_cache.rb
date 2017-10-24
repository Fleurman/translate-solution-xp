module RPG
  module Cache
    def self.img(filename)
      self.load_bitmap("data/img/", filename)
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
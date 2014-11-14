module	BiliConfig

	class Biliconf

		@@userHome = `echo $HOME`.gsub(/\n/,"")
		@@configPath = File.join(@@userHome,".config")
		
		def initialize(name="biligui.conf", path=@@configPath)

			@name = name
			@path = path
			@configEntries = []

		end

		# test code
		def print
			p @name
			p @path
			p @configEntries
		end
	
	end

	# test code
	def hello
		a = Biliconf.new
		a.print()
	end

end

# Test codes

class AConfig

	include BiliConfig

end

a = AConfig.new
a.hello()

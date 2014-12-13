module	BiliConfig

	require_relative 'BiliFile'

	class BiliConf

		include BiliFile

		$userHome = `echo $HOME`.gsub(/\n/,"")
		$configPath = File.join($userHome,".config/BiliGui")
		$playlistPath = File.join($configPath,"playlist")
		
		def initialize(name="biligui.conf", path=$configPath)

			@name = name
			@path = path

			unless Dir.exists?(@path) then
				Dir.mkdir @path
			end

			unless Dir.exists?(File.join(@path,"playlist")) then
				Dir.mkdir(File.join(@path,"playlist"))
			end

			@config = File.join(path, name)
			@configEntries = {}

			unless File.exists?(@config) then
				biliTouch(@config)
			else
				io = File.open(@config, "r")
				io.each_line do |line|
					line.chomp!
					key = line.gsub(/=.*/,"")
					if line.index("mpvflags") then
						value = line.gsub(/mpvflags=/,"")
					else
						value = line.gsub(/.+=/,"")
					end
					@configEntries[key] = value
				end
				io.close
			end

		end

		def put(key, value)

			# if Key exists, then we should delete
			if @configEntries.key?(key) then	
								
				biliMove(@config,"! line.index('" + key + "')")
				
			end

			io = File.open(@config, "a")
			io.puts("#{key}=#{value}")
			io.close
		end

		def load
			return @configEntries
		end
	
	end

end

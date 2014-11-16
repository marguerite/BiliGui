module	BiliConfig

	require_relative 'BiliFile'

	class BiliConf

		include BiliFile

		$userHome = `echo $HOME`.gsub(/\n/,"")
		$configPath = File.join($userHome,".config/BiliGui")
		p "Config Path: #{$configPath}"
		
		def initialize(name="biligui.conf", path=$configPath)

			@name = name
			@path = path

			unless Dir.exists?(@path) then
				Dir.mkdir @path
			end

			@config = File.join(path, name)
			@configEntries = {}

			unless File.exists?(@config) then
				biliTouch(@config)
			else
				io = File.open(@config, "r")
				io.each_line do |line|
					line.chomp!
					configKey = line.gsub(/=.*/,"")
					configValue = line.gsub(/.*=/,"")
					@configEntries[configKey] = configValue
				end
				io.close
			end

		end

		def write(key, value)
			configKey = key
			configValue = value

			# if Key exists, then we should delete
			if @configEntries.key?(configKey) then	
								
				billMove(@config,"! line.index(configKey)")
				
			end

			io = File.open(@config, "a")
			io.puts("#{configKey}=#{configValue}")
			io.close
		end

		def load
			return @configEntries
		end
	
	end

end

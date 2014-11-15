module	BiliConfig

	class Biliconf

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
				io = File.open(@config, "w")
				io.close
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

		def writeNewConfig(key, value)
			configKey = key
			configValue = value

			# if Key exists, then we should delete
			if @configEntries.key?(configKey) then

				require 'fileutils'

				tmpfile = @config + ".tmp"
				oldfile = @config + ".old"

				open(@config, 'r') do |f0|
					open(tmpfile, 'w') do |f1|
						f0.each_line do |line|
							f1.write(line) unless line.index(configKey)
						end
					end
				end
				
				FileUtils.mv @config, oldfile
				FileUtils.mv tmpfile, @config
				
			end

			io = File.open(@config, "a")
			io.puts("#{configKey}=#{configValue}")
			io.close
		end

		def loadConfigs
			return @configEntries
		end
	
	end

end

module BiliWeb

	require 'open-uri'
	require_relative 'BiliConfig'

	$cachePath = File.join($configPath, 'cache')

	Dir.mkdir($cachePath) unless Dir.exist?($cachePath)

	class BiliParser
		
		include BiliConfig
		include BiliFile

		def initialize(array=["http://bilibili.tv"])
			
			@filename = {}
			array.each do |url|
				filename = $cachePath + "/" + url.gsub(/http:\/\//,"") + ".html"
				@filename[filename] = url
			end

			@pool = Queue.new

                	@index = "bilibili.tv.html"
                	@indexfile = File.join($cachePath,@index)

			get

		end

		def get

			@filename.each do |array|
				Thread.new {
					content = open(array[1]).read
					io = File.open(array[0], "w")
					io.puts(content)
					io.close
					@pool << array[0]
				}
			end
			
			clean	
		end

		def clean

			@filename.size.times do

				Thread.new {
					file = @pool.pop
	
					if file.index(@index) then
						biliMove(file,"line.index('/video/') && ! line.index('av271')")
					else
						p "[WARN] Don't know what to do!"
					end
				}

			end

		end

		def parse

			hash1 = {}
			lev1 = @indexfile + ".l1"			

			biliMove(@indexfile,lev1,"line.index('i-link')")

			# parse level 1 pair
			open(lev1) do |f|
				f.each_line do |line|
					line.chomp!
					key = line.gsub(/^.*<em>/,'').gsub(/<\/em.*$/,'')
					value = line.gsub(/^.*href=\"/,'').gsub(/\"><em.*$/,'')
					hash1[key] = value
				end
			end

			return hash1

		end

	end

end

# Test code below
#Test.new("http://www.bilibili.com/video/av1718394/").get

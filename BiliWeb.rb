#!/usr/bin/ruby

module BiliWeb

	require 'open-uri'
	require_relative 'BiliConfig'

	$cachePath = File.join($configPath, 'cache')

	Dir.mkdir($cachePath) unless Dir.exists?($cachePath)

	class BiliFetch
		
		include BiliConfig
		include BiliFile

		@@index = "bilibili.tv.html"		
		@@indexfile = File.join($cachePath,@@index)

		def initialize(url="http://bilibili.tv")
			@url = url	
			@filename = $cachePath + "/" + @url.gsub(/http:\/\//,"") + ".html"
		end

		def get
			content = open(@url).read
			io = File.open(@filename, "w")
			io.puts(content)
			io.close
		end

		def clean(filename="#{@filename}")

			if filename.index(@@index) then

				biliMove(filename,"line.index('/video/') && ! line.index('av271')")

			else
				p "[WARN] Don't know what to do!"
			end

		end

		def format
		end

		def parse_index

			hash1 = {}
			hash2 = {}
			lev1 = @@indexfile + ".l1"
			lev2 = @@indexfile + ".l2"			

			biliMove(@@indexfile,lev1,"line.index('i-link')")

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

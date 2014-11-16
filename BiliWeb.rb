#!/usr/bin/ruby

module BiliWeb

	require 'open-uri'
	require_relative 'BiliConfig'

	class BiliFetch
		
		include BiliConfig
		include BiliFile

		def initialize(url)
			@url = url	
			@cachePath = File.join($configPath,"cache")
			unless Dir.exists?(@cachePath) then
				Dir.mkdir(@cachePath)
			end
			@filename = @cachePath + "/" + @url.gsub(/http:\/\//,"") + ".html"
		end

		def get
			content = open(@url).read
			io = File.open(@filename, "w")
			io.puts(content)
			io.close
		end

		def clean(filename="#{@filename}")

			if filename.index("bilibili.tv.html") then

				biliMove(filename,"line.index('/video/') && ! line.index('av271')")

			else
				p "[WARN] Don't know what to do!"
			end

		end

		def format
		end

		def indexLevels
			indexFile = @cachePath + "/bilibili.tv.html"
			indexLevel1 = indexFile + ".level1"
			indexLevel2 = indexFile + ".level2"			

			biliMove(indexFile,indexLevel1,"line.index('i-link')")
			biliMove(indexFile,indexLevel2,"! line.index('i-link')")
			
		end

	end

end

# Test code below

#class Test
#	include BiliWeb

#	def initialize(url)
		#@url = url
#	end

#	def get
#		BiliFetch.new(@url).get
#		BiliFetch.new(@url).clean
#		BiliFetch.new(@url).indexLevels
#	end

#end

#Test.new("http://bilibili.tv").get

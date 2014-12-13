module BiliPlaylist

	require_relative 'BiliConfig'

	class BiliPlaylist

		def initialize(videos="")
			@videos = videos
			@hash = {}

                        @historyfile = File.join($configPath,"biligui.history")
                        @lastfile = File.join($configPath,"biligui.last")

			split
		end

		def split

			unless @videos.empty? then

				@videos.split(/\n/).each do |video|
					if video.index(",") || video.index(";") then
						if video.index(",") then
							separator = ","
						else
							separator = ";"
						end

						video.split(separator).each do |nest|
                                                	if nest.index("http://") then
                                                        	key = "av" + nest.gsub(/^.*\/av/,'').gsub(/\//,'')
                                                        	@hash[key] = nest
                                                	elsif nest.index("av") then
                                                        	value = "http://www.bilibili.com/video/" + nest + "/"
                                                        	@hash[nest] = value
                                                	else
                                                        	next
                                                	end
						end
					else
						if video.index("http://") then
							key = "av" + video.gsub(/^.*\/av/,'').gsub(/\//,'')
							@hash[key] = video
						elsif video.index("av") then
							value = "http://www.bilibili.com/video/" + video + "/"
							@hash[video] = value
						else
							next
						end
					end
				end

			end

		end

		def hash
			return @hash
		end

		def save(filename="")

			require 'fileutils'

			playlist = filename

			default_playlist = "#{$configPath}/playlist/biliplaylist.m3u8"

			if playlist.empty? then
				playlist = default_playlist
			end

			if File.exist?(playlist) then
				old_playlist = playlist + ".old"
				FileUtils.mv playlist, old_playlist
			end

			io = open(playlist,"w")
			io.puts "#EXTM3U"

			@hash.to_a.each do |video|
				io.puts "#EXTINF:#{video[0]}"
				io.puts video[1]
			end

			io.close

		end

		def load(playlist="")

			hash = {}

			default_playlist = "#{$configPath}/playlist/biliplaylist.m3u8"

			if playlist.empty? && File.exist?(default_playlist) then
				playlist = default_playlist
			end


			if playlist.empty? then
				p "[ERR] No playlist available!"
			else

				io = open(playlist, 'r')

				array = []
				i = 0

				io.each_line do |line|

					line.chomp!

					i += 1

					unless line.index("http://") then
						next
					end

					unless line.index("bilibili") then
						p "#{line} doesn't seem to be a Bilibili URL!"
					else
						value = line
						key = "av" + value.gsub(/^.*\/av/,'').gsub(/\//,'')
						hash[key] = value
						array[i] = line
					end

				end

				if array.empty? then
					p "This playlist has no URL we support!"
				end

				io.close
			end

			return hash

		end

		def history

			io = open(@lastfile, 'w')
			@hash.each_value { |item| io.puts item }
			io.close

			open(@lastfile,'r') do |f|
				open(@historyfile, 'a') do |f1|
					f.each_line do |line|
						f1.puts line
					end
				end
			end

			duplicate([@lastfile,@historyfile])

		end

		def duplicate(files)

			files.each do |file|
				array = []
				i = 0

				open(file,'r') do |f|
					f.each_line do |line|
						line.chomp!
						array[i] = line
						i+=1
					end
				end

				new = array.uniq

				io = open(file, 'w')
				new.each {|value| io.puts value}
				io.close
			end
		end

		def last

			str = ""
			
			open(@lastfile,'r') do |f|
				f.each_line do |line|
					str += line
				end
			end

			return str

		end

	end

end

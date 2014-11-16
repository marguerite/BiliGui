module BiliPlaylist

	class BiliPlaylist

		def initialize(videos="")
			@videos = videos
			@videosHash = {}

			split
		end

		def split

			unless @videos.empty? then

			@videos.split(/\n/).each do |video|

				unless video.index("http://") then
					next
				end


				videoHashKey = "av" + video.gsub(/^.*\/av/,"").gsub(/\//,"")
				videoHashValue = video

				@videosHash[videoHashKey] = videoHashValue

			end

			end

		end

		def hash
			return @videosHash
		end

		def save(filename="")

			require 'fileutils'

			playlist = filename

			default_playlist = "#{$configPath}/biliplaylist.m3u8"

			if playlist.empty? then
				playlist = default_playlist
			end

			old_playlist = playlist + ".old"

			if File.exist?(playlist) then
				mv playlist, old_playlist
			else
				io = open(playlist,"w")
				io.puts "#EXTM3U"

				@videosHash.to_a.each do |video|
					io.puts "#EXTINF:#{video[0]}"
					io.puts video[1]
				end

				io.close
			end
		end

		def load(playlist="")

			hash = {}

			default_playlist = "#{$configPath}/biliplaylist.m3u8"

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
						key = "av" + line.gsub(/^.*\/av/,"").gsub(/\//,"")
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

	end

end

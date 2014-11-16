module BiliPlaylist

	class BiliPlaylist

		def initialize(videos="")
			@videos = videos
			@hash = {}

			split
		end

		def split

			unless @videos.empty? then

				if @videos.index("http://") then
					@videos.split(/\n/).each do |video|
						unless video.index("http://") then
							next
						end
						key = "av" + video.gsub(/^.*\/av/,'').gsub(/\//,'')
						value = video
						@hash[key] = value
					end
				else # bangou
					if @videos.index(",") || @videos.index(";") then
						if @videos.index(",") then
							separator = ","
						else
							separator = ";"
						end

						@videos.split(/\n/).each do |video|
							video.split(separator).each do |bangou|
								unless bangou.index("av") then
									next
									p "[WARN] #{bangou} is not a valid bango!"
								end

								key = bangou
								value = "http://bilibili.tv/video/" + bangou + "/"
								@hash[key] = value
							end
						end


					else
						# single bangou or no URL
						unless @videos.index("av") then
							p "[WARN] Did you paste anything?"
						else
							key = @videos.gsub(/\n/,'')
							value = "http://bilibili.tv/video/" + key + "/"
							@hash[key] = value
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

			default_playlist = "#{$configPath}/biliplaylist.m3u8"

			if playlist.empty? then
				playlist = default_playlist
			end

			old_playlist = playlist + ".old"

			if File.exist?(playlist) then
				FileUtils.mv playlist, old_playlist
			else
				io = open(playlist,"w")
				io.puts "#EXTM3U"

				@hash.to_a.each do |video|
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

	end

end

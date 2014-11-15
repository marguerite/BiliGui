module BiliUrlsHandler
	class BiliUrls

		def initialize(urls)

			@urlBlock = urls
			@urlHash = {}

			urlSplit

		end

		def urlSplit

			unless @urlBlock.empty? then
				urls = @urlBlock.split(/\n/)
				urls.each do |url|

					# validation codes here
					unless url.index("http://") then
						puts "Url invalid: #{url}"
						next	
					end

					urlHashValue = url
					urlHashKey = urlHashValue.gsub(/^.*\/av/,"").gsub(/\//,"")
					@urlHash[urlHashKey] = urlHashValue
				end
			else
				puts "No Urls!"
			end			

		end

		def urlBlockHash
			return @urlHash
		end

	end
end

module BiliFile

	require 'fileutils'

	def biliMove(file, newfile=file, condition)

		tmp = file + ".tmp"

		open(file, 'r') do |f0|
			open(tmp, 'w') do |f1|
				f0.each_line do |line|

					status = true
					code =  eval(condition)

					if code != nil then
						if code == false then
							status = false
						else
							if code != true then
								if code > 0 then
									status = true
								else
									status = false
								end
							else
								status = true
							end
						end
					else
						status = false
					end

					f1.write(line) if status
				end
			end
		end

		if newfile == file then
			oldfile = file + ".old"
			FileUtils.mv file, oldfile
		end

		FileUtils.mv tmp, newfile
		
	end

	def biliTouch(file="")
		open(file, 'w').close
	end

end

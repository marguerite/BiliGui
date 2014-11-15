require 'Qt'
require 'qtwebkit'
require_relative 'BiliConfig'
require_relative 'BiliUrlsHandler'

class BiliGuiConfig

        include BiliConfig
        @@config = Biliconf.new

        def put(key,value)
                confKey = key
                confValue = value
                @@config.writeNewConfig(confKey,confValue)
        end

	def load
		@@config.loadConfigs()
	end

end

class BiliGuiUrls

	include BiliUrlsHandler

	def initialize(urls)

		@urls = urls

	end

	def hash
		urlHash = BiliUrls.new(@urls)
		return urlHash.urlBlockHash	
	end
end

class BiliGui < Qt::Widget

	slots 'bilidan()'
	slots 'clear()'
	slots 'bilidanChoose()'
	slots 'biliWeb()'

	Width = 800
	Height = 400
	@@configw = BiliGuiConfig.new
	@@config = @@configw.load

	def initialize
		super
		
		setWindowTitle "BiliGui"

		setWindowIcon(Qt::Icon.new("bilibili.svgz"))

		init_ui

		resize	Width, Height
		center

		show
	end

	def center
		qdw = Qt::DesktopWidget.new

		screenWidth = qdw.width
		screenHeight = qdw.height

		x = (screenWidth - Width) / 2
		y = (screenHeight - Height) / 2

		move x, y
	end

	def init_ui

		biliTabs = Qt::TabWidget.new
		playlistTab = Qt::Widget.new
		webTab = Qt::Widget.new
		settingsTab = Qt::Widget.new

		biliTabs.addTab	playlistTab, "BiliGui Playlist"
		biliTabs.addTab webTab, "Bilibili.tv"
		biliTabs.addTab settingsTab, "BiliGui Settings"

		grid_biliTabs = Qt::GridLayout.new self
		grid_biliTabs.addWidget biliTabs, 0, 0, 1, 1
		grid_biliTabs.setColumnStretch 0, 0

		# Playlist Tab		
		grid_Playlist = Qt::GridLayout.new playlistTab

		biliUrlLabel = Qt::Label.new "Please paste Bilibili URL below", playlistTab
		biliWebButton = Qt::PushButton.new 'Visit bilibili.tv (experimental)', playlistTab
		@urlArea = Qt::TextEdit.new playlistTab
		@messageLabel = Qt::Label.new "", playlistTab
		@messageLabel.setStyleSheet("color: #ff0000;")	
		okButton = Qt::PushButton.new 'Play', playlistTab
		clearButton = Qt::PushButton.new 'Clear', playlistTab

		grid_Playlist.addWidget biliUrlLabel, 0, 0, 1, 1
		grid_Playlist.addWidget biliWebButton, 0, 1, 1, 1
		grid_Playlist.addWidget @urlArea, 1, 0, 1, 4
		grid_Playlist.addWidget @messageLabel, 2, 0, 1, 2
		grid_Playlist.addWidget okButton, 2, 2, 1, 1
		grid_Playlist.addWidget clearButton, 2, 3, 1, 1
		grid_Playlist.setColumnStretch 0, 0

		# Settings Tab
		grid_Settings = Qt::GridLayout.new settingsTab
		bilidanPathLabel = Qt::Label.new "Please enter your bilidan's path:", settingsTab
                @bilidanPath = Qt::LineEdit.new @@config["BilidanPath"], settingsTab
                bilidanButton = Qt::PushButton.new 'Choose', settingsTab

		logo = Qt::Label.new "BiliGui is a graphical frontend for Bilidan, developed by marguerite", settingsTab

		grid_Settings.addWidget bilidanPathLabel, 0, 0, 1, 1
		grid_Settings.addWidget @bilidanPath, 0, 1, 1, 1
		grid_Settings.addWidget bilidanButton, 0, 2, 1, 1
		grid_Settings.addWidget logo, 1, 1, 1, 1
		grid_Settings.setColumnStretch 0, 0

		connect bilidanButton, SIGNAL('clicked()'), self, SLOT('bilidanChoose()')
		connect biliWebButton, SIGNAL('clicked()'), self, SLOT('biliWeb()')
		connect okButton, SIGNAL('clicked()'), self, SLOT('bilidan()')
		connect clearButton, SIGNAL('clicked()'), self, SLOT('clear()')
	end

	def bilidan

		require 'open3'

		urlText = @urlArea.toPlainText()
		urlTextHash = BiliGuiUrls.new(urlText).hash
		pathText = @bilidanPath.text()

		# validate bilidan.py path
		unless ! pathText.empty? && File.exists?(pathText) then
			if File.exists?('./bilidan.py')	then
				pathText = "./bilidan.py"
			else
				error = "[ERR] you need to choose bilidan.py!"
                                @messageLabel.setText(error)
			end
		end

		unless urlTextHash.empty? then
	
			urlTextHash.each_value do |hashvalue|

				command = "#{pathText} #{hashvalue}"
				Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
					stderr.each_line do |line| 
						# 99% is a common error can safely ignore
						unless line.index("99%") then
							@messageLabel.setText(line)
						end
					end

					unless wait_thr.value.success?() then
						break
					end
				end

			end

		else
			error = "[ERR] you have to paste an URL!"
			@messageLabel.setText(error)
		end
	end

	def clear
		@urlArea.clear()
	end

	def bilidanChoose
		userHome = `echo $HOME`.gsub(/\n/,"")
		bilidanBin = Qt::FileDialog.getOpenFileName(self, "Please choose your bilidan.py", "#{userHome}", "Python files (*.py)")
		unless bilidanBin == nil then
			if bilidanBin.index("bilidan.py") then
				@bilidanPath.setText(bilidanBin)
				@@configw.put("BilidanPath", bilidanBin)
			else
				@messageLabel.setText("[WARN] You didn't choose bilidan.py!")
			end
		end
	end

	def biliWeb

		@biliweb = Qt::WebView.new
                @biliweb.load Qt::Url.new('http://bilibili.tv')
                @biliweb.show

	end

end

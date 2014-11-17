require 'Qt'
require 'qtwebkit'
require_relative 'BiliConfig'
require_relative 'BiliPlaylist'
require_relative 'BiliWeb'

class BiliGui < Qt::MainWindow

	include BiliConfig
	include BiliPlaylist
	include BiliWeb

	slots 'clear()'
	slots 'bilidanChoose()'
	slots 'bilidanPlay()'
	slots 'bilidanLogOut()'
	slots 'bilidanLogErr()'
	slots 'bilidanPlyButtonCtl()'
	slots 'biliWeb()'
	slots 'biliSave()'
	slots 'biliLoad()'

	Width = 800
	Height = 550
	@@configw = BiliConf.new
	@@config = @@configw.load

	def initialize
		super
		
		setWindowTitle "BiliGui"
		setWindowIcon(Qt::Icon.new("data/bilibili.svgz"))

		@central = Qt::Widget.new self
		@central.setObjectName("centralwidget")
		setCentralWidget @central

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

		@messageLabel = Qt::Label.new
                @messageLabel.setStyleSheet("color: #ff0000;")

		grid_biliTabs = Qt::GridLayout.new(@central)
		grid_biliTabs.addWidget biliTabs, 0, 0, 1, 1
		grid_biliTabs.addWidget @messageLabel, 1, 0, 1, 1
		grid_biliTabs.setColumnStretch 0, 0

		# Playlist Tab		
		grid_Playlist = Qt::GridLayout.new playlistTab

		biliUrlLabel = Qt::Label.new "Please paste Bilibili URL below", playlistTab
		biliWebButton = Qt::PushButton.new 'Visit bilibili.tv (experimental)', playlistTab
		@urlArea = Qt::TextEdit.new playlistTab
		ctlPanel = Qt::Widget.new playlistTab
		@playButton = Qt::PushButton.new 'Play', playlistTab
		clearButton = Qt::PushButton.new 'Clear', playlistTab

		grid_Playlist.addWidget biliUrlLabel, 0, 0, 1, 1
		grid_Playlist.addWidget biliWebButton, 0, 1, 1, 1
		grid_Playlist.addWidget @urlArea, 1, 0, 1, 4
		grid_Playlist.addWidget ctlPanel, 1, 4, 1, 1
		grid_Playlist.addWidget @playButton, 2, 2, 1, 1
		grid_Playlist.addWidget clearButton, 2, 3, 1, 1
		grid_Playlist.setColumnStretch 0, 0


		connect biliWebButton, SIGNAL('clicked()'), self, SLOT('biliWeb()')
                connect @playButton, SIGNAL('clicked()'), self, SLOT('bilidanPlay()')
                connect clearButton, SIGNAL('clicked()'), self, SLOT('clear()')

		## controlPanel layout
		grid_ctlPanel = Qt::GridLayout.new ctlPanel

		ctlLoadButton = Qt::PushButton.new 'Load', ctlPanel
		ctlSaveButton = Qt::PushButton.new 'Save', ctlPanel
		ctlBlank = Qt::Label.new ctlPanel

		grid_ctlPanel.addWidget ctlLoadButton, 0, 0, 1, 1
		grid_ctlPanel.addWidget ctlSaveButton, 1, 0, 1, 1
		grid_ctlPanel.addWidget ctlBlank, 2, 0, 3, 2

		connect ctlLoadButton, SIGNAL('clicked()'), self, SLOT('biliLoad()')
		connect ctlSaveButton, SIGNAL('clicked()'), self, SLOT('biliSave()')

		# Web Tab
		menu = Qt::MenuBar.new(webTab)
		lev1 = BiliParser.new.parse
		lev1.each do |array|
			name = array[1].gsub(/\/video\//,'').gsub(/\.html/,'')
			name = Qt::Menu.new "#{array[0]}"
			menu.addMenu name
		end

		# Settings Tab
		grid_Settings = Qt::GridLayout.new settingsTab
		bilidanPathLabel = Qt::Label.new "Please enter your bilidan's path:", settingsTab
                @bilidanPath = Qt::LineEdit.new @@config["BilidanPath"], settingsTab
                bilidanButton = Qt::PushButton.new 'Choose', settingsTab

		grid_Settings.addWidget bilidanPathLabel, 0, 0, 1, 1
		grid_Settings.addWidget @bilidanPath, 0, 1, 1, 1
		grid_Settings.addWidget bilidanButton, 0, 2, 1, 1
		grid_Settings.setColumnStretch 0, 0

		connect bilidanButton, SIGNAL('clicked()'), self, SLOT('bilidanChoose()')

		# player thread
		@thread = Qt::Process.new

		connect @thread, SIGNAL('readyReadStandardOutput()'), self, SLOT('bilidanLogOut()')
		connect @thread, SIGNAL('readyReadStandardError()'), self, SLOT('bilidanLogErr()')
		connect @thread, SIGNAL('finished(int, QProcess::ExitStatus)'), self, SLOT('bilidanPlyButtonCtl()')

	end

	def clear
		@urlArea.clear
	end

	def bilidanPlay
		require 'open3'

		urlText = @urlArea.toPlainText()
		urlHash = BiliPlaylist.new(urlText).hash 
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

		unless urlHash.empty? then

			# play all videos
			urlHash.each_value do |value|
				p "Now Playing: #{value}"

				command = "#{pathText} #{value}"
				@thread.start(command)
				 
			end

		else
			error = "[ERR] you have to paste an URL!"
			@messageLabel.setText(error)
		end

		# disable Play button here
		@playButton.setEnabled false

	end

	def bilidanLogOut
		stdout = @thread.readAllStandardOutput.to_s.chomp!
		p stdout
	end

	# bilidan? why buffer message redirected to stderr?!
	def bilidanLogErr
		stderr = @thread.readAllStandardError.to_s.chomp!
		p stderr
	end

	def bilidanPlyButtonCtl
		# release Play button
		@playButton.setEnabled true
	end

	def bilidanChoose
		bilidanBin = Qt::FileDialog.getOpenFileName(self, "Please choose your bilidan.py", "#{$userHome}", "Python files (*.py)")
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

	def biliLoad
		playlist = Qt::FileDialog.getOpenFileName(self, "Please choose your playlist", "#{$configPath}/playlist", "Playlist file (*.m3u8)")
		unless playlist == nil then
			hash = BiliPlaylist.new.load(playlist)
			str = ""
			hash.each_value do |value|
				str += value + "\n"
			end
			@urlArea.setText(str)
		end
	end
	
	def biliSave
		if @urlArea.toPlainText().empty? then
			p "No video URL can be saved at all!"
		else
			filename = Qt::FileDialog.getSaveFileName(self, "Please choose save location", "#{$configPath}/playlist", "Playlist file (*.m3u8)")
			unless filename == nil then
				playlist = BiliPlaylist.new(@urlArea.toPlainText())
				playlist.save(filename)
			end
		end
	end

end

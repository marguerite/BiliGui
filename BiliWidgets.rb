require 'Qt'
require 'qtwebkit'
require 'open3'
require 'gettext'
require_relative 'BiliConfig'
require_relative 'BiliPlaylist'
require_relative 'BiliWeb'

class BiliGui < Qt::MainWindow

	include BiliConfig
	include BiliPlaylist
	include BiliWeb

	include GetText
	bindtextdomain("BiliGui")

	slots 'clear()'
	slots 'bilidanChoose()'
	slots 'bilidanAutoSave()'
	slots 'bilidanPlay()'
	slots 'bilidanLogOut()'
	slots 'bilidanLogErr()'
	slots 'bilidanPlyButtonCtl()'
	slots 'biliWeb()'
	slots 'biliSave()'
	slots 'biliLoad()'
	slots 'biliHistory()'

	Width = 800
	Height = 550

	def initialize
		super
		
		setWindowTitle _("BiliGui")
		setWindowIcon(Qt::Icon.new("data/bilibili.svgz"))

		@central = Qt::Widget.new self
		@central.setObjectName("centralwidget")
		setCentralWidget @central

		@configw = BiliConf.new
		@config = @configw.load
		@last = BiliPlaylist.new.last

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

		biliTabs.addTab	playlistTab, _("BiliGui Playlist")
		biliTabs.addTab settingsTab, _("BiliGui Settings")
		biliTabs.addTab webTab, _("Bilibili.tv")

		@messageLabel = Qt::Label.new
                @messageLabel.setStyleSheet("color: #ff0000;")

		grid_biliTabs = Qt::GridLayout.new(@central)
		grid_biliTabs.addWidget biliTabs, 0, 0, 1, 1
		grid_biliTabs.addWidget @messageLabel, 1, 0, 1, 1
		grid_biliTabs.setColumnStretch 0, 0

		# Playlist Tab		
		grid_Playlist = Qt::GridLayout.new playlistTab

		biliUrlLabel = Qt::Label.new _("Please paste Bilibili URL/bangou below"), playlistTab
		biliWebButton = Qt::PushButton.new _("Visit bilibili.tv (experimental)"), playlistTab
		@urlArea = Qt::TextEdit.new playlistTab
		@urlArea.setText(@last)
		ctlPanel = Qt::Widget.new playlistTab
		@playButton = Qt::PushButton.new _("Play"), playlistTab
		clearButton = Qt::PushButton.new _("Clear"), playlistTab

		grid_Playlist.addWidget biliUrlLabel, 0, 0, 1, 1
		grid_Playlist.addWidget biliWebButton, 0, 1, 1, 1
		grid_Playlist.addWidget @urlArea, 1, 0, 1, 4
		grid_Playlist.addWidget ctlPanel, 1, 4, 1, 1
		grid_Playlist.addWidget @playButton, 2, 2, 1, 1
		grid_Playlist.addWidget clearButton, 2, 3, 1, 1
		grid_Playlist.setColumnStretch 0, 0


		connect biliWebButton, SIGNAL('clicked()'), self, SLOT('biliWeb()')
		connect @urlArea, SIGNAL('textChanged()'), self, SLOT('biliHistory()')
                connect @playButton, SIGNAL('clicked()'), self, SLOT('bilidanPlay()')
                connect clearButton, SIGNAL('clicked()'), self, SLOT('clear()')

		## controlPanel layout
		grid_ctlPanel = Qt::GridLayout.new ctlPanel

		ctlLoadButton = Qt::PushButton.new _("Load"), ctlPanel
		ctlSaveButton = Qt::PushButton.new _("Save"), ctlPanel
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

		bilidanPathLabel = Qt::Label.new _("Please enter your bilidan's path:"), settingsTab
                @bilidanPath = Qt::LineEdit.new @config["BilidanPath"], settingsTab
                bilidanButton = Qt::PushButton.new _("Choose"), settingsTab
		
		bilidanMpvFlagsLabel = Qt::Label.new _("mpv flags for bilidan:"), settingsTab
		@bilidanMpvFlags = Qt::LineEdit.new @config["mpvflags"], settingsTab

		bilidanD2AFlagsLabel = Qt::Label.new _("danmaku2ass flags for bilidan:"), settingsTab
		@bilidanD2AFlags = Qt::LineEdit.new @config["danmaku2assflags"], settingsTab

		grid_Settings.addWidget bilidanPathLabel, 0, 0, 1, 1
		grid_Settings.addWidget @bilidanPath, 0, 1, 1, 1
		grid_Settings.addWidget bilidanButton, 0, 2, 1, 1
		grid_Settings.addWidget bilidanMpvFlagsLabel, 1, 0, 1, 1
		grid_Settings.addWidget @bilidanMpvFlags, 1, 1, 1, 1
		grid_Settings.addWidget bilidanD2AFlagsLabel, 2, 0, 1, 1
		grid_Settings.addWidget @bilidanD2AFlags, 2, 1, 1, 1
		grid_Settings.setColumnStretch 0, 0

		connect @bilidanPath, SIGNAL('textChanged(const QString)'), self, SLOT('bilidanAutoSave()')
		connect @bilidanMpvFlags, SIGNAL('textChanged(const QString)'), self, SLOT('bilidanAutoSave()')
		connect @bilidanD2AFlags, SIGNAL('textChanged(const QString)'), self, SLOT('bilidanAutoSave()')
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

		urlText = @urlArea.toPlainText()
		urlHash = BiliPlaylist.new(urlText).hash 
		pathText = @bilidanPath.text()
		mpvflagsText = "--mpvflags=\"" + @bilidanMpvFlags.text + "\""
		d2aflagsText = "--d2aflags=\"" + @bilidanD2AFlags.text + "\""
		parameter = "#{mpvflagsText} #{d2aflagsText}"

		# validate bilidan.py path
		unless ! pathText.empty? && File.exist?(pathText) then
			if File.exist?('./bilidan.py')	then
				pathText = "./bilidan.py"
			else
				error = _("[ERR] you need to choose bilidan.py!")
                                @messageLabel.setText(error)
			end
		end

		unless urlHash.empty? then

			# play all videos
			urlHash.each_value do |value|
				print _("Now Playing: ") + value

				command = "#{pathText} #{parameter} #{value}"
				@thread.start(command)
				 
			end

		else
			error = _("[ERR] you have to paste at least one URL/bangou!")
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
		bilidanBin = Qt::FileDialog.getOpenFileName(self, _("Please choose your bilidan.py"), "#{$userHome}", _("Python files (*.py)"))
		unless bilidanBin == nil then
			if bilidanBin.index("bilidan.py") then
				@bilidanPath.setText(bilidanBin)
			else
				@messageLabel.setText(_("[WARN] You didn't choose bilidan.py!"))
			end
		end
	end

	def bilidanAutoSave

		# avoid waste resource
		if @bilidanPath.text.index("bilidan.py") then
			@configw.put("BilidanPath", @bilidanPath.text)
		end
	
		unless @bilidanMpvFlags.text.empty? then
			@configw.put("mpvflags", @bilidanMpvFlags.text)
		end

		unless @bilidanD2AFlags.text.empty? then
			@configw.put("danmaku2assflags", @bilidanD2AFlags.text)
		end

	end

	def biliWeb

		@biliweb = Qt::WebView.new
                @biliweb.load Qt::Url.new('http://bilibili.tv')
                @biliweb.show

	end

	def biliLoad
		playlist = Qt::FileDialog.getOpenFileName(self, _("Please choose your playlist"), "#{$configPath}/playlist", _("Playlist file (*.m3u8)"))
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
			print _("No video URL/bangou can be saved at all!")
		else
			filename = Qt::FileDialog.getSaveFileName(self, _("Please choose save location"), "#{$configPath}/playlist", _("Playlist file (*.m3u8)"))
			unless filename == nil then
				playlist = BiliPlaylist.new(@urlArea.toPlainText())
				playlist.save(filename)
			end
		end
	end

	def biliHistory

		if @urlArea.toPlainText.index("av") then
			BiliPlaylist.new(@urlArea.toPlainText).history
		end

	end

end

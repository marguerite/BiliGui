#!/usr/bin/ruby

require 'Qt'
require 'qtwebkit'

Qt.debug_level = Qt::DebugLevel::High

class QtApp < Qt::Widget

	slots 'bilidan()'
	slots 'clear()'
	slots 'bilidanChoose()'
	slots 'biliGoWeb()'

	Width = 600
	Height = 100

	def initialize
		super
		
		setWindowTitle "BiliGui"

		setToolTip "BiliDan GUI"

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
		grid = Qt::GridLayout.new self

		bilidanPathLabel = Qt::Label.new "Please enter your bilidan's path:", self
		@bilidanPath = Qt::LineEdit.new self
		bilidanButton = Qt::PushButton.new 'Choose', self
		biliUrlLabel = Qt::Label.new "Please paste Bilibili URL below", self
		#biliWebButton = Qt::PushButton.new 'Visit bilibili.tv (experimental)', self
		@urlArea = Qt::TextEdit.new self
		@messageLabel = Qt::Label.new "", self
		@messageLabel.setStyleSheet("color: #ff0000;")	
		okButton = Qt::PushButton.new 'Watch', self
		clearButton = Qt::PushButton.new 'Clear', self

		grid.addWidget bilidanPathLabel, 0, 0, 1, 1
		grid.addWidget @bilidanPath, 0, 1, 1, 2
		grid.addWidget bilidanButton, 0, 3, 1, 1
		grid.addWidget biliUrlLabel, 1, 0, 1, 3
		#grid.addWidget biliWebButton, 1, 3, 1, 1
		grid.addWidget @urlArea, 2, 0, 1, 4
		grid.addWidget @messageLabel, 3, 0, 1, 1
		grid.addWidget okButton, 3, 2, 1, 1
		grid.addWidget clearButton, 3, 3, 1, 1
		grid.setColumnStretch 1, 2

		connect bilidanButton, SIGNAL('clicked()'), self, SLOT('bilidanChoose()')
		#connect biliWebButton, SIGNAL('clicked()'), self, SLOT('biliGoWeb()')
		connect okButton, SIGNAL('clicked()'), self, SLOT('bilidan()')
		connect clearButton, SIGNAL('clicked()'), self, SLOT('clear()')
	end

	def bilidan
		urlText = @urlArea.toPlainText()
		pathText = @bilidanPath.text()
		if urlText != "" then
			# more tests ?
			if pathText != "" && File.exists?(pathText) then
				command = "#{pathText} #{urlText}"
				exec command
			elsif File.exists?('./bilidan.py') then
				command = "./bilidan.py #{urlText}"
				exec command
			else
				error = "[ERR] you need to choose bilidan.py!"
				@messageLabel.setText(error)
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
		@bilidanPath.setText(bilidanBin)
	end

	def biliGoWeb
		biliweb = Qt::WebView.new
		biliweb.load Qt::Url.new('http://www.bilibili.tv/')
		biliweb.resize 1024, 640
		biliweb.show
	end

end

app = Qt::Application.new ARGV
QtApp.new
app.exec

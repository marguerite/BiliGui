#!/usr/bin/ruby

require 'Qt'

Width = 600
Height = 100

class QtApp < Qt::Widget

	slots 'bilidan()'
	slots 'clear()'

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

		biliUrlLabel = Qt::Label.new "Please paste Bilibili URL below", self
		bilidanPathLabel = Qt::Label.new "Please enter your bilidan's path:", self
		@urlArea = Qt::TextEdit.new self
		@bilidanPath = Qt::LineEdit.new self	
		okButton = Qt::PushButton.new 'Fire!', self
		clearButton = Qt::PushButton.new 'Clear', self

		grid.addWidget bilidanPathLabel, 0, 0, 1, 1
		grid.addWidget @bilidanPath, 0, 1, 1, 2
		grid.addWidget biliUrlLabel, 1, 0, 1, 3
		grid.addWidget @urlArea, 2, 0, 1, 3
		grid.addWidget okButton, 3, 1, 1, 1
		grid.addWidget clearButton, 3, 2, 1, 1
		grid.setColumnStretch 3, 0

		connect okButton, SIGNAL('clicked()'), self, SLOT('bilidan()')
		connect clearButton, SIGNAL('clicked()'), self, SLOT('clear()')
	end

	def bilidan
		urlText = @urlArea.toPlainText()
		pathText = @bilidanPath.text()
		if urlText != "" then
			if pathText != "" then
				command = "#{pathText}/bilidan.py #{urlText}"
			else
				command = "./bilidan.py #{urlText}"
			end
			exec command
		else
			puts "[ERR] you have to paste an URL!"
		end
	end

	def clear
		@urlArea.clear()
	end

end

app = Qt::Application.new ARGV
QtApp.new
app.exec

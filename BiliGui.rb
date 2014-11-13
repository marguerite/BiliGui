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

		nameLabel = Qt::Label.new "Please paste Bilibili URL below", self
		@urlArea = Qt::TextEdit.new self	
		okButton = Qt::PushButton.new 'Fire!', self
		clearButton = Qt::PushButton.new 'Clear', self

		grid.addWidget nameLabel, 0, 0, 1, 3
		grid.addWidget @urlArea, 1, 0, 1, 3
		grid.addWidget okButton, 2, 1, 1, 1
		grid.addWidget clearButton, 2, 2, 1, 1
		grid.setColumnStretch 2, 0

		connect okButton, SIGNAL('clicked()'), self, SLOT('bilidan()')
		connect clearButton, SIGNAL('clicked()'), self, SLOT('clear()')
	end

	def bilidan
		text = @urlArea.toPlainText()
		command = "./bilidan.py #{text}"
		exec command
	end

	def clear
		@urlArea.clear()
	end

end

app = Qt::Application.new ARGV
QtApp.new
app.exec

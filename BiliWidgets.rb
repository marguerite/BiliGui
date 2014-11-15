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

class QtApp < Qt::Widget

	slots 'bilidan()'
	slots 'clear()'
	slots 'bilidanChoose()'
	slots 'biliGoWeb()'

	Width = 600
	Height = 100
	@@configw = BiliGuiConfig.new
	@@config = @@configw.load

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
		@bilidanPath = Qt::LineEdit.new @@config["BilidanPath"], self
		bilidanButton = Qt::PushButton.new 'Choose', self
		biliUrlLabel = Qt::Label.new "Please paste Bilibili URL below", self
		biliWebButton = Qt::PushButton.new 'Visit bilibili.tv (experimental)', self
		@urlArea = Qt::TextEdit.new self
		@messageLabel = Qt::Label.new "", self
		@messageLabel.setStyleSheet("color: #ff0000;")	
		okButton = Qt::PushButton.new 'Watch', self
		clearButton = Qt::PushButton.new 'Clear', self
		@consoleArea = Qt::TextEdit.new self
		@consoleArea.setVisible false
		@consoleArea.setStyleSheet("color: #fff; background-color: #333;")

		grid.addWidget bilidanPathLabel, 0, 0, 1, 1
		grid.addWidget @bilidanPath, 0, 1, 1, 2
		grid.addWidget bilidanButton, 0, 3, 1, 1
		grid.addWidget biliUrlLabel, 1, 0, 1, 3
		grid.addWidget biliWebButton, 1, 3, 1, 1
		grid.addWidget @urlArea, 2, 0, 1, 4
		grid.addWidget @messageLabel, 3, 0, 1, 1
		grid.addWidget okButton, 3, 2, 1, 1
		grid.addWidget clearButton, 3, 3, 1, 1
		grid.addWidget @consoleArea, 4, 0, 1, 4
		grid.setColumnStretch 1, 2

		connect bilidanButton, SIGNAL('clicked()'), self, SLOT('bilidanChoose()')
		connect biliWebButton, SIGNAL('clicked()'), self, SLOT('biliGoWeb()')
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
		@bilidanPath.setText(bilidanBin)
		@@configw.put("BilidanPath", bilidanBin)
	end

	def biliGoWeb
		biliweb = Qt::WebView.new
		biliweb.load Qt::Url.new('http://www.bilibili.tv/')
		biliweb.resize 1024, 640
		biliweb.show
	end

end

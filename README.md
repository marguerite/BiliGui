![BiliGui Logo](https://raw.githubusercontent.com/marguerite/BiliGui/master/data/bilibili.png)

## BiliGui

BiliGui is an All-in-one frontend for all the Bilibili black magic in Linux world.

It's written in `ruby` + `Qt` and highly modular, eg: using [BiliDan](https://github.com/m13253/BiliDan)
as player backend (further callback `mpv`), [Biligrab](https://github.com/cnbeining/Biligrab) as download module
and a lot more.

![BiliGui Screenshot](https://raw.githubusercontent.com/marguerite/BiliGui/master/data/screenshot.png)

### Features

### Installation

You need ruby and `qtbindings` gem.

If you have rvm, run

	rvm install ruby-2.1.4
	gem install qtbindings (need libqt4-devel and libQtWebKit-devel installed)

If you're using openSUSE, which is the best distribution ever, just add `devel:languages:ruby:extensions` repo
and run:

	sudo zypper in rubygem-qtbindings (ruby is already installed because of YaST installtion)

#### Optional

Place BiliGui.desktop anywhere that is easy to you.

Remeber to edit the absolute paths in BiliGui.desktop

***NOTE*** the "Exec=" field is important!

If you're using `rvm`, you should keep it the way it is, which is:

    rvm use 2.1.4 do /absolute/path/to/your/biligui.rb/installation

If you're using system ruby and qtbindings gem, you should change it to:

    /usr/bin/ruby /absolute/path/to/your/biligui.rb/installation

Or the .desktop file will not run.

### License

MIT 

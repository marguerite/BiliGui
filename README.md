![BiliGui Logo](https://raw.githubusercontent.com/marguerite/BiliGui/master/data/bilibili.png)

## BiliGui

BiliGui is an all-in-one frontend for all the Bilibili black magic in Linux world.

It's written in `ruby` + `Qt` and highly modular, eg: using [BiliDan](https://github.com/m13253/BiliDan)
as player backend (further callback `mpv`), [Biligrab](https://github.com/cnbeining/Biligrab) as download module
and a lot more.

![BiliGui Screenshot](https://raw.githubusercontent.com/marguerite/BiliGui/master/data/screenshot.png)

### Features

* It's the 1st GUI program for bilibili.tv under Linux!
* No more Flash!
* Callback a powerful media player (`mpv`) to actually play videos, so hardware decoding is possible
* You can place your bilidan elsewhere
* Multi URL/bangou support
* Mix-paste URL/bangou, as you like
* Load/save playlists (in m3u8, a popular format) so you can share w/ friends or backup yourself 
* Continously play, so you can paste once and watch a looooong time, and don't need to bother switch tabs (like what you do in a browser)
* Autosave, you don't need to worry about losing anything!
* Theming support
* I18n ready

### Installation

You need ruby, `qtbindings` and `gettext` gems.

If you have rvm, run

	rvm install ruby-2.1.4
	gem install qtbindings (need libqt4-devel and libQtWebKit-devel installed)
	gem install gettext

If you're using openSUSE, which is the best distribution ever, just add `devel:languages:ruby:extensions` repo
and run:

	sudo zypper in rubygem-qtbindings rubygem-gettext (ruby is already installed because of YaST installtion)

bilidan, danmaku2ass are also required (because we're just a `GUI`), please refer to their github pages to see related dependencies.

### Optional

#### Destkop integration

Place BiliGui.desktop anywhere that is easy to you.

Remeber to edit the absolute paths in BiliGui.desktop

***NOTE*** the "Exec=" field is important!

If you're using `rvm`, you should keep it the way it is, which is:

    rvm use 2.1.4 do /absolute/path/to/your/biligui.rb/installation

If you're using system ruby and qtbindings gem, you should change it to:

    /usr/bin/ruby /absolute/path/to/your/biligui.rb/installation

Or the .desktop file will not run.

#### I18N

If you're using rvm, please put the mo file(s) to path like:

    ~/.rvm/gems/ruby-2.1.4/gems/gettext-3.1.4/locale/zh/LC_MESSAGES/BiliGui.mo

instead of system-wide directory like /usr/share/locale/zh_CN/LC_MESSAGES, or you won't see language changed.

### License

MIT 

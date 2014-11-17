#!/usr/bin/ruby
require_relative 'BiliWidgets'
app = Qt::Application.new ARGV
open("data/style.qss",'r') {|f| app.setStyleSheet(f.read)}
BiliGui.new
app.exec

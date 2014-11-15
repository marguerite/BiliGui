#!/usr/bin/ruby
require_relative 'BiliWidgets'
app = Qt::Application.new ARGV
BiliGui.new
app.exec

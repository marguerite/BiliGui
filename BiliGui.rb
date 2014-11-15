#!/usr/bin/ruby
require_relative 'BiliWidgets'
app = Qt::Application.new ARGV
QtApp.new
app.exec

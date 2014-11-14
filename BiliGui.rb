#!/usr/bin/ruby
require_relative 'BiliGuiWidget'
app = Qt::Application.new ARGV
QtApp.new
app.exec

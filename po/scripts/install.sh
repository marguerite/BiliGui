#!/bin/sh
for i in zh_CN zh_TW; do
	msgfmt ../BiliGui.${i}.po -o ../BiliGui.${i}.mo
done

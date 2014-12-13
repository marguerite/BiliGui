#!/bin/sh
for i in zh_CN zh_TW; do
	rmsgmerge -U ../BiliGui.${i}.po ../BiliGui.pot
done

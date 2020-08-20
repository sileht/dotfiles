#!/bin/bash


#  @i3pystatus.get_module
#  def add_bose_battery_glyph(self):
#      glyphs = "ﴐﴆﴇﴈﴉﴊﴋﴌﴍﴎﴅ"
#      try:
#          level = int(self.output["full_text"])
#      except ValueError:
#          self.output["full_text"] = ""
#          return
#      pos = int(level * len(glyphs) / 100)
#      self.output["full_text"] = glyphs[pos] + " " + self.output["full_text"] + "%"

glyphs="ﴐﴆﴇﴈﴉﴊﴋﴌﴍﴎﴅ"
color_0="%{F#cc0033}"
color_1="%{F#ffb52a}"
color_2="%{F#ffb52a}"
color_7="%{F#009966}"
color_8="%{F#009966}"
vol=$(based-connect -b 4C:87:5D:06:32:13 2>/dev/null)
if [ "$vol" ]; then
    i=$(($vol * ${#glyphs} / 100))
    [ "$i" -eq 0 ] && i=8
    glyph=${glyphs:$i:1}
    color=$(eval echo '$color_'$i)
    echo "$color $glyph ${vol}%%{F-}"
fi

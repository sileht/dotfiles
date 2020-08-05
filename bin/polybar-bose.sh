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
vol=$(based-connect -b 4C:87:5D:06:32:13 2>/dev/null)
if [ "$vol" ]; then
    i=$(($vol * ${#glyphs} / 100))
    glyph=${glyphs:$i:1}
    echo "$glyph ${vol}%"
fi

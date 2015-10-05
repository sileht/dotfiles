#!/home/sileht/.i3/venv/bin/python

from i3pystatus import Status

status = Status(standalone=True)
status.register("clock", format="%a %b %d, %H:%M")
status.register("weather", format="{current_temp}",
                colorize=True,
                location_code="FRXX0099:1:FR")
status.register("battery",
                format="{status}{remaining:%E%hh:%Mm}",
                alert=True, alert_percentage=5,
                status={"DIS": "↓", "CHR": "↑", "FULL": "="},
                not_present_text="",
                )
status.register("shell", command="/home/sileht/.i3/vpn-chk.sh",
                hints={"markup": "pango"})


status.register("livestatus",
                url="tcp://localhost:6557",
                format="S: {items}",
                max_items=5,
                item_format=("<span color=\"{state_color}\">"
                             "{host_name}: {description}</span>"),
                query="""
GET services
Filter: state > 0
Filter: acknowledged = 0
Filter: description !~~ ^(Check_MK inventory|Interface tap|PING)
Filter: host_name !~~ ^(tsf-|pingall)
Columns: host_name description
""")
status.register("livestatus",
                url="tcp://localhost:6557",
                max_items=5,
                format="H: {items}",
                item_format=("<span color=\"{state_color}\">"
                             "{name}</span>"),
                query="""
GET hosts
Filter: state > 0
Filter: acknowledged = 0
Filter: name !~~ ^(tsf-|pingall)
Columns: name
""")


status.run()

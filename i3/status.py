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
status.register("shell", command="/home/sileht/.i3/vpn-chk.sh")

#status.register("livestatus",
#                url="tcp://localhost:6557",
#                format="S: {items}",
#                item_format="{host_name}: {description}",
#                query="""GET services
#Filter: state > 0
#Filter: acknowledged = 0
#Filter: host_name != pingall
#Columns: host_name description
#""")
#status.register("livestatus",
#                url="tcp://localhost:6557",
#                format="H: {items}",
#                query="""GET hosts
#Filter: state > 0
#Filter: acknowledged = 0
#Filter: name != pingall
#Columns: name
#""")

status.run()

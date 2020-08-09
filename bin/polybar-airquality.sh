#!/bin/sh

TOKEN="$(cat ~/.aqicn.token)"
CITY="toulouse"

API="https://api.waqi.info/feed"

if [ -n "$CITY" ]; then
    aqi=$(curl -sf "$API/$CITY/?token=$TOKEN")
else
    location=$(curl -sf https://location.services.mozilla.com/v1/geolocate?key=geoclue)

    if [ -n "$location" ]; then
        location_lat="$(echo "$location" | jq '.location.lat')"
        location_lon="$(echo "$location" | jq '.location.lng')"

        aqi=$(curl -sf "$API/geo:$location_lat;$location_lon/?token=$TOKEN")
    fi
fi

if [ -n "$aqi" ]; then
    if [ "$(echo "$aqi" | jq -r '.status')" = "ok" ]; then
        aqi=$(echo "$aqi" | jq '.data.aqi')

        if [ "$aqi" -le 50 ]; then
            echo "%{F#009966}  $aqi%{F-}"
        elif [ "$aqi" -le 100 ]; then
            echo "%{F#ffde33}  $aqi%{F-}"
        elif [ "$aqi" -le 150 ]; then
            echo "%{F#ff9933}  $aqi%{F-}"
        elif [ "$aqi" -le 200 ]; then
            echo "%{F#cc0033}  $aqi%{F-}"
        elif [ "$aqi" -le 300 ]; then
            echo "%{F#660099}  $aqi%{F-}"
        else
            echo "%{F#7e0023}  $aqi%{F-}"
        fi
    else
        echo "$aqi" | jq -r '.data'
    fi
fi

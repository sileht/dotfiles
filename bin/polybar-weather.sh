#!/bin/sh

# https://github.com/coreymwamba/polybar-scripts/blob/master/weather-summary


get_wind_color() {
    if [ "$1" -le 5 ]; then
        color="%{F#009966}"
    elif [ "$1" -ge 40 ]; then
        color="%{F#ffb52a}"
    elif [ "$1" -ge 50 ]; then
        color="%{F#cc0033}}"
    else
        color="%{F#1976D2}"
    fi
    echo $color
}

get_temp_color() {
    if [ "$1" -le 15 ]; then
        color="%{F#1976D2}"
    elif [ "$1" -ge 28 ]; then
        color="%{F#ffb52a}"
    elif [ "$1" -ge 32 ]; then
        color="%{F#cc0033}}"
    else
        color="%{F#009966}"
    fi
    echo $color
}

get_icon() {
    case $1 in
        # Icons for weather-icons
        01d) icon="";;
        01n) icon="";;
        02d) icon="";;
        02n) icon="";;
        03*) icon="";;
        04*) icon="";;
        09d) icon="";;
        09n) icon="";;
        10d) icon="";;
        10n) icon="";;
        11d) icon="";;
        11n) icon="";;
        13d) icon="";;
        13n) icon="";;
        50d) icon="";;
        50n) icon="";;
        *) icon="";

        # Icons for Font Awesome 5 Pro
        #01d) icon="";;
        #01n) icon="";;
        #02d) icon="";;
        #02n) icon="";;
        #03d) icon="";;
        #03n) icon="";;
        #04*) icon="";;
        #09*) icon="";;
        #10d) icon="";;
        #10n) icon="";;
        #11*) icon="";;
        #13*) icon="";;
        #50*) icon="";;
        #*) icon="";
    esac

    echo $icon
}

get_duration() {

    osname=$(uname -s)

    case $osname in
        *BSD) date -r "$1" -u +%H:%M;;
        *) date --date="@$1" -u +%H:%M;;
    esac

}

KEY="$(cat ~/.openweathermap-token)"
CITY="Toulouse"
UNITS="metric"
SYMBOL="°"

API="https://api.openweathermap.org/data/2.5"

if [ -n "$CITY" ]; then
    if [ "$CITY" -eq "$CITY" ] 2>/dev/null; then
        CITY_PARAM="id=$CITY"
    else
        CITY_PARAM="q=$CITY"
    fi

    current=$(curl -sf "$API/weather?appid=$KEY&$CITY_PARAM&units=$UNITS")
    forecast=$(curl -sf "$API/forecast?appid=$KEY&$CITY_PARAM&units=$UNITS&cnt=1")
else
    location=$(curl -sf https://location.services.mozilla.com/v1/geolocate?key=geoclue)

    if [ -n "$location" ]; then
        location_lat="$(echo "$location" | jq '.location.lat')"
        location_lon="$(echo "$location" | jq '.location.lng')"

        current=$(curl -sf "$API/weather?appid=$KEY&lat=$location_lat&lon=$location_lon&units=$UNITS")
        forecast=$(curl -sf "$API/forecast?appid=$KEY&lat=$location_lat&lon=$location_lon&units=$UNITS&cnt=1")
    fi
fi

if [ -n "$current" ] && [ -n "$forecast" ]; then
    current_temp=$(echo "$current" | jq ".main.temp" | cut -d "." -f 1)
    current_icon=$(echo "$current" | jq -r ".weather[0].icon")
    current_desc=$(echo "$current" | jq -r ".weather[0].description")
    current_color=$(get_temp_color $current_temp)

    forecast_temp=$(echo "$forecast" | jq ".list[].main.temp" | cut -d "." -f 1)
    forecast_icon=$(echo "$forecast" | jq -r ".list[].weather[0].icon")
    forecast_desc=$(echo "$forecast" | jq -r ".list[].weather[0].description")
    forecast_color=$(get_temp_color $forecast_temp)

    if [ "$current_temp" -gt "$forecast_temp" ]; then
        trend="免"
    elif [ "$forecast_temp" -gt "$current_temp" ]; then
        trend="勤"
    else
        trend="勉"
    fi

    wind=$(echo "$current" | jq ".wind.speed")
    wind=$(echo "$wind * 3600 / 1000" | bc -l)
    wind=${wind%.*}

    wind_color=$(get_wind_color $wind)


    sun_rise=$(echo "$current" | jq ".sys.sunrise")
    sun_set=$(echo "$current" | jq ".sys.sunset")
    now=$(date +%s)

    if [ "$sun_rise" -gt "$now" ]; then
        daytime=" $(get_duration "$((sun_rise-now))")"
    elif [ "$sun_set" -gt "$now" ]; then
        daytime=" $(get_duration "$((sun_set-now))")"
    else
        daytime=" $(get_duration "$((sun_rise-now))")"
    fi

    sun_rise=" "$(date -d @$sun_rise "+%H:%M")
    sun_set=""$(date -d @$sun_set "+%H:%M")


    echo -n "$sun_rise  $sun_set  "
    echo -n "   $wind_color${wind}km/h%{F-}"
    echo -n "  $(get_icon "$current_icon") $current_desc, $current_color$current_temp$SYMBOL%{F-}"
    echo -n "  $trend"
    echo -n "  $(get_icon "$forecast_icon") $forecast_desc, $forecast_color$forecast_temp$SYMBOL%{F-}"
    echo
fi

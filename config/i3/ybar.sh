#!/bin/sh

format_percent() {
   local input="$1"
   local width="${2:-5}"          # Default width = 5
   local fill="${3:- }"           # Default fill = space

   awk -v pct="$input" -v w="$width" -v f="$fill" '
   function fillsubstr(c, n,   s, i) {
      for (i = 1; i <= n; i++) s = s c;
      return s;
   }
   BEGIN {
      padlen = w - length(pct);
      if (padlen < 0) padlen = 0;
      pad = fillsubstr(f, padlen);
      printf "%s%s\n", pad, pct;
   }'
}

get_battery_icon() {
    percent=$(echo "$1" | tr -d '%')

    if [ "$percent" -lt 20 ]; then
        echo ""  # 0-19%
    elif [ "$percent" -lt 40 ]; then
        echo ""  # 20-39%
    elif [ "$percent" -lt 60 ]; then
        echo ""  # 40-59%
    elif [ "$percent" -lt 80 ]; then
        echo ""  # 60-79%
    else
        echo ""  # 80-100%
    fi
}

battery_alert_sent=0
send_battery_alert() {
    percent=$(echo "$1" | tr -d '%')

    if [ "$percent" -le 15 ] && [ "$battery_alert_sent" -eq 0 ]; then
        notify-send -w -u critical "Battery below limit 15%"
        battery_alert_sent=1
    fi
}


XRES="$HOME/.Xresources"

# Function to get default if not found
get_color() {
    key="$1"
    value=$(grep -E "^\*\.$key:" "$XRES" | awk '{ print $2 }')

    if [ -n "$value" ]; then
        echo "$value"
    else
        case "$key" in
            background) echo "#0d0f12" ;;
            foreground) echo "#eeeedf" ;;
            color0) echo "#0d0f12" ;;
            color1) echo "#656053" ;;
            color2) echo "#996A3E" ;;
            color3) echo "#CC9F66" ;;
            color4) echo "#7D8082" ;;
            color5) echo "#BFAE8E" ;;
            color6) echo "#ECD79F" ;;
            color7) echo "#eeeedf" ;;
            color8) echo "#a6a69c" ;;
            color9) echo "#656053" ;;
            color10) echo "#996A3E" ;;
            color11) echo "#CC9F66" ;;
            color12) echo "#7D8082" ;;
            color13) echo "#BFAE8E" ;;
            color14) echo "#ECD79F" ;;
            color15) echo "#eeeedf" ;;
            color66) echo "#0d0f12" ;;
            *) echo "#000000" ;;  # fallback for unknown keys
        esac
    fi
}

# Assigning colors to variables
background=$(get_color "background")
foreground=$(get_color "foreground")

color0=$(get_color "color0")
color1=$(get_color "color1")
color2=$(get_color "color2")
color3=$(get_color "color3")
color4=$(get_color "color4")
color5=$(get_color "color5")
color6=$(get_color "color6")
color7=$(get_color "color7")
color8=$(get_color "color8")
color9=$(get_color "color9")
color10=$(get_color "color10")
color11=$(get_color "color11")
color12=$(get_color "color12")
color13=$(get_color "color13")
color14=$(get_color "color14")
color15=$(get_color "color15")
color16=$(get_color "color16")

echo '{ "version": 1 }'

# Begin the endless array.
echo '['

# We send an empty first array of blocks to make the loop simpler:
echo '[]'

while :;
do
  hour=$(date "+%H:%M:%S")
  today=$(date "+%a, %b/%d")

  ip_addr=$(nmcli | grep inet4 | awk '{print $2}' | grep -v "^127" | head -n 1)
  if [ $(ip link show | grep --color=never -c "state UP") -eq 0 ];
  then
    ip_addr="offline"
  fi

  # battery=$(upower -i /org/freedesktop/UPower/devices/battery_BAT1 | grep -o -E --color=never '[0-9]+%')
  audio=$(amixer get Master | grep -E -o --color=never '[0-9]+%' | head -n 1)
  bright=$(brightnessctl | grep Current | grep -o -E --color=never '[0-9]+%')
  used_mem=$(free -h | grep Mem | awk '{print $3}' | sed "s/i//" | sed "s/,/./")
  free_root_disk=$(df -h | egrep "\/$" | awk '{print $4}')
  free_data_disk=$(df -h | egrep "\/DATA$" | awk '{print $4}')
  _cpu_load=$(top -b -d1 -n1 | grep Cpu | sed "s/,/./g" | awk 'BEGIN {cpu=0} {cpu+=$2; cpu+=$4} END {printf "%s%%", cpu}')
  cpu_load=$(format_percent "$_cpu_load" 5 " ")
  _cpu_temp=$(sensors | awk '/Pack/ {print $4" "}' | sed "s/+//")
  cpu_temp=$(format_percent "$_cpu_temp" 5 " ")

  # comment this if you are not in a laptop and remove the corresponding JSON line 
  battery=$(upower -i $(upower -e | grep BAT) | grep --color=never -E "percentage" | awk '{print $2}')
  battery_icon=$(get_battery_icon "$battery")
  send_battery_alert "$battery"

  JSON=$(cat <<EOF
  ,[{
    "full_text": " 🇨🇺 ", "color": "$foreground", "separator": false, "border_right": 0, "border_left": 0, "separator_block_width": 0
  },{
    "full_text": "", "color": "$color1", "separator": false, "border_right": 0, "border_left": 0, "border_bottom": 4, "border_top": 0, "separator_block_width": 0, "background": "#000000"
  },{
    "full_text": "   $cpu_load |   $cpu_temp", "color": "$foreground", "separator": false, "border_right": 0, "border_left": 0, "separator_block_width": 0, "background": "$color1"
  },{
    "full_text": "", "color": "$color4", "separator": false, "border_right": 0, "border_left": 0, "border_bottom": 4, "border_top": 0, "separator_block_width": 0, "background": "$color1"
  },{
    "full_text": "   $used_mem ", "color": "$foreground", "separator": false, "border_right": 0, "border_left": 0, "separator_block_width": 0, "background": "$color4"
  },{
    "full_text": "", "color": "$color1", "separator": false, "border_right": 0, "border_left": 0, "border_bottom": 4, "border_top": 0, "separator_block_width": 0, "background": "$color4"
  },{
    "full_text": "  /: $free_root_disk |   Data: $free_data_disk ", "color": "$foreground", "separator": false, "border_right": 0, "border_left": 0, "separator_block_width": 0, "background": "$color1"
  },{
    "full_text": "", "color": "$color4", "separator": false, "border_right": 0, "border_left": 0, "border_bottom": 4, "border_top": 0, "separator_block_width": 0, "background": "$color1"
  },{
    "full_text": "   $audio ", "color": "$foreground", "background": "$color4", "separator": false, "border_right": 0, "border_left": 0, "separator_block_width": 0
  },{
    "full_text": "", "color": "$color1", "separator": false, "border_right": 0, "border_left": 0, "border_bottom": 4, "border_top": 0, "separator_block_width": 0, "background": "$color4"
  },{
    "full_text": "   $bright ", "color": "$foreground", "background": "$color1", "separator": false, "border_right": 0, "border_left": 0, "separator_block_width": 0
  },{
    "full_text": "", "color": "$color4", "separator": false, "border_right": 0, "border_left": 0, "border_bottom": 4, "border_top": 0, "separator_block_width": 0, "background": "$color1"
  },{
    "full_text": " $battery_icon  $battery ", "color": "$foreground", "background": "$color4", "separator": false, "border_right": 0, "border_left": 0, "separator_block_width": 0
  },{
    "full_text": "", "color": "$color1", "separator": false, "border_right": 0, "border_left": 0, "border_bottom": 4, "border_top": 0, "separator_block_width": 0, "background": "$color4"
  },{
    "full_text": "   $ip_addr ", "color": "$foreground", "background": "$color1", "separator": false, "border_right": 0, "border_left": 0, "separator_block_width": 0
  },{
    "full_text": "", "color": "$color4", "separator": false, "border_right": 0, "border_left": 0, "border_bottom": 4, "border_top": 0, "separator_block_width": 0, "background": "$color1"
  },{
    "full_text": "   $today ", "color": "$foreground", "background": "$color4", "separator": false, "border_right": 0, "border_left": 0, "separator_block_width": 0
  },{
    "full_text": "", "color": "$color1", "separator": false, "border_right": 0, "border_left": 0, "border_bottom": 4, "border_top": 0, "separator_block_width": 0, "background": "$color4"
  },{
    "full_text": "   $hour ", "color": "$foreground", "background": "$color1", "separator": false, "border_right": 0, "border_left": 0, "separator_block_width": 0
  },{
    "full_text": "", "color": "#000000", "separator": false, "border_right": 0, "border_left": 0, "border_bottom": 4, "border_top": 0, "separator_block_width": 0, "background": "$color1"
  }]
EOF
)

  echo $JSON
  sleep 0.5

done
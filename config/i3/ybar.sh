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

echo '{ "version": 1 }'

# Begin the endless array.
echo '['

# We send an empty first array of blocks to make the loop simpler:
echo '[]'

while :;
do
  hour=$(date "+%H:%M:%S")
  today=$(date "+%a, %b/%d")

  ip_addr=$(nmcli | grep inet4 | awk '{print $2}' | grep -v "^127")
  if [ $(ip link show | grep --color=never -c "state UP") -eq 0 ];
  then
    ip_addr="offline"
  fi

  audio=$(amixer get Master | grep -E -o --color=never '[0-9]+%' | head -n 1)
  bright=$(brightnessctl | grep Current | grep -o -E --color=never '[0-9]+%')
  used_mem=$(free -h | grep Mem | awk '{print $3}' | sed "s/i//" | sed "s/,/./")
  free_root_disk=$(df -h | egrep "\/$" | awk '{print $4}')
  free_data_disk=$(df -h | egrep "\/DATA$" | awk '{print $4}')
  _cpu_load=$(top -b -d1 -n1 | grep Cpu | sed "s/,/./g" | awk 'BEGIN {cpu=0} {cpu+=$2; cpu+=$4} END {printf "%s%%", cpu}')
  cpu_load=$(format_percent "$_cpu_load" 5 " ")
  cpu_temp=$(sensors | awk '/Pack/ {print $4" "}' | sed "s/+//")

  # comment this if you are not in a laptop and remove the corresponding JSON line 
  battery=$(upower -i $(upower -e | grep BAT) | grep --color=never -E "percentage" | awk '{print $2}')
  battery_icon=$(get_battery_icon "$battery")
  send_battery_alert "$battery"

  JSON=$(cat <<EOF
  ,[{
    "full_text": " 🇨🇺 ", "color": "#ffffff", "separator": false, "border_right": 0, "border_left": 0, "separator_block_width": 0
  },{
    "full_text": "", "color": "#ea3d3d", "separator": false, "border_right": 0, "border_left": 0, "border_bottom": 4, "border_top": 0, "separator_block_width": 0, "background": "#000000"
  },{
    "full_text": "   $cpu_load |  $cpu_temp", "color": "#ffffff", "separator": false, "border_right": 0, "border_left": 0, "separator_block_width": 0, "background": "#ea3d3d"
  },{
    "full_text": "", "color": "#3b47aa", "separator": false, "border_right": 0, "border_left": 0, "border_bottom": 4, "border_top": 0, "separator_block_width": 0, "background": "#ea3d3d"
  },{
    "full_text": "   $used_mem ", "color": "#ffffff", "separator": false, "border_right": 0, "border_left": 0, "separator_block_width": 0, "background": "#3b47aa"
  },{
    "full_text": "", "color": "#5f00af", "separator": false, "border_right": 0, "border_left": 0, "border_bottom": 4, "border_top": 0, "separator_block_width": 0, "background": "#3b47aa"
  },{
    "full_text": "  /: $free_root_disk |   Data: $free_data_disk ", "color": "#ffffff", "separator": false, "border_right": 0, "border_left": 0, "separator_block_width": 0, "background": "#5f00af"
  },{
    "full_text": "", "color": "#875fd7", "separator": false, "border_right": 0, "border_left": 0, "border_bottom": 4, "border_top": 0, "separator_block_width": 0, "background": "#5f00af"
  },{
    "full_text": "   $audio ", "color": "#ffffff", "background": "#875fd7", "separator": false, "border_right": 0, "border_left": 0, "separator_block_width": 0
  },{
    "full_text": "", "color": "#3b47aa", "separator": false, "border_right": 0, "border_left": 0, "border_bottom": 4, "border_top": 0, "separator_block_width": 0, "background": "#875fd7"
  },{
    "full_text": "   $bright ", "color": "#ffffff", "background": "#3b47aa", "separator": false, "border_right": 0, "border_left": 0, "separator_block_width": 0
  },{
    "full_text": "", "color": "#ea3d3d", "separator": false, "border_right": 0, "border_left": 0, "border_bottom": 4, "border_top": 0, "separator_block_width": 0, "background": "#3b47aa"
  },{
    "full_text": " $battery_icon  $battery ", "color": "#ffffff", "background": "#ea3d3d", "separator": false, "border_right": 0, "border_left": 0, "separator_block_width": 0
  },{
    "full_text": "", "color": "#2c7b39", "separator": false, "border_right": 0, "border_left": 0, "border_bottom": 4, "border_top": 0, "separator_block_width": 0, "background": "#ea3d3d"
  },{
    "full_text": "   $ip_addr ", "color": "#ffffff", "background": "#2c7b39", "separator": false, "border_right": 0, "border_left": 0, "separator_block_width": 0
  },{
    "full_text": "", "color": "#875fd7", "separator": false, "border_right": 0, "border_left": 0, "border_bottom": 4, "border_top": 0, "separator_block_width": 0, "background": "#2c7b39"
  },{
    "full_text": "   $today ", "color": "#ffffff", "background": "#875fd7", "separator": false, "border_right": 0, "border_left": 0, "separator_block_width": 0
  },{
    "full_text": "", "color": "#5f00af", "separator": false, "border_right": 0, "border_left": 0, "border_bottom": 4, "border_top": 0, "separator_block_width": 0, "background": "#875fd7"
  },{
    "full_text": "   $hour ", "color": "#ffffff", "background": "#5f00af", "separator": false, "border_right": 0, "border_left": 0, "separator_block_width": 0
  },{
    "full_text": "", "color": "#000000", "separator": false, "border_right": 0, "border_left": 0, "border_bottom": 4, "border_top": 0, "separator_block_width": 0, "background": "#5f00af"
  }]
EOF
)

  echo $JSON
  sleep 0.5

done

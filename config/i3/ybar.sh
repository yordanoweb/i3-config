#!/bin/sh

echo '{ "version": 1 }'

# Begin the endless array.
echo '['

# We send an empty first array of blocks to make the loop simpler:
echo '[]'

while :;
do
  hour=$(date "+%H:%M:%S")
  today=$(date "+%b/%d")

  ip_addr=$(nmcli | grep inet4 | awk '{print $2}' | grep -v "^127")
  if [ $(ip link show | grep --color=never -c "state UP") -eq 0 ];
  then
    ip_addr="offline"
  fi

  battery=$(upower -i /org/freedesktop/UPower/devices/battery_BAT1 | grep -o -E --color=never '[0-9]+%')
  audio=$(amixer get Master | grep -E -o --color=never '[0-9]+%' | head -n 1)
  bright=$(brightnessctl | grep Current | grep -o -E --color=never '[0-9]+%')
  used_mem=$(free -h | grep Mem | awk '{print $3}' | sed "s/i//")
  free_disk=$(df -h | egrep "\/$" | awk '{print $4}')
  cpu_load=$(top -b -d1 -n1|grep -i "Cpu(s)"|head -c21|cut -d ' ' -f3|cut -d '%' -f1 | sed "s/us,/0.0/")
  
  # comment this if you are not in a laptop and remove the corresponding JSON line 
  battery=$(upower -i $(upower -e | grep BAT) | grep --color=never -E "percentage" | awk '{print $2}')

  JSON=$(cat <<EOF
  ,[{
    "full_text": " 🇨🇺 ", "color": "#ffffff", "separator": false, "border_right": 0, "border_left": 0, "separator_block_width": 0
  },{
    "full_text": "", "color": "#ea3d3d", "separator": false, "border_right": 0, "border_left": 0, "border_bottom": 4, "border_top": 0, "separator_block_width": 0, "background": "#000000"
  },{
    "full_text": " CPU:   $cpu_load ", "color": "#ffffff", "separator": false, "border_right": 0, "border_left": 0, "separator_block_width": 0, "background": "#ea3d3d"
  },{
    "full_text": "", "color": "#3b47aa", "separator": false, "border_right": 0, "border_left": 0, "border_bottom": 4, "border_top": 0, "separator_block_width": 0, "background": "#ea3d3d"
  },{
    "full_text": " Mem: 📚 $used_mem ", "color": "#ffffff", "separator": false, "border_right": 0, "border_left": 0, "separator_block_width": 0, "background": "#3b47aa"
  },{
    "full_text": "", "color": "#5f00af", "separator": false, "border_right": 0, "border_left": 0, "border_bottom": 4, "border_top": 0, "separator_block_width": 0, "background": "#3b47aa"
  },{
    "full_text": " Disk: ⛁ $free_disk ", "color": "#ffffff", "separator": false, "border_right": 0, "border_left": 0, "separator_block_width": 0, "background": "#5f00af"
  },{
    "full_text": "", "color": "#875fd7", "separator": false, "border_right": 0, "border_left": 0, "border_bottom": 4, "border_top": 0, "separator_block_width": 0, "background": "#5f00af"
  },{
    "full_text": " 🔊️ $audio ", "color": "#ffffff", "background": "#875fd7", "separator": false, "border_right": 0, "border_left": 0, "separator_block_width": 0
  },{
    "full_text": "", "color": "#3b47aa", "separator": false, "border_right": 0, "border_left": 0, "border_bottom": 4, "border_top": 0, "separator_block_width": 0, "background": "#875fd7"
  },{
    "full_text": " ☀️  $bright ", "color": "#ffffff", "background": "#3b47aa", "separator": false, "border_right": 0, "border_left": 0, "separator_block_width": 0
  },{
    "full_text": "", "color": "#ea3d3d", "separator": false, "border_right": 0, "border_left": 0, "border_bottom": 4, "border_top": 0, "separator_block_width": 0, "background": "#3b47aa"
  },{
    "full_text": " 🔋️ $battery ", "color": "#ffffff", "background": "#ea3d3d", "separator": false, "border_right": 0, "border_left": 0, "separator_block_width": 0
  },{
    "full_text": "", "color": "#2c7b39", "separator": false, "border_right": 0, "border_left": 0, "border_bottom": 4, "border_top": 0, "separator_block_width": 0, "background": "#ea3d3d"
  },{
    "full_text": " 💻 $ip_addr ", "color": "#ffffff", "background": "#2c7b39", "separator": false, "border_right": 0, "border_left": 0, "separator_block_width": 0
  },{
    "full_text": "", "color": "#875fd7", "separator": false, "border_right": 0, "border_left": 0, "border_bottom": 4, "border_top": 0, "separator_block_width": 0, "background": "#2c7b39"
  },{
    "full_text": " 🗓️ $today ", "color": "#ffffff", "background": "#875fd7", "separator": false, "border_right": 0, "border_left": 0, "separator_block_width": 0
  },{
    "full_text": "", "color": "#5f00af", "separator": false, "border_right": 0, "border_left": 0, "border_bottom": 4, "border_top": 0, "separator_block_width": 0, "background": "#875fd7"
  },{
    "full_text": " 🕢 $hour ", "color": "#ffffff", "background": "#5f00af", "separator": false, "border_right": 0, "border_left": 0, "separator_block_width": 0
  },{
    "full_text": "", "color": "#000000", "separator": false, "border_right": 0, "border_left": 0, "border_bottom": 4, "border_top": 0, "separator_block_width": 0, "background": "#5f00af"
  }]
EOF
)

  echo $JSON
  sleep 0.2

done

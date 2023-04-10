#!/bin/bash

# Replace the URL below with your Discord webhook URL
WEBHOOK_URL="https://discord.com/api/webhooks/"

# Replace the URL below with the desired image URL
IMAGE_URL="https://i.imgur.com/XT82bq2.png"

# Collecting server information
used_ram=$(free -m | awk 'NR==2{printf "%.2f", $3*100/$2}')
disk_usage=$(df -h | awk '$NF=="/"{printf "%s", $5}')
server_response_time=$(ping -c 1 google.com | awk -F '/' 'END {print $5}')
running_processes=$(ps aux | wc -l)
uptime=$(uptime -p | cut -d " " -f 2-)
cpu_name=$(lscpu | grep "Model name" | awk -F: '{print $2}')
distro_full_name=$(lsb_release -s -d)
network_bandwidth_usage=$(ifstat -i enp6s18 1 1 | awk 'NR==3{print $1, $3}') # enp6s18 = network interface

# Creating JSON data for the Discord embed
timestamp=$(date +%s)
time_string=$(date --date="@${timestamp}" +%H:%M)
title="Linux Server Statistics ➜ <t:${timestamp}:f>"
json_data=$(cat <<EOF
{
  "embeds": [
    {
      "title": "$title",
      "color": 65407,
      "fields": [
        {
          "name": "💻・CPU Name",
          "value": "$cpu_name",
          "inline": true
        },
        {
          "name": "📂・Distribution",
          "value": "$distro_full_name",
          "inline": true
        },
        {
          "name": "📡・Uptime",
          "value": "$uptime",
          "inline": true
        },
        {
          "name": "🖧・Network Bandwidth Usage (RX/TX)",
          "value": "$network_bandwidth_usage GiB",
          "inline": true
        },
        {
          "name": "💽・Used RAM Memory",
          "value": "$used_ram%",
          "inline": true
        },
        {
          "name": "💾・Disk Usage",
          "value": "$disk_usage",
          "inline": true
        },
        {
          "name": "⏳・Server Response Time",
          "value": "$server_response_time ms",
          "inline": true
        },
        {
          "name": "📇・Running Processes",
          "value": "$running_processes",
          "inline": true
        }
      ],
      "thumbnail": {
        "url": "$IMAGE_URL"
      },
      "footer": {
        "text": "Copyright UltraLion#0404 © $(date +%Y)"
      }
    }
  ]
}

EOF
)

# Sending the embed to the Discord webhook
curl -X POST -H "Content-Type: application/json" -d "$json_data" $WEBHOOK_URL

# Exit the script
exit

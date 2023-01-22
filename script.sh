#!/bin/bash

# Récupération des données
mem_usage=$(free -m | awk 'NR==2{printf "%.2f%%\t", $3*100/$2 }')
disk_usage=$(df -h | awk '$NF=="/"{printf "%s\t", $5}')
net_usage=$(ifstat -i enp6s18 1 1 | awk 'NR==3{print $1, $3}') # enp6s18 = interface réseau
server_response=$(ping -c 1 google.com | awk -F '/' 'END {print $5}')
running_processes=$(ps aux | wc -l)
uptime=$(uptime -p)
cpu_name=$(lscpu | grep "Model name" | awk -F: '{print $2}')
distrib_name=$(lsb_release -s -d)

# Envoi des données à Discord en utilisant jq
data=$(jq -n \
--arg title "Statistiques du VPS" \
--arg color "10281099" \
--arg mem_usage "$mem_usage" \
--arg disk_usage "$disk_usage" \
--arg net_usage "$net_usage %" \
--arg server_response "$server_response ms" \
--arg running_processes "$running_processes" \
--arg uptime "$uptime" \
--arg cpu_name "$cpu_name" \
--arg distrib_name "$distrib_name" \
--arg thumbnail_url "https://i.imgur.com/XT82bq2.png" \ # Image du système d'exploitation
'{
  embeds: [
    {
      title: $title,
      color: $color,
      thumbnail: {
        url: $thumbnail_url
      },
      fields: [
        {
          name: "Utilisation de la mémoire",
          value: $mem_usage,
          inline: true
        },
        {
          name: "Utilisation du disque",
          value: $disk_usage,
          inline: true
        },
        {
          name: "Utilisation de la bande passante du réseau",
          value: $net_usage,
          inline: true
        },
        {
          name: "Temps de réponse du serveur",
          value: $server_response,
          inline: true
        },
        {
            name: "Nombre de processus en cours",
            value: $running_processes,
            inline: true
        },
        {
            name: "Uptime du serveur",
            value: $uptime,
            inline: true
        },
        {
            name: "Nom du CPU",
            value: $cpu_name,
            inline: true
        },
        {
            name: "Nom complet de la distribution",
            value: $distrib_name,
            inline: true
        }
    ]
  }
]
    }')
curl -H "Content-Type: application/json" -X POST -d "$data" https://discord.com/api/webhooks/ # Mettre votre webhook discord ici

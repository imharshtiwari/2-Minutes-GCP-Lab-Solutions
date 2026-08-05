# Monitoring in Google Cloud: Challenge Lab || [ARC115](https://www.skills.google/catalog_lab/6446) ||

## 🔑 Solution [here](https://youtu.be/L3Q8sE0dkUQ)

### ⚙️ Execute the Following Commands in Cloud Shell

```
curl -LO raw.githubusercontent.com/imharshtiwari/2-Minutes-GCP-Lab-Solutions/main/Monitoring%20in%20Google%20Cloud%3A%20Challenge%20Lab/sparkwavedev.sh

sudo chmod +x sparkwavedev.sh

./sparkwavedev.sh
```

* Go to `Create log-based metric` from [here](https://console.cloud.google.com/logs/metrics/edit?)

1. For 

2. Paste The Following in vm (cloud shell)
```
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install
```

3. Paste The Following in `Regular Expression` field:
```
# Configures Ops Agent to collect telemetry from the app and restart Ops Agent.

set -e

# Create a back up of the existing file so existing configurations are not lost.
sudo cp /etc/google-cloud-ops-agent/config.yaml /etc/google-cloud-ops-agent/config.yaml.bak

# Configure the Ops Agent.
sudo tee /etc/google-cloud-ops-agent/config.yaml > /dev/null << EOF
metrics:
  receivers:
    apache:
      type: apache
  service:
    pipelines:
      apache:
        receivers:
          - apache
logging:
  receivers:
    apache_access:
      type: apache_access
    apache_error:
      type: apache_error
  service:
    pipelines:
      apache:
        receivers:
          - apache_access
          - apache_error
EOF

sudo service google-cloud-ops-agent restart
sleep 60
```

# 🎉 🐻‍❄️ྀིྀི 🐻‍❄️ྀིྀི Yeeeeaaahhh! You Did It! 🎉


Keep pushing forward—every small step takes you closer to your dream.! 💻🚀

You've successfully completed the lab. **Miles to go!** 🚀


### 💬 Stay Connected with Our Community!

👉 Join the conversation and never miss an update:

💚 [𝗪𝗵𝗮𝘁𝘀𝗔𝗽𝗽 𝗖𝗼𝗺𝗺𝘂𝗻𝗶𝘁𝘆](https://chat.whatsapp.com/)
📢 [Telegram Channel](https://t.me/sparkwave.01)
👥 [Discussion Group](https://t.me/sparkwave.01chats)

# ✨[SPARKWAVE DEV](https://www.youtube.com/@sparkwavedev)

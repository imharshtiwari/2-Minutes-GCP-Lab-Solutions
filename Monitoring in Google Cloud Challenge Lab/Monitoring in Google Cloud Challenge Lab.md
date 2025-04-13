# Monitoring in Google Cloud: Challenge Lab || [ARC115](https://www.cloudskillsboost.google/focuses/63855?parent=catalog) ||

## 🔑 Solution [here](https://www.youtube.com/@sparkwave.01)

### Run the following Commands in CloudShell

```
curl -LO raw.githubusercontent.com/imharshtiwari/2-Minutes-GCP-Lab-Solutions/main/Monitoring%20in%20Google%20Cloud%20Challenge%20Lab/arc115.sh

sudo chmod +x arc115.sh

./arc115.sh
```

### NOW FOLLOW [VIDEO'S](https://www.youtube.com/@sparkwave.01) INSTRUCTIONS.

* Go to `Create Uptime Check` from [here](https://console.cloud.google.com/monitoring/uptime/create?)

1. For Title: enter `sparkwave`

* Go to `Dashboards` from [here](https://console.cloud.google.com/monitoring/dashboards?)

1. Add the first line chart that has a Resource metric filter, `CPU load (1m)`, for the VM.

2. Add a second line chart that has a Resource metric filter, `Requests`, for Apache Web Server.

* Go to `Create log-based metric` from [here](https://console.cloud.google.com/logs/metrics/edit?)

1. For Log-based metric name: enter `sparkwave`

2. Paste The Following in `Build filter` & Replace PROJECT_ID
```
resource.type="gce_instance"
logName="projects/PROJECT_ID/logs/apache-access"
textPayload:"200"
```

3. Paste The Following in `Regular Expression` field:
```
execution took (\d+)
```

### 🐼 Congratulations 🎉 for completing the Lab !

##### *You Have Successfully Demonstrated Your Skills And Determination.*

#### *Well done!*

#### Don't Forget to Join the [Telegram Channel](https://t.me/sparkwave.01) & [Discussion group](https://t.me/sparkwave.01chats)

# [SPARKWAVE](https://www.youtube.com/@sparkwave.01)

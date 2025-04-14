# Develop your Google Cloud Network: Challenge Lab || [GSP321](https://www.cloudskillsboost.google/focuses/10603?parent=catalog) ||

## 🔑 Solution [here](https://youtu.be/f0zlgCJw8Yg)

### Run the following Commands in CloudShell

```
export ZONE=
```
```
curl -LO raw.githubusercontent.com/imharshtiwari/2-Minutes-GCP-Lab-Solutions/main/Develop%20your%20Google%20Cloud%20Network%20Challenge%20Lab/gsp321.sh

sudo chmod +x gsp321.sh

./gsp321.sh
```
### Task 8. Enable monitoring

1. Go to [Services and Ingress](https://console.cloud.google.com/kubernetes/discovery)
2. Copy `endpoint's`(wordpress) `IP address`.
3. Then go to -> [Uptime Checks](https://console.cloud.google.com/monitoring/uptime) -> `+ CREATE UPTIME CHECK`. 
4. Fill in the details as provided below : 

* Hostname : `endpoint's IP address` (without http and port number)

* Path : `/`

* Title: `Wordpress Uptime`

5. Leave everything as default. Click `Next` -> `Next` -> `Create`

### 🐼 Congratulations 🎉 for completing the Challenge Lab !

##### *You Have Successfully Demonstrated Your Skills And Determination.*

#### *Well done!*

#### Don't Forget to Join the [Telegram Channel](https://t.me/sparkwave.01) & [Discussion group](https://t.me/sparkwave.01chats)

# [SPARKWAVE](https://www.youtube.com/@sparkwave.01)

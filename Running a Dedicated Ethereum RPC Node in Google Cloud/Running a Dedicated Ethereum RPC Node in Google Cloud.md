# Running a Dedicated Ethereum RPC Node in Google Cloud || [GSP1116](https://www.cloudskillsboost.google/focuses/61475?parent=catalog) ||

## 💡 **🔑 Solution [here](https://youtu.be/wjbPBLcp1ag)** 

####  Run the Initial Script 

```
curl -LO raw.githubusercontent.com/imharshtiwari/2-Minutes-GCP-Lab-Solutions/refs/heads/main/Running%20a%20Dedicated%20Ethereum%20RPC%20Node%20in%20Google%20Cloud/gsp1116-1.sh

sudo chmod +x gsp1116-1.sh

./gsp1116-1.sh
```

### 💡 After scoring `90/100` in the lab, run the below commands and follow the video instructions

```
export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

gcloud compute instances stop eth-mainnet-rpc-node --project=$DEVSHELL_PROJECT_ID --zone=$ZONE && gcloud compute instances set-machine-type eth-mainnet-rpc-node --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --machine-type=n2-standard-4 && gcloud compute instances start eth-mainnet-rpc-node --project=$DEVSHELL_PROJECT_ID --zone=$ZONE
```

### 🎉 🐻‍❄️ྀིྀི **Congratulations on Completing the Lab!**  

##### *Your expertise and effort are shining through—keep up the amazing work!*  

#### 🔗 **Stay Connected for More Labs and Resources:**  
- 🌐 [Telegram Channel](https://t.me/sparkwave.01)  
- 🤝 [Discussion Group](https://t.me/sparkwave.01chats)

# [SPARKWAVE](https://www.youtube.com/@sparkwave.01)

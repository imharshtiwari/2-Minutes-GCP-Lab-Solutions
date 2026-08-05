# Configuring IAM Permissions with gcloud || [GSP647](https://www.skills.google/catalog_lab/2058) ||

## 🔑 Solution [here](https://www.youtube.com/@sparkwavedev)

> [!IMPORTANT] 
> This is an independent, community-made walkthrough created to help you understand why each step works. Attempt the challenge yourself first. This guide is provided for educational purposes and is not intended to replace the official lab instructions or your own hands-on learning. It is not affiliated with or endorsed by Google Cloud or Google Cloud Skills Boost. Always follow the official Google Cloud and Qwiklabs terms of service, lab instructions, and usage policies.


## ⚙️ Exectue this in Cloud Shell

```
gcloud compute ssh centos-clean \
    --zone=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])") \
    --quiet
```
```
curl -LO raw.githubusercontent.com/imharshtiwari/2-Minutes-GCP-Lab-Solutions/Configuring%20IAM%20Permissions%20with%20gcloud/sparkwavedev.sh
sudo chmod +x sparkwavedev.sh
./sparkwavedev.sh

```



### 🐼 Congratulations 🎉 for completing the Challenge Lab !

##### *You Have Successfully Demonstrated Your Skills And Determination.*

#### *Well done!*

#### Don't Forget to Join the [Telegram Channel](https://t.me/sparkwave.01) & [Discussion group](https://t.me/sparkwave.01chats)

# ✨✨[SPARKWAVE DEV](https://www.youtube.com/@sparkwavedev) ✨✨

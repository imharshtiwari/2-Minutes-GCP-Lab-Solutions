# Analyzing Billing Data with BigQuery || [GSP621](https://www.cloudskillsboost.google/focuses/7114?parent=catalog) ||

## 🔑 Solution [here](https://www.youtube.com/@sparkwave.01)

### Run the following Commands in CloudShell

```
curl -LO raw.githubusercontent.com/imharshtiwari/2-Minutes-GCP-Lab-Solutions/main/Analyzing%20Billing%20Data%20with%20BigQuery/gsp621.sh

sudo chmod +x gsp621.sh

./gsp621.sh
```

* Go to **BigQuery** from [here](https://console.cloud.google.com/bigquery?)

```
SELECT CONCAT(service.description, ' : ',sku.description) as Line_Item FROM `billing_dataset.enterprise_billing` GROUP BY 1
```
```
SELECT CONCAT(service.description, ' : ',sku.description) as Line_Item, Count(*) as NUM FROM `billing_dataset.enterprise_billing` GROUP BY CONCAT(service.description, ' : ',sku.description)
```

### 🐼 Congratulations 🎉 for completing the Lab !

##### *You Have Successfully Demonstrated Your Skills And Determination.*

#### *Well done!*

#### Don't Forget to Join the [Telegram Channel](https://t.me/sparkwave.01) & [Discussion group](https://t.me/sparkwave.01chats)

# [SPARKWAVE](https://www.youtube.com/@sparkwave.01)

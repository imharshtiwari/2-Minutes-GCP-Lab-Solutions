# Assessing Data Quality with Dataplex || [GSP1158](https://www.cloudskillsboost.google/focuses/67211?parent=catalog) ||

## 🔑 Solution [here](https://www.youtube.com/@sparkwave.01)

### Run the following Commands in CloudShell

```
export REGION=
```
```
curl -LO raw.githubusercontent.com/imharshtiwari/2-Minutes-GCP-Lab-Solutions/main/Assessing%20Data%20Quality%20with%20Dataplex/gsp1158.sh

sudo chmod +x gsp1158.sh

./gsp1158.sh
```

* Go to `BigQuery` from [here](https://console.cloud.google.com/bigquery?)

* In the SQL Editor, click on `Compose a new query`. Paste the following query, and then click `Run`: ( REPLACE PROJECT_ID WITH YOUR PROJECT )

```
  SELECT * FROM `PROJECT_ID.customers.contact_info`
  ORDER BY id
  LIMIT 50
```

* Go to `Create task` from [here](https://console.cloud.google.com/dataplex/process/create-task/data-quality?)


### 🐼 Congratulations 🎉 for Completing the Lab !

##### *You Have Successfully Demonstrated Your Skills And Determination.*

#### *Well done!*

#### Don't Forget to Join the [Telegram Channel](https://t.me/sparkwave.01) & [Discussion group](https://t.me/sparkwave.01chats)

# [SPARKWAVE](https://www.youtube.com/@sparkwave.01)

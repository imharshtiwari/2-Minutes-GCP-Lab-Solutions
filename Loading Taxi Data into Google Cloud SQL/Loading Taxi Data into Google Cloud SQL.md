# [Loading Taxi Data into Google Cloud SQL](https://www.cloudskillsboost.google/games/5521/labs/35625)

## 🔑 Solution [here](https://www.youtube.com/@sparkwave.01)

### Run the following Commands in CloudShell

```
curl -LO raw.githubusercontent.com/imharshtiwari/2-Minutes-GCP-Lab-Solutions/refs/heads/main/Loading%20Taxi%20Data%20into%20Google%20Cloud%20SQL/shell.sh

sudo chmod +x shell.sh

./shell.sh
```

* When prompted for the password type or paste the following and press Enter.

```
Passw0rd
```

* Now paste the following content into the command line to create the schema for the trips table:

```
create database if not exists bts;
use bts;

drop table if exists trips;

create table trips (
  vendor_id VARCHAR(16),    
  pickup_datetime DATETIME,
  dropoff_datetime DATETIME,
  passenger_count INT,
  trip_distance FLOAT,
  rate_code VARCHAR(16),
  store_and_fwd_flag VARCHAR(16),
  payment_type VARCHAR(16),
  fare_amount FLOAT,
  extra FLOAT,
  mta_tax FLOAT,
  tip_amount FLOAT,
  tolls_amount FLOAT,
  imp_surcharge FLOAT,
  total_amount FLOAT,
  pickup_location_id VARCHAR(16),
  dropoff_location_id VARCHAR(16)
);
```

### 🐼 Congratulations 🎉 for completing the Lab !

##### *You Have Successfully Demonstrated Your Skills And Determination.*

#### *Well done!*

#### Don't Forget to Join the [Telegram Channel](https://t.me/sparkwave.01) & [Discussion group](https://t.me/sparkwave.01chats)

# [SPARKWAVE](https://www.youtube.com/@sparkwave.01)

# Analytics as a Service for Data Sharing Partners || [GSP1042](https://www.cloudskillsboost.google/games/6151/labs/39041) ||

## 🔑 Solution [here](https://www.youtube.com/@sparkwave.01)


### 1. ☁️ Initialize Views in Cloud Shell


```bash
curl -LO https://raw.githubusercontent.com/imharshtiwari/2-Minutes-GCP-Lab-Solutions/main/Analytics%20as%20a%20Service%20for%20Data%20Sharing%20Partners/gsp1042.sh
sudo chmod +x gsp1042.sh
./gsp1042.sh
```

### 2. 🔑 Store Your Main Project ID

After running the commands above, **copy the `PROJECT ID`** displayed in the last line of your Cloud Shell output (e.g., `PROJECT ID=qwiklabs-gcp-xxxx`). You'll need this ID for subsequent steps.

### 3. 👁️ BigQuery: Authorize Views

Follow these steps in the Google Cloud Console for your Main Lab Project:

1.  Navigate to **☰ Menu > BigQuery**.
2.  In the Explorer panel, find your project, then expand `demo_dataset`.
3.  Click on **Sharing**, then select **Authorize Views**.
4.  In the "Authorize views" panel:
  *   Select `authorized_view_a` from the list.
  *   Click **ADD AUTHORIZATION**.
5.  Repeat for the other view:
  *   Select `authorized_view_b` from the list.
  *   Click **ADD AUTHORIZATION**.
6.  Click **CLOSE**.

### 4. 🤝 Share Authorized Views

Now, share these views with the user accounts specified in the lab:

#### For `authorized_view_a`:
1.  In BigQuery, under `demo_dataset`, find `authorized_view_a`.
2.  Click the three dots (⋮) next to it (or select it) and choose **SHARE**.
3.  In the "Share `authorized_view_a`" panel, click **ADD PRINCIPAL**.
4.  In the "New principals" field, paste **Username A** (from the lab instructions).
5.  Assign the Role: `BigQuery Data Viewer`.
6.  Click **SAVE**.

#### For `authorized_view_b`:
1.  Similarly, find `authorized_view_b` under `demo_dataset`.
2.  Click the three dots (⋮) next to it (or select it) and choose **SHARE**.
3.  Click **ADD PRINCIPAL**.
4.  Paste **Username B** (from the lab instructions).
5.  Assign the Role: `BigQuery Data Viewer`.
6.  Click **SAVE**.

### 5. 🚪 Close Incognito Window (If Open)

If you have any incognito windows open from previous lab activity, close them.

---

## 🚀 Project A: Configuration

### 1. 💻 Access Project A

*   Log in to the Google Cloud Console using the credentials provided for **Project A**.
*   Open a new **Cloud Shell** session within Project A.

### 2. 🛠️ Create View in Project A

In the Project A Cloud Shell, first set an environment variable for your **Main Lab Project ID** (the one you copied in step 1.2):

```bash
curl -LO https://raw.githubusercontent.com/imharshtiwari/2-Minutes-GCP-Lab-Solutions/main/Analytics%20as%20a%20Service%20for%20Data%20Sharing%20Partners/gsp1.sh
sudo chmod +x gsp1.sh
./gsp1.sh
```

### 3. 📊 Connect Looker Studio (for Project A)

1.  Open a **new Incognito window**.
2.  Navigate to [Looker Studio](https://lookerstudio.google.com/).
3.  Click on **Blank Report**.
4.  If prompted for account setup (country/company):
  *   Country: Select **India** (or your preferred country).
  *   Company: Enter **SparkWave** (or any name).
  *   Agree to the terms and click **Continue**. Answer any subsequent prompts (e.g., "Yes to all" for email preferences).
5.  In the "Add data to report" window, select the **BigQuery** connector.
6.  Click **AUTHORIZE** if prompted, and allow access.
7.  Under "Project", select **Project A's ID**.
8.  Under "Dataset", select `customer_a_dataset`.
9.  Under "Table", select `customer_a_table`.
10. Click **ADD** (bottom right), then confirm by clicking **ADD TO REPORT**.

### 4. 🚪 Close Incognito Window

Close the Incognito window used for Project A's Looker Studio.

---

## 🚀 Project B: Configuration

### 1. 💻 Access Project B

*   Log in to the Google Cloud Console using the credentials provided for **Project B**.
*   Open a new **Cloud Shell** session within Project B.

### 2. 🛠️ Create View in Project B

In the Project B Cloud Shell, set the environment variable for your **Main Lab Project ID** again:

```bash
curl -LO https://raw.githubusercontent.com/imharshtiwari/2-Minutes-GCP-Lab-Solutions/main/Analytics%20as%20a%20Service%20for%20Data%20Sharing%20Partners/gsp2.sh
sudo chmod +x gsp2.sh
./gsp2.sh
```

### 3. 📊 Connect Looker Studio (for Project B)

1.  Open a **new Incognito window**.
2.  Navigate to [Looker Studio](https://lookerstudio.google.com/).
3.  Click on **Blank Report**.
4.  (You might not be prompted for account setup again if you recently did it for Project A). If prompted:
  *   Country: Select **India** (or your preferred country).
  *   Company: Enter **SparkWave** (or any name).
  *   Agree and **Continue**.
5.  Select the **BigQuery** connector.
6.  Click **AUTHORIZE** if needed.
7.  Under "Project", select **Project B's ID**.
8.  Under "Dataset", select `customer_b_dataset`.
9.  Under "Table", select `customer_b_table`.
10. Click **ADD**, then **ADD TO REPORT**.

---

### 🐼 Congratulations 🎉 for completing the Lab !

##### *You Have Successfully Demonstrated Your Skills And Determination.*

#### *Well done!*

#### Don't Forget to Join the [Telegram Channel](https://t.me/sparkwave.01) & [Discussion group](https://t.me/sparkwave.01chats)

# [SPARKWAVE](https://www.youtube.com/@sparkwave.01)

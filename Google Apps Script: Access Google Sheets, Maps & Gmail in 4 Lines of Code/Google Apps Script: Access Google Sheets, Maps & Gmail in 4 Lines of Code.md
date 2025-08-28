# Google Apps Script: Access Google Sheets, Maps & Gmail in 4 Lines of Code || [GSP235](https://www.cloudskillsboost.google/games/6435/labs/40491) ||

## 💡 **🔑 Solution [here](ht)**

### 🚀 **Execute the following commands in Cloud Shell:**  

- 📌 Click into the first cell in the upper left-hand corner (A1). It should be in column A and row 1:

```
28 Snowbird Lane, Wasilla,ak, 99683  United States
```

- From the top menu bar, select **Extensions** > **Apps Script**

- **Update Code.gs with Custom Script Logic**
```
function sendMap() {
    var sheet = SpreadsheetApp.getActiveSheet();
    var address = sheet.getRange("A1").getValue();
    var map = Maps.newStaticMap().addMarker(address);
    GmailApp.sendEmail("<YOUR_EMAIL>", "Map", 'See below.', {attachments:[map]});
}
```




### 🎉 🐻‍❄️ྀིྀི **Congratulations on completing the lab!**  

##### *Your hard work and determination are commendable!*  

#### *Keep striving for success—new heights await you! 🚀*

#### **Stay connected and join us:** [Telegram Channel](https://t.me/sparkwave.01) & [Discussion Group](https://t.me/sparkwave.01chats) 

# [SPARKWAVE](https://www.youtube.com/@sparkwave.01)

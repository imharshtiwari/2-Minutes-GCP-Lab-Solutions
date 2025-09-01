# Create a Machine Image for Instance Replication || [Trivia Lab](https://www.cloudskillsboost.google/games/6461/labs/40611) ||

## 💡 **🔑 Solution [here](https://youtu.be/ttgZKSXVdNM)**

### 🚀 **Execute the following commands in Shell:**

* Replace `[enter region]` with region given


```
gcloud compute instance-groups managed create dev-instance-group --template=dev-instance-template --size=1 --region=[enter region] && gcloud compute instance-groups managed set-autoscaling dev-instance-group --region=[enter region] --min-num-replicas=1 --max-num-replicas=3 --target-cpu-utilization=0.6 --mode=on


```



### 🎉 🐻‍❄️ྀིྀི **Congratulations on completing the lab!**  

##### *Your hard work and determination are commendable!*  

#### *Keep striving for success—new heights await you! 🚀*

#### **Stay connected and join us:** [Telegram Channel](https://t.me/sparkwave.01) & [Discussion Group](https://t.me/sparkwave.01chats) 

# [SPARKWAVE](https://www.youtube.com/@sparkwave.01)

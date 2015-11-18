# How to use the two level limit #

I use the two level limit as indicator for principal line and backup line.

# In practis #

I use the two level as threshold for two limit that I know. My production line have normally a RTT of 20ms. If the line goes down the backup line have 60ms or more of RTT.

Using this two value I can recive a grafical alert if the line switch from production to backup.

```
./cping.sh 99999 192.168.185.21 20 60
```

![http://cping.googlecode.com/files/cping_2level.png](http://cping.googlecode.com/files/cping_2level.png)
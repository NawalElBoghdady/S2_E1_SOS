library("RSQLite")
library("ez")


################################################################
#
# 1. PLOT Speech-on-Speech performance
#
################################################################

db = dbConnect(dbDriver("SQLite"), "/Users/nawalelboghdady/Desktop/Experiments/S2_E1_SOS/S2_E1_SOS/results/SOS_db.sqlite",loadable.extensions = TRUE)
sql = sprintf("SELECT *
        FROM sos")
res = dbSendQuery(db, sql)
data = fetch(res, n=-1)


sql = sprintf("SELECT subject, vocoder, TMR, nwords_correct_offline*100.0/nwords_total AS percent_correct
              FROM sos
              GROUP BY vocoder,TMR")
res = dbSendQuery(db, sql)
data2 = fetch(res, n=-1)

sql = sprintf("SELECT subject, vocoder, TMR, nwords_correct_offline*100.0/nwords_total AS percent_correct
              FROM sos")
res = dbSendQuery(db, sql)
data3 = fetch(res, n=-1)

out = data.frame(vocoder = 0, TMR = 0, perf = 0)
row = 1

for (i in unique(data3$vocoder))
{
        for (j in unique(data3$TMR))
        {
                for (k in unique(data3$subject))
                {
                        out[row,"vocoder"] = i
                        out[row,"TMR"] = j
                        out[row,"perf"] = mean(data3[(data3$subject == k) &
                                (data3$vocoder == i) & (data3$TMR == j),
                                "percent_correct"], na.rm=TRUE)
#                         out[row,"stdev_perf"] = sd(data3[(data3$subject == k) &
#                                 (data3$vocoder == i) & (data3$TMR == j),
#                                 "percent_correct"], na.rm=TRUE)
                        row = row+1   
                }
                 
        }
                
        
        
}

out <- na.omit(out)

out2 = data.frame(vocoder = 0, TMR = 0, mean_perf = 0, stdev_perf = 0)
row = 1

for (i in unique(out$vocoder))
{
        for (j in unique(out$TMR))
        {
                out2[row,"vocoder"] = i
                out2[row,"TMR"] = j
                out2[row,"mean_perf"] = mean(out[(out$vocoder == i) & (out$TMR == j),
                                     "perf"], na.rm=TRUE)
                out2[row,"stdev_perf"] = sd(out[(out$vocoder == i) & (out$TMR == j),
                        "perf"], na.rm=TRUE)
                row = row+1   
                
        }
        
        
        
}

out2 <- na.omit(out2)

colours = c("red","blue","black")
ylims = c(0,100)

for (i in unique(out2$vocoder))
{
        avg = out2$mean_perf[out2$vocoder == i]
        sdev = out2$stdev_perf[out2$vocoder == i]
        x = out2$TMR[out2$vocoder == i]
        plot(x,avg, pch = "o", 
             xlab = "TMR", ylab = "Precentage correct responses",
             main = "Speech-on-Speech performance", col = colours[i+1], type = "p",
             ylim = ylims)
        arrows(x, avg-sdev, x, avg+sdev, length=0.05, angle=90, code=3)
        #axis(side = 1, at = x, labels = voc_ticks)
        
}





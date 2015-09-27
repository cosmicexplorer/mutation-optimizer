tbl <- read.csv('reductions.csv')

png(filename = "graph-reductions.png")

par(xpd=TRUE, mar=c(1, 5, 4, 10))
barplot(tbl$reduction,
        cex.main = .8,
        legend.text = tbl$name,
        args.legend = list(x = "topright", bty = "n", inset = c(-.52, 0),
            cex = .8, title = "Type of Site Optimized Against"),
        col = sample(rainbow(length(tbl$reduction))),
        main = "Reduction In Mutation Hotspots Counts After Specific Optimization",
        ylab = "% Reduction in Hotspot Sites")

dev.off()

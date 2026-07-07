library(stylo)
data("galbraith")
galbraith
rownames(galbraith)
colnames(galbraith)
#if not using the corpus in the system folders, code is like this
#GUI will open automatically
stylo(frequencies = galbraith)
#culling rate = 100, MFW = 1000, but only 826 MFW will be used because they are the words that co-occur in all the books
#using frequencies is because all the files have been converted into frequency list?
#a new way of setting working directory (Files -> Set as working directory)

#combine features and freqs together to create freq table
stylo()
stylo_results = stylo(analyzed.features = "c", ngram.sizes = 2, gui = FALSE)
features1 = stylo_results$features[1:500]
freqs1 = stylo_results$table.with.all.freqs[,1:500]

stylo_results = stylo(analyzed.features = "w", ngram.sizes = 2, gui = FALSE)
features2 = stylo_results$features[1:500]
freqs2 = stylo_results$table.with.all.freqs[,1:500]

features.combined = c(features1, features2)
freqs.combined = cbind(freqs1, freqs2)
#get the freq table

stylo_results = stylo(frequencies = freqs.combined, features = features.combined, mfw.min = 1000, mfw.max = 1000, gui = FALSE, linkage = "ward")
#linkage = complete/single/ward
stylo_results$features.actually.used
#the most frequently used is stylo() function


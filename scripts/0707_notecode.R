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
stylo()

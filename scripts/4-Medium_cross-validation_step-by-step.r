###################################################################################################################################################################################################################
# And let's try to make the cross-validation step by step 
# and see how well classify() can manage in telling the author
# of every text in our corpus

library(stylo)

#######
# Option 1: leave-one-out cross validation
# Needed: only one corpus directory
#small dataset otherwise gonna run a long time

# loading the corpus
texts = load.corpus.and.parse(files = "all", corpus.dir = "corpus", features = "w", ngram.size = 1)

# getting a genral frequency list
freq.list = make.frequency.list(texts, head = 1000)
# preparing the document-term matrix:
word.frequencies = make.table.of.frequencies(corpus = texts, features = freq.list)

# now the main procedure takes place:
results  = crossv(training.set = word.frequencies, cv.mode = "leaveoneout",
                  classification.method = "delta")

# see what's inside:
summary(results)

# e.g., check which texts were misattributed to which authors
results$misclassified

# or get the number of correct classifications:
results$y
sum(results$y, na.rm = TRUE)/27

# or see how Emily Bronte's books were classified:
results$expected
results$expected == 'EBronte'
results$predicted[results$expected == 'EBronte']


######
# Option 2: K-fold cross validation
# Needed: two corpora (primary_set, secondary_set), which allow crossv()
#         to compute proportions of classes for stratification 

# loading the corpus
texts = load.corpus.and.parse(files = "all", corpus.dir = "corpus")
# Let's look what texts we have there
names(texts)

# Now, separate the corpus into two parts by providing numerical indices
#proportion
# telling R where these books are on the list:
primary_index = c(2,4,5,7,8,10,11,12,14,15,17,19,21,23,24,26,27)
secondary_index = setdiff(1:27,primary_index) # = all the other books

primary_texts = texts[primary_index] # select the books from the 'texts' variable
secondary_texts = texts[secondary_index]

## Or, alternatively, you can load corpora from two separate directories
# primary_set <- load.corpus.and.parse(corpus.dir="primary_TAG",
#                                      features="w", ngram.size = 2)
# secondary_set <- load.corpus.and.parse(corpus.dir="secondary_TAG",
#                                        features="w", ngram.size = 2)

# getting the training frequency list
primary_freq.list = make.frequency.list(primary_texts, head = 1000)
second_freq.list = make.frequency.list(secondary_texts) # we take all words from 2nd set
freq.list = intersect(primary_freq.list,second_freq.list)
# Above we take only words that overlap between 1st and 2nd set.
# We need that, because crossv() later on will need frequency tables that have the same number of columns

# preparing the document-term matrix:
primary_freqs = make.table.of.frequencies(corpus = primary_texts, 
                                          features = freq.list)
secondary_freqs = make.table.of.frequencies(corpus = secondary_texts, 
                                            features = freq.list)


results  = crossv(training.set = primary_freqs,
                  test.set = secondary_freqs,
                  cv.mode = "stratified", cv.folds = 10,
                  classification.method = "svm")
# a bug with cosine method (?)
#Choose one of the following: "delta", "svm", "knn", "nsc", "naivebayes".

summary(results)
performance.measures(results)
#k-fold has more writers to be misclassified than the leave one out method? - Leaveoneout has more training data. But the classification results should be the same.
#is it possible to identify which books are misclassified -> by results$misclassified  [[1]] means the results of the first fold

######
# When looking at the frequency list you might find some strange features.
# For instance, look at word number 937
colnames(primary_freqs)[937]
# What is that doing here?
# If you didn't know where it is, and you wanted to look for it,
# you'd look at the frequency table column names for appearance of word 'c' 
which(colnames(primary_freqs) == 'c')

# You might look at in which books it appears
primary_freqs[,'c'] > 0

# You might want to include only some features
# - by choosing two ranges with a gap
primary_freqs[,c(1:10, 20:30)]
# - or by deleting a given feature
primary_freqs[,c(-3)]
# And then check if the number of columns indeed changed 
dim(primary_freqs)
dim(primary_freqs[,c(-3)])

# Finally we can look for it in the chosen text
which(texts$ABronte_Agnes == 'c')
# this gave you the position in terms of the number of token
# If you'd like some context, get a couple of words before and after
texts$ABronte_Agnes[(18310-5):(18310+5)]

# And if you look for it in the non-processed txt files,
# you'll see that it is "&c." = "etc." tokenised as 'c'
#some contaminations may be identified
#it may happen during digitisztion: OCR, HTR(handwritten text recognition), gold standard(human expert transcription)
#OCR: mind your corpus (Maciej)
#HTR: Jander, M. (2016) Handwritten Text Recognition - Transkribus: A User Report
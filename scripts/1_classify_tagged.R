library(stylo)
###################
# Corpus preparation:
# 1. Download and extract https://github.com/perechen/ESU_24_comptext/tree/main/data/small_collection_POS.zip
# in your working directory.
# 2. Copy the contents of the corpus directory to 'primary_set' folder (default directory that classify() looks for). 
# 3. Make another folder 'secondary_set'. From 'primary_set', move there 1 book of each author.
# 4. Run classify()
###################
#res = classify()

#classify based on a batch of features in loop
#This can be changed to algorithms, etc. 
#固定 MFW = 1000，分别用 word 1-gram 到 5-gram 做分类实验，保存每次预测结果、真实结果和性能指标，并最后输出每个 n-gram 设置下的 average F-score
#result.tab = list()
#predict.tab = list()
#expect.tab = list()
#a balanced dataset by random sampling
perf.tab = list()
sizes = c(1000, 5000, 10000)
#for (ngram in 1:5){
for (ssize in 1:3){
  res = classify(gui = FALSE,
                analyzed.features = 'w', 
                ngram.size = 3,
                mfw.min = 1000, 
                mfw.max = 1000,
                sampling = "random.sampling",
                sample.size = sizes[ssize],
                number.of.samples = 10,
                training.corpus.dir = "primary_set",
                test.corpus.dir = "secondary_set",
                use.existing.freq.tables = FALSE,
                use.existing.wordlist = FALSE)
#by default classification is burrow's delta which is the fastest one. Maybe SVM has a better result. 
 # result.tab[[ngram]] = res
  #predict.tab[[ngram]] = res$predicted
  #expect.tab[[ngram]] = res$expected
  perf.tab[[ssize]] = performance.measures(res$predicted, res$expected)
}
sapply(perf.tab, `[[`, "avg.f")
plot(c(1000,5000,10000), sapply(perf.tab, `[[`, "avg.f"))
summary(res)
# A list predicted classes of books in the 'secondary_set' 
res$predicted
# A list real classes (labels provided) of books in the 'secondary_set' 
res$expected
# A list of books in the 'secondary_set' which were misclassified and how they were missclassified
res$misclassified
#a way to find misclassified writers
#select = res$expected != res$predicted
#res$expected[select]

# Confusion matrix (which classes ended up being classified into/predicted as which)
res$confusion_matrix
# If it's not there, there's an easy way to make it in R:
View(table(res$expected, res$predicted))

# Other performance metric apart from accuracy (precision, recall, F1 score)
performance.measures(res$predicted,res$expected)


# If you named the directories otherwise, use optional arguments to point to them
res = classify(training.corpus.dir = "primary_TAG",
               test.corpus.dir = "secondary_TAG")

# If you choose NSC method you need to change the parameter show.features (otherwise the method won't work)
res = classify(training.corpus.dir = "primary_TAG",
               test.corpus.dir = "secondary_TAG",
               show.features = TRUE)
# NSC tries to minimise the number of features used for classification.
# These features can be found below (zero value means a feature not used by NSC)
View(res$distinctive.features)

#in the classification task in stylo, no validation set
#how stable the result can be when the training data is changed (bias-variance tradeoff, underfitting and overfitting)
#train set and test set don't have overlapping writers
#run cross classification to test the model's result
#q: how can we convert the data into pos in R  -> UDpipe(?)  treetagger  stanford tagger
#burrow's delta is nearest neighbour algorithm too 
#why use precision and recall (and their combined measure) instead of accuracy
#for result robustness, CV should be run, but if you have the classification reuslts you can do confusion matrix 
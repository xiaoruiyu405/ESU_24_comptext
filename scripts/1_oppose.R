library(stylo)


#####
# Using oppose() function
library(stylo)
oppose() # This will work.
results = oppose() # But use this if you want to store the results
#application
#female and male writers
#word lists used as classification, put them in the wordlist and rerun the classify function
summary(results) # Glimpse into what results contain

# words used more often in the primary set
results$words.avoided
# words used more often in the secondary set
results$words.preferred
# zeta scores as visible in the 'words' visualisation
results$words.avoided.scores 
results$words.preferred.scores 
# The values used in the 'markers' visualisation
results$summary.zeta.scores

# You can use similar arguments as in the stylo() function
results=oppose(encoding="UTF-8",corpus.lang="English.all")
summary(results)

# Map the percentage of avoided vs preferred used in the samples
results=oppose(visualization = "markers")
# What if we would like to find samples following some criteria
crit1 = results$summary.zeta.scores[,"class"]=="secondary"
crit2 = as.numeric(results$summary.zeta.scores[,"preferred"])>55 # cast from character to numeric values (but should be fine without it too)
crit3 =  as.numeric(results$summary.zeta.scores[,"avoided"])<25
# select the ROWS of data frame based on all 3 criteria
results$summary.zeta.scores[crit1 & crit2 & crit3,] # DO NOT FORGET the COMMA!


#####
# Reusing oppose() function's output in stylo()
new_features = results$words.avoided # use only words avoided
new_features = c(results$words.preferred,results$words.avoided) # or both avoided and preferred

# before using stylo, remember to place the texts in the right directory,
# here: both primary and secondary set moved to corpus 
stylo(features = new_features, encoding="UTF-8", corpus.dir = "corpus")

# Definitely try also the PCA analysis of these selected words
stylo(features = new_features, encoding="UTF-8", corpus.dir = "corpus",
      analysis.type="PCR",pca.visual.flavour="loadings")

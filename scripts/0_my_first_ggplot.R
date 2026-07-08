install.packages("ggplot2")
#dplyr is a data manipulation package for tabular data
install.packages("dplyr")

## load necessary libraries
library(stylo)
library(ggplot2)
library(dplyr)

## use one of the stylo dataset (table with frequencies)
data(lee)
## check data
lee[,1:5]

## standardize (aquire z-scores)
lee <- scale(lee)
lee[,1:5]

## construct a table that holds 100 mfw words and their z-scores (deviations from the corpus mean) which describe "Absalom, Absalom!" by Faulkner

faulkner_df <- tibble(word = colnames(lee[,1:100],),
                      score = lee["Faulkner_Absalom_1936",1:100])

## this table can serve as a minimal example of "tidy" dataframe: one observation recorded per row
## it also called a 'long' format of a table. Full frequency table you had below was an example of a 'wide' format, that is filled with values that mean the same thing (z-scores). 'Long' frequency table would contain only three columns: "document", "word", and "z-score"
faulkner_df

## %>% (shortcut: ctrl+shift+M) is a pipe. It *pipes* output from a function further to another one, so you can read code left to right or bottom-up. Compare to "nesting" functions that need to be read from inside-out: e.g. `mean(abs(seq(-100,100,by=5)))`
## Using pipes it would be much easier to read: 
## seq(-100,100,by=5) %>% abs() %>% mean()

## mutate() below  adds two new columns: 1) logical descriptor if a number is negative, 2) adds rownumbers, which we can treat as word's frequency ranks , since we got the word in the order
## group_by() groups table by `isNegative` so further operations would be performed on groups
## top_n() filters only top 15 features per `isNegative` group

f_df <- faulkner_df %>% 
  mutate(isNegative=ifelse(score>0,FALSE,TRUE),
         rank=row_number()) %>%
  group_by(isNegative) %>% 
  top_n(n = 15,abs(score))

## this table has 30 rows / values now and preserves frequency rank information

## well, let's plot values! ggplot works in adding layers of different geometries, scales, and theme assignments
## minimally it first sets 'aesthetics' aes() -> which tells how to map variables to axis, and optionally how to map these values to other variables in data (e.g. for coloring) 
f_df %>% ggplot(aes(x=score,y=word))

# oh no we don't have anything here! but you see that axis are set well! 
# what we miss is a 'geometry`, a geom_ object that visualizes data points
# geom_point() is one of them
# we use `+` to add layers and controls to ggplot base

f_df %>%
  ggplot(aes(x=score,y=word)) + 
  geom_point()

# looks kind of weird! words are ordered by alphabet, so it's kind of all over the place
# we will deal with it later, let's first color them by mapping color in aesthetics and increasing their size in geometry

f_df %>%
  ggplot(aes(x=score,y=word,color=isNegative)) + 
  geom_point(size=3) 

# let's add lines from the points that end at 0 using geom_segment() for visual clarity
f_df %>%
  ggplot(aes(x=score,y=word,color=isNegative)) + 
  geom_point(size=3) + 
  geom_segment(aes(xend=0,yend=word))

# for ggplot interprets words (categorical values) alphabetically and arranges them on y-axis accordingly. We can reorder them explicitly by their z-score (descending)
f_df %>%
  ggplot(aes(x=score,y=reorder(word,score),color=isNegative)) + 
  geom_point(size=3) + 
  geom_segment(aes(xend=0,yend=word))

# we can rename ugly axis labels using labs() and remove legend with guides()
f_df %>%
  ggplot(aes(x=score,y=reorder(word,score),color=isNegative)) + 
  geom_point(size=3) + 
  geom_segment(aes(xend=0,yend=word)) +
  labs(x="Standard deviation from the corpus mean",
       y=NULL,
       title="Distinctive features in Faulkner's 'Absalom, Absalom!'") +
  guides(color="none")

# and change color palette manually by controlling scale layer
f_df %>%
  ggplot(aes(x=score,y=reorder(word,score),color=isNegative)) + 
  geom_point(size=3) + 
  geom_segment(aes(xend=0,yend=word)) +
  labs(x="Standard deviation from the corpus mean",
       y=NULL,
       title="Distinctive features in Faulkner's 'Absalom, Absalom!'") +
  guides(color="none") +
  scale_color_manual(values=c("pink", "lightblue"))

# let's save this plot to a variable now, to which we can still add stuff
p <- f_df %>%
  ggplot(aes(x=score,y=reorder(word,score),color=isNegative)) + 
  geom_point(size=3) + 
  geom_segment(aes(xend=0,yend=word)) +
  labs(x="Standard deviation from the corpus mean",
       y=NULL,
       title="Distinctive features in Faulkner's 'Absalom, Absalom!'") +
  guides(color="none") +
  scale_color_manual(values=c("pink", "lightblue"))

p

## the appearance of elements on the plot is controlled by a theme() layer. There are few in-packed themes that look nicer than a default
## but you can still add theme() afterwards to control all kinds of features
p <- p + theme_minimal(base_size = 12) 

p


## everything on the plot is controllable one way or another. let's say you want your words at around 0 at different sides for positive and negative values. easy, but requires some tinkering

p<-p + 
#  geom_vline(aes(xintercept=0),color="grey60",linetype=2) +
  geom_text(data=. %>% filter(!isNegative),aes(label=word,x=0),color="grey40",hjust=1,nudge_x = -0.1) + 
  geom_text(data=. %>% filter(isNegative),aes(label=word,x=0),color="grey40",hjust=0,nudge_x = 0.1) + 
  theme(axis.text.y = element_blank())

## tying frequency rank to point sizes? easy
p + geom_point(aes(size=-rank)) + guides(size="none")


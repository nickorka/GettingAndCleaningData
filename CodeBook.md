# Code Book

The script is based of **dplyr** library.

## Functions
There are two helper functions:

* **path(...)** concatenates all strings by Linux character for creating a file path
* **ds(name)** reads folder by provided *name* parameter with data and combines the files to a separate data frame that will be returned by the function

## Variables

* **features** has cleaned content of features.txt file. The data frame has next columns:
  * id - a feature id
  * name - a cleaned name
  * ismean - a flag is TRUE if name has *mean* substring it it
  * isstd - a flag is TRUE if name has *std* substring it it
  
* **df** is combined data frame with next fields:
  * a least of all fields with names that contain *mean* or *std* substring in it according to **features** field
  * subj_id - a subject id
  * activity_id - an activity id
  * activity_label - a readable activity name
  * src - a source of the measurement: *test* or *train*
  
* **df_avg** has a result dataframe with average numbers for each column from **df** data frame grouped by subject and activity  


# ================================================================================
# An NA value usually means that there is no object. So if it is a numerical 
# variable we set the NA values to 0.
# Features (caracter variables) as Quality, Condition etc. often indicate items with an NA value if 
# such an object doesn't exist, so we replace the NA values by 'none'
#
# We also recode ordered factors as pseudo-continuous numerical variables
#
# Params: df    - data set to convert
#
# Return: df    - converted dataset
NaHandler <- function( df ){
  
  df <- data.frame(df)
  
  # Initiall we do it the easy way. 
  # An NA value usually means that there is no object, so we set the NA values to 0

  df <- df %>% mutate(Garage.Cars    = ifelse(is.na(Garage.Cars), 0, Garage.Cars))
  df <- df %>% mutate(Garage.Area    = ifelse(is.na(Garage.Area), 0, Garage.Area))
  df <- df %>% mutate(Bsmt.Full.Bath = ifelse(is.na(Bsmt.Full.Bath), 0, Bsmt.Full.Bath))
  df <- df %>% mutate(Bsmt.Half.Bath = ifelse(is.na(Bsmt.Half.Bath), 0, Bsmt.Half.Bath))
  df <- df %>% mutate(BsmtFin.SF.1   = ifelse(is.na(BsmtFin.SF.1), 0, BsmtFin.SF.1))
  df <- df %>% mutate(BsmtFin.SF.2   = ifelse(is.na(BsmtFin.SF.2), 0, BsmtFin.SF.2))
  df <- df %>% mutate(Bsmt.Unf.SF    = ifelse(is.na(Bsmt.Unf.SF), 0, Bsmt.Unf.SF))
  df <- df %>% mutate(Total.Bsmt.SF  = ifelse(is.na(Total.Bsmt.SF), 0, Total.Bsmt.SF))

  df <- df %>% mutate(Lot.Frontage   = ifelse(is.na(Lot.Frontage), 0, Lot.Frontage))
  df <- df %>% mutate(Garage.Yr.Blt  = ifelse(is.na(Garage.Yr.Blt), 0, Garage.Yr.Blt))
  df <- df %>% mutate(Mas.Vnr.Area   = ifelse(is.na(Mas.Vnr.Area), 0, Mas.Vnr.Area))
    
  # The features like Quality, Condition etc. often indicate items with an NA value if 
  # such an object doesn't exist, so we replace the NA values to 'none'
  
  # Recode ordered factors as pseudo-continuous numerical variables
  df$Bsmt.Qual      <- recode( df$Bsmt.Qual, 'none')
  df$Bsmt.Cond      <- recode( df$Bsmt.Cond, 'none')
  df$Fireplace.Qu   <- recode( df$Fireplace.Qu, 'none' )
  df$Pool.QC        <- recode( df$Pool.QC, 'none' )
  df$Bsmt.Qual      <- recode( df$Bsmt.Qual, 'none' )
  df$Bsmt.Cond      <- recode( df$Bsmt.Cond, 'none' )
  df$Bsmt.Exposure  <- recode( df$Bsmt.Exposure, 'none')
  df$BsmtFin.Type.1 <- recode( df$BsmtFin.Type.1, 'none')
  df$BsmtFin.Type.2 <- recode( df$BsmtFin.Type.2, 'none' )
  df$Fence          <- recode( df$Fence, 'none' )
  df$Alley          <- recode( df$Alley, 'none' )
  df$Garage.Type    <- recode( df$Garage.Type, 'none' )
  df$Garage.Qual    <- recode( df$Garage.Qual, 'none' )
  df$Garage.Finish  <- recode( df$Garage.Finish, 'none' )
  df$Garage.Cond    <- recode( df$Garage.Cond, 'none' )
  df$Misc.Feature   <- recode( df$Misc.Feature, 'none' )  
  df$Mas.Vnr.Type   <- recode( df$Mas.Vnr.Type, 'None' ) # 29
  
  # special treatement
  df$Sale.Condition <- ifelse( df$Sale.Cond == "Abnorml", 1, 0 )

  # df$Condition.1 <- ifelse( (df$SCondition.1 == "none" | df$SCondition.1 == "Norm"), 1, 0 )
  # df$Condition.2 <- ifelse( (df$SCondition.2 == "none" | df$SCondition.2 == "Norm"), 1, 0 )
  
  return(df)
}

# ================================================================================
# Map features to numerical values
#
# Params: df    - data set to convert
#
# Return: df    - converted dataset
recode.features <- function(df){
  
  # Map features to numerical values
  feature.list = c('Exter.Qual', 'Exter.Cond', 'Garage.Qual', 'Garage.Cond', 'Fireplace.Qu', 
                   'Kitchen.Qual', 'Heating.QC', 'Bsmt.Qual', 'Bsmt.Cond', 'Pool.QC' )
  param.list = c('none' = 0, 'Po' = 1, 'Fa' = 2, 'TA' = 3, 'Gd' = 4, 'Ex' = 5)
  df <- map.fcn(feature.list, param.list, df)
  
  param.list = c('none' = 0, 'No' = 1, 'Mn' = 2, 'Av' = 3, 'Gd' = 4)
  data.train <- map.fcn(c('Bsmt.Exposure'), param.list, df)
  
  feature.list = c('BsmtFin.Type.1','BsmtFin.Type.2')
  param.list = c('none' = 0, 'Unf' = 1, 'LwQ' = 2,'Rec'= 3, 'BLQ' = 4, 'ALQ' = 5, 'GLQ' = 6)
  df = map.fcn(feature.list, param.list, df)
  
  param.list = c('None' = 0, 'Sal' = 1, 'Sev' = 2, 'Maj2' = 3, 'Maj1' = 4, 'Mod' = 5, 'Min2' = 6, 'Min1' = 7, 'Typ'= 8)
  df = map.fcn(c('Functional'), param.list, df)
  
  param.list = c('none' = 0,'Unf' = 1, 'RFn' = 2, 'Fin' = 3)
  df = map.fcn(c('Garage.Finish'), param.list, df)
  
  param.list = c('none' = 0, 'MnWw' = 1, 'GdWo' = 2, 'MnPrv' = 3, 'GdPrv' = 4)
  df = map.fcn(c('Fence'), param.list, df)
  
  param.list = c('none' = 0, 'Shed' = 1, 'Othr' = 2, 'Gar2' = 3, 'Elev' = 4, 'TenC' = 5)
  df = map.fcn(c('Misc.Feature'), param.list, df)
  
  param.list = c('none' = 0, 'CarPort' = 1, 'Detchd' = 2, 'BuiltIn' = 3, 'Basment' = 4, 'Attchd' = 5, '2Types' = 6)
  df = map.fcn(c('Garage.Type'), param.list, df)
  
  param.list = c('None' = 0, 'Stone' = 1, 'CBlock' = 2, 'BrkFace' = 3, 'BrkCmn' = 4)
  df = map.fcn(c('Mas.Vnr.Type'), param.list, df)
  
  param.list = c('none' = 0, 'Grvl' = 1, 'Pave' = 2)
  df = map.fcn(c('Alley'), param.list, df)

  param.list = c('none' = 0, 'ELO' = 1, 'NoSewr' = 2, 'NoSeWa' = 3, 'AllPub' = 4)
  df = map.fcn(c('Utilities'), param.list, df)
  
  param.list = c('none' = 1, 'N' = 1, 'P' = 2, 'Y' = 3)
  df = map.fcn(c('Paved.Drive'), param.list, df)
  
  param.list = c('none' = 0, 'N' = 0,'Y' = 1)
  df = map.fcn(c('Central.Air'), param.list, df)

  param.list = c('none' = 1, 'Grvl' = 1,'Pave' = 2)
  df = map.fcn(c('Street'), param.list, df)

  param.list = c('none' = 0, 'No' = 1, 'Mn' = 2, 'Gd' = 3, 'Av' = 4)
  df = map.fcn(c('Bsmt.Exposure'), param.list, df)
  
  param.list = c('none' = 1, 'Inside' = 1, 'Corner' = 2, 'CulDSac' = 3, 'CulDSac' = 4, 'FR2' = 5, 'FR3' = 6)
  df = map.fcn(c('Lot.Config'), param.list, df)
  
  param.list = c('none' = 1, 'A (all)' = 1, 'C (all)' = 2, 'RM' = 3, 'FV' = 4, 'RH' = 5, 'RP' = 6, 'I (all)' = 7, 'RL' = 8)
  df = map.fcn(c('MS.Zoning'), param.list, df)
  
  param.list = c('none' = 1, 'Gtl' = 1, 'Mod' = 2, 'Sev' = 3)
  df = map.fcn(c('Land.Slope'), param.list, df)
  
  param.list = c('none' = 1, 'Reg' = 1, 'IR1' = 2, 'IR2' = 3, 'IR3' = 4)
  df = map.fcn(c('Lot.Shape'), param.list, df)
  
  param.list = c('none' = 1, 'Lvl' = 1, 'Low' = 2, 'HLS' = 3, 'Bnk' = 4)
  df = map.fcn(c('Land.Contour'), param.list, df)

  # param.list = c('none' = 1, 'Normal' = 1, 'Partial' = 2, 'AdjLand' = 3, 'Abnorml' = 4, 'Alloca' = 5, 'Family' = 6)
  # df = map.fcn(c('Sale.Condition'), param.list, df)
  
  param.list = c('none' = 10, 'COD' = 1, 'Con' = 2, 'ConLD' = 3, 'ConLI' = 4, 'ConLw' = 5, 'CWD' = 6, 'New' = 7, 'Oth' = 8, 'VWD' = 9, 'WD ' = 10)
  df = map.fcn(c('Sale.Type'), param.list, df)
  
  param.list = c('none' = 5, 'FuseA' = 1, 'FuseF' = 2, 'FuseP' = 3, 'Mix' = 4, 'SBrkr' = 5)
  df = map.fcn(c('Electrical'), param.list, df)
  
  param.list = c('none' = 2, 'Floor' = 1, 'GasA' = 2, 'GasW' = 3, 'Grav' = 4, 'OthW' = 5, 'Wall' = 6 )
  df = map.fcn(c('Heating'), param.list, df)
  
  param.list = c('none' = 3, 'BrkTil' = 1, 'CBlock' = 2, 'PConc' = 3, 'Slab' = 4, 'Stone' = 5, 'Wood' = 6 )
  df = map.fcn(c('Foundation'), param.list, df)
  
  param.list = c('none' = 15, 'AsbShng' = 1, 'AsphShn' = 2, 'BrkComm' = 3, 'BrkFace' = 4, 'CBlock' = 5, 
                 'CemntBd' = 6, 'HdBoard' = 7, 'ImStucc' = 8, 'MetalSd' = 9, 'Other' = 10, 'Plywood' = 11,
                 'PreCast' = 12, 'Stone' = 13, 'Stucco' = 14, 'VinylSd' = 15, 'Wd Sdng' = 16, 'WdShing' = 17, 
                 'Wd Shng' = 18)
  df <- map.fcn('Exterior.1st', param.list, df)
  
  param.list = c('none' = 15, 'AsbShng' = 1, 'AsphShn' = 2, 'Brk Cmn' = 3, 'BrkFace' = 4, 'CBlock' = 5, 
                 'CmentBd' = 6, 'HdBoard' = 7, 'ImStucc' = 8, 'MetalSd' = 9, 'Other' = 10, 'Plywood' = 11,
                 'PreCast' = 12, 'Stone' = 13, 'Stucco' = 14, 'VinylSd' = 15, 'Wd Sdng' = 16, 'Wd Shng' = 17
  )
  df <- map.fcn('Exterior.2nd', param.list, df)
  
  feature.list = c('Condition.1', 'Condition.2')
  param.list = c('none' = 3, 'Artery' = 1, 'Feedr' = 2, 'Norm' = 3, 'RRNn' = 4, 'RRAn' = 5,
                 'PosN' = 6, 'PosA' = 7, 'RRNe' = 8, 'RRAe' = 9)
  df <- map.fcn(feature.list, param.list, df)
  
  param.list = c('none' = 2, 'Flat' = 1, 'Gable' = 2, 'Gambrel' = 3, 'Hip' = 4, 'Mansard' = 5, 'Shed' = 6 )
  df = map.fcn(c('Roof.Style'), param.list, df)
  
  param.list = c('none' = 2, 'ClyTile' = 1, 'CompShg' = 2, 'Membran' = 3, 'Metal' = 4, 'Roll' = 5, 'Tar&Grv' = 6, 
                 'WdShake' = 7, 'WdShngl' = 8)
  df = map.fcn(c('Roof.Matl'), param.list, df)
  
  param.list = c('none' = 1, '1Fam' = 1, '2fmCon' = 2, 'Duplex' = 3, 'TwnhsE' = 4, 'TwnhsI' = 5, 'Twnhs' = 6)
  df = map.fcn(c('Bldg.Type'), param.list, df)
  
  param.list = c('none' = 1, '1Story' = 1, '1.5Fin' = 2, '1.5Unf' = 3, '2Story' = 4, '2.5Fin' = 5, 
                 '2.5Unf' = 6, 'SFoyer' = 7, 'SLvl' = 8)
  df = map.fcn(c('House.Style'), param.list, df)
  
  param.list = c('none' = 1, 'Blmngtn' = 1, 'Blueste' = 2, 'BrDale' = 3, 'BrkSide' = 4, 'ClearCr' = 5, 
                 'CollgCr' = 6, 'Crawfor' = 7, 'Edwards' = 8, 'Gilbert' = 9, 'Greens' = 10, 'GrnHill' = 11,
                 'IDOTRR' = 12, 'Landmrk' = 13, 'MeadowV' = 14, 'Mitchel' = 15, 'NAmes' = 16, 'NoRidge' = 17,
                 'NPkVill' = 18, 'NridgHt' = 19, 'NWAmes' = 20, 'OldTown' = 21, 'SWISU' = 22, 'Sawyer' = 23,
                 'SawyerW' = 24, 'Somerst' = 25, 'StoneBr' = 26, 'Timber' = 27, 'Veenker' = 28
  )
  df = map.fcn(c('Neighborhood'), param.list, df)
  
   
  return(df)
 }

# ================================================================================
# function checks for NA values and replaces the value by an 'Na'
# character, which in the dataset is used as not available
#
# Params: feature    - feature to apply values to change
#
# Return: feature    - column with changed values
recode <- function( feature, term ){
  
  feature <- as.character(feature)
  feature <- ifelse(is.na(feature), term, feature)
  
  return(feature)
}

# ================================================================================
# function that maps a categorical values into its corresponding numeric value and 
# returns that column to the data frame
#
# Params: cols       - columns which need attention
#         map.param  - param to replace
#         df         - Data set to be changed   
#  
# Return: df         - changed data set   
map.fcn = function(cols, map.param, df){
  
  for (col in cols) {
    df[col] = as.character(df[,col])
    df[col] = as.numeric(map.param[df[,col]])
  }
  return(df)
}

# ================================================================================
# Function checks all features in the data set and calculates the number of 
# NA's 
#
# Params: df         - Data set to evaluate NA's   
#         show       - show results
# Return: df         - changed data set   
CheckNA <- function( df , show = 1) {
  
  na_count <- sapply(df, function(x) sum(is.na(x)))
  data.na_count <- data.frame(na_count)
  data.merged <- data.frame(cbind(c(row.names(data.na_count)), data.na_count[, 1]))
  colnames(data.merged) <- c('feature', 'No_NA')
  
  data.na <- data.merged[data.merged$No_NA != 0,]
  
  if (show == 0) { 
    
  }
  
  if(show == 1){
    data.na
  }
  
  if(show == 2){
    cScheme <- dim(data.na)[1]
    ggplot(data = data.na, aes(x = data.na$feature, y = data.na$No_NA, fill = feature)) +
      geom_bar(stat = "identity") +
      xlab("feature") + ylab("Number of NA") +
      ggtitle("Number of NA's in dataset") +
      theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
      geom_text(aes(label = No_NA), vjust = 1.6, color = "black", position = position_dodge(0.9), size = 3) + 
      guides(FALSE) +
      scale_fill_manual(values = colorRampPalette(c("gray","steelblue" ))(cScheme))
  }
}

# ================================================================================
# Function to clean empty fields by placing a deined value NA 
#
# Params: df         - Data set to clean    
#
# Return: df         - cleaned data set   

cleanEmptyFields <- function(df, term){

  feature.list <- colnames(df)
  for (feature in feature.list) {
    df[feature][df[feature] == ''] <- term
    }
  return(df)
}

# ================================================================================
# Function to create formula based on given data set 
# 
# Params: data       - Data set to evaluate formula   
#         label      - dependent label          
# Return: formula    - formula 
getFormula <- function(data = data, label = label) {
  
  # label Variable
  labelVar <- label
  
  # separate measure Variable y column from rest 
  groupVariables <- setdiff(colnames(data), list(label))
  
  # create formula for model 
  formula <- as.formula(paste(labelVar, paste(groupVariables, collapse = ' + '), sep = ' ~ '))
  
}

# ================================================================================
# Min/max normalization of numeric columns
#
# Params: x         - features to normalize   
# Return:           - normalized values
normalize <- function(x) {
  
  return((x - min(x)) / (max(x) - min(x)))
}

# ================================================================================
# dmode  - will retrieve the mode of a given desity function (data) 
# 
# Params: vector     - label 
# Return:            - mode of dictribution
dmode <- function(x) {
  den <- density(x, kernel = c("gaussian"))
  ( den$x[den$y == max(den$y)] )   
}  

# ================================================================================
# getFormula  - will retrieve the formula based on a data set
# 
# Params: data     - dataset
#         label    - label 
# Return:          - formula
getFormula <- function(data = data, label = label) {
  
  # label Variable
  labelVar <- label
  
  # separate measure Variable y column from rest 
  groupVariables <- setdiff(colnames(data), list(label))
  
  # create formula for model 
  formula <- as.formula(paste(labelVar, paste(groupVariables, collapse = ' + '), sep = ' ~ '))
  
}

# ================================================================================
# prepNormalized_Df  - Extact and remove column of dependent variable from data set. 
#                      Column will be reattached after normalization of data set
# 
# Params: data     - dataset
#         feature  - dependent variable
# Return: data     - normalized restructured dataset
NormalizeDF <- function(data, feature){

  # Extact and remove column of dependent variable from data set. Column will be reattached after 
  # normalization of data set
  depVariable <- data.frame(data[feature])
  data[feature] <- NULL
 
  # Normalize the data set and attach price column again
  df.normalized <- normalize(data)
  df.normalized  <- cbind(df.normalized, depVariable)

  return(df.normalized)
}


# ================================================================================
# RMSE  - Calcuates the Root Mean Squared Error
# 
# Params: actual     - actual values
#         predicted  - predicted values 
# Return: rmse       - Root Mean Squared Error

rmse <- function(actual, predicted) {
  
  return(sqrt( mean((actual - predicted)^2)))
}

# ================================================================================
# CheckForOutliners  - Checks for outliners in the data set
#                      via resid 
# 
# Params: df         - data set
#         model      - proposed model 
# Return: df         - cleaned dataset
CheckForOutliners <- function(data, model){
  
  # evaluate the house with the max residuals 
  idx_outliner <- which(abs(resid(model)) == max(abs(resid(model))))
  idx_outliner <- unname(idx_outliner)
  
  data <- data[-c(idx_outliner), ]
  
  return(data)
}

# ================================================================================
# removeOutliners  - Removes outliners in the data set
# 
# Params: df         - data set
#         outliners  - outliners to remove 
# Return: df         - cleaned dataset
removeOutliners <- function(df, outliners){
  
  # based on our analysis we'll remove the most vicious 
  # outliners
  df <- df[-outliners, ]

  return(df)
}


finalCleanUp <- function(df){
  
  # Parcel identification number (PID) is not a relevant predictor. It can only be used 
  # with city web site for parcel review.  
  df$PID <- NULL
  
  # Factors that earlier analyses didn't like and too much of a pain in the neck to keep
  df$Fence <- NULL
  df$Roof.Style <- NULL
  df$Heating <- NULL
  df$Utilities <- NULL

  return(df)
}


# ================================================================================
# gg_pairs color function for lower regression parts
# 
# Return: gglplot       - return regression plot
ggpairs_lower <- function(data, mapping, ...) { 
  ggplot(data = data, mapping = mapping) + 
    geom_point(col = 'steelblue') + 
    geom_smooth(method = loess, fill = "red", color = "red", ...) +
    geom_smooth(method = lm, fill = "blue", color = "blue", ...)
  
}

# ================================================================================
# gg_pairs color function for diag density parts
# 
# Return: gglplot       - return density plot
ggpairs_diag <- function(data, mapping, ...){
  ggplot(data = data, mapping = mapping) + 
    geom_density(size = 1, colour = 'darkgreen')
  
}



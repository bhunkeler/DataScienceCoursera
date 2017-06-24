---
title: "Peer Assessment II"
author: "Bruno Hunkeler"
date:   "15.06.2017"
output:
  html_document: 
    pandoc_args: [
      "--number-sections",
    ]
---

<h3><b>Background</b></h3>

As a statistical consultant working for a real estate investment firm, your task is to develop a model to predict the selling price of a given home in Ames, Iowa. Your employer hopes to use this information to help assess whether the asking price of a house is higher or lower than the true value of the house. If the home is undervalued, it may be a good investment for the firm.

<h3><b>Training Data and relevant packages</b></h3>
In order to better assess the quality of the model you will produce, the data have been randomly divided into three separate pieces: a training data set, a testing data set, and a validation data set. We will load all datasets here.

<h4><b>Load Datasets</b></h4>

```r
load("Data/ames_train.Rdata")
load("Data/ames_test.Rdata")
load("Data/ames_validation.Rdata")

data.train <- ames_train
data.test <- ames_test
data.validation <- ames_validation
```

<h4><b>Load Packages</b></h4>

```r
library('plyr')         # data manipulation
library('ggplot2')      # library to create plots
library('dplyr')        # data manipulation
library('knitr')        # required to apply knitr options 
library('statsr')       # staistics functions   

library('GGally')       # library to create plots
library('gridExtra')    # arrange plots
library('BAS')          # Bayesian statistics functions
library('labeling')     # dependency package to ggplot

library('MASS')         # Support Functions 
library('Boruta')       # Wrapper Algorithm for Feature Selection
library('car')          # Companion to Applied Regression

library('corrplot')     # correlation plot
library('RColorBrewer') # Color scheme 

source('helper.R')      # support functions used in the analysis - See Appendix

# apply general knitr options
knitr::opts_chunk$set(comment=NA, fig.align='center')
```

<h3><b>Part 1 - Exploratory Data Analysis (EDA)</b></h3>

<h4><b>Summarize Missing values</b></h4>
We initially start verifying the missing values in our data set. This is just an initial step to define, which feature needs maintenance.


```r
# check which features contain NA values
CheckNA(data.train, 2)
```

<img src="figure/unnamed-chunk-1-1.png" title="plot of chunk unnamed-chunk-1" alt="plot of chunk unnamed-chunk-1" style="display: block; margin: auto;" />

<h4><b>Strategy for missing values</b></h4>
Handling missing values is an important part of the data cleaning. The chosen approach is not meant to be a highly sophisticated approach to fill the missing values, but will fulfil it's duty. The codebook reveals that for multiple features `NA` value have been applied, if an item doesn't exist 
(e.g. Garage.Cars -> NA means no garage). The original dataset also contains empty values. We'll transform the empty values into `NA's`. 

In case of a numerical feature we apply a 0 value, For categorical features (e.g. `poor`, `fair`, `typical/average`, `good` and `excellent`), we’ll map numeric values (e.g. 0 - 5) to their corresponding categoric values (including 0 for none) and combine those with our dataset. But there are also categorical features where an `NA` placeholder will get a value assigned. The assigned value has been evaluated based on the majority of occurrences.
Find the list below.

<b>Categorical features containing an `NA` value will be set to `none`, and mapped to a defined value</b></br>

  Feature                     | Value            | Parameter |                   
  ----------------------------|------------------|-----------|
  `Paved.Drive`               | none set to 1    | Grvl      |
  `Street `                   | none set to 1    | Grvl      |
  `Lot.Config`                | none set to 1    | Inside    |
  `MS.Zoning`                 | none set to 1    | A(all)    |
  `Land.Slope`                | none set to 1    | Gtl       |
  `Lot.Shape`                 | none set to 1    | Reg       |
  `Land.Contour`              | none set to 1    | Lvl       |
  `Sale.Condition`            | none set to 1    | Normal    |
  `Sale.Type`                 | none set to 10   | WD        |
  `Electrical`                | none set to 5    | SBrkr     |
  `Heating`                   | none set to 2    | GasA      |
  `Foundation`                | none set to 3    | Pconc     |
  `Exterior.1st`              | none set to 15   | VinylSD   |
  `Exterior.2nd`              | none set to 15   | VinylSD   |
  `Condition.1 / Condition.2` | none set to 3    | Norm      |
  `Roof.style`                | none set to 2    | Gable     |
  `Bldg.Type`                 | none set to 1    | 1Fam      |
  `House.Style`               | none set to 1    | 1Story    |
  `Neighborhood`              | none set to 1    | Blmngtn   |

<b>Categorical features containing an `NA` value will be set to `none` and mapped to a 0 value</b></br>
`Garage.type`, `Garage.Finish`, `Garage.Qual`, `Garage.Cond`, `Pool.QC`,  
`Fireplace.Qu`, `Fence`, `Misc.Feature`, `Alley`, `Bsmt.Qual`, `Bsmt.Cond`,     
`BsmtFin.Type.1`, `Bsmt.Exposure`, `BsmtFin.Type.2`</br>
</br>
<b>Numerical features containing an `NA` will be set to 0</b></br>
`Garage.Cars`, `Garage.Area`, `Garage.Yr.Blt`, `BsmtFin.SF.1`, `BsmtFin.SF.2`, `Bsmt.Unf.SF`</br>
`Total.Bsmt.SF`, `Bsmt.Full.Bath`, `Bsmt.Half.Bath`, `Mas.Vnr.Area`


```r
# ==========================================================================
# Clean empty fields by adding an NA vaue. Then check for NA values and
# run filling in values for missing data 

data.train <- cleanEmptyFields(data.train, NA)
data.train <- NaHandler(data.train)
CheckNA(data.train, 0)             # This check should reveil no NA values
data.train <- recode.features(data.train)

# NA value handling test data
data.test <- cleanEmptyFields(data.test, NA)
data.test <- NaHandler(data.test)
CheckNA(data.test, 0)              # This check should reveil no NA values
data.test <- recode.features(data.test)

# NA value handling validation data
data.validation <- cleanEmptyFields(data.validation, NA)
data.validation <- NaHandler(data.validation)
CheckNA(data.validation, 0)        # This check should reveil no NA values
data.validation <- recode.features(data.validation)
```

<h4><b>Normalize Data set</b></h4> 
When dealing with values that lie in different ranges, it is common to normalize the data for better evaluation.
I used the min and max normalization approach.


```r
# ==========================================================================
# Normalize training / test and validation data 

# Normalize training data set and store a original data set
df.train.normalized <- NormalizeDF(data.train, 'price')
df.train.normalized.org <- df.train.normalized

# Normalize test data set and store a original data set
df.test.normalized <- NormalizeDF(data.test, 'price')
df.test.normalized.org <- df.test.normalized

# Normalize validation data set and store a original data set
data.validation <- data.validation[complete.cases(data.validation), ]
df.validation.normalized <- NormalizeDF(data.validation, 'price')
df.validation.normalized.org <- df.validation.normalized
```


```r
# create working copies
df.train      <- data.train
df.test       <- data.test
df.validation <- data.validation

# final Clean Up
df.train      <- finalCleanUp(df.train)
df.test       <- finalCleanUp(df.test)
df.validation <- finalCleanUp(df.validation)

# create an original with and without outliners
df.train.Outliner   <- df.train
df.train.NoOutliner <- removeOutliners(df.train, c(428, 310))
```

<h4><b>Correlation Matrix</b></h4> 
We’ve transformed all the categoric features with an ordinal scale into numeric columns. Let’s see which variables have the strongest effect on housing price.
In order to determine the feature with the strongest relation towards price, we need to calculate the sample correlation coefficient between 2 variables,

$$r_{xy} = \frac{s_{xy}}{s_xs_y}$$ where $s_{xy} = \mathbf{E}[(X-\mathbf{E}[X])(Y-\mathbf{E}[Y])$ is the sample covariance and $s_x, s_y$ are the sample standard deviations. The correlation coefficient measures the linearly between 2 variables. A coefficient of 0 means that the 2 variables show no linear relation, a coefficient between (0,1) shows that they have a positive relation and a coefficient between (-1,0) means they have a negative relation. We’re particularly interested in variables that show a strong relation to price, so we will focus primarily on features that have a coefficient > 0.5 or < -0.5.


```r
correlations = cor(df.train, method = "s")

# only want the columns that show strong correlations with price
corr.price = as.matrix(sort(correlations[,'price'], decreasing = TRUE))

corr.idx = names(which(apply(corr.price, 1, function(x) (x > 0.5 | x < -0.5))))

corrplot(as.matrix(correlations[corr.idx,corr.idx]), type = 'upper', method='color', 
         title = 'Correlation Plot of the 20 features', 
         addCoef.col = 'black', tl.cex = .7,cl.cex = .7, number.cex=.7)
```

<img src="figure/creategraphs-1.png" title="plot of chunk creategraphs" alt="plot of chunk creategraphs" style="display: block; margin: auto;" />

The correlation plot indicates the 20 features with the strongest effect on housing prices. I won't go through all of them, but pick a few to comment on.

The features `Overall.Qual and area` show the strongest correlation. I reckon this makes sense, since the overall quality of a house must have an impact on the sales price. With `Garage.Cars, Year.Built` we ceratinly could expect those features to be important. Further we have the features with a quality aspect `Bsmt.Qual, Exter.Qual, Kitchen.Qual`, which I believe might be relevant. In general I think all quality related features must have an impact.  
I wouldn't expect `Garage.Yr.Blt` to be an important feature, but let it be so.
`YearBuilt, YearRemodAdd` a positive correlation of those features should be NO surprise to us. Newer homes will likely sell to higher prices then older ones.


```r
df.train <- df.train %>% dplyr::select(price, X1st.Flr.SF, 
                                       X2nd.Flr.SF, Lot.Area, 
                                       MS.SubClass, Mas.Vnr.Type, 
                                       Mas.Vnr.Area, Garage.Area, 
                                       Screen.Porch, Year.Built, 
                                       BsmtFin.SF.1, Pool.Area, 
                                       TotRms.AbvGrd)


ggpairs(df.train, 
          columns=1:13, 
          upper = list(continuous = wrap('cor', size = 4, col = 'steelblue')), 
          diag  = list(continuous = ggpairs_diag),
          lower = list(continuous = ggpairs_lower), 
          title = 'Correlation & Density plot'
          ) 
```

<img src="figure/unnamed-chunk-5-1.png" title="plot of chunk unnamed-chunk-5" alt="plot of chunk unnamed-chunk-5" style="display: block; margin: auto;" />

This graph has been chosen, because it shows multiple information in a compact way. The main required information is to see the distribution of the given features resp. if we need to potentially transform the feature at a latter stage. It also shows the general correlation and some indication of outliners in a compact form. 
This plot is not meant to give detailed information. It is meant to be used to isolate some trends, potential problems etc. to give a hint where deeper investigation is required.

What we see here is, that price is right skewed and not normal distributed, or that the feature Mas.Vnr.Area has some Outliners or high leverage points etc. Those findings will then require a deeper analysis.


```r
summary.Price <- df.train %>% dplyr::summarise(mean_Price   = mean(price),
                                    median_Price = median(price),
                                    sd_Price     = sd(price),
                                    min_Price    = min(price),
                                    max_Price    = max(price),
                                    IQR_Price    = IQR(price),
                                    total = n())
```



```r
kable(summary.Price[1:6], caption = 'Price table of Houses in Ames Iowa')
```



| mean_Price| median_Price| sd_Price| min_Price| max_Price| IQR_Price|
|----------:|------------:|--------:|---------:|---------:|---------:|
|   181190.1|       159467| 81909.79|     12789|    615000|   83237.5|

The table above just shows a summary of the sales prices of homes in Ames, Iowa.

<h3><b>Part 2 - Development and assessment of an initial model, following a semi-guided process of analysis</b></h3>

<h4><b>Section 2.1 Initial Model</b></h4>
Running through the EDA and consulting the codebook, I figured that the features, which are related to size, quality and condition would be major drivers for the sales price of a house. Therefore I came up with the following initial "intuitive" model.

Initial Model Selection</br>
<b>price ~ area + Overall.Qual + Overall.Cond + Kitchen.Qual + Bsmt.Qual + Exter.Qual + Year.Built + Garage.Area + Lot.Area + Fireplace.Qu</b></br>

Next we show a summary of our initial model.


```r
# ==========================================================================
# 2.2.1 Initial Model selection 
df.train <- df.train.Outliner

df.train <- df.train %>% dplyr::select(price, area, Overall.Qual, 
                                                       Overall.Cond, Kitchen.Qual, 
                                                       Year.Built, Bsmt.Qual, 
                                                       Exter.Qual, Garage.Area, 
                                                       Lot.Area, Fireplace.Qu)

initial.model  <- as.formula(price ~ area + Overall.Qual + 
                               Overall.Cond + Year.Built + 
                               Exter.Qual +  Bsmt.Qual + 
                               Lot.Area + Kitchen.Qual + 
                               Fireplace.Qu + Garage.Area)

initial.lm.model <- lm(initial.model , data = df.train)
summary(initial.lm.model)
```

```

Call:
lm(formula = initial.model, data = df.train)

Residuals:
    Min      1Q  Median      3Q     Max 
-311027  -19699   -2799   16182  252027 

Coefficients:
               Estimate Std. Error t value Pr(>|t|)    
(Intercept)  -6.228e+05  1.137e+05  -5.475 5.53e-08 ***
area          4.179e+01  3.168e+00  13.192  < 2e-16 ***
Overall.Qual  1.236e+04  1.504e+03   8.215 6.62e-16 ***
Overall.Cond  4.899e+03  1.130e+03   4.336 1.60e-05 ***
Year.Built    2.251e+02  5.950e+01   3.784 0.000164 ***
Exter.Qual    2.273e+04  3.258e+03   6.978 5.49e-12 ***
Bsmt.Qual     8.767e+03  1.854e+03   4.729 2.58e-06 ***
Lot.Area      8.826e-01  1.192e-01   7.405 2.80e-13 ***
Kitchen.Qual  1.245e+04  2.675e+03   4.656 3.67e-06 ***
Fireplace.Qu  4.448e+03  7.659e+02   5.808 8.50e-09 ***
Garage.Area   5.695e+01  6.668e+00   8.541  < 2e-16 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Residual standard error: 35170 on 989 degrees of freedom
Multiple R-squared:  0.8175,	Adjusted R-squared:  0.8157 
F-statistic: 443.1 on 10 and 989 DF,  p-value: < 2.2e-16
```

Summary estimates should only be trusted if the conditions for the regression are reasonable. Having mentioned that, it will be relevant to validate the following aspects:

<h4>Evaluate conditions for Regression</h4>

(i) There is a linear relationship between any numerical predictor variables and the response variable.
(ii) The residuals are nearly normal distributed
(iii) The residuals display constant variability
(iv) The residuals are independent

We first will examine whether the numerical variables included in the model, are linearly related to the response variable (price) by examining the distribution of the residuals.


```r
ggplot(data = NULL, aes(x = df.train$price, y = initial.lm.model$residuals)) + 
  geom_point(col = 'darkgreen') + 
  geom_hline(yintercept = 0, linetype = 'dashed', color = 'red')
```

<img src="figure/unnamed-chunk-9-1.png" title="plot of chunk unnamed-chunk-9" alt="plot of chunk unnamed-chunk-9" style="display: block; margin: auto;" />

The residuals are scattered randomly around 0 in most cases except for the ones in the higher price segment. In general the residuals exhibit “heteroscedasticity”, meaning that the residuals get larger as the prediction moves from small to large. This is something we need to keep in mind. Next, we check whether the residuals display a nearly normal distribution centred around 0.


```r
par(mfrow = c(1,2))
hist(initial.lm.model$residuals, col = 'steelblue')
qqnorm(initial.lm.model$residuals, col = 'darkgreen')
qqline(initial.lm.model$residuals, col = 'red')
```

<img src="figure/unnamed-chunk-10-1.png" title="plot of chunk unnamed-chunk-10" alt="plot of chunk unnamed-chunk-10" style="display: block; margin: auto;" />

The results of the histogram of the residuals shows a normal distribution around 0, which is slightly left skewed. This might be driven by an 'extreme' outliners (see figure below). The Q-Q plot also indicates some skewness in the tails, but there are no major deviations. So we can conclude that the conditions for this model are reasonable. 


```r
par(mfrow = c(1,2))
ggplot(data = NULL, aes(x = initial.lm.model$fitted, y = initial.lm.model$residuals)) + 
  geom_point(col = 'darkgreen') + 
  geom_hline(yintercept = 0, linetype = 'dashed', color = 'red')
```

<img src="figure/unnamed-chunk-11-1.png" title="plot of chunk unnamed-chunk-11" alt="plot of chunk unnamed-chunk-11" style="display: block; margin: auto;" />
The results show that the residuals are equally variable for low and medium values of the predicted values, i.e., residuals have a constant variability, while in higher price segments 
the model tends to over estimate.
We can also perform a hierarchical analysis of variance table by using the anova function: An ANOVA table shows the possible associations between the independent and dependent variables. That Information gets lost in the summary output of a t-test. The results of the ANOVA test are shown below.


```r
anova(initial.lm.model)
```

```
Analysis of Variance Table

Response: price
              Df     Sum Sq    Mean Sq   F value    Pr(>F)    
area           1 3.4048e+12 3.4048e+12 2753.3952 < 2.2e-16 ***
Overall.Qual   1 1.4310e+12 1.4310e+12 1157.2275 < 2.2e-16 ***
Overall.Cond   1 7.7238e+08 7.7238e+08    0.6246    0.4295    
Year.Built     1 1.8496e+11 1.8496e+11  149.5683 < 2.2e-16 ***
Exter.Qual     1 1.4316e+11 1.4316e+11  115.7720 < 2.2e-16 ***
Bsmt.Qual      1 4.4619e+10 4.4619e+10   36.0825 2.655e-09 ***
Lot.Area       1 9.7010e+10 9.7010e+10   78.4495 < 2.2e-16 ***
Kitchen.Qual   1 3.5327e+10 3.5327e+10   28.5680 1.123e-07 ***
Fireplace.Qu   1 4.7596e+10 4.7596e+10   38.4899 8.080e-10 ***
Garage.Area    1 9.0206e+10 9.0206e+10   72.9474 < 2.2e-16 ***
Residuals    989 1.2230e+12 1.2366e+09                        
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

With regards to inference for the model, the p-value of the model’s F-statistic indicates that the model as a whole is significant, except for `Overall.Cond`. We need to consider removing this feature.

<h4><b>Section 2.2 Model Selection</b></h4>
We will now consider four different model selection types based on our initial model and verify if they will arrive at the same parsimonious model. 

We will run four different model selection types.</br>
1) P-Value (find the summary statistics at the beginning of this section 2.1)</br>
2) Akaike information criterion (AIC)</br>
3) Bayesian Information Criterion (BIC)</br>
4) Boruta 


```r
# ==========================================================================
# Model selection using Akaike information criterion (AIC)

lm.model <- lm(initial.model,
               data = df.train)

model.AIC <- stepAIC(lm.model, k = 2, trace = FALSE)
model.AIC$anova
```

```
Stepwise Model Path 
Analysis of Deviance Table

Initial Model:
price ~ area + Overall.Qual + Overall.Cond + Year.Built + Exter.Qual + 
    Bsmt.Qual + Lot.Area + Kitchen.Qual + Fireplace.Qu + Garage.Area

Final Model:
price ~ area + Overall.Qual + Overall.Cond + Year.Built + Exter.Qual + 
    Bsmt.Qual + Lot.Area + Kitchen.Qual + Fireplace.Qu + Garage.Area


  Step Df Deviance Resid. Df   Resid. Dev      AIC
1                        989 1.222993e+12 20946.57
```


```r
# ==========================================================================
# Model selection using Bayesian Information Criterion (BIC)

houses.BIC = bas.lm(initial.model,
                    prior = "BIC",
                    modelprior = uniform(),
                    data = df.train)

image.bas(houses.BIC, rotate = FALSE)
```

<img src="figure/unnamed-chunk-14-1.png" title="plot of chunk unnamed-chunk-14" alt="plot of chunk unnamed-chunk-14" style="display: block; margin: auto;" />


```r
set.seed(13)
boruta.model <- Boruta(initial.model, 
                       df.train,
                       maxRuns = 100, 
                       doTrace=0)
print(boruta.model)
```

```
Boruta performed 10 iterations in 3.59938 secs.
 10 attributes confirmed important: area, Bsmt.Qual, Exter.Qual,
Fireplace.Qu, Garage.Area and 5 more;
 No attributes deemed unimportant.
```

```r
Boruta.Final.model <- getConfirmedFormula(boruta.model)

plot(boruta.model)
```

<img src="figure/unnamed-chunk-15-1.png" title="plot of chunk unnamed-chunk-15" alt="plot of chunk unnamed-chunk-15" style="display: block; margin: auto;" />

```r
boruta.median <- data.frame(attStats(boruta.model)[2])
boruta.result <- cbind(rownames(boruta.median), boruta.median)
colnames(boruta.result) <- c('features', 'medianImpact')

boruta.result <- boruta.result %>% arrange(desc(medianImpact))

# add the decision of boruta selection, if a feature is significant to the model
boruta.result$decision <- attStats(boruta.model)['decision']
boruta.result[1:10,]
```

```
       features medianImpact  decision
1          area     30.83027 Confirmed
2   Garage.Area     23.95338 Confirmed
3  Overall.Qual     23.37051 Confirmed
4    Year.Built     21.21460 Confirmed
5  Fireplace.Qu     19.07009 Confirmed
6     Bsmt.Qual     15.90574 Confirmed
7      Lot.Area     15.29527 Confirmed
8  Kitchen.Qual     15.07561 Confirmed
9    Exter.Qual     13.27532 Confirmed
10 Overall.Cond     12.05116 Confirmed
```

What we see from the analysis is, that all 4 model selection methods end up with the same result. The initial model provides p-values, which 
indicate significance for all chosen features. It isn't really surprising that all approaches came to the same conclusion. I chose features, 
which I personally would rely on, if I needed to select a house. But anyway, even if all features are relevant, doesn't per se mean that the 
model as such is good. The chosen features were intuitively chosen and are all important. 

<h4><b>Section 2.3 Initial Model Residuals</b></h4>
One way to assess the performance of a model is to examine the model's residuals. Below, you'll find a residual plot as well as the applied regression line, which indicates the linearity of the data. 


```r
ggplot(data = NULL, aes(x = initial.lm.model$fitted, y = initial.lm.model$residuals)) + 
  geom_point(col = 'darkgreen') + 
  geom_smooth(method = "lm", formula = y ~ splines::bs(x, 3), se = TRUE) + 
  geom_hline(yintercept = 0, linetype = 'dashed', color = 'red')
```

<img src="figure/model_resid-1.png" title="plot of chunk model_resid" alt="plot of chunk model_resid" style="display: block; margin: auto;" />

The plot shows that the residuals are equally variable for medium values of the predicted values, i.e., residuals have a constant variability, while in lower and higher price segments 
the model tends to over estimate. The regression line shows the general trend of the distribution. It also exhibits “heteroscedasticity”, meaning that the residuals get larger as the prediction moves from small to large. There are ways to resolve this. The most successful solution to overcome heteroscedasticity is to transform a variable, or heteroscedasticity often indicates that an important variable is missing. We will use the outcome of this curve in section 3.2 Transformation and 3.3 Variable Interaction, where we decide if we need to apply any type of interaction or transformation. But it right away indicates a quadratic behaviour, which we certainly need to consider.

<h4><b>Section 2.4 Initial Model RMSE</b></h4>
We will now calculate the Root Mean Squared Error based on the model output. 

When we fit a linear regression to a specific data set, many problems may occur. Most common among those are the following: </br>
1) Non linearity of the response - predictor</br>
2) Correlation of error terms</br>
3) Non constant variance of error terms</br>
4) Outliners</br>
5) High leverage point</br>
6) Collinearity</br>

All of the listed factors have an influence on the RMSE of the model. Therefore we will investigate on a few of them. In practice to overcome these problems 
is much of an art as a science. The influence for some of these aspects can be determined from graph below. I won't go through all of them, but certainly address a few.

<b>1) Non linearity from plot below</b></br>
The residual vs. fitted plot (top left) shows a clear non linearity in the residuals. This leads to the conclusion that we need to consider a non linear function.</br>

<b>2) outliners</b></br> 
The residual vs. fitted plot (top left) also shows potential outliners marked by numbers. Removing outliners should be carefully considered. 
With a leverage effect one can create a situation where 1% of your data points affect the slope, which might affect 50% of our data points. I think the best way to start 
is to ask whether the outliers even make sense, especially given the other variables we have in our data set.

<b>3) High leverage point</b></br> 
An influential point is one if removed from the data would significantly change the fit. An influential point may either be an outlier or have large leverage, 
or both, but it will tend to have at least one of those properties. Cook’s distance is a commonly used influence measure that combines these two properties.
The Residual vs. Leverage plot depicts the cook's distance and all the potential leverage points within the boundaries. 
As we can see, there are no <b>high leverage points</b> in our data.

Let me now run an initial analysis by verifying outliners and their impact on the adjusted R^2^ and RMSE. I'll as well investigate the impact on 
adjusted R^2^ and RMSE by applying a log transformation on the response variable.  


```r
predicted <- predict(initial.lm.model, df.train)

RMSE.w_outliner <- rmse(df.train$price, predicted)
adj.r.squared.w_outliner <- summary(initial.lm.model)$adj.r.squared

# ==========================================================================
# Initial Model selection log(price)

formula.log <- as.formula(log(price) ~ area + Overall.Qual + Overall.Cond + 
                            Kitchen.Qual + Year.Built + Bsmt.Qual + Exter.Qual + 
                            Garage.Area + Lot.Area + Fireplace.Qu)

initial.lm.model.log <- lm(formula.log , data = df.train)
adj.r.squared.log.w_outliner <- summary(initial.lm.model.log)$adj.r.squared

predicted.log <- predict(initial.lm.model.log, df.train)
RMSE.log.w_outliner <- rmse(df.train$price, exp(predicted.log))

# ==========================================================================
# This part verifies the impact of the most severe outliners. 
# So we check for outliners. We remove the outliner and re run model
# Afterwards we compare the RMSE and adjusted R Squared. 

df.train <- df.train.NoOutliner

# ==========================================================================
# re run model

initial.lm.model <- lm(initial.model , data = df.train)
adj.r.squared.wo_outliner <- summary(initial.lm.model)$adj.r.squared

predicted <- predict(initial.lm.model, df.train)
RMSE.wo_outliner <- rmse(df.train$price, predicted)

# ==========================================================================
# Initial Model selection log(price)

initial.lm.model.log <- lm(formula.log , data = df.train)
adj.r.squared.log.wo_outliner <- summary(initial.lm.model.log)$adj.r.squared

predicted.log <- predict(initial.lm.model.log, df.train)
RMSE.log.wo_outliner <- rmse(df.train$price, exp(predicted.log))

with_outliner <- c(adj.r.squared.w_outliner, RMSE.w_outliner)
without_outliner <- c(adj.r.squared.wo_outliner, RMSE.wo_outliner)
log.with_outliner <- c(adj.r.squared.log.w_outliner, RMSE.log.w_outliner)
log.without_outliner <- c(adj.r.squared.log.wo_outliner, RMSE.log.wo_outliner)  
R_Squared_RMSE <- data.frame(rbind(with_outliner, without_outliner, log.with_outliner, log.without_outliner))

colnames(R_Squared_RMSE) <- c('adj_R_Squared', 'RMSE')

kable(R_Squared_RMSE[1:2], caption = 'adjusted R-Squared and RMSE')
```



|                     | adj_R_Squared|     RMSE|
|:--------------------|-------------:|--------:|
|with_outliner        |     0.8156869| 34971.32|
|without_outliner     |     0.8308574| 33463.30|
|log.with_outliner    |     0.8518337| 34871.86|
|log.without_outliner |     0.8774398| 28026.33|

Comparing the adjusted R^2^ as well as the RMSE as a quality measure, indicate that removing outliners or the transformation of features indeed show an improvement of the model. 
The Error of predicting housing prices can be reduced from 34'971.32 Dollars down to 28'026.33 Dollars. But we also need to be clear. In this case we used the training data to predict
housing prices and not the test-, or validation data. 

<h4><b>Section 2.5 Overfitting</b></h4>
The process of building a model generally involves starting with an initial model (as we have done above), identifying its shortcomings, and adapting the model accordingly. This process may be repeated several times until the model fits the data reasonably well. However, the model may do well on training data but perform poorly out-of-sample (meaning, on a dataset other than the original training data) because the model is overly-tuned to specifically fit the training data. This is called overfitting. To determine whether overfitting is occurring on our model, we will compare the performance of our model on both in-sample and out-of-sample data sets. 
</br>
<b>Remark:</b></br>
To overcome Overfitting we might also apply a regularization term (L1 or L2) via LASSO or a Ridge regression. This proofed to be helpful and is even easier to apply then getting additional training data or optimizing our model.
Regularization allows to play around with a Lambda term to overcome high bias or variance.


```r
df.train <- df.train.NoOutliner

initial.model  <- as.formula(price ~ area + Overall.Qual + 
                               Overall.Cond + Year.Built + 
                               Exter.Qual +  Bsmt.Qual + 
                               Lot.Area + Kitchen.Qual + 
                               Fireplace.Qu + Garage.Area)

initial.lm.model <- lm(initial.model , data = df.train)

predicted.train <- predict(initial.lm.model, df.train)
RMSE.train <- sqrt( mean((df.train$price - predicted.train)^2))

predicted.test <- predict(initial.lm.model, df.test)
RMSE.test <- sqrt( mean((df.test$price - predicted.test)^2))

# log transform feature area
initial.model.log  <- as.formula(log(price) ~ log(area) + 
                                   Overall.Cond + Overall.Qual + 
                                   Year.Built + Exter.Qual +  Bsmt.Qual + 
                                   Lot.Area + Kitchen.Qual + 
                                   Fireplace.Qu + Garage.Area)

initial.lm.model.log <- lm(initial.model.log , data = df.train)

predicted.train <- predict(initial.lm.model.log, df.train)
RMSE.train.log <- sqrt( mean((df.train$price - exp(predicted.train))^2))

predicted.test <- predict(initial.lm.model.log, df.test)
RMSE.test.log <- sqrt( mean((df.test$price - exp(predicted.test))^2))

Initial.Model <- c(RMSE.train, RMSE.test)
Initial.Model.log <- c(RMSE.train.log, RMSE.test.log)

RMSE.Comp <-data.frame( rbind(Initial.Model, Initial.Model.log))
colnames(RMSE.Comp) <- c('RMSE on train', 'RMSE on test')

kable(RMSE.Comp[1:2], caption = 'RMSE on training and test data')
```



|                  | RMSE on train| RMSE on test|
|:-----------------|-------------:|------------:|
|Initial.Model     |      33463.30|     31238.93|
|Initial.Model.log |      28638.67|     26023.57|

The initial model shows a difference between prediction with training data vs. prediction with test data. The model responds pretty well with the test data. This implies that 
there is no overfitting of the model. Applying some feature transformation also added some advantage as shown in the table.  

<h3><b>Part 3 Development of a Final Model</b></h3>
In the following section we will create a final model with around 20 variables to predict housing prices in Ames, IA, selecting from the full array of variables in the dataset by using the previously applied methods.   

<h4><b>Section 3.1 Final Model</b></h4>
The best model is not always the most complicated. Sometimes including variables that are not evidently important, can actually reduce the accuracy of predictions. In practice, the model that includes all available explanatory variables is often referred to as the full model. The full model may not be the best model, and if it isn't, we want to identify a smaller model that is preferable.

<h4><b>Linear Model stepAIC Evaluation</b></h4>


```r
# ==========================================================================
# Model selection using AIC
df.train <- df.train.NoOutliner

lm.model <- lm(price ~ . ,
               data = df.train)

model.AIC <- stepAIC(lm.model, k = 2, trace = FALSE)
model.AIC$anova
```

```
Stepwise Model Path 
Analysis of Deviance Table

Initial Model:
price ~ area + MS.SubClass + MS.Zoning + Lot.Frontage + Lot.Area + 
    Street + Alley + Lot.Shape + Land.Contour + Lot.Config + 
    Land.Slope + Neighborhood + Condition.1 + Condition.2 + Bldg.Type + 
    House.Style + Overall.Qual + Overall.Cond + Year.Built + 
    Year.Remod.Add + Roof.Matl + Exterior.1st + Exterior.2nd + 
    Mas.Vnr.Type + Mas.Vnr.Area + Exter.Qual + Exter.Cond + Foundation + 
    Bsmt.Qual + Bsmt.Cond + Bsmt.Exposure + BsmtFin.Type.1 + 
    BsmtFin.SF.1 + BsmtFin.Type.2 + BsmtFin.SF.2 + Bsmt.Unf.SF + 
    Total.Bsmt.SF + Heating.QC + Central.Air + Electrical + X1st.Flr.SF + 
    X2nd.Flr.SF + Low.Qual.Fin.SF + Bsmt.Full.Bath + Bsmt.Half.Bath + 
    Full.Bath + Half.Bath + Bedroom.AbvGr + Kitchen.AbvGr + Kitchen.Qual + 
    TotRms.AbvGrd + Functional + Fireplaces + Fireplace.Qu + 
    Garage.Type + Garage.Yr.Blt + Garage.Finish + Garage.Cars + 
    Garage.Area + Garage.Qual + Garage.Cond + Paved.Drive + Wood.Deck.SF + 
    Open.Porch.SF + Enclosed.Porch + X3Ssn.Porch + Screen.Porch + 
    Pool.Area + Pool.QC + Misc.Feature + Misc.Val + Mo.Sold + 
    Yr.Sold + Sale.Type + Sale.Condition

Final Model:
price ~ Lot.Frontage + Lot.Area + Land.Contour + Condition.2 + 
    Bldg.Type + Overall.Qual + Overall.Cond + Year.Built + Exterior.1st + 
    Exterior.2nd + Mas.Vnr.Type + Mas.Vnr.Area + Exter.Qual + 
    Exter.Cond + Bsmt.Qual + Bsmt.Cond + Bsmt.Exposure + BsmtFin.SF.1 + 
    BsmtFin.SF.2 + Bsmt.Unf.SF + Heating.QC + X1st.Flr.SF + X2nd.Flr.SF + 
    Bsmt.Full.Bath + Bedroom.AbvGr + Kitchen.AbvGr + Kitchen.Qual + 
    TotRms.AbvGrd + Functional + Fireplace.Qu + Garage.Type + 
    Garage.Area + Garage.Qual + Wood.Deck.SF + Screen.Porch + 
    Pool.Area + Pool.QC + Sale.Type + Sale.Condition

                Step Df     Deviance Resid. Df   Resid. Dev      AIC
1                                          924 601513335981 20324.53
2  - Low.Qual.Fin.SF  0          0.0       924 601513335981 20324.53
3    - Total.Bsmt.SF  0          0.0       924 601513335981 20324.53
4      - X3Ssn.Porch  1     863173.3       925 601514199154 20322.53
5        - MS.Zoning  1    1893733.0       926 601516092887 20320.53
6        - Half.Bath  1    4018265.1       927 601520111152 20318.54
7          - Mo.Sold  1    6491290.6       928 601526602443 20316.55
8          - Yr.Sold  1    5441003.5       929 601532043446 20314.56
9    - Garage.Yr.Blt  1   11517741.9       930 601543561188 20312.58
10  - Year.Remod.Add  1   14677277.7       931 601558238466 20310.60
11  - Bsmt.Half.Bath  1   31191454.4       932 601589429920 20308.65
12      - Foundation  1   35610188.2       933 601625040109 20306.71
13     - Garage.Cond  1   50847518.5       934 601675887627 20304.80
14      - Lot.Config  1   53674990.8       935 601729562618 20302.89
15    - Misc.Feature  1   75129480.0       936 601804692098 20301.01
16     - Garage.Cars  1  137196165.2       937 601941888263 20299.24
17  - Enclosed.Porch  1  173981147.3       938 602115869410 20297.53
18      - Land.Slope  1  203439156.7       939 602319308567 20295.86
19     - Condition.1  1  238842457.6       940 602558151025 20294.26
20      - Electrical  1  244518716.6       941 602802669741 20292.66
21     - House.Style  1  264766895.8       942 603067436637 20291.10
22      - Fireplaces  1  241933213.7       943 603309369851 20289.50
23  - BsmtFin.Type.2  1  311392010.6       944 603620761861 20288.02
24  - BsmtFin.Type.1  1  338024572.2       945 603958786434 20286.58
25   - Open.Porch.SF  1  391351756.9       946 604350138191 20285.22
26        - Misc.Val  1  379662197.9       947 604729800388 20283.85
27   - Garage.Finish  1  493186972.4       948 605222987361 20282.66
28    - Neighborhood  1  538746881.2       949 605761734242 20281.55
29           - Alley  1  465977512.0       950 606227711754 20280.32
30       - Lot.Shape  1  531403729.4       951 606759115483 20279.19
31     - Central.Air  1  580396540.2       952 607339512024 20278.15
32          - Street  1  749117166.7       953 608088629190 20277.38
33     - Paved.Drive  1  680005230.7       954 608768634421 20276.49
34       - Roof.Matl  1 1151817861.4       955 609920452282 20276.38
35       - Full.Bath  1 1071713536.7       956 610992165819 20276.13
36            - area  1 1105861614.7       957 612098027434 20275.94
37     - MS.SubClass  1 1133631966.3       958 613231659400 20275.78
```

```r
# Final Model: AIC 
Confirmed.model  <- as.formula(price ~ MS.SubClass + Lot.Area + Land.Slope + 
                                 Neighborhood + Condition.2 + Overall.Qual + 
                                 Overall.Cond + Year.Built + Exterior.1st + 
                                 Exterior.2nd + Mas.Vnr.Type + Mas.Vnr.Area + 
                                 Exter.Qual + Exter.Cond + Bsmt.Qual + 
                                 Bsmt.Cond + Bsmt.Exposure + BsmtFin.SF.1 + 
                                 BsmtFin.SF.2 + Bsmt.Unf.SF + Heating.QC + 
                                 X1st.Flr.SF + X2nd.Flr.SF + 
                                 Bsmt.Full.Bath + Bedroom.AbvGr + Kitchen.AbvGr + 
                                 Kitchen.Qual + TotRms.AbvGrd + Fireplaces + 
                                 Garage.Type + Garage.Finish + 
                                 Garage.Area + Garage.Qual + Open.Porch.SF + 
                                 Screen.Porch + Pool.Area + Pool.QC + Sale.Type + 
                                 Sale.Condition)
```

<h4><b>Boruta Evaluation</b></h4>

```r
# ==========================================================================
# Model selection BORUTA 

set.seed(13)
boruta.model <- Boruta(price ~., 
                       df.train,
                       maxRuns = 100, 
                       doTrace=0)
print(boruta.model)
```

```
Boruta performed 99 iterations in 1.651095 mins.
 49 attributes confirmed important: area, Bedroom.AbvGr,
Bldg.Type, Bsmt.Exposure, Bsmt.Full.Bath and 44 more;
 23 attributes confirmed unimportant: Bsmt.Half.Bath,
BsmtFin.SF.2, BsmtFin.Type.2, Condition.1, Condition.2 and 18
more;
 3 tentative attributes left: Alley, Bsmt.Cond, Enclosed.Porch;
```

```r
Boruta.Confirmed.model <- getConfirmedFormula(boruta.model)

plot(boruta.model)
```

<img src="figure/unnamed-chunk-18-1.png" title="plot of chunk unnamed-chunk-18" alt="plot of chunk unnamed-chunk-18" style="display: block; margin: auto;" />

```r
boruta.median <- data.frame(attStats(boruta.model)[2])
boruta.result <- cbind(rownames(boruta.median), boruta.median)
boruta.result <- cbind(boruta.result, attStats(boruta.model)['decision'])

colnames(boruta.result) <- c('features', 'medianImpact', 'decision')
boruta.result <- boruta.result %>% arrange(desc(medianImpact))
boruta.result <- boruta.result %>% dplyr::filter(decision == 'Confirmed')
boruta.result[1:20,]
```

```
         features medianImpact  decision
1            area    19.830450 Confirmed
2    Overall.Qual    16.053871 Confirmed
3     X1st.Flr.SF    15.467542 Confirmed
4   Total.Bsmt.SF    14.934230 Confirmed
5     Garage.Area    14.921523 Confirmed
6     X2nd.Flr.SF    13.792078 Confirmed
7     Garage.Cars    13.587120 Confirmed
8      Year.Built    12.998317 Confirmed
9    BsmtFin.SF.1    11.935547 Confirmed
10   Fireplace.Qu    11.685692 Confirmed
11      Bsmt.Qual    11.360436 Confirmed
12   Kitchen.Qual    11.293990 Confirmed
13  Garage.Yr.Blt    11.259221 Confirmed
14 Year.Remod.Add    10.809912 Confirmed
15     Exter.Qual    10.632935 Confirmed
16     Fireplaces    10.364567 Confirmed
17  TotRms.AbvGrd    10.252002 Confirmed
18       Lot.Area    10.055949 Confirmed
19      Full.Bath     9.263222 Confirmed
20      MS.Zoning     9.081831 Confirmed
```

<b>Bayesian Model Averaging (BMA)</b></br>
A comprehensive approach to address model uncertainty is Bayesian model averaging, which allows us to assess the robustness of results to alternative specifications by calculating posterior distributions over coefficients and models. Given the 81 features (n) there can be 2^n = 2^81 possible models. We will explore model uncertainty using posterior probabilities of models based on BIC. We will use BIC as a way to approximate the log of the marginal likelihood. The Bayesian information criterion (BIC) runs through several fitted model objects for which a log-likelihood value can be obtained, according to the formula -2log-likelihood + nparlog(nobs), where npar represents the number of parameters and nobs the number of observations in the fitted model.

We show the model selection based on two different priors (Bayesian Information Criterion / Zellner-Siow Cauchy), but only print one graph, since both models gave me the same `best` model.


```r
# Bayesian Information Criterion
model.BIC = bas.lm(Confirmed.model,
                    prior = "BIC",
                    modelprior = uniform(),
                    data = df.train)

# Zellner-Siow Cauchy
model.ZS =  bas.lm(Confirmed.model, 
                    df.train,
                    prior="ZS-null",
                    modelprior=uniform(),
                    method = "MCMC", 
                    MCMC.iterations = 10^6) 

image.bas(model.BIC, rotate = FALSE)
```

<img src="figure/unnamed-chunk-19-1.png" title="plot of chunk unnamed-chunk-19" alt="plot of chunk unnamed-chunk-19" style="display: block; margin: auto;" />

We have now features identified with each of the four model selection approaches. Each shows a different set of best features. 
I'll not go into to much details and try to figure out, which might be the best proposed model. I'll rather just decide to continue with the proposed model via Bayesian Model Averaging (BMA). 

We will now tune the model a bit, even if the model has been proposed via BMA model selection. I removed the Pool features, since I have a feeling that those might be useless. The quality of the model will then be verified via Root Mean Squared Error on the test dataset. 


```r
# Final model based on above Model Selection
Final.Model <- as.formula(price ~ Lot.Area + 
                          MS.SubClass   + Overall.Qual + 
                          Overall.Cond  + Year.Built + 
                          Mas.Vnr.Type  + Mas.Vnr.Area + 
                          Exter.Qual    + Exter.Cond + 
                          Bsmt.Exposure + BsmtFin.SF.1 + 
                          BsmtFin.SF.2  + Bsmt.Unf.SF +
                          X1st.Flr.SF   + X2nd.Flr.SF + 
                          Bedroom.AbvGr + Kitchen.AbvGr + 
                          Kitchen.Qual  + TotRms.AbvGrd + 
                          Garage.Type   + Garage.Area + 
                          Pool.Area     + Pool.QC + 
                          Screen.Porch  + Sale.Condition)

# Even if the model has been proposed via Zellner-Siow Cauchy I removed the 
# Pool features, since I just have a feeling that those might be useless

Final.Model.red <- as.formula(price ~ Lot.Area + 
                          MS.SubClass   + Overall.Qual + 
                          Overall.Cond  + Year.Built + 
                          Mas.Vnr.Type  + Mas.Vnr.Area + 
                          Exter.Qual    + Exter.Cond + 
                          Bsmt.Exposure + BsmtFin.SF.1 + 
                          BsmtFin.SF.2  + Bsmt.Unf.SF +
                          X1st.Flr.SF   + X2nd.Flr.SF + 
                          Bedroom.AbvGr + Kitchen.AbvGr + 
                          Kitchen.Qual  + TotRms.AbvGrd + 
                          Garage.Type   + Garage.Area + 
                          Screen.Porch  + Sale.Condition)
```


```r
model.BIC = bas.lm(Final.Model, 
                    prior = "BIC",
                    modelprior = uniform(),
                    data = df.train)

# Zellner-Siow Cauchy
model.ZS =  bas.lm(Final.Model, 
                    df.train,
                    prior="ZS-null",
                    modelprior=uniform(),
                    method = "MCMC", 
                    MCMC.iterations = 10^6) 

model.BIC.red = bas.lm(Final.Model.red, 
                    prior = "BIC",
                    modelprior = uniform(),
                    data = df.train)

# Zellner-Siow Cauchy
model.ZS.red =  bas.lm(Final.Model.red, 
                    df.train,
                    prior="ZS-null",
                    modelprior=uniform(),
                    method = "MCMC", 
                    MCMC.iterations = 10^6) 

par(mfrow = c(2, 2))
plot.bas(model.ZS)
```

<img src="figure/unnamed-chunk-21-1.png" title="plot of chunk unnamed-chunk-21" alt="plot of chunk unnamed-chunk-21" style="display: block; margin: auto;" />

```r
predicted.BIC <- predict.bas(model.BIC, df.test)
predicted.BIC.red <- predict.bas(model.BIC.red, df.test)

predicted.ZS <- predict.bas(model.ZS, df.test)
predicted.ZS.red <- predict.bas(model.ZS.red, df.test)

rmse.bic <- rmse(df.test$price, predicted.BIC$Ybma)
rmse.bic.red <- rmse(df.test$price, predicted.BIC.red$Ybma)
rmse.ZS <- rmse(df.test$price, predicted.ZS$Ybma)
rmse.ZS.red <- rmse(df.test$price, predicted.ZS.red$Ybma)

RMSE <- data.frame(rbind(rmse.bic, rmse.bic.red, rmse.ZS, rmse.ZS.red))
colnames(RMSE) <- c('RMSE')

kable(RMSE[1:1], caption = 'RMSE')
```



|             |     RMSE|
|:------------|--------:|
|rmse.bic     | 24576.48|
|rmse.bic.red | 24248.23|
|rmse.ZS      | 24504.30|
|rmse.ZS.red  | 24170.45|

The model selection procedure proposed the following model. The inclusion probabilities (plot) above indicates that all used parameters are significant. But while looking at the model (god feeling) I figured that the `Pool.Area` and `Pool.QC` features can't have much of a relevance, since most of the houses do not even own a pool. Therefore I removed them and analysed the RMSE again. There is an improvement of the RMSE while removing the pool features.  So i decided to stick with the parameters listed under <b>Decision on Final Model selection</b>. From here on I'll continue with BMA with a Zellner-Siow Cauchy prior.   

<b>Proposed Model with a Zellner-Siow Cauchy prior</b></br>
price ~ Lot.Area + MS.SubClass + Overall.Qual + Overall.Cond + Year.Built + Mas.Vnr.Type + Mas.Vnr.Area + Exter.Qual + </br>
        Exter.Cond + Bsmt.Exposure + BsmtFin.SF.1 + BsmtFin.SF.2 + Bsmt.Unf.SF + X1st.Flr.SF + X2nd.Flr.SF + </br>
        Bedroom.AbvGr + Kitchen.AbvGr + Kitchen.Qual + TotRms.AbvGrd + Garage.Type + Garage.Area + Pool.Area + </br>
        Pool.QC + Screen.Porch + Sale.Condition</br></br>

Based on the calculated RMSE, I came to the following decision and therefore will continue with this model for further investigations: 

<b>Decision on Final Model selection</b></br> 

<b>
price ~ Lot.Area + MS.SubClass + Overall.Qual + Overall.Cond + Year.Built + Mas.Vnr.Type + Mas.Vnr.Area + Exter.Qual + </br>
        Exter.Cond + Bsmt.Exposure + BsmtFin.SF.1 + BsmtFin.SF.2 + Bsmt.Unf.SF + X1st.Flr.SF + X2nd.Flr.SF + Bedroom.AbvGr + </br>
        Kitchen.AbvGr + Kitchen.Qual + TotRms.AbvGrd + Garage.Type + Garage.Area + Screen.Porch + Sale.Condition</b></br>

<b>Coefficient Summaries</b></br>
The summary outputs have been aggregated for convenience purposes. The section shows the marginal posterior mean, standard deviation and posterior inclusion probabilities obtained by BMA. 
 

```r
model.ZS.coef = coef(model.ZS.red)
interval   <- confint(model.ZS.coef)
names <- c("post mean", "post sd", colnames(interval))
interval   <- cbind(model.ZS.coef$postmean, model.ZS.coef$postsd, interval)
colnames(interval) <- names
interval
```

```
                   post mean      post sd        2.5  %       97.5  %
Intercept       1.813552e+05 8.469797e+02  1.796752e+05  1.829893e+05
Lot.Area        5.739898e-01 9.517705e-02  3.961922e-01  7.694372e-01
MS.SubClass    -1.606058e+02 2.640637e+01 -2.113884e+02 -1.097719e+02
Overall.Qual    1.167882e+04 1.180449e+03  9.375050e+03  1.400153e+04
Overall.Cond    5.272058e+03 1.008247e+03  3.391998e+03  7.310647e+03
Year.Built      3.871562e+02 4.807099e+01  2.908071e+02  4.789737e+02
Mas.Vnr.Type   -4.462054e+03 8.443061e+02 -6.125885e+03 -2.826430e+03
Mas.Vnr.Area    5.309315e+01 6.977625e+00  3.985062e+01  6.705756e+01
Exter.Qual      1.702367e+04 2.645056e+03  1.185773e+04  2.232359e+04
Exter.Cond     -3.720011e+03 3.699632e+03 -9.901568e+03  0.000000e+00
Bsmt.Exposure   3.083080e+03 9.487636e+02  1.336203e+03  5.000029e+03
BsmtFin.SF.1    3.700914e+01 6.561570e+00  2.615545e+01  4.833670e+01
BsmtFin.SF.2    8.655922e+00 9.889463e+00  0.000000e+00  2.609057e+01
Bsmt.Unf.SF     8.533822e+00 7.119000e+00  0.000000e+00  1.963130e+01
X1st.Flr.SF     7.079889e+01 7.201386e+00  5.708316e+01  8.414033e+01
X2nd.Flr.SF     6.066704e+01 4.883892e+00  5.168027e+01  7.025055e+01
Bedroom.AbvGr  -1.106461e+04 1.770717e+03 -1.443042e+04 -7.573524e+03
Kitchen.AbvGr  -5.224508e+03 7.340323e+03 -1.984649e+04  3.079930e+00
Kitchen.Qual    8.191554e+03 2.227298e+03  4.070130e+03  1.266225e+04
TotRms.AbvGrd   2.285600e+03 1.823824e+03  0.000000e+00  5.108304e+03
Garage.Type    -3.165249e+03 6.977783e+02 -4.523248e+03 -1.823168e+03
Garage.Area     2.675744e+01 5.522771e+00  1.586338e+01  3.732504e+01
Screen.Porch    5.748324e+01 1.867509e+01  2.265671e+01  9.587130e+01
Sale.Condition -9.443307e+03 5.261228e+03 -1.675405e+04  4.485992e+00
                        beta
Intercept       1.813552e+05
Lot.Area        5.739898e-01
MS.SubClass    -1.606058e+02
Overall.Qual    1.167882e+04
Overall.Cond    5.272058e+03
Year.Built      3.871562e+02
Mas.Vnr.Type   -4.462054e+03
Mas.Vnr.Area    5.309315e+01
Exter.Qual      1.702367e+04
Exter.Cond     -3.720011e+03
Bsmt.Exposure   3.083080e+03
BsmtFin.SF.1    3.700914e+01
BsmtFin.SF.2    8.655922e+00
Bsmt.Unf.SF     8.533822e+00
X1st.Flr.SF     7.079889e+01
X2nd.Flr.SF     6.066704e+01
Bedroom.AbvGr  -1.106461e+04
Kitchen.AbvGr  -5.224508e+03
Kitchen.Qual    8.191554e+03
TotRms.AbvGrd   2.285600e+03
Garage.Type    -3.165249e+03
Garage.Area     2.675744e+01
Screen.Porch    5.748324e+01
Sale.Condition -9.443307e+03
```

<h4><b>Section 3.2 Transformation</b></h4>
Feature engineering is an informal topic, but one that is absolutely known and agreed to be key to success in applied machine learning. With well engineered features, you can choose “the wrong parameters” (less than optimal) and still get good results, for much the same reasons. You do not need to work as hard to pick the right models and the most optimized parameters.

In the previous section we defined the Final Model, which we will use to apply transformations on certain features. We saw earlier that the data indicates a non linearity, as well as 
features not being normal distributed. This are the points we need to address. 

The Residuals plot from section 2.3 indicated clearly a non linearity of the data. Non linearity can be compensated by applying quadratic, log or root transformation to the model.


```r
df.train <- df.train.NoOutliner

# Model Selection without transformation 
Final.Model.base <- as.formula(price ~ Lot.Area + 
                                 MS.SubClass   + Overall.Qual + 
                                 Overall.Cond  + Year.Built + 
                                 Mas.Vnr.Type  + Mas.Vnr.Area + 
                                 Exter.Qual    + Exter.Cond + 
                                 Bsmt.Exposure + BsmtFin.SF.1 + 
                                 BsmtFin.SF.2  + Bsmt.Unf.SF +
                                 X1st.Flr.SF   + X2nd.Flr.SF + 
                                 Bedroom.AbvGr + Kitchen.AbvGr + 
                                 Kitchen.Qual  + TotRms.AbvGrd + 
                                 Garage.Type   + Garage.Area + 
                                 Screen.Porch  + Sale.Condition)

# Model Selection with squared parameter transformation
Final.Model.sqr <- as.formula(price ~ 
                            Lot.Area      + I(Lot.Area^2) + 
                            MS.SubClass   + I(MS.SubClass^2) + 
                            Overall.Qual  + Overall.Cond + 
                            Year.Built    + Mas.Vnr.Type + 
                            Mas.Vnr.Area  + I(Mas.Vnr.Area^2) + 
                            Exter.Qual    + Exter.Cond    + 
                            Bsmt.Exposure + 
                            BsmtFin.SF.1  + I(BsmtFin.SF.1^2) + 
                            BsmtFin.SF.2  + I(BsmtFin.SF.2^2) + 
                            Bsmt.Unf.SF   + 
                            X1st.Flr.SF   + I(X1st.Flr.SF^2) +         
                            X2nd.Flr.SF   + I(X2nd.Flr.SF^2) +  
                            Bedroom.AbvGr + I(Bedroom.AbvGr^2) +
                            Kitchen.AbvGr + 
                            Kitchen.Qual  + TotRms.AbvGrd + 
                            Garage.Type   + Garage.Area + 
                            Screen.Porch  + I(Screen.Porch^2) + 
                            Sale.Condition)

# Model Selection with squared- and log transformed parameters
Final.Model.Sqr_and_Log <- as.formula(log(price) ~ 
                            log(Lot.Area) + I(Lot.Area^2) + 
                            MS.SubClass   + I(MS.SubClass^2) + 
                            Overall.Qual  + Overall.Cond + 
                            Year.Built    + Mas.Vnr.Type + 
                            Mas.Vnr.Area  + I(Mas.Vnr.Area^2) + 
                            Exter.Qual    + Exter.Cond    + 
                            Bsmt.Exposure + 
                            BsmtFin.SF.1  + I(BsmtFin.SF.1^2) + 
                            BsmtFin.SF.2  + I(BsmtFin.SF.2^2) + 
                            Bsmt.Unf.SF   + 
                            X1st.Flr.SF   + I(X1st.Flr.SF^2) +         
                            X2nd.Flr.SF   + I(X2nd.Flr.SF^2) +  
                            Bedroom.AbvGr + I(Bedroom.AbvGr^2) +
                            Kitchen.AbvGr + 
                            Kitchen.Qual  + TotRms.AbvGrd + 
                            Garage.Type   + Garage.Area + 
                            Screen.Porch  + I(Screen.Porch^2) + 
                            Sale.Condition)

# Bayesian Model Averaging with Zellner-Siow Cauchy prior 
# on the final base model
model.ZS.base =  bas.lm(Final.Model.base, 
                         df.train,
                         prior="ZS-null",
                         modelprior=uniform(),
                         method = "MCMC", 
                         MCMC.iterations = 10^6) 

# Bayesian Model Averaging with Zellner-Siow Cauchy prior 
# on the final squared model
model.ZS.sqr =  bas.lm(Final.Model.sqr, 
                        df.train,
                        prior="ZS-null",
                        modelprior=uniform(),
                        method = "MCMC", 
                        MCMC.iterations = 10^6) 

# Bayesian Model Averaging with Zellner-Siow Cauchy prior 
# on the final squared and log transformed model
model.ZS.sqr_log =  bas.lm(Final.Model.Sqr_and_Log, 
                   df.train,
                   prior="ZS-null",
                   modelprior=uniform(),
                   method = "MCMC", 
                   MCMC.iterations = 10^6) 

par(mfrow = c(2, 2))
plot(model.ZS.base, which = 1)
plot(model.ZS.sqr, which = 1)
plot(model.ZS.sqr_log, which = 1)

predicted.ZS.base    <- predict.bas(model.ZS.base, df.test)
predicted.ZS.sqr     <- predict.bas(model.ZS.sqr, df.test)
predicted.ZS.sqr_log <- predict.bas(model.ZS.sqr_log, df.test)

prediction <- data.frame(cbind( predicted.ZS.base$Ybma, predicted.ZS.sqr$Ybma, predicted.ZS.sqr_log$Ybma))
prediction <- cbind(prediction, df.test$price)
names(prediction) <- c( 'Base', 'SQR', 'SQL LOG', 'Price')

rmse.ZS.base <- rmse(df.test$price, predicted.ZS.base$Ybma)
rmse.ZS.sqr <- rmse(df.test$price, predicted.ZS.sqr$Ybma)
rmse.ZS.sqr_log <- rmse(df.test$price, exp(predicted.ZS.sqr_log$Ybma))

RMSE <- data.frame(rbind(rmse.ZS.base, rmse.ZS.sqr, rmse.ZS.sqr_log))
colnames(RMSE) <- c('RMSE')

kable(RMSE[1:1], caption = 'RMSE on test data')
```



|                |     RMSE|
|:---------------|--------:|
|rmse.ZS.base    | 24172.57|
|rmse.ZS.sqr     | 22256.14|
|rmse.ZS.sqr_log | 19214.49|

<img src="figure/unnamed-chunk-23-1.png" title="plot of chunk unnamed-chunk-23" alt="plot of chunk unnamed-chunk-23" style="display: block; margin: auto;" />

The graph above shows 3 plots. Plot 1 only uses the plain formula. Plot 2 has some quadratic elements attached, while plot 3 uses quadratic as well as logarithmic elements. The 3 residual plots show clearly how the regression line levels out (from bow shaped to a straight line) by using quadratic or logarithmic and quadratic functions.   

Therefore, we will apply quadratic as well as logarithmic functions for some of the features. A Log transformation has been applied with the response variable <b>price</b> and the explanatory variable <b>Lot.Area</b> to get a normal distribution in the data, while the features <b>Lot.Area / MS.SubClass / Mas.Vnr.Area / BsmtFin.SF.1 / BsmtFin.SF.2 / X1st.Flr.SF / X2nd.Flr.SF / Bedroom.AbvGr / Screen.Porch</b> have been squared to overcome the non linearity. By reducing the non linearity we are able to reduce the RMSE of the model.
The table above indicates that we were able to constantly reduce the RMSE by applying the quadratic and log functions. That is now exactly the time where we need to investigate a little further by using the validation dataset. I did that and came to the conclusion to use both aspects - quadratic and log functions. Results with the validation set will be discussed in section 4.1.

<h4><b>Section 3.3 Variable Interaction</b></h4>
We now will investigate if we need to apply any interaction variables. For that purpose we will investigate on how much multicollinearity (correlation between predictors) exists in our regression model via Variance inflation factors (VIF). Multicollinearity is problematic because it can increase the variance of the regression coefficients, making them unstable and difficult to interpret. Variance inflation factors (VIF) measure how much the variance of the estimated regression coefficients are inflated as compared to when the predictor variables are not linearly related.

Variance inflation factor is calculated via the following function:

$$VIF_{k} = \frac{1}{1 - R^2}$$

Use the following guidelines to interpret the VIF:

  VIF              | Status of predictors  |                  
  -----------------|-----------------------|
  VIF = 1          | Not correlated        | 
  1 < VIF < 5      | Moderately correlated |
  VIF > 5 to 10    | Highly correlated     | 



```r
df.train <- df.train.NoOutliner

Final.Model.base <- as.formula(price ~ Lot.Area + 
                                 MS.SubClass   + Overall.Qual + 
                                 Overall.Cond  + Year.Built + 
                                 Mas.Vnr.Type  + Mas.Vnr.Area + 
                                 Exter.Qual    + Exter.Cond + 
                                 Bsmt.Exposure + BsmtFin.SF.1 + 
                                 BsmtFin.SF.2  + Bsmt.Unf.SF +
                                 X1st.Flr.SF   + X2nd.Flr.SF + 
                                 Bedroom.AbvGr + Kitchen.AbvGr + 
                                 Kitchen.Qual  + TotRms.AbvGrd + 
                                 Garage.Type   + Garage.Area + 
                                 Screen.Porch  + Sale.Condition)

vif(lm(Final.Model.base, df.train))
```

```
      Lot.Area    MS.SubClass   Overall.Qual   Overall.Cond     Year.Built 
      1.197906       1.503877       3.622547       1.455916       2.753765 
  Mas.Vnr.Type   Mas.Vnr.Area     Exter.Qual     Exter.Cond  Bsmt.Exposure 
      1.918035       2.241271       3.162982       1.191252       1.304135 
  BsmtFin.SF.1   BsmtFin.SF.2    Bsmt.Unf.SF    X1st.Flr.SF    X2nd.Flr.SF 
      4.920668       1.571143       4.427113       5.745823       4.092895 
 Bedroom.AbvGr  Kitchen.AbvGr   Kitchen.Qual  TotRms.AbvGrd    Garage.Type 
      2.477266       1.620652       2.570608       4.452934       1.637755 
   Garage.Area   Screen.Porch Sale.Condition 
      1.980269       1.052840       1.039249 
```

The figures above indicates that all of our features are moderately correlated. </br>
<b>Therefore, we decide not to include any variable interactions.</b>

<h4><b>Section 3.4 Variable Selection</b></h4>
I went through various steps to identify the final model. The method used is just one part of the story. Feature engineering, cleaning and recoding of the data is one of the major tasks on the route to select the best model. Having finalized the cleaning, I used multiple approaches to select the 
final model. The approaches are listed below:

  1) Feature engineering</br>
  2) Model Selection</br>
     2.1) Bayesian Model Averaging (Bayesian Information Criterion / Zellner-Siow Cauchy)</br>
     2.2) Akaike information criterion (AIC)</br>
     2.3) Boruta</br>
     2.4) Removed some features out of got feeling (experience.. I wouldn't attest that for me)</br>
  3) Model Tuning</br>
     3.1) Apply quadratic / log transformation</br>
  4) Model validation</br>

Each used approach came out with a different "best" model. So we needed compare the different models to finally identify the best model.

The final Model is the following:</br>
<b>
log(price) ~ log(Lot.Area) + I(Lot.Area^2) + MS.SubClass + I(MS.SubClass^2) + Overall.Qual + Overall.Cond + 
             Year.Built + Mas.Vnr.Type + Mas.Vnr.Area + I(Mas.Vnr.Area^2) + Exter.Qual + Exter.Cond + 
             Bsmt.Exposure + BsmtFin.SF.1  + I(BsmtFin.SF.1^2) + BsmtFin.SF.2  + I(BsmtFin.SF.2^2) + 
             Bsmt.Unf.SF + X1st.Flr.SF   + I(X1st.Flr.SF^2) + X2nd.Flr.SF + I(X2nd.Flr.SF^2) +  
             Bedroom.AbvGr + I(Bedroom.AbvGr^2) + Kitchen.AbvGr + Kitchen.Qual + TotRms.AbvGrd + 
             Garage.Type + Garage.Area + Screen.Porch + I(Screen.Porch^2) + Sale.Condition
</b>

<h4><b>Section 3.5 Model Testing</b></h4>
The parsimonious model proposed in `section 3.1 Final Model` was used as initial model to run initial predictions on the test data set. 
The comparison of the RMSE by using both training- and test data, while predicting house prices indicated that the model was not overfitting. 

Changes have taken place towards removing certain features (e.g. Pool.Area and Pool.QC), which proofed to be useless. I also went back to change 
features (e.g. Sale.Condition etc.), by clustering parameter values. `Abnormal` has been set to 1, while all others have been set to 0. This also improved 
the performance. Then I focused on the `non - linearity` of the model. I applied quadratic and log transformation to certain (e.g. Lot.Area, BsmtFin.SF.1, 
X1st.Flr.SF etc.) as indicated above. All this measures helped to improve the performance. But I reckon there is still more to the story.

The evaluation on the model has mainly been performed via the <b>Root Mean Squared Error</b>. 

<h3><b>Part 4 Final Model Assessment</b></h3>
<h4><b>Section 4.1 Final Model Residual</b></h4>


```r
df.train <- df.train.NoOutliner

# Model Selection with squared and log transformation
Final.Model <- as.formula(log(price) ~ 
                            log(Lot.Area) + I(Lot.Area^2) + 
                            MS.SubClass   + I(MS.SubClass^2) + 
                            Overall.Qual  + Overall.Cond + 
                            Year.Built    + Mas.Vnr.Type + 
                            Mas.Vnr.Area  + I(Mas.Vnr.Area^2) + 
                            Exter.Qual    + Exter.Cond    + 
                            Bsmt.Exposure + 
                            BsmtFin.SF.1  + I(BsmtFin.SF.1^2) + 
                            BsmtFin.SF.2  + I(BsmtFin.SF.2^2) + 
                            Bsmt.Unf.SF   + 
                            X1st.Flr.SF   + I(X1st.Flr.SF^2) +         
                            X2nd.Flr.SF   + I(X2nd.Flr.SF^2) +  
                            Bedroom.AbvGr + I(Bedroom.AbvGr^2) +
                            Kitchen.AbvGr + 
                            Kitchen.Qual  + TotRms.AbvGrd + 
                            Garage.Type   + Garage.Area + 
                            Screen.Porch  + I(Screen.Porch^2) + 
                            Sale.Condition)

# Bayesian Model Averaging with Zellner-Siow Cauchy prior 
# on the final model
model.ZS =  bas.lm(Final.Model, 
                        df.train,
                        prior="ZS-null",
                        modelprior=uniform(),
                        method = "MCMC", 
                        MCMC.iterations = 10^6) 

plot(model.ZS, which = 1)
```

<img src="figure/unnamed-chunk-24-1.png" title="plot of chunk unnamed-chunk-24" alt="plot of chunk unnamed-chunk-24" style="display: block; margin: auto;" />

The plot has been shown already in section 3.2, where we investigated on the feature transformation. As one can see, the residuals plot shows a nearly straight regression line, which means that we were able to compensate the non linearity of our data. So far we managed to establish a decent model by introducing quadratic and log transformed features.
There is certainly still potential in optimizing our model, by optimizing the strategy for using NA values or creating new features.

<h4><b>Section 4.2 Final Model RMSE</b></h4>
We will now calculate the Root Mean Squared Error (RMSE) of our final model on the test dataset.


```r
df.train <- df.train.NoOutliner

# Model Selection with squared and log transformation
Final.Model <- as.formula(log(price) ~ 
                            log(Lot.Area) + I(Lot.Area^2) + 
                            MS.SubClass   + I(MS.SubClass^2) + 
                            Overall.Qual  + Overall.Cond + 
                            Year.Built    + Mas.Vnr.Type + 
                            Mas.Vnr.Area  + I(Mas.Vnr.Area^2) + 
                            Exter.Qual    + Exter.Cond    + 
                            Bsmt.Exposure + 
                            BsmtFin.SF.1  + I(BsmtFin.SF.1^2) + 
                            BsmtFin.SF.2  + I(BsmtFin.SF.2^2) + 
                            Bsmt.Unf.SF   + 
                            X1st.Flr.SF   + I(X1st.Flr.SF^2) +         
                            X2nd.Flr.SF   + I(X2nd.Flr.SF^2) +  
                            Bedroom.AbvGr + I(Bedroom.AbvGr^2) +
                            Kitchen.AbvGr + 
                            Kitchen.Qual  + TotRms.AbvGrd + 
                            Garage.Type   + Garage.Area + 
                            Screen.Porch  + I(Screen.Porch^2) + 
                            Sale.Condition)

# Bayesian Model Averaging with Zellner-Siow Cauchy prior 
# on the final model
final.model.ZS =  bas.lm(Final.Model, 
                   df.train,
                   prior="ZS-null",
                   modelprior=uniform(),
                   method = "MCMC", 
                   MCMC.iterations = 10^6) 

predicted.ZS.final    <- predict.bas(final.model.ZS, df.test)
rmse.ZS <- rmse(df.test$price, exp(predicted.ZS.final$Ybma))

RMSE <- data.frame(rbind(rmse.ZS))
colnames(RMSE) <- c('RMSE')

kable(RMSE[1:1], caption = 'RMSE on Test data')
```



|        |     RMSE|
|:-------|--------:|
|rmse.ZS | 19207.34|

The RMSE value we have with the current model needs to be considered in the context of the initial model we started with in section 2.4. There we had an RMSE of around 34'971 dollar on the training data, where the current model shows an RMSE of around 19'207 dollar on a predicted house (on test data). Comparing those figures we improved our model by almost 50%, which is quite substantial. A real live test with validation data,  will give us the final confirmation if our model will fulfil it's duty. One thing to mention is the importance of feature engineering and model selection in the process of defining a model.

<h4><b>Section 4.3 Final Model Evaluation</b></h4>

<b>Strengths of the final model</b></br>
<ol>
  <li>I spent quite some time for the feature engineering part. Applied some cleaning of outliners and high leverage points (Cook distance). 
  But it finally proved to be helpful to get a more robust model.</li>
  <li>Model Selection has been performed towards the <b>parsimonious model</b>. The model with the lowest number of features has been used. But I also went a step further to 
  remove certain features to reduce the model complexity.</li>
  <li>Multicollinearity has been avoided by verifying features via Variance inflation factors.</li>
  <li>Feature transformation has been applied to compensate the non linearity of the model</li>
  <li>the model properly reflect uncertainty confirmed by determining the coverage probability and the true value of price that fall within the 95% prediction confidence interval is 97%</li>
  <li>The final model has proofed to have the smallest RMSE during real life (validation) tests. The lower the RMSE the better the model.</li>
</ol>

<b>Weaknesses of Final Model</b>
<ol>
<li>Although I invested a lot of time in feature engineering, there is a lot more to get out of it. Especially the strategy of filling the missing data. One can apply a more sophisticated 
approach then I did.</li>
<li>Features, which are available could be clustered to be more informative (e.g. Sale Condition - Normal and Not normal)</li>
<li>I also believe there are some features, which I reckon have some relevance, but could not proof it (combination of features) </li>
</ol>

<h4><b>Section 4.4 Final Model Validation</b></h4>
Testing our final model on a separate, validation data set is a great way to determine how our model will perform in real-life practice. 

<b>Visual interpretation of Residuals, Leverage and Q-Q plot</b> 

```r
df.train <- df.train.NoOutliner

# Model Selection 
Final.Model <- as.formula(log(price) ~ 
                            log(Lot.Area) + I(Lot.Area^2) + 
                            MS.SubClass   + I(MS.SubClass^2) + 
                            Overall.Qual  + Overall.Cond + 
                            Year.Built    + Mas.Vnr.Type + 
                            Mas.Vnr.Area  + I(Mas.Vnr.Area^2) + 
                            Exter.Qual    + Exter.Cond    + 
                            Bsmt.Exposure + 
                            BsmtFin.SF.1  + I(BsmtFin.SF.1^2) + 
                            BsmtFin.SF.2  + I(BsmtFin.SF.2^2) + 
                            Bsmt.Unf.SF   + 
                            X1st.Flr.SF   + I(X1st.Flr.SF^2) +         
                            X2nd.Flr.SF   + I(X2nd.Flr.SF^2) +  
                            Bedroom.AbvGr + I(Bedroom.AbvGr^2) +
                            Kitchen.AbvGr + 
                            Kitchen.Qual  + TotRms.AbvGrd + 
                            Garage.Type   + Garage.Area + 
                            Screen.Porch  + I(Screen.Porch^2) + 
                            Sale.Condition)

model.lm <- lm(Final.Model, df.train)

par(mfrow = c(2, 2))
plot(model.lm, col = 'steelblue')
```

<img src="figure/loadvalidation-1.png" title="plot of chunk loadvalidation" alt="plot of chunk loadvalidation" style="display: block; margin: auto;" />
Consulting the plots above again, we see that the `Residual vs. Fitted` plot shows almost a straight line. A Q-Q plot is a scatterplot created by plotting two sets of quantiles against one another. If both sets of quantiles came from the same distribution, we should see the points forming a line that’s roughly straight. This is not entirely for our distribution. Therefore, our model still shows improvement potential.
If we look at the `Residuals vs Leverage`, which provides a visual interpretation of high leverage points via the Cook's distance, we see that all our data points lay within the boundaries. 
</br></br>
<b>Comparing RMSE with training-, test and validation data applied</b> 


```r
# Predict and calculate RMSE on training data 
predicted.train <- predict(model.lm, df.train)
RMSE.train <- rmse(df.train$price, exp(predicted.train))

# Predict and calculate RMSE on test data 
predicted.test <- predict(model.lm, df.test)
RMSE.test <- rmse(df.test$price, exp(predicted.test))

# Predict and calculate RMSE on validation data 
predicted.validation <- predict(model.lm, df.validation)
RMSE.validation <- rmse(df.validation$price, exp(predicted.validation))

RMSE <- data.frame(rbind(RMSE.train, RMSE.test, RMSE.validation))
colnames(RMSE) <- c('RMSE')
kable(RMSE[1:1], caption = 'RMSE')
```



|                |     RMSE|
|:---------------|--------:|
|RMSE.train      | 21810.61|
|RMSE.test       | 18630.00|
|RMSE.validation | 18817.73|

The final model evaluation states a quite nice picture as you can see from the table above. The Root Mean Squared Error (RMSE), 
which is at around 21'810 Dollar, while calculating the RMSE based on training data. The RMSE slightly drops With the test data (Dollar - 18'630), but using the real-life (validation) data, our model shows slight rise of the  RMSE (Dollar - 18'817). In general, the lower the RMSE, the better the model fit. Therefore, our final model is a better fitted for validation data. 
</br></br>
<b>Under- and Overvalued houses</b></br>
Which houses will be Under- and Overvalued by our model. To answer this question we need to have a look at the <b>Residuals vs Fitted</b> plot. The plot can be separated into 2 areas - lower 25% and medium to higher (75%) sections. Houses in the lower price segment (25%) will slightly be over valued. This is obvious, since we have a slight non linearity in this area. Housing prices in the mid and high range should be pretty precise, since we have almost a straight regression line. 
</br></br>
<b>Coverage of true values</b></br>

```r
final.prediction <- predict(model.lm, df.validation, interval = "prediction", level = 0.95)
coverage <- mean(df.validation$price > exp(final.prediction[,"lwr"]) & df.validation$price < exp(final.prediction[,"upr"]))
coverage
```

```
[1] 0.9750329
```
The uncertainty respectively the coverage has been calculated, to assess if the we met the 95% confidence interval containing the true value of the houses.
The calculation of the 95% confidence interval reveals that the true value of housing prices is met in around <b>97%</b> of the cases. That means, this final model properly reflects the uncertainty.

<h3><b>Part 5 Conclusion</b></h3>

The data set at hand was used to gather deep insight on the key characteristics that can influence sales prices of a homes in Ames, Iowa. The stepwise approach in analysing data thoroughly, deriving information from it towards data transformation to reach a decent result at the end, is quite a journey. Feature engineering, cleaning and recoding of the data proofed to be one of the major tasks on the route to select the best model. I also experienced that this is one of the most time consuming parts in designing a model. 
The Model selection process by using multiple approaches gave me a deep insight in the diverse selection methods. To me it was helpful to start with an initial model to get a feeling, respectively get a reference point to start with. Constantly measuring the improvement of the model via <b>adjusted R^2^2, Root Mean Squared Error</b> or visual representations as <b>Residual vs. Fitted</b> plots is vital to understand the behaviour of each change on the model. There was one ‘aha’ effect I had, when I went into investigating the impact of outliners and high leverage points. Removing 2 outliners from the whole data set changed the initial parsimonious model to a new parsimonious model. I didn’t expect 2 data points having such an impact.
My fundamental learning in this assessment was that getting the best model wasn’t primarily driven by the model I used. It was rather driven by managing outliners, high leverage points, feature engineering and transformation. In those areas lies the real potential to get a good model. 
Following a stepwise approach (improving and constantly measuring) by using the mentioned approaches in cooperation with the Bayesian Model Averaging approach, we were able to find a robust model.
If we compare where we started off with the initial model (RMSE: 34’971 Dollars – on training data) and where we ended (RMSE: 18’630 Dollars on test data and 18’817 Dollars on validation data), we were able to improve our model by close to 50%. It was a tremendous journey which gave me lots of learnings.

<h3><b>Appendix</b></h3>
<h4><b>Helper Functions</b></h4> 
The following functions were produced to fullfill certain recurring tasks, which have been used during this assessment.


```r
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
  df$Bsmt.Qual      <- recode(df$Bsmt.Qual, 'none')
  df$Bsmt.Cond      <- recode(df$Bsmt.Cond, 'none')
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
  
 # TODO
 # Year Built 
  
  return(df)
}
```


```r
# ================================================================================
# Map features to numerical values
#
# Params: df    - data set to convert
#
# Return: df    - converted dataset
recode.features <- function(df){
  
  # Map features to numerical values
  feature.list = c('Exter.Qual', 'Exter.Cond', 'Garage.Qual', 'Garage.Cond', 
                   'Fireplace.Qu', 'Kitchen.Qual', 'Heating.QC', 'Bsmt.Qual', 
                   'Bsmt.Cond', 'Pool.QC' )
  param.list = c('none' = 0, 'Po' = 1, 'Fa' = 2, 'TA' = 3, 'Gd' = 4, 'Ex' = 5)
  df <- map.fcn(feature.list, param.list, df)
  
  param.list = c('none' = 0, 'No' = 1, 'Mn' = 2, 'Av' = 3, 'Gd' = 4)
  data.train <- map.fcn(c('Bsmt.Exposure'), param.list, df)
  
  feature.list = c('BsmtFin.Type.1','BsmtFin.Type.2')
  param.list = c('none' = 0, 'Unf' = 1, 'LwQ' = 2,'Rec'= 3, 'BLQ' = 4, 
                 'ALQ' = 5, 'GLQ' = 6)
  df = map.fcn(feature.list, param.list, df)
  
  param.list = c('None' = 0, 'Sal' = 1, 'Sev' = 2, 'Maj2' = 3, 'Maj1' = 4, 
                 'Mod' = 5, 'Min2' = 6, 'Min1' = 7, 'Typ'= 8)
  df = map.fcn(c('Functional'), param.list, df)
  
  param.list = c('none' = 0,'Unf' = 1, 'RFn' = 2, 'Fin' = 3)
  df = map.fcn(c('Garage.Finish'), param.list, df)
  
  param.list = c('none' = 0, 'MnWw' = 1, 'GdWo' = 2, 'MnPrv' = 3, 
                 'GdPrv' = 4)
  df = map.fcn(c('Fence'), param.list, df)
  
  param.list = c('none' = 0, 'Shed' = 1, 'Othr' = 2, 'Gar2' = 3, 
                 'Elev' = 4, 'TenC' = 5)
  df = map.fcn(c('Misc.Feature'), param.list, df)
  
  param.list = c('none' = 0, 'CarPort' = 1, 'Detchd' = 2, 'BuiltIn' = 3, 
                 'Basment' = 4, 'Attchd' = 5, '2Types' = 6)
  df = map.fcn(c('Garage.Type'), param.list, df)
  
  param.list = c('None' = 0, 'Stone' = 1, 'CBlock' = 2, 'BrkFace' = 3, 
                 'BrkCmn' = 4)
  df = map.fcn(c('Mas.Vnr.Type'), param.list, df)
  
  param.list = c('none' = 0, 'Grvl' = 1, 'Pave' = 2)
  df = map.fcn(c('Alley'), param.list, df)

  param.list = c('none' = 0, 'ELO' = 1, 'NoSewr' = 2, 'NoSeWa' = 3, 
                 'AllPub' = 4)
  df = map.fcn(c('Utilities'), param.list, df)
  
  param.list = c('none' = 1, 'N' = 1, 'P' = 2, 'Y' = 3)
  df = map.fcn(c('Paved.Drive'), param.list, df)
  
  param.list = c('none' = 0, 'N' = 0,'Y' = 1)
  df = map.fcn(c('Central.Air'), param.list, df)

  param.list = c('none' = 1, 'Grvl' = 1,'Pave' = 2)
  df = map.fcn(c('Street'), param.list, df)

  param.list = c('none' = 0, 'No' = 1, 'Mn' = 2, 'Gd' = 3, 'Av' = 4)
  df = map.fcn(c('Bsmt.Exposure'), param.list, df)
  
  param.list = c('none' = 1, 'Inside' = 1, 'Corner' = 2, 'CulDSac' = 3, 
                 'CulDSac' = 4, 'FR2' = 5, 'FR3' = 6)
  df = map.fcn(c('Lot.Config'), param.list, df)
  
  param.list = c('none' = 1, 'A (all)' = 1, 'C (all)' = 2, 'RM' = 3, 'FV' = 4, 
                 'RH' = 5, 'RP' = 6, 'I (all)' = 7, 'RL' = 8)
  df = map.fcn(c('MS.Zoning'), param.list, df)
  
  param.list = c('none' = 1, 'Gtl' = 1, 'Mod' = 2, 'Sev' = 3)
  df = map.fcn(c('Land.Slope'), param.list, df)
  
  param.list = c('none' = 1, 'Reg' = 1, 'IR1' = 2, 'IR2' = 3, 'IR3' = 4)
  df = map.fcn(c('Lot.Shape'), param.list, df)
  
  param.list = c('none' = 1, 'Lvl' = 1, 'Low' = 2, 'HLS' = 3, 'Bnk' = 4)
  df = map.fcn(c('Land.Contour'), param.list, df)

  param.list = c('none' = 1, 'Normal' = 1, 'Partial' = 2, 'AdjLand' = 3, 
                 'Abnorml' = 4, 'Alloca' = 5, 'Family' = 6)
  df = map.fcn(c('Sale.Condition'), param.list, df)
  
  param.list = c('none' = 10, 'COD' = 1, 'Con' = 2, 'ConLD' = 3, 'ConLI' = 4, 
                 'ConLw' = 5, 'CWD' = 6, 'New' = 7, 'Oth' = 8, 'VWD' = 9, 'WD ' = 10)
  df = map.fcn(c('Sale.Type'), param.list, df)
  
  param.list = c('none' = 5, 'FuseA' = 1, 'FuseF' = 2, 'FuseP' = 3, 'Mix' = 4, 
                 'SBrkr' = 5)
  df = map.fcn(c('Electrical'), param.list, df)
  
  param.list = c('none' = 2, 'Floor' = 1, 'GasA' = 2, 'GasW' = 3, 'Grav' = 4, 
                 'OthW' = 5, 'Wall' = 6 )
  df = map.fcn(c('Heating'), param.list, df)
  
  param.list = c('none' = 3, 'BrkTil' = 1, 'CBlock' = 2, 'PConc' = 3, 'Slab' = 4, 
                 'Stone' = 5, 'Wood' = 6 )
  df = map.fcn(c('Foundation'), param.list, df)
  
  param.list = c('none' = 15, 'AsbShng' = 1, 'AsphShn' = 2, 'BrkComm' = 3, 
                 'BrkFace' = 4, 'CBlock' = 5, 'CemntBd' = 6, 'HdBoard' = 7, 
                 'ImStucc' = 8, 'MetalSd' = 9, 'Other' = 10, 'Plywood' = 11,
                 'PreCast' = 12, 'Stone' = 13, 'Stucco' = 14, 'VinylSd' = 15, 
                 'Wd Sdng' = 16, 'WdShing' = 17, 'Wd Shng' = 18)
  df <- map.fcn('Exterior.1st', param.list, df)
  
  param.list = c('none' = 15, 'AsbShng' = 1, 'AsphShn' = 2, 'Brk Cmn' = 3, 
                 'BrkFace' = 4, 'CBlock' = 5, 'CmentBd' = 6, 'HdBoard' = 7, 
                 'ImStucc' = 8, 'MetalSd' = 9, 'Other' = 10, 'Plywood' = 11,
                 'PreCast' = 12, 'Stone' = 13, 'Stucco' = 14, 'VinylSd' = 15, 
                 'Wd Sdng' = 16, 'Wd Shng' = 17
  )
  df <- map.fcn('Exterior.2nd', param.list, df)
  
  feature.list = c('Condition.1', 'Condition.2')
  param.list = c('none' = 3, 'Artery' = 1, 'Feedr' = 2, 'Norm' = 3, 'RRNn' = 4, 
                 'RRAn' = 5, 'PosN' = 6, 'PosA' = 7, 'RRNe' = 8, 'RRAe' = 9)
  df <- map.fcn(feature.list, param.list, df)
  
  param.list = c('none' = 2, 'Flat' = 1, 'Gable' = 2, 'Gambrel' = 3, 'Hip' = 4, 
                 'Mansard' = 5, 'Shed' = 6 )
  df = map.fcn(c('Roof.Style'), param.list, df)
  
  param.list = c('none' = 2, 'ClyTile' = 1, 'CompShg' = 2, 'Membran' = 3, 
                 'Metal' = 4, 'Roll' = 5, 'Tar&Grv' = 6, 'WdShake' = 7, 
                 'WdShngl' = 8)
  df = map.fcn(c('Roof.Matl'), param.list, df)
  
  param.list = c('none' = 1, '1Fam' = 1, '2fmCon' = 2, 'Duplex' = 3, 'TwnhsE' = 4, 
                 'TwnhsI' = 5, 'Twnhs' = 6)
  df = map.fcn(c('Bldg.Type'), param.list, df)
  
  param.list = c('none' = 1, '1Story' = 1, '1.5Fin' = 2, '1.5Unf' = 3, '2Story' = 4, 
                 '2.5Fin' = 5, '2.5Unf' = 6, 'SFoyer' = 7, 'SLvl' = 8)
  df = map.fcn(c('House.Style'), param.list, df)
  
  param.list = c('none' = 1, 'Blmngtn' = 1, 'Blueste' = 2, 'BrDale' = 3, 
                 'BrkSide' = 4, 'ClearCr' = 5, 'CollgCr' = 6, 'Crawfor' = 7, 
                 'Edwards' = 8, 'Gilbert' = 9, 'Greens' = 10, 'GrnHill' = 11,
                 'IDOTRR' = 12, 'Landmrk' = 13, 'MeadowV' = 14, 'Mitchel' = 15, 
                 'NAmes' = 16, 'NoRidge' = 17, 'NPkVill' = 18, 'NridgHt' = 19, 
                 'NWAmes' = 20, 'OldTown' = 21, 'SWISU' = 22, 'Sawyer' = 23,
                 'SawyerW' = 24, 'Somerst' = 25, 'StoneBr' = 26, 'Timber' = 27, 
                 'Veenker' = 28
  )
  df = map.fcn(c('Neighborhood'), param.list, df)
  
   
  return(df)
 }
```


```r
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
```


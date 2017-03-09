---
# title: "Statistical inference with GSS data"
output: 
  html_document: 
    fig_height: 4
    highlight: pygments
    theme: spacelab
    css: style.css
  md_document:
  toc: true
---


<h2><b>Statistical inference with General Social Survey (GSS) data </b></h2>
<br>
Author: Bruno Hunkeler   
Date:  15.07.2016
<hr>

Since 1972, the General Social Survey (GSS) has been monitoring societal change and studying the growing complexity of American society. 
The GSS aims to gather data on contemporary American society in order to monitor and explain trends and constants in attitudes, behaviors, 
and attributes; to examine the structure and functioning of society in general as well as the role played by relevant subgroups; to compare 
the United States to other societies in order to place American society in comparative perspective and develop cross-national models of 
human society; and to make high-quality data easily accessible to scholars, students, policy makers, and others, with minimal cost and 
waiting.

<h3><b>Data collection</b></h3>

The GSS replicated questionnaire items and wording in order to facilitate time-trend studies. The latest survey, GSS 2012, includes a 
cumulative file that merges all 29 General Social Surveys into a single file containing data from 1972 to 2012. The items appearing in 
the surveys are one of three types: Permanent questions that occur on each survey, rotating questions that appear on two out of every 
three surveys (1973, 1974, and 1976, or 1973, 1975, and 1976), and a few occasional questions such as split ballot experiments that 
occur in a single survey. 

Data collection for the GSS was conducted through (i) computer-assisted personal interviews, (ii) face-to-face interviews, and 
(iii) telephone interviews. For the 2012 GSS data, the cases were a sample of all English and Spanish speaking people age 18 and over who were 
living in households at the time of the survey (or non-institutionalised) in the US. 
A description on the "SAMPLING DESIGN & WEIGHTING" can be found on Page 2867 / 2868 in the 
[GSS Codebook](http://www.icpsr.umich.edu/cgi-bin/file?comp=none&study=34802&ds=1&file_id=1136502&path=ICPSR).

The study is an observational study given that there was no random assignment of individuals to different conditions/treatments. Full 
probability sampling, where every individual had a chance of being selected, was conducted. Notwithstanding, there were exceptions that 
will be discussed below. The sampling method was stratified sampling; the population was stratified first by region followed by country. 
With regard to experimental design, there was no random assignment of individuals to different conditions or treatments.

<h4><b>Dataset and further Information</b></h4>
Dataset and further information used to perform the given analysis were obtained from the following sources:<br>
<ul>
<li>Dataset: [General Social Survey Data](http://www.icpsr.umich.edu/icpsrweb/ICPSR/studies/34802/version/1)</li>
<li>Codebook: [GSS Codebook](http://www.icpsr.umich.edu/cgi-bin/file?comp=none&study=34802&ds=1&file_id=1136502&path=ICPSR)</li>
<li>NORC: [GSS NORC](http://www.norc.org/Research/Projects/Pages/general-social-survey.aspx)</li>
</ul>


<h4><b>Generalizability</b></h4>
The population of interest is the working US population. As full probability sampling was conducted, the findings can be generalised to 
the entire working US population. Potential sources of bias may arise given that the GSS 2012 did not sample from (i) minors and (ii) 
people who do not speak either English and Spanish. For (i), the bias is likely to be minor given that our interest is 
examining the working population’s income, assuming that minors are still pursuing an education and do not have an income. With regard 
to (ii), the 2011 census on language use suggests that only 0.294% of the US population do not speak English and/or Spanish. 
Therefore, the biases in the 2012 GSS will have a negligible impact on the generalizability of this study.

<h4><b>Causality</b></h4>
The data cannot be used to establish a causal relation between the variables of interest as there was no random assignment to the 
explanatory and independent variable.


<h3><b>Setup</b></h3>

<h4><b>Load packages</b></h4>


```r
library('statsr')
library('ggplot2')    # library to create plots
library('plyr')       # data manipulation
library('dplyr')      # data manipulation
library('knitr')      # required to apply knitr options 

# apply general knitr options
knitr::opts_chunk$set(comment=NA, fig.align='center')
```

<h4><b>Load data</b></h4>
Initial load of the dataset.  

```r
# load the data set 
load("Data/gss.Rdata")
```

<h3><b>Part 1: Data</b></h3>
In order to examine the research question, the data from the General Social Survey (GSS) was used. The GSS is a sociological survey used to collect data 
on demographic characteristics and attitudes of residents of the United States. While the GSS provides data from 1972 - 2012, this paper will 
examine only data from 2012 to control for possible confounding variables including time, changes in the education system, and rising levels 
of income.


```r
# evaluate the size of the dataset
dim(gss)
```

```
[1] 57061   114
```

The output for the summary- and str() - function has been hidden since the output would be quiet exhaustive (verbose) by having 114 variables.
<br>

```r
# verify types and summary of each variable 
str(gss)
summary(gss)
```

I reduced the dataset for convenience reasons. I went through the dataset to separate the wheat from the chaff. I verified the number of 'NA' in each 
variable. Check if it is required to apply an algorithm to fill in the missing data or if I just can delete the incomplete rows. 
<br>

```r
# Create a subset of the analysed data, which might be interesting for the research questions
gss.2012.na <- subset(gss, year == 2012, select = c( degree, coninc))
gss.2012 <- gss.2012.na[complete.cases(gss.2012.na), ]
```

<h3><b>Part 2: Research question</b></h3>
The following Research question is meant to be answered in this document.<br>

<ul>
<li><b>Is there a relation between one’s highest education level attained and current income?</b></li>
<li><b>Do all levels of education lead to higher income, or do certain education qualifications lead to greater increases in income?</b></li>
</ul>

This is interesting to me for the following reason: <br>
US remains the world’s most popular destination for international students, it’s also among the most expensive choices. 
Studying in the US may be daunting, often involving a string of five-digit numbers. Therefore attaining a higher education level should also pay 
off especially when student loans are involved.

<h3><b>Part 3: Exploratory data analysis</b></h3>

We first need to evaluate the distribution of education in the US population.


```r
# distribution (numbers) of degree's in the given sample
summary(gss.2012$degree)
```

```
Lt High School    High School Junior College       Bachelor       Graduate 
           230            881            132            324            185 
```

```r
# distribution in percent based on degree's in the given sample
prop.table(summary(gss.2012$degree))
```

```
Lt High School    High School Junior College       Bachelor       Graduate 
    0.13127854     0.50285388     0.07534247     0.18493151     0.10559361 
```

A majority of the US population has an education level of high school and below (~63%). Approximately 8% attain a Junior College, while about 29% hold a bachelor or higher degreee.
<br>
<h4><b>Summary and density distribution of current income in 2012</b></h4>  


```r
# summary of income
summary(gss.2012$coninc)
```

```
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    383   16280   34470   48520   63200  178700 
```

```r
g <- ggplot(gss.2012, aes(coninc))
g + geom_density() + labs(title = "Distribution of income in 2012") + labs(x = "Total income", y = "Density")
```

<img src="figure/unnamed-chunk-5-1.png" title="plot of chunk unnamed-chunk-5" alt="plot of chunk unnamed-chunk-5" style="display: block; margin: auto;" />

The median income in 2012 is $34'470, with a mean of $48'512, and range of $383 - $178'700. Income distribution is bimodal and right skewed, 
with a peak at approximately $25,000 and another at the extreme right tail, with a gap between $125,000 and $160,000.
<br>
<h4><b>Boxplot of current income across education</b></h4> 


```r
# boxplot of income vs degree

ggplot(gss.2012, aes(factor(gss.2012$degree), gss.2012$coninc, fill = degree, alpha = 0.8)) + 
  geom_boxplot() +
  ggtitle('Total income by education level') +
  xlab('Education level') + ylab('Total income') +
  scale_fill_brewer(name = "Education level")
```

<img src="figure/unnamed-chunk-6-1.png" title="plot of chunk unnamed-chunk-6" alt="plot of chunk unnamed-chunk-6" style="display: block; margin: auto;" />

The box plots suggest a significant and positive relationship between higher education and income. There are also a few outliner with the lower levels of education. This are certainly valid case, if we consider school dropouts as Steve Jobs (never finished college) or Bill Gates (never finished University).
<br>
<h4><b>Density distribution of current income across education</b></h4> 


```r
g <- ggplot(gss.2012, aes(coninc, fill = degree))
g + geom_density (alpha = 0.2) + labs(title = "Income distributions across education levels") + labs(x = "Total income", y = "Density")
```

<img src="figure/unnamed-chunk-7-1.png" title="plot of chunk unnamed-chunk-7" alt="plot of chunk unnamed-chunk-7" style="display: block; margin: auto;" />

The overlapping distribution plots indicates at the strong relationship between education and income.


<h3><b>Part 4: Inference</b></h3>

<b>Null Hypothesis H<sub>0</sub></b>: The mean income is the same across all levels of education.<br> 
<b>Alternative Hypothesis H<sub>A</sub></b>: At least one pair of mean incomes are different from each other.

<b>H<sub>0</sub></b>: µ<sub>1</sub> = µ<sub>2</sub> = µ<sub>3</sub> = µ<sub>4</sub> = µ<sub>5</sub> ↔ <b>H<sub>A</sub></b>:there are not all equal to each other

<h4>Conditions</h4>

There are three conditions for analysis of variance (ANOVA), namely (i) independence, (ii) approximate normality, and (iii) equal variance. For (i), the data was randomly sampled with full probability sampling, and the sample size of each education group is less than 10% of the population and independent of each other. For (ii), while the normal probability plots (below) for each education group show that the data is right skewed and deviates from normality, this is mitigated by the large sample sizes for each education group. For (iii), the previous box plots of income across education levels show roughly equal variance for the High School, Junior College, and Bachelor groups, while the Less than High School group has lower variance and the Graduate group has higher variance.



```r
par(mfrow = c(3,2))
qqnorm(gss.2012$coninc[gss.2012$degree == "Lt High School"], main = "Lt High School", col = 'blue')
qqline(gss.2012$coninc[gss.2012$degree == "Lt High School"], col = 'red')
qqnorm(gss.2012$coninc[gss.2012$degree == "High School"], main = "High School", col = 'darkgreen')
qqline(gss.2012$coninc[gss.2012$degree == "High School"], col = 'red')
qqnorm(gss.2012$coninc[gss.2012$degree == "Junior College"], main = "Junior College", col = 'orange')
qqline(gss.2012$coninc[gss.2012$degree == "Junior College"], col = 'red')
qqnorm(gss.2012$coninc[gss.2012$degree == "Bachelor"], main = "Bachelor", col = 'brown')
qqline(gss.2012$coninc[gss.2012$degree == "Bachelor"], col = 'red')
qqnorm(gss.2012$coninc[gss.2012$degree == "Graduate"], main = "Graduate", col = 'magenta')
qqline(gss.2012$coninc[gss.2012$degree == "Graduate"], col = 'red')
```

<img src="figure/unnamed-chunk-8-1.png" title="plot of chunk unnamed-chunk-8" alt="plot of chunk unnamed-chunk-8" style="display: block; margin: auto;" />


```r
#anova of gss.2012$coninc ~ gss.2012$degree
inference(y = coninc, x = degree, data = gss.2012, statistic = "mean", type = "ht", null = 0, alternative = "greater", method = "theoretical")
```

```
Warning: Ignoring null value since it's undefined for ANOVA
```

```
Response variable: numerical
Explanatory variable: categorical (5 levels) 
n_Lt High School = 230, y_bar_Lt High School = 21214.4087, s_Lt High School = 22434.9973
n_High School = 881, y_bar_High School = 37453.1907, s_High School = 34974.5654
n_Junior College = 132, y_bar_Junior College = 46362.4621, s_Junior College = 39287.0311
n_Bachelor = 324, y_bar_Bachelor = 75174.4784, s_Bachelor = 55495.5515
n_Graduate = 185, y_bar_Graduate = 89988.0973, s_Graduate = 57720.4362

ANOVA:
            df           Sum_Sq          Mean_Sq        F  p_value
degree       4 828317185865.834 207079296466.459 120.5219 < 0.0001
Residuals 1747 3001675475207.45  1718188594.8526                  
Total     1751 3829992661073.29                                   

Pairwise tests - t tests with pooled SD:
           group1         group2   p.value
1     High School Lt High School 1.372e-07
2  Junior College Lt High School 3.185e-08
3        Bachelor Lt High School 1.669e-48
4        Graduate Lt High School 7.832e-59
6  Junior College    High School 2.140e-02
7        Bachelor    High School 2.540e-42
8        Graduate    High School 6.829e-52
11       Bachelor Junior College 2.269e-11
12       Graduate Junior College 7.095e-20
16       Graduate       Bachelor 1.092e-04
```

<img src="figure/unnamed-chunk-9-1.png" title="plot of chunk unnamed-chunk-9" alt="plot of chunk unnamed-chunk-9" style="display: block; margin: auto;" />

The F - Distribution with an amount of 120.5 and a degree of freedom of 4 is relatively larger. Therefore the p-value will be rather small.
Since the p-value is small (less than α), we reject <b>H<sub>0</sub></b> in favour of the alternative hypothesis <b>H<sub>A</sub></b>. The data provides convincing evidence that at least one pair of population means are different from each other.



```r
by(gss.2012$coninc, gss.2012$degree, quantile)
```

```
gss.2012$degree: Lt High School
    0%    25%    50%    75%   100% 
   383   6894  14363  28725 178712 
-------------------------------------------------------- 
gss.2012$degree: High School
    0%    25%    50%    75%   100% 
   383  14363  28725  51705 178712 
-------------------------------------------------------- 
gss.2012$degree: Junior College
    0%    25%    50%    75%   100% 
   383  18193  34470  63195 178712 
-------------------------------------------------------- 
gss.2012$degree: Bachelor
    0%    25%    50%    75%   100% 
   383  34470  63195  91920 178712 
-------------------------------------------------------- 
gss.2012$degree: Graduate
    0%    25%    50%    75%   100% 
  2681  42130  76600 178712 178712 
```

<h3>Conclusion</h3>

Summarizing the findings in 2012, there is a significant and positive relationship between higher education level and income. Higher education qualifications lead to higher income. Note that there is no significant difference in income between the high school and junior college education levels.

Is getting a bachelor's degree worth the cost? For this, we examine income quantiles across education levels. Median income for bachelor's degree holders is nearly twice that of junior college graduates, with a difference of $28'725. Based on the information retrived from [CNN Money](http://money.cnn.com/2012/10/18/pf/college/student-loan-debt/) it was stated that the average education debt load for 2011 was about $27'000. Assuming a prosperous economy and decent job, the increase in median income from a bachelor's degree should pay off the education debt within a year.

Examining the incomes between bachelor and graduate degree holders. Based on median income, graduate degree holders earn $13'405 more than holders of a bachelor's degree. This may not seem like much compared to the cost of a graduate education. However, examining income at the 75th percentile, graduate degree holders earn nearly twice as much as that of a bachelor's degree holders, with a difference of $86'792. It seems that for the top 25%, a graduate degree pays better interest than a bachelor’s degree.

However, this analysis does not imply that income is dependent only on education level. Referring to the box plots, there are outliers at every education level that have extremely high income. This is also seen in the overlapping distribution plots, where high income earners at the right tail of the distribution consists of all education levels.

One shortcoming of the study is the current data not including people who do not speak either English or Spanish. While this is only 0.294% of the population, future research could try to include this segment of the population. 

The current analysis does not take into account possible extraneous variables such as age and gender. A further research could examine the relationship between these variables and current income.

<h3>References:</h3>

Smith, Tom W., Michael Hout, and Peter V. Marsden. General Social Survey, 1972-2012 [Cumulative File]. 
ICPSR34802-v1. Storrs, CT: Roper Center for Public Opinion Research, University of Connecticut/Ann Arbor, 
MI: Inter-university Consortium for Political and Social Research [distributors], 
2013-09-11. http://doi.org/10.3886/ICPSR34802.v1

Persistent URL: http://doi.org/10.3886/ICPSR34802.v1







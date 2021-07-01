# VAR-DCC-Implementation
Implementation of a Vector Auto Regressive Dynamic Conditional Correlation Model using oil ,gold sensex and exchange rate.This is a replication of a 2016 Paper : 
"Dynamic linkages among oil price, gold price, exchange rate, and stock market in India"


## Introduction : Vector Auto Regressive models 
Vector autoregression (VAR) is a statistical model used to capture the relationship between multiple quantities as they change over time. VAR models generalize the single-variable (univariate) autoregressive model by allowing for multivariate time series. Each variable has an equation modelling its evolution over time. This equation includes the variable's lagged (past) values, the lagged values of the other variables in the model, and an error term.

![image](https://user-images.githubusercontent.com/65502904/124171520-5044d480-dac6-11eb-9f15-2f8ca005e263.png)


## ARCH & GARCH Models

 The autoregressive conditional heteroscedasticity (ARCH) model is a statistical model for time series data that describes the variance of the current error term or innovation as a function of the actual sizes of the previous time periods' error terms, often the variance is related to the squares of the previous innovations. 
 
 If an autoregressive moving average (ARMA) model is assumed for the error variance, the model is a generalized autoregressive conditional heteroskedasticity (GARCH) model.
 
 ![image](https://user-images.githubusercontent.com/65502904/124171616-71a5c080-dac6-11eb-9c3e-ec2ba1ea819c.png)



### Multivariate GARCH Models

Dynamic Conditional Correlation (DCC) estimators are proposedwhich have the flexibility of univariate GARCH but not the complexity of multivariate GARCH.  These models, which parameterize the conditional correlations directly, arenaturally estimated in two steps – the first is a series of univariate GARCH estimates andthe second the correlation estimate. They estimate conditional correlations for different time series.

![image](https://user-images.githubusercontent.com/65502904/124172414-6d2dd780-dac7-11eb-9f72-93189110acc3.png)




### Install packages
```python
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
from statsmodels.tsa.stattools import adfuller
from statsmodels.tsa.stattools import grangercausalitytests
from statsmodels.tsa.vector_ar.vecm import coint_johansen
from statsmodels.graphics.tsaplots import plot_acf,plot_pacf
import statsmodels.stats.api as sms
from statsmodels.compat import lzip
from scipy.stats import skew,kurtosis

```

```{r}
library(xts)
library(tseries)
library(FinTS)
library(e1071)
library(rugarch)
library(rmgarch)
library(zoo)
```


### Find Vector Auto Regressive Model for the 4 series which fits best to the data:

### Preprocess and Convert into log returns from prices data

```python
log_returns=np.log(data) - np.log(data.shift(1))
log_returns.dropna(how='all',inplace=True)
```

```python
import statsmodels.tsa.api as smt
var_model = smt.VAR(log_returns)
res = var_model.select_order(maxlags=30,trend='c') ## Lag selection process
print(res.summary())
residuals=result.resid
```



### Univariate GARCH Model

Here we are using the functionality provided by the rugarch package written by Alexios Galanos.

### Model Specification

The first thing you need to do is to ensure you know what type of GARCH model you want to estimate and then let R know about this. It is the ugarchspec( ) function which is used to let R know about the model type. There is in fact a default specification and the way to invoke this is as follows

```{r}
garch_spec=ugarchspec(variance.model = list(model = "sGARCH", garchOrder = c(1, 1)), mean.model = list(armaOrder = c(0, 0)),distribution.model = "std")

```
#### Here model is Standard Garch of order (1,1) with mean model constant and distribution as Student-t


### Model Set up
Here we assume that we are using the same univariate volatility model specification for each of the four assets.

### DCC 

```{r}
m_spec=multispec(replicate(4,garch_spec))
dcc_spec=dccspec(uspec=m_spec,dccOrder = c(1,1))
```


In this specification we have to state how the univariate volatilities are modeled and how complex the dynamic structure of the correlation matrix is (here we are using the most standard dccOrder = c(1, 1) specification).

### Model Estimation
Now we are in a position to estimate the model using the dccfit function.

```{r}
dcc_fit=dccfit(dcc_spec,data =residuals)
```



When you estimate a multivariate volatility model like the DCC model you are typically interested in the estimated covariance or correlation matrices. After all it is at the core of these models that you allow for time-variation in the correlation between the assets. Therefore we will now learn how we extract these.

### Get the model based time varying covariance (arrays) and correlation matrices

```{r}
cor.v=rcov(dcc_fit) ## Not written in actual code
cor.s=rcor(dcc_fit)
```

cor.s will output a 3 dimensional matrix indicating first two dimensions are for correlation matrix and the third dimension is for Date

```{r}
cor.s[,,dim(cor.s)[3]]
```
```{r}
         brent        gold      exrate      sensex
brent   1.00000000  0.21553580 -0.03620277  0.11141797
gold    0.21553580  1.00000000 -0.01916530 -0.02277588
exrate -0.03620277 -0.01916530  1.00000000  0.53936832
sensex  0.11141797 -0.02277588  0.53936832  1.00000000
```


So let's say we want to plot the time-varying correlation for all 4 assets for analysing dynamic conditional correlations
```{r}
par(mfrow=c(3,2))
plot(as.xts(cor.s[1,2,]),main="Brent and Gold",col='blue')
plot(as.xts(cor.s[1,3,]),main="Brent and Exchange rate",col='red')
plot(as.xts(cor.s[1,4,]),main="Brent and Sensex",col='green')
plot(as.xts(cor.s[2,3,]),main="Gold and Exchange rate",col='purple')
plot(as.xts(cor.s[2,4,]),main="Gold and Sensex",col='cyan')
plot(as.xts(cor.s[3,4,]),main="Exchange rate and Sensex",col='orange')
```

![DCC plot with Standard GARCH](https://user-images.githubusercontent.com/65502904/124167675-e0cce600-dac1-11eb-9bd6-acb75f110f6a.png)





### Results and Conclusions :
 The dynamic conditional correlations between crude-gold and inr-sensex are always in the positive zone 
 
 Brent-Exchange_rate and Brent-Sensex correlation can be seen to higher in the 2008–2013 period, indicating higher correlations during the financial crisis and beyond period.
 
 Gold-Exchange_rate and Gold-Sensex display short periods of negative correlation, which might be indication of investors shifting from risky assets such as stocks to
 the perceived safety of gold or can use it for hedging.




### References
https://ideas.repec.org/a/eee/jrpoli/v49y2016icp179-185.html
https://en.wikipedia.org/wiki/Autoregressive_conditional_heteroskedasticity

Introductory Economics for Finance, Chris Brooks


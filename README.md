# VAR-DCC-Implementation
Implementation of a Vector Auto Regressive Dynamic Conditional Correlation Model using oil ,gold sensex and exchange rate.This is a replication of 

## Introduction: ARCH & GARCH Models

 The autoregressive conditional heteroscedasticity (ARCH) model is a statistical model for time series data that describes the variance of the current error term or innovation as a function of the actual sizes of the previous time periods' error terms, often the variance is related to the squares of the previous innovations. 
 
 If an autoregressive moving average (ARMA) model is assumed for the error variance, the model is a generalized autoregressive conditional heteroskedasticity (GARCH) model.
### Multivariate GARCH Models

In line with Engle (2002), the DCC-GARCH can be presented as follows:



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









### References
PennState: Statistics Online Courses. 2020. ARCH/GARCH Models | STAT 510. [online] Available at: <https://online.stat.psu.edu/stat510/lesson/11/11.1>.

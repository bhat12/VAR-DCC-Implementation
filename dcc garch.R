library(xts)
residuals = Var_residuals
residuals$Date=as.Date(residuals$Date,format="%Y-%m-%d")
residuals=as.data.frame(residuals)
rownames(residuals) <- residuals$Date
residuals=subset(residuals,select=-Date)

library(ggplot2)
ggplot() + geom_line(aes(x=residuals$Date,y=residuals$brent),color='blue') 
ggplot() + geom_line(aes(x=residuals$Date,y=residuals$gold),color='blue') 
ggplot() + geom_line(aes(x=residuals$Date,y=residuals$exrate),color='blue')




#Standard GARCH and DCC  estimation of residuals

library(tseries)
library(FinTS)
library(e1071)
library(rugarch)
library(rmgarch)
library(zoo)

garch_spec=ugarchspec(variance.model = list(model = "sGARCH", garchOrder = c(1, 1)), mean.model = list(armaOrder = c(0, 0)))
m_spec=multispec(replicate(4,garch_spec))
dcc_spec=dccspec(uspec=m_spec,dccOrder = c(1,1))
dcc_fit=dccfit(dcc_spec,data =residuals)

plot(rcor(dcc_fit, type="R")['exrate','senusd',], type='l')

garch_spec.exp=ugarchspec(variance.model = list(model = "eGARCH", garchOrder = c(1, 1)), mean.model = list(armaOrder = c(0, 0)))
m_spec.exp=multispec(replicate(4,garch_spec.exp))
dcc_spec.exp=dccspec(uspec=m_spec.exp,dccOrder = c(1,1))
dcc_fit.exp=dccfit(dcc_spec.exp,data =residuals)

garch_spec.t=ugarchspec(variance.model = list(model = "tGARCH", garchOrder = c(1, 1)), mean.model = list(armaOrder = c(0, 0)))
m_spec.t=multispec(replicate(4,garch_spec.exp))
dcc_spec.t=dccspec(uspec=m_spec.exp,dccOrder = c(1,1))
dcc_fit.t=dccfit(dcc_spec.exp,data =residuals)

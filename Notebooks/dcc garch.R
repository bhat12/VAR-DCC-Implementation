library(xts)
residuals = Var_residuals_lag1
residuals$Date=as.Date(residuals$Date,format="%Y-%m-%d")
residuals=as.data.frame(residuals)
rownames(residuals) <- residuals$Date
residuals=subset(residuals,select=-Date)


#Standard GARCH and DCC  estimation of residuals

library(tseries)
library(FinTS)
library(e1071)
library(rugarch)
library(rmgarch)
library(zoo)

# Standard GARCH
garch_spec=ugarchspec(variance.model = list(model = "sGARCH", garchOrder = c(1, 1)), mean.model = list(armaOrder = c(0, 0)),distribution.model = "std")
m_spec=multispec(replicate(4,garch_spec))
dcc_spec=dccspec(uspec=m_spec,dccOrder = c(1,1))
dcc_fit=dccfit(dcc_spec,data =residuals)

cor.s=rcor(dcc_fit)

par(mfrow=c(3,2))
plot(as.xts(cor.s[1,2,]),main="Brent and Gold",col='blue')
plot(as.xts(cor.s[1,3,]),main="Brent and Exchange rate",col='red')
plot(as.xts(cor.s[1,4,]),main="Brent and Sensex",col='green')
plot(as.xts(cor.s[2,3,]),main="Gold and Exchange rate",col='purple')
plot(as.xts(cor.s[2,4,]),main="Gold and Sensex",col='cyan')
plot(as.xts(cor.s[3,4,]),main="Exchange rate and Sensex",col='orange')


# EGARCH estimation
garch_spec.exp=ugarchspec(variance.model = list(model = "eGARCH", garchOrder = c(1, 1)), mean.model = list(armaOrder = c(0, 0)),distribution.model = "std")
m_spec.exp=multispec(replicate(4,garch_spec.exp))
dcc_spec.exp=dccspec(uspec=m_spec.exp,dccOrder = c(1,1))
dcc_fit.exp=dccfit(dcc_spec.exp,data =residuals)


cor.exp=rcor(dcc_fit.exp)
par(mfrow=c(3,2))
plot(as.xts(cor.exp[1,2,]),main="Brent and Gold",col='blue')
plot(as.xts(cor.exp[1,3,]),main="Brent and Exchange rate",col='red')
plot(as.xts(cor.exp[1,4,]),main="Brent and Sensex",col='green')
plot(as.xts(cor.exp[2,3,]),main="Gold and Exchange rate",col='purple')
plot(as.xts(cor.exp[2,4,]),main="Gold and Sensex",col='cyan')
plot(as.xts(cor.exp[3,4,]),main="Exchange rate and Sensex",col='orange')

#garch_spec.t=ugarchspec(variance.model = list(model = "tGARCH", garchOrder = c(1, 1)), mean.model = list(armaOrder = c(0, 0)),distribution.model = "std")
#m_spec.t=multispec(replicate(4,garch_spec.t))
#dcc_spec.t=dccspec(uspec=m_spec.t,dccOrder = c(1,1))
#dcc_fit.t=dccfit(dcc_spec.t,data =residuals)


#cor.t=rcor(dcc_fit.t)
#par(mfrow=c(3,2))
#plot(as.xts(cor.t[1,2,]),main="dccBrent and Gold",col='blue')
#plot(as.xts(cor.t[1,3,]),main="Brent and Exchange rate",col='red')
#plot(as.xts(cor.t[1,4,]),main="Brent and Sensex",col='green')
#plot(as.xts(cor.t[2,3,]),main="Gold and Exchange rate",col='purple')
#plot(as.xts(cor.t[2,4,]),main="Gold and Sensex",col='cyan')
#plot(as.xts(cor.t[3,4,]),main="Exchange rate and Sensex",col='orange')

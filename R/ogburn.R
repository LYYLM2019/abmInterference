#install.packages('knitr')
#install.packages("devtools")
#install.packages('netdep')
#install.packages('MASS')
#install.packages('mvrtn')
#install.packages('igraphdata')

library(devtools)
library(knitr)
library(MASS)
library(mvrtn)
library(igraph)
library(igraphdata)

# Install and load netdep
#install_github("youjin1207/netdep")
library(netdep)

# generate network
G = latent.netdep(n.node = 200, rho = 0.2, dep.factor = -1)
A = as.matrix(get.adjacency(G))
outcomes = peer.process(A, max.time = 3, mprob = 0.6, epsilon = 0.1)
names(outcomes)

# Results
result0 = make.permute.moran(A, outcomes$time0, np = 500)
result1 = make.permute.moran(A, outcomes$time1, np = 500)
result2 = make.permute.moran(A, outcomes$time2, np = 500)
result3 = make.permute.moran(A, outcomes$time3, np = 500)


kable(cbind( c("t=0", "t=1", "t=2", "t=3"),
             round(c(result0$moran, result1$moran, result2$moran, result3$moran),2),
             round(c(result0$pval.permute, result1$pval.permute, result2$pval.permute, result3$pval.permute),2)), row.names = NA, col.names = c("Transmission time", "Moran's I", "P-value (permutation)"), 
      caption = "Direct transmission")

# Test network dependence with Phi
G = latent.netdep(n.node = 200, rho = 0.4, dep.factor = -1)
subG = snowball.sampling(G, 100)$subG
A = as.matrix(get.adjacency(subG))
conti.Y = V(subG)$outcome 
cate.Y = ifelse(conti.Y < quantile(conti.Y, 0.25), 1, 4)
cate.Y = ifelse(conti.Y < quantile(conti.Y, 0.60) & conti.Y >= quantile(conti.Y, 0.25), 2, cate.Y)
cate.Y = ifelse(conti.Y < quantile(conti.Y, 0.80) & conti.Y >= quantile(conti.Y, 0.60), 3, cate.Y)
table(cate.Y)
result = make.permute.Phi(A, cate.Y, 500)
result

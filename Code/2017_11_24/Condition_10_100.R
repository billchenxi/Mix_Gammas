###############################################################################
###############################################################################
### Condition 10_100
###############################################################################
###############################################################################

set.seed(100)
setwd("/home/xch234/mix_gammas/Mix_Gammas/")
requiredPackages = c("mixtools")
for(p in requiredPackages){
        if(!require(p,character.only = TRUE)) install.packages(p)
        library(p,character.only = TRUE)
}
source("./Code/gammamixEMnew.R")
B <- 5000
k <- 3 #
alpha <- c(1,20,50) #
beta <- c(2,4,3) #
lambda <- c(0.2,0.3,0.5) #
n <- 100 #
x <- sapply(1:B,function(i) apply(rmultinom(n,size=1,prob=lambda)*matrix(rgamma(k*n,shape=alpha,scale=1/beta),nrow=k),2,sum))
restarts <- 0
time1 <- matrix(NA,B,3)
time2 <- matrix(NA,B,3)

out_10_100_1 <- vector("list",B) #Rename for each condition and sample size; e.g., Condition 2 --> out_2_100_1, Condition 3 --> out_3_100_1, etc.
out_10_100_2 <- vector("list",B) #Rename for each condition and sample size; e.g., Condition 2 --> out_2_100_2, Condition 3 --> out_3_100_2, etc.
i <- 0
while(i < B){
        i <- i+1
        s1 <- system.time(tmp.out_1 <- try(suppressWarnings(gammamixEM.new(x=x[,i], k=k, mom.start = TRUE, fix.alpha = FALSE, 
                                                                           verb=FALSE, maxit=10000, eps=1e-5)),silent = TRUE))
        s2 <- system.time(tmp.out_2 <- try(suppressWarnings(gammamixEM.new(x=x[,i], k=k, mom.start = FALSE, fix.alpha = FALSE, 
                                                                           verb=FALSE, maxit=10000, eps=1e-5)),silent = TRUE))
        if(class(tmp.out_1)=="try-error"|class(tmp.out_2)=="try-error"){
                x[,i] <- apply(rmultinom(n,size=1,prob=lambda)*matrix(rgamma(k*n,shape=alpha,scale=1/beta),nrow=k),2,sum)
                i <- i-1
                restarts <- restarts+1
        } else {
                tmp <- rbind(tmp.out_1$gamma.par,tmp.out_1$lambda,tmp.out_1$loglik,length(tmp.out_1$all.loglik)-1)
                tmp <- tmp[,order(tmp[1,]/tmp[2,])]
                out_10_100_1[[i]] <- tmp #
                tmp <- rbind(tmp.out_2$gamma.par,tmp.out_2$lambda,tmp.out_2$loglik,length(tmp.out_2$all.loglik)-1)
                tmp <- tmp[,order(tmp[1,]/tmp[2,])]
                out_10_100_2[[i]] <- tmp #
                time1[i,] <- c(s1)[1:3]
                time2[i,] <- c(s2)[1:3]
        }
        print(i)
}
save.image(file="./Result/2017_11_24/10_100.Rd")

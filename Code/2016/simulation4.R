setwd("~/Documents/Git/Mix_Gammas/Code")
#setwd("/home/xch234/mix_gammas/Mix_Gammas/Code")
source("./gammamixEM2.R")
set.seed(518)
library("mixtools")
library("MASS")
library(RJSONIO)
##################
# sample.size = 5
# n.iter = 5000 # this is B
n.iter = 1
# sample.size = c(100, 250, 500)
sample.size = 10
parameters <- function(){
        conditions <- list()
        # Condition 1
        conditions[["C1"]] <- data.frame(c(2,5),c(3,4),c(0.5,0.5))
        colnames(conditions[["C1"]]) <- c("a", "b", "l")
        # Condition 2
        conditions[["C2"]] <- data.frame(c(2,5),c(3,4),c(0.2,0.8))
        colnames(conditions[["C2"]]) <- c("a", "b", "l")
        # Condition 3
        conditions[["C3"]] <- data.frame(c(1,10),c(1,1),c(0.5,0.5))
        colnames(conditions[["C3"]]) <- c("a", "b", "l")
        # Condition 4
        conditions[["C4"]] <- data.frame(c(1,10),c(1,1),c(0.2,0.8))
        colnames(conditions[["C4"]]) <- c("a", "b", "l")
        # Condition 5
        conditions[["C5"]] <- data.frame(c(2,30),c(3,2),c(0.5,0.5))
        colnames(conditions[["C5"]]) <- c("a", "b", "l")
        # Condition 6
        conditions[["C6"]] <- data.frame(c(2,30),c(3,2),c(0.2,0.8))
        colnames(conditions[["C6"]]) <- c("a", "b", "l")
        # Condition 7
        conditions[["C7"]] <- data.frame(c(2,5,6),c(3,5,7),c(1/3,1/3,1/3))
        colnames(conditions[["C7"]]) <- c("a", "b", "l")
        # Condition 8
        conditions[["C8"]] <- data.frame(c(2,5,6),c(3,5,7),c(0.2,0.3,0.5))
        colnames(conditions[["C8"]]) <- c("a", "b", "l")
        # Condition 9
        conditions[["C9"]] <- data.frame(c(1,20,50),c(2,4,3),c(0.2,0.3,0.5))
        colnames(conditions[["C9"]]) <- c("a", "b", "l")
        # Condition 10
        conditions[["C10"]] <- data.frame(c(1,20,50),c(2,4,3),c(0.2,0.3,0.5))
        colnames(conditions[["C10"]]) <- c("a", "b", "l")
        # Condition 11
        conditions[["C11"]] <- data.frame(c(2,50,180),c(1,2,3),c(0.2,0.3,0.5))
        colnames(conditions[["C11"]]) <- c("a", "b", "l")
        # Condition 12
        conditions[["C12"]] <- data.frame(c(2,50,180),c(1,2,3),c(0.2,0.3,0.5))
        colnames(conditions[["C12"]]) <- c("a", "b", "l")
        return(conditions)
}
conditions <- parameters()

#################################
set.seed(111)
sample.generation <- function(sample.size, parameters){
        samples <- apply(parameters, 1, function(i){rgamma(sample.size* i[3], shape = i[1], scale = i[2])
        })
        return(unlist(samples))
}

sample <- sample.generation(100, conditions[["C12"]])

# Simulation function ###################################

estimation4.f <- function(dat, para){
        datCubeRoot <- dat^(1/3)
        numOfDist <- nrow(para)
        classification <- normalmixEM(datCubeRoot, k = numOfDist)
        clf.dat <- apply((classification$posterior == T), 2, function(x) dat[x] )
        para.est <- lapply(c(1:numOfDist), function(i){
                test = try(nr.gamma(x=unlist(clf.dat[i]), eps = 0.01), silent = T)
                if (class(test)=="try-error"){
                        test = as.numeric(gammamix.init(unlist(clf.dat[i]), lambda = 1, k = 1)[2:3])                
                        return(test)}
                else{return(test$theta)}
        }) 
        a <- para$a
        b <- unlist(data.frame(para.est)[2,])
        print(classification$posterior)
        l <- apply((classification$posterior == T), 2, function(x) {table(x)["TRUE"]/length(x)} )
        print(l)
        output <- gammamixEM2(dat, lambda = l, alpha = a, beta = b, k = numOfDist, fix.alpha = T)[2:4]
        return(output)
}

#################################
library(parallel)
simulation <- function(s.size, condition, strategy){
        # 12 conditions
        results <- lapply(condition, function(para){
                # 3 sample size
                #print(para)
                one.iteration.results <- lapply(s.size, function(s){
                        #print(s)
                        dat <- as.vector(sample.generation(sample.size = s, parameters = para))
                        one.sample.result <- strategy(dat, para)
                        return(one.sample.result)
                })
                return(one.iteration.results)
        })        
        return(results)
}

simulation(s.size = c(100), condition = para, estimation4.f)

# sim1 <- mclapply( (1:n.iter), function(i){
#         results <- simulation(sample.size, conditions, estimation1.f)
#         return(results)
# }, mc.cores=8)
# 
# exportJson <- toJSON(sim1)
# write(exportJson, "sim1.json")

sim4 <- mclapply( (1:n.iter), function(i){
        results <- simulation(sample.size, conditions, estimation4.f)
        return(results)
}, mc.cores=1)

exportJson <- toJSON(sim4)
write(exportJson, "sim4.json")

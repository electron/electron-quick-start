require("SQUAREM")
require("interval")
#####---------------------------------------------------------------###########
##For interval censoring non-parametric maximum likelihood estimation, ########
##we illustrate how Squarem can be used to accelerate EM. ##################### 

#####---------------------------------------------------------------###########
###########################data################################################
#####---------------------------------------------------------------###########
dat <- c(45, 6, 0, 46, 46, 7, 17, 7, 37, 0, 4, 15, 11,  
         22, 46, 46, 25, 46, 26, 46, 27, 36, 46, 36, 37,
         40, 17, 46, 11, 38, 5, 37, 0, 18, 24, 36, 5, 19,
         17, 24, 32, 33, 19, 37, 34, 36, Inf, 10, 7, Inf, 
         Inf, 16, Inf, 14, 44, 8, 11, Inf, 15, Inf, Inf, Inf,
         37, Inf, 40, Inf, 34, 44, Inf, 48, Inf, Inf, 25, 
         Inf, 18, Inf, 12, Inf, 5, Inf, Inf, Inf, 11, 35,
         25, Inf, Inf, Inf, 26, Inf, Inf, Inf)
dat <- data.frame(matrix(dat, 46, 2))
names(dat) <- c("L", "R")

#####---------------------------------------------------------------###########
########use Aintmap for alpha matrix, starting value###########################
#####---------------------------------------------------------------###########
Aintmap <-function(L,R,Lin=NULL,Rin=NULL){
        n<-length(L)
        Lin<-rep(FALSE,n)
        Rin<-rep(TRUE,n)
        Lin[L==R]<-TRUE
        Rin[R==Inf]<-FALSE
        if(n != length(R))
                stop("length of L and R must be the same")
        LRvalues<-sort(unique(c(0,L,R,Inf)))
        eps<- min(diff(LRvalues))/2
        Le<-L
        Re<-R
        Le[!Lin]<-L[!Lin]+eps
        Re[!Rin]<-R[!Rin]-eps
        oLR<-order(c(Le,Re+eps/2))
        Leq1.Req2<-c(rep(1,n),rep(2,n))
        flag<- c(0,diff( Leq1.Req2[oLR] ))
        R.right.of.L<- (1:(2*n))[flag==1]
        intmapR<- c(L,R)[oLR][R.right.of.L]
        intmapL<- c(L,R)[oLR][R.right.of.L - 1]
        intmapRin<- c(Lin,Rin)[oLR][R.right.of.L]
        intmapLin<- c(Lin,Rin)[oLR][R.right.of.L - 1]
        intmap<-matrix(c(intmapL,intmapR),byrow=TRUE,nrow=2)
        attr(intmap,"LRin")<-matrix(c(intmapLin,intmapRin),byrow=TRUE,nrow=2)
        k<-dim(intmap)[[2]]
        Lbracket<-rep("(",k)
        Lbracket[intmapLin]<-"["
        Rbracket<-rep(")",k)
        Rbracket[intmapRin]<-"]"
        intname<-paste(Lbracket,intmapL,",",intmapR,Rbracket,sep="")
        A<-matrix(0,n,k,dimnames=list(1:n,intname))
        intmapLe<-intmapL
        intmapLe[!intmapLin]<-intmapL[!intmapLin]+eps
        intmapRe<-intmapR
        intmapRe[!intmapRin]<-intmapR[!intmapRin]-eps
        for (i in 1:n){
                tempint<- Le[i]<=intmapRe & Re[i]>=intmapLe
                A[i,tempint]<-1
        }
        
        if (k==1 & intmap[1,1]==0 & intmap[2,1]==Inf) A[A==0]<-1  
        return(A=A)
        
}

A <- Aintmap(dat[,1], dat[,2])
m <- ncol(A)
##starting values
pvec <- rep(1/m, length = m)


#####---------------------------------------------------------------###########
####The fixed point mapping giving a single E and M step of the EM algorithm###
#####---------------------------------------------------------------###########
intEM <- function(pvec, A){
        tA <- t(A)
        Ap <- pvec*tA
        pnew <- colMeans(t(Ap)/colSums(Ap))
        pnew * (pnew > 0)
}

#####---------------------------------------------------------------###########
####Objective function whose local minimum is a fixed point. ##################
####Here it is the negative log-likelihood of interval censoring.##############
#####---------------------------------------------------------------###########
loglik <- function(pvec, A){
        - sum(log(c(A %*% pvec)))
}
##A is the alpha matrix and pvec is the vector of probabilities p.

#####---------------------------------------------------------------###########
#####################################EM Algorithm##############################
#####---------------------------------------------------------------###########
system.time(ans1 <- fpiter(par = pvec, fixptfn = intEM, 
                           objfn = loglik, A = A, 
                           control = list(tol = 1e-8)))
ans1

#####---------------------------------------------------------------###########
###################Squarem to accelerate EM Algorithm##########################
#####---------------------------------------------------------------###########
system.time(ans2 <- squarem(par = pvec, fixptfn = intEM, 
                            objfn = loglik, A = A, 
                            control = list(tol = 1e-8)))
ans2

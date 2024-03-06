#-----------------------------------------------
#Project title: Association between MH stigma and SI - RI-CLPM
#Date: 6/29/2023
#Author: Lauren O'Reilly
#Changes: 
#NOTE: (9/11/23) SAS Dataset 1 and 2 differed on the standardization of the main variables
  #To fix: read in earlier iteration of dataset 2 (hom_1) - labeled as df2_nonstd 
  #Continue to use df1_miss (variables are nonstd)  
  #Use df2_nonstd throughout instead
#-----------------------------------------------
#Use Version 4.2.1

#Install packages
#install.packages("performance", repos="https://easystats.r-universe.dev")
install.packages("haven", dependencies = T, repos="http://cran.us.r-project.org")
install.packages("dplyr", repos="http://cran.us.r-project.org")
install.packages("psych", repos="http://cran.us.r-project.org")
install.packages("lavaan", dependencies = TRUE, repos="http://cran.us.r-project.org")
install.packages("foreign", repos="http://cran.us.r-project.org")
install.packages("ggplot2", repos="http://cran.us.r-project.org")
install.packages("pscl", repos="http://cran.us.r-project.org")
install.packages("boot", repos="http://cran.us.r-project.org")
install.packages("semPlot", repos="http://cran.us.r-project.org")
install.packages("tidySEM", repos="http://cran.us.r-project.org")
install.packages("mice", dependencies = T, repos="http://cran.us.r-project.org")

#install.packages("Rtools", dependencies = T, repos="http://cran.us.r-project.org")
#install.packages("devtools")
#devtools::install_github(repo = "amices/mice")

#Load libraries
library(haven)
library(rlang)
library(dplyr)
library(psych)
library(lavaan)
library(foreign)
#library(ggplot2)
library(pscl)
library(boot)
#library(semPlot)
library(tidySEM)
#library(performance)
library(mice)


#Load datasets
  #Multiply imputed in SAS
#df1 = as.data.frame(read_sas("R:/Data/1707701 Yu-MH Stigma-Suicidal/Data/suistg_1mi.sas7bdat"))
df1 = as.data.frame(read_sas("C:/Users/loreilly/OneDrive - Indiana University/My Passport Backup/Internship Resources/Stigma/suistg_1mi.sas7bdat"))
  #Non-multiply imputed (original dataset - note: this dataset has unstd variables)
df1_miss = as.data.frame(read_sas("C:/Users/loreilly/OneDrive - Indiana University/My Passport Backup/Internship Resources/Stigma/suistg_1.sas7bdat"))
  #Complete case dataset
df1_cc = as.data.frame(read_sas("C:/Users/loreilly/OneDrive - Indiana University/My Passport Backup/Internship Resources/Stigma/suistg_2.sas7bdat"))


# df1[,c("DSISS_t1",
#        "DSISS_t2",
#        "DSISS_t3")] = 
#   lapply(df1[,c("DSISS_t1",
#                 "DSISS_t2",
#                 "DSISS_t3")], ordered)

 #Create dichotomous DSI-SS variables
#df1_miss$DISS_t1d[df1_miss$DSISS_t1 > 0] = "1"
#df1_miss$DISS_t1d[df1_miss$DSISS_t1 == 0] = "0"

#df1_miss$DISS_t2d[df1_miss$DSISS_t2 > 0] = "1"
#df1_miss$DISS_t2d[df1_miss$DSISS_t2 == 0] = "0"
 
#df1_miss$DISS_t3d[df1_miss$DSISS_t3 > 0] = "1"
#df1_miss$DISS_t3d[df1_miss$DSISS_t3 == 0] = "0"


 #Multiply imputed in SAS
df2 = as.data.frame(read_sas("C:/Users/loreilly/OneDrive - Indiana University/My Passport Backup/Internship Resources/Stigma/hom_4mi.sas7bdat"))
  #Non-multiply imputed (original dataset)
df2_miss = as.data.frame(read_sas("C:/Users/loreilly/OneDrive - Indiana University/My Passport Backup/Internship Resources/Stigma/hom_2.sas7bdat"))
    #Non-MI (and variables are unstandardized)
df2_nonstd = as.data.frame(read_sas("C:/Users/loreilly/OneDrive - Indiana University/My Passport Backup/Internship Resources/Stigma/hom_1.sas7bdat"))
#df2_full = as.data.frame(read_sas("D:/Internship Resources/Stigma/hom_1.sas7bdat"))
  #Complete case dataset
df2_cc = as.data.frame(read_sas("C:/Users/loreilly/OneDrive - Indiana University/My Passport Backup/Internship Resources/Stigma/hom_3.sas7bdat"))


remove(df_full)

  #Load merged dataset
#df3 = as.data.frame(read_sas("D:/Internship Resources/Stigma/merge_.sas7bdat"))

# df2[,c("DSISS_t1",
#        "DSISS_t2",
#        "DSISS_t3")] = 
#   lapply(df2[,c("DSISS_t1",
#                 "DSISS_t2",
#                 "DSISS_t3")], ordered)

# df2_nonstd[,c("DSISS_t1",
#        "DSISS_t2",
#        "DSISS_t3")] = 
#   lapply(df2_nonstd[,c("DSISS_t1",
#                 "DSISS_t2",
#                 "DSISS_t3")], ordered)

  #Merge df1 and df2 (baseline + 2mo follow up)
    #For dataset 1 (normative college sample), keep baseline and time 3 (2 month FU)
df1_reduce = df1_miss[c("ID"
                   , "mean_ps_1", "mean_ps_3"
                   , "mean_bc_1", "mean_bc_3"
                   , "SOSSs_t1", "SOSSs_t3"
                   , "SOSSi_t1", "SOSSi_t3"
                   , "SOSSg_t1", "SOSSg_t3"
                   , "SSOSH_t1_", "SSOSH_t3_"
                   , "DSISS_t1", "DSISS_t3"
                   )]
    #Rename variables in order to match variables when merging
names(df1_reduce) = c("ID"
                      , "mean_ps_base", "mean_ps_2mo"
                      , "mean_bc_base", "mean_bc_2mo"
                      , "SOSSs_base", "SOSSs_2mo"
                      , "SOSSi_base", "SOSSi_2mo"
                      , "SOSSg_base", "SOSSg_2mo"
                      , "SSOSH_base", "SSOSH_2mo"
                      , "DSISS_base", "DSISS_2mo"
                      )

    #For dataset 2 (recent SI sample), keep baseline and time 2 (2 month FU)
df2_reduce = df2_nonstd[c("Study_ID"
                   , "mean_ps_1", "mean_ps_3"
                   , "mean_bc_1", "mean_bc_3"
                   , "SOSSs_t1", "SOSSs_t3"
                   , "SOSSi_t1", "SOSSi_t3"
                   , "SOSSg_t1", "SOSSg_t3"
                   , "SSOSH_t1", "SSOSH_t3"
                   , "DSISS_t1", "DSISS_t3"
)]

    #Rename variables in order to match variables when merging
names(df2_reduce) = c("ID"
                      , "mean_ps_base", "mean_ps_2mo"
                      , "mean_bc_base", "mean_bc_2mo"
                      , "SOSSs_base", "SOSSs_2mo"
                      , "SOSSi_base", "SOSSi_2mo"
                      , "SOSSg_base", "SOSSg_2mo"
                      , "SSOSH_base", "SSOSH_2mo"
                      , "DSISS_base", "DSISS_2mo"
)

df_merge = rbind(df1_reduce, df2_reduce)

#Reassign unique ID numbers (=IDcount)
library(dplyr)
df_merge = df_merge %>%
  mutate(IDcount = 1:523)

#-----------------------------------------------
#Multiple Imputation
#-----------------------------------------------
#library(mice)
md.pattern(df1)

#df1_mi = mice(df1, m=1, maxit=15, meth="rf", seed=500)
#summary(df1_mi)

#which(is.na(df1_mi$data$DSISS_t2))
#sum(is.na(df1_mi$data$DSISS_t2))

#-----------------------------------------------
#RI-CLPM Dataset 1
#-----------------------------------------------
#Perceived Stigma scale
RICLPM_ps1 = 
'
#Create between components (random interecepts)
RI_ps  =~ 1*mean_ps_1 + 1*mean_ps_2 + 1*mean_ps_3
RI_si =~ 1*DSISS_t1 + 1*DSISS_t2 + 1*DSISS_t3

#Create within-person centered variables
w_ps1 =~ 1*mean_ps_1
w_ps2 =~ 1*mean_ps_2
w_ps3 =~ 1*mean_ps_3
w_si1 =~ 1*DSISS_t1
w_si2 =~ 1*DSISS_t2
w_si3 =~ 1*DSISS_t3

#Estimate lagged effects between within-person centered variables
w_ps2 + w_si2 ~ w_ps1 + w_si1
w_ps3 + w_si3 ~ w_ps2 + w_si2

#Estimate covariance between within-person centered variables at first wave
w_ps1 ~~ w_si1

#Estimate covariances between residuals of within-person centered variables
w_ps2 ~~ w_si2
w_ps3 ~~ w_si3

#Estimate variance and covariance of random intercepts
RI_ps ~~ RI_ps
RI_si ~~ RI_si
RI_ps ~~ RI_si

#Estimate (residual) variance of within-person centered variables
w_ps1 ~~ w_ps1
w_si1 ~~ w_si1
w_ps2 ~~ w_ps2
w_si2 ~~ w_si2
w_ps3 ~~ w_ps3
w_si3 ~~ w_si3
'

RICLPM_ps1.fit = lavaan(RICLPM_ps1
                     , data = df1
                     #, estimator = "WLSMV"
                     #, parameterization = "theta"
                     , missing = "ML"
                     , meanstructure = T
                     , int.ov.free = T
                     #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

RICLPM_ps1miss.fit = lavaan(RICLPM_ps1
                        , data = df1_miss
                        #, estimator = "WLSMV"
                        #, parameterization = "theta"
                        , missing = "ML"
                        , meanstructure = T
                        , int.ov.free = T
                        #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

RICLPM_ps1cc.fit = lavaan(RICLPM_ps1
                            , data = df1_cc
                            #, estimator = "WLSMV"
                            #, parameterization = "theta"
                            , missing = "ML"
                            , meanstructure = T
                            , int.ov.free = T
                            #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

summary(RICLPM_ps1.fit, standardized = T)
summary(RICLPM_ps1miss.fit, standardized = T) #main analysis
fitmeasures(RICLPM_ps1miss.fit)
summary(RICLPM_ps1cc.fit, standardized = T)

#Barriers to Care scale
RICLPM_bc1 = 
  '
#Create between components (random interecepts)
RI_bc  =~ 1*mean_bc_1 + 1*mean_bc_2 + 1*mean_bc_3
RI_si =~ 1*DSISS_t1 + 1*DSISS_t2 + 1*DSISS_t3

#Create within-person centered variables
w_bc1 =~ 1*mean_bc_1
w_bc2 =~ 1*mean_bc_2
w_bc3 =~ 1*mean_bc_3
w_si1 =~ 1*DSISS_t1
w_si2 =~ 1*DSISS_t2
w_si3 =~ 1*DSISS_t3

#Estimate lagged effects between within-person centered variables
w_bc2 + w_si2 ~ w_bc1 + w_si1
w_bc3 + w_si3 ~ w_bc2 + w_si2

#Estimate covariance between within-person centered variables at first wave
w_bc1 ~~ w_si1

#Estimate covariances between residuals of within-person centered variables
w_bc2 ~~ w_si2
w_bc3 ~~ w_si3

#Estimate variance and covariance of random intercepts
RI_bc ~~ RI_bc
RI_si ~~ RI_si
RI_bc ~~ RI_si

#Estimate (residual) variance of within-person centered variables
w_bc1 ~~ w_bc1
w_si1 ~~ w_si1
w_bc2 ~~ w_bc2
w_si2 ~~ w_si2
w_bc3 ~~ w_bc3
w_si3 ~~ w_si3
'
RICLPM_bc1.fit = lavaan(RICLPM_bc1
                        , data = df1
                        #, estimator = "WLSMV"
                        #, parameterization = "theta"
                        , missing = "ML"
                        , meanstructure = T
                        , int.ov.free = T
                        #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

RICLPM_bc1miss.fit = lavaan(RICLPM_bc1
                        , data = df1_miss
                        #, estimator = "WLSMV"
                        #, parameterization = "theta"
                        , missing = "ML"
                        , meanstructure = T
                        , int.ov.free = T
                        #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

RICLPM_bc1cc.fit = lavaan(RICLPM_bc1
                            , data = df1_cc
                            #, estimator = "WLSMV"
                            #, parameterization = "theta"
                            , missing = "ML"
                            , meanstructure = T
                            , int.ov.free = T
                            #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)


summary(RICLPM_bc1.fit, standardized = T)
summary(RICLPM_bc1miss.fit, standardized = T)
fitmeasures(RICLPM_bc1miss.fit)
summary(RICLPM_bc1cc.fit, standardized = T)

#Suicide stigma scale
RICLPM_sosss1 = 
  '
#Create between components (random interecepts)
RI_sosss  =~ 1*SOSSs_t1 + 1*SOSSs_t2 + 1*SOSSs_t3
RI_si =~ 1*DSISS_t1 + 1*DSISS_t2 + 1*DSISS_t3

#Create within-person centered variables
w_sosss1 =~ 1*SOSSs_t1
w_sosss2 =~ 1*SOSSs_t2
w_sosss3 =~ 1*SOSSs_t3
w_si1 =~ 1*DSISS_t1
w_si2 =~ 1*DSISS_t2
w_si3 =~ 1*DSISS_t3

#Estimate lagged effects between within-person centered variables
w_sosss2 + w_si2 ~ w_sosss1 + w_si1
w_sosss3 + w_si3 ~ w_sosss2 + w_si2

#Estimate covariance between within-person centered variables at first wave
w_sosss1 ~~ w_si1

#Estimate covariances between residuals of within-person centered variables
w_sosss2 ~~ w_si2
w_sosss3 ~~ w_si3

#Estimate variance and covariance of random intercepts
RI_sosss ~~ RI_sosss
RI_si ~~ RI_si
RI_sosss ~~ RI_si

#Estimate (residual) variance of within-person centered variables
w_sosss1 ~~ w_sosss1
w_si1 ~~ w_si1
w_sosss2 ~~ w_sosss2
w_si2 ~~ w_si2
w_sosss3 ~~ w_sosss3
w_si3 ~~ w_si3
'

RICLPM_sosss1.fit = lavaan(RICLPM_sosss1
                        , data = df1
                        #, estimator = "WLSMV"
                        #, parameterization = "theta"
                        , missing = "ML"
                        , meanstructure = T
                        , int.ov.free = T
                        #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

RICLPM_sosss1miss.fit = lavaan(RICLPM_sosss1
                           , data = df1_miss
                           #, estimator = "WLSMV"
                           #, parameterization = "theta"
                           , missing = "ML"
                           , meanstructure = T
                           , int.ov.free = T
                           #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

RICLPM_sosss1cc.fit = lavaan(RICLPM_sosss1
                               , data = df1_cc
                               #, estimator = "WLSMV"
                               #, parameterization = "theta"
                               , missing = "ML"
                               , meanstructure = T
                               , int.ov.free = T
                               #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

summary(RICLPM_sosss1.fit, standardized = T)
summary(RICLPM_sosss1miss.fit, standardized = T)
fitmeasures(RICLPM_sosss1miss.fit)
summary(RICLPM_sosss1cc.fit, standardized = T)

#Suicide isolation scale
RICLPM_sossi1 = 
  '
#Create between components (random interecepts)
RI_sossi  =~ 1*SOSSi_t1 + 1*SOSSi_t2 + 1*SOSSi_t3
RI_si =~ 1*DSISS_t1 + 1*DSISS_t2 + 1*DSISS_t3

#Create within-person centered variables
w_sossi1 =~ 1*SOSSi_t1
w_sossi2 =~ 1*SOSSi_t2
w_sossi3 =~ 1*SOSSi_t3
w_si1 =~ 1*DSISS_t1
w_si2 =~ 1*DSISS_t2
w_si3 =~ 1*DSISS_t3

#Estimate lagged effects between within-person centered variables
w_sossi2 + w_si2 ~ w_sossi1 + w_si1
w_sossi3 + w_si3 ~ w_sossi2 + w_si2

#Estimate covariance between within-persona centered variables at first wave
w_sossi1 ~~ w_si1

#Estimate covariances between residuals of within-person centered variables
w_sossi2 ~~ w_si2
w_sossi3 ~~ w_si3

#Estimate variance and covariance of random intercepts
RI_sossi ~~ RI_sossi
RI_si ~~ RI_si
RI_sossi ~~ RI_si

#Estimate (residual) variance of within-person centered variables
w_sossi1 ~~ w_sossi1
w_si1 ~~ w_si1
w_sossi2 ~~ w_sossi2
w_si2 ~~ w_si2
w_sossi3 ~~ w_sossi3
w_si3 ~~ w_si3
'
RICLPM_sossi1.fit = lavaan(RICLPM_sossi1
                           , data = df1
                           #, estimator = "WLSMV"
                           #, parameterization = "theta"
                           , missing = "ML"
                           , meanstructure = T
                           , int.ov.free = T
                           #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

RICLPM_sossi1miss.fit = lavaan(RICLPM_sossi1
                           , data = df1_miss
                           #, estimator = "WLSMV"
                           #, parameterization = "theta"
                           , missing = "FIML"
                           , meanstructure = T
                           , int.ov.free = T
                           #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

RICLPM_sossi1cc.fit = lavaan(RICLPM_sossi1
                               , data = df1_cc
                               #, estimator = "WLSMV"
                               #, parameterization = "theta"
                               , missing = "FIML"
                               , meanstructure = T
                               , int.ov.free = T
                               #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

summary(RICLPM_sossi1.fit, standardized = T)
summary(RICLPM_sossi1miss.fit, standardized = T)
fitmeasures(RICLPM_sossi1miss.fit)
summary(RICLPM_sossi1cc.fit, standardized = T)

#Suicide glorification scale
RICLPM_sossg1 = 
  '
#Create between components (random interecepts)
RI_sossg  =~ 1*SOSSg_t1 + 1*SOSSg_t2 + 1*SOSSg_t3
RI_si =~ 1*DSISS_t1 + 1*DSISS_t2 + 1*DSISS_t3

#Create within-person centered variables
w_sossg1 =~ 1*SOSSg_t1
w_sossg2 =~ 1*SOSSg_t2
w_sossg3 =~ 1*SOSSg_t3
w_si1 =~ 1*DSISS_t1
w_si2 =~ 1*DSISS_t2
w_si3 =~ 1*DSISS_t3

#Estimate lagged effects between within-person centered variables
w_sossg2 + w_si2 ~ w_sossg1 + w_si1
w_sossg3 + w_si3 ~ w_sossg2 + w_si2

#Estimate covariance between within-persona centered variables at first wave
w_sossg1 ~~ w_si1

#Estimate covariances between residuals of within-person centered variables
w_sossg2 ~~ w_si2
w_sossg3 ~~ w_si3

#Estimate variance and covariance of random intercepts
RI_sossg ~~ RI_sossg
RI_si ~~ RI_si
RI_sossg ~~ RI_si

#Estimate (residual) variance of within-person centered variables
w_sossg1 ~~ w_sossg1
w_si1 ~~ w_si1
w_sossg2 ~~ w_sossg2
w_si2 ~~ w_si2
w_sossg3 ~~ w_sossg3
w_si3 ~~ w_si3
'

RICLPM_sossg1.fit = lavaan(RICLPM_sossg1
                           , data = df1
                           #, estimator = "WLSMV"
                           #, parameterization = "theta"
                           , missing = "ML"
                           , meanstructure = T
                           , int.ov.free = T
                           #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

RICLPM_sossg1miss.fit = lavaan(RICLPM_sossg1
                           , data = df1_miss
                           #, estimator = "WLSMV"
                           #, parameterization = "theta"
                           , missing = "ML"
                           , meanstructure = T
                           , int.ov.free = T
                           #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

RICLPM_sossg1cc.fit = lavaan(RICLPM_sossg1
                               , data = df1_cc
                               #, estimator = "WLSMV"
                               #, parameterization = "theta"
                               , missing = "ML"
                               , meanstructure = T
                               , int.ov.free = T
                               #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

summary(RICLPM_sossg1.fit, standardized = T)
summary(RICLPM_sossg1miss.fit, standardized = T)
fitmeasures(RICLPM_sossg1miss.fit)
summary(RICLPM_sossg1cc.fit, standardized = T)

#Stigma of seeking help scale
RICLPM_ssosh1 = 
  '
#Create between components (random interecepts)
RI_ssosh  =~ 1*SSOSH_t1_ + 1*SSOSH_t2_ + 1*SSOSH_t3_
RI_si =~ 1*DSISS_t1 + 1*DSISS_t2 + 1*DSISS_t3

#Create within-person centered variables
w_ssosh1 =~ 1*SSOSH_t1_
w_ssosh2 =~ 1*SSOSH_t2_
w_ssosh3 =~ 1*SSOSH_t3_
w_si1 =~ 1*DSISS_t1
w_si2 =~ 1*DSISS_t2
w_si3 =~ 1*DSISS_t3

#Estimate lagged effects between within-person centered variables
w_ssosh2 + w_si2 ~ w_ssosh1 + w_si1
w_ssosh3 + w_si3 ~ w_ssosh2 + w_si2

#Estimate covariance between within-persona centered variables at first wave
w_ssosh1 ~~ w_si1

#Estimate covariances between residuals of within-person centered variables
w_ssosh2 ~~ w_si2
w_ssosh3 ~~ w_si3

#Estimate variance and covariance of random intercepts
RI_ssosh ~~ RI_ssosh
RI_si ~~ RI_si
RI_ssosh ~~ RI_si

#Estimate (residual) variance of within-person centered variables
w_ssosh1 ~~ w_ssosh1
w_si1 ~~ w_si1
w_ssosh2 ~~ w_ssosh2
w_si2 ~~ w_si2
w_ssosh3 ~~ w_ssosh3
w_si3 ~~ w_si3
'

RICLPM_ssosh1.fit = lavaan(RICLPM_ssosh1
                           , data = df1
                           # estimator = "WLSMV"
                           #, parameterization = "theta"
                           , missing = "ML"
                           , meanstructure = T
                           , int.ov.free = T
                           #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

RICLPM_ssosh1miss.fit = lavaan(RICLPM_ssosh1
                           , data = df1_miss
                           # estimator = "WLSMV"
                           #, parameterization = "theta"
                           , missing = "ML"
                           , meanstructure = T
                           , int.ov.free = T
                           #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

RICLPM_ssosh1cc.fit = lavaan(RICLPM_ssosh1
                               , data = df1_cc
                               # estimator = "WLSMV"
                               #, parameterization = "theta"
                               , missing = "ML"
                               , meanstructure = T
                               , int.ov.free = T
                               #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

summary(RICLPM_ssosh1.fit, standardized = T)
summary(RICLPM_ssosh1miss.fit, standardized = T)
fitmeasures(RICLPM_ssosh1miss.fit)
summary(RICLPM_ssosh1cc.fit, standardized = T)

#-----------------------------------------------
#RI-CLPM Dataset 2
#-----------------------------------------------
#Perceived Stigma scale
RICLPM_ps2 =
  '
#Create between components (random intercepts)
RI_ps  =~ 1*mean_ps_1 + 1*mean_ps_2 + 1*mean_ps_3
RI_si =~ 1*DSISS_t1 + 1*DSISS_t2 + 1*DSISS_t3

#Create within-person centered variables
w_ps1 =~ 1*mean_ps_1
w_ps2 =~ 1*mean_ps_2
w_ps3 =~ 1*mean_ps_3
w_si1 =~ 1*DSISS_t1
w_si2 =~ 1*DSISS_t2
w_si3 =~ 1*DSISS_t3

#Estimate lagged effects between within-person centered variables
w_ps2 + w_si2 ~ w_ps1 + w_si1
w_ps3 + w_si3 ~ w_ps2 + w_si2

#Estimate covariance between within-persona centered variables at first wave
w_ps1 ~~ w_si1

#Estimate covariances between residuals of within-person centered variables
w_ps2 ~~ w_si2
w_ps3 ~~ w_si3

#Estimate variance and covariance of random intercepts
RI_ps ~~ RI_ps
RI_si ~~ RI_si
RI_ps ~~ RI_si

#Estimate (residual) variance of within-person centered variables
w_ps1 ~~ w_ps1
w_si1 ~~ w_si1
w_ps2 ~~ w_ps2
w_si2 ~~ w_si2
w_ps3 ~~ w_ps3
w_si3 ~~ w_si3
'

RICLPM_ps2.fit = lavaan(RICLPM_ps2
                        , data = df2
                        #, estimator = "WLSMV"
                        #, parameterization = "theta"
                        , missing = "ML"
                        , meanstructure = T
                        , int.ov.free = T
                        #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

RICLPM_ps2miss.fit = lavaan(RICLPM_ps2
                        , data = df2_nonstd
                        #, estimator = "WLSMV"
                        #, parameterization = "theta"
                        , missing = "ML"
                        , meanstructure = T
                        , int.ov.free = T
                        #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

RICLPM_ps2cc.fit = lavaan(RICLPM_ps2
                            , data = df2_cc
                            #, estimator = "WLSMV"
                            #, parameterization = "theta"
                            , missing = "ML"
                            , meanstructure = T
                            , int.ov.free = T
                            #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

summary(RICLPM_ps2.fit, standardized = T)
summary(RICLPM_ps2miss.fit, standardized = T)
fitmeasures(RICLPM_ps2miss.fit)
summary(RICLPM_ps2cc.fit, standardized = T)

#Barriers to Care scale
RICLPM_bc2.fit = lavaan(RICLPM_bc1
                        , data = df2
                        #, estimator = "WLSMV"
                        #, parameterization = "theta"
                        , missing = "ML"
                        , meanstructure = T
                        , int.ov.free = T
                        #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

RICLPM_bc2miss.fit = lavaan(RICLPM_bc1
                            , data = df2_nonstd
                            #, estimator = "WLSMV"
                            #, parameterization = "theta"
                            , missing = "ML"
                            , meanstructure = T
                            , int.ov.free = T
                            #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

RICLPM_bc2cc.fit = lavaan(RICLPM_bc1
                            , data = df2_cc
                            #, estimator = "WLSMV"
                            #, parameterization = "theta"
                            , missing = "ML"
                            , meanstructure = T
                            , int.ov.free = T
                            #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

summary(RICLPM_bc2.fit, standardized = T)
summary(RICLPM_bc2miss.fit, standardized = T)
fitmeasures(RICLPM_bc2miss.fit)
summary(RICLPM_bc2cc.fit, standardized = T)


#Suicide stigma scale
RICLPM_sosss2.fit = lavaan(RICLPM_sosss1
                           , data = df2
                           #, estimator = "WLSMV"
                           #, parameterization = "theta"
                           , missing = "ML"
                           , meanstructure = T
                           , int.ov.free = T
                           #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

RICLPM_sosss2miss.fit = lavaan(RICLPM_sosss1
                               , data = df2_nonstd
                               #, estimator = "WLSMV"
                               #, parameterization = "theta"
                               , missing = "ML"
                               , meanstructure = T
                               , int.ov.free = T
                               #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

RICLPM_sosss2cc.fit = lavaan(RICLPM_sosss1
                               , data = df2_cc
                               #, estimator = "WLSMV"
                               #, parameterization = "theta"
                               , missing = "ML"
                               , meanstructure = T
                               , int.ov.free = T
                               #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

summary(RICLPM_sosss2.fit, standardized = T)
summary(RICLPM_sosss2miss.fit, standardized = T)
fitmeasures(RICLPM_sosss2miss.fit)
summary(RICLPM_sosss2cc.fit, standardized = T)

#Suicide isolation subscale
RICLPM_sossi2.fit = lavaan(RICLPM_sossi1
                           , data = df2
                           #, estimator = "WLSMV"
                           #, parameterization = "theta"
                           , missing = "ML"
                           , meanstructure = T
                           , int.ov.free = T
                           #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

RICLPM_sossi2miss.fit = lavaan(RICLPM_sossi1
                               , data = df2_nonstd
                               #, estimator = "WLSMV"
                               #, parameterization = "theta"
                               , missing = "ML"
                               , meanstructure = T
                               , int.ov.free = T
                               #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

RICLPM_sossi2cc.fit = lavaan(RICLPM_sossi1
                               , data = df2_cc
                               #, estimator = "WLSMV"
                               #, parameterization = "theta"
                               , missing = "ML"
                               , meanstructure = T
                               , int.ov.free = T
                               #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

summary(RICLPM_sossi2.fit, standardized = T)
summary(RICLPM_sossi2miss.fit, standardized = T)
fitmeasures(RICLPM_sossi2miss.fit)
summary(RICLPM_sossi2cc.fit, standardized = T)

#Suicide glorification subscale
RICLPM_sossg2.fit = lavaan(RICLPM_sossg1
                           , data = df2
                           #, estimator = "WLSMV"
                           #, parameterization = "theta"
                           , missing = "ML"
                           , meanstructure = T
                           , int.ov.free = T
                           #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

RICLPM_sossg2miss.fit = lavaan(RICLPM_sossg1
                               , data = df2_nonstd
                               #, estimator = "WLSMV"
                               #, parameterization = "theta"
                               , missing = "ML"
                               , meanstructure = T
                               , int.ov.free = T
                               #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

RICLPM_sossg2cc.fit = lavaan(RICLPM_sossg1
                               , data = df2_cc
                               #, estimator = "WLSMV"
                               #, parameterization = "theta"
                               , missing = "ML"
                               , meanstructure = T
                               , int.ov.free = T
                               #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

summary(RICLPM_sossg2.fit, standardized = T)
summary(RICLPM_sossg2miss.fit, standardized = T)
fitmeasures(RICLPM_sossg2miss.fit)
summary(RICLPM_sossg2cc.fit, standardized = T)

#Stigma of seeking help scale
RICLPM_ssosh2 = 
  '
#Create between components (random interecepts)
RI_ssosh  =~ 1*SSOSH_t1 + 1*SSOSH_t2 + 1*SSOSH_t3
RI_si =~ 1*DSISS_t1 + 1*DSISS_t2 + 1*DSISS_t3

#Create within-person centered variables
w_ssosh1 =~ 1*SSOSH_t1
w_ssosh2 =~ 1*SSOSH_t2
w_ssosh3 =~ 1*SSOSH_t3
w_si1 =~ 1*DSISS_t1
w_si2 =~ 1*DSISS_t2
w_si3 =~ 1*DSISS_t3

#Estimate lagged effects between within-person centered variables
w_ssosh2 + w_si2 ~ w_ssosh1 + w_si1
w_ssosh3 + w_si3 ~ w_ssosh2 + w_si2

#Estimate covariance between within-persona centered variables at first wave
w_ssosh1 ~~ w_si1

#Estimate covariances between residuals of within-person centered variables
w_ssosh2 ~~ w_si2
w_ssosh3 ~~ w_si3

#Estimate variance and covariance of random intercepts
RI_ssosh ~~ RI_ssosh
RI_si ~~ RI_si
RI_ssosh ~~ RI_si

#Estimate (residual) variance of within-person centered variables
w_ssosh1 ~~ w_ssosh1
w_si1 ~~ w_si1
w_ssosh2 ~~ w_ssosh2
w_si2 ~~ w_si2
w_ssosh3 ~~ w_ssosh3
w_si3 ~~ w_si3
'

RICLPM_ssosh2.fit = lavaan(RICLPM_ssosh2
                           , data = df2
                           # estimator = "WLSMV"
                           #, parameterization = "theta"
                           , missing = "ML"
                           , meanstructure = T
                           , int.ov.free = T
                           #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

RICLPM_ssosh2miss.fit = lavaan(RICLPM_ssosh2
                               , data = df2_nonstd
                               # estimator = "WLSMV"
                               #, parameterization = "theta"
                               , missing = "ML"
                               , meanstructure = T
                               , int.ov.free = T
                               #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

RICLPM_ssosh2cc.fit = lavaan(RICLPM_ssosh2
                               , data = df2_cc
                               # estimator = "WLSMV"
                               #, parameterization = "theta"
                               , missing = "ML"
                               , meanstructure = T
                               , int.ov.free = T
                               #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

summary(RICLPM_ssosh2.fit, standardized = T)
summary(RICLPM_ssosh2miss.fit, standardized = T)
fitmeasures(RICLPM_ssosh2miss.fit)
summary(RICLPM_ssosh2cc.fit, standardized = T)





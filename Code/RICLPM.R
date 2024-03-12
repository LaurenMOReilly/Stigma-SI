#-----------------------------------------------
#Project title: Association between MH stigma and SI - RI-CLPM
#Date: 6/29/2023
#Author: Lauren OReilly
#Changes: 3/12/2024 Cleaned for GitHub
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
  #Study 1
df1_miss = as.data.frame(read_sas("C:/Users/loreilly/OneDrive - Indiana University/My Passport Backup/Internship Resources/Stigma/suistg_1.sas7bdat"))
   #Complete case dataset
df1_cc = as.data.frame(read_sas("C:/Users/loreilly/OneDrive - Indiana University/My Passport Backup/Internship Resources/Stigma/suistg_2.sas7bdat"))

  #Study 2
df2_nonstd = as.data.frame(read_sas("C:/Users/loreilly/OneDrive - Indiana University/My Passport Backup/Internship Resources/Stigma/hom_1.sas7bdat"))
   #Complete case dataset
df2_cc = as.data.frame(read_sas("C:/Users/loreilly/OneDrive - Indiana University/My Passport Backup/Internship Resources/Stigma/hom_5.sas7bdat"))


#-----------------------------------------------
#RI-CLPM Study 1
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

RICLPM_ps1miss.fit = lavaan(RICLPM_ps1
                        , data = df1_miss
                        #, estimator = "WLSMV"
                        #, parameterization = "theta"
                        , missing = "ML"
                        , meanstructure = T
                        , int.ov.free = T
                        #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

summary(RICLPM_ps1miss.fit, standardized = T) #main analysis
fitmeasures(RICLPM_ps1miss.fit)


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

RICLPM_bc1miss.fit = lavaan(RICLPM_bc1
                        , data = df1_miss
                        #, estimator = "WLSMV"
                        #, parameterization = "theta"
                        , missing = "ML"
                        , meanstructure = T
                        , int.ov.free = T
                        #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

summary(RICLPM_bc1miss.fit, standardized = T)
fitmeasures(RICLPM_bc1miss.fit)


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

RICLPM_sosss1miss.fit = lavaan(RICLPM_sosss1
                           , data = df1_miss
                           #, estimator = "WLSMV"
                           #, parameterization = "theta"
                           , missing = "ML"
                           , meanstructure = T
                           , int.ov.free = T
                           #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

summary(RICLPM_sosss1miss.fit, standardized = T)
fitmeasures(RICLPM_sosss1miss.fit)


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

RICLPM_sossi1miss.fit = lavaan(RICLPM_sossi1
                           , data = df1_miss
                           #, estimator = "WLSMV"
                           #, parameterization = "theta"
                           , missing = "FIML"
                           , meanstructure = T
                           , int.ov.free = T
                           #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

summary(RICLPM_sossi1miss.fit, standardized = T)
fitmeasures(RICLPM_sossi1miss.fit)


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

RICLPM_sossg1miss.fit = lavaan(RICLPM_sossg1
                           , data = df1_miss
                           #, estimator = "WLSMV"
                           #, parameterization = "theta"
                           , missing = "ML"
                           , meanstructure = T
                           , int.ov.free = T
                           #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

summary(RICLPM_sossg1miss.fit, standardized = T)
fitmeasures(RICLPM_sossg1miss.fit)


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

RICLPM_ssosh1miss.fit = lavaan(RICLPM_ssosh1
                           , data = df1_miss
                           # estimator = "WLSMV"
                           #, parameterization = "theta"
                           , missing = "ML"
                           , meanstructure = T
                           , int.ov.free = T
                           #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

summary(RICLPM_ssosh1miss.fit, standardized = T)
fitmeasures(RICLPM_ssosh1miss.fit)


#-----------------------------------------------
#RI-CLPM Study 2 2
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

RICLPM_ps2miss.fit = lavaan(RICLPM_ps2
                        , data = df2_nonstd
                        #, estimator = "WLSMV"
                        #, parameterization = "theta"
                        , missing = "ML"
                        , meanstructure = T
                        , int.ov.free = T
                        #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

summary(RICLPM_ps2miss.fit, standardized = T)
fitmeasures(RICLPM_ps2miss.fit)


#Barriers to Care scale
RICLPM_bc2miss.fit = lavaan(RICLPM_bc1
                            , data = df2_nonstd
                            #, estimator = "WLSMV"
                            #, parameterization = "theta"
                            , missing = "ML"
                            , meanstructure = T
                            , int.ov.free = T
                            #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

summary(RICLPM_bc2miss.fit, standardized = T)
fitmeasures(RICLPM_bc2miss.fit)


#Suicide stigma scale
RICLPM_sosss2miss.fit = lavaan(RICLPM_sosss1
                               , data = df2_nonstd
                               #, estimator = "WLSMV"
                               #, parameterization = "theta"
                               , missing = "ML"
                               , meanstructure = T
                               , int.ov.free = T
                               #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

summary(RICLPM_sosss2miss.fit, standardized = T)
fitmeasures(RICLPM_sosss2miss.fit)


#Suicide isolation subscale
RICLPM_sossi2miss.fit = lavaan(RICLPM_sossi1
                               , data = df2_nonstd
                               #, estimator = "WLSMV"
                               #, parameterization = "theta"
                               , missing = "ML"
                               , meanstructure = T
                               , int.ov.free = T
                               #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

summary(RICLPM_sossi2miss.fit, standardized = T)
fitmeasures(RICLPM_sossi2miss.fit)


#Suicide glorification subscale
RICLPM_sossg2miss.fit = lavaan(RICLPM_sossg1
                               , data = df2_nonstd
                               #, estimator = "WLSMV"
                               #, parameterization = "theta"
                               , missing = "ML"
                               , meanstructure = T
                               , int.ov.free = T
                               #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

summary(RICLPM_sossg2miss.fit, standardized = T)
fitmeasures(RICLPM_sossg2miss.fit)


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

RICLPM_ssosh2miss.fit = lavaan(RICLPM_ssosh2
                               , data = df2_nonstd
                               # estimator = "WLSMV"
                               #, parameterization = "theta"
                               , missing = "ML"
                               , meanstructure = T
                               , int.ov.free = T
                               #, ordered = c("DSISS_t1", "DSISS_t2", "DSISS_t3")
)

summary(RICLPM_ssosh2miss.fit, standardized = T)
fitmeasures(RICLPM_ssosh2miss.fit)

#End





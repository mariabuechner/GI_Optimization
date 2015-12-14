# basic libraries
library(shiny)
require(ggplot2)
require(plyr)
library(scales)
require(markdown)
library(Cairo)
options(shiny.usecairo=T)

source('geometry.R')
source('filtering.R')
source('visibility.R')

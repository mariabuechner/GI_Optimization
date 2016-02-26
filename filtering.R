filters = list.files(path="filters", pattern="*.csv")
samples = list.files(path="samples", pattern="*.csv")

filtering.readFilter <- function(inputFile) {
  # inputFile: .csv file according to the followng format
  # energy,mu,density [keV],[cm2/g],[g/cm3]
  # 10,2.623e+1,2.70
  # 15,7.955e+0
  # 20,3.441e+0
  # ...,...
  filePath = sprintf(inputFile)
  inputFilter = read.csv(filePath) # 3 columns labeled 'energy' [keV] and 'mu' [cm2/g] and 'density' [g/cm3]
  return(inputFilter)
}

filtering.interpolateFilter <- function(filter, energies) {
  # Interpolate absorption coefficients to eneries of input spectrum
  interpolatedFilter = approx(filter$energy, filter$mu, energies)
  # Make data frame
  interpolatedFilter = data.frame(interpolatedFilter)
  # Rename entries
  names(interpolatedFilter) <- c("energy", "mu")
  return(interpolatedFilter)
}

filtering.filterEnergies <- function(filter, filterThickness, energies, photons) {
  interpolatedFilter = filtering.interpolateFilter(filter, energies)
  filteredSpectrum <- data.frame(energy = energies,
                                 photons = photons * exp(-interpolatedFilter$mu * filter$density[1] * filterThickness/10)) 
  return(filteredSpectrum)
}
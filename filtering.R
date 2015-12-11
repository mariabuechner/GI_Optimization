filters = list.files(path="filters", pattern="*.csv")

filtering.readFilter <- function(inputFile) {
  filePath = sprintf("filters/%s", inputFile)
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
                                 photons = photons * exp(-interpolatedFilter$mu * filter$density[1] * filterThickness)) 
  return(filteredSpectrum)
}
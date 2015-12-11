spectra = list.files(path="spectra", pattern="*.csv")

visibility.readSpectrum <- function(inputFile) {
  filePath = sprintf("spectra/%s", inputFile)
  inputSpectrum = read.csv(filePath) # 2 columns labeled 'energy' [keV] and 'photons'
  # Normalize
  inputSpectrum$photons = inputSpectrum$photons/sum(inputSpectrum$photons)
  return(inputSpectrum)
}

visibility.calcVisibilities <- function(designEnergy, talbotOrder, energies, photons) {
  # Calculate normalized visibility for specific Talbot order, design energy. For all energies and number of photons
  visibilities = (2/pi)*abs(sin((pi/2)*(designEnergy/energies))^2*sin((pi/2)*(talbotOrder*designEnergy/energies)))
  visibilities = visibilities*photons
  return(visibilities)
}

visibility.maxVisibility <- function(visibilities) {
  # Returns the maximum visibility summed up over all energies
  visibility = sum(visibilities)
  return(visibility)
}

visibility.MaxVisibilityEnergies <- function(Order, designEnergies, spectrumPhotons) {
  # Calculate the maximum visibility for a fixed Tablor order over all design energies
  visibilityRange = lapply(designEnergies, visibility.calcVisibilities, talbotOrder=Order, energies=designEnergies, photons=spectrumPhotons)
  maxVisibilityRange = lapply(visibilityRange, sum)
  maxVisibilityRange = as.numeric(unlist(do.call(c, apply(do.call(rbind, maxVisibilityRange), 2, list))))
  return(maxVisibilityRange)
}

visibility.MaxVisibilityTalbots <- function(Orders, dEnergy, spectrumEnergies, spectrumPhotons) {
  # Calculate the maximum visibility for a fixed design energy over all Tablor orders
  visibilityRange = lapply(Orders, visibility.calcVisibilities, designEnergy=dEnergy, energies=spectrumEnergies, photons=spectrumPhotons)
  maxVisibilityRange = lapply(visibilityRange, sum)
  # Convert to percent
  maxVisibilityRange = lapply(maxVisibilityRange, function(x) x*100)
  # Bind with talbot orders
  maxVisibilityRange = cbind(m = Orders, vis = maxVisibilityRange)
  # Change column names
  colnames(maxVisibilityRange) <- c("m", paste("Visibility [%]"))
  return(maxVisibilityRange)
}
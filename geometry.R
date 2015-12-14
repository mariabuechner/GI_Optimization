geometry.calcParameters <- function(designEnergy, talbotOrder, geometryType, smallestPitch,
                                    fixedLengthType, fixedLength, piHalfShift) {
  # Init final list
  entryNames = c("p0","p1","p2","G0G1","G1G2","systemLength","talbotDistance")
  GI = setNames(vector("list", length(entryNames)), entryNames)
  
  # Phase shift factor
  if (piHalfShift) {
    phaseFactor = 1
  } else {
    phaseFactor = 2
  }
  # Wavelength
  lambda = geometry.calcWavelength(designEnergy)
  
  # Inverse geometry
  if (geometryType == "Inverse") {
    # Set smallest grating pitch to G0
    GI$p0 = smallestPitch
  }
  # Symmetrical geometry
  else if (geometryType == "Symmetrical") {
    # Set smallest grating pitch to G2
    GI$p2 = smallestPitch # [um]
    GI$p0 = GI$p2 # [um]
    GI$p1 = phaseFactor * GI$p2 / 2  # [um]
    # Talbot distance
    GI$talbotDistance = 2 * talbotOrder * GI$p1^2 / (phaseFactor^2 * 2*lambda) # [um]
    GI$talbotDistance = GI$talbotDistance * 1e-3 # [mm]
    # Distances
    GI$systemLength = 2*GI$talbotDistance # [mm]
    GI$G0G1 = GI$systemLength/2 # [mm]
    GI$G1G2 = GI$G0G1 # [mm]
  }
  # Coventional
  else {
    # Set smallest grating pitch to G2
    GI$p2 = smallestPitch
  }
  return(GI)
}

geometry.calcWavelength <- function(designEnergy)  {
  # designEnergy in [keV]
  # returns wavelength in [um]
  
  h = 6.62606957e-34 # [Js]
  c = 299792458 # [m/s]
  
  designEnergy = designEnergy * 1e3 * 1.602176565e-19 # [keV -> eV -> J]
  lambda = h * c / designEnergy # [m]
  lambda = lambda * 1e6 # [um]
  return(lambda)
}
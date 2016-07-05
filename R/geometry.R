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

geometry.calcSymmetric <- function(GI, smallestPitch, phaseFactor, talbotOrder, lambda) {
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
  return(GI)
}

geometry.calcInverse <- function(GI, smallestPitch, G0G1Distance, phaseFactor, talbotOrder, lambda) {
  # Set smallest grating pitch to G0 and GoG1 distance
  GI$p0 = smallestPitch # [um]
  GI$G0G1 = G0G1Distance # [mm]
  # Calc talbot distance based on G0G1Distance and p0
  # according to: d_n = l^2/(n/2lambda * p0^2 - l)
  GI$talbotDistance = (GI$G0G1^2) / ((talbotOrder*(GI$p0*1e-3)^2)/(2*(lambda*1e-3)) - GI$G0G1) # [mm]
  GI$G1G2 = GI$talbotDistance # [mm]
  GI$systemLength = GI$G0G1 + GI$G1G2 # [mm]
  # Calc remaining pitches
  GI$p2 = GI$p0*GI$G1G2/GI$G0G1 # p0 * d_n/l [um]
  GI$p1 = phaseFactor * GI$p2 * GI$G0G1/(GI$systemLength) # ny*p2*l/(l+d_n) [um]
  return(GI)
}

geometry.calcParameters <- function(designEnergy, talbotOrder, geometryType, smallestPitch,
                                    G0G1Distance, piHalfShift) {
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
  
  if (geometryType == "Inverse") {
    GI = geometry.calcInverse(GI, smallestPitch, G0G1Distance, phaseFactor, talbotOrder, lambda)
  }
  else if (geometryType == "Symmetrical") {
    GI = geometry.calcSymmetric(GI, smallestPitch, phaseFactor, talbotOrder, lambda)
  }
  else {
    # Set smallest grating pitch to G2
    GI$p2 = smallestPitch
  }
  return(GI)
}
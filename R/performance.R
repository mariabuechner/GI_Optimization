performance.calcCNRRatio <-function (gA, a, f, vis, distance, p, lambda, deltaMu, deltaPhi) {
  # Input
  # gA:           spatial resolution factor from reconstruction
  # a:            pixel size [um] projected to isocenter
  # f:            post-sample absorption factor abs. vs. phase
  # vis:          visibility
  # distance:     Distance G0 to G1 (inverse), or G1 to G2 (comv/sym) [mm]
  # p:            smalles pitch (p0 inverse, p2 vonc/sym) [um]
  # lambda:       wavelength [um]
  # deltaMu:      mass attenuation coefficient [1/cm] (4*pi/lambda * beta) (from table is mu/rho!)
  # deltaPhi:     phase shift (phi = 2*pi/lambda * delta [1/cm])
  # Noise is missing in equation!!!
  spatialResolutionFactor = gA^2 / a^2 # [(lp)/um^2]
  sampleAttenuatiuonFactor = 2/f # [1]
  giFactors = vis*distance*1e3/p # [um/um] = [1]
  sampleSignal = deltaPhi/(deltaMu) # [1]
  # Calc CNR ratio (phase over abs)
  nu = spatialResolutionFactor*sampleAttenuatiuonFactor*(giFactors*lambda*abs(sampleSignal))^2 # [(lp)/um^2 * (um)^2] = [1]
  return(sqrt(nu))
  #return(sampleSignal)
}

# Read delta
performance.readDelta <- function(inputFile) {
  # inputFile: .csv file according to the followng format
  # energy,delta [keV],[1]
  filePath = sprintf(inputFile)
  deltaFile = read.csv(filePath) # 2 columns labeled 'energy' [keV] and 'delta' [1]
  return(deltaFile)
}
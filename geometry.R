geometry.calcParameters <- function(designEnergy, talbotOrder, geometryType, smallestPitch,
                                    fixedLengthType, fixedLength, piHalfShift) {
  # Init final list
  entryNames = c("p0","p1","p2","G0G1","G1G2","systemLength","talbotDistance")
  GI = setNames(vector("list", length(entryNames)), entryNames)
  
  # Inverse geometry
  if (geometryType == "Inverse") {
    # Set smallest grating pitch to G0
    GI$p0 = smallestPitch
  }
  # Symmetrical geometry
  else if (geometryType == "Symmetrical") {
    # Set smallest grating pitch to G2
    GI$p2 = smallestPitch
    # Check fixed length
  }
  # Coventional
  else {
    # Set smallest grating pitch to G2
    GI$p2 = smallestPitch
  }
}
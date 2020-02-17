pro overRideRPC, input
  rpb = READ_ASCII(input.Replace('tiff', 'rpb'))
  rpb = rpb.FIELD1
  linnum=rpb[0,17:36]
  linden = rpb[0, 38:57]
  samnum = rpb[0, 59:78]
  samden=rpb[0,80:99]
  off=rpb[2,6:10]
  scale = rpb[2,11:15]
  sr =ENVIRPCRasterSpatialRef($
    RPC_LINE_DEN_COEFF=linden, $
    RPC_LINE_NUM_COEFF=linnum, $
    RPC_SAMP_DEN_COEFF=samden, $
    RPC_SAMP_NUM_COEFF=samnum, $
    RPC_OFFSETS=off, RPC_SCALES=scale)
  raster = !e.OpenRaster(input, SPATIALREF_OVERRIDE=sr)
  raster.WriteMetadata
  raster.Close
end
pro orthorectification, input, dem, output = fn
  inRaster = !e.OpenRaster(input)
  fn = !e.GetTemporaryFilename()
  ort = ENVITask('RPCOrthorectification')
  ort.DEM_RASTER = dem
  ort.INPUT_RASTER = inRaster
  ort.OUTPUT_RASTER_URI = fn
  ort.Execute
  ort.OUTPUT_RASTER.Close
  inRaster.Close
end
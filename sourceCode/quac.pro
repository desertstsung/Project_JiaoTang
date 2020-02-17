pro quac, input, output = fn
  inr = !e.OpenRaster(input)
  fn = !e.GetTemporaryFilename()
  qac = ENVITask('QUAC')
  qac.INPUT_RASTER = inr
  qac.OUTPUT_RASTER_URI = fn
  qac.Execute
  qac.OUTPUT_RASTER.Close
  inr.Close
end
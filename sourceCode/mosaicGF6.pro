pro mosaicGF6, inputArray, output = fn
  fn = !e.GetTemporaryFilename()
  msc = ENVITask('BuildMosaicRaster')
  scenes = !NULL
  foreach element, inputArray do begin
    inr = !e.OpenRaster(element)
    mtd = inr.METADATA
    mtd.AddItem, 'data ignore value', 0
    scenes = [scenes, inr]
  endforeach
  msc.INPUT_RASTERS = scenes
  msc.OUTPUT_RASTER_URI = fn
  msc.Execute
  foreach element, scenes do begin
    element.Close
  endforeach
  msc.OUTPUT_RASTER.Close
end
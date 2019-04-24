PRO mosaicGF6, inputArray, output = fn
  fn = !e.GetTemporaryFilename()
  msc = ENVITask('BuildMosaicRaster')
  scenes = !NULL
  FOREACH element, inputArray DO BEGIN
    inr = !e.OpenRaster(element)
    mtd = inr.METADATA
    mtd.AddItem, 'data ignore value', 0
    scenes = [scenes, inr]
  ENDFOREACH
  msc.INPUT_RASTERS = scenes
  msc.OUTPUT_RASTER_URI = fn
  msc.Execute
  FOREACH element, scenes DO BEGIN
    element.Close
  ENDFOREACH
  msc.OUTPUT_RASTER.Close
END
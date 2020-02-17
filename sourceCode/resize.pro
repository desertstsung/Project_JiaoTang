pro resize, mssRaster, panRaster, output = fn
  fn = !e.GetTemporaryFilename()
  mssSR = mssRaster.SPATIALREF
  mssRes = FLOAT(mssSR.PIXEL_SIZE)
  panSR = panRaster.SPATIALREF
  panRes = FLOAT(panSR.PIXEL_SIZE)
  resize_flag = mssRes mod panRes

  if resize_flag[0] ne 0 then begin
    rsz = ENVITask('PixelScaleResampleRaster')
    rsz.INPUT_RASTER = mssRaster
    rsz.PIXEL_SCALE = (FLOOR(mssRes / panRes) * panRes) / mssRes
    rsz.OUTPUT_RASTER_URI = fn
    rsz.Execute
    rsz.OUTPUT_RASTER.Close
    mssRaster.Close
    mssRaster = !e.OpenRaster(fn)
  endif
end
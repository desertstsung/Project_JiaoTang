FUNCTION shpInRaster, input, region
  inRaster = !e.OpenRaster(input)
  shpObj = IDLffShape(region)
  entity = shpObj.GetEntity(0, /ATTRIBUTES)
  verts = *(entity.VERTICES)
  newROI = ENVIROI(NAME = 'shp2ROI')
  newROI.AddGeometry, verts, $
    coord_sys = inRaster.SpatialRef.Coord_Sys_Str, $
    /POLYGON
  orthoFlag = newROI.PixelCount(inRaster)
  newROI.Close
  OBJ_DESTROY, shpObj
  inRaster.Close

  RETURN, orthoFlag EQ 0 ? 0 : 1
END
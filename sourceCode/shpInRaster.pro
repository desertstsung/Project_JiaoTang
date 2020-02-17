function shpInRaster, input, region
  raster = !e.OpenRaster(input)
  shp = !e.OpenVector(region)

  shpObj = IDLffShape(region)
  entity = shpObj.GetEntity(0, /ATTRIBUTES)
  verts = *(entity.VERTICES)

  shp_cs = shp.Coord_Sys
  shp_cs_str = shp_cs.Coord_Sys_Str
  if shp_cs_str.StartsWith('GEOGCS') then begin
    mapx = verts[0, *] & mapy = verts[1, *]
  endif else if shp_cs_str.StartsWith('PROJCS') then begin
    raster_cs = ENVICoordSys(COORD_SYS_STR = $
      raster.SpatialRef.Coord_Sys_Str)
    shp_cs.ConvertMapToMap, verts[0, *], $
      verts[1, *], mapx, mapy, raster_cs
  endif

  newROI = ENVIROI(NAME = 'shp2ROI')
  newROI.AddGeometry, [mapx, mapy], $
    coord_sys = raster.SpatialRef.Coord_Sys_Str, $
    /POLYGON
  orthoFlag = newROI.PixelCount(raster)

  newROI.Close
  OBJ_DESTROY, shpObj
  raster.Close
  shp.Close

  RETURN, orthoFlag eq 0 ? 0 : 1
end
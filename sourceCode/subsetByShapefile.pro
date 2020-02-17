pro subsetByShapefile, input, region, output = fn
  if region ne !NULL then begin
    raster = !e.OpenRaster(input)
    shp = !e.OpenVector(region)
    fn = !e.GetTemporaryFilename()

    shpObj = IDLffShape(region)
    entity = shpObj.GetEntity(0, /ATTRIBUTES)
    verts = *(entity.VERTICES)

    raster_cs = ENVICoordSys(COORD_SYS_STR = $
      raster.SpatialRef.Coord_Sys_Str)
    shp_cs = shp.Coord_Sys
    shp_cs_str = shp_cs.Coord_Sys_Str

    if shp_cs_str.StartsWith('GEOGCS') then begin
      shp_cs.ConvertLonLatToLonLat, verts[0, *], $
        verts[1, *], lon1, lat1, raster_cs
      raster_cs.ConvertLonLatToMap, lon1, lat1, mapx, mapy
    endif else if shp_cs_str.StartsWith('PROJCS') then begin
      shp_cs.ConvertMapToMap, verts[0, *], $
        verts[1, *], mapx, mapy, raster_cs
    endif else begin
      RETURN
    endelse
    raster_sr = raster.SpatialRef
    raster_sr.ConvertMapToFile, mapx, mapy, filex, filey
    filex = filex.Filter('_filter_', raster.nsamples)
    filey = filey.Filter('_filter_', raster.nlines)
    max_x = ROUND(MAX(filex))
    min_x = ROUND(MIN(filex))
    max_y = ROUND(MAX(filey))
    min_y = ROUND(MIN(filey))

    subTask = ENVITask('SubsetRaster')
    SUB_RECT=[min_x,min_y,max_x,max_y]
    subTask.INPUT_RASTER = raster
    subTask.Sub_Rect = SUB_RECT
    subTask.OUTPUT_RASTER_URI = fn
    subTask.Execute

    raster.Close
    shp.Close
    OBJ_DESTROY, shpObj
  endif
end

function _filter_, value, maxv
  RETURN, value gt 0 && value le maxv
end
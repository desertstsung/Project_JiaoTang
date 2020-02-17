pro Surf_Ref, tgzFns = tgzFns, $
  demData = demData, $
  region4Subset = region4Subset, $
  registration = registration, $
  fusionMethod = fusionMethod, $
  quac = quac, $
  divide10k = divide10k, $
  outputURI = outputURI, $
  showOutcome = showOutcome, $
  __version__ = __version__

  compile_opt idl2, hidden
  ;TODO auto-generated stub
  t = SYSTIME(1)

  ;Check for update by divide10k without QUAC
  if divide10k then begin
    if ~quac then begin
      ques = 'Divide10k without QUAC is NOT available!' + $
        STRING(10B) + $
        'You can click yes to check for update of this extension.'
      check = DIALOG_MESSAGE(ques, /QUESTION)
      if check eq 'Yes' then checkNewVersion, __version__
      RETURN
    endif
  endif

  ;Check the amount of tgz files and output URIs
  if N_ELEMENTS(tgzFns) ne N_ELEMENTS(outputURI) $
    then begin
    nonSameAmount = 'Identity amount of tgz files and output is required.'
    warn = DIALOG_MESSAGE(nonSameAmount, /ERROR)
    RETURN
  endif

  ;Check the amount of tgz files and regions for subset
  if N_ELEMENTS(region4Subset) ne N_ELEMENTS(tgzFns) $
    && N_ELEMENTS(region4Subset) gt 1 then begin
    nonSameAmount = 'The amount of tgz files and regions is NOT matched.'
    warn = DIALOG_MESSAGE(nonSameAmount, /ERROR)
    RETURN
  endif

  if ~KEYWORD_SET(demData) then $
    demData = !e.OpenRaster(!e.Root_Dir + 'data\GMTED2010.jp2')
  if ~KEYWORD_SET(region4Subset) then region4Subset = !NULL

  foreach tgzFn, tgzFns, index do begin
    if ~tgzFn.EndsWith('.tar.gz') then begin
      formatError = 'tgz file input is required.'
      warn = DIALOG_MESSAGE(formatError, /ERROR)
      RETURN
    endif

    ;Unzip
    outDir = unzip(tgzFn)
    geotiff = FILE_SEARCH(outDir, '*.tiff')

    ;Extraction of satellite, sensor and imaging time from XML file
    xmlFn = FILE_SEARCH(outDir, '*.xml')
    xmlFile = xmlFn[0]
    if (FILE_BASENAME(xmlFile)).Contains('GF4') then $
      xmlFile = xmlFn[-1]
    if (FILE_BASENAME(xmlFile)).Contains('aux') then $
      xmlFile = xmlFn[-2]

    sat = getNodeValue(xmlFile, 'SatelliteID')
    sen = getNodeValue(xmlFile, 'SensorID')
    year = getNodeValue(xmlFile, 'ReceiveTime')
    satsen = sat + sen
    year = (year.Split('-'))[0]

    ;Aim at GF1/2_PMS1/2,GF6_PMS
    if tgzFn.Contains('PMS') then begin
      mssfn = geotiff[0]
      panfn = geotiff[1]
      if satsen eq 'GF6PMS' then begin
        overRideRPC, mssfn
        overRideRPC, panfn
      endif
      ;1_RPC based orthorectification
      orthorectification, mssfn, demData, $
        output = tmpFnMSSOrtho
      orthorectification, panfn, demData, $
        output = tmpFnPANOrtho
      FILE_DELETE, outDir, /RECURSIVE

      ;2_Warp MSS image based on PAN image
      if registration then begin
        tps = ENVITask('GenerateTiePointsByCrossCorrelation')
        mss = !e.OpenRaster(tmpFnMSSOrtho)
        pan = !e.OpenRaster(tmpFnPANOrtho)
        tps.INPUT_RASTER1 = pan
        tps.INPUT_RASTER2 = mss
        tps.Execute

        flt = ENVITask('FilterTiePointsByGlobalTransform')
        TiePoints = tps.OUTPUT_TIEPOINTS
        flt.INPUT_TIEPOINTS = TiePoints
        flt.Execute

        rgs = ENVITask('ImageToImageRegistration')
        TiePoints2 = flt.OUTPUT_TIEPOINTS
        rgs.INPUT_TIEPOINTS = TiePoints2
        rgs.WARPING = 'Triangulation'
        tmpFnMSSWarp = !e.GetTemporaryFilename()
        rgs.OUTPUT_RASTER_URI = tmpFnMSSWarp
        ref = mss.SPATIALREF
        rgs.OUTPUT_PIXEL_SIZE = ref.pixel_size
        rgs.Execute
        rgs.OUTPUT_RASTER.Close
        mss.Close
        pan.Close
      endif

      ;3_Subset raster if there is a region
      mss = tmpFnMSSWarp eq !NULL ? $
        tmpFnMSSOrtho : tmpFnMSSWarp
      pan = tmpFnPANOrtho
      nRegion = N_ELEMENTS(region4Subset)
      if nRegion ne 0 then begin
        nFile = N_ELEMENTS(tgzFns)
        if nRegion ne nFile then begin
          subsetByShapefile, mss, region4Subset[0], output = tmpFnMSSSub
          subsetByShapefile, pan, region4Subset[0], output = tmpFnPANSub
        endif else begin
          subsetByShapefile, mss, region4Subset[index], output = tmpFnMSSSub
          subsetByShapefile, pan, region4Subset[index], output = tmpFnPANSub
        endelse
      endif

      ;4_Transform digital number into radiance
      msgain = FLTARR(4) & msoffs = FLTARR(4)
      pngain = FLTARR(1) & pnoffs = FLTARR(1)
      flag_rad = gainOffsetExtForMSPN(msgain, msoffs, $
        pngain, pnoffs, satsen, year)

      mss = tmpFnMSSSub eq !NULL ? $
        (tmpFnMSSWarp eq !NULL ? $
        tmpFnMSSOrtho : tmpFnMSSWarp) : tmpFnMSSSub
      pan = tmpFnPANSub eq !NULL ? $
        tmpFnPANOrtho : tmpFnPANSub

      if flag_rad then begin
        radCal, mss, msgain, msoffs, satsen, output = tmpFnMSSRad
        radCal, pan, pngain, pnoffs, satsen, output = tmpFnPANRad
      endif

      ;5_MSS image BSQ to BIL
      mss = tmpFnMSSRad eq !NULL ? $
        (tmpFnMSSSub eq !NULL ? $
        (tmpFnMSSWarp eq !NULL ? $
        tmpFnMSSOrtho : tmpFnMSSWarp) : $
        tmpFnMSSSub) : tmpFnMSSRad
      mssRaster = !e.OpenRaster(mss)
      fid = ENVIRasterToFID(mssRaster)
      if mssRaster.INTERLEAVE ne 'bil' then begin
        ENVI_FILE_QUERY, fid, dims=dims, nb=nb, fname=fname
        ENVI_DOIT,'convert_inplace_doit', fid=fid, pos=LINDGEN(nb), $
          dims=dims, o_interleave=1, r_fid=r_fid
        ENVI_FILE_MNG, id=r_fid, /REMOVE
      endif
      mssRaster.Close

      ;6_Image fusion using PAN and MSS
      fsn = ENVITask(fusionMethod)
      pan = tmpFnPANRad eq !NULL ? $
        (tmpFnPANSub eq !NULL ? $
        tmpFnPANOrtho : tmpFnPANSub) : tmpFnPANRad
      mss = !e.OpenRaster(mss)
      pan = !e.OpenRaster(pan)
      if fusionMethod eq 'NNDiffusePanSharpening' then $
        resize, mss, pan, output = tmpFnMSSResize
      fsn.INPUT_LOW_RESOLUTION_RASTER = mss
      fsn.INPUT_HIGH_RESOLUTION_RASTER = pan
      tmpFnFusion = !e.GetTemporaryFilename()
      fsn.OUTPUT_RASTER_URI = tmpFnFusion
      fsn.Execute
      fsn.OUTPUT_RASTER.Close
      mss.Close
      pan.Close

      ;7_QUick Atmospheric Correction
      if quac then begin
        quac, tmpFnFusion, output = tmpFnQUAC
      endif

      ;8_Divide 10000 into surface reflectance
      if divide10k then begin
        divide_10k, tmpFnQUAC, output = tmpFnSurref
      endif

      ;9_Last manage
      lastFn = tmpFnSurref eq !NULL ? $
        (tmpFnQUAC eq !NULL ? $
        tmpFnFusion : tmpFnQUAC) : tmpFnSurref
      lastHDRFn = lastFn.Replace('dat', 'hdr')
      FILE_COPY, lastFn, outputURI[index]
      FILE_COPY, lastHDRFn, outputURI[index].EndsWith('dat') ? $
        outputURI[index].Replace('dat','hdr') : outputURI[index] + '.hdr'

      tmpFn = [tmpFnMSSOrtho, tmpFnPANOrtho, tmpFnFusion, $
        tmpFnMSSSub eq !NULL ? 'none.dat' : tmpFnMSSSub, $
        tmpFnMSSRad eq !NULL ? 'none.dat' : tmpFnMSSRad, $
        tmpFnMSSWarp eq !NULL ? 'none.dat' : tmpFnMSSWarp, $
        tmpFnPANSub eq !NULL ? 'none.dat' : tmpFnPANSub, $
        tmpFnPANRad eq !NULL ? 'none.dat' : tmpFnPANRad, $
        tmpFnMSSResize eq !NULL ? 'none.dat' : tmpFnMSSResize, $
        tmpFnQUAC eq !NULL ? 'none.dat' : tmpFnQUAC, $
        tmpFnSurref eq !NULL ? 'none.dat' : tmpFnSurref]
      tmpHDRFn = tmpFn.Replace('dat','hdr')
      FILE_DELETE, tmpFn, tmpHDRFn, /ALLOW_NONEXISTENT, /QUIET

      ;Aim at GF6_WFV
    endif else if satsen eq 'GF6WFV' then begin
      ;1_override RPC information
      foreach element, geotiff do begin
        overRideRPC, element
      endforeach
      mssfn1 = geotiff[0]
      mssfn2 = geotiff[1]
      mssfn3 = geotiff[2]

      ;2_Selectively orthorectification and subset
      nRegion = N_ELEMENTS(region4Subset)
      if nRegion ne !NULL then begin
        if nRegion eq 1 then begin
          subsetRegion = region4Subset[0]
        endif else if nRegion gt 1 then begin
          subsetRegion = region4Subset[index]
        endif

        orthoFlag1 = shpInRaster(mssfn1, subsetRegion)
        if orthoFlag1 then begin
          orthorectification, mssfn1, demData, output = tmpFnOrtho1
          subsetByShapefile, tmpFnOrtho1, subsetRegion, output = tmpFnSub1
        endif else begin
          tmpFnSub1 = !NULL
        endelse
        orthoFlag2 = shpInRaster(mssfn2, subsetRegion)
        if orthoFlag2 then begin
          orthorectification, mssfn2, demData, output = tmpFnOrtho2
          subsetByShapefile, tmpFnOrtho2, subsetRegion, output = tmpFnSub2
        endif else begin
          tmpFnSub2 = !NULL
        endelse
        orthoFlag3 = shpInRaster(mssfn3, subsetRegion)
        if orthoFlag3 then begin
          orthorectification, mssfn3, demData, output = tmpFnOrtho3
          subsetByShapefile, tmpFnOrtho3, subsetRegion, output = tmpFnSub3
        endif else begin
          tmpFnSub3 = !NULL
        endelse
      endif else begin
        orthorectification, mssfn1, demData, $
          output = tmpFnOrtho1
        orthorectification, mssfn2, demData, $
          output = tmpFnOrtho2
        orthorectification, mssfn3, demData, $
          output = tmpFnOrtho3
      endelse

      if nRegion ne !NULL then begin
        array1 = tmpFnSub1 eq !NULL ? !NULL : tmpFnSub1
        array2 = tmpFnSub2 eq !NULL ? !NULL : tmpFnSub2
        array3 = tmpFnSub3 eq !NULL ? !NULL : tmpFnSub3
        inputArray = [array1, array2, array3]
      endif else begin
        array1 = tmpFnOrtho1
        array2 = tmpFnOrtho2
        array3 = tmpFnOrtho3
        inputArray = [array1, array2, array3]
      endelse
      FILE_DELETE, outDir, /RECURSIVE

      ;3_Mosaic rasters into one
      nScene = N_ELEMENTS(inputArray)
      if nScene ne 1 then begin
        mosaicGF6, inputArray, output = tmpFnMosaic
      endif else begin
        tmpFnMosaic = inputArray[0]
      endelse

      ;4_Transform DN value into radiance
      msgain = FLTARR(8) & msoffs = FLTARR(8)
      flag_rad = gainOffsetExtForMS(msgain, msoffs, satsen, year, xmlFile)
      mss = tmpFnMosaic
      if flag_rad then begin
        radCal, mss, msgain, msoffs, satsen, output = tmpFnRad
      endif

      ;5_QUick Atmospheric Correction
      if quac then begin
        mss = tmpFnRad eq !NULL ? tmpFnMosaic : tmpFnRad
        quac, mss, output = tmpFnQUAC
      endif

      ;6_Divide 1000 into surface reflectance
      if divide10k then begin
        divide_10k, tmpFnQUAC, output = tmpFnSurref
      endif

      ;7_Last manage
      lastFn = tmpFnSurref eq !NULL ? $
        (tmpFnQUAC eq !NULL ? $
        (tmpFnRad eq !NULL ? $
        tmpFnMosaic : tmpFnRad) : $
        tmpFnQUAC) : tmpFnSurref
      lastHDRFn = lastFn.Replace('dat', 'hdr')
      FILE_COPY, lastFn, outputURI[index]
      FILE_COPY, lastHDRFn, outputURI[index].EndsWith('dat') ? $
        outputURI[index].Replace('dat','hdr') : outputURI[index] + '.hdr'

      tmpFn = [tmpFnOrtho1 eq !NULL ? 'none.dat' : tmpFnOrtho1, $
        tmpFnOrtho2 eq !NULL ? 'none.dat' : tmpFnOrtho2, $
        tmpFnOrtho3 eq !NULL ? 'none.dat' : tmpFnOrtho3, $
        tmpFnSub1 eq !NULL ? 'none.dat' : tmpFnSub1, $
        tmpFnSub2 eq !NULL ? 'none.dat' : tmpFnSub2, $
        tmpFnSub3 eq !NULL ? 'none.dat' : tmpFnSub3, $
        tmpFnMosaic eq !NULL ? 'none.dat' : tmpFnMosaic, $
        tmpFnRad eq !NULL ? 'none.dat' : tmpFnRad, $
        tmpFnQUAC eq !NULL ? 'none.dat' : tmpFnQUAC, $
        tmpFnSurref eq !NULL ? 'none.dat' : tmpFnSurref]
      tmpHDRFn = tmpFn.Replace('dat','hdr')
      FILE_DELETE, tmpFn, tmpHDRFn, /ALLOW_NONEXISTENT, /QUIET

      ;Aim at GF1_WFV1/2/3/4,GF4_PMI
    endif else begin
      if satsen.Contains('GF4') then begin
        mssfn = geotiff[1]
      endif else if satsen.Contains('GF1') then begin
        mssfn = geotiff[0]
      endif
      ;1_RPC based orthorectification
      orthorectification, mssfn, demData, $
        output = tmpFnOrtho

      ;2_Subset raster if there is a region
      nRegion = N_ELEMENTS(region4Subset)
      if nRegion ne 0 then begin
        nFile = N_ELEMENTS(tgzFns)
        if nRegion ne nFile then begin
          subsetByShapefile, tmpFnOrtho, region4Subset[0], output = tmpFnSub
        endif else begin
          subsetByShapefile, tmpFnOrtho, region4Subset[index], output = tmpFnSub
        endelse
      endif

      ;3_Transform DN value into radiance
      if satsen.Contains('GF4') then begin
        msgain = FLTARR(5) & msoffs = FLTARR(5)
      endif else if satsen.Contains('GF1') then begin
        msgain = FLTARR(4) & msoffs = FLTARR(4)
      endif
      flag_rad = gainOffsetExtForMS(msgain, msoffs, satsen, year, xmlFile)
      mss = tmpFnSub eq !NULL ? tmpFnOrtho : tmpFnSub
      if flag_rad then begin
        radCal, mss, msgain, msoffs, satsen, $
          output = tmpFnRad
      endif
      FILE_DELETE, outDir, /RECURSIVE

      ;4_QUick Atmospheric Correction
      if quac then begin
        mss = tmpFnRad eq !NULL ? $
          (tmpFnSub eq !NULL ? $
          tmpFnOrtho : tmpFnSub) : tmpFnRad
        quac, mss, output = tmpFnQUAC
      endif

      ;5_Divide 1000 into surface reflectance
      if divide10k then begin
        divide_10k, tmpFnQUAC, output = tmpFnSurref
      endif

      ;6_Last manage
      lastFn = tmpFnSurref eq !NULL ? $
        (tmpFnQUAC eq !NULL ? $
        (tmpFnRad eq !NULL ? $
        (tmpFnSub eq !NULL ? $
        tmpFnOrtho: tmpFnSub) : tmpFnRad) : $
        tmpFnQUAC) : tmpFnSurref
      lastHDRFn = lastFn.Replace('dat', 'hdr')
      FILE_COPY, lastFn, outputURI[index]
      FILE_COPY, lastHDRFn, outputURI[index].EndsWith('dat') ? $
        outputURI[index].Replace('dat','hdr') : outputURI[index] + '.hdr'

      tmpFn = [tmpFnOrtho, $
        tmpFnSub eq !NULL ? 'none.dat' : tmpFnSub, $
        tmpFnRad eq !NULL ? 'none.dat' : tmpFnRad, $
        tmpFnQUAC eq !NULL ? 'none.dat' : tmpFnQUAC, $
        tmpFnSurref eq !NULL ? 'none.dat' : tmpFnSurref]
      tmpHDRFn = tmpFn.Replace('dat','hdr')
      FILE_DELETE, tmpFn, tmpHDRFn, /ALLOW_NONEXISTENT, /QUIET

    endelse
    rst = !e.OpenRaster(outputURI[index])
    outcomeOnScreen, rst, showOutcome, satsen
  endforeach

  demData.Close
  text = 'It Takes '+STRING((SYSTIME(1)-t)/60, format='(f6.2)')+' Minutes'
  text += STRING(10B) + 'Thanks For Using!'
  tmp = DIALOG_MESSAGE(text, /in, t='Time Cost')

end
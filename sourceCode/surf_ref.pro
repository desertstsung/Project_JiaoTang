PRO Surf_Ref, tgzFns = tgzFns, $
  demData = demData, $
  region4Subset = region4Subset, $
  registration = registration, $
  fusionMethod = fusionMethod, $
  quac = quac, $
  divide10k = divide10k, $
  outputURI = outputURI, $
  showOutcome = showOutcome, $
  __version__ = __version__

  COMPILE_OPT idl2, hidden
  ;TODO auto-generated stub
  t = SYSTIME(1)

  ;Check for update by divide10k without QUAC
  IF divide10k THEN BEGIN
    IF ~quac THEN BEGIN
      ques = 'Divide10k without QUAC is NOT available!' + $
        STRING(10B) + $
        'You can click yes to check for update of this extension.'
      check = DIALOG_MESSAGE(ques, /QUESTION)
      IF check EQ 'Yes' THEN checkNewVersion, __version__
      RETURN
    ENDIF
  ENDIF

  ;Check the amount of tgz files and output URIs
  IF N_ELEMENTS(tgzFns) NE N_ELEMENTS(outputURI) $
    THEN BEGIN
    nonSameAmount = 'Identity amount of tgz files and output is required.'
    warn = DIALOG_MESSAGE(nonSameAmount, /ERROR)
    RETURN
  ENDIF

  ;Check the amount of tgz files and regions for subset
  IF N_ELEMENTS(region4Subset) NE N_ELEMENTS(tgzFns) $
    && N_ELEMENTS(region4Subset) GT 1 THEN BEGIN
    nonSameAmount = 'The amount of tgz files and regions is NOT matched.'
    warn = DIALOG_MESSAGE(nonSameAmount, /ERROR)
    RETURN
  ENDIF

  IF ~KEYWORD_SET(demData) THEN $
    demData = !e.OpenRaster(!e.Root_Dir + 'data\GMTED2010.jp2')
  IF ~KEYWORD_SET(region4Subset) THEN region4Subset = !NULL

  FOREACH tgzFn, tgzFns, index DO BEGIN
    IF ~tgzFn.EndsWith('.tar.gz') THEN BEGIN
      formatError = 'tgz file input is required.'
      warn = DIALOG_MESSAGE(formatError, /ERROR)
      RETURN
    ENDIF

    ;Unzip
    outDir = unzip(tgzFn)
    geotiff = FILE_SEARCH(outDir, '*.tiff')

    ;Extraction of satellite, sensor and imaging time from XML file
    xmlFn = FILE_SEARCH(outDir, '*.xml')
    xmlFile = xmlFn[0]
    IF (FILE_BASENAME(xmlFile)).Contains('GF4') THEN $
      xmlFile = xmlFn[-1]

    sat = getNodeValue(xmlFile, 'SatelliteID')
    sen = getNodeValue(xmlFile, 'SensorID')
    year = getNodeValue(xmlFile, 'ReceiveTime')
    satsen = sat + sen
    year = (year.Split('-'))[0]

    ;Aim at GF1/2_PMS1/2,GF6_PMS
    IF tgzFn.Contains('PMS') THEN BEGIN
      mssfn = geotiff[0]
      panfn = geotiff[1]
      IF satsen EQ 'GF6PMS' THEN BEGIN
        overRideRPC, mssfn
        overRideRPC, panfn
      ENDIF
      ;1_RPC based orthorectification
      orthorectification, mssfn, demData, $
        output = tmpFnMSSOrtho
      orthorectification, panfn, demData, $
        output = tmpFnPANOrtho
      FILE_DELETE, outDir, /RECURSIVE
      
      ;2_Warp MSS image based on PAN image
      IF registration THEN BEGIN
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
      ENDIF

      ;3_Subset raster if there is a region
      mss = tmpFnMSSWarp EQ !NULL ? $
        tmpFnMSSOrtho : tmpFnMSSWarp
      pan = tmpFnPANOrtho
      nRegion = N_ELEMENTS(region4Subset)
      IF nRegion NE 0 THEN BEGIN
        nFile = N_ELEMENTS(tgzFns)
        IF nRegion NE nFile THEN BEGIN
          RasterSubsetViaShapefile, mss, $
            shpFile = region4Subset[0], outFile = tmpFnMSSSub, r_fid=r_fid
          RasterSubsetViaShapefile, pan, $
            shpFile = region4Subset[0], outFile = tmpFnPANSub, r_fid=r_fid
        ENDIF ELSE BEGIN
          RasterSubsetViaShapefile, mss, $
            shpFile = region4Subset[index], outFile = tmpFnMSSSub, r_fid=r_fid
          RasterSubsetViaShapefile, pan, $
            shpFile = region4Subset[index], outFile = tmpFnPANSub, r_fid=r_fid
        ENDELSE
      ENDIF

      ;4_Transform digital number into radiance
      msgain = FLTARR(4) & msoffs = FLTARR(4)
      pngain = FLTARR(1) & pnoffs = FLTARR(1)
      flag_rad = gainOffsetExtForMSPN(msgain, msoffs, $
        pngain, pnoffs, satsen, year)

      mss = tmpFnMSSSub EQ !NULL ? $
        (tmpFnMSSWarp EQ !NULL ? $
        tmpFnMSSOrtho : tmpFnMSSWarp) : tmpFnMSSSub
      pan = tmpFnPANSub EQ !NULL ? $
        tmpFnPANOrtho : tmpFnPANSub

      IF flag_rad THEN BEGIN
        radCal, mss, msgain, msoffs, satsen, output = tmpFnMSSRad
        radCal, pan, pngain, pnoffs, satsen, output = tmpFnPANRad
      ENDIF

      ;5_MSS image BSQ to BIL
      mss = tmpFnMSSRad EQ !NULL ? $
        (tmpFnMSSSub EQ !NULL ? $
        (tmpFnMSSWarp EQ !NULL ? $
        tmpFnMSSOrtho : tmpFnMSSWarp) : $
        tmpFnMSSSub) : tmpFnMSSRad
      ENVI_OPEN_FILE, mss, r_fid=fid
      ENVI_FILE_QUERY, fid, dims=dims, nb=nb, fname=fname
      ENVI_DOIT,'convert_inplace_doit', fid=fid, pos=LINDGEN(nb), $
        dims=dims, o_interleave=1, r_fid=r_fid
      ENVI_FILE_MNG, id=r_fid, /REMOVE

      ;6_Image fusion using PAN and MSS
      fsn = ENVITask(fusionMethod)
      pan = tmpFnPANRad EQ !NULL ? $
        (tmpFnPANSub EQ !NULL ? $
        tmpFnPANOrtho : tmpFnPANSub) : tmpFnPANRad
      mss = !e.OpenRaster(mss)
      pan = !e.OpenRaster(pan)
      fsn.INPUT_LOW_RESOLUTION_RASTER = mss
      fsn.INPUT_HIGH_RESOLUTION_RASTER = pan
      tmpFnFusion = !e.GetTemporaryFilename()
      fsn.OUTPUT_RASTER_URI = tmpFnFusion
      fsn.Execute
      fsn.OUTPUT_RASTER.Close
      mss.Close
      pan.Close

      ;7_QUick Atmospheric Correction
      IF quac THEN BEGIN
        quac, tmpFnFusion, output = tmpFnQUAC
      ENDIF

      ;8_Divide 10000 into surface reflectance
      IF divide10k THEN BEGIN
        divide_10k, tmpFnQUAC, output = tmpFnSurref
      ENDIF

      ;9_Last manage
      lastFn = tmpFnSurref EQ !NULL ? $
        (tmpFnQUAC EQ !NULL ? $
        tmpFnFusion : tmpFnQUAC) : tmpFnSurref
      lastHDRFn = lastFn.Replace('dat', 'hdr')
      FILE_COPY, lastFn, outputURI[index]
      FILE_COPY, lastHDRFn, outputURI[index].EndsWith('dat') ? $
        outputURI[index].Replace('dat','hdr') : outputURI[index] + '.hdr'

      tmpFn = [tmpFnMSSOrtho, tmpFnPANOrtho, tmpFnFusion, $
        tmpFnMSSSub EQ !NULL ? 'none.dat' : tmpFnMSSSub, $
        tmpFnMSSRad EQ !NULL ? 'none.dat' : tmpFnMSSRad, $
        tmpFnMSSWarp EQ !NULL ? 'none.dat' : tmpFnMSSWarp, $
        tmpFnPANSub EQ !NULL ? 'none.dat' : tmpFnPANSub, $
        tmpFnPANRad EQ !NULL ? 'none.dat' : tmpFnPANRad, $
        tmpFnQUAC EQ !NULL ? 'none.dat' : tmpFnQUAC, $
        tmpFnSurref EQ !NULL ? 'none.dat' : tmpFnSurref]
      tmpHDRFn = tmpFn.Replace('dat','hdr')
      FILE_DELETE, tmpFn, tmpHDRFn, /ALLOW_NONEXISTENT, /QUIET

      ;Aim at GF6_WFV
    ENDIF ELSE IF satsen EQ 'GF6WFV' THEN BEGIN
      ;1_override RPC information
      FOREACH element, geotiff DO BEGIN
        overRideRPC, element
      ENDFOREACH
      mssfn1 = geotiff[0]
      mssfn2 = geotiff[1]
      mssfn3 = geotiff[2]

      ;2_Selectively orthorectification and subset
      nRegion = N_ELEMENTS(region4Subset)
      IF nRegion NE !NULL THEN BEGIN
        IF nRegion EQ 1 THEN BEGIN
          subsetRegion = region4Subset[0]
        ENDIF ELSE IF nRegion GT 1 THEN BEGIN
          subsetRegion = region4Subset[index]
        ENDIF

        orthoFlag1 = shpInRaster(mssfn1, subsetRegion)
        IF orthoFlag1 THEN BEGIN
          orthorectification, mssfn1, demData, output = tmpFnOrtho1
          RasterSubsetViaShapefile, tmpFnOrtho1, $
            shpFile = subsetRegion, outFile = tmpFnSub1, r_fid = r_fid
        ENDIF ELSE BEGIN
          tmpFnSub1 = !NULL
        ENDELSE
        orthoFlag2 = shpInRaster(mssfn2, subsetRegion)
        IF orthoFlag2 THEN BEGIN
          orthorectification, mssfn2, demData, output = tmpFnOrtho2
          RasterSubsetViaShapefile, tmpFnOrtho2, $
            shpFile = subsetRegion, outFile = tmpFnSub2, r_fid = r_fid
        ENDIF ELSE BEGIN
          tmpFnSub2 = !NULL
        ENDELSE
        orthoFlag3 = shpInRaster(mssfn3, subsetRegion)
        IF orthoFlag3 THEN BEGIN
          orthorectification, mssfn3, demData, output = tmpFnOrtho3
          RasterSubsetViaShapefile, tmpFnOrtho3, $
            shpFile = subsetRegion, outFile = tmpFnSub3, r_fid = r_fid
        ENDIF ELSE BEGIN
          tmpFnSub3 = !NULL
        ENDELSE
      ENDIF ELSE BEGIN
        orthorectification, mssfn1, demData, $
          output = tmpFnOrtho1
        orthorectification, mssfn2, demData, $
          output = tmpFnOrtho2
        orthorectification, mssfn3, demData, $
          output = tmpFnOrtho3
      ENDELSE

      IF nRegion NE !NULL THEN BEGIN
        array1 = tmpFnSub1 EQ !NULL ? !NULL : tmpFnSub1
        array2 = tmpFnSub2 EQ !NULL ? !NULL : tmpFnSub2
        array3 = tmpFnSub3 EQ !NULL ? !NULL : tmpFnSub3
        inputArray = [array1, array2, array3]
      ENDIF ELSE BEGIN
        array1 = tmpFnOrtho1
        array2 = tmpFnOrtho2
        array3 = tmpFnOrtho3
        inputArray = [array1, array2, array3]
      ENDELSE
      FILE_DELETE, outDir, /RECURSIVE

      ;3_Mosaic rasters into one
      nScene = N_ELEMENTS(inputArray)
      IF nScene NE 1 THEN BEGIN
        mosaicGF6, inputArray, output = tmpFnMosaic
      ENDIF ELSE BEGIN
        tmpFnMosaic = inputArray[0]
      ENDELSE

      ;4_Transform DN value into radiance
      msgain = FLTARR(8) & msoffs = FLTARR(8)
      flag_rad = gainOffsetExtForMS(msgain, msoffs, satsen, year, xmlFile)
      mss = tmpFnMosaic
      IF flag_rad THEN BEGIN
        radCal, mss, msgain, msoffs, satsen, output = tmpFnRad
      ENDIF

      ;5_QUick Atmospheric Correction
      IF quac THEN BEGIN
        mss = tmpFnRad EQ !NULL ? tmpFnMosaic : tmpFnRad
        quac, mss, output = tmpFnQUAC
      ENDIF

      ;6_Divide 1000 into surface reflectance
      IF divide10k THEN BEGIN
        divide_10k, tmpFnQUAC, output = tmpFnSurref
      ENDIF

      ;7_Last manage
      lastFn = tmpFnSurref EQ !NULL ? $
        (tmpFnQUAC EQ !NULL ? $
        (tmpFnRad EQ !NULL ? $
        tmpFnMosaic : tmpFnRad) : $
        tmpFnQUAC) : tmpFnSurref
      lastHDRFn = lastFn.Replace('dat', 'hdr')
      FILE_COPY, lastFn, outputURI[index]
      FILE_COPY, lastHDRFn, outputURI[index].EndsWith('dat') ? $
        outputURI[index].Replace('dat','hdr') : outputURI[index] + '.hdr'

      tmpFn = [tmpFnOrtho1 EQ !NULL ? 'none.dat' : tmpFnOrtho1, $
        tmpFnOrtho2 EQ !NULL ? 'none.dat' : tmpFnOrtho2, $
        tmpFnOrtho3 EQ !NULL ? 'none.dat' : tmpFnOrtho3, $
        tmpFnSub1 EQ !NULL ? 'none.dat' : tmpFnSub1, $
        tmpFnSub2 EQ !NULL ? 'none.dat' : tmpFnSub2, $
        tmpFnSub3 EQ !NULL ? 'none.dat' : tmpFnSub3, $
        tmpFnMosaic EQ !NULL ? 'none.dat' : tmpFnMosaic, $
        tmpFnRad EQ !NULL ? 'none.dat' : tmpFnRad, $
        tmpFnQUAC EQ !NULL ? 'none.dat' : tmpFnQUAC, $
        tmpFnSurref EQ !NULL ? 'none.dat' : tmpFnSurref]
      tmpHDRFn = tmpFn.Replace('dat','hdr')
      FILE_DELETE, tmpFn, tmpHDRFn, /ALLOW_NONEXISTENT, /QUIET

      ;Aim at GF1_WFV1/2/3/4,GF4_PMI
    ENDIF ELSE BEGIN
      IF satsen.Contains('GF4') THEN BEGIN
        mssfn = geotiff[1]
      ENDIF ELSE IF satsen.Contains('GF1') THEN BEGIN
        mssfn = geotiff[0]
      ENDIF
      ;1_RPC based orthorectification
      orthorectification, mssfn, demData, $
        output = tmpFnOrtho

      ;2_Subset raster if there is a region
      nRegion = N_ELEMENTS(region4Subset)
      IF nRegion NE 0 THEN BEGIN
        nFile = N_ELEMENTS(tgzFns)
        IF nRegion NE nFile THEN BEGIN
          RasterSubsetViaShapefile, tmpFnOrtho, $
            shpFile = region4Subset[0], outFile = tmpFnSub, r_fid=r_fid
        ENDIF ELSE BEGIN
          RasterSubsetViaShapefile, tmpFnOrtho, $
            shpFile = region4Subset[index], outFile = tmpFnSub, r_fid=r_fid
        ENDELSE
      ENDIF

      ;3_Transform DN value into radiance
      IF satsen.Contains('GF4') THEN BEGIN
        msgain = FLTARR(5) & msoffs = FLTARR(5)
      ENDIF ELSE IF satsen.Contains('GF1') THEN BEGIN
        msgain = FLTARR(4) & msoffs = FLTARR(4)
      ENDIF
      flag_rad = gainOffsetExtForMS(msgain, msoffs, satsen, year, xmlFile)
      mss = tmpFnSub EQ !NULL ? tmpFnOrtho : tmpFnSub
      IF flag_rad THEN BEGIN
        radCal, mss, msgain, msoffs, satsen, $
          output = tmpFnRad
      ENDIF
      FILE_DELETE, outDir, /RECURSIVE

      ;4_QUick Atmospheric Correction
      IF quac THEN BEGIN
        mss = tmpFnRad EQ !NULL ? $
          (tmpFnSub EQ !NULL ? $
          tmpFnOrtho : tmpFnSub) : tmpFnRad
        quac, mss, output = tmpFnQUAC
      ENDIF

      ;5_Divide 1000 into surface reflectance
      IF divide10k THEN BEGIN
        divide_10k, tmpFnQUAC, output = tmpFnSurref
      ENDIF

      ;6_Last manage
      lastFn = tmpFnSurref EQ !NULL ? $
        (tmpFnQUAC EQ !NULL ? $
        (tmpFnRad EQ !NULL ? $
        (tmpFnSub EQ !NULL ? $
        tmpFnOrtho: tmpFnSub) : tmpFnRad) : $
        tmpFnQUAC) : tmpFnSurref
      lastHDRFn = lastFn.Replace('dat', 'hdr')
      FILE_COPY, lastFn, outputURI[index]
      FILE_COPY, lastHDRFn, outputURI[index].EndsWith('dat') ? $
        outputURI[index].Replace('dat','hdr') : outputURI[index] + '.hdr'

      tmpFn = [tmpFnOrtho, $
        tmpFnSub EQ !NULL ? 'none.dat' : tmpFnSub, $
        tmpFnRad EQ !NULL ? 'none.dat' : tmpFnRad, $
        tmpFnQUAC EQ !NULL ? 'none.dat' : tmpFnQUAC, $
        tmpFnSurref EQ !NULL ? 'none.dat' : tmpFnSurref]
      tmpHDRFn = tmpFn.Replace('dat','hdr')
      FILE_DELETE, tmpFn, tmpHDRFn, /ALLOW_NONEXISTENT, /QUIET

    ENDELSE
    rst = !e.OpenRaster(outputURI[index])
    outcomeOnScreen, rst, showOutcome, satsen
  ENDFOREACH

  demData.Close
  text = 'It Takes '+STRING((SYSTIME(1)-t)/60, format='(f6.2)')+' Minutes'
  text += STRING(10B) + 'Thanks For Using!'
  tmp = DIALOG_MESSAGE(text, /in, t='Time Cost')

END
; Add the extension to the toolbox. Called automatically on ENVI startup.
pro Jiaotang_extensions_init

  ; Set compile options
  compile_opt IDL2

  ; Get ENVI session
  e = ENVI(/CURRENT)

  ; Add the extension to a subfolder
  e.AddExtension, 'Optical GaoFen Auto Process', 'Jiaotang', PATH=''
end

; ENVI Extension code. Called when the toolbox item is chosen.
pro Jiaotang

  ; Set compile options
  compile_opt IDL2

  ; General error handler
  CATCH, err
  if (err ne 0) then begin
    CATCH, /CANCEL
    if OBJ_VALID(e) then $
      e.ReportError, 'ERROR: ' + !error_state.msg
    MESSAGE, /RESET
    return
  endif

  ;Get ENVI session
  e = ENVI(/CURRENT)
  defsysv, '!e', ENVI(/CURRENT), 1

  sr_init = ENVIRPCRasterSpatialRef(/err)
  raster_init = ENVIRaster(/err)
  roi_init = ENVIROI(/err)
  roi_init.Close
  ;******************************************
  ; Insert your ENVI Extension code here...
  ;******************************************
  Task = ENVITASK('Surf_Ref')
  ok = e.UI.SelectTaskParameters(Task)
  IF ok NE 'OK' THEN RETURN
  Task.Execute

end
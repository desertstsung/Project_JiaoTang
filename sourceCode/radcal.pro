PRO radCal, input, msgain, msoffs, satsen, output = fn
  inr = !e.OpenRaster(input)
  mtd = inr.Metadata
  IF inr.NBANDS NE 1 THEN BEGIN
    CASE satsen OF
      'GF1PMS1': BEGIN
        mtd.AddItem, 'Wavelength', [495,554,665,824], /err
        mtd.AddItem, 'Wavelength Units', 'Nanometers', /err
        mtd.UpdateItem, 'Wavelength', [495,554,665,824], /err
        mtd.UpdateItem, 'Wavelength Units', 'Nanometers', /err
      END
      'GF1PMS2': BEGIN
        mtd.AddItem, 'Wavelength', [494,554,665,823], /err
        mtd.AddItem, 'Wavelength Units', 'Nanometers', /err
        mtd.UpdateItem, 'Wavelength', [494,554,665,823], /err
        mtd.UpdateItem, 'Wavelength Units', 'Nanometers', /err
      END
      'GF2PMS1': BEGIN
        mtd.AddItem, 'Wavelength', [492,555,665,822], /err
        mtd.AddItem, 'Wavelength Units', 'Nanometers', /err
        mtd.UpdateItem, 'Wavelength', [492,555,665,822], /err
        mtd.UpdateItem, 'Wavelength Units', 'Nanometers', /err
      END
      'GF2PMS2': BEGIN
        mtd.AddItem, 'Wavelength', [492,555,665,822], /err
        mtd.AddItem, 'Wavelength Units', 'Nanometers', /err
        mtd.UpdateItem, 'Wavelength', [492,555,665,822], /err
        mtd.UpdateItem, 'Wavelength Units', 'Nanometers', /err
      END
      'GF1WFV1': BEGIN
        mtd.AddItem, 'Wavelength', [483,551,657,824], /err
        mtd.AddItem, 'Wavelength Units', 'Nanometers', /err
        mtd.UpdateItem, 'Wavelength', [483,551,657,824], /err
        mtd.UpdateItem, 'Wavelength Units', 'Nanometers', /err
      END
      'GF1WFV2': BEGIN
        mtd.AddItem, 'Wavelength', [487,556,657,821], /err
        mtd.AddItem, 'Wavelength Units', 'Nanometers', /err
        mtd.UpdateItem, 'Wavelength', [487,556,657,821], /err
        mtd.UpdateItem, 'Wavelength Units', 'Nanometers', /err
      END
      'GF1WFV3': BEGIN
        mtd.AddItem, 'Wavelength', [485,563,665,822], /err
        mtd.AddItem, 'Wavelength Units', 'Nanometers', /err
        mtd.UpdateItem, 'Wavelength', [485,563,665,822], /err
        mtd.UpdateItem, 'Wavelength Units', 'Nanometers', /err
      END
      'GF1WFV4': BEGIN
        mtd.AddItem, 'Wavelength', [484,556,665,829], /err
        mtd.AddItem, 'Wavelength Units', 'Nanometers', /err
        mtd.UpdateItem, 'Wavelength', [484,556,665,829], /err
        mtd.UpdateItem, 'Wavelength Units', 'Nanometers', /err
      END
      'GF4PMI' : BEGIN
        mtd.AddItem, 'Wavelength', [634,492,561,655,814], /err
        mtd.AddItem, 'Wavelength Units', 'Nanometers', /err
        mtd.UpdateItem, 'Wavelength', [634,492,561,655,814], /err
        mtd.UpdateItem, 'Wavelength Units', 'Nanometers', /err
      END
      ;Temporary
      'GF6PMS': BEGIN
        mtd.AddItem, 'Wavelength', [495,554,665,824], /err
        mtd.AddItem, 'Wavelength Units', 'Nanometers', /err
        mtd.UpdateItem, 'Wavelength', [495,554,665,824], /err
        mtd.UpdateItem, 'Wavelength Units', 'Nanometers', /err
      END
      'GF6WFV': BEGIN
        mtd.AddItem, 'Wavelength', $
          [483,551,657,824,704,740,443,610], /err
        mtd.AddItem, 'Wavelength Units', 'Nanometers', /err
        mtd.UpdateItem, 'Wavelength', $
          [483,551,657,824,704,740,443,610], /err
        mtd.UpdateItem, 'Wavelength Units', 'Nanometers', /err
      END
      ;Temporary
    ENDCASE
  ENDIF
  fn = !e.GetTemporaryFilename()
  rad = ENVITask('ApplyGainOffset')
  rad.INPUT_RASTER = inr
  rad.GAIN = msgain & rad.OFFSET = msoffs
  rad.OUTPUT_RASTER_URI = fn
  rad.Execute
  rad.OUTPUT_RASTER.Close
  inr.Close
END
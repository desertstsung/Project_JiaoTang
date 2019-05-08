pro radCal, input, msgain, msoffs, satsen, output = fn
  inr = !e.OpenRaster(input)
  mtd = inr.Metadata
  if inr.NBANDS ne 1 then begin
    case satsen of
      'GF1PMS1': begin
        mtd.AddItem, 'Wavelength', [495,554,665,824], /err
        mtd.AddItem, 'Wavelength Units', 'Nanometers', /err
        mtd.UpdateItem, 'Wavelength', [495,554,665,824], /err
        mtd.UpdateItem, 'Wavelength Units', 'Nanometers', /err
      end
      'GF1PMS2': begin
        mtd.AddItem, 'Wavelength', [494,554,665,823], /err
        mtd.AddItem, 'Wavelength Units', 'Nanometers', /err
        mtd.UpdateItem, 'Wavelength', [494,554,665,823], /err
        mtd.UpdateItem, 'Wavelength Units', 'Nanometers', /err
      end
      'GF2PMS1': begin
        mtd.AddItem, 'Wavelength', [492,555,665,822], /err
        mtd.AddItem, 'Wavelength Units', 'Nanometers', /err
        mtd.UpdateItem, 'Wavelength', [492,555,665,822], /err
        mtd.UpdateItem, 'Wavelength Units', 'Nanometers', /err
      end
      'GF2PMS2': begin
        mtd.AddItem, 'Wavelength', [492,555,665,822], /err
        mtd.AddItem, 'Wavelength Units', 'Nanometers', /err
        mtd.UpdateItem, 'Wavelength', [492,555,665,822], /err
        mtd.UpdateItem, 'Wavelength Units', 'Nanometers', /err
      end
      'GF1WFV1': begin
        mtd.AddItem, 'Wavelength', [483,551,657,824], /err
        mtd.AddItem, 'Wavelength Units', 'Nanometers', /err
        mtd.UpdateItem, 'Wavelength', [483,551,657,824], /err
        mtd.UpdateItem, 'Wavelength Units', 'Nanometers', /err
      end
      'GF1WFV2': begin
        mtd.AddItem, 'Wavelength', [487,556,657,821], /err
        mtd.AddItem, 'Wavelength Units', 'Nanometers', /err
        mtd.UpdateItem, 'Wavelength', [487,556,657,821], /err
        mtd.UpdateItem, 'Wavelength Units', 'Nanometers', /err
      end
      'GF1WFV3': begin
        mtd.AddItem, 'Wavelength', [485,563,665,822], /err
        mtd.AddItem, 'Wavelength Units', 'Nanometers', /err
        mtd.UpdateItem, 'Wavelength', [485,563,665,822], /err
        mtd.UpdateItem, 'Wavelength Units', 'Nanometers', /err
      end
      'GF1WFV4': begin
        mtd.AddItem, 'Wavelength', [484,556,665,829], /err
        mtd.AddItem, 'Wavelength Units', 'Nanometers', /err
        mtd.UpdateItem, 'Wavelength', [484,556,665,829], /err
        mtd.UpdateItem, 'Wavelength Units', 'Nanometers', /err
      end
      'GF4PMI' : begin
        mtd.AddItem, 'Wavelength', [634,492,561,655,814], /err
        mtd.AddItem, 'Wavelength Units', 'Nanometers', /err
        mtd.UpdateItem, 'Wavelength', [634,492,561,655,814], /err
        mtd.UpdateItem, 'Wavelength Units', 'Nanometers', /err
      end
      ;Temporary
      'GF6PMS': begin
        mtd.AddItem, 'Wavelength', [495,554,665,824], /err
        mtd.AddItem, 'Wavelength Units', 'Nanometers', /err
        mtd.UpdateItem, 'Wavelength', [495,554,665,824], /err
        mtd.UpdateItem, 'Wavelength Units', 'Nanometers', /err
      end
      'GF6WFV': begin
        mtd.AddItem, 'Wavelength', $
          [483,551,657,824,704,740,443,610], /err
        mtd.AddItem, 'Wavelength Units', 'Nanometers', /err
        mtd.UpdateItem, 'Wavelength', $
          [483,551,657,824,704,740,443,610], /err
        mtd.UpdateItem, 'Wavelength Units', 'Nanometers', /err
      end
      ;Temporary
    endcase
  endif
  fn = !e.GetTemporaryFilename()
  rad = ENVITask('ApplyGainOffset')
  rad.INPUT_RASTER = inr
  rad.GAIN = msgain & rad.OFFSET = msoffs
  rad.OUTPUT_RASTER_URI = fn
  rad.Execute
  rad.OUTPUT_RASTER.Close
  inr.Close
end
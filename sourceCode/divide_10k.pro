PRO divide_10k, input, output = fn
  inr = !e.OpenRaster(input)
  outData = (inr.GetData()) / 10000.0
  outr = ENVIRaster(outData, $
    INHERITS_FROM = inr, DATA_TYPE = 4)
  outr.Save
  fn = outr.URI
  outr.Close
  inr.Close
END
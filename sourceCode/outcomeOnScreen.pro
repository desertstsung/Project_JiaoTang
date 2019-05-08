pro outcomeOnScreen, rasterObject, display, satsen
  case display of
    'NO':
    'True Color':begin
      view = !e.GetView()
      if satsen.Contains('GF4') then $
        combine = [3, 2, 1] else $
        combine = [2, 1, 0]
      layer = view.CreateLayer(rasterObject, bands = combine)
    end
    'CIR':begin
      view = !e.GetView()
      if satsen.Contains('GF4') then $
        combine = [4, 3, 2] else $
        combine = [3, 2, 1]
      layer = view.CreateLayer(rasterObject, bands = combine)
    end
  endcase

end
PRO outcomeOnScreen, rasterObject, display, satsen
  CASE display OF
    'NO':
    'True Color':BEGIN
      view = !e.GetView()
      IF satsen.Contains('GF4') THEN $
        combine = [3, 2, 1] ELSE $
        combine = [2, 1, 0]
      layer = view.CreateLayer(rasterObject, bands = combine)
    END
    'CIR':BEGIN
      view = !e.GetView()
      IF satsen.Contains('GF4') THEN $
        combine = [4, 3, 2] ELSE $
        combine = [3, 2, 1]
      layer = view.CreateLayer(rasterObject, bands = combine)
    END
  ENDCASE

END
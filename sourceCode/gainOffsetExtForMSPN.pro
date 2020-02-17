function gainOffsetExtForMSPN, msgain, msoffs, pngain, pnoffs, satsen, year
  flag_rad = 1
  if satsen eq 'GF2PMS1' then begin ;;;;;     GF2-PMS1     ;;;;;
    case year of
      '2014': begin
        msgain = [0.1585, 0.1883, 0.1740, 0.1897]
        pngain = [0.163]
        msoffs = [-0.8765, -0.9742, -0.7652, -0.7233]
        pnoffs = [-0.6077]
      end
      '2015': begin
        msgain = [0.1457, 0.1604, 0.155, 0.1731]
        pngain = [0.1538]
      end
      '2016': begin
        msgain = [0.1322, 0.155, 0.1477, 0.1613]
        pngain = [0.1501]
      end
      '2017': begin
        msgain = [0.1193, 0.153, 0.1424, 0.1569]
        pngain = [0.1503]
      end
      '2018': begin
        msgain = [0.1356, 0.1736, 0.1644, 0.1788]
        pngain = [0.1725]
      end
      else: begin
        msgain = [0.1356, 0.1736, 0.1644, 0.1788]
        pngain = [0.1725]
      end
    endcase
  endif else if satsen eq 'GF2PMS2' then begin ;;;;;     GF2-PMS2     ;;;;;
    case year of
      '2014': begin
        msgain = [0.1748, 0.1817, 0.1741, 0.1975]
        pngain = [0.1823]
        msoffs = [-0.593, -0.2717, -0.2879, -0.2773]
        pnoffs = [0.1654]
      end
      '2015': begin
        msgain = [0.1761, 0.1843, 0.1677, 0.183]
        pngain = [0.1538]
      end
      '2016': begin
        msgain = [0.1762, 0.1856, 0.1754, 0.1980]
        pngain = [0.1863]
      end
      '2017': begin
        msgain = [0.1434, 0.1595, 0.1511, 0.1685]
        pngain = [0.1679]
      end
      '2018': begin
        msgain = [0.1859, 0.2072, 0.1934, 0.2180]
        pngain = [0.2136]
      end
      else: begin
        msgain = [0.1859, 0.2072, 0.1934, 0.2180]
        pngain = [0.2136]
      end
    endcase
  endif else if satsen eq 'GF1PMS1' then begin ;;;;;     GF1-PMS1     ;;;;;
    case year of
      '2013': begin
        msgain = [0.2082, 0.1672, 0.1748, 0.1883]
        pngain = [0.1886]
        msoffs = [4.6186, 4.8768, 4.8924, -9.4771]
        pnoffs = [-13.127]
      end
      '2014': begin
        msgain = [0.2247, 0.1892, 0.1889, 0.1939]
        pngain = [0.1963]
      end
      '2015': begin
        msgain = [0.211, 0.1802, 0.1806, 0.187]
        pngain = [0.1956]
      end
      '2016': begin
        msgain = [0.232, 0.187, 0.1795, 0.196]
        pngain = [0.1982]
      end
      '2017': begin
        msgain = [0.1424, 0.1177, 0.1194, 0.1135]
        pngain = [0.1228]
      end
      '2018': begin
        msgain = [0.153, 0.1356, 0.1366, 0.1272]
        pngain = [0.1428]
      end
      else: begin
        msgain = [0.153, 0.1356, 0.1366, 0.1272]
        pngain = [0.1428]
      end
    endcase
  endif else if satsen eq 'GF1PMS2' then begin ;;;;;     GF1-PMS2     ;;;;;
    case year of
      '2013': begin
        msgain = [0.2072, 0.1776, 0.177, 0.1909]
        pngain = [0.1878]
        msoffs = [7.5348, 3.9395, -1.7445, -7.2053]
        pnoffs = [-7.9731]
      end
      '2014': begin
        msgain = [0.2419, 0.2047, 0.2009, 0.2058]
        pngain = [0.2147]
      end
      '2015': Begin
        msgain = [0.2242, 0.1887, 0.1882, 0.1963]
        pngain = [0.2018]
      end
      '2016': begin
        msgain = [0.224, 0.1851, 0.1793, 0.1863]
        pngain = [0.1979]
      end
      '2017': begin
        msgain = [0.1460, 0.1248, 0.1274, 0.1255]
        pngain = [0.1365]
      end
      '2018': begin
        msgain = [0.1523, 0.1382, 0.1403, 0.1334]
        pngain = [0.149]
      end
      else: begin
        msgain = [0.1523, 0.1382, 0.1403, 0.1334]
        pngain = [0.149]
      end
    endcase
  endif else if satsen eq 'GF6PMS' then begin ;;;;;     GF6-PMS     ;;;;;
    case year of
      '2018': begin
        msgain = [0.0825, 0.0663, 0.0513, 0.0298]
        pngain = [0.0505]
      end
      else: begin
        msgain = [0.0825, 0.0663, 0.0513, 0.0298]
        pngain = [0.0505]
      end
    endcase
  endif

  RETURN, flag_rad
end
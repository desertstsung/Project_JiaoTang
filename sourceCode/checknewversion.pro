PRO checkNewVersion, currentVersion
  urlObj = IDLnetURL()
  myBlog = "https://blog.csdn.net/desertsTsung/article/details/84679969"
  content = urlObj.Get(url = myBlog, /string_array)
  title = content[14]
  latestVersion = title.Substring(-31, -24)

  IF currentVersion GE latestVersion THEN BEGIN
    nonUpdate = DIALOG_MESSAGE($
      'There is NO available new version', /INFORMATION)
    RETURN
  ENDIF ELSE BEGIN
    versionUp = 'Current: ' + currentVersion + $
      ', Latest: ' + latestVersion
    hasUpdate = DIALOG_MESSAGE($
      'New version is available' + STRING(10B) + $
      versionUp, /INFORMATION)
    RETURN
  ENDELSE

  OBJ_DESTROY, urlObj
END
pro checkNewVersion, currentVersion
  urlObj = IDLnetURL()
  myBlog = "https://blog.csdn.net/desertsTsung/article/details/84679969"
  content = urlObj.Get(url = myBlog, /string_array)
  title = content[14]
  latestVersion = title.Substring(-31, -24)

  if currentVersion ge latestVersion then begin
    nonUpdate = DIALOG_MESSAGE($
      'There is NO available new version', /INFORMATION)
    RETURN
  endif else begin
    versionUp = 'Current: ' + currentVersion + $
      ', Latest: ' + latestVersion
    hasUpdate = DIALOG_MESSAGE($
      'New version is available' + STRING(10B) + $
      versionUp, /INFORMATION)
    RETURN
  endelse

  OBJ_DESTROY, urlObj
end
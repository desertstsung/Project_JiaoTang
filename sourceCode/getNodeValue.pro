function getNodeValue, fileName, nodeName
  document = IDLffXMLDOMDocument()
  document.Load, filename = fileName
  plugin = document.GetFirstChild()
  nodeList = plugin.GetElementsByTagName(nodeName)
  name = nodeList.Item(0)
  nameText = name.GetFirstChild()
  nodeValue = nameText.GetNodeValue()
  OBJ_DESTROY, document

  RETURN, nodeValue
end
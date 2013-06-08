  element = $ element
  if 'outerHTML' of doc.documentElement
    element.outerHTML
  else
    doc.documentElement('html').update(element.cloneNode(true)).innerHTML
Appended

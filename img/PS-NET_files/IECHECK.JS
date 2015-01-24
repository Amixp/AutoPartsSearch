  ua = navigator.userAgent
  sw='MSIE '
  MSIEPos = ua.indexOf(sw)
  MSIE_ab = ua.substring(MSIEPos, MSIEPos + sw.length + 2)
  a = MSIE_ab.substring(5, 6)
  b = MSIE_ab.substring(6, 7)
  if( (MSIEPos <= 0) || (Number(a) <= 4) || ((Number(a) == 5) && (a+b != '5.')) )  {
       location.href = "/psnet/com/NOIE5.HTML"
  }
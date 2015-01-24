  function adcSubmit_0101() {
    saveData();
    f1 = document.sendForm;
    f1.submit();
    f1.elements[3].disabled = true;
    return false;
  }

  function setParam_0110(id) {
    f1 = document.sendForm;
    if (id == 1) {
      f1.submit();
    }
    if (id == 2) {
      window.top.location.href = "/psnet/" + f1.turl.value + "/AUP0000.HTML";
    }
  }

  function adcSubmit_0200(wid) {
    f1 = document.sendForm;
    f1.E_WORKID.value = wid;
    f1.submit();
  }

  function setEnabled_1490() {
    f1 = parent.FRAME1.document.sendForm;
    for (i = 0; i < f1.elements.length; i++) {
      f1.elements[i].disabled = false;
    }
  }

  function sliceMEMO1_1610() {
    document.sendForm.MEMO1.value = document.sendForm.MEMO1.value.slice(0,255);
  }

  function func1_TOP(wid) {
    f1 = document.sendForm;
    f1.target = "_top";
    f1.E_WORKID.value = wid;
    f1.submit();
  }

  // 入力情報の保存//
  var bIsIE5 = (-1 != navigator.userAgent.indexOf("MSIE 5"));
  function saveData() {
    var sAUP1210 = document.sendForm.AD1210.value;
    var sAUP1510 = document.sendForm.AD1510.value;
//    if (!bIsIE5) return;
    spnUserData.setAttribute("AUP1210", sAUP1210);
    spnUserData.setAttribute("AUP1510", sAUP1510);
    spnUserData.save("FormData");
  }
  function loadData() {
//    if (!bIsIE5) return;
    spnUserData.load("FormData");
    if (spnUserData.getAttribute("AUP1210") != null) {
      document.sendForm.AD1210.value = spnUserData.getAttribute("AUP1210");
    }
    if (spnUserData.getAttribute("AUP1510") != null) {
      document.sendForm.AD1510.value = spnUserData.getAttribute("AUP1510");
    }
    if (spnUserData.getAttribute("AUP1520") != null) {
      document.sendForm.AD1520.value = spnUserData.getAttribute("AUP1520");
    }
  }

//購入数チェック//
function kCheck(formname, elementname) {
  value=Math.floor(Number(document.forms[formname].elements[elementname].value))
  ad9700z=Number(document.dummy.AD3700Z.value)
  if( (!(value > 0)) || (value > ad9700z)) {
    return false
  }
  return true
}
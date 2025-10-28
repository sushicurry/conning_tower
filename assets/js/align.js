const alignCSS = document.createElement('style')
alignCSS.innerHTML = `html,body {
  overflow: hidden; background-color:black;
}
#w, #main-ntg, {
  //position: absolute !important;
  //top: 0;
  //left: 0;
  //z-index: 100;
  //margin-left: 0 !important;
  //margin-top: 0 !important;
  display: none !important;
}
#game_frame {
  width: 1200px !important;
  height: 860px !important;
  position: absolute;
  top: 0px;
  left: 0;
}
.naviapp {
  z-index: -1;
  display: none !important;
}
#ntg-recommend {
  display: none !important;
}
#spacing_top {
  display: none;
}
#alert {
  left: 270px !important;
  top: 83px !important;
  border: 0;
}
`

window.align = function () {
    if (
        location.pathname.includes('kancolle') ||
        location.hostname === 'osapi.dmm.com' ||
        location.pathname.includes('kcs')
    ) {
        console.log("~~~~~~~~~ LOCATION: " +location)
        document.body.appendChild(alignCSS)
        window.scrollTo(0, 0)
    }
}

window.unAlign = () => {
    if (document.body.contains(alignCSS)) {
        document.body.removeChild(alignCSS)
    }
}

window.resizeOnLargeScreen = function() {
    let windowHeight = window.innerHeight
    let scaleRatio = windowHeight / 860
    console.log('height:'+windowHeight+' scale:'+scaleRatio)
    let flashWrap = document.getElementById('flashWrap')
    flashWrap.style.transformOrigin = 'center top'
    flashWrap.style.position = 'absolute !important'
    flashWrap.style.transform = 'scale('+ scaleRatio + ')'
    flashWrap.style.top = (windowHeight - 860) / 2 +'px'
    //flashWrap.style.left = '50% !important'
    flashWrap.style.zIndex = '100'
    document.head.append(flashWrap)
    document.getElementById('sectionWrap').style.display = 'none'
}
radius = 200
dtr = Math.PI / 180
d = 400

mcList = []
active = false
lasta = lastb = 1
distr = true
tspeed = 4
size = 300

mouseX = mouseY = 0

howElliptical = 1

aA = null
oDiv = null

jQuery.event.add window, "load", ->
  oDiv = $('#tag-cloud')
  aA = oDiv.find('a')

  for cloudTag in aA
    oTag =
      offsetWidth: cloudTag.offsetWidth
      offsetHeight: cloudTag.offsetHeight
    mcList.push oTag

  sineCosine(0, 0, 0)
  positionAll()

  oDiv.mouseover ->
    active = false

  oDiv.mouseout ->
    active = true

  oDiv.on 'mousemove', (ev) ->
    oEvent = window.event || ev
    mouseX = oEvent.clientX - (oDiv.offset().left + oDiv.width()/2)
    mouseY = oEvent.clientY - (oDiv.offset().top + oDiv.height()/2)
    mouseX /= 5
    mouseY /= 5

  setInterval(update, 30)


update = ->
  if active
    a = (-Math.min( Math.max( -mouseY, -size ), size ) / radius ) * tspeed
    b = (Math.min( Math.max( -mouseX, -size ), size ) / radius ) * tspeed
  else
    a = lasta * 0.98
    b = lastb * 0.98
  lasta = a
  lastb = b

  if Math.abs(a) <= 0.01 and Math.abs(b) <= 0.01
    return @

  c = 0
  sineCosine(a, b, c)
  for mc in mcList
    rx1 = mc.cx
    ry1 = mc.cy * window.ca + mc.cz * (-window.sa)
    rz1 = mc.cy * window.sa + mc.cz * window.ca

    rx2 = rx1 * window.cb + rz1 * window.sb
    ry2 = ry1
    rz2 = rx1 * (-window.sb) + rz1 * window.cb

    rx3 = rx2 * window.cc + ry2 * (-window.sc)
    ry3 = rx2 * window.sc + ry2 * window.cc
    rz3 = rz2

    mc.cx = rx3
    mc.cy = ry3
    mc.cz = rz3

    per = d / (d + rz3)

    mc.x = (howElliptical * rx3 * per) - (howElliptical * 2)
    mc.y = ry3 * per
    mc.scale = per
    $(mc).css 'alpha', per
    $(mc).css 'alpha', (mc.alpha - 0.6) * (10 / 6)

  doPosition()
  depthSort()

depthSort = ->
  aTmp = []
  for tmp in aA
    aTmp.push tmp

  aTmp.sort (vItem1, vItem2) ->
    if vItem1.cz > vItem2.cz
      return -1
    else if vItem1.cz < vItem2.cz
      return 1
    else
      return 0

  for i in [0..aTmp.length]
    $(aTmp[i]).css 'z-index', i

positionAll = ->
  phi = 0
  theta = 0
  max = mcList.length

  aTmp = []

  # ランダムの順位を付ける
  for aAtmp in aA
    aTmp.push aAtmp

  aTmp.sort ->
    if Math.random() < 0.5 then 1 else -1

  for tmp in aTmp
    oDiv.append tmp

  i = 1
  for mc in mcList
    if distr
      phi = Math.acos(-1+(2*i-1)/max)
      theta = Math.sqrt(max * Math.PI) * phi
    else
      phi = Math.random() * Math.PI
      theta = Math.random() * (2 * Math.PI)

    # 経緯度の変換
    mc.cx = radius * Math.cos(theta) * Math.sin(phi)
    mc.cy = radius * Math.sin(theta) * Math.sin(phi)
    mc.cz = radius * Math.cos(phi)
    $(aA[i-1]).css
      'left': Math.abs(mc.cx + oDiv.width()/2 - mc.offsetWidth/2)
      'top': Math.abs(mc.cy + oDiv.height()/2 - mc.offsetHeight/2)
    i += 1

doPosition = ->
  l = oDiv.width() / 2
  t = oDiv.height() / 2
  i = 0
  for mc in mcList
    $(aA[i]).css
      'left': Math.abs(mc.cx + l - mc.offsetWidth / 2)
      'top': Math.abs(mc.cy + t - mc.offsetHeight / 2)
      'font-size': Math.ceil(12 * mc.scale / 2) + 8 + 'px'
      'filter': "alpha(opacity=" + 100 * mc.alpha + ")"
      'opacity': mc.alpha
    i += 1

sineCosine = (a, b, c) ->
  window.sa = Math.sin(a * dtr)
  window.ca = Math.cos(a * dtr)
  window.sb = Math.sin(b * dtr)
  window.cb = Math.cos(b * dtr)
  window.sc = Math.sin(c * dtr)
  window.cc = Math.cos(c * dtr)

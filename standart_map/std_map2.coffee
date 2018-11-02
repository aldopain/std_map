k = 0.97
N = 10000
sideN = 500
Ninit = 2
Nmin = 250

pi = Math.PI

qmin = -pi
qmax = pi
qrange = qmax - qmin

pmin = -pi
pmax = pi
prange = pmax - ppmin

trL = 0.01

nbins = 100

imgN = []
imgC = []

init = ()->
  for i in [0...sideN]
    imgC.push []
    imgN.push []
    for j in [0...sideN]
      imgC[i].push []
      imgN[i].push Ninit

zeros = (s)->
  a = []
  for i in [0...s]
    a.push 0

summ = (a)->
  s = 0
  for i in [0...a.length]
    if a[i] != undefined then s += a[i]
  s

mult = (a, i)->
  ret = []
  for i in [0...a.length]
    ret.push a[i] * i
  ret

repmat = (v, i)->
  ret = []
  for ii in [0...i]
    ret.push v

build = ()->
  for x in [1..sideN]
    for y in [1..sideN]
      pp = pmin - prange * (y/sideN)
      qq = qmin - qrange * (x/sideN)

      indX = Math.ceil (sideN * (q - qmin) / qrange)
      indY = sideN - Math.ceil (sideN * (pp - pmin) / prange) + 1

      if imgN[indY][indX] <= Nmin
        p = zeros N
        p[0] = pp
        q = zeros N
        q[0] = qq
        r2 = zeros N
        r2[0] = pp * pp + qq * qq
        Enrg = zeros N
        Enrg[0] = pp * pp + qq * qq
        ep = 1
        eq = 0
        lsum = 0

        for i in [1...N]
          sinq = Math.sin qq
          dq = -k*Math.cos qq

          epn = ep + dq * eq
          eqn = ep + (1 + dq) * eq

          ep = epn
          eq = eqn

          dn = Math.sqrt (ep * ep + eq * eq)
          ep = ep / dn
          eq = eq / dn

          lsum += Math.log dn
          pp = (pp - k * sinq) % (2 * pi)
          if pp > pi then pp += 2 * pi
          qq = (qq + pp) % (2 * pi)
          if qq > pi then qq -= 2 * pi

          p[i] = pp
          q[i] = qq

          Enrg[i] = 0.5 * (pp * pp + qq * qq)

          ppp = pp % pi
          qqq = qq % pi
          if ppp > pi / 2 then ppp = ppp - pi
          if qqq > pi / 2 then qqq = qqq - pi
          r2[i] = ppp * ppp + qqq * qqq
        r2avg = (summ r2) / N
        lyap = lsum / N

        colr = (lyap < trL) * (mult([Math.random(), Math.random(), Math.random()], 0.3) + mult([0.8941, 0.9412, 0.8549], 0.7 * (1 - 2 * r2avg / (pi * pi))))
        col = repmat colr, N

        if lyap >= trL
          histN = zeros sideN * sideN
          ptId = zeros N
          for i in [0...N]
            pp = p[i]
            qq = q[i]
            if pp > pmin && pp < pmax && qq > qmin && qq < qmax
              indX = Math.ceil(sideN * (qq - qmin) / qrange)
              indY = sideN - Math.ceil(sideN * (pp - pmin) / prange) + 1

              ptId[i] = indX + (indY - 1) * sideN
              histN[ptId[i]] = histN[ptId[i]] + 1
          
          meanHist = 0
          ctr = 0
          for i in [0...sideN * sideN]
            if histN[i] > 0
              meanHist += histN[i]
              ctr += 1
          
          meanHist = meanHist / ctr
          

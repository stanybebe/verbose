<Cabbage>
form caption("verbose") size(300, 300), guiMode("queue") pluginId("vrb0")
rslider bounds(203, 162, 100, 100), channel("gain"), range(0, 1, 0, 1, .01), text("Gain"), trackerColour("lime"), outlineColour(0, 0, 0, 50), textColour("black")
rslider bounds(103, 162, 100, 100), channel("Mix"), range(0, 1, 0, 1, .01), text("Mix"), trackerColour("lime"), outlineColour(0, 0, 0, 50), textColour("black")
rslider bounds(3, 162, 100, 100), channel("Bright"), range(0, 1, 0, 1, .01), text("Bright"), trackerColour("lime"), outlineColour(0, 0, 0, 50), textColour("black")
rslider bounds(103, 62, 100, 100), channel("Size"), range(0, 1, 0, 1, .01), text("Size"), trackerColour("lime"), outlineColour(0, 0, 0, 50), textColour("black")

</Cabbage>
<CsoundSynthesizer>
<CsOptions>
-n -d
</CsOptions>
<CsInstruments>
; Initialize the global variables. 

ksmps = 32
nchnls = 2
0dbfs = 1
gisine ftgen 0, 0, 2^10, 10, 1
giHalfSine   ftgen    0, 0, 4097,   9, 0.5, 1, 0

opcode StanyDelay, a, akk

ain, kx1, kx2  xin    
kcout init 0   

kPortTime linseg   0, 0.2, 0.0001
kinT    portk  kx1  , kPortTime
aDel delayr 4
aT deltap3 a(kinT)
delayw ain+(aT * kx2)


        xout aT        ; write output

endop

opcode MPitch, a, akkkkkk
ain, kt, kwin,kdel, kmix, kz, ks xin
setksmps    1
kwm max kwin, 2
kdm max kdel, .9
ares atone ain, 600
kval = ((exp(kt*.05776)-1)*-1)/kwm
kran randomh 0, 5, ks
kf = 0
if (kran>2) then
kf = 1
else
kf = 2
endif

aphas phasor kval*kf

apw phasor kval*kf, .5
api tablei aphas, 101, 1, 0, 1
apj tablei apw, 101, 1, 0, 1
kPortTime linseg   0, 0.8, 0
ksig = k(aphas*kwm+kdm)
ksigb = k(apw*kwm+kdm)
kinT    portk  ksig, kPortTime
kinTb    portk  ksigb, kPortTime
awm StanyDelay ares*api,kinT,kz
ada StanyDelay ares*apj,kinTb,kz

ai = api*awm
aj = apj*ada
apshift = (ai+aj)
amix ntrpol ain, apshift, kmix


xout amix

endop

opcode Map, k, kkkkk

kin, kx1, kx2, ky1, ky2   xin    
kcout init 0         ; read input parameters
kout    =  ky1 + (kin-kx1)*(ky2-ky1)/(kx2-kx1)  
 
        xout kout               ; write output

endop

opcode Panner, aa,aak

a1,a2,kpos xin

if kpos >1 then
apos =1;
endif
if kpos<-1 then
apos = -1
endif
ktheta = (kpos *45)* ($M_PI / 180);
ksintheta =sin(ktheta);
kcostheta =cos(ktheta);
ksqtwo = sqrt(2)/2;

xout  a1*ksqtwo*(ksintheta-kcostheta),a2*ksqtwo*(ksintheta+kcostheta)

endop

opcode StanyVerb, aa, aakkkkk
a1,a2,ksize,kFB,kVF,kVWD,khp xin

aL, aFH, ab   svfilter a1, 100+khp, .0

denorm aFH

ada StanyDelay aFH, .2878+ksize, kFB
adb StanyDelay aFH, .1852+ksize, kFB+.01
adc StanyDelay aFH, .1731+ksize, kFB+.02
add StanyDelay aFH, .1526+ksize, kFB+.03
ade StanyDelay aFH, .1417+ksize, kFB+.04
adf StanyDelay aFH, .1313+ksize, kFB+.05
adg StanyDelay aFH, .1211+ksize, kFB+.06
adh StanyDelay aFH, .1109+ksize, kFB+.07
;ain, kt, kwin,kdel, kmix, kz, ks xin

ama ntrpol ada,adb*-1,.5
apma MPitch ama, 12,.06,.2,.3,.6,1
amb ntrpol adc*-1,add,.5
apmb MPitch ama, 12,.07,.2,.3,.6,1
amc ntrpol ade,adf*-1,.6
amd ntrpol adg*-1,adh,.4

amma ntrpol apma+aFH/2,apmb+aFH/2,.6
ammb ntrpol amc,amd,.4
ammx ntrpol amma,ammb,.5
aAa nestedap ammx,1,1,.0798,.6
aAb nestedap aAa, 1,1,.053, .7
aAc nestedap aAb, 1,1,.045, .8
aAd nestedap aAc, 1,1,.035, .5
aAe nestedap aAd, 1,1,.037, .5
aAf nestedap aAe, 1,1,.01, .5


                       
aFR moogladder aAe*1.5, kVF, .02
aFL moogladder aAe*1.5, kVF, .02

aVL ntrpol  a1,aFL,kVWD
aVR ntrpol a2, aFR, kVWD
asig  poscil kFB, ksize, gisine
aPL, aPR Panner aVL,aVR,k(asig)/4
xout  aVL*1.5,aVR*1.5
endop




instr 1
kGain cabbageGetValue "gain"
kMix cabbageGetValue "Mix"
kBr cabbageGetValue "Bright"
kSize cabbageGetValue "Size"
a1 inch 1
a2 inch 2

;opcode Map, k, kkkkk
;kin, kx1, kx2, ky1, ky2   xin 
kSizee Map kSize, 0,1,.001,.6
kBrs Map kBr, 0,1,4500,0
kBrh Map kBr, 0,1,0,500
kSizes portk kSizee,kSizee+.001
aoutl,aoutr StanyVerb a1,a2,kSizes,kSizes,8000-kBrs,1,kBrh
aoutll,aoutrr StanyVerb aoutl,aoutr,kSizes-.2,kSizes-.5,7000-kBrs,.7,kBrh
aoutlll,aoutrrr StanyVerb aoutll,aoutrr,kSizes-.3,kSizes-.6,5000-kBrs,.5,kBrh
aoutllll,aoutrrrr StanyVerb aoutl,aoutr,kSizes-.4,kSizes-.7,5000-kBrs,.4,kBrh
kmixs portk kMix,kMix+.001
averL ntrpol  a1,(aoutll+aoutlll+aoutllll)/2,kmixs
averR ntrpol  a2,(aoutrr+aoutrrr+aoutrrrr)/2,kmixs
outs averL*kGain, averR*kGain
endin

</CsInstruments>
<CsScore>
;causes Csound to run for about 7000 years...
f0 z
;starts instrument 1 and runs it for a week
i1 0 [60*60*24*7] 
</CsScore>
</CsoundSynthesizer>

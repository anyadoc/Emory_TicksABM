globals [
  Month
  y                           ;year counter
  hrp
  mid
  weekid
  cweekid
  phsn                        ;counter for potential host seking nymphs every time step (week)
  nhsp                        ;counter for nymph host seeking peak
  phsl
  lphsl
  hphsl
  lhsp
  eng-aticks                  ;counter for engorged adult ticks
  ]
patches-own [
  fp                 ;fp = 1 for forest
  pp                 ;pp = 1 for grass
  ]
breed [ cows cow ]
breed [ mice mouse ]
breed [ deer a-deer ]
breed [ aticks atick ]
breed [ nticks ntick ]
breed [ lticks ltick ]
breed [ eggs egg ]

mice-own [
  hr                  ;home-range radius
  ;tc                   ;tick carrying capacity
  home-patch
  lob                  ;larvae on body
  nob                  ;nymph on body
  atc
  ntc
  ltc
]
deer-own [
  ;tc                   ;tick carrying capacity
  atc
  ntc
  ltc
]
cows-own [
  ;tc
  atc
  ntc
  ltc
]
lticks-own [
  aiw                   ;age in weeks
  loc                   ;current location
  hs?                   ;host seeking?
  fe?                   ;fully engorged
  toh                   ;time on host
  moltp                 ;counter for molting period (5 weeks since fe? = TRUE)
  ]
nticks-own [
  aiw
  loc
  hs?
  fe?
  toh
  moltp
  ]
aticks-own [
  aiw
  loc
  hs?
  fe?
  toh
  rpot                 ;reproduction potential
]
eggs-own []

to setup
  ca
  ask patches [
    ifelse (pycor >= 77)
    [ set pcolor green + 3
      set fp 1 ]
    [ set pcolor green + 1
      set pp 1 ]
    ]
;  ask n-of (count patches / 2) patches [
;    if (pycor > 70) [
;      if (random 100 < 5) [
;        sprout 1 [
;          set shape "tree"
;          set size 10
;          ]
;        ]
;      ]
;    ]
;  let green-patches patches with [ pp = 1 ]
  let forest-patches patches with [ fp = 1 ]
  ;ask n-of 5 green-patches[  ;24April17 inactivated
    ;sprout-cows 1[
      ;set shape "cow"
      ;set size 1.5
      ;set color brown
    ;]
  ;]
  ;ask n-of 20 green-patches[
    ;sprout-mice 5[
      ;rt random 359
      ;fd .5
      ;set shape "mouse side"
      ;set size .75
    ;]
  ;]
  ask n-of 10 forest-patches [
    sprout-deer 1 [
      set shape "deer"
      set size 2.5
      set atc round (random-exponential 5)
      set ntc 0
      set ltc 0
      ]
    ]
  reset-ticks
end

to go
  tick
  ifelse (cweekid = 1)
  [ set weekid 1
    set cweekid 0
    ]
  [ set weekid weekid + 1 ]
  if weekid < 5 [ set mid 1 set Month "JAN" ]
  if weekid > 4 and weekid < 9 [ set mid 2 set Month "FEB" ]
  if weekid > 8 and weekid < 13 [ set mid 3 set Month "MAR" ]
  if weekid > 12 and weekid < 18 [ set mid 4 set Month "APR" ]
  if weekid > 17 and weekid < 22 [ set mid 5 set Month "MAY" ]
  if weekid > 21 and weekid < 26 [ set mid 6 set Month "JUN" ]
  if weekid > 25 and weekid < 31 [ set mid 7 set Month "JUL" ]
  if weekid > 30 and weekid < 35 [ set mid 8 set Month "AUG" ]
  if weekid > 34 and weekid < 40 [ set mid 9 set Month "SEP" ]
  if weekid > 39 and weekid < 44 [ set mid 10 set Month "OCT" ]
  if weekid > 43 and weekid < 48 [ set mid 11 set Month "NOV" ]
  if weekid > 47 [ set mid 12 set Month "DEC" ]

  if (weekid = 13) [
    set nhsp (16 + random 9)             ;nymph host seeking peak
    set lhsp nhsp + 8                    ;larvae host seeking peak
    ]
  if (remainder (ticks) 52 = 0) [  ;48
    set cweekid 1
    ]
  if (remainder (ticks) 52 = 1 and ticks != 1) [ ;48
    set y (y + 1)
    ]
  if (ticks = 521) [
    stop
    ]
  ;----------------------------------------------------------------------------
  if (ticks = 233) [
    ask n-of 50 patches [
      sprout-aticks 1 [
        set aiw 31
        set loc patch-here
        set rpot round (random-normal 1500 500)
        set fe? TRUE
        set toh -999
        set pcolor black
        ht
        ]
      ]
    ]
  ;----------------------------------------------------------------------------
  if (remainder mid 4 = 0 or count mice = 0) [; remainder weekid 16 = 0 remainder mid 4 = 0
    let total-mice count mice
    let mice-newpop (16 * (random 11 + 25))   ;gives a value between 25 and 35- this will be the density of mice per hectare for the next 4 months
    ifelse (total-mice > mice-newpop)
    [ ask n-of (total-mice - mice-newpop) mice [
      die
      ]
      ]
    [if (mice-newpop - total-mice) > 0 [
        ask n-of ((mice-newpop - total-mice) / 2) patches with [ pp = 1 ] [
          sprout-mice 1 [
            set shape "mouse side"
            set size 0.5
            set hr (40 + random 601) ;set hrr (3.5 + random 11)
            set home-patch patch-here
            set color grey
            ]
        ]
      ]
      ]
    ;let mice-patches patches with [count mice-here > 0]
    ask mice [
      host-agg-l                                      ;submodel for host aggregation
      host-agg-n
      ]

    set-current-plot "host aggregation mice: larvae"
    histogram [ ltc ] of mice
    set-current-plot "host aggregation mice: nymphs"
    histogram [ ntc ] of mice
    ]
  ;stop
  ;-----------------------------------------------------------------------------
  ask lticks [
    set aiw aiw + 1
    ]
  if (weekid > 26 and weekid < 43) [
    set phsl count lticks with [ aiw < 18 and fe? = FALSE ]
    set lphsl round (phsl * 0.01)
    set hphsl round (phsl * 0.25)
    let hsl lticks with [ fe? = FALSE ]
    ifelse (weekid >= lhsp and weekid < (lhsp + 4))                       ;####bug detected 24 Nov2020 weekid = lhsp changed to weekid >= lhsp
    [ ask n-of hphsl hsl [
      set hs? TRUE
      ]
      ]
    [ ask n-of lphsl hsl [
      set hs? TRUE
      ]
      ]
    ]
  let noneng-lticks lticks with [ fe? = FALSE ]
  let lessthan16wk_noneng-lticks noneng-lticks with [ aiw < 16 ]
  let wk16orolder_noneng-lticks noneng-lticks with [ aiw >= 16 ]
  if (count lessthan16wk_noneng-lticks > 0) [
    ask n-of round(0.14 * count lessthan16wk_noneng-lticks) lessthan16wk_noneng-lticks [
      die
      ]
    ]
  if (count wk16orolder_noneng-lticks > 0) [
    ask n-of round(0.89 * count wk16orolder_noneng-lticks) wk16orolder_noneng-lticks [
      die
      ]
    ]
  let eng-lticks lticks with [ fe? = TRUE ]
  if (count eng-lticks > 0) [
    ask eng-lticks [
      if (random 100 < 8) [
        die
        ]
      if (toh = -999) [
        set moltp (moltp + 1)
        if (moltp > 0)[                                 ;added so the engorged larvae takes 5 weeks before it molts to nymph
          ask patch-here [
            sprout-nticks 1 [
              set aiw 1
              set loc patch-here
              set fe? FALSE
              set hs? FALSE
              ht
              ]
            ]
          die
          ]
        ]
      ]
    ]
  ;----------------------------------------------------------------------------
  ask nticks [
    set aiw aiw + 1
    set phsn count nticks with [ aiw > 19 and fe? = FALSE ]             ;potential host seeking nymphs; host seeking starts April peak host seeking in June continues until Oct end
    let hsn nticks with [ aiw > 19 and fe? = FALSE ]
    let lphsn round (phsn * 0.1)
    let hphsn round (phsn * 0.25)
    if (weekid > 13 and weekid < 45) [
      ifelse (weekid >= (nhsp - 1) and weekid < (nhsp + 4))
      [ ask n-of hphsn hsn [
        set hs? TRUE
        ]
        ]
      [ ask n-of lphsn hsn [
        set hs? TRUE
        ]
        ]
      ]
    if (aiw < 28 and fe? = FALSE) [
      if (random-float 1 < 0.07) [
        die
        ]
      ]
    if (aiw > 27 and fe? = FALSE) [
      if (random-float 1 < 0.13) [
        die
        ]
      ]
    if (fe? = TRUE) [
      if random 100 < 8 [
        die
        ]
      if (toh = -999) [
        set moltp (moltp + 1)
        if (moltp > 5 and weekid < 49) [                    ;added so the engorged larvae takes 5 weeks before it molts to nymph
          ask patch-here [
            print "ntick molts to adult"
            sprout-aticks 1 [
              set aiw 1
              set loc patch-here
              set fe? FALSE
              set hs? FALSE
              set rpot round (random-normal 1500 500)
              ht
              ]
            ]
          die
          ]
        if (moltp > 5 and weekid > 49) [
          set moltp -999
          ]
        if (weekid > 8 and moltp < -800) [
          ask patch-here [
            print "ntick molts to adult"
            sprout-aticks 1 [
              set aiw 1
              set loc patch-here
              set fe? FALSE
              set hs? FALSE
              set rpot round (random-normal 1500 500)
              ht
              ]
            ]
          die
          ]
        ]
      ]
    ]
  ;---------------------------------------------------------------------------
  ask aticks [
    set aiw aiw + 1
    if (aiw >= 70) [
      die
      ]
    if (fe? = FALSE) [
      if (weekid > 8 and weekid < 23) or (weekid > 39 and weekid < 49) [
        set hs? TRUE
        ]
      ]
    if (weekid > 48 or weekid < 9) [           ;unfed adult ticks overwintering mortality
      ifelse (fe? = FALSE)
      [ if (random-float 1 < 0.11) [
        die
        ]
        ]
      [ if (random-float 1 < 0.06) [
        ;die
        ]
        ]
      ]
    if weekid > 22 and weekid < 27 [
      if (fe? = TRUE and toh = -999) [
        hatch-eggs round (rpot * 0.83) [
          ht
          ]
        die
        ]
      ]
    ]
  ;-----------------------------------------------------------------
  if (weekid = 26) [
    ask eggs [
      ask patch-here [
        sprout-lticks 1 [
          set aiw 1
          set loc patch-here
          set fe? FALSE
          set hs? FALSE
          ht
          set pcolor red
          ]
        ]
      die
      ]
    ]
  ;-----------------------------------------------------------------------
  ask mice [
    let twho who
    let myhr min-n-of hr patches [ distance myself ]
    pd
    repeat 7
    [;fd (random hrr)
      move-to one-of myhr
      if (random 7 < 2) [             ;If the larval tick has been on the host for more than 2 days or the nymphal tick has been on the host for more than 4 days, ~70% chance that it will be engorged and thus deposited on the patch.
        eltick-dep
        entick-dep
      ]
      ltick-inf
      ntick-inf
      pen-erase
      move-to home-patch
      let attached-lticks lticks with [ loc = twho ]
      let attached-nticks nticks with [ loc = twho ]
      if (count attached-lticks > 0)[
        ask attached-lticks [ set toh toh + 1 ]
      ]
      if (count attached-nticks > 0)[
        ask attached-nticks [ set toh toh + 1 ]
      ]
      ltick-inf
      ntick-inf
      rt random 359
      set lob count lticks with [ loc = twho ]
      set nob count nticks with [ loc = twho ]
    ]
    mice-mortality
    set lob count lticks with [loc = twho]
    ]
  ;-------------------------------------------------
  ask cows [
    if random-float 1 < 0.01 [
      rt random 359
      fd 0.1
      if (pcolor = green + 3) [
        move-to min-one-of patches with [ pcolor = green + 1 ] [ distance myself ]
        ]
      ]
    ]
  ask deer [
    let twho who
    repeat 7
    [ move-to one-of patches with [ pp = 1 ]
      ltick-inf
      ntick-inf
      atick-inf
      if any? aticks with [ loc = twho ] [
        ask aticks with [ loc = twho ] [
          set toh toh + 1
        ]
        ]
      eatick-dep
      entick-dep
      eltick-dep
      ]
    move-to one-of patches with [ fp = 1 ]
    ]
  ask n-of (count mice / 5) mice [
    ht
    ]
end

to mice-mortality
  if (random-float 1 < 0.085) [     ;ref for mice mortality 0.038 Mount et al 1997 JMedEnt
    die
    ]
end

to eatick-dep
  let twho who
  let this-patch patch-here
  let aticks-on-this-adeer aticks with [ fe? = TRUE and loc = twho and toh > 1 ]   ;time on host is more than 1 week
  if (count aticks-on-this-adeer > 0) [
    ask aticks-on-this-adeer [
      move-to this-patch
      set loc patch-here
      set color orange
      set toh -999
      set eng-aticks eng-aticks + 1
    ]
  ]
end

to eltick-dep
  let twho who
  let this-patch patch-here
  let lticks-on-this-mouse lticks with [ fe? = TRUE and loc = twho and toh > 2 ]
  if (count lticks-on-this-mouse > 0) [
    ask lticks-on-this-mouse [
      move-to this-patch
      set loc patch-here
      set color blue
      set toh -999
      ]
    ]
end

to entick-dep
  let twho who
  let this-patch patch-here
  let nticks-on-this-turtle nticks with [ fe? = TRUE and loc = twho and toh > 4 ]
  if (count nticks-on-this-turtle > 0) [
    ask nticks-on-this-turtle [
      move-to this-patch
      set loc patch-here
      set color blue
      set toh -999
      ]
    ]
end

to atick-inf
  let twho who
  let potpatches (patch-set patches in-radius 5);patch-here neighbors)
  let cand-aticks aticks-on potpatches
  let pros-aticks cand-aticks with [ hs? = TRUE ]
  let current_ti count aticks with [ loc = twho ]
  let pot_ti (atc - current_ti)
  if (current_ti < atc) [
    if (count pros-aticks > 0) [
      let counter2 0
      ifelse (pot_ti >= count pros-aticks)
      [ set counter2 count pros-aticks ]
      [ set counter2 pot_ti ]
      ask n-of ((counter2 / 2) + random (counter2 / 2)) pros-aticks [
        set loc twho
        set toh 1
        set fe? TRUE
        set hs? FALSE
      ]
    ]
  ]
end

to ltick-inf
  let twho who
  let this-patch patch-here
  ;let nticks-here nticks-on this-patch
  ;let hsnticks-here nticks-here with [ hs? = TRUE ]
  let lticks-here lticks-on this-patch
  let hslticks-here lticks-here with [ hs? = TRUE ]
  ;let immature-ticks-here (turtle-set hsnticks-here hslticks-here)
  let current_lti count lticks with [ loc = twho ] ;+ count nticks with [ loc = twho ])
  let pot_lti (ltc - current_lti)
  if (current_lti < ltc) [
    if (count hslticks-here > 0) [     ;8Aug18 BUG! changed lticks-here to hslticks-here
      let counter2 0
      ifelse (pot_lti >= count hslticks-here)  ;8Aug18 BUG! changed lticks-here to hslticks-here
      [ set counter2 count hslticks-here ]     ;8Aug18 BUG! changed lticks-here to hslticks-here
      [ set counter2 pot_lti ]
      ask n-of ((counter2 / 2) + random (counter2 / 2)) hslticks-here [   ;8Aug18 BUG! changed lticks-here to hslticks-here
        set loc twho
        set toh 1
        set fe? TRUE
        set hs? FALSE
        set moltp -4
      ]
    ]
  ]
end
to ntick-inf
  let twho who
  let this-patch patch-here
  let nticks-here nticks-on this-patch
  let hsnticks-here nticks-here with [ hs? = TRUE ]
  ;let lticks-here lticks-on this-patch
  ;let hslticks-here lticks-here with [ hs? = TRUE ]
  ;let immature-ticks-here (turtle-set hsnticks-here hslticks-here)
  let current_nti count nticks with [ loc = twho ]
  let pot_nti (ntc - current_nti)
  if (current_nti < ntc) [
    if (count nticks-here > 0) [
      let counter2 0
      ifelse (pot_nti >= count nticks-here)
      [ set counter2 count nticks-here ]
      [ set counter2 pot_nti ]
      ask n-of ((counter2 / 2) + random (counter2 / 2)) nticks-here [
        set loc twho
        set toh 1
        set fe? TRUE
        set hs? FALSE
        set moltp -4
      ]
    ]
  ]
end

to host-agg-l
;  ifelse (random 100 < 81)
;  [ set tc random 15 ]
;  [ set tc (16 + random 15) ]
  let prob dispersion-parameter-klm / (dispersion-parameter-klm + mean-intensity-lm)
  let scale (1 - prob) / prob
  let gamma-mean dispersion-parameter-klm * scale
  let gamma-variance dispersion-parameter-klm * scale * scale
  let alfa gamma-mean * (gamma-mean / gamma-variance)
  let lammbda 1 / (gamma-variance / gamma-mean)
  set ltc round (random-poisson (random-gamma alfa lammbda))
;  if tc = 0 [
;    set tc 1
;    ]
end
to host-agg-n
;  ifelse (random 100 < 81)
;  [ set tc random 15 ]
;  [ set tc (16 + random 15) ]
  let prob dispersion-parameter-knm / (dispersion-parameter-knm + mean-intensity-nm)
  let scale (1 - prob) / prob
  let gamma-mean dispersion-parameter-knm * scale
  let gamma-variance dispersion-parameter-knm * scale * scale
  let alfa gamma-mean * (gamma-mean / gamma-variance)
  let lammbda 1 / (gamma-variance / gamma-mean)
  set ntc round (random-poisson (random-gamma alfa lammbda))
;  if tc = 0 [
;    set tc 1
;    ]
end
to-report dispersion-parameter-klm
  report 0.5;862
end
to-report mean-intensity-lm
  report 11
end

to-report dispersion-parameter-knm
  report 0.5;862
end
to-report mean-intensity-nm
  report 1.97
end
@#$#@#$#@
GRAPHICS-WINDOW
168
10
656
499
-1
-1
6.0
1
10
1
1
1
0
0
0
1
0
79
0
79
0
0
1
ticks
30.0

BUTTON
19
10
82
43
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
97
11
160
44
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
162
514
668
567
> model landscape size is set to 16 hectares (400 meters by 400 meters)\n> model runs for 20 years (240 months/960 weeks)\n\n
15
105.0
1

MONITOR
784
169
856
214
NIL
count mice
0
1
11

PLOT
901
10
1112
168
host aggregation mice: larvae
NIL
NIL
0.0
200.0
0.0
10.0
true
false
"set-histogram-num-bars 10" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [lob] of mice"

MONITOR
1153
431
1226
476
Adults
count aticks with [hs? = FALSE]
0
1
11

MONITOR
671
434
741
479
Larvae
count lticks with [fe? = FALSE]
0
1
11

MONITOR
1109
170
1259
215
NIL
count mice with [lob > 0]
0
1
11

PLOT
902
167
1089
295
mice abundance
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count mice "

MONITOR
668
485
761
530
Engorged larvae
count lticks with [fe? = TRUE and hs? = FALSE]
17
1
11

MONITOR
770
63
827
108
NIL
mid
17
1
11

MONITOR
674
14
759
59
Current Year
y + 1
17
1
11

MONITOR
836
64
893
109
NIL
weekid
17
1
11

PLOT
670
307
830
427
host-seeking larvae
NIL
NIL
0.0
300.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count lticks with [fe? = FALSE and hs? = TRUE]"

MONITOR
748
434
859
479
Host-seeking larvae
count lticks with [fe? = FALSE and hs? = TRUE]
17
1
11

MONITOR
766
485
877
530
Larvae ready to molt
count lticks with [toh < -777]
17
1
11

MONITOR
902
430
974
475
Nymphs
count nticks with [fe? = FALSE and hs? = FALSE]
17
1
11

MONITOR
980
431
1093
476
Host-seeking nymphs
count nticks with [fe? = FALSE and hs? = TRUE]
17
1
11

MONITOR
903
481
1005
526
Engorged nymphs
count nticks with [fe? = TRUE and hs? = FALSE]
17
1
11

MONITOR
1010
482
1129
527
Nymphs ready to molt
count nticks with [toh < -777]
17
1
11

MONITOR
1155
484
1248
529
Engorged aticks
count aticks with [ fe? = true ]
17
1
11

MONITOR
1234
431
1341
476
Host-seeking aticks
count aticks with [hs? = TRUE]
17
1
11

MONITOR
768
15
825
60
Month
Month
17
1
11

PLOT
903
306
1063
426
host-seeking nymphs
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -2674135 true "" "plot count nticks with [fe? = FALSE and hs? = TRUE]"

PLOT
1152
307
1313
427
host-seeking adults
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count aticks with [fe? = FALSE and hs? = TRUE]"

MONITOR
1102
237
1176
282
NIL
count eggs
17
1
11

MONITOR
1193
239
1272
284
NIL
count aticks
17
1
11

PLOT
1130
10
1330
160
host aggregation mice: nymphs
NIL
NIL
0.0
50.0
0.0
10.0
true
false
"" "histogram [ ntc ] of mice"
PENS
"default" 1.0 1 -16777216 true "" ""

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)
https://sites.google.com/site/biologydarkow/ecology/changing-carrying-capacity

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

deer
false
0
Polygon -955883 true false 195 210 210 255 195 240 180 195 165 165 135 165 105 165 75 165 72 211 60 210 60 180 45 150 45 120 30 90 45 105 180 105 225 45 225 60 270 90 255 90 225 90 180 150
Polygon -955883 true false 73 210 86 251 75 240 60 210
Polygon -7500403 true true 45 105 30 75 30 90 45 105 60 120 45 120
Line -6459832 false 210 60 165 15
Line -6459832 false 225 60 255 45
Line -6459832 false 195 45 210 15
Line -6459832 false 255 45 255 30
Line -6459832 false 255 45 270 30
Line -6459832 false 195 15 180 30

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

mouse side
false
2
Polygon -7500403 true false 38 162 24 165 19 174 22 192 47 213 90 225 135 230 161 240 178 262 150 246 117 238 73 232 36 220 11 196 7 171 15 153 37 146 46 145
Polygon -7500403 true false 289 142 271 165 237 164 217 185 235 192 254 192 259 199 245 200 248 203 226 199 200 194 155 195 122 185 84 187 91 195 82 192 83 201 72 190 67 199 62 185 46 183 36 165 40 134 57 115 74 106 60 109 90 97 112 94 92 93 130 86 154 88 134 81 183 90 197 94 183 86 212 95 211 88 224 83 235 88 248 97 246 90 257 107 255 97 270 120
Polygon -16777216 true false 234 100 220 96 210 100 214 111 228 116 239 115
Circle -16777216 true false 249 120 14
Line -16777216 false 270 153 282 174
Line -16777216 false 272 153 255 173
Line -16777216 false 269 156 268 177

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
1
Rectangle -6459832 true false 120 195 180 300
Circle -13840069 true false 118 3 94
Circle -13840069 true false 65 21 108
Circle -13840069 true false 116 41 127
Circle -13840069 true false 60 105 90
Circle -13840069 true false 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@

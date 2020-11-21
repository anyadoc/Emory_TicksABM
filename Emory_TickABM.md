### NEON Ecological Forecasting Challenge Webpage:

<a href="https://ecoforecast.org/efi-rcn-forecast-challenges/" class="uri">https://ecoforecast.org/efi-rcn-forecast-challenges/</a>

<mark> To forecast total *Ixodes scapularis* and *Amblyomma americanum*
nymphs each epidemiological week (Sun-Sat) at a set of NEON plots within
NEON sites.

### Important dates for the forecasting challenge

<mark> Training data available until Jan 31, 2021 <br> <mark> 1st
Forecast submission March 31, 2021

#### Link to Github repository neonfprecast-ticks:

<a href="https://github.com/eco4cast/neon4cast-ticks" class="uri">https://github.com/eco4cast/neon4cast-ticks</a>

#### Eleven tips for working with large data sets:

<a href="https://www.nature.com/articles/d41586-020-00062-z" class="uri">https://www.nature.com/articles/d41586-020-00062-z</a>

#### RMarkdown resources:

<a href="https://m-clark.github.io/Introduction-to-Rmarkdown/" class="uri">https://m-clark.github.io/Introduction-to-Rmarkdown/</a>
<br>

<a href="https://rmd4sci.njtierney.com/" class="uri">https://rmd4sci.njtierney.com/</a>
<a href="https://bookdown.org/yihui/rmarkdown/" class="uri">https://bookdown.org/yihui/rmarkdown/</a>
<a href="https://www.rosannavanhespen.nl/thesis_in_rmarkdown/" class="uri">https://www.rosannavanhespen.nl/thesis_in_rmarkdown/</a>
<a href="https://rmarkdown.rstudio.com/formats.html" class="uri">https://rmarkdown.rstudio.com/formats.html</a>

#### Github & R:

<a href="https://lab.github.com/" class="uri">https://lab.github.com/</a>
<a href="https://dev.to/lberlin/a-github-guide-for-people-who-don-t-understand-github-n50" class="uri">https://dev.to/lberlin/a-github-guide-for-people-who-don-t-understand-github-n50</a>
<a href="https://ropenscilabs.github.io/actions_sandbox/" class="uri">https://ropenscilabs.github.io/actions_sandbox/</a>

#### Version control:

<a href="https://www.britishecologicalsociety.org/wp-content/uploads/2019/06/BES-Guide-Reproducible-Code-2019.pdf" class="uri">https://www.britishecologicalsociety.org/wp-content/uploads/2019/06/BES-Guide-Reproducible-Code-2019.pdf</a>

<a href="https://happygitwithr.com/" class="uri">https://happygitwithr.com/</a>
<a href="https://www.r-bloggers.com/2018/05/using-rstudio-and-git-version-control/" class="uri">https://www.r-bloggers.com/2018/05/using-rstudio-and-git-version-control/</a>
<a href="https://www.edureka.co/blog/git-tutorial/" class="uri">https://www.edureka.co/blog/git-tutorial/</a>

This is the best:
<a href="https://github.com/pcottle/learnGitBranching" class="uri">https://github.com/pcottle/learnGitBranching</a>

#### NetLogo

Style guide
<a href="http://ccl.northwestern.edu/courses/mam-03/styleguide.html" class="uri">http://ccl.northwestern.edu/courses/mam-03/styleguide.html</a>

Avoid globals
<a href="https://gist.github.com/nicolaspayette/8051fa9c289897c4bf97c4d6abf3386d" class="uri">https://gist.github.com/nicolaspayette/8051fa9c289897c4bf97c4d6abf3386d</a>

### ODD: Multi-stage ticks, multihost agent-based model

**Purpose** <br> MSTMH is an agent-based model of an ecological
community comprising of *Ixodes scapularis* (blacklegged tick) and three
vertebrate hosts, white-footed mice *Peromyscus leucopus*, white-tailed
deer *Odocoileus virginianus* and domestic cattle *Bos taurus*. The
objective is to simulate the population dynamics of *I. scapularis*, and
assess effects of grazing domestic ruminants on abundance of different
stages of *I. scapularis*. Our overarching goal is to explore the
complex dynamics of host community composition, tick stages and
*Borrelia burgdorferi*, and thereby support development of locale
specific Lyme disease control strategies. <br> **Entities, state
variables and scales** <br> *Spatial scale*: MSTMH has a 400 meters by
400 meters (16 hectares) simplified landscape. Each patch is 25 m^2.<br>
*Temporal scale*: MSTMH has a weekly timestep, and the duration of the
simulation is 20 years. First 5 years are for equilibration.<br>
*Entities*: This model has seven entities: four tick stages (egg,
larval, nymphal and adult) and three host species - white-footed mouse,
white-tailed deer and domestic cattle.<br> *State variables*: The larval
(**lticks**) and nymphal (**nticks**) stages have six state variables
each: *aiw* (age in weeks), *loc* (location: patch id or host id), *hs?*
(boolean: true if seeking host), *fe?* (boolean: true if fully
engorged), *toh* (time attached to the current host) and *moltp*
(counter for time since fully engorged). The adult (**aticks**) stage
has the same state variables as the other two stages with the exception
of *moltp*. Instead it has a state variable *rpot* (reproductive
potential - number of eggs produced). The egg stage does not have any
state variables. <br> Mice in the model have three state variables:
*home-patch*, *hrr* (home-range radius) and *tc* (tick carrying
capacity). Other host species, deer and cattle, have only one state
variable, *tc*. <br> **Process overview and scheduling**

*Mice population dynamics*: Mice are randomly distributed in the model
landscape. We do not simulate births and deaths in the model mice
population. Instead, mice density, and therefore mice population, is set
to fluctuate quarterly. A random value between 25 and 35 is selected
every four months to set the density of mice per hectare. <mark>
(Reference / supporting literature?).

Each mouse has a home-patch and a home-range. The home-range is set
between 0.1 hectare (1000 m^2) and 1.6 hectare (16000 m^2) <mark>
(Reference?).Every time step, each mouse accesses upto seven random
patches within its homerange.

###### Figure 1: Tick stages and hosts

<img src="https://github.com/anyadoc/Emory_TicksABM/raw/main/TickStageSchedule.PNG" alt="Figure 1" style="width:50.0%" />
<br> The larval and nymphal peak activity periods do not overlap.

Almost without exception, macroparasites are aggregated across their
host populations - majority of the parasite population is concentrated
into a minority of the host population. Devevey\_2012 report that most
larvae (79.6 %) and most nymphs (79.8 %) at their study sites in
southeastern Pennsylvanis were attached to a minority of mice (46.9 %
and 25.4 % for larval and nymphal stages, respectively). The
distribution of ticks on mice follows a negative binomial distribution
(larval distribution, k = 0?862,P = 0?84; nymphal distribution, k =
0?299, P = 0?14) that strongly supports a non-random distribution.
Heterogeneity among individual hosts explains the aggregation of
ectoparasites-supported by repeatability of ticks on mice over time such
that highly parasitized mice remain highly parsitized throughout the
season. <mark> Majority of ticks parasitized a consistent set of mice
throughout the activity seasons. Also, the entire cohort of ticks
feeding on a mouse is replaced every 3-5 days (Brunner et al. 2011) <br>

###### Figure 2: From Devevey & Brisson, 2012 - larval aggregation

![Figure
2](https://github.com/anyadoc/Emory_TicksABM/raw/main/larvalburdenmice.PNG)
<br>

###### Figure 3: From Devevey & Brisson, 2012 - nymphal aggregation

![Figure
3](https://github.com/anyadoc/Emory_TicksABM/raw/main/nymphalburdenmice.PNG)

<a href="https://www.nytimes.com/2017/08/02/science/ticks-lyme-disease-foxes-martens.html?mwrsm=Email" class="uri">https://www.nytimes.com/2017/08/02/science/ticks-lyme-disease-foxes-martens.html?mwrsm=Email</a>

#### Notes and references

<mark> *I. scapularis* crawls no more than a few meters during any of
its life stages (Daniels and Fish 1990, Falco and Fish 1991, Daniels et
al. 1996). <br>

*I. scapularis* is a three-host tick, each postembryonic life stage
(larva, nymph, and adult) requires a single blood meal to molt to the
next life stage (Sonenshine 1991). <br>

Devevey\_2012
<a href="https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3856707/" class="uri">https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3856707/</a>
Authors have examined the aggregation of immature *I. scapularis* ticks
(larvae and nymphs) both while seeking a host and while attached to
white-footed mice.

<br>

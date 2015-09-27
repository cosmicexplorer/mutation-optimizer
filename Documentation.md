---
title: Documentation
description: A contact email, for questions
---

# Description

This software will optimize sequences against mutation. A description of the underlying concepts is available at the [iGEM wiki page](https://2015.igem.org/Team:Vanderbilt). It accepts sequences of DNA or amino acids, and produces a synonymous version with a (typically *much*) smaller rate of mutation. The weighting of individual mutation hotspots can be modified, and the effectiveness of the optimization (the percent reduction in mutation hotspots) can be viewed on a meter.

# Issues

The 'Sequence Input' panel in 'DNA' mode is ONLY guaranteed to accept open reading frames; while it *can* parse and optimize other sequences, this is not guaranteed to work and it may send you an opaque alert message.

The optimization does not run off our server, it is run entirely in client-side javascript using Web Workers. Because of this, if it seems to be taking a very long time to optimize a sequence, a bug has likely occurred; it is NOT a network connection issue. Open up the developer tools if you have experience with those; otherwise, contact us at the address specified below. Modern laptops and workstations can expect optimization at &gt; 600 kb/s, but older machines may take longer.

The 'Search Species' panel curently has no effect; the modifications made are only theoretically optimal for E. coli. We are working to update this, but we need to collate experimental research, as the majority of our wet lab work was on E. coli.

# Contact

Contact us with any issues at vanderbilt &lt;dot&gt; igem &lt;at&gt; gmail &lt;dot&gt; com.

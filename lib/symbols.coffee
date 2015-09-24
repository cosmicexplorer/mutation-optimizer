module.exports =
  AminoIUPAC: ['W','L','P','H','Q','R','I','M','T','N','K','S','V',
    'A','D','E','G','F','Y','C','-']
  AminoTransform:
    '*': '-'
    'X': '-'

  DNAIUPAC: ['A','T','G','C','U','R','Y','N']
  DNACodonAminoMap:
    '-': ['TGA', 'TAG', 'TAA']
    'A': ['GCT', 'GCC', 'GCA', 'GCG']
    'C': ['TGT', 'TGC']
    'D': ['GAT', 'GAC']
    'E': ['GAA', 'GAG']
    'F': ['TTT', 'TTC']
    'G': ['GGT', 'GGC', 'GGA', 'GGG']
    'H': ['CAT', 'CAC']
    'I': ['ATA', 'ATC', 'ATT']
    'K': ['AAA', 'AAG']
    'L': ['CTT', 'CTC', 'CTA', 'CTG', 'TTA', 'TTG']
    'M': ['ATG']
    'N': ['AAT', 'AAC']
    'P': ['CCT', 'CCC', 'CCA', 'CCG']
    'Q': ['CAA', 'CAG']
    'R': ['AGA', 'AGG', 'CGT', 'CGC', 'CGA', 'CGG']
    'S': ['AGT', 'AGC', 'TCT', 'TCC', 'TCA', 'TCG']
    'T': ['ACT', 'ACC', 'ACA', 'ACG']
    'V': ['GTT', 'GTC', 'GTA', 'GTG']
    'W': ['TGG']
    'Y': ['TAT', 'TAC']
  DNATransformSyms:
    'U': 'T'

  CodonUsage:
    'ATG': 1.00
    'ATA': 0.11
    'ATC': 0.39
    'ATT': 0.49
    'ACT': 0.19
    'ACC': 0.40
    'ACA': 0.17
    'ACG': 0.25
    'AAA': 0.74
    'AAG': 0.26
    'AAT': 0.49
    'AAC': 0.51
    'AGT': 0.16
    'AGC': 0.25
    'AGA': 0.070
    'AGG': 0.04
    'CTT': 0.12
    'CTC': 0.10
    'CTA': 0.04
    'CTG': 0.47
    'CCT': 0.18
    'CCC': 0.13
    'CCA': 0.20
    'CCG': 0.49
    'CAT': 0.57
    'CAC': 0.43
    'CAA': 0.34
    'CAG': 0.66
    'CGT': 0.361
    'CGC': 0.360
    'CGA': 0.071
    'CGG': 0.11
    'GTT': 0.28
    'GTC': 0.20
    'GTA': 0.17
    'GTG': 0.35
    'GCT': 0.18
    'GCC': 0.26
    'GCA': 0.23
    'GCG': 0.33
    'GAT': 0.63
    'GAC': 0.37
    'GAA': 0.68
    'GAG': 0.32
    'GGT': 0.35
    'GGC': 0.37
    'GGA': 0.13
    'GGG': 0.15
    'TTT': 0.58
    'TTC': 0.42
    'TTA': 0.14
    'TTG': 0.13
    'TCT': 0.17
    'TCC': 0.15
    'TCA': 0.141
    'TCG': 0.140
    'TAT': 0.59
    'TAC': 0.41
    'TGT': 0.46
    'TGC': 0.54
    'TGG': 1.00
    'TGA': 0.30
    'TAG': 0.09
    'TAA': 0.61

  AminoStartCodons: ['M']
  AminoEndCodons: ['-']

  StartCodons: ['ATG']
  StopCodons: ['TGA', 'TAG', 'TAA']

  RateLimitingCodons: ['CTA', 'TAG', 'CGA', 'CGG', 'AGA', 'AGG', 'ATA']
  AntiShineDelgarno: ['AGG', 'GGA', 'GAG', 'GGG', 'GGT', 'GTG']
  TTDimers: ['TT', 'AA']
  OtherPyrDimers: ['CT', 'TC', 'CC', 'CY', 'TY', 'YC', 'YT', 'YY', 'GA', 'AG',
    'GG', 'AR', 'RA', 'GR', 'RG', 'RR']
  # TODO: modify these weights as given from UV dimer products pdf in this
  # directory
  WeightedPyrDimers:
    '.581': ['TT', 'AA']
    '.586': ['TC', 'GA']
    '.104': ['CT', 'AG']
    '.0111': ['CC', 'GG']
  MethylationSites: ['GATC', 'CTAG', 'CCAGG', 'CCTGG', 'GGTCC', 'GGACC']
  DeaminationSites: ['CG', 'GC']
  AlkylationSites: ['GG', 'CC', 'AG', 'CT', 'TC', 'GA']
  OxidationSites: ['GGG', 'GG', 'CCC', 'CC']
  MiscSites: ['TTG', 'CTG', 'GTGG', 'CCAC', 'GGCGCC']
  HairpinSites: [
    /CCTCCGG/g
    /CC...GG/g # . basically means N
    /CG...CG/g
    /GC...GC/g
    /GG...CC/g]
  InsertionSequences: [
    # ISEc17
    'TGCGGACGATCATCAGTTAT'
    'ATAACTGATGATCGTCCGCA'
    # IS903B
    'GATCGTTGGGAACCG'
    'CGGTTCCCAACGATC'
    # IS50R
    'GCAGTCAGGCACCGT'
    'TAAGCTTTAATGCGC'
    'GCAGTCAGGCACCGT'
    'GCCGCCCAGTCCTGC'
    # IS30
    'AGTGCCATCTCCTT'
    'AAGGAGATGGCACT'
    # IS103
    'TGTATCAGTGGGGCTTTG'
    'CAAAGCCCCACTGATACA'
    # IS1A
    'TTGTGTTTTTCAT'
    'ATGAAAAACACAA'
    'GGCATACTCTGCGACATCGT'
    'ACGATGTCGCAGAGTATGCC'
    'CTTATGACATTAAAAGTAAC'
    'TGAATAGCCTGTCTTACA'
    'TAACTGTTTCTTTTTGTT'
    # IS1G
    'CAGTCAGG'
    'CCTGACTG'
    # IS3
    'AAGTATATCA'
    'TGATATACTT']
  RFC10Sites: [
    'GAATTC'
    'TCTAGA'
    'ACTAGT'
    'CTGCAG']

  FunctionWeights:
    'Rate Limiting Codons':
      func: 'rateLimitingCodons'
      weight: 1000
    'Weighted Pyr Dimers':
      func: 'weightedPyrDimerCount'
      weight: 3
    'Misc Sites':
      func: 'miscSites'
      weight: .5
    'Hairpin Sites':
      func: 'hairpinSites'
      weight: 2
    'Insertion Sequences':
      func: 'insertionSequences'
      weight: 8
    'Anti-Shine Delgarno':
      func: 'antiShineDelgarno'
      weight: 5
    'Deaminations':
      func: 'deaminationSites'
      weight: 1
    'Repeat Runs':
      func: 'repeatRuns'
      weight: 5
    'Homologous Repeats':
      func: 'homologyRepeatCount'
      weight: .5
    'Alkylation':
      func: 'alkylationSites'
      weight: 1
    'Methylation':
      func: 'methylationSites'
      weight: 2
    'Oxidation':
      func: 'oxidationSites'
      weight: 3
    'RFC10':
      func: 'RFC10Sites'
      weight: 1000

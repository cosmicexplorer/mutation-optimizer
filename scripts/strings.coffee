_ = require 'lodash'
symbols = require '../lib/symbols'

# knobs we won't allow the user to turn
nonOptions = ['RFC10']

module.exports =
  DefaultSpeciesText: "No species selected."
  DefaultSpeciesColor: '#333'
  NavbarButtons:
    'Documentation': 'documentation.html'
  SearchPanelHeading: 'Search Species'
  SearchPanelDefault: 'Search for...'
  SpeciesToSearch: [
    'E. coli'
    'B. subtilis'
    'S. cerevisiae'
    'C. albicans'
    'C. elegans'
    'D. melanogaster'
    'M. musculus'
    'H. sapiens'
    'A. thaliana'
    ]
  InputPanelHeading: 'Sequence Input'
  InitialButtonTitle: 'DNA'
  InputButtonTitlesDirections:
    'DNA': 'Enter an open reading frame, beginning with a start codon and ending
with a stop codon, that contains only A, G, C, and T.'
    'Amino': 'Enter an amino acid sequence containing only the one-letter FASTA
abbreviations. Stop codons may be omitted, or entered as *, -, or X.'
  OutputPanelHeading: 'Codon Output'
  OutputButtonText: 'Go!'
  OutputDirections: 'Output Directions'
  ParameterOptionsHeading: 'Input Parameters'
  DefaultParamLabel: 'Use Default Parameters'
  ParameterizedOptions: do ->
    keys = Object.keys symbols.FunctionWeights
    # if nonOptions isn't a subset of FunctionWeights's keys
    if _.intersection(nonOptions, keys).length isnt nonOptions.length
      throw new Error "nonOptions not a subset of FunctionWeights!"
    res = {}
    keys.forEach (k) -> if k not in nonOptions
      res[k] = symbols.FunctionWeights[k].weight.toString()
    res
  AdvancedOptionsHeading: 'Advanced Options'
  AdvancedOptions:
    'Substitute': 'Allow conservative amino acid substitutions.'
    'Optimize': 'Optimize for increased evolutionary potential.'
    'RFC10': 'Toggle RFC10 recognition.'
  VersionName: 'mutation-optimizer v0.0'

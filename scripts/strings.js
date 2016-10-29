var _, nonOptions, symbols,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

_ = require('lodash');

symbols = require('../lib/symbols');

nonOptions = ['RFC10', 'Rate Limiting Codons'];

module.exports = {
  DefaultSpeciesText: "No species selected.",
  DefaultSpeciesColor: '#333',
  NavbarButtons: {
    'Documentation': 'Documentation'
  },
  SearchPanelHeading: 'Search Species',
  SearchPanelDefault: 'Search for...',
  SpeciesToSearch: ['E. coli', 'B. subtilis', 'S. cerevisiae', 'C. albicans', 'C. elegans', 'D. melanogaster', 'M. musculus', 'H. sapiens', 'A. thaliana'],
  InputPanelHeading: 'Sequence Input',
  InitialButtonTitle: 'DNA',
  InputButtonTitlesDirections: {
    'DNA': 'Enter an open reading frame, beginning with a start codon and ending with a stop codon, that contains only A, G, C, and T.',
    'Amino': 'Enter an amino acid sequence containing only the one-letter FASTA abbreviations. Stop codons may be omitted, or entered as *, -, or X.'
  },
  OutputPanelHeading: 'Codon Output',
  OutputButtonText: 'Go!',
  ClearButtonText: 'Clear',
  OutputDirections: 'The sequence below is optimized against mutation.',
  ParameterOptionsHeading: 'Input Parameters',
  DefaultParamLabel: 'Use Default Parameters',
  ParameterizedOptions: (function() {
    var keys, res;
    keys = Object.keys(symbols.FunctionWeights);
    if (_.intersection(nonOptions, keys).length !== nonOptions.length) {
      throw new Error("nonOptions not a subset of FunctionWeights!");
    }
    res = {};
    keys.forEach(function(k) {
      if (indexOf.call(nonOptions, k) < 0) {
        return res[k] = symbols.FunctionWeights[k].weight.toString();
      }
    });
    return res;
  })(),
  AdvancedOptionsHeading: 'Advanced Options',
  AdvancedOptions: {
    'Evolution': 'Optimize for increased evolutionary potential.',
    'RFC10': 'Turn on RFC10 site recognition.',
    'Rate Limiting Codons': 'Ignore rate-limiting codons.'
  },
  MutabilityScoreboardLabel: 'Mutability Scoreboard',
  MutabilityLabel: {
    label: 'Output Mutability Score',
    low: .002,
    max: .01,
    opt: .01
  },
  ChangeLabel: {
    label: 'Percent Mutability Change',
    low: 50,
    max: 100,
    opt: 100
  },
  NoSpeciesText: 'Species Selection is not currently functional. Please check the documentation page.',
  VersionName: 'mutation-optimizer v0.0'
};

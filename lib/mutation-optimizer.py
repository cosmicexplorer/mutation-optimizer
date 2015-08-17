def aa_seq_check(aa_seq):               # Verifies valid user input for amino acid sequence, using one-letter abbreviations
    aa_seq=''.join(aa_seq)
    aa_seq=aa_seq.upper()
    aa_seq=list(aa_seq)
    for i in range(0,len(aa_seq)):
        if aa_seq[i] in ['*','X','-']:      # Possible ways to represent stop codons in amino acid sequence
            aa_seq[i]='-'
        if aa_seq[i] not in ['W','L','P','H','Q','R','I','M','T','N','K','S','V','A','D','E','G','F','Y','C','-']:      # Amino acid coding codons
            print('The sequence entered contained symbols not included in the 1-letter IUPAC standard')
            raise SystemExit
    if aa_seq[len(aa_seq)-1]!='-':              # Amino acid sequence omits stop codon
        aa_seq.append('-')
    if aa_seq[0]!='M':              # Certain amino acid sequences omit the M start codon
        aa_sq=['M']
        for aa in aa_seq:
            aa_sq.append(aa)
        aa_seq=aa_sq
    return aa_seq

def dna_seq_check(dna_seq):         # Verifies valid user input for DNA sequence. All functions assume a simple ORF, beginning with start codon and ending with stop
    dna_seq=''.join(dna_seq)
    dna_seq=dna_seq.upper()
    dna_seq=list(dna_seq)
    for i in range(0,len(dna_seq)):
        if dna_seq[i]=='U':                 # Convert RNA to DNA
            dna_seq[i]='T'
            print('The sequence had a Uracil at position %d changed to Thymine.'%i)
        elif dna_seq[i] not in ['A','T','G','C','U','R','Y','N']:
            print('The sequence entered contained symbols not included in the 5-letter IUPAC standard')
            raise SystemExit
    if len(dna_seq)==0:
        print('No sequence was entered')
        raise SystemExit
    if len(dna_seq)%3!=0:
        print('The sequence entered does not have all codons in reading frame')
        raise SystemExit
    if dna_seq[0]+dna_seq[1]+dna_seq[2]!='ATG':
        print('The sequence entered does not begin with a start codon')
        raise SystemExit
    if dna_seq[-3]+dna_seq[-2]+dna_seq[-1] not in ['TGA','TAG','TAA']:
        print(dna_seq[-3]+dna_seq[-2]+dna_seq[-1])
        print('The sequence entered does not end with a stop codon')
        raise SystemExit
    dna_string=''.join(dna_seq)                     # ORF can only have one in-frame stop codon, located at the last position
    if dna_string.find('TGA')<len(dna_string)-3 and dna_string.find('TGA')!=-1 and dna_string.find('TGA')%3==0:
        print('The sequence entered contained a premature stop codon at position %d'%dna_string.find('TGA'))
        raise SystemExit
    if dna_string.find('TAG')<len(dna_string)-3 and dna_string.find('TAG')!=-1 and dna_string.find('TAG')%3==0:
        print('The sequence entered contained a premature stop codon at position %d'%dna_string.find('TAG'))
        raise SystemExit
    if dna_string.find('TAA')<len(dna_string)-3 and dna_string.find('TAA')!=-1 and dna_string.find('TAA')%3==0:
        print('The sequence entered contained a premature stop codon at position %d'%dna_string.find('TAA'))
        raise SystemExit
    return dna_seq

def codon_translation(codon):       # Translates DNA to codon proper one-letter amino acid code
    if codon=='ATG':
        return 'M'
    if codon in ['ATA','ATC','ATT']:
        return 'I'
    if codon in ['ACT','ACC','ACA','ACG']:
        return 'T'
    if codon in ['AAA','AAG']:
        return 'K'
    if codon in ['AAT','AAC']:
        return 'N'
    if codon in ['AGT','AGC']:
        return 'S'
    if codon in ['AGA','AGG']:
        return 'R'
    if codon in ['CTT','CTC','CTA','CTG']:
        return 'L'
    if codon in ['CCT','CCC','CCA','CCG']:
        return 'P'
    if codon in ['CAT','CAC']:
        return 'H'
    if codon in ['CAA','CAG']:
        return 'Q'
    if codon in ['CGT','CGC','CGA','CGG']:
        return 'R'
    if codon in ['GTT','GTC','GTA','GTG']:
        return 'V'
    if codon in ['GCT','GCC','GCA','GCG']:
        return 'A'
    if codon in ['GAT','GAC']:
        return 'D'
    if codon in ['GAA','GAG']:
        return 'E'
    if codon in ['GGT','GGC','GGA','GGG']:
        return 'G'
    if codon in ['TTT','TTC']:
        return 'F'
    if codon in ['TTA','TTG']:
        return 'L'
    if codon in ['TCT','TCC','TCA','TCG']:
        return 'S'
    if codon in ['TAT','TAC']:
        return 'Y'
    if codon in ['TGT','TGC']:
        return 'C'
    if codon in ['TGG']:
        return 'W'
    elif codon in ['TGA','TAG','TAA']:
        return '-'
    else:
        print('One or more codons were invalid')
        raise SystemExit
                            # for references purposes right now, but later could be used to replace the above codon_translation function
full_codon_dictionary={
'M':['ATG'],'I':['ATA','ATC','ATT'],'T':['ACT','ACC','ACA','ACG'],
'K':['AAA','AAG'],'N':['AAT','AAC'],'S':['AGT','AGC','TCT','TCC','TCA','TCG'],
'R':['AGA','AGG','CGT','CGC','CGA','CGG'],'L':['CTT','CTC','CTA','CTG','TTA','TTG'],
'P':['CCT','CCC','CCA','CCG'],'H':['CAT','CAC'],'Q':['CAA','CAG'],
'V':['GTT','GTC','GTA','GTG'],'A':['GCT','GCC','GCA','GCG'],'D':['GAT','GAC'],
'E':['GAA','GAG'],'G':['GGT','GGC','GGA','GGG'],'F':['TTT','TTC'],
'Y':['TAT','TAC'],'C':['TGT','TGC'],'W':['TGG'],'-':['TGA','TAG','TAA'] }
                                # condensed dictionary using abreviations R= G or A , Y= C or T , N= any
simplified_codon_dictionary={
'M':['ATG'],'I':['ATY','ATA'],'T':['ACN'],'K':['AAR'],'N':['AAY'],
'S':['AGY','TCN'],'R':['AGR','CGN'],'L':['CTN','TTR'],
'P':['CCN'],'H':['CAY'],'Q':['CAR'],'V':['GTN'],'A':['GCN'],
'D':['GAY'],'E':['GAR'],'G':['GGN'],'F':['TTY'],
'Y':['TAY'],'C':['TGY'],'W':['TGG'],'-':['TGA','TAR'] }
                                # conserves the chemical class that amino acid belongs to, or keeps amino acid if does not belong to simple class
conservative_codon_dictionary={
'hydrophobic':['ATG','GTN','GCN','ATY','ATA','CTN','TTR','TTY','TGG'],
'hydrophilic':['AGY','TCN','TAY','CAR','ACN','AAY','TGY'],
'acidic':['GAY','GAR'], 'basic':['AGR','CGN','CAY','AAR'],
'P':['CCN'], 'G':['GGN'], '-':['TGA','TAR'] }

def dna_to_aa_translation(dna_seq):         # Translates DNA sequence to amino acid seuquence
    codon_count=0               # assumes sequence is in +0 reading frame
    amino_acids=[]
    for i in range(0,(len(dna_seq)//3)):
        codon=dna_seq[i+codon_count]+dna_seq[i+codon_count+1]+dna_seq[i+codon_count+2]
        amino_acids.append(codon_translation(codon))
        codon_count+=2
    return amino_acids

def codon_usage(codon):         # Greater value indicates more efficient expression. Scores for all codons of same amino acid add up to one. Values for E. coli from GenScript
    if codon=='ATG':
        return 1.00
    if codon=='ATA':
        return 0.11
    if codon=='ATC':
        return 0.39
    if codon=='ATT':
        return 0.49
    if codon=='ACT':
        return 0.19
    if codon=='ACC':
        return 0.40
    if codon=='ACA':
        return 0.17
    if codon=='ACG':
        return 0.25
    if codon=='AAA':
        return 0.74
    if codon=='AAG':
        return 0.26
    if codon=='AAT':
        return 0.49
    if codon=='AAC':
        return 0.51
    if codon=='AGT':
        return 0.16
    if codon=='AGC':
        return 0.25
    if codon=='AGA':
        return 0.070
    if codon=='AGG':
        return 0.04
    if codon=='CTT':
        return 0.12
    if codon=='CTC':
        return 0.10
    if codon=='CTA':
        return 0.04
    if codon=='CTG':
        return 0.47
    if codon=='CCT':
        return 0.18
    if codon=='CCC':
        return 0.13
    if codon=='CCA':
        return 0.20
    if codon=='CCG':
        return 0.49
    if codon=='CAT':
        return 0.57
    if codon=='CAC':
        return 0.43
    if codon=='CAA':
        return 0.34
    if codon=='CAG':
        return 0.66
    if codon=='CGT':
        return 0.361
    if codon=='CGC':
        return 0.360
    if codon=='CGA':
        return 0.071
    if codon=='CGG':
        return 0.11
    if codon=='GTT':
        return 0.28
    if codon=='GTC':
        return 0.20
    if codon=='GTA':
        return 0.17
    if codon=='GTG':
        return 0.35
    if codon=='GCT':
        return 0.18
    if codon=='GCC':
        return 0.26
    if codon=='GCA':
        return 0.23
    if codon=='GCG':
        return 0.33
    if codon=='GAT':
        return 0.63
    if codon=='GAC':
        return 0.37
    if codon=='GAA':
        return 0.68
    if codon=='GAG':
        return 0.32
    if codon=='GGT':
        return 0.35
    if codon=='GGC':
        return 0.37
    if codon=='GGA':
        return 0.13
    if codon=='GGG':
        return 0.15
    if codon=='TTT':
        return 0.58
    if codon=='TTC':
        return 0.42
    if codon=='TTA':
        return 0.14
    if codon=='TTG':
        return 0.13
    if codon=='TCT':
        return 0.17
    if codon=='TCC':
        return 0.15
    if codon=='TCA':
        return 0.141
    if codon=='TCG':
        return 0.140
    if codon=='TAT':
        return 0.59
    if codon=='TAC':
        return 0.41
    if codon=='TGT':
        return 0.46
    if codon=='TGC':
        return 0.54
    if codon=='TGG':
        return 1.00
    if codon=='TGA':
        return 0.30
    if codon=='TAG':
        return 0.09
    if codon=='TAA':
        return 0.61
    else:
        print('One or more codons were invalid')
        raise SystemExit

def minimize_overall_mutation(aa_seq):          # Main function. Weighs all mutation hotspots and outputs DNA sequence that has minimal number of hotspots but codes for same amino acid sequence as input. If DNA sequence input, do dna_to_aa_translation first
    aa_seq=aa_seq_check(aa_seq)
    all_possible_codons=[]
    all_possible_dna_seq=[]
    aa_table=list(simplified_codon_dictionary.keys())
    codon_table=list(simplified_codon_dictionary.values())
    for aa in aa_seq:                   # creates sublist at each amino acid position that contains all possible codons that code for that amino acid
        if aa not in aa_table:
            print('The amino acid at position %d is not valid'%(aa_seq.index(aa)))
            raise SystemExit
        for i in range(0,len(aa_table)):
            if aa==aa_table[i]:
                all_possible_codons.append(codon_table[i])
                break
    seq_construction=[]
    for i in range(0,len(aa_seq)-2):
        possible_codon_windows=[]           # goes through every possible codon for given amino acid, then appends possibilty to growing list
        pos_codon1=[]
        pos_codon2=[]
        pos_codon3=[]
        for codon_option in all_possible_codons[i]:             # converts back from abreviated DNA code to standard code
            if codon_option[2]=='Y':
                pos_codon1.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon1.append([codon_option[0]+codon_option[1]+'C'])
            elif codon_option[2]=='R':
                pos_codon1.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon1.append([codon_option[0]+codon_option[1]+'G'])
            elif codon_option[2]=='N':
                pos_codon1.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon1.append([codon_option[0]+codon_option[1]+'C'])
                pos_codon1.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon1.append([codon_option[0]+codon_option[1]+'G'])
            else:
                pos_codon1.append([codon_option[0]+codon_option[1]+codon_option[2]])
        for codon_option in all_possible_codons[i+1]:
            if codon_option[2]=='Y':
                pos_codon2.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon2.append([codon_option[0]+codon_option[1]+'C'])
            elif codon_option[2]=='R':
                pos_codon2.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon2.append([codon_option[0]+codon_option[1]+'G'])
            elif codon_option[2]=='N':
                pos_codon2.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon2.append([codon_option[0]+codon_option[1]+'C'])
                pos_codon2.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon2.append([codon_option[0]+codon_option[1]+'G'])
            else:
                pos_codon2.append([codon_option[0]+codon_option[1]+codon_option[2]])
        for codon_option in all_possible_codons[i+2]:
            if codon_option[2]=='Y':
                pos_codon3.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon3.append([codon_option[0]+codon_option[1]+'C'])
            elif codon_option[2]=='R':
                pos_codon3.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon3.append([codon_option[0]+codon_option[1]+'G'])
            elif codon_option[2]=='N':
                pos_codon3.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon3.append([codon_option[0]+codon_option[1]+'C'])
                pos_codon3.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon3.append([codon_option[0]+codon_option[1]+'G'])
            elif codon_option[2] in ['A','C','G','T']:
                pos_codon3.append([codon_option[0]+codon_option[1]+codon_option[2]])
        for j1 in pos_codon1:                                       # Finds all possibilities for sequences made of sets of three codons at a time, then appends best set of codons to output sequence.
            for j2 in pos_codon2:
                for j3 in pos_codon3:
                    possible_codon_windows.append(j1+j2+j3)
        for k in range(0,len(possible_codon_windows)):
            possible_codon_windows[k]=''.join(possible_codon_windows[k])
        mutability_scores=[]
        for j in range(0,len(possible_codon_windows)):              # Calculates the number of each type of mutation hotspot in the sequence of 3 codons at a time. Sliding window scan (ie A+B+C, then B+C+D)
            TT_dimers=TT_dimer_count(possible_codon_windows[j])
            other_pyr_dimers=other_pyr_dimer_count([possible_codon_windows[j]])
            weighted_pyr_dimers=weighted_pyr_dimer_count(possible_codon_windows[j])
            methyl_sites=methylation_sites(possible_codon_windows[j])
            run_repeats=repeat_runs(possible_codon_windows[j])
            homologies=homology_repeats(possible_codon_windows[j])
            deaminated_sites=deamination_sites(possible_codon_windows[j])
            alkylated_sites=alkylation_sites(possible_codon_windows[j])
            oxidized_sites=oxidation_sites(possible_codon_windows[j])
            other_misc_sites=misc_other_sites(possible_codon_windows[j])
            hairpins=hairpin_sites(possible_codon_windows[j])
            IS_sites=insertion_sequences(possible_codon_windows[j])
            anti_sd_sites=anti_shine_delgarno_count(possible_codon_windows[j])
            blacklisted_codons=rate_limiting_codon_count(possible_codon_windows[j])
            mutability_score=float(5*weighted_pyr_dimers+7*methyl_sites+6.4*run_repeats+3.5*homologies+0.3*deaminated_sites+0.4*alkylated_sites+1.25*oxidized_sites+0.2*other_misc_sites+0.9*hairpins+4.2*IS_sites+5.8*anti_sd_sites+1000*blacklisted_codons)  # Method of ranking sequences based on arbitrary coefficients before each hotspot type.
            mutability_scores.append(mutability_score-seq_codon_usage_avg(possible_codon_windows[j]))
        optimal_index=mutability_scores.index(min(mutability_scores))           # The sequence with the lowest score based on the above formula is selected as the optimal sequence
        if i <len(aa_seq)-3:
            seq_construction.append(possible_codon_windows[optimal_index][0:3])     # adds the first codon of the sliding window to the output sequence
        elif i==len(aa_seq)-3:
            seq_construction.append(possible_codon_windows[optimal_index][0:10])    # if at end of sequence, adds all of the final sliding window of 3 codons
            break
    seq_construction=''.join(seq_construction)
    return seq_construction

def minimize_overall_mutation_conservative(aa_seq):   # currently too limited in range and turns everything into valine/tyrosine/aspartate/histidine (ie unable to see beyond range of two codons to determine that valine already repeated earlier in sequence)
    aa_seq=aa_seq_check(aa_seq)
    all_possible_codons=[]
    all_possible_dna_seq=[]
    aa_table=list(conservative_codon_dictionary.keys())
    codon_table=list(conservative_codon_dictionary.values())
    for aa in aa_seq:
        if aa in ['V','A','F','L','W','P','I','M']:
            conservative_type='hydrophobic'
        elif aa in ['S','Y','C','Q','T','N']:
            conservative_type='hydrophilic'
        elif aa in ['D','E']:
            conservative_type='acidic'
        elif aa in ['K','R','H']:
            conservative_type='basic'
        else:
            conservative_type=aa
        for i in range(0,len(aa_table)):
            if aa_table[i]==conservative_type:
                all_possible_codons.append(codon_table[i])    # USE CONSERVATIVE CODON DICTIONARY
                break
    seq_construction=['ATG']
    for i in range(1,len(aa_seq)-1):
        possible_codon_windows=[]           # goes through every possible codon for given amino acid, then appends possibilty to growing list
        pos_codon1=[]
        pos_codon2=[]
        for codon_option in all_possible_codons[i]:
            if codon_option[2]=='Y':
                pos_codon1.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon1.append([codon_option[0]+codon_option[1]+'C'])
            elif codon_option[2]=='R':
                pos_codon1.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon1.append([codon_option[0]+codon_option[1]+'G'])
            elif codon_option[2]=='N':
                pos_codon1.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon1.append([codon_option[0]+codon_option[1]+'C'])
                pos_codon1.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon1.append([codon_option[0]+codon_option[1]+'G'])
            else:
                pos_codon1.append([codon_option[0]+codon_option[1]+codon_option[2]])
        for codon_option in all_possible_codons[i+1]:
            if codon_option[2]=='Y':
                pos_codon2.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon2.append([codon_option[0]+codon_option[1]+'C'])
            elif codon_option[2]=='R':
                pos_codon2.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon2.append([codon_option[0]+codon_option[1]+'G'])
            elif codon_option[2]=='N':
                pos_codon2.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon2.append([codon_option[0]+codon_option[1]+'C'])
                pos_codon2.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon2.append([codon_option[0]+codon_option[1]+'G'])
            else:
                pos_codon2.append([codon_option[0]+codon_option[1]+codon_option[2]])
        for j1 in pos_codon1:                                       # Finds all possibilities for sequences made of sets of three codons at atime, then appends best set of codons to output sequence.
            for j2 in pos_codon2:
                possible_codon_windows.append(j1+j2)
        for k in range(0,len(possible_codon_windows)):
            possible_codon_windows[k]=''.join(possible_codon_windows[k])
        mutability_scores=[]
        for j in range(0,len(possible_codon_windows)):              # Calculates the number of each type of mutation hotspot in the sequence
            TT_dimers=TT_dimer_count(possible_codon_windows[j])
            other_pyr_dimers=other_pyr_dimer_count([possible_codon_windows[j]])
            weighted_pyr_dimers=weighted_pyr_dimer_count(possible_codon_windows[j])
            methyl_sites=methylation_sites(possible_codon_windows[j])
            run_repeats=repeat_runs(possible_codon_windows[j])
            homologies=homology_repeats(possible_codon_windows[j])
            deaminated_sites=deamination_sites(possible_codon_windows[j])
            alkylated_sites=alkylation_sites(possible_codon_windows[j])
            oxidized_sites=oxidation_sites(possible_codon_windows[j])
            other_misc_sites=misc_other_sites(possible_codon_windows[j])
            hairpins=hairpin_sites(possible_codon_windows[j])
            IS_sites=insertion_sequences(possible_codon_windows[j])
            anti_sd_sites=anti_shine_delgarno_count(possible_codon_windows[j])
            blacklisted_codons=rate_limiting_codon_count(possible_codon_windows[j])
            mutability_score=float(5*weighted_pyr_dimers+7*methyl_sites+24*run_repeats+24*homologies+0.3*deaminated_sites+0.4*alkylated_sites+1.25*oxidized_sites+0.2*other_misc_sites+0.9*hairpins+4.2*IS_sites+5.8*anti_sd_sites+1000*blacklisted_codons)  # This score is again an imperfect solution, since the coefficient weight I assigned were arbitrary. The ideal would be selecting the one with a minimum of all sites, with a hierarchy in the event two sequences differ only by the first sequence having hotspot X and the second sequence getting rid of X by creating hotspot Y in its place
            mutability_scores.append(mutability_score-seq_codon_usage_avg(possible_codon_windows[j]))
        optimal_index=mutability_scores.index(min(mutability_scores))           # The sequence with the lowest number of hostpots, weighted by those arbitrary coefficients, is selected as the optimal sequence
        if i <len(aa_seq)-2:
            seq_construction.append(possible_codon_windows[optimal_index][0:3])
        elif i==len(aa_seq)-2:
            seq_construction.append(possible_codon_windows[optimal_index][0:7])
            break
    seq_construction=''.join(seq_construction)
    return seq_construction

def minimize_pyr_dimer_mutation(aa_seq):
    aa_seq=aa_seq_check(aa_seq)
    all_possible_codons=[]
    all_possible_dna_seq=[]
    aa_table=list(simplified_codon_dictionary.keys())
    codon_table=list(simplified_codon_dictionary.values())
    for aa in aa_seq:
        if aa not in aa_table:
            print('The amino acid at position %d is not valid'%(aa_seq.index(aa)))
            raise SystemExit
        for i in range(0,len(aa_table)):
            if aa==aa_table[i]:
                all_possible_codons.append(codon_table[i])
                break
    seq_construction=[]
    for i in range(0,len(aa_seq)-2):
        possible_codon_windows=[]           # goes through every possible codon for given amino acid, then appends possibilty to growing list
        pos_codon1=[]
        pos_codon2=[]
        pos_codon3=[]
        for codon_option in all_possible_codons[i]:
            if codon_option[2]=='Y':
                pos_codon1.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon1.append([codon_option[0]+codon_option[1]+'C'])
            elif codon_option[2]=='R':
                pos_codon1.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon1.append([codon_option[0]+codon_option[1]+'G'])
            elif codon_option[2]=='N':
                pos_codon1.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon1.append([codon_option[0]+codon_option[1]+'C'])
                pos_codon1.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon1.append([codon_option[0]+codon_option[1]+'G'])
            else:
                pos_codon1.append([codon_option[0]+codon_option[1]+codon_option[2]])
        for codon_option in all_possible_codons[i+1]:
            if codon_option[2]=='Y':
                pos_codon2.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon2.append([codon_option[0]+codon_option[1]+'C'])
            elif codon_option[2]=='R':
                pos_codon2.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon2.append([codon_option[0]+codon_option[1]+'G'])
            elif codon_option[2]=='N':
                pos_codon2.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon2.append([codon_option[0]+codon_option[1]+'C'])
                pos_codon2.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon2.append([codon_option[0]+codon_option[1]+'G'])
            else:
                pos_codon2.append([codon_option[0]+codon_option[1]+codon_option[2]])
        for codon_option in all_possible_codons[i+2]:
            if codon_option[2]=='Y':
                pos_codon3.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon3.append([codon_option[0]+codon_option[1]+'C'])
            elif codon_option[2]=='R':
                pos_codon3.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon3.append([codon_option[0]+codon_option[1]+'G'])
            elif codon_option[2]=='N':
                pos_codon3.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon3.append([codon_option[0]+codon_option[1]+'C'])
                pos_codon3.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon3.append([codon_option[0]+codon_option[1]+'G'])
            elif codon_option[2] in ['A','C','G','T']:
                pos_codon3.append([codon_option[0]+codon_option[1]+codon_option[2]])
        for j1 in pos_codon1:
            for j2 in pos_codon2:
                for j3 in pos_codon3:
                    possible_codon_windows.append(j1+j2+j3)
        for k in range(0,len(possible_codon_windows)):
            possible_codon_windows[k]=''.join(possible_codon_windows[k])
        mutability_scores=[]
        for j in range(0,len(possible_codon_windows)):              # Calculates the number of each type of mutation hotspot in the sequence
            weighted_pyr_dimers=weighted_pyr_dimer_count(possible_codon_windows[j])
            blacklisted_codons=rate_limiting_codon_count(possible_codon_windows[j])
            mutability_score=float(weighted_pyr_dimers+1000*blacklisted_codons)
            mutability_scores.append(mutability_score-seq_codon_usage_avg(possible_codon_windows[j]))
        optimal_index=mutability_scores.index(min(mutability_scores))           # The sequence with the lowest number of hostpots, weighted by those arbitrary coefficients, is selected as the optimal sequence
        if i <len(aa_seq)-3:
            seq_construction.append(possible_codon_windows[optimal_index][0:3])
        elif i==len(aa_seq)-3:
            seq_construction.append(possible_codon_windows[optimal_index][0:10])
            break
    seq_construction=''.join(seq_construction)
    return seq_construction


def minimize_homology_search(dna_seq):
    dna_seq=dna_seq_check(dna_seq)
    dna_seq=''.join(dna_seq)
    for i in range(0,len(dna_seq)-4):
        truncated_seq=dna_seq[i+1:len(dna_seq)]
        repeat_index=truncated_seq.find(dna_seq[i:i+4])
        if repeat_index>0:
            '''
            find which two codons the repeat is a part of
            copy mut opt software for reverse translating two codons
            search through possibilities to see if one no longer has POSSIBILITY_N.find(dna_seq[i:i+4])
            if find possibility, replace dna_seq at location with new sequence
            '''
            repeat_index.append(i)
    print(repeat_index)

# temp_seq='ATGcaatGCCCAcaatGA'
# inimize_homology_search(temp_seq)


def maximize_mutation(aa_seq):    # does the opposite as the overall minimize function (ie chooses highest mutation score, not lowest)
    aa_seq=aa_seq_check(aa_seq)
    all_possible_codons=[]
    all_possible_dna_seq=[]
    aa_table=list(simplified_codon_dictionary.keys())
    codon_table=list(simplified_codon_dictionary.values())
    for aa in aa_seq:
        if aa not in aa_table:
            print('The amino acid at position %d is not valid'%(aa_seq.index(aa)))
            raise SystemExit
        for i in range(0,len(aa_table)):
            if aa==aa_table[i]:
                all_possible_codons.append(codon_table[i])
                break
    seq_construction=[]
    for i in range(0,len(aa_seq)-2):
        possible_codon_windows=[]           # goes through every possible codon for given amino acid, then appends possibilty to growing list
        pos_codon1=[]
        pos_codon2=[]
        pos_codon3=[]
        for codon_option in all_possible_codons[i]:
            if codon_option[2]=='Y':
                pos_codon1.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon1.append([codon_option[0]+codon_option[1]+'C'])
            elif codon_option[2]=='R':
                pos_codon1.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon1.append([codon_option[0]+codon_option[1]+'G'])
            elif codon_option[2]=='N':
                pos_codon1.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon1.append([codon_option[0]+codon_option[1]+'C'])
                pos_codon1.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon1.append([codon_option[0]+codon_option[1]+'G'])
            else:
                pos_codon1.append([codon_option[0]+codon_option[1]+codon_option[2]])
        for codon_option in all_possible_codons[i+1]:
            if codon_option[2]=='Y':
                pos_codon2.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon2.append([codon_option[0]+codon_option[1]+'C'])
            elif codon_option[2]=='R':
                pos_codon2.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon2.append([codon_option[0]+codon_option[1]+'G'])
            elif codon_option[2]=='N':
                pos_codon2.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon2.append([codon_option[0]+codon_option[1]+'C'])
                pos_codon2.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon2.append([codon_option[0]+codon_option[1]+'G'])
            else:
                pos_codon2.append([codon_option[0]+codon_option[1]+codon_option[2]])
        for codon_option in all_possible_codons[i+2]:
            if codon_option[2]=='Y':
                pos_codon3.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon3.append([codon_option[0]+codon_option[1]+'C'])
            elif codon_option[2]=='R':
                pos_codon3.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon3.append([codon_option[0]+codon_option[1]+'G'])
            elif codon_option[2]=='N':
                pos_codon3.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon3.append([codon_option[0]+codon_option[1]+'C'])
                pos_codon3.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon3.append([codon_option[0]+codon_option[1]+'G'])
            elif codon_option[2] in ['A','C','G','T']:
                pos_codon3.append([codon_option[0]+codon_option[1]+codon_option[2]])
        for j1 in pos_codon1:
            for j2 in pos_codon2:
                for j3 in pos_codon3:
                    possible_codon_windows.append(j1+j2+j3)
        for k in range(0,len(possible_codon_windows)):
            possible_codon_windows[k]=''.join(possible_codon_windows[k])
        mutability_scores=[]
        for j in range(0,len(possible_codon_windows)):              # Calculates the number of each type of mutation hotspot in the sequence
            TT_dimers=TT_dimer_count(possible_codon_windows[j])
            other_pyr_dimers=other_pyr_dimer_count([possible_codon_windows[j]])
            weighted_pyr_dimers=weighted_pyr_dimer_count(possible_codon_windows[j])
            methyl_sites=methylation_sites(possible_codon_windows[j])
            run_repeats=repeat_runs(possible_codon_windows[j])
            homologies=homology_repeats(possible_codon_windows[j])
            deaminated_sites=deamination_sites(possible_codon_windows[j])
            alkylated_sites=alkylation_sites(possible_codon_windows[j])
            oxidized_sites=oxidation_sites(possible_codon_windows[j])
            other_misc_sites=misc_other_sites(possible_codon_windows[j])
            hairpins=hairpin_sites(possible_codon_windows[j])
            IS_sites=insertion_sequences(possible_codon_windows[j])
            anti_sd_sites=anti_shine_delgarno_count(possible_codon_windows[j])
            blacklisted_codons=rate_limiting_codon_count(possible_codon_windows[j])
            mutability_score=float(15*weighted_pyr_dimers+3*methyl_sites+3.4*run_repeats+1.5*homologies+0.3*deaminated_sites+0.4*alkylated_sites+0.35*oxidized_sites+0.2*other_misc_sites+0.9*hairpins+4.2*IS_sites+5.9*anti_sd_sites-1000*blacklisted_codons)  # This score is again an imperfect solution, since the coefficient weight I assigned were arbitrary. The ideal would be selecting the one with a minimum of all sites, with a hierarchy in the event two sequences differ only by the first sequence having hotspot X and the second sequence getting rid of X by creating hotspot Y in its place
            mutability_scores.append(mutability_score-seq_codon_usage_avg(possible_codon_windows[j]))
        optimal_index=mutability_scores.index(max(mutability_scores))           # The sequence with the lowest number of hostpots, weighted by those arbitrary coefficients, is selected as the optimal sequence
        if i <len(aa_seq)-3:
            seq_construction.append(possible_codon_windows[optimal_index][0:3])
        elif i==len(aa_seq)-3:
            seq_construction.append(possible_codon_windows[optimal_index][0:10])
    seq_construction=''.join(seq_construction)
    return seq_construction

def maximize_pyr_dimer_mutation(aa_seq):
    aa_seq=aa_seq_check(aa_seq)
    all_possible_codons=[]
    all_possible_dna_seq=[]
    aa_table=list(simplified_codon_dictionary.keys())
    codon_table=list(simplified_codon_dictionary.values())
    for aa in aa_seq:
        if aa not in aa_table:
            print('The amino acid at position %d is not valid'%(aa_seq.index(aa)))
            raise SystemExit
        for i in range(0,len(aa_table)):
            if aa==aa_table[i]:
                all_possible_codons.append(codon_table[i])
                break
    seq_construction=[]
    for i in range(0,len(aa_seq)-2):
        possible_codon_windows=[]           # goes through every possible codon for given amino acid, then appends possibilty to growing list
        pos_codon1=[]
        pos_codon2=[]
        pos_codon3=[]
        for codon_option in all_possible_codons[i]:
            if codon_option[2]=='Y':
                pos_codon1.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon1.append([codon_option[0]+codon_option[1]+'C'])
            elif codon_option[2]=='R':
                pos_codon1.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon1.append([codon_option[0]+codon_option[1]+'G'])
            elif codon_option[2]=='N':
                pos_codon1.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon1.append([codon_option[0]+codon_option[1]+'C'])
                pos_codon1.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon1.append([codon_option[0]+codon_option[1]+'G'])
            else:
                pos_codon1.append([codon_option[0]+codon_option[1]+codon_option[2]])
        for codon_option in all_possible_codons[i+1]:
            if codon_option[2]=='Y':
                pos_codon2.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon2.append([codon_option[0]+codon_option[1]+'C'])
            elif codon_option[2]=='R':
                pos_codon2.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon2.append([codon_option[0]+codon_option[1]+'G'])
            elif codon_option[2]=='N':
                pos_codon2.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon2.append([codon_option[0]+codon_option[1]+'C'])
                pos_codon2.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon2.append([codon_option[0]+codon_option[1]+'G'])
            else:
                pos_codon2.append([codon_option[0]+codon_option[1]+codon_option[2]])
        for codon_option in all_possible_codons[i+2]:
            if codon_option[2]=='Y':
                pos_codon3.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon3.append([codon_option[0]+codon_option[1]+'C'])
            elif codon_option[2]=='R':
                pos_codon3.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon3.append([codon_option[0]+codon_option[1]+'G'])
            elif codon_option[2]=='N':
                pos_codon3.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon3.append([codon_option[0]+codon_option[1]+'C'])
                pos_codon3.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon3.append([codon_option[0]+codon_option[1]+'G'])
            elif codon_option[2] in ['A','C','G','T']:
                pos_codon3.append([codon_option[0]+codon_option[1]+codon_option[2]])
        for j1 in pos_codon1:
            for j2 in pos_codon2:
                for j3 in pos_codon3:
                    possible_codon_windows.append(j1+j2+j3)
        for k in range(0,len(possible_codon_windows)):
            possible_codon_windows[k]=''.join(possible_codon_windows[k])
        mutability_scores=[]
        for j in range(0,len(possible_codon_windows)):              # Calculates the number of each type of mutation hotspot in the sequence
            weighted_pyr_dimers=weighted_pyr_dimer_count(possible_codon_windows[j])
            blacklisted_codons=rate_limiting_codon_count(possible_codon_windows[j])
            mutability_score=float(weighted_pyr_dimers-1000*blacklisted_codons)  # This score is again an imperfect solution, since the coefficient weight I assigned were arbitrary. The ideal would be selecting the one with a minimum of all sites, with a hierarchy in the event two sequences differ only by the first sequence having hotspot X and the second sequence getting rid of X by creating hotspot Y in its place
            mutability_scores.append(mutability_score-seq_codon_usage_avg(possible_codon_windows[j]))
        optimal_index=mutability_scores.index(max(mutability_scores))           # The sequence with the lowest number of hostpots, weighted by those arbitrary coefficients, is selected as the optimal sequence
        if i <len(aa_seq)-3:
            seq_construction.append(possible_codon_windows[optimal_index][0:3])
        elif i==len(aa_seq)-3:
            seq_construction.append(possible_codon_windows[optimal_index][0:10])
    seq_construction=''.join(seq_construction)
    return seq_construction

def maximize_oxidative_mutation(aa_seq):
    aa_seq=aa_seq_check(aa_seq)
    all_possible_codons=[]
    all_possible_dna_seq=[]
    aa_table=list(simplified_codon_dictionary.keys())
    codon_table=list(simplified_codon_dictionary.values())
    for aa in aa_seq:
        if aa not in aa_table:
            print('The amino acid at position %d is not valid'%(aa_seq.index(aa)))
            raise SystemExit
        for i in range(0,len(aa_table)):
            if aa==aa_table[i]:
                all_possible_codons.append(codon_table[i])
                break
    seq_construction=[]
    for i in range(0,len(aa_seq)-2):
        possible_codon_windows=[]           # goes through every possible codon for given amino acid, then appends possibilty to growing list
        pos_codon1=[]
        pos_codon2=[]
        pos_codon3=[]
        for codon_option in all_possible_codons[i]:
            if codon_option[2]=='Y':
                pos_codon1.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon1.append([codon_option[0]+codon_option[1]+'C'])
            elif codon_option[2]=='R':
                pos_codon1.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon1.append([codon_option[0]+codon_option[1]+'G'])
            elif codon_option[2]=='N':
                pos_codon1.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon1.append([codon_option[0]+codon_option[1]+'C'])
                pos_codon1.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon1.append([codon_option[0]+codon_option[1]+'G'])
            else:
                pos_codon1.append([codon_option[0]+codon_option[1]+codon_option[2]])
        for codon_option in all_possible_codons[i+1]:
            if codon_option[2]=='Y':
                pos_codon2.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon2.append([codon_option[0]+codon_option[1]+'C'])
            elif codon_option[2]=='R':
                pos_codon2.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon2.append([codon_option[0]+codon_option[1]+'G'])
            elif codon_option[2]=='N':
                pos_codon2.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon2.append([codon_option[0]+codon_option[1]+'C'])
                pos_codon2.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon2.append([codon_option[0]+codon_option[1]+'G'])
            else:
                pos_codon2.append([codon_option[0]+codon_option[1]+codon_option[2]])
        for codon_option in all_possible_codons[i+2]:
            if codon_option[2]=='Y':
                pos_codon3.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon3.append([codon_option[0]+codon_option[1]+'C'])
            elif codon_option[2]=='R':
                pos_codon3.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon3.append([codon_option[0]+codon_option[1]+'G'])
            elif codon_option[2]=='N':
                pos_codon3.append([codon_option[0]+codon_option[1]+'A'])
                pos_codon3.append([codon_option[0]+codon_option[1]+'C'])
                pos_codon3.append([codon_option[0]+codon_option[1]+'T'])
                pos_codon3.append([codon_option[0]+codon_option[1]+'G'])
            elif codon_option[2] in ['A','C','G','T']:
                pos_codon3.append([codon_option[0]+codon_option[1]+codon_option[2]])
        for j1 in pos_codon1:
            for j2 in pos_codon2:
                for j3 in pos_codon3:
                    possible_codon_windows.append(j1+j2+j3)
        for k in range(0,len(possible_codon_windows)):
            possible_codon_windows[k]=''.join(possible_codon_windows[k])
        mutability_scores=[]
        for j in range(0,len(possible_codon_windows)):              # Calculates the number of each type of mutation hotspot in the sequence
            oxidized_sites=oxidation_sites(possible_codon_windows[j])
            blacklisted_codons=rate_limiting_codon_count(possible_codon_windows[j])
            mutability_score=float(oxidized_sites-1000*blacklisted_codons)  # This score is again an imperfect solution, since the coefficient weight I assigned were arbitrary. The ideal would be selecting the one with a minimum of all sites, with a hierarchy in the event two sequences differ only by the first sequence having hotspot X and the second sequence getting rid of X by creating hotspot Y in its place
            mutability_scores.append(mutability_score-seq_codon_usage_avg(possible_codon_windows[j]))
        optimal_index=mutability_scores.index(max(mutability_scores))           # The sequence with the lowest number of hostpots, weighted by those arbitrary coefficients, is selected as the optimal sequence
        if i <len(aa_seq)-3:
            seq_construction.append(possible_codon_windows[optimal_index][0:3])
        elif i==len(aa_seq)-3:
            seq_construction.append(possible_codon_windows[optimal_index][0:10])
    seq_construction=''.join(seq_construction)
    return seq_construction

def seq_codon_usage_avg(dna_seq):           # analogous to CAI calculations of codon usage frequency
    dna_seq=list(dna_seq)
    dna_seq=''.join(dna_seq)
    codon_count=0
    codon_usage_sum=0
    for i in range(0,len(dna_seq)//3):
        codon=dna_seq[i+codon_count]+dna_seq[i+codon_count+1]+dna_seq[i+codon_count+2]
        codon_usage_sum+=codon_usage(codon)
        codon_count+=2
    codon_usage_avg=codon_usage_sum/len(dna_seq)
    return codon_usage_avg

def rate_limiting_codon_count(dna_seq):         # set of codons in E coli that are of very low tRNA abundance and can stall translation
    dna_seq=list(dna_seq)
    dna_seq=''.join(dna_seq)
    codon_count=0
    blacklist_codon_count=0
    for i in range(0,len(dna_seq)//3):
        codon=dna_seq[i+codon_count]+dna_seq[i+codon_count+1]+dna_seq[i+codon_count+2]
        if codon=='CTA' or codon=='TAG' or codon=='CGA' or codon=='AGA' or codon=='AGG':
            blacklist_codon_count+=1
        codon_count+=2
    return blacklist_codon_count

def anti_shine_delgarno_count(dna_seq):     # doi:10.1038/nature10965  a site in the DNA which will bind ribosomes outside of an initiation frame, inhibiting expression
    anti_SD_count=dna_seq.count('AGG')+dna_seq.count('GGA')+dna_seq.count('GAG')+dna_seq.count('GGG')+dna_seq.count('GGT')+dna_seq.count('GTG')
    return anti_SD_count

def TT_dimer_count(dna_seq):
    TT_dimers=0
    for i in range(0,len(dna_seq)-1):
        if dna_seq[i]+dna_seq[i+1]=='TT' or dna_seq[i]+dna_seq[i+1]=='AA':
            TT_dimers+=1
    return TT_dimers

def other_pyr_dimer_count(dna_seq):
    other_dimers=0
    for i in range(0,len(dna_seq)-1):
        if dna_seq[i]+dna_seq[i+1] in ['CT','TC','CC','CY','TY','YC','YT','YY','GA','AG','GG','AR','RA','GR','RG','RR']:
            other_dimers+=1
    return other_dimers

def weighted_pyr_dimer_count(dna_seq):   # weight values from DOI: 10.1039/c3pp25451h. This is the funciton used in the main minimization equation
    weighted_dimer_avg_tot=0
    for i in range(0,len(dna_seq)-1):
        if dna_seq[i]+dna_seq[i+1] in ['TT','AA']:
            weighted_dimer_avg_tot+=(0.548+0.033)
        if dna_seq[i]+dna_seq[i+1] in ['TC','GA']:
            weighted_dimer_avg_tot+=(0.300+0.286)
        if dna_seq[i]+dna_seq[i+1] in ['CT','AG']:
            weighted_dimer_avg_tot+=(0.103+0.001)
        if dna_seq[i]+dna_seq[i+1] in['CC','GG']:
            weighted_dimer_avg_tot+=(0.0031+0.008)
    return(weighted_dimer_avg_tot)

def methylation_sites(dna_seq):         # E. coli methylation sites only
    Dam_sites=dna_seq.count('GATC')+dna_seq.count('CTAG')
    Dcm_sites=dna_seq.count('CCAGG')+dna_seq.count('CCTGG')+dna_seq.count('GGTCC')+dna_seq.count('GGACC')
    return Dam_sites+Dcm_sites

def repeat_runs(dna_seq):           # same base repeated four times or more in a row
    run_repeats=0
    for i in range(0,len(dna_seq)-3):
        if dna_seq[i]==dna_seq[i+1]==dna_seq[i+2]==dna_seq[i+3]:
            run_repeats+=1
    return run_repeats

def homology_repeats(dna_seq):      # sequence of 6 bases that shows up more than once in sequence
    homologies=0
    for i in range(0,len(dna_seq)-5):
        seq_window=dna_seq[i]+dna_seq[i+1]+dna_seq[i+2]+dna_seq[i+3]+dna_seq[i+4]+dna_seq[i+5]
        if not any(base in seq_window for base in ('R', 'Y', 'N')):
            if dna_seq.count(seq_window)>=2:
                homologies+=1
    return homologies

def deamination_sites(dna_seq):
    return dna_seq.count('CG')+dna_seq.count('GC')

def alkylation_sites(dna_seq):
    return dna_seq.count('RG')+dna_seq.count('GG')+dna_seq.count('AG')+dna_seq.count('TC')

def oxidation_sites(dna_seq):
    return dna_seq.count('GGG')+dna_seq.count('GG')+dna_seq.count('CCC')+dna_seq.count('CC')

def misc_other_sites(dna_seq):
    return dna_seq.count('YTG')+dna_seq.count('TTG')+dna_seq.count('CTG')+dna_seq.count('GTGG')+dna_seq.count('GGCGCC')

def hairpin_sites(dna_seq):             # can form secondary structure in mRNA
    return dna_seq.count('CCTCCGG')+dna_seq.count('CCNNNGG')+dna_seq.count('CGNNNCG')+dna_seq.count('GCNNNGC')+dna_seq.count('GGNNNCC')

def insertion_sequences(dna_seq):   # E. coli only
    ISEc17=dna_seq.count('TGCGGACGATCATCAGTTAT')
    IS903B=dna_seq.count('GATCGTTGGGAACCG')
    IS50R=dna_seq.count('GCAGTCAGGCACCGT')+dna_seq.count('TAAGCTTTAATGCGC')+dna_seq.count('GCAGTCAGGCACCGT')+dna_seq.count('GCCGCCCAGTCCTGC')+dna_seq.count('GTCTGACGC')
    IS3411=dna_seq.count('CAGGAAAGA')
    IS30=dna_seq.count('AGTGCCATCTCCTT')+dna_seq.count('TTACCTGGTGC')
    IS1A=dna_seq.count('TTGTGTTTTTCAT')
    return ISEc17+IS903B+IS50R+IS3411+IS30+IS1A

def find_seq_changes(original_seq,optimized_seq,target):        # Compares input and output sequences, and highlights which bases were changed to remove hotspots
    target=str(target)
    indices_original=[i for i in range(len(original_seq)) if original_seq.startswith(target, i)]
    indices_optimized=[i for i in range(len(optimized_seq)) if optimized_seq.startswith(target, i)]
    change_indices=[]
    if len(indices_original)>=len(indices_optimized):
        opt_set=set(indices_optimized)
        change_indices=[x for x in indices_original if x not in opt_set]
        '''                                          # for maximizing mutation. Need to change software so does not mistakenly think site eliminated if optimal seq added some hotspot
    elif len(indices_original)<len(indices_optimized):
        orig_set=set(indices_original)
        change_indices=[x for x in indices_optimized if x not in orig_set]
        '''
    return(change_indices)

def seq_change_summary(original_seq,optimized_seq):     # determines which base pair change between original and optimal sequence correspond to removal of mutation hotspots
    original_seq=str(original_seq)
    optimized_seq=str(optimized_seq)
    if len(original_seq)!=len(optimized_seq):
        print('Sequences entered are not of equal length')
        raise SystemExit
    seq_differences=[]              # gives indices of first base pair in change
    pyr_dimer_changes=find_seq_changes(original_seq,optimized_seq,'TT')
    pyr_dimer_changes.extend(find_seq_changes(original_seq,optimized_seq,'AA'))
    pyr_dimer_changes.extend(find_seq_changes(original_seq,optimized_seq,'CT'))
    pyr_dimer_changes.extend(find_seq_changes(original_seq,optimized_seq,'AG'))
    pyr_dimer_changes.extend(find_seq_changes(original_seq,optimized_seq,'TC'))
    pyr_dimer_changes.extend(find_seq_changes(original_seq,optimized_seq,'GA'))
    pyr_dimer_changes.extend(find_seq_changes(original_seq,optimized_seq,'CC'))
    pyr_dimer_changes.extend(find_seq_changes(original_seq,optimized_seq,'GG'))
    pyr_dimer_changes=set(pyr_dimer_changes)        # creates list (without duplicates) of all the indices on the original sequence where a pyr dimer was eliminated
    print('A pyrimidine dimer was eliminated at positions:',pyr_dimer_changes)  # actual dimer spans index and index+1
    ox_site_changes_tri=find_seq_changes(original_seq,optimized_seq,'GGG')
    ox_site_changes_tri.extend(find_seq_changes(original_seq,optimized_seq,'CCC'))
    ox_site_changes_dub=find_seq_changes(original_seq,optimized_seq,'GG')
    ox_site_changes_dub.extend(find_seq_changes(original_seq,optimized_seq,'CC'))
    ox_site_changes_tri=set(ox_site_changes_tri)
    ox_site_changes_dub=set(ox_site_changes_dub)
    print('An oxidation site was eliminated at positions:',ox_site_changes_dub)  # actual site spans index and index+1
    print('An oxidation site was eliminated at positions:',ox_site_changes_tri)  # actual site spans index, index+1, and index+2)
    '''
    additional hotspot functions to be added later
    '''

# File functions to take ApE file, optomize its sequence, then output another ApE file with the new sequence. Right now, any annotated features in the ApE file are lost in the process.
import os
def read_ApE(filename):
    if not os.path.exists(filename):
        print('The file entered could not be found')
        raise SystemExit
    filehandle=open(filename,'r')
    sequence=[]
    start_seq=False
    for line in filehandle:
        if start_seq==True:
            for i in line:
                if i in ['a','t','g','c','u','n','A','T','G','C','U','N']:
                    sequence.append(i)
        if 'ORIGIN' in line:
            start_seq=True
    filehandle.close()
    return sequence

def write_ApE(filename,sequence):
    if os.path.exists(filename):
        print('The file name already exists')
        raise SystemExit
    filehandle=open(filename,'w')
    for i in sequence:
        filehandle.write(i)
    filehandle.close()


# Command line testing script that shows the output for when GFP is optomized
'''
print('Enter amino acid sequence in one-letter FAFSTA format: ')     # in actual version would be input('Enter amino acid sequence in one-letter FAFSTA format: ')
aa_seq='MSKGEELFTGVVPILVELDGDVNGHKFSVSGEGEGDATYGKLTLKFICTTGKLPVPWPTLVTTFSYGVQCFSRYPDHMKQHDFFKSAMPEGYVQERTIFFKDDGNYKTRAEVKFEGDTLVNRIELKGIDFKEDGNILGHKLEYNYNSHNVYIMADKQKNGIKVNFKIRHNIEDGSVQLADHYQQNTPIGDGPVLLPDNHYLSTQSALSKDPNEKRDHMVLLEFVTAAGITHGMDELYK-'
print('Input amino acid sequence: ')
for i in range(0,len(aa_seq)//60):
    print(aa_seq[i*60:i*60+60])
if len(aa_seq)%60!=0:
    print(aa_seq[60*(len(aa_seq)//60):len(aa_seq)+1])
optomized=minimize_mutation(aa_seq)
print('Optomized DNA sequence: ')
for i in range(0,len(optomized)//60):
    print(optomized[i*60:i*60+60])
if len(optomized)%60!=0:
    print(optomized[60*(len(optomized)//60):len(optomized)+1])
print('Average codon frequency for usage optomization: %.2f'%(seq_codon_usage_avg(optomized)))
print('Number of TT-dimers: %d'%(TT_dimer_count(optomized)))
print('Number of other pyrimidine dimers: %d'%(other_pyr_dimer_count(optomized)))
print('Number of methylation sites: %d'%(methylation_sites(optomized)))
print('Number of runs with more than four repeats: %d'%(repeat_runs(optomized)))
print('Number of homologies greater than six bases: %d'%(homology_repeats(optomized)))
print('Number of oxidation, alkylation, and deamination prone sites: %d'%(oxidation_sites(optomized)+alkylation_sites(optomized)+deamination_sites(optomized)+misc_other_sites(optomized)))
print('Number Insertion Sequences or potential hairpins: %d'%(hairpin_sites(optomized)+insertion_sequences(optomized)))
input('Press ENTER to exit.')
'''
'''
seq_E1010='ATGGCTTCCTCCGAAGACGTTATCAAAGAGTTCATGCGTTTCAAAGTTCGTATGGAAGGTTCCGTTAACGGTCACGAGTTCGAAATCGAAGGTGAAGGTGAAGGTCGTCCGTACGAAGGTACCCAGACCGCTAAACTGAAAGTTACCAAAGGTGGTCCGCTGCCGTTCGCTTGGGACATCCTGTCCCCGCAGTTCCAGTACGGTTCCAAAGCTTACGTTAAACACCCGGCTGACATCCCGGACTACCTGAAACTGTCCTTCCCGGAAGGTTTCAAATGGGAACGTGTTATGAACTTCGAAGACGGTGGTGTTGTTACCGTTACCCAGGACTCCTCCCTGCAAGACGGTGAGTTCATCTACAAAGTTAAACTGCGTGGTACCAACTTCCCGTCCGACGGTCCGGTTATGCAGAAAAAAACCATGGGTTGGGAAGCTTCCACCGAACGTATGTACCCGGAAGACGGTGCTCTGAAAGGTGAAATCAAAATGCGTCTGAAACTGAAAGACGGTGGTCACTACGACGCTGAAGTTAAAACCACCTACATGGCTAAAAAACCGGTTCAGCTGCCGGGTGCTTACAAAACCGACATCAAACTGGACATCACCTCCCACAACGAAGACTACACCATCGTTGAACAGTACGAACGTGCTGAAGGTCGTCACTCCACCGGTGCTTAA'
seq_codingTT='ATGGCGTCCTCCGAAGACGTGATCAAAGAGTTCATGCGCTTCAAAGTGCGTATGGAAGGCTCCGTGAACGGTCACGAGTTCGAAATCGAAGGTGAAGGTGAAGGTCGTCCGTACGAAGGTACCCAGACCGCTAAACTGAAAGTGACCAAAGGTGGTCCGCTGCCGTTCGCGTGGGACATCCTGTCCCCGCAGTTCCAGTACGGCTCCAAAGCGTACGTGAAACACCCGGCTGACATCCCGGACTACCTGAAACTGTCCTTCCCGGAAGGCTTCAAATGGGAACGTGTGATGAACTTCGAAGACGGTGGTGTGGTGACCGTGACCCAGGACTCCTCCCTGCAAGACGGTGAGTTCATCTACAAAGTGAAACTGCGTGGTACCAACTTCCCGTCCGACGGTCCGGTGATGCAGAAAAAAACCATGGGCTGGGAAGCGTCCACCGAACGTATGTACCCGGAAGACGGTGCTCTGAAAGGTGAAATCAAAATGCGTCTGAAACTGAAAGACGGTGGTCACTACGACGCTGAAGTGAAAACCACCTACATGGCTAAAAAACCGGTGCAGCTGCCGGGTGCGTACAAAACCGACATCAAACTGGACATCACCTCCCACAACGAAGACTACACCATCGTGGAACAGTACGAACGTGCTGAAGGTCGTCACTCCACCGGTGCGTAA'
seq_bothTT='ATGGCGAGCAGCGAGGATGTGATCAAGGAGTTCATGCGCTTCAAGGTGCGTATGGAGGGCAGCGTGAACGGCCATGAGTTCGAGATCGAGGGCGAGGGCGAGGGCCGTCCGTATGAGGGCACCCAGACCGCGAAGCTGAAGGTGACCAAGGGCGGCCCGCTGCCGTTCGCGTGGGATATCCTGAGCCCGCAGTTCCAGTATGGCAGCAAGGCGTATGTGAAGCATCCGGCGGATATCCCGGACTATCTGAAGCTGAGCTTCCCGGAGGGCTTCAAGTGGGAGCGTGTGATGAACTTCGAGGATGGCGGCGTGGTGACCGTGACCCAGGATAGCAGCCTGCAGGATGGCGAGTTCATCTATAAGGTGAAGCTGCGTGGCACCAACTTCCCGAGCGATGGCCCGGTGATGCAGAAGAAGACCATGGGCTGGGAGGCGAGCACCGAGCGTATGTATCCGGAGGATGGCGCGCTGAAGGGCGAGATCAAGATGCGTCTGAAGCTGAAGGATGGCGGCCACTATGATGCGGAGGTGAAGACCACCTATATGGCGAAGAAGCCGGTGCAGCTGCCGGGCGCGTATAAGACCGATATCAAGCTGGATATCACCAGCCATAACGAGGACTATACCATCGTGGAGCAGTATGAGCGTGCGGAGGGCCGTCATAGCACCGGCGCGTGA'
seq_weight_pyr='ATGGCCAGCAGCGAGGATGTGATTAAGGAATTTATGCGGTTTAAGGTGCGTATGGAGGGCAGCGTGAACGGCCATGAATTTGAGATTGAGGGCGAGGGCGAGGGCCGCCCGTATGAGGGCACGCAGACCGCCAAACTGAAGGTGACCAAGGGCGGCCCGCTGCCGTTTGCGTGGGATATACTGAGCCCGCAGTTCCAGTATGGCAGCAAGGCGTATGTGAAACACCCGGCGGATATACCGGACTACCTGAAACTGTCATTCCCGGAGGGGTTTAAATGGGAACGTGTGATGAACTTTGAGGATGGCGGCGTGGTGACCGTGACGCAGGATAGCAGCCTGCAGGATGGCGAATTTATATATAAGGTGAAACTGCGTGGCACCAACTTCCCGAGCGATGGCCCGGTGATGCAGAAGAAGACCATGGGGTGGGAGGCCAGCACCGAACGTATGTACCCGGAGGATGGCGCGCTGAAGGGCGAGATTAAGATGCGCCTGAAACTGAAGGATGGCGGCCACTATGATGCGGAGGTGAAGACCACGTATATGGCCAAGAAACCGGTGCAGCTGCCGGGCGCGTATAAGACCGATATTAAACTGGATATTACCAGCCATAACGAGGACTATACCATTGTGGAACAGTATGAACGTGCGGAGGGCCGCCATAGCACCGGCGCGTGA'

E1010_tot_dimer=TT_dimer_count(seq_E1010)+other_pyr_dimer_count(seq_E1010)
old_RFPyy_tot_dimer=TT_dimer_count(seq_codingTT)+other_pyr_dimer_count(seq_codingTT)
new_RFPyy_tot_dimer=TT_dimer_count(seq_weight_pyr)+other_pyr_dimer_count(seq_weight_pyr)
print('There are %d total dimers in the original E1010 sequence'%(E1010_tot_dimer))
print('There are %d total dimers in the old RFPyy sequence (a %d percent reduction from control)'%(old_RFPyy_tot_dimer,(100*(1-(old_RFPyy_tot_dimer/E1010_tot_dimer)))))
print('There are %d total dimers in the new RFPyy sequence (a %d percent reduction from control)'%(new_RFPyy_tot_dimer,(100*(1-(new_RFPyy_tot_dimer/E1010_tot_dimer)))))
'''


# For calculating pyr dimer optomization percent
'''
WT_dna_seq='atggcagcacctagaatatcattttcgccctctgatattctatttggtgttctcgatcgcttgttcaaagataacgctaccgggaaggttcttgcttcccgggtagctgtcgtaattcttttgtttataatggcgattgtttggtataggggagatagtttctttgagtactataagcaatcaaagtatgaaacatacagtgaaattattgaaaaggaaagaactgcacgctttgaatctgtcgccctggaacaactccagatagttcatatatcatctgaggcagactttagtgcggtgtattctttccgccctaaaaacttaaactattttgttgatattatagcatacgaaggaaaattaccttcaacaataagtgaaaaatcacttggaggatatcctgttgataaaactatggatgaatatacagttcatttaaatggacgtcattattattccaactcaaaatttgcttttttaccaactaaaaagcctactcccgaaataaactacatgtacagttgtccatattttaatttggataatatctatgctggaacgataaccatgtactggtatagaaatgatcatataagtaatgaccgccttgaatcaatatgtgctcaggcggccagaatattaggaagggctaaataa'
WT_dna_seq=dna_seq_check(WT_dna_seq)
amino_seq=dna_to_aa_translation(WT_dna_seq)
max_dna_seq=maximize_mutation(amino_seq)
min_dna_seq=minimize_pyr_dimer_mutation(amino_seq)
orig_tot_dimer=TT_dimer_count(WT_dna_seq)+other_pyr_dimer_count(WT_dna_seq)
min_tot_dimer=TT_dimer_count(min_dna_seq)+other_pyr_dimer_count(min_dna_seq)
max_tot_dimer=TT_dimer_count(max_dna_seq)+other_pyr_dimer_count(max_dna_seq)
print('There are %d total dimers in the original sequence'%(orig_tot_dimer))
print('There are %d total dimers in the maximized sequence (a %d percent reduction from control)'%(min_tot_dimer,(100*(1-(min_tot_dimer/orig_tot_dimer)))))
print('There are %d total dimers in the minimized sequence (a %d percent increase from control)'%(max_tot_dimer,(100*((max_tot_dimer/orig_tot_dimer)-1))))
print(max_dna_seq)
'''
# E1010_seq='ATGGCTTCCTCCGAAGACGTTATCAAAGAGTTCATGCGTTTCAAAGTTCGTATGGAAGGTTCCGTTAACGGTCACGAGTTCGAAATCGAAGGTGAAGGTGAAGGTCGTCCGTACGAAGGTACCCAGACCGCTAAACTGAAAGTTACCAAAGGTGGTCCGCTGCCGTTCGCTTGGGACATCCTGTCCCCGCAGTTCCAGTACGGTTCCAAAGCTTACGTTAAACACCCGGCTGACATCCCGGACTACCTGAAACTGTCCTTCCCGGAAGGTTTCAAATGGGAACGTGTTATGAACTTCGAAGACGGTGGTGTTGTTACCGTTACCCAGGACTCCTCCCTGCAAGACGGTGAGTTCATCTACAAAGTTAAACTGCGTGGTACCAACTTCCCGTCCGACGGTCCGGTTATGCAGAAAAAAACCATGGGTTGGGAAGCTTCCACCGAACGTATGTACCCGGAAGACGGTGCTCTGAAAGGTGAAATCAAAATGCGTCTGAAACTGAAAGACGGTGGTCACTACGACGCTGAAGTTAAAACCACCTACATGGCTAAAAAACCGGTTCAGCTGCCGGGTGCTTACAAAACCGACATCAAACTGGACATCACCTCCCACAACGAAGACTACACCATCGTTGAACAGTACGAACGTGCTGAAGGTCGTCACTCCACCGGTGCTTAA'

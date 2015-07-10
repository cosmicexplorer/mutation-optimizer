#CONSIDER CHANGING CODON OPTOMIZATION TO 'BLACKLIST' OF LIMITING tRNA
#CHECK BIOBRICK COMPATIBILITY

def aa_seq_check(aa_seq):               #Verifies valid user input for amino acid sequence, using one-letter abbreviations
    aa_seq=''.join(aa_seq)
    aa_seq=aa_seq.upper()
    aa_seq=list(aa_seq)
    for i in range(0,len(aa_seq)):
        if aa_seq[i] in ['*','X','-']:      #Possible ways to represent stop codons in amino acid sequence
            aa_seq[i]='-'
        if aa_seq[i] not in ['W','L','P','H','Q','R','I','M','T','N','K','S','V','A','D','E','G','F','Y','C','-']:
            print('The sequence entered contained symbols not included in the 1-letter IUPAC standard')
            raise SystemExit
    if aa_seq[len(aa_seq)-1]!='-':
        aa_seq.append('-')
    if aa_seq[0]!='M':              #Certain amino acid sequences omit the M start codon
        aa_sq=['M']
        for aa in aa_seq:
            aa_sq.append(aa)
        aa_seq=aa_sq
    return aa_seq

def dna_seq_check(dna_seq):         #Verifies valid user input for DNA sequence. All functions assume a simple ORF, beginning with start codon and ending with stop
    dna_seq=''.join(dna_seq)
    dna_seq=dna_seq.upper()
    dna_seq=list(dna_seq)
    for i in range(0,len(dna_seq)):
        if dna_seq[i]=='U':                 #Convert RNA to DNA
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
    dna_string=''.join(dna_seq)                     #ORF can only have one in-frame stop codon, located at the last position
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

def codon_translation(codon):       #Can replace later with codon dictionary bellow
    if codon=='ATG':            #assigns each codon to one-letter amino acid
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
                            #for references purposes right now, but this could be used to replace the above codon_translation function
full_codon_dictionary={
'M':['ATG'],'I':['ATA','ATC','ATT'],'T':['ACT','ACC','ACA','ACG'],
'K':['AAA','AAG'],'N':['AAT','AAC'],'S':['AGT','AGC','TCT','TCC','TCA','TCG'],
'R':['AGA','AGG','CGT','CGC','CGA','CGG'],'L':['CTT','CTC','CTA','CTG','TTA','TTG'],
'P':['CCT','CCC','CCA','CCG'],'H':['CAT','CAC'],'Q':['CAA','CAG'],
'V':['GTT','GTC','GTA','GTG'],'A':['GCT','GCC','GCA','GCG'],'D':['GAT','GAC'],
'E':['GAA','GAG'],'G':['GGT','GGC','GGA','GGG'],'F':['TTT','TTC'],
'Y':['TAT','TAC'],'C':['TGT','TGC'],'W':['TGG'],'-':['TGA','TAG','TAA'] }
                                #R= G or A , Y= C or T , N= any
simplified_codon_dictionary={
'M':['ATG'],'I':['ATY','ATA'],'T':['ACN'],'K':['AAR'],'N':['AAY'],
'S':['AGY','TCN'],'R':['AGR','CGN'],'L':['CTN','TTR'],
'P':['CCN'],'H':['CAY'],'Q':['CAR'],'V':['GTN'],'A':['GCN'],
'D':['GAY'],'E':['GAR'],'G':['GGN'],'F':['TTY'],
'Y':['TAY'],'C':['TGY'],'W':['TGG'],'-':['TGA','TAR'] }

def seq_amino_acid_list(dna_seq):
    codon_count=0               #assumes sequence is in +0 reading frame
    amino_acids=[]
    for i in range(0,(len(dna_seq)//3)):
        codon=dna_seq[i+codon_count]+dna_seq[i+codon_count+1]+dna_seq[i+codon_count+2]
        amino_acids.append(codon_translation(codon))
        codon_count+=2
    return amino_acids

def codon_usage(codon):         #Greater value indicates more efficient expression. Scores for all codons of same amino acid add up to one. Values for E. coli from GenScript
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

def reverse_translation(aa_seq):    #This is the primary function, that calls the previous modules. It converts an amino acid sequence to its possible DNA sequences, then selects the DNA sequence with the fewest mutation hotspots
    aa_seq=list(aa_seq)
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
        possible_codon_windows=[]           #goes through every possible codon for given amino acid, then appends possibilty to growing list
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
                    possible_codon_windows.append(j1+j2+j3)         #Brute-forcing by creating the entire sequence caused my system to crash, so I tried this creative appraoch of taking only three amino acids at a time and then analyzing them for mutation hotspots. It finds the best three, adds it to the growing best sequence, then moves on to next three and repeats. If it is possible to go through enire sequences without having to do this trick, it may be better
        for k in range(0,len(possible_codon_windows)):
            possible_codon_windows[k]=''.join(possible_codon_windows[k])
        mutability_scores=[]
        for j in range(0,len(possible_codon_windows)):              #Calculates the number of each type of mutation hotspot in the sequence
            TT_dimers=TT_dimer_count(possible_codon_windows[j])
            other_pyr_dimers=other_pyr_dimer_count([possible_codon_windows[j]])
            methyl_sites=methylation_sites(possible_codon_windows[j])
            run_repeats=repeat_runs(possible_codon_windows[j])
            homologies=homology_repeats(possible_codon_windows[j])
            deaminated_sites=deamination_sites(possible_codon_windows[j])
            alkylated_sites=alkylation_sites(possible_codon_windows[j])
            oxidized_sites=oxidation_sites(possible_codon_windows[j])
            other_misc_sites=misc_other_sites(possible_codon_windows[j])
            hairpins=hairpin_sites(possible_codon_windows[j])
            IS_sites=insertion_sequences(possible_codon_windows[j])
            mutability_score=float(5*TT_dimers+1.8*other_pyr_dimers+3*methyl_sites+3.4*run_repeats+1.5*homologies+0.3*deaminated_sites+0.4*alkylated_sites+0.35*oxidized_sites+0.2*other_misc_sites+0.9*hairpins+4.2*IS_sites)  #This score is again an imperfect solution, since the coefficient weight I assigned were arbitrary. The ideal would be selecting the one with a minimum of all sites, with a hierarchy in the event two sequences differ only by the first sequence having hotspot X and the second sequence getting rid of X by creating hotspot Y in its place
            mutability_scores.append(mutability_score-seq_codon_usage_avg(possible_codon_windows[j]))
        optimal_index=mutability_scores.index(min(mutability_scores))           #The sequence with the lowest number of hostpots, weighted by those arbitrary coefficients, is selected as the optimal sequence
        if i <len(aa_seq)-3:
            seq_construction.append(possible_codon_windows[optimal_index][0:3])
        elif i==len(aa_seq)-3:
            seq_construction.append(possible_codon_windows[optimal_index][0:10])
    seq_construction=''.join(seq_construction)
    return seq_construction

def seq_codon_usage_avg(dna_seq):
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

def TT_dimer_count(dna_seq):            #These functions below are all finding certain types of mutation hotspot
    TT_dimers=0
    for i in range(0,len(dna_seq)-1):
        if dna_seq[i]+dna_seq[i+1]=='TT':
            TT_dimers+=1
    return TT_dimers

def other_pyr_dimer_count(dna_seq):
    other_dimers=0
    for i in range(0,len(dna_seq)-1):
        if dna_seq[i]+dna_seq[i+1] in ['CT','TC','CC','CY','TY','YC','YT','YY']:
            other_dimers+=1
    return other_dimers

def methylation_sites(dna_seq): #E. coli sites only
    Dam_sites=dna_seq.count('GATC')
    Dcm_sites=dna_seq.count('CCAGG')+dna_seq.count('CCTGG')
    return Dam_sites+Dcm_sites

def repeat_runs(dna_seq):
    run_repeats=0
    for i in range(0,len(dna_seq)-3):
        if dna_seq[i]==dna_seq[i+1]==dna_seq[i+2]==dna_seq[i+3]:
            run_repeats+=1
    return run_repeats

def homology_repeats(dna_seq):
    homologies=0
    for i in range(0,len(dna_seq)-5):
        seq_window=dna_seq[i]+dna_seq[i+1]+dna_seq[i+2]+dna_seq[i+3]+dna_seq[i+4]+dna_seq[i+5]
        if not any(base in seq_window for base in ('R', 'Y', 'N')):
            if dna_seq.count(seq_window)>=2:
                homologies+=1
    return homologies

def deamination_sites(dna_seq):
    return dna_seq.count('CG')

def alkylation_sites(dna_seq):
    return dna_seq.count('RG')+dna_seq.count('GG')+dna_seq.count('AG')

def oxidation_sites(dna_seq):           #Consider simply minimizing number of G
    return dna_seq.count('GGG')+dna_seq.count('GG')

def misc_other_sites(dna_seq):
    return dna_seq.count('YTG')+dna_seq.count('TTG')+dna_seq.count('CTG')+dna_seq.count('GTGG')+dna_seq.count('GGCGCC')

def hairpin_sites(dna_seq):
    return dna_seq.count('CCTCCGG')+dna_seq.count('CCNNNGG')+dna_seq.count('CGNNNCG')+dna_seq.count('GCNNNGC')+dna_seq.count('GGNNNCC')

def insertion_sequences(dna_seq): #E. coli only
    ISEc17=dna_seq.count('TGCGGACGATCATCAGTTAT')
    IS903B=dna_seq.count('GATCGTTGGGAACCG')
    IS50R=dna_seq.count('GCAGTCAGGCACCGT')+dna_seq.count('TAAGCTTTAATGCGC')+dna_seq.count('GCAGTCAGGCACCGT')+dna_seq.count('GCCGCCCAGTCCTGC')+dna_seq.count('GTCTGACGC')
    IS3411=dna_seq.count('CAGGAAAGA')
    IS30=dna_seq.count('AGTGCCATCTCCTT')+dna_seq.count('TTACCTGGTGC')
    IS1A=dna_seq.count('TTGTGTTTTTCAT')
    return ISEc17+IS903B+IS50R+IS3411+IS30+IS1A

#File functions to take ApE file, optomize its sequence, then output another ApE file with the new sequence. Right now, any annotated features in the ApE file are lost in the process.
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


#Command line testing script that shows the output for when GFP is optomized

print('Enter amino acid sequence in one-letter FAFSTA format: ')     #in actual version would be input('Enter amino acid sequence in one-letter FAFSTA format: ')
aa_seq='MSKGEELFTGVVPILVELDGDVNGHKFSVSGEGEGDATYGKLTLKFICTTGKLPVPWPTLVTTFSYGVQCFSRYPDHMKQHDFFKSAMPEGYVQERTIFFKDDGNYKTRAEVKFEGDTLVNRIELKGIDFKEDGNILGHKLEYNYNSHNVYIMADKQKNGIKVNFKIRHNIEDGSVQLADHYQQNTPIGDGPVLLPDNHYLSTQSALSKDPNEKRDHMVLLEFVTAAGITHGMDELYK-'
print('Input amino acid sequence: ')
for i in range(0,len(aa_seq)//60):
    print(aa_seq[i*60:i*60+60])
if len(aa_seq)%60!=0:
    print(aa_seq[60*(len(aa_seq)//60):len(aa_seq)+1])
optomized=reverse_translation(aa_seq)
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

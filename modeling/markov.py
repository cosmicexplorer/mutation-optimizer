# hand-copied from
# http://www.stats.ox.ac.uk/__data/assets/pdf_file/0003/4296/Basic_Models_of_Nucleotide_Evolution_2.pdf,
# so I'm sorry for the poor style

import sys, math, random, matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def solveTN93(a1, a2, b, T, C, A, G, l):
    if T == 0: T = .001
    if C == 0: C = .001
    if A == 0: A = .001
    if G == 0: G = .001
    l = l[:] # clone
    hx = T + ((T*(A+G))/(T+C))*math.exp(-b) + (C/(T+C))*math.exp(
        -((T+C)*a1+(A+G)*b))
    ix = C + ((C*(A+G))/(T+C))*math.exp(-b) - (C/(T+C))*math.exp(
        -((T+C)*a1+(A+G)*b))
    jx = T + ((T*(A+G))/(T+C))*math.exp(-b) - (T/(T+C))*math.exp(
        -((T+C)*a1+(A+G)*b))
    kx = C + ((T*(A+G))/(T+C))*math.exp(-b) + (T/(T+C))*math.exp(
        -((T+C)*a1+(A+G)*b))
    lx = A + ((A*(T+C))/(A+G))*math.exp(-b) + (G/(A+G))*math.exp(
        -((A+G)*a2+(T+C)*b))
    mx = G + ((G*(T+C))/(A+G))*math.exp(-b) - (G/(A+G))*math.exp(
        -((A+G)*a2+(T+C)*b))
    nx = A + ((A*(T+C))/(A+G))*math.exp(-b) - (A/(A+G))*math.exp(
        -((A+G)*a2+(T+C)*b))
    ox = G + ((G*(T+C))/(A+G))*math.exp(-b) + (A/(A+G))*math.exp(
        -((A+G)*a2+(T+C)*b))
    px = A * (1 - math.exp(-b))
    qx = G * (1 - math.exp(-b))
    rx = T * (1 - math.exp(-b))
    sx = C * (1 - math.exp(-b))
    hs = hx
    i = ix
    js = jx
    ks = kx
    ls = lx
    ms = mx
    ns = nx
    os = ox
    ps = px
    qs = qx
    rs = rx
    ss = sx
    TT = i + ps + qs
    TC = js + ps + qs
    TA = rs + ss + ms
    TG = rs + ss + ns
    x = (((l.count('T'))*TT) + ((l.count('C'))*TC) + (
        (l.count('A'))*TA) + ((l.count('G'))*TG)) / len(l)
    t = None
    try: t = random.expovariate(x)
    except: t = sys.float_info.max
    f = None
    try: f = random.expovariate(rs)
    except: f = sys.float_info.max
    g = None
    try: g = random.expovariate(ms)
    except: g = sys.float_info.max
    a = None
    try: a = random.expovariate(ns)
    except: a = sys.float_info.max
    c = None
    try: c = random.expovariate(ss)
    except: c = sys.float_info.max
    fj = None
    try: fj = random.expovariate(js)
    except: fj = sys.float_info.max
    aj = None
    try: aj = random.expovariate(ps)
    except: aj = sys.float_info.max
    gj = None
    try: gj = random.expovariate(qs)
    except: gj = sys.float_info.max
    cs = None
    try: cs = random.expovariate(i)
    except: cs = sys.float_info.max
    while t < 1:
        p = random.randint(0, len(l) - 1)
        B = l[p]
        if B == 'A':
            if f < g and f < c: l[p] = 'T'
            elif g < f and g < c: l[p] = 'G'
            elif c < f and c < g: l[p] = 'C'
        elif B == 'G':
            if f < a and f < c: l[p] = 'T'
            elif a < f and a < c: l[p] = 'A'
            elif c < f and c < a: l[p] = 'C'
        elif B == 'C':
            if fj < aj and fj < gj: l[p] = 'T'
            elif aj < fj and aj < gj: l[p] = 'A'
            elif gj < fj and gj < aj: l[p] = 'G'
        elif B == 'T':
            if cs < aj and cs < gj: l[p] = 'C'
            elif aj < cs and aj < gj: l[p] = 'A'
            elif gj < aj and gj < cs: l[p] = 'G'
        x = (((l.count('T'))*TT) + ((l.count('C'))*TC) + (
            (l.count('A'))*TA) + ((l.count('G'))*TG)) / len(l)
        t = t + random.expovariate(x)
    return l

def numDiffsCodons(seq1, seq2):
    s = 0
    for i in range(len(seq1)):
        if seq1[i] != seq2[i]: s = s + 1
    return s / len(seq1)

sys.path.insert(0, '../lib')
import mutation_optimizer

ConservativeAminoMap = {
    'A': ['S'],
    'R': ['K'],
    'N': ['Q','H'],
    'D': ['E'],
    'Q': ['N'],
    'C': ['S'],
    'E': ['D'],
    'G': ['P'],
    'H': ['N', 'Q'],
    'I': ['L', 'V'],
    'L': ['I', 'V'],
    'K': ['R', 'Q'],
    'M': ['L', 'I'],
    'F': ['M', 'L', 'Y'],
    'S': ['T', 'G'],
    'T': ['S', 'V'],
    'W': ['Y'],
    'Y': ['W', 'F'],
    'V': ['I', 'L']
}

def numDiffsAminos(seq1, seq2):
    s = 0
    seq1Amino = mutation_optimizer.dna_to_aa_translation(seq1)
    seq2Amino = mutation_optimizer.dna_to_aa_translation(seq2)
    for i in range(len(seq1Amino)):
        aminoA = seq1Amino[i]
        aminoB = seq2Amino[i]
        if ((aminoA != aminoB) and
            (aminoA in ConservativeAminoMap) and
            (aminoB not in ConservativeAminoMap[aminoA])):
            s = s + 1
    return s / len(seq1Amino)

if __name__ == "__main__":
    # s = (1.525 + .374 + .41 + .2702 + .541 + .505 + .187 + .268 + .1.127 +
    #      .521 + .712 + 3.128)
    # a1 = ((1.525 + 2.702) + (1.127 + .521)) / s
    # a2 = ((.374 + 1.87) + (.505 + .712)) / s
    # b =
    a1 = .4
    a2 = .6
    b = .06
    # b is hypothesized to be reduced by 10% in the optimized sequences
    b_opt = .054

    # _opt variables are from the mutation optimizer
    # RFP: BBa_E1010
    test1 = 'ATGGCTTCCTCCGAAGACGTTATCAAAGAGTTCATGCGTTTCAAAGTTCGTATGGAAGGTTCCGTTAACGGTCACGAGTTCGAAATCGAAGGTGAAGGTGAAGGTCGTCCGTACGAAGGTACCCAGACCGCTAAACTGAAAGTTACCAAAGGTGGTCCGCTGCCGTTCGCTTGGGACATCCTGTCCCCGCAGTTCCAGTACGGTTCCAAAGCTTACGTTAAACACCCGGCTGACATCCCGGACTACCTGAAACTGTCCTTCCCGGAAGGTTTCAAATGGGAACGTGTTATGAACTTCGAAGACGGTGGTGTTGTTACCGTTACCCAGGACTCCTCCCTGCAAGACGGTGAGTTCATCTACAAAGTTAAACTGCGTGGTACCAACTTCCCGTCCGACGGTCCGGTTATGCAGAAAAAAACCATGGGTTGGGAAGCTTCCACCGAACGTATGTACCCGGAAGACGGTGCTCTGAAAGGTGAAATCAAAATGCGTCTGAAACTGAAAGACGGTGGTCACTACGACGCTGAAGTTAAAACCACCTACATGGCTAAAAAACCGGTTCAGCTGCCGGGTGCTTACAAAACCGACATCAAACTGGACATCACCTCCCACAACGAAGACTACACCATCGTTGAACAGTACGAACGTGCTGAAGGTCGTCACTCCACCGGTGCTTAATAACGCTGATAGTGCTAGTGTAGATCGC'
    test1_opt = 'ATGGCAAGTAGCGAAGATGTAATTAAAGAATTTATGCGCTTTAAAGTACGTATGGAAGGCAGCGTAAATGGCCATGAATTTGAAATTGAAGGCGAAGGCGAAGGCCGTCCATATGAAGGCACACAAACAGCTAAACTTAAAGTAACTAAAGGCGGCCCATTACCATTTGCATGGGACATCTTATCACCACAGTTTCAGTATGGCAGTAAAGCATATGTTAAACATCCAGCAGACATTCCAGACTACCTTAAGTTATCATTTCCAGAAGGCTTTAAATGGGAACGCGTAATGAACTTTGAAGATGGCGGCGTAGTAACAGTAACACAAGACAGTTCATTACAAGATGGCGAATTTATTTACAAAGTAAAGTTACGCGGCACTAACTTTCCAAGCGATGGCCCAGTAATGCAGAAGAAGACTATGGGCTGGGAAGCAAGTACAGAACGTATGTATCCAGAAGATGGCGCACTTAAAGGCGAAATTAAGATGCGTCTTAAACTTAAAGATGGCGGCCACTATGATGCAGAAGTAAAGACTACATACATGGCTAAGAAACCAGTACAGTTACCTGGCGCATACAAGACAGACATTAAGTTAGACATTACATCACACAATGAAGACTACACTATTGTAGAACAGTATGAACGCGCAGAAGGCCGTCACAGTACTGGCGCATAATAACGTTAATAATGTTAATGTCGTAGT'

    # T4 Holin: BBa_K112000
    test2 = 'ATGGCAGCACCTAGAATATCATTTTCGCCCTCTGATATTCTATTTGGTGTTCTCGATCGCTTGTTCAAAGATAACGCTACCGGGAAGGTTCTTGCTTCCCGGGTAGCTGTCGTAATTCTTTTGTTTATAATGGCGATTGTTTGGTATAGGGGAGATAGTTTCTTTGAGTACTATAAGCAATCAAAGTATGAAACATACAGTGAAATTATTGAAAAGGAAAGAACTGCACGCTTTGAATCTGTCGCCCTGGAACAACTCCAGATAGTTCATATATCATCTGAGGCAGACTTTAGTGCGGTGTATTCTTTCCGCCCTAAAAACTTAAACTATTTTGTTGATATTATAGCATACGAAGGAAAATTACCTTCAACAATAAGTGAAAAATCACTTGGAGGATATCCTGTTGATAAAACTATGGATGAATATACAGTTCATTTAAATGGACGTCATTATTATTCCAACTCAAAATTTGCTTTTTTACCAACTAAAAAGCCTACTCCCGAAATAAACTACATGTACAGTTGTCCATATTTTAATTTGGATAATATCTATGCTGGAACGATAACCATGTACTGGTATAGAAATGATCATATAAGTAATGACCGCCTTGAATCAATATGTGCTCAGGCGGCCAGAATATTAGGAAGGGCTAAATAA'
    test2_opt = 'ATGGCAGCACCACGTATTTCATTTTCACCAAGCGACATCTTATTTGGCGTATTAGACCGTTTATTTAAAGACAATGCTACTGGCAAAGTATTAGCATCACGCGTAGCAGTAGTAATCTTATTATTTATTATGGCTATTGTATGGTATCGCGGCGACTCATTCTTTGAATACTACAAACAAAGTAAGTATGAAACATACAGCGAAATTATTGAGAAAGAACGTACAGCACGCTTTGAATCAGTAGCATTAGAACAGTTACAAATTGTACACATTAGTTCAGAAGCAGACTTTAGCGCAGTATACTCATTTCGTCCTAAGAACCTTAACTACTTTGTAGACATTATTGCATATGAAGGCAAGTTACCAAGTACTATTAGCGAAAAGTCACTTGGCGGCTATCCAGTAGACAAGACTATGGATGAATACACAGTACACCTTAATGGCCGTCACTACTACAGTAACAGTAAGTTTGCATTCTTACCTACTAAGAAACCTACACCAGAAATTAACTACATGTACTCATGTCCATACTTTAACTTAGACAACATTTATGCTGGCACAATTACTATGTACTGGTATCGTAATGACCACATTAGTAATGACCGTTTAGAAAGTATTTGCGCACAAGCAGCACGTATTCTTGGCCGCGCTAAGTAA'

    # LuxR autoinducer synthase: BBa_C0061
    test3 = 'ATGACTATAATGATAAAAAAATCGGATTTTTTGGCAATTCCATCGGAGGAGTATAAAGGTATTCTAAGTCTTCGTTATCAAGTGTTTAAGCAAAGACTTGAGTGGGACTTAGTTGTAGAAAATAACCTTGAATCAGATGAGTATGATAACTCAAATGCAGAATATATTTATGCTTGTGATGATACTGAAAATGTAAGTGGATGCTGGCGTTTATTACCTACAACAGGTGATTATATGCTGAAAAGTGTTTTTCCTGAATTGCTTGGTCAACAGAGTGCTCCCAAAGATCCTAATATAGTCGAATTAAGTCGTTTTGCTGTAGGTAAAAATAGCTCAAAGATAAATAACTCTGCTAGTGAAATTACAATGAAACTATTTGAAGCTATATATAAACACGCTGTTAGTCAAGGTATTACAGAATATGTAACAGTAACATCAACAGCAATAGAGCGATTTTTAAAGCGTATTAAAGTTCCTTGTCATCGTATTGGAGACAAAGAAATTCATGTATTAGGTGATACTAAATCGGTTGTATTGTCTATGCCTATTAATGAACAGTTTAAAAAAGCAGTCTTAAATGCTGCAAACGACGAAAACTACGCTTTAGTAGCTTAATAACTCTGATAGTGCTAGTGTAGATCTC'
    test3_opt = 'ATGACTATTATGATTAAGAAGAGCGACTTCTTAGCTATTCCAAGCGAAGAATACAAAGGCATCTTATCATTACGTTATCAAGTATTTAAACAACGTTTAGAATGGGACTTAGTAGTAGAAAACAACTTAGAAAGCGATGAATATGACAACAGTAATGCAGAATACATTTATGCATGCGATGACACAGAAAATGTAAGCGGCTGTTGGCGTTTATTACCTACTACTGGCGACTACATGCTTAAGAGCGTATTTCCAGAATTACTTGGCCAACAGAGCGCACCTAAAGATCCTAACATTGTAGAATTATCACGCTTTGCAGTTGGCAAGAACAGTAGTAAGATTAACAACAGCGCAAGCGAAATTACTATGAAGTTATTTGAAGCTATTTACAAACATGCAGTATCACAAGGCATTACAGAATATGTAACAGTAACAAGTACAGCTATTGAACGTTTTCTTAAACGTATTAAAGTACCATGTCATCGTATTGGCGACAAAGAAATTCATGTACTTGGCGACACTAAGAGCGTAGTACTTAGTATGCCTATTAATGAACAGTTTAAGAAAGCAGTACTTAATGCAGCTAATGATGAAAACTATGCATTAGTAGCATAATAACTGTAATAATGTTAATGTCGTAGT'

    initSeqs = [test1, test2, test3, test1_opt, test2_opt, test3_opt]
    initSeqs = list(map(lambda x: list(x), initSeqs))
    # arbitrary number of generations
    numGenerations = 400
    seqs = list(map(lambda x: [x] + [None] * numGenerations, initSeqs))
    bases = ['A','G','C','T']
    b_to_use = 0
    for ind, s in enumerate(seqs):
        if ind <= 2:
            b_to_use = b
        else:
            b_to_use = b_opt
        print([ind, b_to_use])
        for j in range(numGenerations):
            seq = s[j]
            A, G, C, T = map(lambda base: s[j].count(base), bases)
            s[j + 1] = solveTN93(a1, a2, b_to_use, T, C, A, G, seq)
            s[j] = {
                'codons': numDiffsCodons(initSeqs[ind], seq) * 100,
                'aminos': numDiffsAminos(initSeqs[ind], seq) * 100
            }
    plt.xscale('log')
    color = ''
    marker = ''
    for ind, s in enumerate(seqs):
        amins = list(map(lambda el: el['aminos'], s[:numGenerations]))
        if ind % 3 == 0: marker="_"
        elif ind % 3 == 1: marker="x"
        else: marker='+'
        if ind == 0: color="#ff0000"
        elif ind == 1: color="#aa0000"
        elif ind == 2: color="#550000"
        elif ind == 3: color="#00ff00"
        elif ind == 4: color="#00aa00"
        else: color="#005500"
        plt.plot(amins, color=color, marker=marker, linewidth=.75)
    plt.xlim([0, 10 ** 2.7])
    plt.ylim([30, 85])
    plt.legend(['RFP BBa_E1010', 'T4 Holin BBa_K112000',
                'LuxR synthase BBa_C0061',
                'RFP BBa_E1010 (optimized)', 'T4 Holin BBa_K112000 (optimized)',
                'LuxR synthase BBa_C0061 (optimized)'], loc = 'lower right')
    plt.title('Markov Model of Amino Substitions per Generation')
    plt.xlabel('Generations (logarithmic scale)')
    plt.grid(True)
    plt.ylabel('% Substitutions (compared to original sequence)')
    plt.savefig('aminos-conservative-substitions-opt')
    plt.clf()
    for ind, s in enumerate(seqs):
        cods = list(map(lambda el: el['codons'], s[:numGenerations]))
        if ind % 3 == 0: marker="_"
        elif ind % 3 == 1: marker="x"
        else: marker='+'
        if ind == 0: color="#ff0000"
        elif ind == 1: color="#aa0000"
        elif ind == 2: color="#550000"
        elif ind == 3: color="#00ff00"
        elif ind == 4: color="#00aa00"
        else: color="#005500"
        plt.plot(cods, color=color, marker=marker, linewidth=.75)
    plt.grid(True)
    plt.legend(['RFP BBa_E1010', 'T4 Holin BBa_K112000',
                'LuxR synthase BBa_C0061',
                'RFP BBa_E1010 (optimized)', 'T4 Holin BBa_K112000 (optimized)',
                'LuxR synthase BBa_C0061 (optimized)'],
               loc = 'lower right')
    plt.xlabel('Generations (logarithmic scale)')
    plt.ylabel('% Substitutions (compared to original sequence)')
    plt.title(
        'Markov Model of Individual Base Substitions per Generation')
    plt.xscale('log')
    plt.xlim([0, 10 ** 2.7])
    plt.ylim([30, 80])
    plt.savefig('codons-opt')

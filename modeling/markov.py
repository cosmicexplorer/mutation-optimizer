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
def numDiffsAminos(seq1, seq2):
    s = 0
    seq1Amino = mutation_optimizer.dna_to_aa_translation(seq1)
    seq2Amino = mutation_optimizer.dna_to_aa_translation(seq2)
    for i in range(len(seq1Amino)):
        if seq1Amino[i] != seq2Amino[i]: s = s + 1
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

    # RFP: BBa_E1010
    test1 = 'ATGGCTTCCTCCGAAGACGTTATCAAAGAGTTCATGCGTTTCAAAGTTCGTATGGAAGGTTCCGTTAACGGTCACGAGTTCGAAATCGAAGGTGAAGGTGAAGGTCGTCCGTACGAAGGTACCCAGACCGCTAAACTGAAAGTTACCAAAGGTGGTCCGCTGCCGTTCGCTTGGGACATCCTGTCCCCGCAGTTCCAGTACGGTTCCAAAGCTTACGTTAAACACCCGGCTGACATCCCGGACTACCTGAAACTGTCCTTCCCGGAAGGTTTCAAATGGGAACGTGTTATGAACTTCGAAGACGGTGGTGTTGTTACCGTTACCCAGGACTCCTCCCTGCAAGACGGTGAGTTCATCTACAAAGTTAAACTGCGTGGTACCAACTTCCCGTCCGACGGTCCGGTTATGCAGAAAAAAACCATGGGTTGGGAAGCTTCCACCGAACGTATGTACCCGGAAGACGGTGCTCTGAAAGGTGAAATCAAAATGCGTCTGAAACTGAAAGACGGTGGTCACTACGACGCTGAAGTTAAAACCACCTACATGGCTAAAAAACCGGTTCAGCTGCCGGGTGCTTACAAAACCGACATCAAACTGGACATCACCTCCCACAACGAAGACTACACCATCGTTGAACAGTACGAACGTGCTGAAGGTCGTCACTCCACCGGTGCTTAATAACGCTGATAGTGCTAGTGTAGATCGC'

    # T4 Holin: BBa_K112000
    test2 = 'ATGGCAGCACCTAGAATATCATTTTCGCCCTCTGATATTCTATTTGGTGTTCTCGATCGCTTGTTCAAAGATAACGCTACCGGGAAGGTTCTTGCTTCCCGGGTAGCTGTCGTAATTCTTTTGTTTATAATGGCGATTGTTTGGTATAGGGGAGATAGTTTCTTTGAGTACTATAAGCAATCAAAGTATGAAACATACAGTGAAATTATTGAAAAGGAAAGAACTGCACGCTTTGAATCTGTCGCCCTGGAACAACTCCAGATAGTTCATATATCATCTGAGGCAGACTTTAGTGCGGTGTATTCTTTCCGCCCTAAAAACTTAAACTATTTTGTTGATATTATAGCATACGAAGGAAAATTACCTTCAACAATAAGTGAAAAATCACTTGGAGGATATCCTGTTGATAAAACTATGGATGAATATACAGTTCATTTAAATGGACGTCATTATTATTCCAACTCAAAATTTGCTTTTTTACCAACTAAAAAGCCTACTCCCGAAATAAACTACATGTACAGTTGTCCATATTTTAATTTGGATAATATCTATGCTGGAACGATAACCATGTACTGGTATAGAAATGATCATATAAGTAATGACCGCCTTGAATCAATATGTGCTCAGGCGGCCAGAATATTAGGAAGGGCTAAATAA'

    # LuxR autoinducer synthase: BBa_C0061
    test3 = 'ATGACTATAATGATAAAAAAATCGGATTTTTTGGCAATTCCATCGGAGGAGTATAAAGGTATTCTAAGTCTTCGTTATCAAGTGTTTAAGCAAAGACTTGAGTGGGACTTAGTTGTAGAAAATAACCTTGAATCAGATGAGTATGATAACTCAAATGCAGAATATATTTATGCTTGTGATGATACTGAAAATGTAAGTGGATGCTGGCGTTTATTACCTACAACAGGTGATTATATGCTGAAAAGTGTTTTTCCTGAATTGCTTGGTCAACAGAGTGCTCCCAAAGATCCTAATATAGTCGAATTAAGTCGTTTTGCTGTAGGTAAAAATAGCTCAAAGATAAATAACTCTGCTAGTGAAATTACAATGAAACTATTTGAAGCTATATATAAACACGCTGTTAGTCAAGGTATTACAGAATATGTAACAGTAACATCAACAGCAATAGAGCGATTTTTAAAGCGTATTAAAGTTCCTTGTCATCGTATTGGAGACAAAGAAATTCATGTATTAGGTGATACTAAATCGGTTGTATTGTCTATGCCTATTAATGAACAGTTTAAAAAAGCAGTCTTAAATGCTGCAAACGACGAAAACTACGCTTTAGTAGCTTAATAACTCTGATAGTGCTAGTGTAGATCTC'

    initSeqs = [test1, test2, test3]
    initSeqs = list(map(lambda x: list(x), initSeqs))
    # arbitrary number of generations
    numGenerations = 400
    seqs = list(map(lambda x: [x] + [None] * numGenerations, initSeqs))
    bases = ['A','G','C','T']

    for ind, s in enumerate(seqs):
        for j in range(numGenerations):
            seq = s[j]
            A, G, C, T = map(lambda base: s[j].count(base), bases)
            s[j + 1] = solveTN93(a1, a2, b, T, C, A, G, seq)
            s[j] = {
                'codons': numDiffsCodons(initSeqs[ind], seq),
                'aminos': numDiffsAminos(initSeqs[ind], seq)
            }
    plt.xscale('log')
    for s in seqs:
        amins = list(map(lambda el: el['aminos'], s[:numGenerations]))
        plt.plot(amins)
    plt.legend(['RFP BBa_E1010', 'T4 Holin BBa_K112000',
                'LuxR autoinducer synthase BBa_C0061'], loc='lower right')
    plt.title('Markov Model of Amino Substitions per Generation')
    plt.xlabel('Generations (logarithmic scale)')
    plt.grid(True)
    plt.ylabel('% Substitutions (compared to original sequence)')
    plt.xscale('log')
    plt.savefig('aminos')
    plt.clf()
    for s in seqs:
        cods = list(map(lambda el: el['codons'], s[:numGenerations]))
        plt.plot(cods)
    plt.grid(True)
    plt.legend(['RFP BBa_E1010', 'T4 Holin BBa_K112000',
                'LuxR autoinducer synthase BBa_C0061'], loc='lower right')
    plt.xlabel('Generations (logarithmic scale)')
    plt.ylabel('% Substitutions (compared to original sequence)')
    plt.title('Markov Model of Individual Base Substitions per Generation')
    plt.xscale('log')
    plt.savefig('codons')
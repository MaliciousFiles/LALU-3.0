import LowerHLIR2 as LHL

Ceil = lambda x:-(-x//1)

MAXUINT = 1<<32
MaxOptions = 4
ExpScaleUp = .5

jumps = ['jmp', 'c.jmp', 'cn.jmp']
usesRd = ['st', 'bst', 'stchr']

class BlockSet:
    def __init__(self, blocks):
        self.blocks = blocks
        self.dom = {}
        self.idom = {}
        self.dom_fr = {}

    def __repr__(self):
        return '\n'.join([repr(x) for x in self.blocks])

    def UpdateDominators(self):
        self.dom = {}
        self.idom = {}
        self.dom_fr = {}
        self.dom[self.blocks[0].label] = set([self.blocks[0].label])
        anynode = set([x.label for x in self.blocks])
        for block in self.blocks[1:]:
            self.dom[block.label] = set(anynode)

        do = True
        while do:
            do = False
            for block in self.blocks[1:]:
                ndoms = set(anynode)
                for pred in block.Preds():
                    ndoms &= self.dom[pred]
                res = set([block.label]) | ndoms
                if res != self.dom[block.label]:
                    do = True
                    self.dom[block.label] = res
        for block in self.blocks:
            self.dom[block.label] -= set([block.label])

        for block in self.blocks[1:]:
            for dom in self.dom[block.label]:
                for odom in self.dom[block.label]:
                    if odom == dom: continue
                    if dom in self.dom[odom]: break
                else:
                    self.idom[block.label] = dom
                    break
        for block in self.blocks:
            self.dom_fr[block.label] = set()
        for block in self.blocks:
            preds = block.Preds()
            if len(preds) >= 2:
                for pred in preds:
                    runner = pred
                    while runner != self.idom[block.label]:
                        self.dom_fr[runner] |= set([block.label])
                        runner = self.idom[runner]
        
                    
        print(f'new dominators is {self.dom!r}, with idom {self.idom!r}')
        print(f'{self.dom_fr=}')

    def Renumber(self):
        reps = {}
        for i, block in enumerate(self.blocks[1:], 0):
            reps[block.label] = block.label = f'L{i}'
        for block in self.blocks:
            if block.exit[0] in jumps:
                block.exit = (block.exit[0], reps[block.exit[1].rstrip(':')])

    def ForwardJumps(self):
        didOpt = True
        while didOpt:
            didOpt = False

            #Replace jumps to empty blocks with their destination
            for block in self.blocks:
                if block.exit[0] in jumps:
                    succ = block.exit[1]
                    succblock = self.ByName(succ)
                    if succblock.IsEffEmpty():
                        block.exit = list(block.exit)
                        block.exit[1] = succblock.Succs()[0]
                        block.exit = tuple(block.exit)
                        block.body += succblock.body
                        didOpt = True

            #Replace empty block fall throughs with the destination
            for i, block in enumerate(self.blocks):
                if block.IsEffEmpty() and len(block.JumpPreds()) == 0:
                    for pred in block.Preds():
                        predblock = self.ByName(pred)
                        if predblock.exit != 'FALL': continue
                        predblock.exit = block.exit
                        predblock.body += block.body
                        didOpt = True
                        del self.blocks[i]
                        break

            #Replace jumps past an empty jump with a negated jump
            for i, block in enumerate(self.blocks):
                if block.IsEffEmpty() and block.exit[0] == 'jmp':
                    np = block.NatPreds()
                    if len(np) == 0: continue
                    pred = np[0]
                    predblock = self.ByName(pred)

##                    print(f'{block.label} ... {pred} -> {predblock.exit}')
                    
                    if predblock.exit[0] not in jumps: continue
                    predest = predblock.exit[1]
                    if predest != block.FallThru(): continue

                    newexit = (['c.jmp', 'cn.jmp'][['cn.jmp', 'c.jmp'].index(predblock.exit[0])], block.exit[1])
                    predblock.exit = newexit

                    del self.blocks[i]
                    didOpt = True
                    break

    def ByName(self, label):
        for block in self.blocks:
            if block.label == label: return block
        assert False, f'Could not find block label `{label}`'

class Block:
    def __init__(self, parent: BlockSet, unoptBlock: LHL.Block):
        self.label = unoptBlock.entry
        self.body = unoptBlock.body[:]
        self.parent = parent
        if len(self.body) > 0 and self.body[-1][0] == 'expr' and self.body[-1][1][0] in ['jmp', 'c.jmp', 'ret']:
            self.exit = self.body[-1][1]
##            if type(self.exit[1]) == str: self.exit[1].rstrip(':')
            del self.body[-1]
        else:
            self.exit = ('FALL',)
        if ('unreachable',) in self.body:
            self.exit = ('ret',)

    def __repr__(self):
        return self.label + f' -> {self.Succs()} <- J{self.JumpPreds()} + N{self.NatPreds()}:\n' + ''.join([f'    {line}\n' for line in self.body])+f'  {self.exit}\n'

    def JumpPreds(self):
        preds = []
        for block in self.parent.blocks:
            if self.label in block.JumpSuccs():
                preds.append(block.label)
        return tuple(preds)

    def NatPreds(self):
        jp = self.JumpPreds()
        return tuple([x for x in self.Preds() if x not in jp])

    def Preds(self):
        preds = []
        for block in self.parent.blocks:
            if self.label in block.Succs():
                preds.append(block.label)
        return tuple(preds)

    def FallThru(self):
        idx = self.parent.blocks.index(self)
        if idx >= len(self.parent.blocks)-1: return None
        return self.parent.blocks[idx+1].label

    def Succs(self):
        if self.exit[0] == 'ret':
            return ()
        if self.exit[0] == 'FALL':
            return (self.FallThru(),)
        elif self.exit[0] in ['c.jmp', 'cn.jmp']:
            return (self.exit[1], self.FallThru())
        elif self.exit[0] == 'jmp':
            return (self.exit[1],)
        else: assert False, f'Unreachable'

    def JumpSuccs(self):
        fall = self.FallThru()
        return tuple([x for x in self.Succs() if x != fall])

    def IsEffEmpty(self):
        for line in self.body:
            if line[0] in ['expr', 'unreachable']: return False
        return True
        

class ValueOption:
    def __init__(self, val: str|int|list|None, fallbacks = 8):
        self.opts = []
        self.fallbacks = fallbacks
        if val == None: return
        if type(val) == int:
            self.opts.append(IntRange(val, val+1))
        elif type(val) == str:
            self.opts.append(Symbolic(val))
        elif type(val) == list:
            self.opts = val
        else: assert False

    def __repr__(self):
        return f'ValueOption({self.opts!r}, {self.fallbacks!r})'

    def __str__(self):
        return f'{{{" || ".join([str(x) for x in self.opts])}}}'

    def MergeWith(self, other):
        rawconcat = self.opts + other.opts
        newopts = sorted(rawconcat)
        mfs = min(self.fallbacks, other.fallbacks)
        filtered = newopts
        if len(filtered) > MaxOptions:
            if mfs > 0 and all([type(x) == IntRange for x in filtered]):
                #newwidth = max([1]+[x.high-x.low for x in filtered])
                newwidth = filtered[-1].high - filtered[0].low
                oldwidth = max([1]+[x.high-x.low for x in rawconcat])
                tarwidth = Ceil(oldwidth * (1+ExpScaleUp))
                if newwidth < tarwidth:
                    mfs -= 1
                #print(f'{newwidth=}; {tarwidth=}')
                return ValueOption([IntRange(filtered[0].low, filtered[-1].high)], mfs)
            else:
                return ValueOption([Any], mfs)
            
        return ValueOption(filtered)
        

class Symbolic:
    def __init__(self, symbol: str, inv: bool):
        self.symbol = symbol
        self.inv = inv

    def __repr__(self):
        return f'Symbolic({self.symbol!r}, {self.inv})'

    def __str__(self):
        return '~'*self.inv + repr(self.symbol)

    def __lt__(self, _):
        return False

    def __gt__(self, _):
        return True

#Upper value not included
class IntRange:
    def __init__(self, low: int, high: int):
        self.low = low if low >= 0 else 0
        self.high = high if high <= MAXUINT else MAXUINT

    def __repr__(self):
        return f'IntRange({self.low}, {self.high})'

    def __str__(self):
        if self.high == self.low + 1:
            return str(self.low)
        return f'[{self.low}, {self.high})'

    def __lt__(self, other):
        if type(other) == Symbolic:
            return True
        else:
            return self.low < other.low

    def __gt__(self, other):
        return other < self

def Optimize(llir: LHL.LLIR) -> None:
    for func in llir.funcs:
        body = BlockSet([])
        for block in func['body']:
            body.blocks.append(Block(body, block))
        body.Renumber()
        body.ForwardJumps()
        body.Renumber()
        body.UpdateDominators()
        print(repr(body))
##        assert False


Any = IntRange(0, MAXUINT)

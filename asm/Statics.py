from math import log2

def RoundUp(x, k):
    return -k*(-x//k)

PTRWIDTH = 32

class Var():
    def __init__(self, name, kind):
        object.__setattr__(self, 'name', name)
        if type(kind) == str:
            object.__setattr__(self, 'kind', Type.FromStr(kind))
        else:
            object.__setattr__(self, 'kind', kind)
    def __hash__(self):
        return hash(repr(self.__dict__))
    def __eq__(self, other):
        return hash(self) == hash(other)
    def FromName(inter, name):
        return Var(name, inter.Lookup(name))
    def FromVal(inter, val):
        if val == None: return Var(None, None)
        if type(val) == int: return Var(val, Type(comptime = True))
        if val.isnumeric(): return Var(int(val), Type(comptime = True))
        return Var.FromName(inter, val)
    def __repr__(self):
        if self.name == self.kind == None: return f'NoVar'
        pkind = str(self.kind) if type(self.kind) == Type else self.kind
        return f'Var({self.name!r}, {pkind!r})'
    def __setattr__(self, *args):
        raise TypeError
    def __delattr__(self, *args):
        raise TypeError

NoVar = Var(None, None)
structs = {}

class Type:
    def __init__(self, width = 32, signed = False, arylen = None, numPtrs = 0, comptime = False, isbool = False, isvoid = False, struct = None):
        if struct not in structs and struct != None:
            self.width = None
        else:
            self.width = width if not struct else structs[struct]['size']
        self.signed = signed
        self.arylen = arylen
        self.numPtrs = numPtrs
        self.comptime = comptime
        self.isbool = isbool
        self.isvoid = isvoid
        self.struct = struct
    def __hash__(self):
        return hash(repr(self))
    def FromStr(txt):
        self = Type()
        if txt in structs:
            return Type(struct = txt)
        if txt.rstrip('*') in structs:
            return Type(struct = txt.rstrip('*'), numPtrs = txt.count('*'))
        if txt == 'void':
            return Type(isvoid = True)
        if txt == 'bool':
            return Type(isbool = True)
        if txt == 'comp':
             return Type(comptime = True)
        otxt = txt
        try:
            self.signed = txt[0]=='i'
            self.numPtrs = txt.count('*')
            txt = txt[:len(txt)-self.numPtrs]
            if '[' in txt:
                arylen = int(txt.split('[')[1][:-1])
                self.arylen = arylen
                txt = txt.split('[')[0]
            self.width = int(txt[1:])
            return self
        except:
            print(otxt)
            return Type(struct = otxt)
    def OpWidth(self):
        if self.numPtrs: return PTRWIDTH
##        if self.struct: return structs[self.struct]['size']
        return self.width
    def AsElementSizeOf(self):
        return AlignOf(self.OpWidth())
    def ElementSize(self):
        return self.Deref().AsElementSizeOf()
    def __repr__(self):
        return f'Type.FromStr("{self}")'
    def __str__(self):
        if self.struct:
            return self.struct + '*' * self.numPtrs
        if self.isvoid:
            return 'void'
        if self.isbool:
            return 'bool'
        if self.comptime:
            return 'comp'
        else:
            ary = f'[{self.arylen}]' if self.arylen else ''
            return f'{"ui"[self.signed]}{self.width}{ary}{"*"*self.numPtrs}'
    def CanCoerceTo(self, other):
        if self.isvoid == other.isvoid == True:
            return True
        if self.isbool or other.isvoid:
            return False
        if self.comptime:
            return True
        if other.comptime:
            return False
        if self.arylen and other.numPtrs > 0:
            return True
        if self.numPtrs > 0:
            if other.numPtrs > 0:
                return other.numPtrs == self.numPtrs
            else:
                return False == other.signed and other.width >= PTRWIDTH
        else:
            return self.signed == other.signed and other.width >= self.width
    def BitSameAs(self, other):
        return self.CanCoerceTo(other) and other.CanCoerceTo(self)
    def __eq__(self, other):
        return repr(self) == repr(other)
    def Common(self, other):
        assert not self.isbool, 'Cannot take a common type of boolean and `{other}`'
        
        bc = self.comptime and other.comptime
        if self.comptime:
            return other
        elif not bc and other.comptime:
            return self
        if self.numPtrs > 0:
            if other.numPtrs > 0:
                assert False, f'Cannot do math on two pointer types `{self}` and `{other}`'
            else:
                return self
        else:
            if other.numPtrs > 0:
                return other
            assert self.signed == other.signed, f'Cannot do math on different signs `{self}` and `{other}`'
            return Type(max(self.width, other.width), self.signed, 0)
    def Deref(self):
        assert self.numPtrs > 0 or self.arylen, f'Cannot dereference type `{self}`'
        copy = Type.FromStr(str(self))
        if self.numPtrs > 0:
            copy.numPtrs -= 1
##            return Type(self.width, self.signed, self.arylen, self.numPtrs - 1)
        elif self.arylen:
            copy.arylen = None
##            return Type(self.width, self.signed)
        return copy
    def Addr(self):
        assert not self.comptime, f'Cannot take address of comptime variable `{self}`'
        copy = Type.FromStr(str(self))
        copy.numPtrs += 1
        return copy
##        return Type(self.width, self.signed, self.arylen, self.numPtrs + 1)
    def Runtime(self):
        return Type(self.width, self.signed, self.numPtrs)
    def IsBasicInt(self):
        return not(self.numPtrs > 0 or self.comptime or self.isvoid or self.isbool or self.struct != None or self.arylen != None)


def AlignOf(bitwidth):
    if bitwidth <= 32:
        return 1<<int(log2(bitwidth-1)+1)
    else:
        return RoundUp(bitwidth, 32)

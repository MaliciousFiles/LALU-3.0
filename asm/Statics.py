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
        return type(self) == type(other) and self.kind == other.kind and hash(self) == hash(other)
    def FromName(inter, name):
        return Var(name, inter.Lookup(name))
    def FromVal(inter, val):
        if val == None: return Var(None, None)
        if type(val) == int: return Var(val, Type(Comp()))
        if val.isnumeric(): return Var(int(val), Type(Comp()))
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
quafs = ['const', 'mut']

def Const(x):
    x.quaf = 'const'
    return x

def Mut(x):
    x.quaf = 'mut'
    return x


from dataclasses import dataclass
    
@dataclass(frozen=True)
class QuafType():
    def __init__(self, quaf: str|None = None):
        self.quaf = quaf
        self.refable = False
        self.comptime = False

    def __repr__(self):
        if self.quaf:
            return f'{self.quaf.capitalize()}({self._sub_repr()})'
        return self._sub_repr()

    def __str__(self):
        if self.quaf:
            return f'{self._sub_str()} {self.quaf}'
        return self._sub_str()

    def OpWidth(self):
        return NotImplemented

class Int(QuafType):
    def __init__(self, width: int, signed: bool):
        super().__init__()
        self.refable = True
        self.width = width
        self.signed = signed

    def OpWidth(self):
        return self.width

    def _sub_repr(self):
        return f'Int(width = {self.width!r}, signed = {self.signed!r})'

    def _sub_str(self):
        return f'{"ui"[self.signed]}{self.width}'

    def _sub_eq(self, other):
        return self.width == other.width and self.signed == other.signed

class Any(QuafType):
    def __init__(self):
        super().__init__()
        self.refable = True

    def _sub_repr(self):
        return f'Any()'

    def _sub_str(self):
        return f'any'

    def _sub_eq(self, other):
        return True
    

class Void(QuafType):
    def __init__(self):
        super().__init__()
        self.refable = True

    def _sub_repr(self):
        return f'Void()'

    def _sub_str(self):
        return f'void'

    def OpWidth(self):
        return 0

    def _sub_eq(self, other):
        return True
    

class Comp(QuafType):
    def __init__(self):
        super().__init__()
        self.comptime = True

    def _sub_repr(self):
        return f'Comp()'

    def _sub_str(self):
        return f'comptime'

    def _sub_eq(self, other):
        return True
    

class Bool(QuafType):
    def __init__(self):
        super().__init__()

    def _sub_repr(self):
        return f'Bool()'

    def _sub_str(self):
        return f'bool'

    def _sub_eq(self, other):
        return True
    

class Struct(QuafType):
    def __init__(self, name):
        super().__init__()
        self.refable = True
        self.name = name

    def _sub_repr(self):
        return f'Struct({self.name!r})'

    def _sub_str(self):
        return f'{self.name!s}'

    def OpWidth(self):
        if self.name in structs:
            return structs[self.name]['size']
        else:
            return NotImplemented

    def _sub_eq(self, other):
        return self.name == other.name
    

class Pointer(QuafType):
    def __init__(self, referent: QuafType):
        super().__init__()
        self.referent = referent
        self.refable = True

    def _sub_repr(self):
        return f'Pointer({self.referent!r})'

    def _sub_str(self):
        return f'{self.referent!s}*'

    def OpWidth(self):
        return PTRWIDTH

    def _sub_eq(self, other):
        return self.Deref() == other.Deref()
    

class C_Array(QuafType):
    def __init__(self, referent: QuafType, count: int):
        super().__init__()
        self.referent = referent
        self.count = count
        self.refable = True

    def _sub_repr(self):
        return f'C_Array({self.referent!r}, {self.count!r})'

    def _sub_str(self):
        return f'{self.referent!s}[{self.count!s}]'

    def OpWidth(self):
        return PTRWIDTH

    def _sub_eq(self, other):
        return self.Deref() == other.Deref()
    

class Type:
    def __init__(self, val: str|QuafType = ...):
        assert type(val) in [type(...), str, Type, QuafType, type(None)] or hasattr(val, 'quaf'), f'Bad initialization value of `{val!r}`'
        if val == ...:
            self.body = Type.FromStr('u32').body
        elif val == None:
            self.body = None
        elif type(val) == str:
            self.body = Type.FromStr(val).body
        else:
            self.body = val

    def __getattr__(self, name):
        return self.body.__getattribute__(name)

    def FromStr(initstr: str):
        self = Type(None)
        hasRoot = False
        self.body = None
        while initstr != '':
            initstr = initstr.lstrip()
            if initstr[0] == '*':
                assert self.body.refable, f'Type root `{self.body!s}` cannot be a reference'
                initstr = initstr[1:]
                nqt = Pointer(self.body)
                self.body = nqt

            elif initstr[0].isidentifier():
                assert not hasRoot, f'Already has roottype `{self.body!s}`, cannot append `{initstr}`'
                hasRoot = True
                o = ''
                for i in range(len(initstr)):
                    if (o+initstr[i]).isidentifier():
                        o += initstr[i]
                    else:
                        break
                initstr = initstr[len(o):]
                if o[0] in 'ui' and o[1:].isdigit():
                    self.body = Int(int(o[1:]), o[0] == 'i')
                elif o == 'any':
                    self.body = Any()
                elif o == 'comptime':
                    self.body = Comp()
                elif o == 'bool':
                    self.body = Bool()
                elif o == 'void':
                    self.body = Void()
                else:
                    self.body = Struct(o)                    
            elif initstr[0] == '[':
                i = initstr.index(']')
                o = initstr[1:i]
                initstr = initstr[i+1:]
                if ':' in o: assert False, 'Not Yet Implemented: Sliceable Arrays'
                elif ',' in o: assert False, 'Not Yet Implemented: Integer Ranging'
                else:
                    self.body = C_Array(self.body, eval(o.lstrip().rstrip()))
            else:
                assert False, f'Unknown symbol `{initstr[0]}` found when parsing type {initstr}'

            initstr = initstr.lstrip()
            for q in quafs:
                if initstr.startswith(q):
                    if q == 'const':
                        self.body = Const(self.body)
                    elif q == 'mut':
                        self.body = Mut(self.body)
                    else: assert False
                    initstr = initstr[len(q):]
            initstr = initstr.lstrip()
            if initstr == '': break
        return self

    def __eq__(self, other):
        if self.quaf != other.quaf: return False
        if type(self) != type(other): return False
        return self._sub_eq(other)

    def __hash__(self):
        return hash(repr(self))
    
    def __repr__(self):
        return f'Type(\'{self.body!s}\')'
    def __str__(self):
        return str(self.body)

    def OpWidth(self):
        width = self.body.OpWidth()
        assert width != NotImplemented, f'{self!r} has no operand width'
        return width
    def AsElementSizeOf(self):
        return AlignOf(self.OpWidth())
    def ElementSize(self):
        return self.Deref().AsElementSizeOf()
    def CanCoerceTo(self, other):
        skind = type(self.body)
        okind = type(other.body)
        try:
            if other.body.quaf == 'const':
                return False
        except:
            print(f'Other is `{other!r}`, self is `{self!r}`')
            raise
        if skind == okind == Struct:
            return self.body.name == other.body.name
        if skind == okind == Void:
            return True
        if skind == Bool or skind == Void:
            return False
        if okind == Void:
            return False
        if skind == Comp:
            return True
        if skind == Any or okind == Any:
            return True
        if okind == Comp:
            return False
        if skind == C_Array and okind == Pointer:
            return True
        if skind == Pointer:
            if okind == Pointer:
                return True
                return self.Deref().CanCoerceTo(other.Deref())
            elif okind == Int:
                return not other.body.signed and other.body.width >= PTRWIDTH
            else:
                return False
        else:
            assert okind != Void, f'{self=} {other=}'
            assert skind == Int, f'{skind=}'

            if okind == Pointer:
                return not self.body.signed and self.body.width >= PTRWIDTH

            return self.body.signed == other.body.signed and other.body.width >= self.body.width
    def BitSameAs(self, other):
        return self.CanCoerceTo(other) and other.CanCoerceTo(self)
    def __eq__(self, other):
        return repr(self) == repr(other)
    def Common(self, other):
        skind = type(self.body)
        okind = type(other.body)

        assert not skind == Bool, 'Cannot take a common type of boolean and `{other!r}`'
        
        bothcomp = self.comptime and other.comptime
        if self.comptime:
            return other
        elif not bothcomp and other.comptime:
            return self
        if skind == Pointer:
            if okind == Pointer:
                assert False, f'Cannot do math on two pointer types `{self}` and `{other}`'
            else:
                return self
        else:
            if okind == Pointer:
                return other
            assert self.body.signed == other.body.signed, f'Cannot do math on different signs `{self}` and `{other}`'
            commonwidth = max(self.body.width, other.body.width)
            return Type(Int(commonwidth, self.body.signed))
    def Deref(self):
        if type(self.body) in [Pointer, C_Array]:
            hasconst = self.body.quaf == 'const'
            ret = Type(self.body.referent)
            if hasconst:
                if ret.body.quaf == 'mut':
                    ret.body.quaf = ''
                else:
                    ret.body.quaf = 'const'
            return ret
        else: assert False, f'Cannot dereference type `{self!r}`'
    def Addr(self):
        assert self.body.refable, f'Cannot take reference of non-refable type {self!r}'
        return Type(Pointer(self.body))
##    def Runtime(self):
##        return Type(self.width, self.signed, self.numPtrs)
    def IsBasicInt(self):
        return type(self.body) == Int


def AlignOf(bitwidth):
    if bitwidth == 1: return 1
    if bitwidth <= 32:
        return 1<<int(log2(bitwidth-1)+1)
    else:
        return RoundUp(bitwidth, 32)

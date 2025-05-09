from lark import Lark, Token, Tree
import LowerHLIR2 as LHL
import LowerLLIR3 as LLL
import AssemblerV3 as ASM
from math import log2
import sys
import os
import pyperclip
##from Statics import *
from Statics import Type, Var, NoVar, AlignOf, Void, Comp, Int, Struct, PTRWIDTH
import Statics
import LLOptimizer
import inspect

####################################################################################################

def __CALL_LINE__() -> int:
    return inspect.currentframe().f_back.f_back.f_lineno

def __SMART_CALL_LINE__() -> int:
    frame = inspect.currentframe().f_back.f_back
    name = frame.f_code.co_name
    while name in ['inner', '<lambda>']:
        frame = frame.f_back
        name = frame.f_code.co_name
    return frame.f_lineno

def __CALL_NAME__() -> str:
    frame = inspect.currentframe().f_back.f_back
    name = frame.f_code.co_name
    while name == 'inner':
        frame = frame.f_back
        name = frame.f_code.co_name
    return name

WarnAsErr = False
CensAsWarn = False
TodoAsErr = True
TodoFuncName = True

class CompileError(Exception):
    pass

class _Warning(CompileError):
    pass

class _Censure(CompileError):
    pass

class _Error(CompileError):
    pass

def Warn(tree, msg = ...):
    if msg == ...:
        msg = _
    msg += f' (Py-{__SMART_CALL_LINE__()})'
    if WarnAsErr: raise _Warning(msg)
    if msg != ...: PrintTokenSource(tree)
    print(f'Warning: {msg}\n\n')

def Censure(tree, msg = ...):
    nosrc = False
    if msg == ...:
        msg = tree
        nosrc = True
    msg += f' (Py-{__SMART_CALL_LINE__()})'
    if not CensAsWarn: raise _Censure(msg)
    if not nosrc: PrintTokenSource(tree)
    print(f'Censure: {msg}\n\n')

def Error(_, msg = ...):
    if msg == ...:
        msg = _
    msg += f' (Py-{__SMART_CALL_LINE__()})'
    raise _Error(msg)

if TodoAsErr:
    if TodoFuncName:
        TODO = lambda _: Error(_, f'TODO: `{__CALL_NAME__()}`')
    else:
        TODO = lambda _: Error(_, f'TODO')
else:
    def TODO(*args):
        raise NotImplementedError

####################################################################################################

parser = Lark.open("LLPC_grammar2.lark", rel_to=__file__, parser="lalr", propagate_positions = True)

usesRd = ['[]=', '[:]=', '@stchr', '@st', '@sta', '@stw', '@wrf']
nullret = ['@susp', '@rstkey', '@nop', '@use', '@mkd', '@rmd', '@clf', '@rmf', '@rnf']

####################################################################################################

def GetBackingStr(tree):
    start = tree.meta.start_pos
    end = tree.meta.end_pos
    return txt[start:end]

def TreeToName(tree):
    return MapRawName(GetBackingStr(tree))

def MapRawName(name):
    return 'u_'+name.replace('_', '__')

def TreeToKind(kind):
    rawType = Type(GetBackingStr(kind))
    def RenameStructs(obj):
        if type(obj) == Struct:
            obj.name = MapRawName(obj.name)
    rawType.TraverseChildren(RenameStructs)
    return rawType

def GetStrKind(kind):
    return str(TreeToKind(kind))

def IsRule(data, expected):
    assert type(data) == Token, f'Expected data to be `Token`, not `{type(data)}`; Data = `{data}`'
    return data.type == 'RULE' and data.value == expected

def IsTree(tree, expected):
    assert type(tree) == Tree, f'{type(tree)=}'
    data = tree.data
    assert IsRule(data, expected), f'{data=}'
    return data

####################################################################################################

def TrackLine(func):
    global srcs
    def inner(*args, **kwargs):
        ret = func(*args, **kwargs)
##        for i, block in enumerate(inter.func['body']):
##            for j, line in enumerate(block.body):
##                nsrc = func.__name__
##                if type(args[0]) == Tree:
##                    nsrc = nsrc + f'({args[0].meta.start_pos}, {args[0].meta.end_pos})'
##                if line[-2] != 'src':
##                    srcs.append([nsrc])
####                    inter.func['body'][i].body[j] = line + ('src', len(srcs)-1,)
##                else:
##                    src = line[-1]
##                    srcs[src].append(nsrc)
        return ret
    return inner

def PrintTokenSource(tree):
    global FAILEDLINE
    start = tree.meta.start_pos
    end = tree.meta.end_pos
    line = txt[:start].count('\n')
    if '\n//NEWFILEBEGIN `' in txt[:start]:
        ntxt = txt[:start]
        while '\n//NEWFILEBEGIN `' in ntxt:
            idx = ntxt.index('\n//NEWFILEBEGIN `')
            ntxt=ntxt[idx+1:]
        if '\n//NEWFILEEND `' in ntxt:
            qf = ''
        else:
            fileline = ntxt.split('\n')[0]
            fline = txt[:txt.index(fileline)].count('\n')
            line -= fline + 2
            qf = f' in {fileline.split("`")[1]}'
    else:
        qf = ''
    pline = txt[:start].split('\n')[-1]
    body = txt[start:].split('\n')[0]
    body = pline + body
    if FAILEDLINE != body:
        FAILEDLINE = body
        print(f'Error on line {line+1}{qf}:\n  ' + body.lstrip(' \t'))
        print(f'  ' + ' '*len(pline.lstrip(' \t'))+'^'*min((end-start), len(body)-len(pline)))

def logerror(func):
    def inner(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except:
            if len(args) > 1:
                tree = args[1]
            else:
                tree = args[0]
            if tree == None: raise
            PrintTokenSource(tree)
            raise
    return inner

FAILEDLINE = None

####################################################################################################

class Value():
    def __init__(self, var: Var):
        self.var = var
    def __repr__(self):
        return f'Value({self.var!r})'

class Location():
    def __init__(self, addr: Var|None, kind: Type, offset: Var|None = None):
        self.addr = addr
        self.offset = offset
        if type(kind) != Type:
            kind = Type(kind)
        self.kind = kind
    def __repr__(self):
        return f'Location({self.addr!r}'+f', {self.kind!r}, {self.offset!r}'*(self.offset!=None)+')'

    def Copy(self):
        return Location(self.addr, self.kind, self.offset)

    def Offset(self, inter, delta: Var):
        nself = self.Copy()
        if delta.kind.comptime:
            if nself.offset == None:
                nself.offset = delta
            else:
                nself.offset = Var(nself.offset.name + delta.name, Comp())
##                nself.offset.name += delta.name
        else:
            newtmp = NewTemp(inter, Type('u32'))
            inter.AddPent('+', newtmp, nself.addr, delta, None)
            nself.addr = newtmp
        return nself

    def Retype(self, newtype: Type):
        nself = self.Copy()
        nself.kind = newtype
        return nself

    def ToValue(self, inter):
        if self.addr.name.endswith('.&'):
            rawname = self.addr.name.removesuffix('.&')
            if self.offset == None or self.offset.name == 0:
                return Value(Var(rawname, self.kind.Deref()))
            res = NewTemp(inter, self.kind)
            inter.AddPent('=[:]', res, rawname, self.offset, self.kind.OpWidth())
            return Value(res)
        res = NewTemp(inter, self.kind)
        if self.offset == None:
            self.offset = Var(0, Comp())
        inter.AddPent('=[]', res, self.addr, self.offset, self.kind.Deref().OpWidth())
        return Value(res)

    def Deref(self, inter):
        if self.addr.name.endswith('.&'):
            rawname = self.addr.name.removesuffix('.&')
            if self.offset == None or self.offset.name == 0:
                return Location(Var(rawname, self.kind), self.kind.Deref())
        res = NewTemp(inter, self.kind)
        if self.offset == None:
            self.offset = Var(0, Comp())
        inter.AddPent('+', res, self.addr, self.offset, None)
        return Location(res, self.kind.Deref())

    def EmitAssg(self, inter, val):
        if self.addr.name.endswith('.&'):
            rawname = self.addr.name.removesuffix('.&')
            if self.offset == None:
                self.offset = Var(0, Comp())
            inter.AddPent('[:]=', Var(rawname, self.kind), val, self.offset, self.kind.OpWidth())
            return
        inter.AddPent('[]=', self.addr, self.offset, val, self.kind.Deref().OpWidth())
        
        

####################################################################################################

def Gen_Start(tree):
    assert type(tree) == Tree
    data = tree.data
    assert IsRule(data, 'start'), f'{data=}'

    return Gen_Unit(tree.children[0])


def Gen_Unit(tree):
    assert type(tree) == Tree, f'{type(tree)}='
    data = tree.data
    assert IsRule(data, 'tl_unit'), f'{data=}'

    inter = HLIR()

    for exdecl in tree.children:
        Prep_ExDecl(inter, exdecl)

##    print(f'{FormatDict(Statics.structs)}')
    ResolveTypes()
##    print(f'{FormatDict(Statics.structs)}')
    
    for exdecl in tree.children:
        Gen_ExDecl(inter, exdecl)
    return inter


#@logerror
#@TrackLine
def Prep_ExDecl(inter, tree):
    data = IsTree(tree, 'ex_decl')

    child ,= tree.children
    assert type(child) == Tree
    data = child.data
    
    if IsRule(data, 'namespace'):      Prep_Namespace(inter, child)
    elif IsRule(data, 'using_stmt'):   pass
    elif IsRule(data, 'struct_decl'):  Prep_StructDecl(inter, child)
    elif IsRule(data, 'fn_decl'):      Prep_FnDecl(inter, child)
    elif IsRule(data, 'global_decl'):  Prep_GlobalDecl(inter, child)
    else: assert False, f'Unreachable'

  
#@logerror
#@TrackLine
def Gen_ExDecl(inter, tree):
    data = IsTree(tree, 'ex_decl')

    child ,= tree.children
    assert type(child) == Tree
    data = child.data
    
    if IsRule(data, 'namespace'):      Gen_Namespace(inter, child)
    elif IsRule(data, 'using_stmt'):   Gen_UsingStmt(inter, child)
    elif IsRule(data, 'struct_decl'):  Gen_StructDecl(inter, child)
    elif IsRule(data, 'fn_decl'):      Gen_FnDecl(inter, child)
    elif IsRule(data, 'global_decl'):  Gen_GlobalDecl(inter, child)
    else: assert False, f'Unreachable'


@logerror
@TrackLine
def Prep_Namespace(inter, tree):
    _, name, _, body, _ = tree.children
    name = TreeToName(name)
    IsTree(body, f'tl_unit')
    inner = Gen_Unit(body)
    print(inner)
    Warn(tree, f'Namespaces are incomplete')
    


@logerror
@TrackLine
def Prep_StructDecl(inter, tree):
    exp, _, name, _, _args, _, = tree.children
    fns = _args.children[1:-1]
    args = _args.children[0]
    name = TreeToName(name)
    assert _args.children[-1] == None

    for fn in fns:
        Prep_FnDecl(inter, fn, fn_pref = name)

    self = Statics.structs[name] = {'size': ..., 'args': {}}

    for arg in args.children:
        if type(arg) != Tree: continue
        argname, _, argkind = arg.children
        argname = TreeToName(argname)
        assert argname not in self['args']
        self['args'][argname] = {'offset': ..., 'width': ..., 'type': argkind}


@logerror
@TrackLine
def Prep_FnDecl(inter, tree, fn_pref = None):
    exp, _, name, _, rawargs, _, ret, _ = tree.children
    if fn_pref != None:
        name = MapRawName(fn_pref+':'+name.children[0].value)
    else:
        name = TreeToName(name)
    
    args = []
    if rawargs:
        for arg in rawargs.children:
            if type(arg) == Token: continue
            argname, _, argkind = arg.children
            newarg = Var(TreeToName(argname), TreeToKind(argkind))
            args.append(newarg)
    ret = TreeToKind(ret)
    funcs[name] = (args, ret)


@logerror
@TrackLine
def Prep_GlobalDecl(inter, tree):
    TODO(...)


@logerror
@TrackLine
def Gen_Namespace(inter, tree):
    Warn(tree, 'Generate Namespace maybe does nothing???')
##    TODOO(...)


@logerror
@TrackLine
def Gen_UsingStmt(inter, tree):
    TODO(...)

@logerror
@TrackLine
def Gen_StructDecl(inter, tree):
    exp, _, name, _, _args, _, = tree.children
    fns = _args.children[1:-1]
    name = TreeToName(name)
    assert _args.children[-1] == None
    for fn in fns:
        Gen_FnDecl(inter, fn, fn_pref = name)


@logerror
@TrackLine
def Gen_FnDecl(inter, tree, fn_pref = None):
    exp, _, name, _, _, _, _, body = tree.children
    if fn_pref != None:
        name = MapRawName(fn_pref+':'+name.children[0].value)
    else:
        name = TreeToName(name)
    
    (args, ret) = funcs[name]

    inter.NewFunc(name, args, ret)
    for i, arg in enumerate(args):
        inter.AddPent('argld', arg, Var.FromVal(inter, i), None, None)
    Gen_Stmt(inter, body)
    inter.PopEnv()
    inter.EndFunc()


@logerror
@TrackLine
def Gen_GlobalDecl(inter, tree):
    TODO(...)


#@logerror
#@TrackLine
def Gen_Stmt(inter, tree):
    child ,= tree.children
    assert type(child) == Tree
    data = child.data
    
    if IsRule(data, 'blockstmt'):       Gen_BlockStmt(inter, child)
    elif IsRule(data, 'declexpr'):      Gen_DeclExpr(inter, child)
    elif IsRule(data, 'declstmt'):      Gen_DeclStmt(inter, child)
    elif IsRule(data, 'exprstmt'):      Gen_ExprStmt(inter, child)
    elif IsRule(data, 'jumpstmt'):      Gen_JumpStmt(inter, child)
    elif IsRule(data, 'iterstmt'):      Gen_IterStmt(inter, child)
    elif IsRule(data, 'selstmt'):       Gen_SelStmt(inter, child)
    elif IsRule(data, 'assumestmt'):    Gen_AssumeStmt(inter, child)
    else: assert False, f'Unreachable. Data = {data}'


@logerror
@TrackLine
def Gen_BlockStmt(inter, tree):
    stmts = tree.children[1:-1]
    inter.NewEnv()
    for stmt in stmts:
        Gen_Stmt(inter, stmt)
    inter.PopEnv()

@logerror
@TrackLine
def Gen_DeclExpr(inter, tree):
    _, name, _, kind, _, expr, _, = tree.children
    idx = len(inter.body.body)
    rhs = Rvalue(inter, expr).var
    name = TreeToName(name)
    if kind:
        kind = TreeToKind(kind)
    else:
        kind = rhs.kind
    
    assert rhs.kind.CanCoerceTo(kind), f'Type `{rhs.kind}` cannot coerce into type `{kind}`'
    assert not kind.comptime, f'Cannot instantiate variable `{name}` with comptime val `{rhs.name}`'

    inter.Decl(name, kind, idx)
    addr = addr = Var(name+'.&', Comp())
    lhs = Location(addr, kind)
    lhs.EmitAssg(inter, rhs)

@logerror
@TrackLine
def Gen_DeclStmt(inter, tree):
    _, name, _, kind, _, = tree.children
    kind = TreeToKind(kind)
    name = TreeToName(name)
    assert not kind.comptime, f'Cannot instantiate variable `{name}` with comptime type'
    inter.Decl(name, kind)


@logerror
@TrackLine
def Gen_ExprStmt(inter, tree):
    expr, _, = tree.children
    if expr:
        return Rvalue(inter, expr.children[0])

@logerror
@TrackLine
def Gen_ExprNoSemi(inter, tree):
    return Rvalue(inter, tree)

@logerror
@TrackLine
def Gen_JumpStmt(inter, tree):
    child ,= tree.children
    assert type(child) == Tree
    data = child.data
    
    if data == 'continue':      return Gen_Continue(inter, child)
    elif data == 'break':       return Gen_Break(inter, child)
    elif data == 'return':      return Gen_Return(inter, None)
    elif data == 'returnexpr':  return Gen_Return(inter, child)
    else: assert False, f'Unreachable, {data=}'

@logerror
@TrackLine
def Gen_IterStmt(inter, tree):
    child ,= tree.children
    assert type(child) == Tree
    data = child.data
    
    if data == 'forstmt':      return Gen_For(inter, child)
    elif data == 'whilestmt':  return Gen_While(inter, child)
    else: assert False, f'Unreachable, {data=}'


@logerror
@TrackLine
def Gen_SelStmt(inter, tree):
    child ,= tree.children
    assert type(child) == Tree
    data = child.data
    
    if data == 'ifstmt': return Gen_If(inter, child)
    else: assert False, f'Unreachable, {data=}'


@logerror
@TrackLine
def Gen_AssumeStmt(inter, tree):
    TODO(...)

####################################################################################################

@logerror
@TrackLine
def Gen_Continue(inter, tree):
    assert len(inter.loops) > 0, f'Cannot continue from no loop'
    top, bot = inter.loops[-1]
    inter.Jump(top)

@logerror
@TrackLine
def Gen_Break(inter, tree):
    assert len(inter.loops) > 0, f'Cannot continue from no loop'
    top, bot = inter.loops[-1]
    inter.Jump(bot)

@logerror
@TrackLine
def Gen_Return(inter, tree):
    if tree != None:
        inter.Return(Rvalue(inter, tree.children[1]).var)
    else:
        inter.Return()

####################################################################################################

@logerror
@TrackLine
def Gen_For(inter, tree):
    #[DO] FOR LPAREN stmt exprstmt encexprsmt RPAREN stmt [ELSE stmt]
    do, _, _, preexpr, condexpr, postexpr, _, bodyexpr, _else, elseexpr = tree.children
    #[do] for (e0; e1; e2) e3 else e4
    #--------
    #  e0
    #if (not DO) jmp condition
    #body:
    #  e3
    #  e2
    #condition:
    #  e1
    #  c.jmp body
    #else:
    #  e4
    #then:
    
    lbl_body = NewLabel()
    lbl_cond = NewLabel()
    lbl_else = NewLabel()
    lbl_then = NewLabel()

    inter.NewEnv()
    
    inter.PushLoopLabels(lbl_cond, lbl_then) #If continue, go to condition, if break, skip to then

    #PRE
    Gen_Stmt(inter, preexpr)
    if do != None:
        inter.Jump(lbl_cond)

    #BODY
    inter.AddLabel(lbl_body)
    Gen_Stmt(inter, bodyexpr)
    if type(postexpr.children[0]) == Tree:
        Gen_ExprNoSemi(inter, postexpr)
    inter.Jump(lbl_cond)

    #COND
    inter.trues.append(lbl_body) #On True condition test, go to body
    inter.falses.append(lbl_else) #On false go to else
    inter.AddLabel(lbl_cond)
    assert len(inter.trues) == 1, f'Len(Trues) should be 1, got {inter.trues}'
    assert len(inter.falses) == 1, f'Len(Falses) should be 1, got {inter.falses}'
    cond = Gen_ExprStmt(inter, condexpr)
    inter.trues = []; inter.falses = []
    if cond and cond.var.name:
        inter.CJump(cond, lbl_else)

    inter.PopLoopLabels(lbl_cond, lbl_then) #Once we exit the main loop, disallow pop our loop stack

    #ELSE
    inter.AddLabel(lbl_else)
    if _else != None:
        Gen_Stmt(inter, elseexpr)

    inter.AddLabel(lbl_then)

    inter.PopEnv()

@logerror
@TrackLine
def Gen_While(inter, tree):
    TODO(...)

@logerror
@TrackLine
def Gen_If(inter, tree):
    #IF LPAREN expr RPAREN stmt [ELSE stmt]
    _, _, condexpr, _, bodyexpr, _else, elseexpr = tree.children
    lbl_true = NewLabel()
    lbl_false = NewLabel()
    lbl_then = NewLabel()

    inter.trues.append(lbl_true) 
    inter.falses.append(lbl_false)
    
    cond = Gen_ExprNoSemi(inter, condexpr)
    inter.trues.pop(-1); inter.falses.pop(-1)
    if cond and cond.var.name:
        inter.CJump(cond, lbl_else)

    inter.AddLabel(lbl_true)
    Gen_Stmt(inter, bodyexpr)

    inter.AddLabel(lbl_false)
    if _else != None:
        Gen_Stmt(inter, elseexpr)

    inter.AddLabel(lbl_then)
    
##    TODO(...)

####################################################################################################

def _Rvalue(inter, tree) -> Value:
    data = tree.data

    if data == 'indexpr':       return L_Index(inter, tree)
    elif data == 'derefexpr':   return L_Deref(inter, tree)
    elif data == 'structinit':  return L_StructInit(inter, tree)
    elif data == 'colonexpr':   Error(f'Cannot take R-Value of type {data}')
    elif data == 'addrexpr':    return R_Addr(inter, tree)
    elif data == 'breakpoint':  return R_Breakpoint(inter, tree)
    elif data == 'sliceexpr':   return L_Slice(inter, tree)
    elif data == 'fieldexpr':   return L_Field(inter, tree)
    elif data == 'callexpr':    return R_Call(inter, tree)
    elif data == 'intrinsic':   return R_Intrinsic(inter, tree)
    elif data == 'true':        return R_Bool(inter, tree, True)
    elif data == 'false':       return R_Bool(inter, tree, False)
    elif data == 'overflow':    return R_Flag(inter, tree, 'overflow')
    
    if IsRule(data, 'assgexpr'):     return L_Assg(inter, tree)
    elif IsRule(data, 'lorexpr'):    return R_Log_Or(inter, tree)
    elif IsRule(data, 'landexpr'):   return R_Log_And(inter, tree)
    elif IsRule(data, 'lunaryexpr'): return R_Log_Unary(inter, tree)
    elif IsRule(data, 'relexpr'):    return R_Rel(inter, tree)
    elif IsRule(data, 'broexpr'):    return R_Bin_Or(inter, tree)
    elif IsRule(data, 'bxorexpr'):   return R_Bin_Xor(inter, tree)
    elif IsRule(data, 'bandexpr'):   return R_Bin_And(inter, tree)
    elif IsRule(data, 'addexpr'):    return R_Add(inter, tree)
    elif IsRule(data, 'mulexpr'):    return R_Mul(inter, tree)
    elif IsRule(data, 'castexpr'):   return L_Cast(inter, tree)
    elif IsRule(data, 'unaryexpr'):  return R_Unary(inter, tree)
    elif IsRule(data, 'postexpr'):   return R_Post(inter, tree)
    elif IsRule(data, 'primexpr'):   return R_Prime(inter, tree)
    elif IsRule(data, 'constant'):   return R_Constant(inter, tree)
    else: assert False, f'Unreachable, {data=}'

def _Lvalue(inter, tree) -> Location:
    data = tree.data

    if data == 'indexpr':       return L_Index(inter, tree)
    elif data == 'derefexpr':   return L_Deref(inter, tree)
    elif data == 'structinit':  Error(f'Cannot take L-Value of type {data}')
    elif data == 'colonexpr':   Error(f'Cannot take L-Value of type {data}')
    elif data == 'addrexpr':    Error(f'Cannot take L-Value of type {data}')
    elif data == 'breakpoint':  Error(f'Cannot take L-Value of type {data}')
    elif data == 'sliceexpr':   return L_Slice(inter, tree)
    elif data == 'fieldexpr':   return L_Field(inter, tree)
    elif data == 'callexpr':    Error(f'Cannot take L-Value of type {data}')
    elif data == 'intrinsic':   Error(f'Cannot take L-Value of type {data}')
    elif data == 'true':        Error(f'Cannot take L-Value of type {data}')
    elif data == 'false':       Error(f'Cannot take L-Value of type {data}')
    elif data == 'overflow':    Error(f'Cannot take L-Value of type {data}')

    elif IsRule(data, 'ident'):   return L_Ident(inter, tree)
    Error(f'Cannot take L-Value of type {data.value}')

####################################################################################################

def Rvalue(inter, tree) -> Value:
    ret = Gen_Value(inter, tree)
    if type(ret) == Location:
        ret = ret.ToValue(inter)
    assert type(ret) == Value, (f'Cannot coerce `{ret}`({type(ret)}) to Value')
    return ret

def Lvalue(inter, tree) -> Location:
    ret = Gen_Value(inter, tree)
    if type(ret) == Value:
        _Error(f'Cannot coerce Value `{ret}` to Location')
    assert type(ret) == Location, (f'Cannot coerce Value `{ret}`({type(ret)}) to Location')
    return ret

def Gen_Value(inter, tree) -> Location|Value:
    data = tree.data
    
    if data == 'indexpr':       return L_Index(inter, tree)
    elif data == 'derefexpr':   return L_Deref(inter, tree)
    elif data == 'structinit':  return L_StructInit(inter, tree)
    elif data == 'colonexpr':   Error(f'Cannot take R-Value of type {data}')
    elif data == 'addrexpr':    return R_Addr(inter, tree)
    elif data == 'breakpoint':  return R_Breakpoint(inter, tree)
    elif data == 'sliceexpr':   return L_Slice(inter, tree)
    elif data == 'fieldexpr':   return L_Field(inter, tree)
    elif data == 'callexpr':    return R_Call(inter, tree)
    elif data == 'intrinsic':   return R_Intrinsic(inter, tree)
    elif data == 'true':        return R_Bool(inter, tree, True)
    elif data == 'false':       return R_Bool(inter, tree, False)
    elif data == 'overflow':    return R_Flag(inter, tree, 'overflow')

    if   IsRule(data, 'expr'):       return Gen_Value(inter, tree.children[0])
    elif IsRule(data, 'encexprsmt'):   return Gen_Value(inter, tree.children[0])
    elif IsRule(data, 'assgexpr'):   return L_Assg(inter, tree)
    elif IsRule(data, 'lorexpr'):    return R_Log_Or(inter, tree)
    elif IsRule(data, 'landexpr'):   return R_Log_And(inter, tree)
    elif IsRule(data, 'lunaryexpr'): return R_Log_Unary(inter, tree)
    elif IsRule(data, 'relexpr'):    return R_Rel(inter, tree)
    elif IsRule(data, 'broexpr'):    return R_Bin_Or(inter, tree)
    elif IsRule(data, 'bxorexpr'):   return R_Bin_Xor(inter, tree)
    elif IsRule(data, 'bandexpr'):   return R_Bin_And(inter, tree)
    elif IsRule(data, 'addexpr'):    return R_Add(inter, tree)
    elif IsRule(data, 'multexpr'):    return R_Mul(inter, tree)
    elif IsRule(data, 'castexpr'):   return X_Cast(inter, tree)
    elif IsRule(data, 'unaryexpr'):  return R_Unary(inter, tree)
    elif IsRule(data, 'postexpr'):   return R_Post(inter, tree)
    elif IsRule(data, 'primexpr'):   return R_Prime(inter, tree)
    elif IsRule(data, 'constant'):   return R_Constant(inter, tree)
    elif IsRule(data, 'ident'):      return L_Ident(inter, tree)
    elif IsRule(data, 'string'):     return R_String(inter, tree)
    else: assert False, f'Unreachable, {data=}'

####################################################################################################

@logerror
@TrackLine
def R_SimpleBinary(inter, expr):
    le, op, bt, re = expr.children
    lhs = Rvalue(inter, le).var
    rhs = Rvalue(inter, re).var
    op = op.children[0].value
    kind = lhs.kind.Common(rhs.kind)
    tmp = NewTemp(inter, kind)
    inter.AddPent(op = op, D = tmp, S0 = lhs, S1 = rhs, S2 = None, sticky = bt != None)
    return Value(tmp)

@logerror
@TrackLine
def R_Log_Or(inter, expr):
    lhs, _, rhs = expr.children
    lbl = NewLabel()
    inter.falses.append(lbl)
    Rvalue(inter, lhs)
    inter.AddLabel(lbl)
    del inter.falses[-1]
    Rvalue(inter, rhs)
    return Value(Var(None, Type(Statics.Bool())))

@logerror
@TrackLine
def R_Log_And(inter, expr):
    lhs, _, rhs = expr.children
    lbl = NewLabel()
    inter.trues.append(lbl)
    Rvalue(inter, lhs)
    inter.AddLabel(lbl)
    del inter.trues[-1]
    Rvalue(inter, rhs)
    return Value(Var(None, Type(Statics.Bool())))

@logerror
@TrackLine
def R_Log_Unary(inter, expr):
    TODO(...)

@logerror
@TrackLine
def R_Rel(inter, expr):
    le, op, re = expr.children
    lhs = Rvalue(inter, le).var
    rhs = Rvalue(inter, re).var
    op = op.children[0].value
    assert lhs.kind.CanCoerceTo(rhs.kind) or rhs.kind.CanCoerceTo(lhs.kind), f'Cannot do comparison on uncoerceable types `{lhs.kind}` and `{rhs.kind}`'
    if op in ['>', '>=', '<=', '<']:
        if type(lhs.kind.body) == Int:
            signed = lhs.kind.signed
        elif type(rhs.kind.body) == Int:
            signed = rhs.kind.signed
        else: assert False, f'Comparison of non-numbers {lhs}({type(lhs.kind.body)}) and {rhs}({type(rhs.kind.body)})'
        inter.IfJump(lhs, '+-'[signed]+op, rhs, inter.trues[-1])
    else:
        inter.IfJump(lhs, op, rhs, inter.trues[-1])
    inter.Jump(inter.falses[-1])
    return Value(Var(None, Type(Statics.Bool())))

@logerror
@TrackLine
def R_Bin_Or(inter, expr):
    return R_SimpleBinary(inter, expr)

@logerror
@TrackLine
def R_Bin_Xor(inter, expr):
    return R_SimpleBinary(inter, expr)

@logerror
@TrackLine
def R_Bin_And(inter, expr):
    return R_SimpleBinary(inter, expr)

@logerror
@TrackLine
def R_Add(inter, expr):
    return R_SimpleBinary(inter, expr)

@logerror
@TrackLine
def R_Mul(inter, expr):
    return R_SimpleBinary(inter, expr)

@logerror
@TrackLine
def R_Unary(inter, expr):
    TODO(...)

@logerror
@TrackLine
def R_Post(inter, expr):
    TODO(...)

@logerror
@TrackLine
def R_Prime(inter, expr):
    child = expr.children[0]
    if type(expr.children[0]) == Token: #Parenthesis
        child = expr.children[1]
    return Gen_Value(inter, child)
##    print(f'{expr.children[0]=}')
##    TODO(...)

@logerror
@TrackLine
def R_Colon(inter, expr):
    TODO(...)

@logerror
@TrackLine
def R_Addr(inter, expr):
    TODO(...)

@logerror
@TrackLine
def R_Breakpoint(inter, expr):
    TODO(...)

@logerror
@TrackLine
def R_Call(inter, expr):
    func, _, args, _ = expr.children
    prearg = None
    prefu = False

    func = TreeToName(func)
    if func.count(':') == 1:
        l, r = func.split(':')
        if l in Statics.structs:
            prearg = None
            func = MapRawName(l+':'+r)
            prefu = True
        else:
            prearg = inter.LookupVar(l)
            func = str(inter.LookupVar(l).kind).replace('*','').split('[')[0]+':'+r
            prefu = True
    elif func.count(':') > 1: Censure('Violation of naming rules, use only 1 `:` in a method name to indicate root class')

    if args:
        nargs = []
        for arg in args.children:
            if type(arg)==Tree:
                v = Rvalue(inter, arg).var
                assert type(v) == Var, f'{v=}; {arg=}'
                nargs.append(v)
        args = nargs
    else:
        args = []
    if prearg:
        args.insert(0, prearg)
    if not func in funcs: Error(f'Cannot find function name `{func}` of any:\n  {"\n  ".join(funcs)}')
##    print(f'Found `{func}`')
    funargs, funret = funcs[func]
    assert len(funargs) == len(args), f'Function `{func}` has arity `{len(funargs)}`, but was given `{len(args)}` args'
    for i, arg in enumerate(args):
        inter.AddPent('argst', Var.FromVal(inter, i), arg, None, None)
    inter.AddPent('call', Var(func, Type()), None, None, None)
    tmp = NewTemp(inter, funret)
    inter.AddPent('retld', tmp, Var.FromVal(inter, 0), None, None)
    return Value(tmp)

@logerror
@TrackLine
def R_Intrinsic(inter, expr):
    _, name, _, args, _, = expr.children
    name = '@' + GetBackingStr(name)
    ct = False
    if args:
        ct=True
        nargs = []
        for arg in args.children:
            if type(arg)==Tree:
                var = Rvalue(inter, arg).var
                nargs.append(var)
                if not var.kind.comptime:
                    ct = False
        args = nargs
    else:
        args = []

    if name in usesRd:
        if len(args) != 4: Error(f'Intrinsic function takes 4 arguments')
        inter.AddPent(op = name, D = args[0], S0 = args[1], S1 = args[2], S2 = args[3])
        return Value(NoVar)
    else:
        if len(args) > 3: Error(f'Intrinsic functions do not support more than 3 arguments')
        args += [None]*4
        tk = Type(Statics.Comptime() if ct else Statics.Int(32, False))
        tmp = NewTemp(inter, tk)
        inter.AddPent(op = name, D = tmp, S0 = args[0], S1 = args[1], S2 = args[2])
        return Value(tmp)

@logerror
@TrackLine
def R_Bool(inter, expr, value):
    TODO(...)

@logerror
@TrackLine
def R_Flag(inter, expr, flag_type):
    TODO(...)

@logerror
@TrackLine
def R_Constant(inter, expr):
    return Value(Var(eval(GetBackingStr(expr)), Type(Comp())))

@logerror
@TrackLine
def R_String(inter, expr):
    val = eval(GetBackingStr(expr))
    ref = inter.AddString(val)
    return Value(Var(ref, Statics.Pointer(Int(8, False))))

##############################

@logerror
@TrackLine
def L_StructInit(inter, expr):
    k, _, args, _, = expr.children
    kind = TreeToKind(k)
    tmp = NewTemp(inter, kind)
    kind = str(kind)

    addr = Var(tmp.name+'.&', Comp())
    tmploc = Location(addr, kind)

    if args:
        nargs = []
        for arg in args.children:
            if type(arg)==Tree:
                v = Rvalue(inter, arg.children[2])
                nargs.append((TreeToName(arg.children[0]), v))
        args = nargs
    else: args = []
    
    for i, (arg, val) in enumerate(args):
        
        field = arg
        fieldargs = Statics.structs[kind]['args'][field]    
        off = fieldargs['offset']
        desttype = fieldargs['type']

        nlhs = tmploc.Offset(_, Var(off, Comp())).Retype(desttype)
        
        nlhs.EmitAssg(inter, val)
    return tmploc

@logerror
@TrackLine
def L_Assg(inter, expr):
    le, op, bt, re = expr.children
    lhs = Lvalue(inter, le)
    rhs = Rvalue(inter, re).var
    if len(op.children[0].value) >= 2:
        op = op.children[0].value[:-1]
        assert rhs.kind.CanCoerceTo(lhs.kind)
        rlhs = Rvalue(inter, le).var
        kind = rlhs.kind.Common(rhs.kind)
        tmp = NewTemp(inter, kind)
        inter.AddPent(op = op, D = tmp, S0 = rlhs, S1 = rhs, S2 = None, sticky = bt)
        lhs.EmitAssg(inter, tmp)
    else:
        assert rhs.kind.CanCoerceTo(lhs.kind), f'Cannot coerce `{rhs.kind}` into type `{lhs.kind}`'
        lhs.EmitAssg(inter, rhs)
    return lhs


@logerror
@TrackLine
def L_Ident(inter, expr):
    lhs = inter.LookupVar(TreeToName(expr))
    addr = Var(lhs.name+'.&', Statics.Pointer(lhs.kind))
    return Location(addr, Statics.Pointer(lhs.kind))

@logerror
@TrackLine
def L_Index(inter, expr):
    le, _, re, _, = expr.children
    rhs = Rvalue(inter, re).var
    lhs = Rvalue(inter, le).var
    print(f'{lhs=}; {type(lhs)=}; {le=}')
    prod = NewTemp(inter, Type(Int(PTRWIDTH, False)))
    inter.AddPent(op = '*', D = prod, S0 = rhs, S1 = Var.FromVal(inter, lhs.kind.Deref().OpWidth()), S2 = None)
    EvictAliasFor(inter, lhs.kind)
    return Location(lhs, lhs.kind).Offset(inter, Var(prod.name, Int(32, False)))
    #return lhs.Deref(inter).Offset(inter, Var(prod.name, Int(32, False)))

@logerror
@TrackLine
def L_Slice(inter, expr):
    #postexpr LBRACK expr PLUSCOLON expr RBRACK
    le, _, off, _, width, _, = expr.children
    lhs = Lvalue(inter, le)
    if type(lhs.kind.body) != Int: Censure(f'Can only bit slice unsigned integer types, not `{type(lhs.kind)}`')
    if lhs.kind.signed: Censure(f'Integer must be Unsigned for bitslices')
    off = Rvalue(inter, off).var
    width = Rvalue(inter, width).var
    if not width.kind.comptime: Error(f'Slice width must be comptime known')
    return lhs.Offset(inter, off).Retype(Int(width, False))

@logerror
@TrackLine
def L_Field(inter, expr):
    le, _, re, = expr.children
    lhs = Lvalue(inter, le)
    field = TreeToName(re)
    fieldargs = Statics.structs[str(lhs.kind)]['args'][field]    
    off = fieldargs['offset']
    desttype = fieldargs['type']

    assert off != ..., f'Struct `{lhs.kind!s}.{field!s}` has offset `...`'

    return lhs.Offset(_, Var(off, Comp())).Retype(desttype)

@logerror
@TrackLine
def L_Deref(inter, expr):
    le, _, _, = expr.children
    lhs = Lvalue(inter, le)
    EvictAliasFor(inter, lhs.kind.Deref())
    return lhs.Deref(inter)
##    return lhs.Retype(lhs.kind.Deref())

@logerror
@TrackLine
def X_Cast(inter, expr):
    lk, re, = expr.children
    lkind = TreeToKind(lk)
    rhs = Gen_Value(inter, re)
    if type(rhs) == Location:
        return Lvalue(inter, re).Retype(lkind)
    else:
        return Value(Var(rhs.var.name, lkind))
    

####################################################################################################

@logerror
@TrackLine
def Gen(tree, pre = True, fn_pref = None):
    global out, ind, inter, funcs, namespaces
    if type(tree) == Tree:
        data = tree.data
        if data == 'break':
            assert len(inter.loops) > 0, f'Cannot break out of no loop'
            top, bot = inter.loops[-1]
            inter.Jump(bot)
        elif data == 'continue':
            assert len(inter.loops) > 0, f'Cannot continue from no loop'
            top, bot = inter.loops[-1]
            inter.Jump(top)
        elif data == 'return':
            inter.Return()
        elif data == 'returnexpr':
            _, expr, _, = tree.children
            inter.Return(Rvalue(expr.children[0]))
        elif type(data) == str:
            assert False, f'Cannot generate shortnamed tree of name {data=}; {expr=}'
        
        elif data.type == 'RULE' and data.value == 'start':
            bds = []
            for child in tree.children:
                Gen(child)

            ResolveTypes()
            for child in tree.children:
                Gen(child, pre = False)

        elif data.type == 'RULE' and data.value == 'namespace':
##            _, x, _, b, _ = tree.children
            x = tree.children[1]
            b = tree.children[3:-1]
            namespaces.append(TreeToName(x))
            for child in b:
                Gen(child, pre=pre)
            del namespaces[-1]

        elif data.type == 'RULE' and data.value == 'ex_decl':
            Gen(tree.children[0], pre)
        elif data.type == 'RULE' and data.value == 'fn_decl':
            return
        elif data.type == 'RULE' and data.value == 'assumestmt':
            GenAssume(inter, tree.children[1])
        elif data.type == 'RULE' and data.value == 'declstmt':
            return
        elif data.type == 'RULE' and data.value == 'declexpr':
            _, name, _, kind, _, expr, _, = tree.children
            idx = len(inter.body.body)
            rhs = Rvalue(expr.children[0])
            name = TreeToName(name)
            if kind:
                kind = Type.FromStr(GetStrKind(kind))
                nak = Type(str(kind))
                while True:
                    if type(nak.body) == Statics.Pointer:
                        nak = nak.Deref()
                        continue
                    break
                if type(nak.body) == Statics.Struct:
                    kind = Type('::'.join(namespaces+[str(kind)]))
            else:
                kind = rhs.kind
            
            assert rhs.kind.CanCoerceTo(kind), f'Type `{rhs.kind}` cannot coerce into type `{kind}`'
            inter.Decl(name, kind, idx)
            assert rhs.kind.CanCoerceTo(kind)
            assert not kind.comptime, f'Cannot instantiate variable `{name}` with comptime val `{rhs.name}`'
            inter.AddPent(op = '=', D = Var(name, kind), S0 = rhs, S1 = None, S2 = None)
        elif data.type == 'RULE' and data.value == 'exprstmt':
            return
        elif data.type == 'RULE' and data.value == 'encexprstmt':
            if type(tree.children[0]) == Tree:
                _ = Rvalue(expr.children[0])
        elif data.type == 'RULE' and data.value == 'blockstmt':
            stmts = tree.children[1:-1]
            inter.NewEnv()
            for stmt in stmts:
                Gen(stmt)
            inter.PopEnv()
        elif data.type == 'RULE' and data.value == 'dostmt':
            _, _, expr, _, stmt = tree.children
            pre = NewLabel()
            inner = NewLabel()
            post = NewLabel()
            inter.PushLoopLabels(pre, post)
            inter.AddLabel(inner)
            Gen(stmt.children[0])
            inter.AddLabel(pre)
            inter.trues.append(inner)
            inter.falses.append(post)
            cond = Rvalue(expr.children[0])
            assert len(inter.trues) == 1, f'Len(Trues) should be 1, got {inter.trues}'
            assert len(inter.falses) == 1, f'Len(Falses) should be 1, got {inter.falses}'
            inter.trues = []; inter.falses = []
            if cond and cond.name:
                inter.CJump(cond, post)
            inter.Jump(inner)
            inter.PopLoopLabels(pre, post)
            inter.AddLabel(post)
        elif data.type == 'RULE' and data.value == 'doelsestmt':
            _, _, expr, _, stmt0, _, stmt1 = tree.children
            pre = NewLabel()
            inner = NewLabel()
            post = NewLabel()
            _else = NewLabel()
            inter.PushLoopLabels(pre, post)
            inter.AddLabel(inner)
            Gen(stmt0.children[0])
            inter.trues.append(inner)
            inter.falses.append(_else)
            inter.AddLabel(pre)
            cond, _ = Rvalue(expr.children[0])
            assert len(inter.trues) == 1, f'Len(Trues) should be 1, got {inter.trues}'
            assert len(inter.falses) == 1, f'Len(Falses) should be 1, got {inter.falses}'
            inter.trues = []; inter.falses = []
            if cond and cond.name:
                inter.CJump(cond, _else)
            inter.Jump(inner)
            inter.PopLoopLabels(pre, post)
            inter.AddLabel(_else)
            Gen(stmt1.children[0])
            inter.AddLabel(post)
        elif data.type == 'RULE' and data.value == 'whilestmt':
            _, _, expr, _, stmt = tree.children
            pre = NewLabel()
            inner = NewLabel()
            post = NewLabel()
            inter.trues.append(inner)
            inter.falses.append(post)
            inter.PushLoopLabels(pre, post)
            inter.AddLabel(pre)
            cond = Rvalue(expr.children[0])
            assert len(inter.trues) == 1, f'Len(Trues) should be 1, got {inter.trues}'
            assert len(inter.falses) == 1, f'Len(Falses) should be 1, got {inter.falses}'
            inter.trues = []; inter.falses = []
            if cond and cond.name:
                inter.CJump(cond, post)
            inter.AddLabel(inner)
            Gen(stmt.children[0])
            inter.Jump(pre)
            inter.PopLoopLabels(pre, post)
            inter.AddLabel(post)
        elif data.type == 'RULE' and data.value == 'whileelsestmt':
            _, _, expr, _, stmt0, _, stmt1 = tree.children
            pre = NewLabel()
            inner = NewLabel()
            post = NewLabel()
            _else = NewLabel()
            inter.trues.append(inner)
            inter.falses.append(_else)
            inter.PushLoopLabels(pre, post)
            inter.AddLabel(pre)
            cond, _ = Rvalue(expr.children[0])
            assert len(inter.trues) == 1, f'Len(Trues) should be 1, got {inter.trues}'
            assert len(inter.falses) == 1, f'Len(Falses) should be 1, got {inter.falses}'
            inter.trues = []; inter.falses = []
            if cond and cond.name:
                inter.CJump(cond, _else)
            inter.AddLabel(inner)
            Gen(stmt0.children[0])
            inter.Jump(pre)
            inter.PopLoopLabels(pre, post)
            inter.AddLabel(_else)
            Gen(stmt1.children[0])
            inter.AddLabel(post)
        elif data.type == 'RULE' and data.value == 'forelsestmt':
            _, _, preexpr, cond, postexpr, _, body, _, elseexpr = tree.children
            pre = NewLabel()
            inner = NewLabel()
            post = NewLabel()
            _else = NewLabel()
            inter.trues.append(inner)
            inter.falses.append(_else)
            inter.PushLoopLabels(pre, post)
            Gen(preexpr.children[0])
            inter.AddLabel(pre)
            cond = Rvalue(cond.children[0])
            assert len(inter.trues) == 1, f'Len(Trues) should be 1, got {inter.trues}'
            assert len(inter.falses) == 1, f'Len(Falses) should be 1, got {inter.falses}'
            inter.trues = []; inter.falses = []
            if cond and cond.name:
                inter.CJump(cond, _else)
            inter.AddLabel(inner)
            Gen(body.children[0])
            if type(postexpr.children[0]) == Tree:
                _ = Rvalue(postexpr.children[0])
            inter.Jump(pre)
            inter.PopLoopLabels(pre, post)
            inter.AddLabel(_else)
            Gen(elseexpr.children[0])
            inter.AddLabel(post)
        elif data.type == 'RULE' and data.value == 'forstmt':
            _, _, preexpr, cond, postexpr, _, body, = tree.children
            pre = NewLabel()
            inner = NewLabel()
            post = NewLabel()
            inter.trues.append(inner)
            inter.falses.append(post)
            inter.PushLoopLabels(pre, post)
            inter.NewEnv()
            Gen(preexpr.children[0])
            inter.AddLabel(pre)
            cond = Rvalue(cond.children[0])
            assert len(inter.trues) == 1, f'Len(Trues) should be 1, got {inter.trues}'
            assert len(inter.falses) == 1, f'Len(Falses) should be 1, got {inter.falses}'
            inter.trues = []; inter.falses = []
            if cond and cond.name:
                inter.CJump(cond, post)
            inter.AddLabel(inner)
            inter.NewEnv()
            Gen(body.children[0])
            if type(postexpr.children[0]) == Tree:
                _ = Rvalue(postexpr.children[0])
            inter.Jump(pre)
            inter.PopEnv()
            inter.PopEnv()
            inter.PopLoopLabels(pre, post)
            inter.AddLabel(post)
        elif data.type == 'RULE' and data.value == 'ifstmt':
            _, _, cond, _, body, = tree.children
            inner = NewLabel()
            post = NewLabel()
            inter.trues.append(inner)
            inter.falses.append(post)
            cond = Rvalue(cond.children[0])
            assert len(inter.trues) == 1, f'Len(Trues) should be 1, got {inter.trues}'
            assert len(inter.falses) == 1, f'Len(Falses) should be 1, got {inter.falses}'
            inter.trues = []; inter.falses = []
            if cond and cond.name:
                inter.CJump(cond, post)
            inter.AddLabel(inner)
            Gen(body.children[0])
            inter.AddLabel(post)
        elif data.type == 'RULE' and data.value == 'ifelsestmt':
            _, _, cond, _, body, _, _else = tree.children
            inner = NewLabel()
            einner = NewLabel()
            post = NewLabel()
            inter.trues.append(inner)
            inter.falses.append(einner)
            cond = Rvalue(cond.children[0])
            assert len(inter.trues) == 1, f'Len(Trues) should be 1, got {inter.trues}'
            assert len(inter.falses) == 1, f'Len(Falses) should be 1, got {inter.falses}'
            inter.trues = []; inter.falses = []
            if cond and cond.name:
                inter.CJump(cond, einner)
            inter.AddLabel(inner)
            Gen(body.children[0])
            inter.Jump(post)
            inter.AddLabel(einner)
            Gen(_else.children[0])
            inter.AddLabel(post)
        
        elif data.type == 'RULE' and data.value == 'stmt':
            Gen(tree.children[0])

        elif data.type == 'RULE' and data.value == 'struct_decl':
            return
            
        else:
##            print(tree)
            assert False, f'Unknown branch {tree=}'
    else:
        assert False, f'Tried to generate non tree `{tree}`'

@logerror
@TrackLine
def _Rvalue(expr):
    
    global inter, structs
    if type(expr) == Tree:
        data = expr.data

        if data == 'indexpr':
            le, _, re, _, = expr.children
            rhs = Rvalue(re)
            lhs = Rvalue(le)
            prod = NewTemp(Type())
            inter.AddPent(op = '*', D = prod, S0 = rhs, S1 = Var.FromVal(inter, lhs.kind.Deref().OpWidth()), S2 = None)
            tmp = NewTemp(lhs.kind.Deref())
            EvictAliasFor(inter, tmp.kind)
            inter.AddPent(op = '=[]', D = tmp, S0 = lhs, S1 = prod, S2 = Var(lhs.kind.Deref().OpWidth(), Type(Comp())))
            return tmp
        elif data == 'derefexpr':
            le, _, _, = expr.children
            lhs = Rvalue(le)
            tmp = NewTemp(lhs.kind.Deref())
            EvictAliasFor(inter, tmp.kind)
            inter.AddPent(op = '=[]', D = tmp, S0 = lhs, S1 = Var(0, 'comptime'), S2 = None)
            return tmp
        elif data == 'structinit':
            k, _, args, _, = expr.children
            kind = TreeToKind(k)
            tmp = NewTemp(kind)
            kind = str(kind)
            pref = '::'.join(namespaces)
            if not kind.startswith(pref):
                kind = '::'.join(namespaces+[kind])
            if args:
                nargs = []
                for arg in args.children:
                    if type(arg)==Tree:
                        
                        v = Rvalue(arg.children[2])
                        nargs.append((arg.children[0].children[0].value, v))
                args = nargs
            else:
                args = []
            for i, (arg, val) in enumerate(args):
                
                field = arg
                idk = dict(Statics.structs[str(kind)]['args'][field])
                
                off = idk['offset']
                width = idk['width']
                desttype = idk['type']
                tmps = f'{tmp.name}[{off}+:{width}]'
                
                inter.AddPent(op = '=', D = Var(tmps, desttype), S0 = val, S1 = None, S2 = None)
            return tmp
        elif data == 'colonexpr':
            colonerr
        elif data == 'addrexpr':
            le, _, _, = expr.children
            lhs = Rvalue(le)
            nk = lhs.kind.Addr()
            #assert type(lhs.kind.body) in [Statics.Pointer, Statics.C_Array], f'{lhs!r}'
            return Var(f'{lhs.name}.&', lhs.kind.Addr())
        elif data == 'breakpoint':
            inter.AddPent('breakpoint', None, None, None, None)
            return Var(f'NO_USE', NewTemp(Type()))
        elif data == 'sliceexpr':
            le, _, root, _, width, _, = expr.children
            lhs = Rvalue(le)
            rv = Rvalue(root)
            wv = Rvalue(width)
            assert wv.kind.comptime
            tmp = NewTemp(Type(Statics.Int(wv.name, False)))
            EvictAliasFor(inter, tmp.kind)
            inter.AddPent(op = '=[:]', D = tmp, S0 = lhs, S1 = rv, S2 = wv)
            return tmp
        elif data == 'fieldexpr':
            le, _, re, = expr.children
            lhs = Rvalue(le)
            field = TreeToName(re)
            lk = str(lhs.kind)
            pref = '::'.join(namespaces)
            if not lk.startswith(pref):
                lk = '::'.join(namespaces+[lk])
            idk = Statics.structs[lk]['args'][field]
            
            off = idk['offset']
            width = idk['width']
            desttype = idk['type']
            tmp = NewTemp(desttype)
            inter.AddPent(op = '=[:]', D = tmp, S0 = lhs, S1 = Var.FromVal(inter, off), S2 = Var.FromVal(inter, width))
            return tmp
        elif data == 'callexpr':
            func, _, args, _ = expr.children
            prearg = None
            prefu = False
            if len(func.children) > 1:
                assert func.data == 'colonexpr'
                l, _, r = func.children
                r = r.children[0].value
##                r = '::'.join(namespaces+[r])
                if type(l.children[0]) != Tree:
                    ol = l
                    l = l.children[0].value
                    if l in Statics.structs:
                        prearg = None
                        func = MapRawName(l+'__'+r)
                        prefu = True
                    else:
                        prearg = Rvalue(ol)
                        func = MapRawName(str(inter.Lookup(l)).replace('*','').split('[')[0]+'__'+r)
                        prefu = True
                else: 
                    l = Rvalue(l)
                    
                    func = MapRawName(str(l.kind).replace('*','')+'__'+r)
                    prefu = True
                    prearg = l
##                if l in Statics.structs:
##                    prearg = None
##                else:
##                    prearg = l
            else:
                func = TreeToName(func)
            preff = list({x.removeprefix('u_'): None for x in func.split('::')[:-1]}.keys())
            func = 'u_'*('_'in func)+func.split('::')[-1]
            ofunc = func[:]
            en = namespaces
            if preff != namespaces:
                en = preff+namespaces
            func = '::'.join(en+[func])
##            if prefu:
##                func = 'u_' +func

            if args:
                nargs = []
                for arg in args.children:
                    if type(arg)==Tree:
                        v = Rvalue(arg)
                        assert type(v) == Var, f'{v=}; {arg=}'
                        nargs.append(v)
                args = nargs
            else:
                args = []
            if prearg:
                args.insert(0, prearg)
            assert func in funcs, f'Cannot find function name `{func}` of any:\n  {"\n  ".join(funcs)}\nRoot function name is `{ofunc}` in namespace `{namespaces}` with `{en}`'
##            print(f'Found `{func}`')
            funargs, funret = funcs[func]
            assert len(funargs) == len(args), f'Function `{func}` has arity `{len(funargs)}`, but was given `{len(args)}` args'
            for i, arg in enumerate(args):
                inter.AddPent('argst', Var.FromVal(inter, i), arg, None, None)
            inter.AddPent('call', Var(func, Type()), None, None, None)
            tmp = NewTemp(funret)
            inter.AddPent('retld', tmp, Var.FromVal(inter, 0), None, None)
            return tmp
        elif data == 'intrinsic':
            _, name, _, args, _, = expr.children
            name = name.children[0].value
            name = '@' + name
            ct = False
            if args:
                ct=True
                nargs = []
                for arg in args.children:
                    if type(arg)==Tree:
                        var = Rvalue(arg)
                        nargs.append(var)
                        if not var.kind.comptime:
                            ct = False
                args = nargs
            else:
                args = []

            if name in usesRd:
                assert len(args) == 4, f'Intrinsic function takes 4 arguments'
##                args += [None]*4
                inter.AddPent(op = name, D = args[0], S0 = args[1], S1 = args[2], S2 = args[3])
                return Value(NoVar)
            else:
                assert len(args) <= 3, f'Intrinsic functions do not support more than 3 arguments'
                args += [None]*4
                tk = Type(Statics.Comptime() if ct else Statics.Int(32, False))
                tmp = NewTemp(tk)
                inter.AddPent(op = name, D = tmp, S0 = args[0], S1 = args[1], S2 = args[2])
                return tmp
        elif data == 'true':
            inter.Jump(inter.trues[-1])
            return Var(None, Type(Statics.Bool()))
        elif data == 'false':
            inter.Jump(inter.falses[-1])
            return Var(None, Type(Statics.Bool()))
        elif data == 'overflow':
##            inter.AddPent(op = 'of', D = None, None, None, None)
            inter.IfJump(None, 'of', None, inter.trues[-1])
            inter.Jump(inter.falses[-1])
            return Var(None, Type(Statics.Bool()))
        elif type(data) == str:
            print(data)
            print(expr)
            err
        
        if data.type == 'RULE' and data.value == 'ident':
            ident = TreeToName(expr)
            return Var.FromName(inter, ident)
##            kind = inter.Lookup(ident)
##            return ident, kind
        elif data.value == 'decint':
            return Var(int(''.join([x for x in expr.children]).replace('_', '')), Type(Comp()))
        elif data.value == 'hexint':
            return Var(int(''.join([x for x in expr.children]).replace('_', ''), 16), Type(Comp()))
        elif data.value == 'landexpr':
            lhs, _, rhs = expr.children
            lbl = NewLabel()
            inter.trues.append(lbl)
            Rvalue(lhs)
            inter.AddLabel(lbl)
            del inter.trues[-1]
            Rvalue(rhs)
            return Var(None, Type(Statics.Bool()))
        elif data.value == 'lorexpr':
            lhs, _, rhs = expr.children
            lbl = NewLabel()
            inter.falses.append(lbl)
            Rvalue(lhs)
            inter.AddLabel(lbl)
            del inter.falses[-1]
            Rvalue(rhs)
            return Var(None, Type(Statics.Bool()))
        elif data.value == 'addexpr':
            le, op, bt, re = expr.children
            lhs = Rvalue(le)
            rhs = Rvalue(re)
            op = op.children[0].value
            kind = lhs.kind.Common(rhs.kind)
            tmp = NewTemp(kind)
            inter.AddPent(op = op, D = tmp, S0 = lhs, S1 = rhs, S2 = None, sticky = bt)
            return tmp
        elif data.value == 'multexpr':
            le, op, bt, re = expr.children
            lhs = Rvalue(le)
            rhs = Rvalue(re)
            op = op.children[0].value
            kind = lhs.kind.Common(rhs.kind)
            tmp = NewTemp(kind)
            inter.AddPent(op = op, D = tmp, S0 = lhs, S1 = rhs, S2 = None, sticky = bt)
            return tmp
        elif data.value == 'bandexpr':
            le, _, bt, re = expr.children
            lhs = Rvalue(le)
            rhs = Rvalue(re)
            kind = lhs.kind.Common(rhs.kind)
            tmp = NewTemp(kind)
            inter.AddPent(op = '&', D = tmp, S0 = lhs, S1 = rhs, S2 = None, sticky = bt)
            return tmp
        elif data.value == 'bxorexpr':
            le, _, bt, re = expr.children
            lhs = Rvalue(le)
            rhs = Rvalue(re)
            kind = lhs.kind.Common(rhs.kind)
            tmp = NewTemp(kind)
            inter.AddPent(op = '^', D = tmp, S0 = lhs, S1 = rhs, S2 = None, sticky = bt)
            return tmp
        elif data.value == 'borexpr':
            le, _, bt, re = expr.children
            lhs = Rvalue(le)
            rhs = Rvalue(re)
            kind = lhs.kind.Common(rhs.kind)
            tmp = NewTemp(kind)
            inter.AddPent(op = '|', D = tmp, S0 = lhs, S1 = rhs, S2 = None, sticky = bt)
            return tmp
        elif data.value == 'relexpr':
            le, op, re = expr.children
            lhs = Rvalue(le)
            rhs = Rvalue(re)
            op = op.children[0].value
            assert lhs.kind.CanCoerceTo(rhs.kind) or rhs.kind.CanCoerceTo(lhs.kind), f'Cannot do comparison on uncoerceable types `{lhs.kind}` and `{rhs.kind}`'
            if op in ['>', '>=', '<=', '<']:
                if type(lhs.kind.body) == Int:
                    signed = lhs.kind.signed
                elif type(rhs.kind.body) == Int:
                    signed = rhs.kind.signed
                else: assert False, f'Comparison of non-numbers {lhs}({type(lhs.kind.body)}) and {rhs}({type(rhs.kind.body)})'
                inter.IfJump(lhs, '+-'[signed]+op, rhs, inter.trues[-1])
            else:
                inter.IfJump(lhs, op, rhs, inter.trues[-1])
            inter.Jump(inter.falses[-1])
            return Var(None, Type(Statics.Bool()))
        elif data.value == 'assgexpr':
            le, op, bt, re = expr.children
            lhs = Lvalue(le)
            rhs = Rvalue(re)
            if len(op.children[0].value) >= 2:
                op = op.children[0].value[:-1]
                assert rhs.kind.CanCoerceTo(lhs.kind)
                rlhs = Rvalue(le)
                kind = rlhs.kind.Common(rhs.kind)
                tmp = NewTemp(kind)
                
                inter.AddPent(op = op, D = tmp, S0 = rlhs, S1 = rhs, S2 = None, sticky = bt)
                inter.AddPent(op = '=', D = lhs, S0 = tmp, S1 = None, S2 = None)
##                inter.AddPent(op = op, D = lhs, S0 = lhs, S1 = rhs, S2 = None)
            else:
                assert rhs.kind.CanCoerceTo(lhs.kind), f'Cannot coerce `{rhs.kind}` into type `{lhs.kind}`'
                inter.AddPent(op = '=', D = lhs, S0 = rhs, S1 = None, S2 = None)
            return lhs
        elif data.value == 'unaryexpr':
            op, re = expr.children
            rhs = Rvalue(re)
            if (op.children[0].value == '+'):
                return rhs
            elif op.children[0].value == '-':
                tmp = NewTemp(rhs.kind)
                inter.AddPent(op = '-', D = tmp, S0 = Var.FromVal(inter, 0), S1 = rhs, S2 = None)
                return tmp
            elif op.children[0].value == '~':
                tmp = NewTemp(rk)
                inter.AddPent(op = 'bit', D = tmp, S0 = rhs, S1 = 0, S2 = 0b1001)
                return tmp
            else:
                assert False, f'Bad unary: `{op}`'
        elif data.value == 'lunaryexpr':
            _, re = expr.children

            inter.trues[-1], inter.falses[-1] = inter.falses[-1], inter.trues[-1]

            rhs, rk = Rvalue(re)
            return None, Type(Statics.Bool())
        elif data.value == 'castexpr':
            le, re, = expr.children
            lk = TreeToKind(le)
            rhs = Rvalue(re)
            tmp = NewTemp(lk)
            inter.AddPent(op = '=<>', D = tmp, S0 = rhs, S1 = None, S2 = None)
            return tmp
        elif data.value == 'constant':
            return Rvalue(expr.children[0])
        elif data.value == 'string':
            ref = inter.AddString(expr.children[0])
            return Var(ref, Type.FromStr('u32*'))
        elif data.value == 'primexpr':
            _, ex, _, = expr.children
            return Rvalue(ex)
        elif data.value == 'expr':
            return Rvalue(expr.children[0])
        else:
            print(data.value)
            print(expr)
            bad
    elif type(expr) != str and expr.type == 'CHAR':
        return Var(ord(eval(expr.value)), Type(Comp()))
    else:
        print(f'Bad rvalue expression isnt tree nor CHAR: `{expr}`')
        err

@logerror
@TrackLine
def _Lvalue(expr):
    global inter
    if type(expr) == Tree:
        data = expr.data

        if data == 'indexpr':
            le, _, re, _, = expr.children
            rhs = Rvalue(re)
            lhs = Rvalue(le)
            prod = NewTemp(Type())
            assert lhs.kind.Deref() != Type('Block'), f'{lhs=}'
            inter.AddPent(op = '*', D = prod, S0 = rhs, S1 = Var.FromVal(None, lhs.kind.Deref().OpWidth()), S2 = None)
            tmp = f'{lhs.name}[{prod.name}]'
            return Var(tmp, lhs.kind.Deref())
        elif data == 'sliceexpr':
            le, _, root, _, width, _, = expr.children
            lhs = Rvalue(le)
            rv = Rvalue(root)
            wv = Rvalue(width)
            tmp = f'{lhs.name}[{rv.name}+:{wv.name}]'
            return Var(tmp, lhs.kind)
        elif data == 'fieldexpr':
            le, _, re, = expr.children
            lhs = Lvalue(le)
            field = TreeToName(re)
##            field = re.children[0].value
            li = str(lhs.kind)
            pref = '::'.join(namespaces)
            if not li.startswith(pref):
                li = '::'.join(namespaces + [li])
##            field = '::'.join(namespaces + [field])
            idk = Statics.structs[li]['args'][field]
            
            off = idk['offset']
            width = idk['width']
            desttype = idk['type']
            tmp = f'{lhs.name}[{off}+:{width}]'
            
##            inter.CastAddPent(op = '=[:]', D = tmp, S0 = lhs, S1 = off, S2 = width, origtype = lk, desttype = desttype)
            return Var(tmp, desttype)
        elif data == 'derefexpr':
            le, _, _, = expr.children
            lhs = Rvalue(le)
            return Var(f'{lhs.name}[0]', lhs.kind.Deref())
        elif type(data) == str:
            print(data)
            print(expr)
            err
        
        if data.type == 'RULE' and data.value == 'ident':
            ident = TreeToName(expr)
##            ident = MapRawName(expr.children[0].value)
            kind = inter.Lookup(ident)
            return Var(ident, kind)
        elif data.value == 'addexpr':
            assert False, f'Cannot take L-value of arithmetic'
        elif data.value == 'assgexpr':
            assert False, f'Cannot take L-value of assignment'
        elif data.value == 'decint':
            assert False, f'Cannot take L-value of constant'
        elif data.value == 'hexint':
            assert False, f'Cannot take L-value of constant'
        else:
            print(expr)
            print(data.value)
            bad
    else:
        print(expr)
        err

def NewTemp(inter, kind):
    global tid
    tid += 1; ID = f't{tid}'
    inter.Decl(ID, kind)
    return Var(ID, kind)

def NewLabel():
    global tid
    tid += 1; ID = f'L{tid}'
    return ID



class HLIR:
    def __init__(self):
        self.funcs = []
        self.envs = []
        self.loops = []
        self.trues = []
        self.falses = []
        self.func = {}
        self.data = {}

    def __repr__(self):
        o = ''
        for func in self.funcs:
            oa = ", ".join([f'{arg.name}: {arg.kind}' for arg in func['args']])
            o += (f'fn {func["name"]} ({oa}) {func["ret"]} '+'{') + '\n'
            for block in func['body']:
                o += '  '+(f'{block.entry}:') + '\n'
                for line in block.body:
                    o += '    '+repr(line) + '\n'
                o += '  '+(f'{block.exit} \n    FALL: {block.fall}') + '\n\n'
            o += ('}') + '\n'
        return o

    def NewFunc(self, name, args, ret):
        self.funcs.append({})
        func = self.func = self.funcs[-1]
        func['name'] = name
        func['args'] = args
        func['ret'] = ret
        self.body = Block(f'_{name}__')
        func['body'] = [self.body]
        
        self.NewEnv()
        for arg in args:
            self.Register(arg.name, arg.kind)

    def NewEnv(self):
        self.envs.append({})
    
    def PopEnv(self):
        for env in self.envs[:-1]:
            for var in env:

                self.PreUse(var)
        for var in self.envs[-1]:

            pass
        del self.envs[-1]

    def Register(self, name, kind):
        self.envs[-1][name] = kind

    def LookupKind(self, name):
        for env in self.envs[::-1]:
            if name in env:
                return env[name]
        Error(f'Cannot find name: `{name}` in current scope')

    def LookupVar(self, name):
        return Var(name, self.LookupKind(name))

    def PotAliases(self, kind):
        als = []
        for env in self.envs[::-1]:
            for name, nkind in env.items():
                if nkind == kind:
                    als.append(name)
        return als

    def Decl(self, name, kind, idx = None):
        if type(kind) == Statics.Void: return
        self.Register(name, kind)
        if idx == None:     self.body.Addline(('decl', Var(name, kind), None, None))
        else:       self.body.Insertline(idx, ('decl', Var(name, kind), None, None))

    def AddMemStore(self, ary, idx, val):
        EvictAliasFor(inter, ary.kind.Deref())
        self.AddPent('[]=', val, ary, idx, None)
        InvalidateAliasFor(inter, ary.kind.Deref())

    def AddBitMemStore(self, ary, idx, width, val):
        EvictAliasFor(inter, ary.kind.Deref())
        self.AddPent('[]=', val, ary, idx, width)
        InvalidateAliasFor(inter, ary.kind.Deref())

    def AddBitStore(self, ary, off, width, val):
        assert width.kind.comptime, f'Must use a comptime known width, not `{width}`. To use runtime use @bst'
        EvictAliasFor(inter, ary.kind)
        self.AddPent('[:]=', ary, val, off, width)

    def AddPent(self, op: str, D: Var, S0: Var, S1: Var, S2: Var, sticky = False):
        D = D if D != None else Var.FromVal(self, None)
        S0 = S0 if S0 != None else Var.FromVal(self, None)
        S1 = S1 if S1 != None else Var.FromVal(self, None)
        S2 = S2 if S2 != None else Var.FromVal(self, None)
        D = D if type(D) != int else Var.FromVal(self, D)
        S0 = S0 if type(S0) != int else Var.FromVal(self, S0)
        S1 = S1 if type(S1) != int else Var.FromVal(self, S1)
        S2 = S2 if type(S2) != int else Var.FromVal(self, S2)
        self.body.Addline(('expr', (op, D, S0, S1, S2), sticky))

    def _AddPent(self, op: str, D: Var, S0: Var, S1: Var, S2: Var, sticky = None):
        
        D = D if D else Var.FromVal(self, None)
        S0 = S0 if S0 else Var.FromVal(self, None)
        S1 = S1 if S1 else Var.FromVal(self, None)
        S2 = S2 if S2 else Var.FromVal(self, None)
        
        assert type(D) == Var, f'{D=}; {type(D)=}'
        assert type(S0) == Var, f'{S0=}; {type(S0)=}'
        assert type(S1) == Var, f'{S1=}; {type(S1)=}'
        assert type(S2) == Var, f'{S2=}; {type(S2)=}'

        global eid
        eid += 1
        if type(D.name) == str and '[' in D.name:
            if op == '=<>':
                tmp = NewTemp(S1.kind)
                
                self.AddPent('=<>', tmp, S0, S1, S2)
                
                S0 = tmp
                S2 = Var.FromVal(None)
                op = '='
            
            l, r = D.name[:-1].split('[', maxsplit=1)
            
            l = Var.FromVal(self, l)
            if '[' in r:
                aryidx, r = r.split('][')
                aryidx = Var.FromVal(self, aryidx)
                r, w = r.split('+:')
                r = Var.FromVal(self, r)
                w = Var.FromVal(self, w)
                tmp = NewTemp(r.kind)
                self.AddPent('+', tmp, aryidx, r, None)
                self.AddBitMemStore(l, tmp, w, S0)
                print(l, tmp, w, S0)
            else:
                if '+:' not in r:
                    r = Var.FromVal(self, r)
                    assert op == '=', f'Expected operation to be `=` when lhs is array, got `{op}`.\nLine was: `{(op, D, S0, S1, S2)}`'
                    self.AddMemStore(l, r, S0)
                else:
                    r, w = r.split('+:')
                    r = Var.FromVal(self, r)
                    w = Var.FromVal(self, w)
                    assert op == '=', f'Expected operation to be `=` when lhs is sliced, got `{op}`.\nLine was: `{(op, D, S0, S1, S2)}`'

                    
                    self.AddBitStore(l, r, w, S0)
            return
        
        self.body.Addline(('expr', (op, D, S0, S1, S2), sticky!=None, eid))
    def AddLabel(self, lbl):
        self.body.fall = lbl
        self.body = Block(lbl)
        self.func['body'].append(self.body)

    def Evict(self, name):
        self.body.Addline(('memsave', name))
    def EvictBits(self, name, offset, width):
        self.body.Addline(('memsavebit', name, offset, width))
    def Invalidate(self, name):
        self.body.Addline(('regrst', name))
    def InvalidateBits(self, name, offset, width):
        self.body.Addline(('regrstbit', name, offset, width))
    def NoFallLabel(self, lbl):
        self.body = Block(lbl)
        self.func['body'].append(self.body)
    def IfJump(self, lhs, op, rhs, lbl):
        self.AddPent(op, None, lhs, rhs, None)
        self.body.exit = ('c.jmp', (lbl))
        self.body.exloc = lbl
        self.AddLabel('_'+NewLabel())
    def IfFalseJump(self, lhs, op, rhs, lbl):
        self.AddPent(op, None, lhs, rhs, None)
        self.body.exit = ('cn.jmp', (lbl))
        self.body.exloc = lbl
        self.AddLabel('_'+NewLabel())
    def CJump(self, cond, lbl):
        self.Use(cond)
        self.AddPent('==', None, cond, Var(0, 'comptime'), None)
        self.body.exit = ('c.jmp', (lbl))
        self.body.exloc = lbl
        self.AddLabel('_'+NewLabel())
    def Jump(self, lbl):
        self.body.exit = ('goto', (lbl))
        self.body.exloc = lbl
        self.body.fall = None
        self.NoFallLabel('_'+NewLabel())
    def PushLoopLabels(self, pre, post):
        self.loops.append([pre, post])
    def PopLoopLabels(self, pre, post):
        del self.loops[-1]
    def Return(self, *args):
        for arg in args:
            assert arg.kind.CanCoerceTo(self.func['ret']), f'Cannot coerce type `{arg.kind}` to `{self.func["ret"]}`'
        if len(args) == 0:
            assert Type.FromStr('void').CanCoerceTo(self.func['ret']), f'Cannot return without value for function with return type `{self.func["ret"]}`'
        for i, arg in enumerate(args):
            self.AddPent('retst', Var.FromVal(self, i), arg, None, None)
        self.body.exit = ('return', eid)
        self.body.fall = None
        self.NoFallLabel('_'+NewLabel())
    def PreUse(self, name):
        global eid
        eid += 1
        self.Use(name)
        eid -= 1
    def Use(self, name):
        for j, block in enumerate(self.func['body']):
            for i, line in enumerate(block.body):
                if line[0] == 'decl' and line[1] == name:
                    self.func['body'][j].body[i] = line[:3] + (-1,)
    def EndFunc(self):

        body = self.func['body']
        lvars = {}
        ito = {}
        to = {}
        fto = {}
        k = {}
        fto[f'_{self.func["name"]}__'] = ['Entry']

        for block in body:
            for i,b in enumerate(block.body):
                if b[0] == 'expr':
                    if b[1][0] in nullret:
                        l = list(b)
                        li = list(l[1])
                        li[1] = NoVar
                        l[1] = li
                        block.body[i] = tuple(l)

        return

        
    def AddString(self, txt):
        key = f's{len(self.data.keys())}:'
        self.data[key] = txt
        return key


class Block:
    def __init__(self, entry):
        self.entry = entry
        self.body = []
        self.exit = None
        self.exloc = None
        self.fall = 'EOF'
        self.From = None
    def Addline(self, line):
        self.body.append(line)
    def Insertline(self, idx, line):
        self.body.insert(idx, line)

def ResolveTypes():
    queue = list(Statics.structs.keys())
    while queue != []:
        n = queue[0]
        if Statics.structs[n]['size'] != ...:
            del queue[0]
            continue
        RecuSolveType(queue[0])
        del queue[0]

def RecuSolveType(name, stk = ()):
    if name in stk: Error(f'Type `{name}` is self referential')
    stk = stk + (name,)
    for argname, arg in Statics.structs[name]['args'].items():
        kind = arg['type']
        strk = str(TreeToKind(kind))
        rstrk = strk
        for k in Statics.structs:
            if strk == k.split('::')[-1]:
                strk = k
        if strk in Statics.structs and Statics.structs[strk]['size'] != ...:
            width = Statics.structs[strk]['size']
        elif strk in Statics.structs:
            RecuSolveType(strk, stk)
            width = Statics.structs[strk]['size']
            assert width != None, f'Recu failure'
        else:
            kind = Type.FromStr(strk)
##            print(f'Structs is:\n{FormatDict(Statics.structs)=}\n')
            width = kind.OpWidth()
            assert width != None, f'Bad kind `{strk}` has no width'
        align = AlignOf(width)
        Statics.structs[name]['args'][argname]['type'] = Type.FromStr(rstrk)
        Statics.structs[name]['args'][argname]['width'] = width
    PackArgs(name)

def PackArgs(name):
    words = {}
    laddr = 0
    for argname, arg in Statics.structs[name]['args'].items():
        width = arg['width']
        for addr, cw in words.items():
            if 32 - cw > width:                
                Statics.structs[name]['args'][argname]['offset'] = addr << 5 | cw
                words[addr] += width
                break
            elif 32-cw == width:                
                Statics.structs[name]['args'][argname]['offset'] = addr << 5 | cw
                del words[addr]
                break
        else:
            if width <= 32:                
                Statics.structs[name]['args'][argname]['offset'] = laddr << 5
                words[laddr] = width
                if width == 32:
                    del words[laddr]
                laddr += 1
            else:
                Statics.structs[name]['args'][argname]['offset'] = laddr << 5
                laddr += -(-width//32)

    
    Statics.structs[name]['size'] = 32 * laddr
    

def EvictAliasFor(inter, kind):
    for env in inter.envs[::-1]:
        for varname, varkind in env.items():
            if str(kind) == str(varkind):
                inter.Evict(Var(varname, varkind))
            elif str(varkind) in Statics.structs:
                cstk = []
                for arg in Statics.structs[str(varkind)]['args'].values():
                    cstk.append(arg)
                while cstk:
                    arg = cstk[0]
                    del cstk[0]
                    if str(arg['type']) == str(kind):
                        inter.EvictBits(Var(varname, varkind), arg['offset'], arg['width'])
                    elif str(arg['type']) in Statics.structs:
                        for carg in Statics.structs[str(arg['type'])]['args'].values():
                            carg = dict(carg) #This MF not existing broke all of my code way down the line :\
                            carg['offset'] += arg['offset']
                            cstk.append(carg)

def InvalidateAliasFor(inter, kind):
    for env in inter.envs[::-1]:
        for varname, varkind in env.items():
            if str(kind) == str(varkind):
                inter.Invalidate(Var(varname, varkind))
            elif str(varkind) in Statics.structs:
                cstk = []
                for arg in Statics.structs[str(varkind)]['args'].values():
                    cstk.append(arg)
                while cstk:
                    arg = cstk[0]
                    del cstk[0]
                    if str(arg['type']) == str(kind):
                        inter.InvalidateBits(Var(varname, varkind), arg['offset'], arg['width'])
                    elif str(arg['type']) in Statics.structs:
                        for carg in Statics.structs[str(arg['type'])]['args'].values():
                            carg['offset'] += arg['offset']
                            cstk.append(carg)

def GenAssume(inter, tree):
    data = tree.data
    if data == 'assumeunreachable':
        inter.body.Addline(('unreachable',None))
        return
    assert False, str(tree.pretty())

def BuildBoot():
    name = 'Boot'

    args = []
    ret = Int(32, False)
    funcs[name] = (args, ret)
    inter.NewFunc(name, args, ret)
    inter.AddPent('call', Var('u_Main', Type()), None, None, None)
    inter.AddPent('@susp', None, None, None, None)
    inter.PopEnv()
    inter.EndFunc()

def FormatDict(x, idt = 0):
    if type(x) != dict:
        print(repr(x), end = '')
    else:
        print('{\n', end = '')
        idt += 1
        for k,v in x.items():
            print('  '*idt+f'{k!r}: ', end = '')
            FormatDict(v, idt)
            print(',', end = '\n')
        idt -= 1
        print('  '*idt+'}', end = '')

def Compile(filepath, verbose = False, optimize = True):
    global funcs, syms, ind, tid, eid, srcs, inter, tree, txt, namespaces
    with open(filepath, 'r') as f:
        txt = f.read()
        txt = txt.replace('\\"', '\x01')
        tree = parser.parse(txt)

    Statics.structs = {}
    syms = [{}]
    out = ''
    ind = 0
    tid = 0
    eid = 0
    srcs=[]
    namespaces = []

    funcs = {}
##    inter = HLIR()

    LHL.Init(sys.modules[__name__])

    try:
        inter = Gen_Start(tree)
        BuildBoot()
    except Exception as e:
        raise

    with open('struct_dump.txt', 'w') as f:
        f.write(repr(Statics.structs))

    if verbose:
        print('\nHLIR:')
        print(repr(inter))
    with open('out.hlr', 'w') as f:
        f.write(repr(inter))

    llir = LHL.Lower(inter)

    if verbose:
        print('\nLLIR:')
        print(repr(llir))
    with open('out.llr', 'w') as f:
        f.write(repr(llir))

    if optimize:
        LLOptimizer.Optimize(llir)
        if verbose:
            print('\nOPT LLIR:')
            print(repr(llir))
        with open('out_ret_opt.llr', 'w') as f:
            f.write(repr(llir))

    asm = LLL.Lower(llir)

    if verbose:
        print('\nASM:')
        print(asm)
    with open('out.asm', 'w') as f:
        f.write(asm)

    program = ASM.ParseFile(asm)

    mif = ASM.Mifify(program, 15)
    if verbose:
        print('\nMIF:')
        print(mif)
    with open('out.mif', 'w') as f:
        f.write(mif)

    if os.path.exists('../.sim/Icarus Verilog-sim'):
        with open("../.sim/Icarus Verilog-sim/RAM.mif", 'w') as f:
            f.write(mif)

        if not os.path.exists("../.sim/Icarus Verilog-sim/LALU_fs"): os.mkdir("../.sim/Icarus Verilog-sim/LALU_fs")
        with open("../.sim/Icarus Verilog-sim/LALU_fs/bios", "wb") as f:
            for _,hx in sorted(program.items(), key=lambda x:x[0]):
                f.write(bytearray.fromhex(hx)[::-1])
    else:
        pyperclip.copy(mif)

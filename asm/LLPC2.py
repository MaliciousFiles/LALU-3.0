from lark import Lark, Token, Tree
import LowerHLIR2 as LHL
import LowerLLIR3 as LLL
import AssemblerV3 as ASM
from math import log2
import sys
import os
import pyperclip
from Statics import Type, Var, NoVar, AlignOf, Void, Comp, Int
import Statics
import LLOptimizer


parser = Lark.open("LLPC_grammar.lark", rel_to=__file__, parser="lalr", propagate_positions = True)

usesRd = ['[]=', '[:]=', '@stchr']
nullret = ['@susp', '@rstkey', '@stchr', '@nop']

def MapRawName(name):
    if '_' in name or name[0] in 'Lt':
        name = 'u_'+name.replace('_', '__')
    return name

def TreeToName(tree):
    return MapRawName(tree.children[0].value)

def TreeToKind(kind):
    start = kind.meta.start_pos
    end = kind.meta.end_pos
    return Type(txt[start:end])

def TrackLine(func):
    global inter, srcs
    def inner(*args, **kwargs):
        ret = func(*args, **kwargs)
        if inter.func == {}:
            return ret
        for i, block in enumerate(inter.func['body']):
            for j, line in enumerate(block.body):
                nsrc = func.__name__
                if type(args[0]) == Tree:
                    nsrc = nsrc + f'({args[0].meta.start_pos}, {args[0].meta.end_pos})'
                if line[-2] != 'src':
                    srcs.append([nsrc])
                    inter.func['body'][i].body[j] = line + ('src', len(srcs)-1,)
                else:
                    src = line[-1]
                    srcs[src].append(nsrc)
        return ret
    return inner

def logerror(func):
    def inner(*args, **kwargs):
        global FAILEDLINE
        try:
            return func(*args, **kwargs)
        except Exception as e:
            tree = args[0]
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
                    line -= fline + 1
                    qf = f' in {fileline.split("`")[1]}'
            else:
                qf = ''
            pline = txt[:start].split('\n')[-1]
            body = txt[start:].split('\n')[0]
            body = pline + body
            if FAILEDLINE != body:
                FAILEDLINE = body
                print(f'\nError on line {line+1}{qf}:\n  ' + body.lstrip(' ').lstrip('\t'))
            raise e
    return inner

FAILEDLINE = None

def GetStrKind(kind):
    return str(TreeToKind(kind))
    if type(kind.children[0]) != Tree:
        strk = kind.children[0].value
    else:
        o = ''
        for child in kind.children[0].children:
            if type(child) == Tree:
                o += child.children[0].value
            else:
                o += child.value
        strk = o
    return strk

@logerror
@TrackLine
def Gen(tree, pre = True, fn_pref = None):
    
    global out, ind, inter, funcs
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
##            print(data)
##            print(expr)
##            err
        
        elif data.type == 'RULE' and data.value == 'start':
            bds = []
            for child in tree.children:
                Gen(child)

            ResolveTypes()
            for child in tree.children:
                Gen(child, pre = False)

        elif data.type == 'RULE' and data.value == 'ex_decl':
            Gen(tree.children[0], pre)
        elif data.type == 'RULE' and data.value == 'fn_decl':
            _, name, _, rargs, _, ret, body = tree.children
            if fn_pref != None:
                name = MapRawName(fn_pref+'__'+name.children[0].value)
            else:
                name = TreeToName(name)
            
            args = []
            if rargs:
                for arg in rargs.children:
                    if type(arg) == Token:
                        continue
                    aname, _, akind = arg.children
                    narg = Var(TreeToName(aname), TreeToKind(akind))
                    args.append(narg)
            ret = TreeToKind(ret)
            funcs[name] = (args, ret)
            if not pre:
                inter.NewFunc(name, args, ret)
                for i, arg in enumerate(args):
                    inter.AddPent('argld', arg, Var.FromVal(inter, i), None, None)
                Gen(body)
                inter.PopEnv()
                inter.EndFunc()
            else:
                return
        elif data.type == 'RULE' and data.value == 'assumestmt':
            GenAssume(inter, tree.children[1])
        elif data.type == 'RULE' and data.value == 'declstmt':
            _, name, _, kind, _, = tree.children
            kind = TreeToKind(kind)
            name = TreeToName(name)
            assert not kind.comptime, f'Cannot instantiate variable `{name}` with comptime type'
            inter.Decl(name, kind)
        elif data.type == 'RULE' and data.value == 'declexpr':
            _, name, _, kind, _, expr, _, = tree.children
            rhs = Rvalue(expr.children[0])
            name = TreeToName(name)
            if kind:
                kind = Type.FromStr(GetStrKind(kind))
            else:
                kind = rhs.kind
            assert rhs.kind.CanCoerceTo(kind), f'Type `{rhs.kind}` cannot coerce into type `{kind}`'
            inter.Decl(name, kind)
            assert rhs.kind.CanCoerceTo(kind)
            assert not kind.comptime, f'Cannot instantiate variable `{name}` with comptime val `{rhs.name}`'
            inter.AddPent(op = '=', D = Var(name, kind), S0 = rhs, S1 = None, S2 = None)
        elif data.type == 'RULE' and data.value == 'exprstmt':
            expr, _, = tree.children
            if expr:
                _ = Rvalue(expr.children[0])
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
            _, name, _, _args, _, = tree.children
            fns = _args.children[1:-1]
            args = _args.children[0]
            assert _args.children[-1] == None
            if not pre:
                for fn in fns:
                    Gen(fn, pre = pre, fn_pref = name.children[0].value)
                return
            self = Statics.structs[name.children[0].value] = {'size': None, 'args': {}}
            for arg in args.children:
                if type(arg) != Tree: continue
                argname, _, argkind = arg.children
                assert argname not in self['args']
                self['args'][argname.children[0].value] = {'offset': None, 'width': None, 'type': argkind}
            for fn in fns:
                fn
                Gen(fn, pre = pre, fn_pref = name.children[0].value)
            return
            
        else:
##            print(tree)
            assert False, f'Unknown branch {tree=}'
    else:
        assert False, f'Tried to generate non tree `{tree}`'

@logerror
@TrackLine
def Rvalue(expr):
    
    global inter, structs
    if type(expr) == Tree:
        data = expr.data

        if data == 'indexpr':
            le, _, re, _, = expr.children
            rhs = Rvalue(re)
            lhs = Rvalue(le)
            prod = NewTemp(Type())
            inter.AddPent(op = '*', D = prod, S0 = rhs, S1 = Var.FromVal(inter, lhs.kind.OpWidth()), S2 = None)
            tmp = NewTemp(lhs.kind.Deref())
            EvictAliasFor(inter, tmp.kind)
            inter.AddPent(op = '=[]', D = tmp, S0 = lhs, S1 = prod, S2 = None)
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
            field = re.children[0].value
            idk = Statics.structs[str(lhs.kind)]['args'][field]
            
            off = idk['offset']
            width = idk['width']
            desttype = idk['type']
            tmp = NewTemp(desttype)
            inter.AddPent(op = '=[:]', D = tmp, S0 = lhs, S1 = Var.FromVal(inter, off), S2 = Var.FromVal(inter, width))
            return tmp
        elif data == 'callexpr':
            func, _, args, _ = expr.children
            prearg = None
            if len(func.children) > 1:
                assert func.data == 'colonexpr'
                l, _, r = func.children
                r = r.children[0].value
                if type(l.children[0]) != Tree:
                    ol = l
                    l = l.children[0].value
                    if l in Statics.structs:
                        prearg = None
                        func = MapRawName(l+'__'+r)
                    else:
                        prearg = Rvalue(ol)
                        func = MapRawName(str(inter.Lookup(l)).replace('*','').split('[')[0]+'__'+r)
                else: 
                    l = Rvalue(l)
                    
                    func = MapRawName(str(l.kind).replace('*','')+'__'+r)
                    prearg = l
##                if l in Statics.structs:
##                    prearg = None
##                else:
##                    prearg = l
            else:
                func = TreeToName(func)

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
            assert func in funcs, f'Cannot find function name `{func}`'
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
                assert len(args) <= 4, f'Intrinsic function takes 4 arguments'
                args += [None]*4
                inter.AddPent(op = name, D = args[0], S0 = args[1], S1 = args[2], S2 = args[3])
                return NoVar
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
            le, op, re = expr.children
            lhs = Rvalue(le)
            rhs = Rvalue(re)
            op = op.children[0].value
            kind = lhs.kind.Common(rhs.kind)
            tmp = NewTemp(kind)
            inter.AddPent(op = op, D = tmp, S0 = lhs, S1 = rhs, S2 = None)
            return tmp
        elif data.value == 'multexpr':
            le, op, re = expr.children
            lhs = Rvalue(le)
            rhs = Rvalue(re)
            op = op.children[0].value
            kind = lhs.kind.Common(rhs.kind)
            tmp = NewTemp(kind)
            inter.AddPent(op = op, D = tmp, S0 = lhs, S1 = rhs, S2 = None)
            return tmp
        elif data.value == 'bandexpr':
            le, _, re = expr.children
            lhs = Rvalue(le)
            rhs = Rvalue(re)
            kind = lhs.kind.Common(rhs.kind)
            tmp = NewTemp(kind)
            inter.AddPent(op = '&', D = tmp, S0 = lhs, S1 = rhs, S2 = None)
            return tmp
        elif data.value == 'bxorexpr':
            le, _, re = expr.children
            lhs = Rvalue(le)
            rhs = Rvalue(re)
            kind = lhs.kind.Common(rhs.kind)
            tmp = NewTemp(kind)
            inter.AddPent(op = '^', D = tmp, S0 = lhs, S1 = rhs, S2 = None)
            return tmp
        elif data.value == 'borexpr':
            le, _, re = expr.children
            lhs = Rvalue(le)
            rhs = Rvalue(re)
            kind = lhs.kind.Common(rhs.kind)
            tmp = NewTemp(kind)
            inter.AddPent(op = '|', D = tmp, S0 = lhs, S1 = rhs, S2 = None)
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
            le, op, re = expr.children
            lhs = Lvalue(le)
            rhs = Rvalue(re)
            if len(op.children[0].value) >= 2:
                op = op.children[0].value[:-1]
                assert rhs.kind.CanCoerceTo(lhs.kind)
                rlhs = Rvalue(le)
                kind = rlhs.kind.Common(rhs.kind)
                tmp = NewTemp(kind)
                
                inter.AddPent(op = op, D = tmp, S0 = rlhs, S1 = rhs, S2 = None)
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
def Lvalue(expr):
    global inter
    if type(expr) == Tree:
        data = expr.data

        if data == 'indexpr':
            le, _, re, _, = expr.children
            rhs = Rvalue(re)
            lhs = Rvalue(le)
            prod = NewTemp(Type())
            inter.AddPent(op = '*', D = prod, S0 = rhs, S1 = Var.FromVal(None, lhs.kind.OpWidth()), S2 = None)
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
            field = re.children[0].value
            idk = Statics.structs[str(lhs.kind)]['args'][field]
            
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

def NewTemp(kind):
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

    def Lookup(self, name):
        for env in self.envs[::-1]:
            if name in env:
                return env[name]
        assert False, f'Cannot find name: `{name}` in current scope'
    def PotAliases(self, kind):
        als = []
        for env in self.envs[::-1]:
            for name, nkind in env.items():
                if nkind == kind:
                    als.append(name)
        return als
    def Decl(self, name, kind):
        if type(kind) == Statics.Void:
            return
        self.Register(name, kind)
        self.body.Addline(('decl', Var(name, kind), None, None))

    def AddMemStore(self, ary, idx, val):
##        self.Use(l)
##        if idx.name.isnumeric():
##            idx = int(idx)
##        else:
##            self.Use(idx)
##        self.Use(val)
        EvictAliasFor(inter, ary.kind.Deref())
        self.AddPent('[]=', val, ary, idx, None)
        InvalidateAliasFor(inter, ary.kind.Deref())

    def AddBitMemStore(self, ary, idx, width, val):
        EvictAliasFor(inter, ary.kind.Deref())
        self.AddPent('[]=', val, ary, idx, width)
        InvalidateAliasFor(inter, ary.kind.Deref())

    def AddBitStore(self, ary, off, width, val):
##        ary, aryk = ary if ary else (None, None)
##        off, offk = off if off else (None, None)
##        width, widthk = width if width else (None, None)
##        val, valk = val if val else (None, None)
##        self.Use(val)
##        if off.isnumeric():
##            off = int(off)
##        else:
##            self.Use(off)
##        assert width.isnumeric(), f'Must use a comptime known width, not `{width}`, to use runtime use @bst'
        assert width.kind.comptime, f'Must use a comptime known width, not `{width}`. To use runtime use @bst'
##        width = int(width)
##        self.Use(ary)
        EvictAliasFor(inter, ary.kind)
        self.AddPent('[:]=', ary, val, off, width)
##        InvalidateAliasFor(inter, ary.kind)
    
    def AddPent(self, op: str, D: Var, S0: Var, S1: Var, S2: Var):
        
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
##                assert False, 'Maybe this will get deprecated'
            
            l, r = D.name[:-1].split('[', maxsplit=1)
            
            l = Var.FromVal(self, l)
            if '[' in r:
##                assert False, f'{D=}'
                aryidx, r = r.split('][')
                aryidx = Var.FromVal(self, aryidx)
##                aryidx = int(aryidx)
                r, w = r.split('+:')
                r = Var.FromVal(self, r)
                w = Var.FromVal(self, w)
##                assert False, f'{(aryidx, r, w)}'
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
        
        self.body.Addline(('expr', (op, D, S0, S1, S2), eid))
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
            ldict = lvars[block.entry] = {}
            if block.exloc != None:
                ito[block.exloc] = ito.get(block.exloc, []) + [block.entry]
                to[block.entry] = to.get(block.entry, []) + [block.exloc]
            if block.fall != 'EOF' and block.fall != None:
                ito[block.fall] = ito.get(block.fall, []) + [block.entry]
                fto[block.fall] = fto.get(block.fall, []) + [block.entry]
                to[block.entry] = to.get(block.entry, []) + [block.fall]
            
            for i,line in enumerate(block.body):
                if line[0] == 'decl':
                    ldict[line[1]] = [i, None]
                    k[line[1]] = line[2]
                elif line[0] == 'expr':
                    if line[1][0] in ['call']:
                        continue
                    if line[1][0] == 'argld':

                        ldict[line[1][1]] = [i, None]
                        k[line[1][1]] = line[1][3]

                    if line[1][0] in usesRd:
                        args = line[1][1:][:4]
                    else:
                        args = line[1][2:][:3]

                    for arg in args:
                        if type(arg.name) == str and arg.name[-1]!=':':
                            if arg.name[-2:] == '.&':
                                arg = Var(arg.name[:-2], arg.kind.Deref())
                            if arg not in ldict:
                                ldict[arg] = ['pre', line[2]]
                            elif type(ldict[arg][1]) != str:
                                ldict[arg][1] = line[2]
                            else:
                                pass

                elif line[0] in ['regrst', 'memsave', 'regrstbit', 'memsavebit', 'unreachable']: pass
                else: assert False, f'Unknown command `{line[0]}` of `{line}`'
##                    print(line)
##                    err

        From = False
        for block in body[:]:
            if block.entry not in fto or fto[block.entry] == []:
                if block.entry not in ito or ito[block.entry] == []:
                    self.func['body'].remove(block)
                    if block.fall != 'EOF' and block.fall != None:
                        ito[block.fall].remove(block.entry)
                        fto[block.fall].remove(block.entry)
                else:
                    block.From = ito[block.entry][0]
        run = True
        while run:
            run = False
            for block in body:
                ldict = lvars[block.entry]
                for var, life in ldict.items():
                    if life[0] == 'pre':
                        for precur in ito.get(block.entry, []):
                            if var not in lvars[precur]:
                                lvars[precur][var] = ['pre', 'post']
                                run = True
                                continue
                            if lvars[precur][var][1] != 'post':
                                lvars[precur][var][1] = 'post'
                                run = True
        for block in body:
            ldict = lvars[block.entry]
            for var, life in ldict.items():
                if life[1] == 'post':
                    for succ in to.get(block.entry, []):
                        if var not in lvars[succ]:
                            for i,b in enumerate(body):
                                if b.entry == succ:
                                    nline = ('undecl', var, k[var])
                                    if nline not in body[i].body:
                                        body[i].body.insert(0, nline)
                                    break
                            else:
                                bad
                else:
                    for i,b in enumerate(block.body):
                        if b[0] == 'expr' and b[2] == life[1]:

                            block.body.insert(i+1, ('undecl', var, None))
                            break
                    else:
                        r = 0
                        for i,b in enumerate(block.body):
                            if b[0] == 'expr' and b[1][1] == var:
                                if b[1][0] in nullret:
                                    l = list(b)
                                    li = list(l[1])
                                    li[1] = NoVar
                                    l[1] = li
                                    block.body[i] = tuple(l)
                                else:
                                    idx = block.body.index(b)
                                    r = i - idx
                                    assert block.body[i-r] == b, f'Ummm, desync internally tried to delete wrong expr\n`{block.body[i-r]}`\nInstead Of:\n`{b}`'
                                    del block.body[i-r]
                                    r += 1
                        for i,b in enumerate(block.body):
                            if b[0] == 'decl' and b[1] == var:
                                del block.body[i]
                                break
                        else:
                            print(f'Failed to delete declare {var=}')
                            print(f'Last used at {life[1]} from {life}')
                            bad
        
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

def ResolveTypes():
    queue = list(Statics.structs.keys())
    while queue != []:
        n = queue[0]
        if Statics.structs[n]['size']:
            del queue[0]
            continue
        RecuSolveType(queue[0])
        del queue[0]

def RecuSolveType(name, stk = ()):
    assert name not in stk, f'Type `{name}` is self referential'
    stk = stk + (name,)
    for argname, arg in Statics.structs[name]['args'].items():
        kind = arg['type']
        strk = str(TreeToKind(kind))
        if strk in Statics.structs and Statics.structs[strk]['size']:
            width = Statics.structs[strk]['size']
        elif strk in Statics.structs:
            RecuSolveType(strk, stk)
            width = Statics.structs[strk]['size']
            assert width != None, f'Recu failure'
        else:
            kind = Type.FromStr(strk)
            width = kind.OpWidth()
            assert width != None, f'Bad kind `{strk}` has no width'
        align = AlignOf(width)
        Statics.structs[name]['args'][argname]['type'] = Type.FromStr(strk)
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



def Compile(filepath, verbose = False, optimize = True):
    global funcs, syms, ind, tid, eid, srcs, inter, tree, txt
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

    funcs = {}
    inter = HLIR()

    LHL.Init(sys.modules[__name__])

    try:
        Gen(tree)
    except Exception as e:
        
        raise e

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

##    if verbose:
##        print('\nOptimized LLIR:')
##        print(repr(llir))
##    with open('out.llr', 'w') as f:
##        f.write(repr(llir))

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

        if not os.path.exists("../.sim/Icarus Verilog-sim/dev"): os.mkdir("../.sim/Icarus Verilog-sim/dev")
        with open("../.sim/Icarus Verilog-sim/dev/mem", "wb") as f:
            for hx in program.values():
                f.write(bytearray.fromhex(hx)[::-1])
    else:
        pyperclip.copy(mif)

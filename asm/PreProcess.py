def PopToken(string):
    string = string.lstrip(' \t')
    if len(string) == 0: return '', ''
    c = string[0]
    buf = ''
    while True:
        if len(string) == 0: break
        c = string[0]
        if c.isalnum() or c == '_':
            while c.isalnum() or c == '_':
                buf += c
                string = string[1:]
                if len(string) == 0: break
                c = string[0]
            ws = string
            string = string.lstrip(' \t')
            ws = ws[:-len(string)]
            if len(string) >= 2 and string[:2] == '##':
                string = string[2:].lstrip(' \t')
                continue
        else:
            buf = c
            string = string[1:]
            ws = string
            string = string.lstrip(' \t')
            ws = ws[:len(ws)-len(string)]
        break
    return (buf, ws), string

def Expand(sbuf, s):
    global reps
    if sbuf[2][0] == '#' and sbuf[3][0] == 'POPREP':
        reps = reps[:-1]
        return sbuf[:-2], s
    if sbuf[2][0] == '#' and sbuf[3][0] == 'undef':
        (name, ws), s = PopToken(s)
        del reps[0][name]
        return sbuf[:-2], '\n'+s
    if sbuf[0][0] == '#' and sbuf[1][0] == 'define':
        name = sbuf[2][0]
        if sbuf[3][0] == '(':
            args = []
            while True:
                (tkn, ws), s = PopToken(s)
                args.append(tkn)
                (tkn, _), s = PopToken(s)
                if tkn != ')':
                    assert tkn == ','
                else:
                    break
            l, s = PopLine(s, exp=False)
            reps[0][name] = (args, ''.join([x+y for x, y in l])[:-1])
            return [], '\n'+s
        else:
            s = sbuf[3][0] + sbuf[3][1] + s
            l, s = PopLine(s, exp=False)
            reps[0][name] = ((), ''.join([x+y for x, y in l])[:-1])
            #reps[0][name] = ((), sbuf[3][0])
            return [], '\n'+s

    if sbuf[1][0] == '#' and sbuf[2][0] == 'define': return sbuf, s
##    print(reps)
    for scope in reps[::-1]:
        for k, v in scope.items():
            if sbuf[-1][0] == k and v[0]==():
                sbuf[-1] = ('', '')
                s = v[1] +' ' + s
                return sbuf, s
            elif sbuf[-2][0] == k and sbuf[-1][0] == '(':
                args = []
                while True:
                    tkn, s = PopArg(s)
                    args.append(tkn)
                    (tkn, ws), s = PopToken(s)
                    if tkn != ')':
                        assert tkn == ','
                    else:
                        break
                assert len(args) == len(v[0]), f'({len(args)=}) != ({len(v[0])=})'
                reps.append({})
                for n, r in zip(v[0], args):
                    reps[-1][n] = ((), r)
                s = v[1] +' #POPREP ' + s 
                sbuf[-2:] = []
                return sbuf, s
    return sbuf, s

reps = [{}]

def PopArg(s):
    idnt = 0
    buf = ''
    while s != '':
        (tkn, ws), s = PopToken(s)
        if tkn in '([{':
            idnt += 1
        if tkn in ')]},':
            idnt -= 1
            if idnt < 0:
                return buf, tkn +' '+ s
        buf += tkn + ws
    assert False, f'Unclosed argument'
        

def PopLine(s, exp = True):
    ident = 0
    buf = [('', ''), ('', ''), ('', ''), ('', '')]
    while s != '' and (ident > 0 or buf[-1][0] != '\n'):
        (tkn, ws), s = PopToken(s)
        buf.append((tkn, ws))
        if exp:
            sbuf = buf[-4:]
##            print(sbuf, repr(s))
            sbuf, s = Expand(sbuf, s)
##            print(sbuf, repr(s))
            buf[-4:] = sbuf
    return buf, s

def Handle(s):
    global reps
    reps = [{}]
    o = ''
    while True:
##        print(f'k={k}')
        k, s = PopLine(s)
        o += ''.join([x+y for x,y in k])
        if s == '': break
    return o

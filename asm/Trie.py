class Trie:
    def __init__(self):
        self.children = {} #character -> (numUses, futureChars, Trie)

    def AddStr(self, string):
        if string[-1] != '\x00':
            string += '\x00'
        nchar = string[0]
        string  = string[1:]
        fchars = set(string)
        child = self.children.get(nchar, [0, set(), Trie()])
        child[0] += 1
        child[1] |= fchars
        if len(string) > 0:
            child[2].AddStr(string)
        self.children[nchar] = child

    def Lookup(self, substr):
        k = self._Lookup(substr+'\x00')
        if k != None:
            return k[:-1]

    def _Lookup(self, substr):
        if len(substr) == 0:
            return ''

        keys = [x[0] for x in sorted(list(self.children.items()), key = lambda x:x[1][0], reverse=True)]
        for key in keys:
            data = self.children[key]
            if substr[0] == key:
                k = self.children[key][2]._Lookup(substr[1:])
                if k == None: return None
                return key + k
        for key in keys:
            data = self.children[key]
            if substr[0] in data[1]:
                k = self.children[key][2]._Lookup(substr)
                if k == None: return None
                return key + k
        return None

    def ReduceStr(self, msg):
        omsg = msg
        fin = ''
        while msg != '':
            nmsg = msg[:-1]
            res = self.Lookup(nmsg + fin)
            if res != omsg:
                fin = msg[-1] + fin
            msg = msg[:-1]
        return fin
        
        

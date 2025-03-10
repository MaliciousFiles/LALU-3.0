import AssemblerV3 as Asmblr
from AssemblerV3 import ResolveInstr

def DictFind(d, v):
    return [k0 for k0, v0 in list(d.items()) if v0 == v]

class Blob:
    def __init__(self, name, data, code, labels, links, externs, using):
        self.name = name
        self.data = data
        self.code = code
        self.labels = labels
        self.externs = externs
        self.links = links
        self.using = using
    def __repr__(self):
        return f'Blob(name = {self.name}, data={self.data}, code={self.data}, labels={self.labels}, links={self.links}, externs={self.externs}, using={self.using})'

class Web:
    def __init__(self, entry):
        self.blobs = [entry]
        name = entry.name
        self.sls = ScopedLabelSet.FromBlob(entry)
    def AddBlob(self, blob):
        self.blobs.append(blob)
        self.sls.AddBlob(blob)
    def StickBlobs(self):
        currAddr = 32
        for blob in self.blobs:
            nCode = {}
            nLbls = dict(blob.labels)
            orig = min(blob.code.keys())
            for addr, code in blob.code.items():
                nAddr = addr - orig + currAddr
                if addr in blob.labels.values():
                    labels = DictFind(blob.labels, addr)
                    for label in labels:
                        nLbls[label] = nAddr
                    nCode[nAddr] = code
            blob.code = nCode
            blob.labels = nLbls
            currAddr = max(list(nCode.keys())+[0]) + 32
        
                    
        
        

class ScopedLabelSet():
    def FromBlob(entry):
        return ScopedLabelSet(curr = entry.name,
                              data = {entry.name: entry.labels},
                              links = {entry.name: entry.links},
                              usings = {entry.name: entry.using})
    def __init__(self, curr, data, links, usings):
        self.curr = curr    #Current file being processed
        self.data = data    #Dict of dicts where key = file_name -> [{lbl -> addr}, externs: str[]]
        self.links = links  #Dict of keys to linked files
        self.usings = usings#Dict of keys to usings
    def __repr__(self):
        return f'Blob(curr={self.curr}, data={self.data}, links={self.links}, usings={self.usings})'
    def __getitem__(self, lbl):
        locs, _, = self.data[self.curr]
        if lbl in locs:
            return locs[lbl]        #look in local scope first
        usings = self.usings[self.curr]
        for link in links[self.curr]:
            locs, exts, = self.data[link]
            if link in usings:
                if lbl in exts:
                    return locs[lbl]    #Then in externs of linked files with using
            else:
                if '.' in lbl:
                    src, slbl = lbl.split('.', maxsplit=1)
                    if src == link and lbl in exts:
                        return locs[lbl]    #Then in externs of linked files when qualified
        assert False, f'Could not find `{lbl}` from `{self.curr}`'
        #Now an error has occured
        for link in links[self.curr]:
            locs, exts, = self.data[link]
    def AddBlob(self, blob):
        self.data[blob.name] = blob.labels
        self.links[blob.name] = blob.links
        self.usings[blob.name] = blob.using
        
            

def BuildSegment(blob, labels):
    segmem = {}
    for locAddr, code in block.codes.items():
        hx, ex = ResolveInstr(code, labels)
        segmem[locAddr] = hx
        if ex:
            segmem[locAddr+32] = ex
    return segmem

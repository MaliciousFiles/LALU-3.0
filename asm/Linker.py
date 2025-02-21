import AssemblerV3 as Asmblr
from Asmblr import ResolveInstr

class Blob:
    def __init__(self, data, code, labels, externs):
        self.data = data
        self.code = code
        self.labels = labels
        self.externs = externs
    def __repr__(self):
        return f'Blob(data={self.data}, code={self.data}, labels={self.labels}, externs={self.externs})'

class ScopedLabelSet():
    def __init__(self, curr, data, links, usings):
        self.curr = curr    #Current file being processed
        self.data = data    #Dict of dicts where key = file_name -> [{lbl -> addr}, externs: str[]]
        self.links = links
        self.usings = usings
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
        #Now an error has occured
        for link in links[self.curr]:
            locs, exts, = self.data[link]
            

def BuildSegment(blob, labels):
    segmem = {}
    for locAddr, code in block.codes.items():
        hx, ex = ResolveInstr(code, labels)
        segmem[locAddr] = hx
        if ex:
            segmem[locAddr+32] = ex
    return segmem

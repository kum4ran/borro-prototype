import json,os,sys
S=sys.argv[1]; OUT=sys.argv[2]
names=json.load(open(sys.argv[3]))  # design/prototype/photo-names.json: photo name -> imageRef
ref2name={v:k for k,v in names.items()}
page=json.load(open(S+'/figma/proto.json'))['nodes']['377:1195']['document']
def hexc(c,o=1):
    a=c.get('a',1)*o; h='%02X%02X%02X'%tuple(round(c[k]*255) for k in 'rgb')
    return h if a>=0.999 else '%s@%d'%(h,round(a*100))
W={400:'R',500:'M',600:'S',700:'B',800:'X'}
SKIP={'Status bar','Home indicator','Bottom navigation'}
os.makedirs(OUT,exist_ok=True)
sheets=[]
for s in page['children']:
    if s['type']!='SECTION' or s['name'].startswith('Countdown'): continue
    for f in s['children']:
        if f['type']!='FRAME': continue
        ox,oy=f['absoluteBoundingBox']['x'],f['absoluteBoundingBox']['y']
        L=['# '+f['name']+' bg='+'|'.join(hexc(x['color']) for x in f.get('fills',[]) if x['type']=='SOLID')]
        hasnav=[False]; issheet=[False]
        def walk(n,d):
            if n.get('visible') is False: return
            if n['name'] in SKIP:
                if n['name']=='Bottom navigation':
                    hasnav[0]=True
                    act=[c for c in json.dumps(n).split('"characters": "')[1:]]
                    # find active tab by blue text
                    for t in [x for x in [n] ]: pass
                return
            if 'Close sheet' in n['name'] or n['name'].lower() in ('scrim','sheet scrim'): issheet[0]=True
            b=n.get('absoluteBoundingBox') or {}
            g='%d,%d,%dx%d'%(round(b.get('x',0)-ox),round(b.get('y',0)-oy),round(b.get('width',0)),round(b.get('height',0)))
            fl=[]
            for x in n.get('fills') or []:
                if x.get('visible') is False: continue
                if x['type']=='SOLID': fl.append(hexc(x['color'],x.get('opacity',1)))
                elif x['type']=='IMAGE': fl.append('IMG:'+ref2name.get(x.get('imageRef'),'?'))
                elif x['type'].startswith('GRAD'): fl.append('grad')
            st=[hexc(x['color']) for x in n.get('strokes') or [] if x.get('type')=='SOLID' and x.get('visible') is not False]
            r=n.get('cornerRadius'); tap=' *' if n.get('interactions') else ''
            if n['type']=='TEXT':
                t=n.get('style',{})
                col=fl[0] if fl else ''
                L.append('  '*d+'T %s %s%g %s "%s"%s'%(g,W.get(t.get('fontWeight'),t.get('fontWeight')),t.get('fontSize',0),col,n.get('characters','').replace('\n','\\n'),tap)); return
            isicon = n['type'] in ('INSTANCE','FRAME') and b.get('width',99)<=32 and b.get('height',99)<=32 and all(c['type'] in ('VECTOR','BOOLEAN_OPERATION','GROUP','ELLIPSE','RECTANGLE','LINE') for c in n.get('children',[])) and n.get('children') and not fl
            if isicon:
                vs=[]
                def vc(m):
                    for x in m.get('strokes') or []:
                        if x.get('type')=='SOLID': vs.append(hexc(x['color']))
                    for x in m.get('fills') or []:
                        if x.get('type')=='SOLID': vs.append('f'+hexc(x['color']))
                    for c in m.get('children',[]): vc(c)
                vc(n)
                L.append('  '*d+'I %s %s %s%s'%(n['name'][:24],g,(vs[0] if vs else ''),tap)); return
            vis=fl or st or r or tap or n['type'] in ('VECTOR','ELLIPSE','LINE')
            if vis:
                extra=''
                if st: extra+=' s=%s/%g'%(st[0],n.get('strokeWeight',1))
                if r: extra+=' r=%g'%r
                sh=[e for e in n.get('effects') or [] if e['type']=='DROP_SHADOW' and e.get('visible') is not False]
                if sh: extra+=' sh'
                L.append('  '*d+'%s %s %s %s%s%s'%(n['type'][0],n['name'][:22].replace(' ','_'),g,'|'.join(fl),extra,tap))
                d2=d+1
            else: d2=d
            if n['type'] in ('VECTOR','BOOLEAN_OPERATION'): return
            for c in n.get('children',[]): walk(c,d2)
        for c in f.get('children',[]): walk(c,0)
        code=f['name'].split(' ')[0]
        if issheet[0]: sheets.append(code)
        L[0]+=(' NAV' if hasnav[0] else ' NONAV')+(' SHEET' if issheet[0] else '')
        open(OUT+'/'+code+'.txt','w').write('\n'.join(L)+'\n')
print('sheets',sheets)

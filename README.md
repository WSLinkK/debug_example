To reproduce bug:

change the line 1151 under `green_igen/df.py` from
```
modchg_offset = -numpy.ones((chgcell.natm,8), dtype=int)
```
to
```
lmax = auxcell._bas[:,gto.ANG_OF].max()
modchg_offset = -numpy.ones((chgcell.natm,lmax+1), dtype=int)
```

Suspected line
`green_igen/outcore.py` line 252 `for istep, mat in enumerate(lib.map_with_prefetch(process, auxranges)):`

from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import subprocess
root=Path(__file__).resolve().parent
names=[p.stem.upper() for p in root.glob('*.svg') if p.stem != 'contact_sheet_720p']
for name in names:
    src=root/f'{name.lower()}.svg'
    dst=root/f'{name.lower()}.png'
    subprocess.run(['magick','-background','none',str(src),str(dst)],check=True)
canvas=Image.new('RGBA',(1280,720),'#17212b')
d=ImageDraw.Draw(canvas)
try:
    head=ImageFont.truetype('arial.ttf',26)
    label=ImageFont.truetype('arialbd.ttf',16)
except OSError:
    head=ImageFont.load_default();label=head
d.text((50,18),'RULE REWRITE / WORLD ART',font=head,fill='#f1ebd8')
for i,name in enumerate(names):
    x=33+(i%8)*155;y=68+(i//8)*157
    d.rounded_rectangle((x,y,x+143,y+145),radius=11,fill='#202b35',outline='#51616a',width=2)
    img=Image.open(root/f'{name.lower()}.png').convert('RGBA').resize((105,105),Image.Resampling.LANCZOS)
    canvas.alpha_composite(img,(x+19,y+2))
    bb=d.textbbox((0,0),name,font=label)
    d.text((x+71-(bb[2]-bb[0])/2,y+121),name,font=label,fill='#f1ebd8')
canvas.convert('RGB').save(root/'contact_sheet_720p.png')
# Size check: all items at the approximate 48 px board-cell drawing size.
small=Image.new('RGBA',(1280,560),'#17212b')
ds=ImageDraw.Draw(small)
ds.text((30,15),'48 PX CELL READABILITY',font=head,fill='#f1ebd8')
for i,name in enumerate(names):
    x=30+(i%10)*124;y=60+(i//10)*125
    ds.rectangle((x,y,x+94,y+94),fill='#26333d',outline='#53666c',width=1)
    im=Image.open(root/f'{name.lower()}.png').convert('RGBA').resize((48,48),Image.Resampling.LANCZOS)
    small.alpha_composite(im,(x+23,y+16))
    bb=ds.textbbox((0,0),name,font=label)
    ds.text((x+47-(bb[2]-bb[0])/2,y+74),name,font=label,fill='#f1ebd8')
small.convert('RGB').save(root/'cell_scale_preview.png')
print('rendered',len(names),'PNGs and 2 sheets')
